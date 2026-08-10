/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2026 Javier O. Cordero Perez
 **
 ** This file is part of QPrompt.
 **
 ****************************************************************************/

#include "voskspeechrecognizer.h"
#include "scriptfollower.h"

#include <QCoreApplication>
#include <QDebug>
#include <QFile>
#include <QtEndian>

namespace {
quint16 read16(const QByteArray &data, qsizetype offset)
{
    return qFromLittleEndian<quint16>(
        reinterpret_cast<const uchar *>(data.constData() + offset));
}

quint32 read32(const QByteArray &data, qsizetype offset)
{
    return qFromLittleEndian<quint32>(
        reinterpret_cast<const uchar *>(data.constData() + offset));
}

QByteArray readPcm16Mono16k(const QString &path, QString *error)
{
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly)) {
        *error = QStringLiteral("Could not open WAV file: %1").arg(file.errorString());
        return {};
    }

    const QByteArray wave = file.readAll();
    if (wave.size() < 12 || wave.first(4) != "RIFF" || wave.sliced(8, 4) != "WAVE") {
        *error = QStringLiteral("The input is not a RIFF/WAVE file.");
        return {};
    }

    bool validFormat = false;
    QByteArray pcm;
    qsizetype offset = 12;
    while (offset + 8 <= wave.size()) {
        const QByteArray chunkId = wave.sliced(offset, 4);
        const quint32 chunkSize = read32(wave, offset + 4);
        const qsizetype payload = offset + 8;
        if (payload + chunkSize > wave.size()) {
            *error = QStringLiteral("The WAV file contains a truncated chunk.");
            return {};
        }

        if (chunkId == "fmt " && chunkSize >= 16) {
            validFormat = read16(wave, payload) == 1
                && read16(wave, payload + 2) == 1
                && read32(wave, payload + 4) == 16000
                && read16(wave, payload + 14) == 16;
        } else if (chunkId == "data") {
            pcm = wave.sliced(payload, chunkSize);
        }

        offset = payload + chunkSize + (chunkSize & 1U);
    }

    if (!validFormat) {
        *error = QStringLiteral("The WAV file must be 16 kHz, mono, 16-bit PCM.");
        return {};
    }
    if (pcm.isEmpty())
        *error = QStringLiteral("The WAV file contains no PCM data.");
    return pcm;
}
}

int main(int argc, char *argv[])
{
    QCoreApplication application(argc, argv);
    const QStringList arguments = application.arguments();
    if (arguments.size() != 5) {
        qCritical().noquote()
            << "usage: vosk_recognizer_smoke <libvosk> <model-directory>"
               " <16k-mono-pcm.wav> <script.txt>";
        return 2;
    }

    QString waveError;
    const QByteArray pcm = readPcm16Mono16k(arguments.at(3), &waveError);
    if (pcm.isEmpty()) {
        qCritical().noquote() << waveError;
        return 2;
    }

    QFile scriptFile(arguments.at(4));
    if (!scriptFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qCritical().noquote() << "Could not open script:" << scriptFile.errorString();
        return 2;
    }
    const QString script = QString::fromUtf8(scriptFile.readAll());
    if (script.trimmed().isEmpty()) {
        qCritical() << "The script fixture is empty.";
        return 2;
    }

    VoskSpeechRecognizer recognizer;
    ScriptFollower follower;
    follower.setScript(script);
    follower.setTrackingWindow(0, script.size());
    QString recognizerError;
    QString finalTranscript;
    bool stableMatchSeen = false;
    int furthestStablePosition = 0;
    const auto followTranscript = [&follower, &stableMatchSeen, &furthestStablePosition](
                                      const QString &text) {
        const QVariantMap match = follower.acceptPartialTranscript(text);
        qInfo().noquote()
            << "match: offset=" << match.value(QStringLiteral("position")).toInt()
            << "confidence=" << match.value(QStringLiteral("confidence")).toReal()
            << "stable=" << match.value(QStringLiteral("stable")).toBool();
        if (match.value(QStringLiteral("stable")).toBool()) {
            stableMatchSeen = true;
            furthestStablePosition = qMax(furthestStablePosition,
                match.value(QStringLiteral("position")).toInt());
        }
    };
    QObject::connect(&recognizer, &VoskSpeechRecognizer::errorOccurred,
        [&recognizerError](const QString &message) { recognizerError = message; });
    QObject::connect(&recognizer, &VoskSpeechRecognizer::partialTranscript,
        [&followTranscript](const QString &text) {
            qInfo().noquote() << "partial:" << text;
            followTranscript(text);
        });
    QObject::connect(&recognizer, &VoskSpeechRecognizer::finalTranscript,
        [&finalTranscript, &followTranscript](const QString &text) {
            finalTranscript = text;
            qInfo().noquote() << "final:" << text;
            followTranscript(text);
        });

    recognizer.initialize(arguments.at(1), arguments.at(2), 16000);
    if (!recognizerError.isEmpty()) {
        qCritical().noquote() << recognizerError;
        return 1;
    }

    constexpr qsizetype ChunkBytes = 3200;
    for (qsizetype offset = 0; offset < pcm.size(); offset += ChunkBytes) {
        const qsizetype remaining = pcm.size() - offset;
        recognizer.acceptPcm16(pcm.sliced(offset, qMin(ChunkBytes, remaining)));
    }
    recognizer.finish();

    if (!recognizerError.isEmpty()) {
        qCritical().noquote() << recognizerError;
        return 1;
    }
    if (finalTranscript.isEmpty()) {
        qCritical() << "Vosk produced no final transcript.";
        return 1;
    }
    if (!stableMatchSeen || furthestStablePosition == 0) {
        qCritical() << "Recognition produced no stable script position.";
        return 1;
    }
    qInfo() << "furthest stable document offset:" << furthestStablePosition;
    return 0;
}
