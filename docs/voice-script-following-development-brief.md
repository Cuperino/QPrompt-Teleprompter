# Offline Voice Script Following — Development Brief

## Summary

Add an optional offline mode that automatically advances the teleprompter as the presenter reads the displayed script. A Windows desktop MVP is now connected end to end and is undergoing interaction tuning.

This feature is a local, sequential progress tracker. It is not a voice-command system, a general transcription feature, or a document-wide search system. The expected speech is the text currently on screen, plus a small amount of text immediately before and after it.

## Product objective

Keep the presenter's current line in QPrompt's reading region without requiring them or an operator to continually adjust scroll speed.

The experience should have these properties:

- Speech causes the script to advance naturally.
- Faster and slower delivery are followed without manual speed changes.
- Silence stops movement.
- Minor mispronunciations, omitted words, and recognition errors do not break tracking.
- Skipping ahead within the nearby script is handled automatically.
- Uncertain tracking holds the current position instead of jumping.
- Manual controls remain available and immediately override voice following.
- Microphone audio and recognition remain on the device.

## Non-goals

- Voice commands such as "start", "pause", or "faster".
- Sending audio to a cloud recognition service.
- Producing, displaying, or saving a general-purpose transcript.
- Searching the complete document for arbitrary spoken passages.
- Guessing a distant position when local tracking has been lost.
- Replacing QPrompt's existing manual input methods.

## Core behaviour

When voice following starts, QPrompt creates an ordered token index for:

1. A small look-back region above the viewport.
2. The text currently visible in the viewport.
3. A small look-ahead region below the viewport.

The system maintains an expected next-token pointer. Partial results from an offline streaming recognizer are compared with tokens near this pointer. Ordered matches advance the pointer; insertions, deletions, and substitutions are tolerated.

Tracking is predominantly monotonic. A local backward correction may be allowed when supported by strong evidence, but the system must never make an unconfirmed large jump.

As the matched token advances, its source document offset is converted to a visual position. The viewport then moves smoothly to keep the active line near the configured reading region.

## Proposed data flow

```text
QTextDocument
    -> visible/look-ahead token index
    -> expected script position

Microphone
    -> offline streaming speech recognizer
    -> partial recognized tokens
    -> local sequence matcher
    -> document offset + confidence
    -> smoothed viewport target
    -> QPrompt reading region
```

## Major components

### Audio capture

The Windows MVP uses Qt Multimedia and the default system microphone. It first requests 16 kHz mono, 16-bit PCM when the device supports that format. Otherwise it captures the device's preferred format, including common 44.1/48 kHz stereo or floating-point formats, then downmixes and resamples locally to the 16 kHz mono PCM required by Vosk.

Recognition runs on a worker thread. Microphone capture and format conversion currently run on the main Qt thread; moving conversion away from the QML/render thread remains a follow-up if profiling shows that it affects rendering.

Responsibilities:

- Convert native device audio to the recognizer's required sample format. **Implemented.**
- Start and stop capture with the voice-following session. **Implemented.**
- Expose listening, silence, and error states. **Implemented.**
- Enumerate and select an input device. **Not yet implemented; the default input is used.**
- Request and report platform microphone permission. **Not yet implemented outside the current Windows desktop path.**

### Offline recognizer

Define a backend-neutral C++ interface so recognition engines can be evaluated or replaced without changing the script follower.

The interface should emit partial token sequences frequently enough for responsive tracking. Perfect transcription and punctuation are unnecessary.

Initial candidates:

- **Vosk:** small offline streaming models and support for restricted vocabularies. A strong MVP candidate when the recognizer vocabulary is derived from the local script window.
- **sherpa-onnx:** offline streaming C/C++ APIs, partial tokens and timestamps, multiple model families, and broad platform support. A strong long-term candidate.

`whisper.cpp` may be evaluated, but its greater model/runtime cost and chunk-oriented streaming make it a lower-priority candidate for this constrained task.

Language models should be optional installable packs where practical. Downloading a model may require a network connection, but prompting and recognition must not.

### Script token index

Build tokens from the document while preserving the mapping back to original `QTextDocument` character offsets.

Normalization should account for:

- Case and punctuation.
- Unicode whitespace and presentation forms.
- Apostrophes and common word contractions.
- Numbers and their likely spoken forms.
- Rich-text elements that do not produce spoken content.

The index should be refreshed after document edits and when manual navigation moves the active region outside the current tracking window.

### Local sequence matcher

Compare recognized partial tokens against a bounded window around the expected position. A weighted edit-distance or similar incremental sequence alignment is sufficient for an initial implementation.

Matching rules:

