/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2026 Javier O. Cordero Perez
 **
 ** This file is part of QPrompt.
 **
 ****************************************************************************/

#pragma once

#include <QByteArray>
#include <QObject>
#include <QString>

// Backend-neutral streaming recognizer contract. Implementations live on a
// worker thread; callers send PCM chunks through queued signal connections.
class OfflineSpeechRecognizer : public QObject
{
    Q_OBJECT

public:
    using QObject::QObject;
    ~OfflineSpeechRecognizer() override = default;

public Q_SLOTS:
    virtual void initialize(const QString &libraryPath, const QString &modelPath, int sampleRate) = 0;
    virtual void acceptPcm16(const QByteArray &audio) = 0;
    virtual void reset() = 0;
    virtual void finish() = 0;

Q_SIGNALS:
    void ready();
    void partialTranscript(const QString &text);
    void finalTranscript(const QString &text);
    void errorOccurred(const QString &message);
};

