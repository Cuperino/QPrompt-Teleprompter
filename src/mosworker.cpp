/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2026 Javier O. Cordero Pérez
 **
 ** This file is part of QPrompt.
 **
 ** This program is free software: you can redistribute it and/or modify
 ** it under the terms of the GNU General Public License as published by
 ** the Free Software Foundation, version 3 of the License.
 **
 ** This program is distributed in the hope that it will be useful,
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 ** GNU General Public License for more details.
 **
 ** You should have received a copy of the GNU General Public License
 ** along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **
 ****************************************************************************/

#include "mosworker.h"

#include "../qprompt_version.h"

#include <QDateTime>
#include <QElapsedTimer>
#include <QLoggingCategory>
#include <QRandomGenerator>
#include <QStringList>
#include <QTimer>
#include <QUrl>

#include <algorithm>
#include <utility>

#include <imos/device.h>
#include <imos/session/in_memory_store.h>
#include <imos/transports/ws40.h>
#if defined(Q_OS_WASM)
#include <imos/transports/ws40_emscripten.h>
#endif
#if defined(QPROMPT_MOS_TCP28)
#include <imos/transports/tcp28.h>
#endif

Q_LOGGING_CATEGORY(lcMos, "qprompt.mos")

// The transport enum from MosInputSource, mirrored here so this TU does not
// depend on the facade header (which would drag Qt Quick into the engine).
namespace {
enum MosTransportValue { TransportWs40 = 0, TransportWs40Passive = 1, TransportTcp28 = 2 };

// Pin the numeric values the ctrlCommand signal documents to the library's
// enums, so a library reorder cannot silently remap prompter actions.
static_assert(static_cast<int>(imos::profiles::CtrlCommand::Ready) == 0);
static_assert(static_cast<int>(imos::profiles::CtrlCommand::Execute) == 1);
static_assert(static_cast<int>(imos::profiles::CtrlCommand::Pause) == 2);
static_assert(static_cast<int>(imos::profiles::CtrlCommand::Stop) == 3);
static_assert(static_cast<int>(imos::profiles::CtrlCommand::Signal) == 4);
static_assert(static_cast<int>(imos::profiles::CtrlScope::RunningOrder) == 0);
static_assert(static_cast<int>(imos::profiles::CtrlScope::Story) == 1);
static_assert(static_cast<int>(imos::profiles::CtrlScope::Item) == 2);

struct QtMosClock final : imos::IClock {
    QtMosClock() { timer.start(); }
    imos::MonotonicTime now() override { return imos::MonotonicTime{timer.elapsed()}; }
    imos::WallClockTime wallClock() override { return imos::WallClockTime{QDateTime::currentMSecsSinceEpoch()}; }
    QElapsedTimer timer;
};

struct QtMosRandom final : imos::IRandom {
    std::uint64_t next() override { return QRandomGenerator::global()->generate64(); }
};

struct QtMosLogger final : imos::ILogger {
    void log(imos::LogLevel level, std::string_view message) noexcept override
    {
        const auto text = QString::fromUtf8(message.data(), static_cast<qsizetype>(message.size()));
        switch (level) {
        case imos::LogLevel::Warning:
            qCWarning(lcMos).noquote() << text;
            break;
        case imos::LogLevel::Error:
            qCCritical(lcMos).noquote() << text;
            break;
        default:
            qCDebug(lcMos).noquote() << text;
            break;
        }
    }
};

// Uniform host interface over the concrete transports (they share ITransport
// but start/stop/pump/nextDeadline are per-class).
struct TransportHolder {
    virtual ~TransportHolder() = default;
    virtual imos::Result<void> start() = 0;
    virtual void stop() = 0;
    virtual void pump(imos::PeerSession &session) = 0;
    virtual bool isConnected(imos::Channel channel) const = 0;
    virtual std::optional<imos::MonotonicTime> nextDeadline() const = 0;
    virtual imos::ITransport *transport() = 0;
};

template<typename Client>
struct TransportHolderImpl final : TransportHolder {
    template<typename... Args>
    explicit TransportHolderImpl(Args &&...args)
        : client(std::forward<Args>(args)...)
    {
    }
    imos::Result<void> start() override { return client.start(); }
    void stop() override { client.stop(); }
    void pump(imos::PeerSession &session) override { client.pump(session); }
    bool isConnected(imos::Channel channel) const override { return client.isConnected(channel); }
    std::optional<imos::MonotonicTime> nextDeadline() const override { return client.nextDeadline(); }
    imos::ITransport *transport() override { return &client; }
    Client client;
};

// Profile 5 bridge: roCtrl and roItemCue arrive here during Device::poll(),
// on the MOS thread, and are forwarded as queued signals to the GUI. onCtrl
// returns success once the command is dispatched — the roAck therefore means
// "accepted and handed to the prompter", not "executed"; the GUI acts
// asynchronously and a blocking wait here could deadlock against a modal UI.
struct ControlBridge final : imos::profiles::IControlSink {
    imos::Result<void> onCtrl(const imos::profiles::CtrlRequest &request) override
    {
        worker->reportCtrl(static_cast<int>(request.command),
                           static_cast<int>(request.scope),
                           QString::fromStdString(request.roID),
                           QString::fromStdString(request.storyID),
                           QString::fromStdString(request.itemID));
        return {};
    }
    void onItemCue(const imos::profiles::ItemCue &cue) override
    {
        worker->reportItemCue(QString::fromStdString(cue.roID),
                              QString::fromStdString(cue.storyID),
                              QString::fromStdString(cue.itemID),
                              QString::fromStdString(cue.roEventType),
                              QString::fromStdString(cue.roEventTime));
    }
    MosWorker *worker = nullptr;
};

// Raw-sink opt-out of the Profile 2 shadow model: QPrompt holds no running
// order state yet, so roCtrl targets must be taken on faith instead of being
// NACKed against an empty model. Construction messages are accepted and
// dropped. Replaced by real Profile 2 support later.
struct NullRunningOrderSink final : imos::profiles::IRunningOrderSink {
    imos::Result<void> onRoCreate(const imos::codec::Message &) override { return {}; }
    imos::Result<void> onRoReplace(const imos::codec::Message &) override { return {}; }
    imos::Result<void> onRoMetadataReplace(const imos::codec::Message &) override { return {}; }
    imos::Result<void> onRoDelete(const imos::codec::Message &) override { return {}; }
    imos::Result<void> onRoElementAction(const imos::codec::Message &) override { return {}; }
    imos::Result<void> onRoReadyToAir(const imos::codec::Message &) override { return {}; }
    imos::Result<void> onRoElementStat(const imos::codec::Message &) override { return {}; }
};

QString describePeer(const imos::profiles::PeerMachineInfo &peer)
{
    const auto &info = peer.info;
    QStringList parts;
    const auto manufacturer = QString::fromStdString(info.manufacturer);
    const auto model = QString::fromStdString(info.model);
    const auto swRev = QString::fromStdString(info.swRev);
    if (!manufacturer.isEmpty())
        parts << manufacturer;
    if (!model.isEmpty())
        parts << model;
    if (!swRev.isEmpty())
        parts << swRev;
    QString description = parts.join(QChar(QChar::Space));
    if (peer.hasSupportedProfiles) {
        QStringList profiles;
        for (int i = 0; i < imos::profiles::kProfileCount; ++i)
            if (info.profiles[static_cast<std::size_t>(i)])
                profiles << QString::number(i);
        if (!profiles.isEmpty())
            description += QStringLiteral(" — MOS %1, profiles %2")
                               .arg(QString::fromStdString(info.mosRev), profiles.join(QStringLiteral(", ")));
    }
    return description;
}

} // namespace