- Reward ordered token matches.
- Give distinctive words more weight than common words.
- Permit recognized words not present in the script.
- Permit script words that were not recognized or were not spoken.
- Prefer the nearest plausible occurrence of repeated text.
- Allow forward skips within the look-ahead window.
- Require stronger evidence for backward movement.
- Never advance on microphone level alone.

The matcher should emit a document offset, confidence value, and stability state.

Example result type:

```cpp
struct ScriptFollowPosition {
    int documentOffset = -1;
    float confidence = 0.0f;
    bool stable = false;
};
```

### Motion controller

Recognition updates will arrive in discrete steps and may be revised. The matched word must therefore become a target rather than an immediate viewport jump.

The controller should:

- Keep the active line close to the reading-region anchor.
- Smooth changes between confirmed positions.
- Estimate short-term delivery pace from recent matches.
- Use restrained forward prediction between recognition updates.
- Stop prediction promptly during silence or low confidence.
- Limit acceleration and large visual movements.

Existing QPrompt document-position and viewport functions should be reused rather than creating a second scrolling implementation.

The current MVP reuses QPrompt's `position` animation and reading-region geometry. Stable matches target a bounded position five script tokens ahead of the last confirmed word to compensate for recognition latency. Voice-driven position changes use a 520 ms linear, retargetable animation so successive partial results blend more smoothly than the original short ease-out movement.

This is an initial latency compensation mechanism, not yet a full pace controller. Estimating delivery pace, predicting continuously between recognition updates, and applying explicit acceleration limits remain planned improvements. The five-token lead is exposed as a tunable session property while real reading behaviour is evaluated.

## Tracking states

Suggested states are:

- **Disabled:** no microphone use or model activity.
- **Loading:** model or audio device is being initialized.
- **Listening:** audio is active but no stable match is available yet.
- **Following:** stable local matches are driving the viewport.
- **Holding:** silence or insufficient confidence; viewport remains stationary.
- **Lost:** no plausible local match exists; manual repositioning is required. **Planned; not currently a distinct runtime state.**
- **Error:** permission, device, model, or runtime failure.

The UI should communicate these states without distracting the presenter.

## Manual interaction

Manual input always has priority.

When the user scrolls, selects a marker, or otherwise changes position manually:

1. Suspend automatic motion immediately.
2. Move the expected token pointer to the new visible region.
3. Rebuild the bounded matching window if needed.
4. Resume following after a stable local speech match is established.

The operator must also be able to disable voice following instantly while preserving the current script position.

## Privacy and platform requirements

- Voice following is off by default.
- Show an unambiguous microphone/listening indicator.
- Do not retain audio after it has been processed.
- Do not transmit audio or recognized text.
- Add Android `RECORD_AUDIO` permission handling.
- Add `NSMicrophoneUsageDescription` to macOS and iOS application metadata.
- Handle browser permission and secure-context requirements if WebAssembly support is pursued.
- Clearly report when no compatible offline model is installed.

The current implementation is Windows-only. Development builds can load locally staged Vosk assets through environment variables, while the Windows installer places the runtime and English model beside QPrompt and discovers them automatically. Android, Apple-platform, WebAssembly, model-installation UI, and microphone-selection work has not started.

## MVP scope

The first proof of concept should deliberately be narrow:

- One desktop platform.
- One English offline streaming model.
- Plain and rich-text scripts using the existing editor.
- Matching restricted to visible text plus a small look-ahead/look-back window.
- Silence holds position.
- Minor omissions and substitutions are tolerated.
- Manual repositioning resets the local tracker.
- Minimal listening/following/holding status display.

The proof of concept should be developed against recorded audio before microphone and UI integration. This makes the alignment behaviour deterministic and testable.

## Test scenarios

Create fixtures containing a script, recorded audio, and expected progress positions. At minimum, cover:

- Clean reading at slow, normal, and fast speeds.
- Pauses of different lengths.
- A missed or mispronounced word.
- An omitted sentence.
- A short improvised phrase.
- Repeated words and repeated sentences.
- A local backward reread.
- Background noise and a distant microphone.
- Manual repositioning followed by reacquisition.

Track these measurements:

- Recognition-to-motion latency.
- Word-position error.
- Time spent confidently following.
- Recovery time after a local skip.
- False forward or backward jumps.
- CPU and memory use.

Current automated coverage consists of deterministic `ScriptFollower` unit tests and one manual Vosk integration harness using the official 16 kHz recorded sample. The matcher tests cover exact local speech, recognition errors, weak evidence, bounded tracking windows, nearby skips, apostrophe/case normalization, backward-movement rejection, and bounded reading lead. The broader recorded-audio matrix and quantitative measurements above remain to be built.

## Initial acceptance criteria

The MVP is successful when:

