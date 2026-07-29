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

#include "mosinputsource.h"

#include "appcontroller.h"
#include "mosworker.h"

#include <QCoreApplication>
#include <QSettings>
#include <QThread>

// Profile 5 roCtrl vocabulary as carried by MosWorker::ctrlCommand.
namespace {
enum CtrlCommandValue { CtrlReady = 0, CtrlExecute = 1, CtrlPause = 2, CtrlStop = 3, CtrlSignal = 4 };
} // namespace

#if (defined(Q_OS_MACOS) or defined(Q_OS_IOS))
#define QPROMPT_SETTINGS QSettings settings(QCoreApplication::organizationDomain(), QCoreApplication::applicationName())
#else
#define QPROMPT_SETTINGS QSettings settings(QCoreApplication::organizationName(), QCoreApplication::applicationName().toLower())
#endif

MosInputSource::MosInputSource(AppController *controller)
    : AbstractInputSource(controller)
{
    m_initializeSource();
}

MosInputSource::~MosInputSource()
{
    shutdown();
}

void MosInputSource::m_initializeSource()
{
    AbstractInputSource::m_initializeSource();
    m_loadSettings();
    m_startWorker();
    if (m_enabled)
        emit startRequested(m_settings);
}

void MosInputSource::m_startWorker()
{
    m_worker = new MosWorker;
    m_thread = new QThread(this);
    m_thread->setObjectName(QStringLiteral("mos"));
    m_worker->moveToThread(m_thread);
    connect(m_thread, &QThread::finished, m_worker, &QObject::deleteLater);

    connect(this, &MosInputSource::startRequested, m_worker, &MosWorker::startSession);
    connect(this, &MosInputSource::stopRequested, m_worker, &MosWorker::stopSession);
    connect(m_worker, &MosWorker::statusChanged, this, &MosInputSource::onWorkerStatus);
    connect(m_worker, &MosWorker::peerInfoChanged, this, &MosInputSource::onPeerInfo);
    connect(m_worker, &MosWorker::ctrlCommand, this, &MosInputSource::onCtrlCommand);
    connect(m_worker, &MosWorker::itemCueReceived, this, &MosInputSource::onItemCue);
    // roItemCue origination seam: the prompter reports marker crossings
    // through AppController; the worker decides what (if anything) to send.
    connect(m_controller, &AppController::markerPassed, m_worker, &MosWorker::onMarkerPassed);

    m_thread->start();
    // AppController is a leaked singleton, so destructors never run; quitting
    // the app is what tears the MOS thread down.
    connect(QCoreApplication::instance(), &QCoreApplication::aboutToQuit, this, &MosInputSource::shutdown);
}

void MosInputSource::shutdown()
{
    if (!m_thread)
        return;
    // Stop the session synchronously so the transport's I/O threads are down
    // before the event loop quits; the worker never blocks back on the GUI
    // thread, so this cannot deadlock.
    QMetaObject::invokeMethod(m_worker, &MosWorker::stopSession, Qt::BlockingQueuedConnection);
    m_thread->quit();
    if (!m_thread->wait(3000)) {
        // A wedged transport teardown is leaked rather than terminated, to
        // avoid crashing on exit.
        qWarning("MOS thread did not shut down in time; leaking it.");
    }
    m_thread = nullptr;
    m_worker = nullptr;
}

bool MosInputSource::enabled() const
{
    return m_enabled;
}

void MosInputSource::setEnabled(bool enabled)
{
    if (m_enabled == enabled)
        return;
    m_enabled = enabled;
    m_saveSettings();
    if (m_enabled)
        emit startRequested(m_settings);
    else
        emit stopRequested();
    emit enabledChanged();
}

MosInputSource::Status MosInputSource::status() const
{
    return m_status;
}

QString MosInputSource::statusMessage() const
{
    return m_statusMessage;
}

QString MosInputSource::peerDescription() const
{
    return m_peerDescription;
}

QString MosInputSource::mosID() const
{
    return m_settings.mosID;
}

void MosInputSource::setMosID(const QString &mosID)
{
    if (m_settings.mosID == mosID)
        return;
    m_settings.mosID = mosID;
    m_saveSettings();
    emit configChanged();
}

QString MosInputSource::ncsID() const
{
    return m_settings.ncsID;
}

void MosInputSource::setNcsID(const QString &ncsID)
{
    if (m_settings.ncsID == ncsID)
        return;
    m_settings.ncsID = ncsID;
    m_saveSettings();
    emit configChanged();
}

QString MosInputSource::endpointUrl() const
{
    return m_settings.url;
}

void MosInputSource::setEndpointUrl(const QString &url)
{
    if (m_settings.url == url)
        return;
    m_settings.url = url;
    m_saveSettings();
    emit configChanged();
}

MosInputSource::Transport MosInputSource::transport() const
{
    return static_cast<Transport>(m_settings.transport);
}

void MosInputSource::setTransport(Transport transport)
{
    if (m_settings.transport == static_cast<int>(transport))
        return;
    m_settings.transport = static_cast<int>(transport);
    m_saveSettings();
    emit configChanged();
}

bool MosInputSource::utf8Wire() const
{
    return m_settings.utf8Wire;
}