struct MosWorker::Engine {
    QtMosClock clock;
    QtMosRandom random;
    QtMosLogger logger;
    imos::InMemoryMessageStore store;
    ControlBridge control;
    NullRunningOrderSink runningOrders;
    // Device holds a raw ITransport*; it is declared after the transport so
    // it is destroyed first.
    std::unique_ptr<TransportHolder> transport;
    std::unique_ptr<imos::Device> device;
    bool running = false;
    bool peerInfoRequested = false;
    int lastStatus = -1;
    QString lastMessage;
    QString lastPeerDescription;
};

MosWorker::MosWorker(QObject *parent)
    : QObject(parent)
    , m_timer(new QTimer(this))
{
    m_timer->setSingleShot(true);
    m_timer->setTimerType(Qt::CoarseTimer);
    connect(m_timer, &QTimer::timeout, this, &MosWorker::tick);
}

MosWorker::~MosWorker()
{
    stopSession();
}

void MosWorker::startSession(const MosSessionSettings &settings)
{
    stopSession();
    m_engine = std::make_unique<Engine>();
    auto &engine = *m_engine;

    const auto wire = settings.utf8Wire ? imos::encoding::WireEncoding::Utf8 : imos::encoding::WireEncoding::Ucs2Be;

    imos::SessionConfig session;
    session.mosID = settings.mosID.toStdString();
    session.ncsID = settings.ncsID.toStdString();
    session.keepAliveIntervalMillis = 30'000; // spec floor: no faster than 30 s
    session.wireEncode.encoding = wire;
    session.wireDecode.encoding = wire;

    imos::profiles::MachineInfo info;
    info.manufacturer = "Cuperino";
    info.model = "QPrompt";
    info.swRev = QPROMPT_VERSION_STRING;
    info.id = session.mosID;
    info.deviceType = imos::profiles::DeviceType::Mos;
    // Profiles 0 (basic communication) and 5 (item control). The spec chains
    // P5 onto P1+P2; those are advertised once QPrompt really implements
    // them — no flag is claimed that is not real.
    info.profiles = {true, false, false, false, false, true, false, false};
    info.mosRev = "4.0";
    info.opTime = engine.clock.wallClock();

    const QUrl url(settings.url);
    if (settings.transport == TransportTcp28) {
#if defined(QPROMPT_MOS_TCP28)
        imos::transports::tcp28::EndpointConfig config;
        config.role = imos::transports::tcp28::Role::Device;
        config.peerHost = (url.host().isEmpty() ? settings.url : url.host()).toStdString();
        if (url.port() > 0)
            config.ports.mom = url.port();
        config.wireEncoding = wire;
        engine.transport = std::make_unique<TransportHolderImpl<imos::transports::tcp28::Tcp28Endpoint>>(
            std::move(config), &engine.clock, &engine.random, &engine.logger);
        auto *endpoint = &static_cast<TransportHolderImpl<imos::transports::tcp28::Tcp28Endpoint> *>(engine.transport.get())->client;
        endpoint->setErrorHandler([this](imos::Channel, const std::string &diagnostic) {
            const auto text = QString::fromStdString(diagnostic);
            // May fire on the transport's I/O thread; marshal to this thread.
            QMetaObject::invokeMethod(this, [this, text] {
                if (m_engine)
                    setStatus(m_engine->lastStatus, text);
            }, Qt::QueuedConnection);
        });
#else
        setStatus(Error, tr("Legacy MOS 2.8 TCP is not available on this platform."));
        m_engine.reset();
        return;
#endif
    } else {
        imos::transports::ws40::ClientConfig config;
        config.endpointUrl = settings.url.toStdString();
        config.mosID = session.mosID;
        config.ncsID = session.ncsID;
        config.channels = {imos::Channel::Mom, imos::Channel::Ro};
        config.passive = settings.transport == TransportWs40Passive;
        config.wireEncoding = wire;
        if (!settings.username.isEmpty())
            config.auth = imos::ws40::BasicCredentials{settings.username.toStdString(), settings.password.toStdString()};
#if defined(Q_OS_WASM)
        using WsClient = imos::transports::ws40::Ws40EmscriptenClient;
#else
        using WsClient = imos::transports::ws40::Ws40Client;
#endif
        engine.transport = std::make_unique<TransportHolderImpl<WsClient>>(
            std::move(config), &engine.clock, &engine.random, &engine.logger);
        auto *client = &static_cast<TransportHolderImpl<WsClient> *>(engine.transport.get())->client;
        client->setErrorHandler([this](imos::Channel, const std::string &diagnostic) {
            const auto text = QString::fromStdString(diagnostic);
            QMetaObject::invokeMethod(this, [this, text] {
                if (m_engine)
                    setStatus(m_engine->lastStatus, text);
            }, Qt::QueuedConnection);
        });
    }

    engine.control.worker = this;
    engine.device = std::make_unique<imos::Device>(
        imos::DeviceConfig{std::move(session), std::move(info)},
        imos::PeerSession::Dependencies{&engine.clock, engine.transport->transport(), &engine.store,
                                        &engine.logger, &engine.random, nullptr});
    engine.device->attach(engine.control);
    engine.device->attach(engine.runningOrders);

    if (const auto started = engine.transport->start(); !started.ok()) {
        setStatus(Error, QString::fromStdString(started.error().message));
        m_engine.reset();
        return;
    }

    engine.running = true;
    setStatus(Connecting, QString());
    scheduleTick();
}

