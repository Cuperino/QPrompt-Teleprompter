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

#pragma once

#include "offlinespeechrecognizer.h"

// Bridges Qt's OfflineSpeechRecognizer interface to Apple's on-device Speech
// framework (SFSpeechRecognizer). Vosk has never shipped an iOS build, and
// even if it had, dynamically loading an arbitrary unsigned dylib at
// runtime the way VoskSpeechRecognizer does via QLibrary isn't permitted
// under iOS's code-signing/sandbox model, so iOS gets its own backend built
// on the platform's own, officially supported on-device recognizer instead.
class AppleSpeechRecognizer final : public OfflineSpeechRecognizer
{
    Q_OBJECT

public:
    explicit AppleSpeechRecognizer(QObject *parent = nullptr);
    ~AppleSpeechRecognizer() override;

public Q_SLOTS:
    void initialize(const QString &libraryPath, const QString &modelPath, int sampleRate) override;
    void acceptPcm16(const QByteArray &audio) override;
    void reset() override;
    void finish() override;

private:
    void startTask();
    void stopTask(bool cancel);

    // Opaque handle to an Objective-C AppleSpeechRecognizerPrivate instance
    // (see applespeechrecognizer.mm), bridged through void* so this header
    // stays plain C++ and can be included (and moc'd) from non-Objective-C
    // translation units such as voicefollowsession.cpp.
    void *d = nullptr;
    bool m_authorized = false;
};
