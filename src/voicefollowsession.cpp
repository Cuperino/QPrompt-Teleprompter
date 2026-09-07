/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2026 Javier O. Cordero Perez
 **
 ** This file is part of QPrompt.
 **
 ****************************************************************************/

#include "voicefollowsession.h"

#include "offlinespeechrecognizer.h"
#ifdef Q_OS_IOS
#include "applespeechrecognizer.h"
#else
#include "voskspeechrecognizer.h"
#endif

#include <QCoreApplication>
#include <QDir>
#include <QFileInfo>
#include <QStandardPaths>
#include <QTextDocument>
#include <QVariantMap>

#include <algorithm>
#include <cmath>
#include <cstring>
#include <limits>

#ifdef QPROMPT_HAVE_QT_MULTIMEDIA
#include <QAudioDevice>
#include <QAudioFormat>
#include <QAudioSource>
#include <QIODevice>
#include <QMediaDevices>
#endif

namespace {
constexpr int RecognitionSampleRate = 16000;
constexpr int SilenceHoldMilliseconds = 1400;

#ifdef QPROMPT_HAVE_QT_MULTIMEDIA
float normalizedAudioSample(const char *sample, QAudioFormat::SampleFormat format)
{
    switch (format) {
    case QAudioFormat::UInt8:
        return (static_cast<unsigned char>(*sample) - 128.0f) / 128.0f;
    case QAudioFormat::Int16: {
        qint16 value;
        std::memcpy(&value, sample, sizeof(value));
        return value / 32768.0f;
    }
    case QAudioFormat::Int32: {
        qint32 value;
        std::memcpy(&value, sample, sizeof(value));
        return static_cast<float>(value / 2147483648.0);
    }
    case QAudioFormat::Float: {
        float value;
        std::memcpy(&value, sample, sizeof(value));
        return std::isfinite(value) ? std::clamp(value, -1.0f, 1.0f) : 0.0f;
    }
    default:
        return 0.0f;
    }
}
#endif
}

VoiceFollowSession::VoiceFollowSession(QObject *parent)
    : QObject(parent)
    , m_libraryPath(defaultLibraryPath())
    , m_modelPath(defaultModelPath())
{
    m_silenceTimer.setSingleShot(true);
    m_silenceTimer.setInterval(SilenceHoldMilliseconds);
    connect(&m_silenceTimer, &QTimer::timeout, this, &VoiceFollowSession::holdForSilence);

    // Vosk has no iOS build, and dynamically loading an arbitrary unsigned
    // dylib the way VoskSpeechRecognizer does via QLibrary isn't permitted
    // under iOS's code-signing/sandbox model anyway, so iOS is backed by
    // Apple's own on-device Speech framework instead.
#ifdef Q_OS_IOS
    m_recognizer = new AppleSpeechRecognizer;
#else
    m_recognizer = new VoskSpeechRecognizer;
#endif
    m_recognizer->moveToThread(&m_recognitionThread);
    connect(&m_recognitionThread, &QThread::finished, m_recognizer, &QObject::deleteLater);
    connect(this, &VoiceFollowSession::initializeRecognizer,
        m_recognizer, &OfflineSpeechRecognizer::initialize, Qt::QueuedConnection);
    connect(this, &VoiceFollowSession::audioReady,
        m_recognizer, &OfflineSpeechRecognizer::acceptPcm16, Qt::QueuedConnection);
    connect(this, &VoiceFollowSession::resetRecognizer,
        m_recognizer, &OfflineSpeechRecognizer::reset, Qt::QueuedConnection);
    connect(this, &VoiceFollowSession::finishRecognizer,
        m_recognizer, &OfflineSpeechRecognizer::finish, Qt::QueuedConnection);
    connect(m_recognizer, &OfflineSpeechRecognizer::ready,
        this, &VoiceFollowSession::recognizerReady, Qt::QueuedConnection);
    connect(m_recognizer, &OfflineSpeechRecognizer::partialTranscript,
        this, &VoiceFollowSession::acceptTranscript, Qt::QueuedConnection);
    connect(m_recognizer, &OfflineSpeechRecognizer::finalTranscript,
        this, &VoiceFollowSession::acceptTranscript, Qt::QueuedConnection);
    connect(m_recognizer, &OfflineSpeechRecognizer::errorOccurred,
        this, &VoiceFollowSession::recognizerError, Qt::QueuedConnection);
    m_recognitionThread.setObjectName(QStringLiteral("Offline speech recognition"));
    m_recognitionThread.start();
}