void MosWorker::stopSession()
{
    m_timer->stop();
    if (!m_engine)
        return;
    m_engine->running = false;
    // Halt the transport's I/O threads while the Device (which holds a raw
    // pointer to it) is still alive; the Engine destructor then tears down
    // Device before transport.
    if (m_engine->transport)
        m_engine->transport->stop();
    m_engine.reset();
    setStatus(Disabled, QString());
}

void MosWorker::onMarkerPassed(int index, const QString &name)
{
    // Outbound roItemCue seam: needs Profile 4 story ingestion to resolve a
    // marker into a real roID/storyID/itemID; fabricated IDs would only be
    // noise on the wire, so for now the crossing is just logged.
    qCDebug(lcMos) << "Marker passed" << index << name << "(roItemCue deferred until Profile 4)";
}

void MosWorker::reportCtrl(int command, int scope, const QString &roID, const QString &storyID, const QString &itemID)
{
    qCDebug(lcMos) << "roCtrl command" << command << "scope" << scope << roID << storyID << itemID;
    emit ctrlCommand(command, scope, roID, storyID, itemID);
}

void MosWorker::reportItemCue(const QString &roID, const QString &storyID, const QString &itemID, const QString &eventType, const QString &eventTime)
{
    qCDebug(lcMos) << "roItemCue" << roID << storyID << itemID << eventType << eventTime;
    emit itemCueReceived(roID, storyID, itemID, eventType, eventTime);
}

