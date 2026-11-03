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

#include "applespeechrecognizer.h"

#include <QMetaObject>
#include <QPointer>

#import <AVFoundation/AVFoundation.h>
#import <Speech/Speech.h>

// Tracks whether the task it's attached to has been deliberately discarded
// (VoiceFollowSession::reanchor() -> reset(), see stopTask() below) so its
// resultHandler block can tell an intentional cancellation apart from a real
// error/final-result and drop the callback silently instead of forwarding a
// spurious error for a task nobody asked about any more.
@interface QPromptSpeechTaskState : NSObject
@property (atomic, assign) BOOL cancelled;
@end

@implementation QPromptSpeechTaskState
@end

@interface AppleSpeechRecognizerPrivate : NSObject
@property (nonatomic, strong) SFSpeechRecognizer *recognizer;
@property (nonatomic, strong) SFSpeechAudioBufferRecognitionRequest *request;
@property (nonatomic, strong) SFSpeechRecognitionTask *task;
@property (nonatomic, strong) AVAudioFormat *pcmFormat;
@property (nonatomic, strong) QPromptSpeechTaskState *taskState;
@property (nonatomic, assign) AppleSpeechRecognizer *owner;
@end

@implementation AppleSpeechRecognizerPrivate
@end

namespace {
// d is a void* in the header (see applespeechrecognizer.h) so that plain
// C++ translation units such as voicefollowsession.cpp can include it
// without pulling in Objective-C; this recovers the real type for use
// within this file.
AppleSpeechRecognizerPrivate *impl(void *d)
{
    return (__bridge AppleSpeechRecognizerPrivate *)d;
}
}

AppleSpeechRecognizer::AppleSpeechRecognizer(QObject *parent)
    : OfflineSpeechRecognizer(parent)
{
    AppleSpeechRecognizerPrivate *p = [[AppleSpeechRecognizerPrivate alloc] init];
    p.owner = this;
    d = (__bridge_retained void *)p;
}

AppleSpeechRecognizer::~AppleSpeechRecognizer()
{
    stopTask(true);
    AppleSpeechRecognizerPrivate *p = (__bridge_transfer AppleSpeechRecognizerPrivate *)d;
    d = nullptr;
    Q_UNUSED(p) // released once this local strong reference goes out of scope
}

void AppleSpeechRecognizer::initialize(const QString &libraryPath, const QString &modelPath, int sampleRate)
{
    Q_UNUSED(libraryPath)
    Q_UNUSED(modelPath)

    stopTask(true);
    m_authorized = false;

    if (sampleRate <= 0) {
        Q_EMIT errorOccurred(tr("The speech recognizer sample rate is invalid."));
        return;
    }

    AppleSpeechRecognizerPrivate *p = impl(d);

    // Only the interleaved 16-bit mono PCM stream VoiceFollowSession already
    // resamples audio into (see RecognitionSampleRate in voicefollowsession.cpp)
    // needs to be represented here; acceptPcm16() below wraps chunks of it in
    // buffers of this exact format.
    AudioStreamBasicDescription asbd = {};
    asbd.mSampleRate = sampleRate;
    asbd.mFormatID = kAudioFormatLinearPCM;
    asbd.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    asbd.mBitsPerChannel = 16;
    asbd.mChannelsPerFrame = 1;
    asbd.mFramesPerPacket = 1;
    asbd.mBytesPerFrame = 2;
    asbd.mBytesPerPacket = 2;
    p.pcmFormat = [[AVAudioFormat alloc] initWithStreamDescription:&asbd];

    NSLocale *locale = [NSLocale localeWithLocaleIdentifier:@"en-US"];
    p.recognizer = [[SFSpeechRecognizer alloc] initWithLocale:locale];
    if (!p.recognizer) {
        Q_EMIT errorOccurred(tr("Apple Speech recognition is not available for this locale."));
        return;
    }
    if (!p.recognizer.supportsOnDeviceRecognition) {
        Q_EMIT errorOccurred(tr("This device does not support on-device speech recognition."));
        return;
    }

    QPointer<AppleSpeechRecognizer> self(this);
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        QString reason;
        switch (status) {
        case SFSpeechRecognizerAuthorizationStatusAuthorized:
            break;
        case SFSpeechRecognizerAuthorizationStatusDenied:
            reason = AppleSpeechRecognizer::tr(
                "Speech recognition access was denied. Enable it in Settings > Privacy & Security > Speech Recognition.");
            break;
        case SFSpeechRecognizerAuthorizationStatusRestricted:
            reason = AppleSpeechRecognizer::tr("Speech recognition is restricted on this device.");
            break;
        case SFSpeechRecognizerAuthorizationStatusNotDetermined:
        default:
            reason = AppleSpeechRecognizer::tr("Speech recognition authorization was not determined.");
            break;
        }
        const bool granted = (status == SFSpeechRecognizerAuthorizationStatusAuthorized);
        // Marshal back onto AppleSpeechRecognizer's own thread (the
        // recognition worker thread set up in VoiceFollowSession) rather
        // than wherever Apple happens to invoke this handler from, since
        // startTask() below touches the same Objective-C state that
        // acceptPcm16()/reset()/finish() read and write there.
        if (!self)
            return;
        QMetaObject::invokeMethod(self, [self, granted, reason]() {
            if (!self)
                return;
            if (!granted) {
                Q_EMIT self->errorOccurred(reason);
                return;
            }
            self->m_authorized = true;
            self->startTask();
            Q_EMIT self->ready();
        }, Qt::QueuedConnection);
    }];
}