void MosInputSource::setUtf8Wire(bool utf8Wire)
{
    if (m_settings.utf8Wire == utf8Wire)
        return;
    m_settings.utf8Wire = utf8Wire;
    m_saveSettings();
    emit configChanged();
}

QString MosInputSource::username() const
{
    return m_settings.username;
}

void MosInputSource::setUsername(const QString &username)
{
    if (m_settings.username == username)
        return;
    m_settings.username = username;
    m_saveSettings();
    emit configChanged();
}

QString MosInputSource::password() const
{
    return m_settings.password;
}

void MosInputSource::setPassword(const QString &password)
{
    if (m_settings.password == password)
        return;
    m_settings.password = password;
    m_saveSettings();
    emit configChanged();
}

bool MosInputSource::tcp28Available() const
{
#if defined(QPROMPT_MOS_TCP28)
    return true;
#else
    return false;
#endif
}

void MosInputSource::applyAndReconnect()
{
    m_saveSettings();
    if (m_enabled) {
        emit stopRequested();
        emit startRequested(m_settings);
    }
}

void MosInputSource::onWorkerStatus(int status, const QString &message)
{
    const auto newStatus = static_cast<Status>(status);
    if (m_status == newStatus && m_statusMessage == message)
        return;
    m_status = newStatus;
    m_statusMessage = message;
    emit statusChanged();
}

void MosInputSource::onPeerInfo(const QString &description)
{
    if (m_peerDescription == description)
        return;
    m_peerDescription = description;
    emit peerChanged();
}

void MosInputSource::onCtrlCommand(int command, int scope, const QString &roID, const QString &storyID, const QString &itemID)
{
    // Scope (running order vs story vs item) is forwarded for logging but
    // every scope acts on the current script until Profiles 2/4 give QPrompt
    // real running-order state.
    Q_UNUSED(scope)
    Q_UNUSED(roID)
    switch (command) {
    case CtrlReady:
        emit readyPrompter();
        break;
    case CtrlExecute:
        // Absolute command, not a toggle: start or resume, never stop.
        emit startPrompter();
        break;
    case CtrlPause:
        // Absolute pause, unlike the pause() signal whose QML handler toggles.
        emit pausePrompter();
        break;
    case CtrlStop:
        emit stop();
        break;
    case CtrlSignal: {
        QString target = storyID;
        if (!itemID.isEmpty())
            target += (target.isEmpty() ? itemID : QStringLiteral("/") + itemID);
        emit signalCue(target.isEmpty() ? tr("Newsroom signal") : tr("Newsroom signal: %1").arg(target));
        break;
    }
    default:
        break;
    }
}

void MosInputSource::onItemCue(const QString &roID, const QString &storyID, const QString &itemID, const QString &eventType, const QString &eventTime)
{
    Q_UNUSED(roID)
    QString target = storyID;
    if (!itemID.isEmpty())
        target += (target.isEmpty() ? itemID : QStringLiteral("/") + itemID);
    QString text = eventType.isEmpty() ? tr("Cue") : tr("Cue: %1").arg(eventType);
    if (!target.isEmpty())
        text += QStringLiteral(" — ") + target;
    if (!eventTime.isEmpty())
        text += QStringLiteral(" @ ") + eventTime;
    emit signalCue(text);
}

void MosInputSource::m_loadSettings()
{
    QPROMPT_SETTINGS;
    m_enabled = settings.value(QStringLiteral("mos/enabled"), false).toBool();
    m_settings.mosID = settings.value(QStringLiteral("mos/mosID"), QStringLiteral("qprompt.local")).toString();
    m_settings.ncsID = settings.value(QStringLiteral("mos/ncsID"), QString()).toString();
    m_settings.url = settings.value(QStringLiteral("mos/url"), QStringLiteral("ws://127.0.0.1:10540/mos")).toString();
    m_settings.transport = settings.value(QStringLiteral("mos/transport"), 0).toInt();
    m_settings.utf8Wire = settings.value(QStringLiteral("mos/utf8Wire"), false).toBool();
    m_settings.username = settings.value(QStringLiteral("mos/username"), QString()).toString();
    // Stored in plain text like the rest of QSettings; a keychain-backed
    // store is a known follow-up.
    m_settings.password = settings.value(QStringLiteral("mos/password"), QString()).toString();
    if (!tcp28Available() && m_settings.transport == static_cast<int>(Transport::Tcp28))
        m_settings.transport = static_cast<int>(Transport::Ws40);
}

void MosInputSource::m_saveSettings() const
{
    QPROMPT_SETTINGS;
    settings.setValue(QStringLiteral("mos/enabled"), m_enabled);
    settings.setValue(QStringLiteral("mos/mosID"), m_settings.mosID);
    settings.setValue(QStringLiteral("mos/ncsID"), m_settings.ncsID);
    settings.setValue(QStringLiteral("mos/url"), m_settings.url);
    settings.setValue(QStringLiteral("mos/transport"), m_settings.transport);
    settings.setValue(QStringLiteral("mos/utf8Wire"), m_settings.utf8Wire);
    settings.setValue(QStringLiteral("mos/username"), m_settings.username);
    settings.setValue(QStringLiteral("mos/password"), m_settings.password);
}