VoiceFollowSession::~VoiceFollowSession()
{
    stopAudioCapture();
    if (m_recognitionThread.isRunning()) {
        QMetaObject::invokeMethod(m_recognizer, "finish", Qt::BlockingQueuedConnection);
        m_recognitionThread.quit();
        m_recognitionThread.wait();
    }
}

QQuickTextDocument *VoiceFollowSession::document() const
{
    return m_document;
}

void VoiceFollowSession::setDocument(QQuickTextDocument *document)
{
    if (m_document == document)
        return;
    disconnect(m_documentConnection);
    m_document = document;
    if (m_document && m_document->textDocument()) {
        m_documentConnection = connect(m_document->textDocument(), &QTextDocument::contentsChanged,
            this, &VoiceFollowSession::updateScript);
    }
    updateScript();
    Q_EMIT documentChanged();
}

QString VoiceFollowSession::libraryPath() const
{
    return m_libraryPath;
}

void VoiceFollowSession::setLibraryPath(const QString &path)
{
    const QString cleaned = QDir::cleanPath(path);
    if (m_libraryPath == cleaned)
        return;
    m_libraryPath = cleaned;
    Q_EMIT configurationChanged();
}

QString VoiceFollowSession::modelPath() const
{
    return m_modelPath;
}

void VoiceFollowSession::setModelPath(const QString &path)
{
    const QString cleaned = QDir::cleanPath(path);
    if (m_modelPath == cleaned)
        return;
    m_modelPath = cleaned;
    Q_EMIT configurationChanged();
}

VoiceFollowSession::State VoiceFollowSession::state() const
{
    return m_state;
}

bool VoiceFollowSession::active() const
{
    return m_active;
}

bool VoiceFollowSession::audioCaptureAvailable() const
{
#ifdef QPROMPT_HAVE_QT_MULTIMEDIA
    return true;
#else
    return false;
#endif
}

QVariantList VoiceFollowSession::audioInputDevices() const
{
    QVariantList devices;
#ifdef QPROMPT_HAVE_QT_MULTIMEDIA
    QVariantMap systemDefault;
    systemDefault[QStringLiteral("id")] = QString();
    systemDefault[QStringLiteral("description")] = tr("System Default");
    devices.append(systemDefault);

    const auto inputs = QMediaDevices::audioInputs();
    for (const QAudioDevice &device : inputs) {
        QVariantMap entry;
        entry[QStringLiteral("id")] = QString::fromLatin1(device.id().toBase64());
        entry[QStringLiteral("description")] = device.description();
        devices.append(entry);
    }
#endif
    return devices;
}

QString VoiceFollowSession::audioInputDeviceId() const
{
    return m_audioInputDeviceId;
}

void VoiceFollowSession::setAudioInputDeviceId(const QString &id)
{
    if (m_audioInputDeviceId == id)
        return;
    m_audioInputDeviceId = id;
    Q_EMIT configurationChanged();
}

int VoiceFollowSession::position() const
{
    return m_follower.position();
}

qreal VoiceFollowSession::confidence() const
{
    return m_confidence;
}

bool VoiceFollowSession::stable() const
{
    return m_stable;
}

QString VoiceFollowSession::transcript() const
{
    return m_transcript;
}

QString VoiceFollowSession::errorString() const
{
    return m_errorString;
}

int VoiceFollowSession::readingLeadTokens() const
{
    return m_readingLeadTokens;
}

