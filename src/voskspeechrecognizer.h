/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2026 Javier O. Cordero Perez
 **
 ** This file is part of QPrompt.
 **
 ****************************************************************************/

#pragma once

#include "offlinespeechrecognizer.h"

#include <QLibrary>

struct VoskModel;
struct VoskRecognizer;

// Loads Vosk through its stable C ABI at runtime. QPrompt therefore remains
// buildable without a Vosk SDK and can clearly report a missing local runtime.
class VoskSpeechRecognizer final : public OfflineSpeechRecognizer
{
    Q_OBJECT

public:
    explicit VoskSpeechRecognizer(QObject *parent = nullptr);
    ~VoskSpeechRecognizer() override;

public Q_SLOTS:
    void initialize(const QString &libraryPath, const QString &modelPath, int sampleRate) override;
    void acceptPcm16(const QByteArray &audio) override;
    void reset() override;
    void finish() override;

private:
    using ModelNew = VoskModel *(*)(const char *);
    using ModelFree = void (*)(VoskModel *);
    using RecognizerNew = VoskRecognizer *(*)(VoskModel *, float);
    using RecognizerFree = void (*)(VoskRecognizer *);
    using AcceptWaveform = int (*)(VoskRecognizer *, const char *, int);
    using Result = const char *(*)(VoskRecognizer *);
    using RecognizerReset = void (*)(VoskRecognizer *);
    using SetLogLevel = void (*)(int);

    bool resolveApi();
    QString textFromResult(const char *json, const char *field) const;
    void cleanup();

    QLibrary m_library;
    VoskModel *m_model = nullptr;
    VoskRecognizer *m_recognizer = nullptr;
    QString m_lastPartial;

    ModelNew m_modelNew = nullptr;
    ModelFree m_modelFree = nullptr;
    RecognizerNew m_recognizerNew = nullptr;
    RecognizerFree m_recognizerFree = nullptr;
    AcceptWaveform m_acceptWaveform = nullptr;
    Result m_partialResult = nullptr;
    Result m_result = nullptr;
    Result m_finalResult = nullptr;
    RecognizerReset m_recognizerReset = nullptr;
    SetLogLevel m_setLogLevel = nullptr;
};

