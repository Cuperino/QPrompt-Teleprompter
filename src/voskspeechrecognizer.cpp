/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2026 Javier O. Cordero Perez
 **
 ** This file is part of QPrompt.
 **
 ****************************************************************************/

#include "voskspeechrecognizer.h"

#include <QFileInfo>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>

#include <limits>

VoskSpeechRecognizer::VoskSpeechRecognizer(QObject *parent)
    : OfflineSpeechRecognizer(parent)
{
}

VoskSpeechRecognizer::~VoskSpeechRecognizer()
{
    cleanup();
}

void VoskSpeechRecognizer::initialize(const QString &libraryPath, const QString &modelPath, int sampleRate)
{
    cleanup();

    if (sampleRate <= 0) {
        Q_EMIT errorOccurred(tr("The speech recognizer sample rate is invalid."));
        return;
    }
    if (!QFileInfo(modelPath).isDir()) {
        Q_EMIT errorOccurred(tr("The Vosk model directory does not exist: %1").arg(modelPath));
        return;
    }

    m_library.setFileName(libraryPath.isEmpty() ? QStringLiteral("vosk") : libraryPath);
    if (!m_library.load()) {
        Q_EMIT errorOccurred(tr("Could not load the offline Vosk runtime: %1").arg(m_library.errorString()));
        return;
    }
    if (!resolveApi()) {
        cleanup();
        return;
    }

    m_setLogLevel(-1);
    const QByteArray encodedModelPath = QFile::encodeName(modelPath);
    m_model = m_modelNew(encodedModelPath.constData());
    if (!m_model) {
        Q_EMIT errorOccurred(tr("Vosk could not load the model at %1").arg(modelPath));
        cleanup();
        return;
    }

    m_recognizer = m_recognizerNew(m_model, static_cast<float>(sampleRate));
    if (!m_recognizer) {
        Q_EMIT errorOccurred(tr("Vosk could not create a streaming recognizer."));
        cleanup();
        return;
    }

    Q_EMIT ready();
}

void VoskSpeechRecognizer::acceptPcm16(const QByteArray &audio)
{
    if (!m_recognizer || audio.isEmpty())
        return;
    if (audio.size() > std::numeric_limits<int>::max()) {
        Q_EMIT errorOccurred(tr("The microphone supplied an oversized audio block."));
        return;
    }

    const int outcome = m_acceptWaveform(m_recognizer, audio.constData(), static_cast<int>(audio.size()));
    if (outcome < 0) {
        Q_EMIT errorOccurred(tr("Vosk rejected a microphone audio block."));
        return;
    }

    if (outcome > 0) {
        const QString text = textFromResult(m_result(m_recognizer), "text");
        m_lastPartial.clear();
        if (!text.isEmpty())
            Q_EMIT finalTranscript(text);
        return;
    }

    const QString partial = textFromResult(m_partialResult(m_recognizer), "partial");
    if (!partial.isEmpty() && partial != m_lastPartial) {
        m_lastPartial = partial;
        Q_EMIT partialTranscript(partial);
    }
}

void VoskSpeechRecognizer::reset()
{
    m_lastPartial.clear();
    if (m_recognizer)
        m_recognizerReset(m_recognizer);
}

void VoskSpeechRecognizer::finish()
{
    if (m_recognizer) {
        const QString text = textFromResult(m_finalResult(m_recognizer), "text");
        if (!text.isEmpty())
            Q_EMIT finalTranscript(text);
    }
    cleanup();
}

bool VoskSpeechRecognizer::resolveApi()
{
#define RESOLVE_VOSK(member, symbol) \
    member = reinterpret_cast<decltype(member)>(m_library.resolve(symbol)); \
    if (!member) { \
        Q_EMIT errorOccurred(tr("The Vosk runtime is missing the required symbol %1.").arg(QStringLiteral(symbol))); \
        return false; \
    }

    RESOLVE_VOSK(m_modelNew, "vosk_model_new")
    RESOLVE_VOSK(m_modelFree, "vosk_model_free")
    RESOLVE_VOSK(m_recognizerNew, "vosk_recognizer_new")
    RESOLVE_VOSK(m_recognizerFree, "vosk_recognizer_free")
    RESOLVE_VOSK(m_acceptWaveform, "vosk_recognizer_accept_waveform")
    RESOLVE_VOSK(m_partialResult, "vosk_recognizer_partial_result")
    RESOLVE_VOSK(m_result, "vosk_recognizer_result")
    RESOLVE_VOSK(m_finalResult, "vosk_recognizer_final_result")
    RESOLVE_VOSK(m_recognizerReset, "vosk_recognizer_reset")
    RESOLVE_VOSK(m_setLogLevel, "vosk_set_log_level")

#undef RESOLVE_VOSK
    return true;
}

QString VoskSpeechRecognizer::textFromResult(const char *json, const char *field) const
{
    if (!json)
        return {};

    QJsonParseError error;
    const QJsonDocument document = QJsonDocument::fromJson(QByteArray(json), &error);
    if (error.error != QJsonParseError::NoError || !document.isObject())
        return {};
    return document.object().value(QLatin1String(field)).toString().simplified();
}

void VoskSpeechRecognizer::cleanup()
{
    if (m_recognizer && m_recognizerFree)
        m_recognizerFree(m_recognizer);
    m_recognizer = nullptr;
    if (m_model && m_modelFree)
        m_modelFree(m_model);
    m_model = nullptr;
    m_lastPartial.clear();

    if (m_library.isLoaded())
        m_library.unload();
}