void AppleSpeechRecognizer::acceptPcm16(const QByteArray &audio)
{
    AppleSpeechRecognizerPrivate *p = impl(d);
    if (!m_authorized || !p.request || audio.isEmpty())
        return;

    const NSUInteger frameCount = static_cast<NSUInteger>(audio.size() / sizeof(qint16));
    if (frameCount == 0)
        return;

    AVAudioPCMBuffer *buffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:p.pcmFormat
        frameCapacity:static_cast<AVAudioFrameCount>(frameCount)];
    if (!buffer)
        return;
    buffer.frameLength = static_cast<AVAudioFrameCount>(frameCount);
    memcpy(buffer.int16ChannelData[0], audio.constData(), static_cast<size_t>(audio.size()));

    [p.request appendAudioPCMBuffer:buffer];
}

void AppleSpeechRecognizer::reset()
{
    if (!m_authorized)
        return;
    stopTask(true);
    startTask();
}

void AppleSpeechRecognizer::finish()
{
    stopTask(false);
}

void AppleSpeechRecognizer::startTask()
{
    AppleSpeechRecognizerPrivate *p = impl(d);
    if (!p.recognizer)
        return;

    p.request = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    p.request.shouldReportPartialResults = YES;
    p.request.requiresOnDeviceRecognition = YES;

    QPromptSpeechTaskState *taskState = [[QPromptSpeechTaskState alloc] init];
    p.taskState = taskState;

    QPointer<AppleSpeechRecognizer> self(this);
    p.task = [p.recognizer recognitionTaskWithRequest:p.request
        resultHandler:^(SFSpeechRecognitionResult *result, NSError *error) {
        if (taskState.cancelled)
            return;

        if (!self)
            return;

        if (error) {
            NSString *message = error.localizedDescription;
            const QString text = QString::fromNSString(message);
            QMetaObject::invokeMethod(self, [self, text]() {
                if (self)
                    Q_EMIT self->errorOccurred(text);
            }, Qt::QueuedConnection);
            return;
        }
        if (!result)
            return;

        const QString text = QString::fromNSString(result.bestTranscription.formattedString);
        const bool isFinal = result.isFinal;
        QMetaObject::invokeMethod(self, [self, text, isFinal]() {
            if (!self || text.isEmpty())
                return;
            if (isFinal)
                Q_EMIT self->finalTranscript(text);
            else
                Q_EMIT self->partialTranscript(text);
        }, Qt::QueuedConnection);
    }];
}

void AppleSpeechRecognizer::stopTask(bool cancel)
{
    AppleSpeechRecognizerPrivate *p = impl(d);
    if (cancel) {
        p.taskState.cancelled = YES;
        [p.task cancel];
    } else if (p.request) {
        [p.request endAudio];
    }
    p.request = nil;
    p.task = nil;
    p.taskState = nil;
}
