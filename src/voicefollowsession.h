/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2026 Javier O. Cordero Perez
 **
 ** This file is part of QPrompt.
 **
 ****************************************************************************/

#pragma once

#include "scriptfollower.h"

#include <QMetaObject>
#include <QObject>
#include <QQmlEngine>
#include <QQuickTextDocument>
#include <QThread>
#include <QTimer>

#ifdef QPROMPT_HAVE_QT_MULTIMEDIA
#include <QAudioFormat>
#include <QVector>

class QAudioSource;
class QIODevice;
#endif

class OfflineSpeechRecognizer;

class VoiceFollowSession : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QQuickTextDocument *document READ document WRITE setDocument NOTIFY documentChanged)
    Q_PROPERTY(QString libraryPath READ libraryPath WRITE setLibraryPath NOTIFY configurationChanged)
    Q_PROPERTY(QString modelPath READ modelPath WRITE setModelPath NOTIFY configurationChanged)
    Q_PROPERTY(State state READ state NOTIFY stateChanged)
    Q_PROPERTY(bool active READ active NOTIFY activeChanged)
    Q_PROPERTY(bool audioCaptureAvailable READ audioCaptureAvailable CONSTANT)
    Q_PROPERTY(int position READ position NOTIFY matchChanged)
    Q_PROPERTY(qreal confidence READ confidence NOTIFY matchChanged)
    Q_PROPERTY(bool stable READ stable NOTIFY matchChanged)
    Q_PROPERTY(QString transcript READ transcript NOTIFY transcriptChanged)
    Q_PROPERTY(QString errorString READ errorString NOTIFY errorStringChanged)
    Q_PROPERTY(int readingLeadTokens READ readingLeadTokens WRITE setReadingLeadTokens NOTIFY configurationChanged)

public:
    enum State {
        Disabled,
        Loading,
        Listening,
        Following,
        Holding,
        Error
    };
    Q_ENUM(State)

    explicit VoiceFollowSession(QObject *parent = nullptr);
    ~VoiceFollowSession() override;

    QQuickTextDocument *document() const;
    void setDocument(QQuickTextDocument *document);

    QString libraryPath() const;
    void setLibraryPath(const QString &path);
    QString modelPath() const;
    void setModelPath(const QString &path);

    State state() const;
    bool active() const;
    bool audioCaptureAvailable() const;
    int position() const;
    qreal confidence() const;
    bool stable() const;
    QString transcript() const;
    QString errorString() const;
    int readingLeadTokens() const;
    void setReadingLeadTokens(int tokenCount);

    Q_INVOKABLE void start();
    Q_INVOKABLE void stop();
    Q_INVOKABLE void setTrackingWindow(int firstVisibleCharacter, int lastVisibleCharacter);
    Q_INVOKABLE void reanchor(int documentPosition, int firstVisibleCharacter, int lastVisibleCharacter);

Q_SIGNALS:
    void documentChanged();
    void configurationChanged();
    void stateChanged();
    void activeChanged();
    void matchChanged();
    void transcriptChanged();
    void errorStringChanged();
    void followedPosition(int documentPosition, qreal confidence);

    void initializeRecognizer(const QString &libraryPath, const QString &modelPath, int sampleRate);
    void audioReady(const QByteArray &audio);
    void resetRecognizer();
    void finishRecognizer();

private Q_SLOTS:
    void updateScript();
    void recognizerReady();
    void acceptTranscript(const QString &text);
    void recognizerError(const QString &message);
    void holdForSilence();

private:
    void setState(State state);
    void setError(const QString &message);
    bool startAudioCapture();
    void stopAudioCapture();
#ifdef QPROMPT_HAVE_QT_MULTIMEDIA
    QByteArray convertCaptureToRecognitionPcm(const QByteArray &audio);
#endif

    static QString defaultLibraryPath();
    static QString defaultModelPath();

    QQuickTextDocument *m_document = nullptr;
    QMetaObject::Connection m_documentConnection;
    ScriptFollower m_follower;

    QString m_libraryPath;
    QString m_modelPath;
    QString m_transcript;
    QString m_errorString;
    State m_state = Disabled;
    bool m_active = false;
    bool m_stable = false;
    bool m_hadStableMatch = false;
    qreal m_confidence = 0.0;
    int m_lastEmittedPosition = -1;
    int m_readingLeadTokens = 5;

    QThread m_recognitionThread;
    OfflineSpeechRecognizer *m_recognizer = nullptr;
    QTimer m_silenceTimer;

#ifdef QPROMPT_HAVE_QT_MULTIMEDIA
    QAudioSource *m_audioSource = nullptr;
    QIODevice *m_audioDevice = nullptr;
    QAudioFormat m_captureFormat;
    QByteArray m_captureRemainder;
    QVector<float> m_resampleSamples;
    double m_resamplePosition = 0.0;
#endif
};