void VoiceFollowSession::setReadingLeadTokens(int tokenCount)
{
    tokenCount = std::clamp(tokenCount, 0, 12);
    if (m_readingLeadTokens == tokenCount)
        return;
    m_readingLeadTokens = tokenCount;
    Q_EMIT configurationChanged();
}

void VoiceFollowSession::start()
{
    if (m_active)
        return;
    updateScript();
    if (!m_document || !m_document->textDocument() || m_document->textDocument()->isEmpty()) {
        setError(tr("Open a script before enabling voice following."));
        return;
    }
    if (!audioCaptureAvailable()) {
        setError(tr("This QPrompt build does not include Qt Multimedia microphone capture."));
        return;
    }

    m_active = true;
    m_stable = false;
    m_hadStableMatch = false;
    m_confidence = 0.0;
    m_lastEmittedPosition = -1;
    m_transcript.clear();
    m_errorString.clear();
    Q_EMIT activeChanged();
    Q_EMIT matchChanged();
    Q_EMIT transcriptChanged();
    Q_EMIT errorStringChanged();
    setState(Loading);
    Q_EMIT initializeRecognizer(m_libraryPath, m_modelPath, RecognitionSampleRate);
}

void VoiceFollowSession::stop()
{
    if (!m_active && m_state == Disabled)
        return;
    m_active = false;
    m_silenceTimer.stop();
    stopAudioCapture();
    Q_EMIT finishRecognizer();
    m_stable = false;
    m_confidence = 0.0;
    Q_EMIT activeChanged();
    Q_EMIT matchChanged();
    setState(Disabled);
}

void VoiceFollowSession::setTrackingWindow(int firstVisibleCharacter, int lastVisibleCharacter)
{
    m_follower.setTrackingWindow(firstVisibleCharacter, lastVisibleCharacter);
}

void VoiceFollowSession::reanchor(int documentPosition, int firstVisibleCharacter, int lastVisibleCharacter)
{
    m_follower.reset(documentPosition);
    m_follower.setTrackingWindow(firstVisibleCharacter, lastVisibleCharacter);
    m_lastEmittedPosition = -1;
    m_stable = false;
    m_confidence = 0.0;
    m_hadStableMatch = false;
    if (m_active) {
        Q_EMIT resetRecognizer();
        setState(Listening);
    }
    Q_EMIT matchChanged();
}

void VoiceFollowSession::updateScript()
{
    if (!m_document || !m_document->textDocument()) {
        m_follower.setScript({});
        return;
    }
    const int previousPosition = m_follower.position();
    m_follower.setScript(m_document->textDocument()->toPlainText());
    m_follower.reset(previousPosition);
}

void VoiceFollowSession::recognizerReady()
{
    if (!m_active) {
        Q_EMIT finishRecognizer();
        return;
    }
    if (!startAudioCapture())
        return;
    setState(Listening);
    m_silenceTimer.start();
}

void VoiceFollowSession::acceptTranscript(const QString &text)
{
    if (!m_active || text.isEmpty())
        return;
    m_silenceTimer.start();
    if (m_transcript != text) {
        m_transcript = text;
        Q_EMIT transcriptChanged();
    }

    const QVariantMap result = m_follower.acceptPartialTranscript(text);
    m_confidence = result.value(QStringLiteral("confidence")).toReal();
    m_stable = result.value(QStringLiteral("stable")).toBool();
    Q_EMIT matchChanged();

    if (!m_stable) {
        setState(m_hadStableMatch ? Holding : Listening);
        return;
    }

    m_hadStableMatch = true;
    setState(Following);
    if (m_follower.position() != m_lastEmittedPosition) {
        m_lastEmittedPosition = m_follower.position();
        const int readingPosition = m_follower.positionAfterTokens(
            m_lastEmittedPosition, m_readingLeadTokens);
        Q_EMIT followedPosition(readingPosition, m_confidence);
    }
}

