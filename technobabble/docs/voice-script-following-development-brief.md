# Technobabble: offline voice following

This brief describes the Rust implementation in Technobabble 0.2.0. It replaces the retired C++/Qt development brief.

## Current design

CPAL captures microphone audio on a native callback. A bounded queue feeds Vosk on a worker thread. The follower aligns recognized words against a local script window; accepted matches produce a smoothed visual target. Audio and recognition stay local. Microphone use is off at launch.

Manual seeking reanchors the follower and increments the recognition epoch so queued old hypotheses cannot move the script. Matching does not guess distant positions. Mirror and vertical flip transform rendering without reversing logical reading order.

## Guided calibration

The calibration dialog keeps a separate passage and follower, preserving the open script. It pauses prompting and offers three steps:

1. Load the selected microphone and speech model, then sample four seconds of room noise.
2. Read the supplied English passage naturally. Collect raw input levels, peak level, and advancing script matches.
3. Review gain, noise floor, lead words, and smoothing suggestions. Apply explicitly, optionally saving a named presenter preset.

Noise uses the 90th percentile of quiet input samples. Speaking level uses the median of samples sufficiently above that noise. Gain targets a comfortable level while limiting amplified peaks; noise floor is set between measured noise and speech. Lead and smoothing use estimated reading pace. They are heuristics for initial tuning, not a measurement of recognition latency.

Insufficient samples or advancing matches, input clipping, and poor signal-to-noise reject the recommendation. Cancellation stops capture without applying settings. Repeating calibration is appropriate after changing the room, microphone, or presenter. No calibration audio is retained.

Presenter presets store the full voice settings and device name in data/session.json. Loading a preset stops prompting and capture. Existing sessions without presets remain compatible. Saving the same name explicitly replaces its settings.

## Tracking and recovery

- Loading: speech model or microphone is starting.
- Listening: waiting for the first local script match.
- Following: recent accepted matches permit motion.
- Holding, silence: no above-threshold input within the configured timeout. A fresh match is required before motion resumes.
- Holding, mismatch: input is present but does not confidently align.
- Tracking lost: roughly four accumulated seconds of audible input without an accepted match. Silence does not consume this budget.
- Paused: capture remains available but prompting is stopped.
- Error/off: capture is stopped and the error is shown.

The most recently accepted script phrase is retained and highlighted in preview and output, including mirrored/flipped views. Rejected hypotheses do not replace it. Manual reanchoring clears it. The Resume from here action sets the tracker at the current reading guide, clears old hypotheses, and starts waiting for fresh local speech. Nearby valid speech can also recover automatically.

## Implementation and verification

- calibration.rs: guided sampling, recommendation validation, presenter preset type.
- tracking.rs: tracking health and audible-time accounting.
- follower.rs: bounded alignment and matched character range separate from reading lead.
- voice.rs: audio capture, raw meter/peak counters, speech engine and epoch reset.
- app.rs: wizard, preset persistence, recovery controls and highlight rendering.

Automated tests cover calibration validity and rejection, old session/preset round trips, silence/lost/recovery transitions, Unicode phrase boundaries, alignment and display geometry. See VALIDATION.md for actual platform checks and limitations. Real presenter trials remain necessary to tune the heuristics across accents, rooms and microphones. The calibration passage currently assumes an English speech model. The current Windows, Apple Silicon and Linux verification is recorded in VALIDATION.md.

## Spoken forms and Word scripts

`speech_text.rs` normalizes English numeric, currency, percentage, ordinal, date and abbreviation readings before local alignment. Script-only pronunciation aliases are edited in the voice controls and saved with the session. Every normalized word retains its source character range; multiword expansions must match together so a wrong numeric suffix is not sufficient evidence. Highlighting and manual reanchoring still use the unchanged script. Lead advances between source ranges rather than within expansions.

`word.rs` reads only the bounded DOCX document body with ZIP and namespace-aware XML parsers. Direct run emphasis uses Unicode character spans; the shared preview/output layout converts these to byte boundaries. Unaffected spans survive text edits. Word imports are unsaved copies and text saving rejects non-text extensions. Recovery persists aliases, emphasis and the display toggle, with defaults for older sessions. See README for supported readings and Word import limitations.

## Required platforms

Windows 11 x86-64, native Apple Silicon macOS, and Linux x86-64 (Ubuntu 22.04 build baseline) are required targets. Changes must pass the same Rust tests and strict Clippy checks on all three, plus packaged speech checks. The repository-root workflow and standalone source workflow enforce these build checks. Linux headless window checks use Xvfb; real microphone, Wayland and portal interactions still require desktop acceptance checks.

## Presentation and remote controls

`presentation.rs` owns appearance, presentation preset snapshots and screen selection/fallback. `app.rs` renders the same appearance in preview and output and applies output positioning only on explicit open/move/preset load, allowing later manual movement. Native screen coordinates are converted for viewport scaling; Wayland uses manual placement. Style cache invalidation preserves the script character anchor when typography changes.

`remote.rs` stores portable logical-key chords and two bindings per action. Key events retain their own modifiers; exact matching and non-repeat key-down dispatch prevent accidental modified-key and held-pedal actions. The UI records a key without running it and keeps pointer controls usable during recording. Text edits and modal work block playback keys. Output-window keys invoke the same actions. Both new settings sets persist in session recovery with legacy defaults.