void MosWorker::tick()
{
    if (!m_engine || !m_engine->running)
        return;
    auto &engine = *m_engine;

    engine.transport->pump(engine.device->session());
    engine.device->poll();

    while (auto event = engine.device->nextEvent()) {
        switch (event->type) {
        case imos::SessionEventType::ChannelFault:
        case imos::SessionEventType::ProtocolError:
        case imos::SessionEventType::StoreError:
            qCWarning(lcMos) << "Session event" << static_cast<int>(event->type)
                             << QString::fromStdString(event->diagnostic);
            engine.lastMessage = QString::fromStdString(event->diagnostic);
            break;
        case imos::SessionEventType::DeliveryFailed:
            qCWarning(lcMos) << "Delivery failed for message" << QString::fromStdString(event->messageId);
            break;
        default:
            qCDebug(lcMos) << "Session event" << static_cast<int>(event->type)
                           << QString::fromStdString(event->diagnostic);
            break;
        }
    }

    updateStatus();
    scheduleTick();
}

void MosWorker::updateStatus()
{
    auto &engine = *m_engine;
    const bool connected = engine.transport->isConnected(imos::Channel::Mom);

    if (connected && !engine.peerInfoRequested) {
        engine.peerInfoRequested = true;
        if (const auto requested = engine.device->requestMachineInfo(); !requested.ok())
            qCWarning(lcMos) << "reqMachInfo failed:" << QString::fromStdString(requested.error().message);
    } else if (!connected) {
        // Re-request on the next connect; a failover peer may differ.
        engine.peerInfoRequested = false;
    }

    if (const auto *peer = engine.device->peerMachineInfo()) {
        const auto description = describePeer(*peer);
        if (description != engine.lastPeerDescription) {
            engine.lastPeerDescription = description;
            emit peerInfoChanged(description);
        }
    }

    setStatus(connected ? Connected : Connecting, engine.lastMessage);
}

void MosWorker::setStatus(int status, const QString &message)
{
    if (m_engine) {
        if (m_engine->lastStatus == status && m_engine->lastMessage == message)
            return;
        m_engine->lastStatus = status;
        m_engine->lastMessage = message;
    }
    emit statusChanged(status, message);
}

void MosWorker::scheduleTick()
{
    if (!m_engine || !m_engine->running)
        return;
    auto &engine = *m_engine;
    // Floor: inbound frames are queued by the transport with no wakeup
    // callback, so the engine must look for them on its own cadence.
    constexpr qint64 floorMillis = 25;
    qint64 delay = floorMillis;
    const auto now = engine.clock.now();
    const auto consider = [&delay, now](const std::optional<imos::MonotonicTime> &deadline) {
        if (deadline)
            delay = std::min(delay, std::max<qint64>(0, deadline->millis - now.millis));
    };
    consider(engine.device->nextDeadline());
    consider(engine.transport->nextDeadline());
    m_timer->start(static_cast<int>(delay));
}