void VoiceFollowSession::recognizerError(const QString &message)
{
    if (!m_active && m_state == Disabled)
        return;
    m_active = false;
    stopAudioCapture();
    Q_EMIT activeChanged();
    setError(message);
}

void VoiceFollowSession::holdForSilence()
{
    if (!m_active)
        return;
    m_stable = false;
    m_confidence = 0.0;
    Q_EMIT matchChanged();
    setState(Holding);
}

void VoiceFollowSession::setState(State state)
{
    if (m_state == state)
        return;
    m_state = state;
    Q_EMIT stateChanged();
}

void VoiceFollowSession::setError(const QString &message)
{
    if (m_errorString != message) {
        m_errorString = message;
        Q_EMIT errorStringChanged();
    }
    setState(Error);
}

bool VoiceFollowSession::startAudioCapture()
{
#ifdef QPROMPT_HAVE_QT_MULTIMEDIA
    QAudioDevice input = QMediaDevices::defaultAudioInput();
    if (!m_audioInputDeviceId.isEmpty()) {
        const QByteArray wantedId = QByteArray::fromBase64(m_audioInputDeviceId.toLatin1());
        const auto inputs = QMediaDevices::audioInputs();
        const auto it = std::find_if(inputs.begin(), inputs.end(), [&wantedId](const QAudioDevice &device) {
            return device.id() == wantedId;
        });
        if (it != inputs.end())
            input = *it;
    }
    if (input.isNull()) {
        recognizerError(tr("No microphone input device is available."));
        return false;
    }

    QAudioFormat format;
    format.setSampleRate(RecognitionSampleRate);
    format.setChannelCount(1);
    format.setSampleFormat(QAudioFormat::Int16);

    if (!input.isFormatSupported(format)) {
        const QAudioFormat preferred = input.preferredFormat();
        QAudioFormat monoPcm = preferred;
        monoPcm.setChannelCount(1);
        monoPcm.setSampleFormat(QAudioFormat::Int16);
        format = input.isFormatSupported(monoPcm) ? monoPcm : preferred;
    }

    if (format.sampleRate() <= 0 || format.channelCount() <= 0
        || format.bytesPerSample() <= 0
        || format.sampleFormat() == QAudioFormat::Unknown) {
        recognizerError(tr("The default microphone reported an unusable capture format."));
        return false;
    }

    m_captureFormat = format;
    m_captureRemainder.clear();
    m_resampleSamples.clear();
    m_resamplePosition = 0.0;
    qInfo() << "Voice microphone capture format:"
            << format.sampleRate() << "Hz," << format.channelCount() << "channels,"
            << format.sampleFormat();

    m_audioSource = new QAudioSource(input, format, this);
    connect(m_audioSource, &QAudioSource::stateChanged, this, [this](QtAudio::State state) {
        if (state == QtAudio::StoppedState && m_active && m_audioSource
            && m_audioSource->error() != QtAudio::NoError) {
            recognizerError(tr("Microphone capture stopped with error code %1.")
                                .arg(static_cast<int>(m_audioSource->error())));
        }
    });
    m_audioDevice = m_audioSource->start();
    if (!m_audioDevice) {
        recognizerError(tr("The microphone could not be started."));
        return false;
    }
    connect(m_audioDevice, &QIODevice::readyRead, this, [this]() {
        if (!m_audioDevice || !m_active)
            return;
        const QByteArray audio = m_audioDevice->readAll();
        const QByteArray recognitionPcm = convertCaptureToRecognitionPcm(audio);
        if (!recognitionPcm.isEmpty())
            Q_EMIT audioReady(recognitionPcm);
    });
    return true;
#else
    recognizerError(tr("This QPrompt build does not include microphone capture."));
    return false;
#endif
}

void VoiceFollowSession::stopAudioCapture()
{
#ifdef QPROMPT_HAVE_QT_MULTIMEDIA
    m_audioDevice = nullptr;
    if (m_audioSource) {
        m_audioSource->stop();
        m_audioSource->deleteLater();
        m_audioSource = nullptr;
    }
    m_captureRemainder.clear();
    m_resampleSamples.clear();
    m_resamplePosition = 0.0;
#endif
}