- It operates with networking disabled after model installation.
- Normal reading keeps the active passage within the configured reading region.
- Pausing speech reliably stops automatic movement.
- Minor recognition errors do not produce visible jumps.
- Skipping a nearby sentence reacquires without manual search.
- Low-confidence input holds position.
- Manual navigation overrides motion and allows local reacquisition.
- Audio processing does not visibly degrade QPrompt's rendering or scrolling performance.

## Principal risks

- Model size and runtime performance on older or mobile hardware.
- Recognition quality across languages, accents, microphones, and noisy venues.
- Ambiguity in scripts containing repeated phrases.
- Unstable partial recognition results causing jitter.
- Packaging and microphone permissions beyond Windows.
- WebAssembly memory limits and model delivery size.

These risks should be addressed through bounded local matching, conservative confidence handling, recorded-audio regression fixtures, and backend-independent recognizer integration.

## Completed first implementation step

The standalone C++ script-following test harness now accepts:

- Plain script text.
- A prerecorded audio file.
- Partial token results from one offline recognizer.

It outputs partial/final hypotheses, document offsets, confidence values, and stability decisions. The same matcher and recognizer are now connected to Qt microphone capture and QPrompt's existing viewport controls. Timestamped output and a larger regression corpus remain follow-up test work.

## Implementation status

The Windows desktop MVP is connected end to end:

- `ScriptFollower` provides Unicode-aware tokenization, original document offsets, bounded look-back/look-ahead matching, confidence gating, and stronger evidence requirements for backward movement.
- Weighted local sequence alignment tolerates missing, inserted, and incorrectly recognized words and holds position when evidence is weak.
- `OfflineSpeechRecognizer` defines a backend-neutral worker interface.
- `VoskSpeechRecognizer` dynamically loads the Vosk C runtime, so Vosk is not a build-time dependency.
- `VoiceFollowSession` runs Vosk recognition on a worker thread and captures the default microphone through Qt Multimedia.
- Native microphone formats are downmixed and resampled locally to 16 kHz mono PCM instead of rejecting devices that do not expose that exact format directly.
- QPrompt exposes an always-visible **Voice follow** control in prompting mode with Loading, Listening, Following, Waiting for speech, and Error feedback.
- Stable matches drive QPrompt's existing reading-region position. A tunable five-token lead compensates for recognizer latency, and a 520 ms linear retargetable animation smooths successive updates.
- Silence changes the session to Holding after approximately 1.4 seconds and stops new automatic targets.
- Manual scrolling and marker navigation re-anchor the bounded tracking window. Selecting a normal scroll velocity disables voice following.
- `scripts/setup-vosk-dev.ps1` stages the Windows runtime, small English model, and official recorded sample in the ignored build tree.
- `scripts/run-qprompt-voice-dev.ps1` validates those assets, sets the local runtime/model environment, and launches the installed Debug application with visible Qt diagnostics.
- `scriptfollower_test` supplies deterministic matcher tests, including bounded forward lead.
- `vosk_recognizer_smoke` verifies the real runtime/model path and feeds recognized partial results into `ScriptFollower` using recorded 16 kHz mono PCM.

The Vosk runtime, English model, and recorded sample are downloaded build assets and are not committed to the repository. Windows Release packaging embeds the runtime, its companion DLLs, the English model, and the Vosk Apache-2.0 license in the installer; the recorded sample remains development-only. The installed application discovers these files relative to `QPrompt.exe`, needs no Voice Follow environment variables, operates without networking, and does not transmit or retain microphone audio.

## Windows self-contained installer

Run the complete Release workflow from PowerShell in the repository root:

```powershell
.\scripts\build-windows-voice-installer.ps1
```

The script prepares the pinned Vosk assets, configures and builds Release, runs the deterministic tests, stages the application, and invokes CPack/NSIS. Its default Qt prefix is `C:\Qt\6.8.3\msvc2022_64`; pass `-QtPrefix` when Qt is installed elsewhere. The output is `build-release\qprompt-2.1.0-win64.exe`.

The Windows package is deliberately monolithic. QPrompt, Qt/QML, KDE/Kirigami runtime files, the Microsoft runtime, Vosk, and the speech model are installed together so Voice Follow cannot be omitted through component selection. A clean-path smoke test of the generated installer confirmed that the installed application loads Vosk and its three companion DLLs from its own `bin` directory and opens a native 48 kHz stereo float microphone without either `QPROMPT_VOSK_LIBRARY` or `QPROMPT_VOSK_MODEL`.

The MVP is functional and packaged on Windows but not complete. Current priorities are calibrating reading lead and motion against real presenters, replacing fixed lead with measured short-term pace prediction, expanding recorded-audio regression coverage, profiling audio conversion, adding input-device selection, and implementing packaging and microphone permissions beyond Windows.