#ifdef QPROMPT_HAVE_QT_MULTIMEDIA
QByteArray VoiceFollowSession::convertCaptureToRecognitionPcm(const QByteArray &audio)
{
    if (audio.isEmpty() || !m_captureFormat.isValid())
        return {};

    m_captureRemainder.append(audio);
    const int frameBytes = m_captureFormat.bytesPerFrame();
    const int sampleBytes = m_captureFormat.bytesPerSample();
    if (frameBytes <= 0 || sampleBytes <= 0)
        return {};

    const qsizetype completeBytes = m_captureRemainder.size()
        - (m_captureRemainder.size() % frameBytes);
    if (completeBytes <= 0)
        return {};

    const QByteArray frames = m_captureRemainder.first(completeBytes);
    m_captureRemainder.remove(0, completeBytes);
    const qsizetype frameCount = frames.size() / frameBytes;
    m_resampleSamples.reserve(m_resampleSamples.size() + frameCount);

    for (qsizetype frame = 0; frame < frameCount; ++frame) {
        const char *frameData = frames.constData() + frame * frameBytes;
        float mono = 0.0f;
        for (int channel = 0; channel < m_captureFormat.channelCount(); ++channel) {
            mono += normalizedAudioSample(frameData + channel * sampleBytes,
                m_captureFormat.sampleFormat());
        }
        m_resampleSamples.append(mono / m_captureFormat.channelCount());
    }

    const double sourceStep = static_cast<double>(m_captureFormat.sampleRate())
        / RecognitionSampleRate;
    QByteArray output;
    output.reserve(static_cast<qsizetype>(
        (m_resampleSamples.size() / sourceStep + 1) * sizeof(qint16)));

    while (m_resamplePosition + 1.0 < m_resampleSamples.size()) {
        const qsizetype first = static_cast<qsizetype>(m_resamplePosition);
        const float fraction = static_cast<float>(m_resamplePosition - first);
        const float sample = m_resampleSamples.at(first)
            + (m_resampleSamples.at(first + 1) - m_resampleSamples.at(first)) * fraction;
        const qint16 pcm = static_cast<qint16>(std::lround(
            std::clamp(sample, -1.0f, 1.0f) * std::numeric_limits<qint16>::max()));
        output.append(reinterpret_cast<const char *>(&pcm), sizeof(pcm));
        m_resamplePosition += sourceStep;
    }

    const qsizetype discard = std::min(
        static_cast<qsizetype>(m_resamplePosition), m_resampleSamples.size() - 1);
    if (discard > 0) {
        m_resampleSamples.remove(0, discard);
        m_resamplePosition -= discard;
    }
    return output;
}
#endif

QString VoiceFollowSession::defaultLibraryPath()
{
    const QString configured = qEnvironmentVariable("QPROMPT_VOSK_LIBRARY");
    if (!configured.isEmpty())
        return configured;
#ifdef Q_OS_WIN
    return QDir(QCoreApplication::applicationDirPath()).filePath(QStringLiteral("libvosk.dll"));
#elif defined(Q_OS_MACOS)
    return QDir(QCoreApplication::applicationDirPath()).filePath(QStringLiteral("libvosk.dylib"));
#else
    return QStringLiteral("libvosk.so");
#endif
}

QString VoiceFollowSession::defaultModelPath()
{
    const QString configured = qEnvironmentVariable("QPROMPT_VOSK_MODEL");
    if (!configured.isEmpty())
        return configured;

    const QString bundled = QDir(QCoreApplication::applicationDirPath())
        .filePath(QStringLiteral("models/vosk-model-small-en-us-0.15"));
    if (QFileInfo::exists(QDir(bundled).filePath(QStringLiteral("conf/model.conf"))))
        return bundled;

    return QDir(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation))
        .filePath(QStringLiteral("models/vosk-model-small-en-us-0.15"));
}
