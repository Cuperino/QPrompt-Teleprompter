# Technobabble

A standalone Rust rebuild of the core QPrompt workflow, with adjustable offline
microphone voice-follow designed into the first version. Everything belonging to
this project lives in this directory. The retired C++/QML project is no longer part of the active workspace.

## Required platforms

Windows 11 (x86-64), macOS on Apple Silicon (native ARM64), and Linux (x86-64, Ubuntu 22.04 or newer as the build baseline) are required targets. New features must compile and pass the same tests on all three. Linux distributions need compatible system graphics/audio libraries; this is not a fully static executable for every Linux distribution.

The repository-root `.github/workflows/technobabble-native.yml` builds all three targets on pushes and pull requests. The standalone source archive includes its equivalent `.github/workflows/native.yml`. Each job runs formatting, strict Clippy, unit tests, native release packaging and a packaged Vosk recording test. Linux additionally creates an X11 window under Xvfb; macOS verifies the app signature. Native live-microphone and desktop file-dialog checks remain manual acceptance checks. Windows CI uses a Windows Server runner; Windows 11 is checked locally.

## Run the Windows package

Open `dist/technobabble-windows-amd64/technobabble.exe`. Keep the accompanying
`voice` directory beside the executable. No installer, Python, Qt, browser, account,
API key, or internet connection is needed at runtime. Use a writable folder.

Choose **Voice follow**, then **Start**, to follow your microphone. **Pause** holds
the script but keeps the microphone available; **Turn microphone off** releases it.
The microphone is always off on launch. Audio and transcripts are never saved or
sent over a network.

## Features

- Editable scripts; clipboard support; drag-and-drop text and Word files; UTF-8 and UTF-16
  import; UTF-8 saving with atomic replacement and overwrite confirmation.
- Frame-time-based timed scrolling, adjustable speed, countdown, reverse and loop.
- Offline voice-follow with microphone selection, match threshold, reading lead,
  search-window size, smoothing, silence timeout, gain, noise floor, and optional
  confident backward tracking. Holds on unrelated speech or silence.
- Adjustable type size and column width; horizontal mirror and vertical flip;
  reading guide; fullscreen; a separate output window for another monitor.
- `#` cue markers, find-and-jump, wheel/drag seeking, elapsed timer.
- Automatic recovery of script and settings in `data/session.json` every two
  seconds after changes and on clean exit. Saving a named script is explicit.
  A recovery write failure is shown and prevents silent exit.
- Cached text geometry, visible-row culling, on-demand idle redraws, and a bounded
  microphone queue with recognition on a worker thread.

The following are the default keyboard shortcuts; configurable bindings can replace them. Keyboard shortcuts apply after clicking the preview, so typing in the editor does
not start playback accidentally:

| Key | Action |
| --- | --- |
| Space | Start / pause |
| Esc | Pause and leave fullscreen |
| Up / Down | Increase / decrease timed speed |
| Left / Right | Seek backward / forward |
| Home / End | Start / end of script |
| Page Up / Page Down | Previous / next `#` cue |
| M | Mirror horizontally |
| F | Flip vertically; reverse on-screen scroll direction |
| F11 | Fullscreen; also works in the output window |
| Ctrl/Cmd+O | Open text or Word script |
| Ctrl/Cmd+S | Save |
| Ctrl/Cmd+Shift+S | Save as |

Double-click the preview to start/pause. Open and Save As use the native system
file browser, including folder navigation and overwrite confirmation. Browsing
pauses playback and microphone capture. Markdown is displayed as plain text.
M and F also work in the separate output window. F changes the screen orientation
and motion, while script progress (including voice-follow) stays in reading order.

## Guided calibration and tracking recovery

In the voice controls, choose **Calibrate voice...**. Select your microphone before starting.

1. Begin the room-noise check and stay quiet for four seconds.
2. Continue to reading and read the displayed passage naturally. Your script is not replaced.
3. Review the suggested gain, noise floor, lead words, and smoothing. Apply them, or enter a presenter name and choose **Apply and save / replace preset**.

The suggestions use unamplified input levels and matched reading pace. Lead and smoothing are starting estimates, not measured recognition latency. Clipped input, insufficient matching speech, and poor signal-to-noise prevent a recommendation. Repeat calibration after changing the microphone or room. Nothing is applied until you confirm; Cancel stops the microphone and keeps your original settings. No calibration audio is recorded.

**Presenter presets** stores named voice settings (including the microphone) in the portable `data/session.json`. Click a name to load it; playback pauses. Saving with the same name replaces that preset. You can also save manually tuned settings here.

During voice playback, **Holding - silence** means the input is quiet. **Holding - speech does not match** means speech has not aligned confidently. After about four accumulated seconds of audible input without a match, **Tracking lost** appears. Input level alone never advances the script. A fresh nearby match can recover tracking automatically.

The last accepted phrase is highlighted in both the preview and output, respecting mirror and flip. To recover after a larger skip, move the desired line to the reading guide and click **Resume from here**. This discards stale recognition and waits for a fresh local match; it does not jump to a guessed distant passage.

## Presentation presets

Open **Controls → Appearance and presentation presets** to choose sans serif, bold sans serif or monospace text, line spacing, text/background/guide colours, and guide position. Text size, column width, guide visibility, mirror and flip remain in the display controls below. Enter a presentation name and choose **Save / replace presentation** to store these settings together. Click a saved name to load it; playback pauses and the script stays open. Presentation presets are separate from microphone/presenter presets and persist in `data/session.json`.

**Refresh screens** lists the connected outputs. Select a preferred output screen, then use **Open / move output to screen**, or save it with a presentation preset. Loading the preset moves an already-open output; opening the output later also uses the preference. A missing screen falls back to the primary screen when opening or applying the preset. **Manual placement** lets you drag the window yourself. Display numbering may change after rearranging cables; refresh and reselect the output if needed. Wayland compositors control window placement, so on Wayland the app explicitly requests manual placement using the desktop's window controls. F11 still toggles output fullscreen.

## Configurable clickers, pedals and shortcuts

Open **Controls → Remote controls and shortcuts**. Each action has two bindings, allowing a keyboard key and a presenter clicker or keyboard-style foot pedal to perform the same action. Click a binding and press the desired device key or chord. Conflicts are rejected with a message; clear the other assignment first. Escape or **Cancel recording** cancels capture; **Restore default shortcuts** resets the mappings.

Actions include start/pause, pause only, faster/slower, previous/next cue, seeking, script start/end, mirror and flip. For example, assign a pedal's `B` key to **Pause only**, or clear the default Page Down cue mapping and assign a clicker's Page Down key to **Start / pause**. Capture pauses playback. Settings survive restarts.

Controls work when the preview or output window has keyboard focus. Editing the script, a preset name or another text field does not trigger playback commands. Key-repeat events are ignored, so holding a pedal does not repeatedly toggle playback. Escape always pauses; F11 and Open/Save chords are reserved. Command-key bindings use Cmd on macOS and Ctrl on Windows/Linux. These are foreground keyboard controls, not global shortcuts or raw USB/Bluetooth HID drivers; a device must send keys the OS exposes to the application. OS-reserved shortcuts may never reach the app.

## Spoken-text matching

English voice following recognizes reading forms without changing the displayed script:

- Numbers, grouped thousands, decimals, negatives, ordinals and percentages: `1,204`, `3.5`, `-25`, `21st`, `25%`.
- Pounds, dollars and euros: `£25` matches “twenty-five pounds”; `£1.05` matches “one pound and five pence”. Two decimal places use minor currency units.
- UK day/month/year dates and ISO year-month-day dates: `03/11/2026` and `2026-11-03` match “the third of November twenty twenty-six” or “third November two thousand twenty-six”. Numeric dates use four-digit years and UK ordering, never US month/day ordering.
- Days beside written months, such as `3 Nov 2026` or `November 3, 2026`, support ordinal readings in the written order. Common month abbreviations, titles (`Dr.`, `Prof.`), and initialisms (`BBC`, `NHS`, `UK`, `USA`, `CEO`, `AI`, `FBI`) have built-in readings.

Under **Voice follow → Pronunciation aliases**, enter one `written phrase = spoken phrase` per line, for example `Siobhan = shiv on` or `SQL = sequel`. Use the words the recognizer actually produces. The longest matching phrase wins; aliases are case-insensitive, apply only to script text and are saved in session recovery. Empty or malformed lines are ignored. Aliases can override built-in readings for unusual names, acronyms or preferred pronunciations.

Matching remains local and confidence-gated; an expanded amount must match as a whole. Optional “and”, “the” and “of” do not count as alignment evidence. These are English reading rules, not general multilingual number understanding. Use aliases for unsupported readings. Live accuracy still depends on the speech model and microphone.

## Word document import

Open or drop a `.docx` file directly. Word is not required. Paragraphs become separated script paragraphs; blank paragraphs, explicit line breaks, tabs, Unicode and table-cell text are retained in reading order. Deleted revision text, hidden runs and field instructions are omitted; inserted text and visible field results are retained.

Directly applied **bold**, *italic* and underline are retained for preview and output. The editor's **Show imported emphasis in preview / output** checkbox toggles them. Editing keeps unaffected formatting; an edited formatted run becomes plain. The editor itself remains plain text.

Import creates an unsaved script copy. **Save** writes `.txt` or `.md`, never overwrites the Word file, and exports plain text. Emphasis and its display preference survive app restart through session recovery, but are not stored in text exports. Import is not Word layout reproduction: inherited styles, automatic list numbering, headers/footers, comments, drawings and text boxes are not imported. Legacy `.doc`, password-encrypted files and macro-enabled Word files are unsupported. DOCX archives are limited to 32 MiB and their uncompressed document body to 8 MiB.

## Build on Windows, Linux, or macOS

Install a current stable Rust toolchain. The lockfile pins Rust dependencies.
Python 3.9+ is used only to stage voice assets and assemble distributions.

Apple Silicon: extract `dist/technobabble-darwin-arm64.zip`, keep `voice/` beside `Technobabble.app`, and open the app from a writable folder. The app is locally ad-hoc signed, not Developer ID notarized. macOS microphone access uses the usage description in the app bundle.

Linux: extract `dist/technobabble-linux-x86_64.zip` with a ZIP tool that preserves Unix permissions, then run `./technobabble` from a writable folder with its adjacent `voice/` directory. If extraction drops execute permission, run `chmod +x technobabble`. Use a normal X11 or Wayland desktop with OpenGL, ALSA-compatible audio and an XDG desktop portal/backend for native file browsing. On Ubuntu 22.04, runtime packages include `libasound2`, `libxkbcommon0`, `libxkbcommon-x11-0`, `libwayland-client0`, `libgl1`, `libegl1`, `libx11-6`, `libxi6`, `libxcursor1`, `libxrandr2`, `libxcb-randr0`, `xdg-desktop-portal` and a desktop-specific portal backend such as `xdg-desktop-portal-gtk`.

Windows: install the Visual Studio C++ build tools / Windows SDK, then:

```powershell
cd C:\Dev\teleprompter\technobabble
cargo test --locked
python scripts/package.py
```

Linux (Debian/Ubuntu development packages):

```sh
sudo apt-get install build-essential pkg-config libasound2-dev libxkbcommon-dev libxkbcommon-x11-0 \
  libwayland-dev libgl1-mesa-dev libx11-dev libxi-dev libxcursor-dev libxrandr-dev libxcb-randr0-dev
cargo test --locked
python3 scripts/package.py
```

macOS: install Xcode command-line tools, then:

```sh
xcode-select --install
cargo test --locked
python3 scripts/package.py
```

Build separately on Intel and Apple Silicon Macs for each executable architecture.
The included Vosk macOS library is universal2. The packaging script creates an
ad-hoc-signed `.app` with a microphone usage description. Move the **whole** output
folder, keeping `voice` beside the `.app`. Public distribution requires your own
Developer ID signing/notarization. Linux uses system ALSA and window-system/GL
libraries; macOS uses its system audio/window frameworks; Windows uses system APIs.

On the configured Mac, Rust is isolated under this project's `.toolchain/` without
changes to shell startup files. To use that toolchain for future builds:

```sh
sh scripts/with-toolchain.sh cargo test --locked
sh scripts/with-toolchain.sh python3 scripts/package.py --skip-download
```

The standalone `.github/workflows/native.yml` builds Windows, Linux, Apple Silicon,
and Intel Mac packages when this directory is used as a repository root. It has not
been uploaded or run remotely as part of this local rebuild.

For development: `cargo run --locked`. All local build products stay in `target/`.
For a portable package using already staged assets:
`python scripts/package.py --skip-download`. `RUST_PROMPTER_HOME` can explicitly
override the portable data/voice root for testing or read-only installations.

## Offline speech assets

`scripts/setup-voice.py` downloads pinned Vosk wheels and extracts **only native
libraries**, without installing Python packages. It verifies fixed SHA-256 hashes
for the runtime and model. Windows/Linux use Vosk 0.3.45; macOS uses the upstream
universal2 0.3.42 build. The small English model is `vosk-model-small-en-us-0.15`.

To use another language/model, replace `voice/model/` with an unpacked compatible
Vosk model containing `conf/`, `am/`, and its other model files. Stop voice-follow
first. Spell out numbers as spoken and use a quiet microphone for better matching.
Long jumps beyond Look ahead need a manual seek to reanchor. Low-confidence speech
holds the position; it does not fall back to timed scrolling.

The voice controls are deliberately independent: the **match threshold** controls
script alignment, **noise floor** controls silence detection, and **gain** scales
microphone samples. Smoothing is the approximate response time, in seconds. Higher
lead places more upcoming words near the reading guide.

Sources: [Vosk API](https://github.com/alphacep/vosk-api),
[Vosk models and licenses](https://alphacephei.com/vosk/models),
[CPAL](https://docs.rs/cpal/0.16.0/cpal/),
[eframe](https://docs.rs/eframe/0.33.3/eframe/).

## Checks and current limits

```sh
cargo fmt --check
cargo clippy --locked --all-targets -- -D warnings
cargo test --locked
cargo run --release --locked -- --voice-smoke
```

The optional real-engine smoke test uses `voice/test.wav` and writes
`data/voice-smoke.txt`. This checkout includes the existing QPrompt Vosk test fixture.
It tests real speech decoding plus script matching, separately from live microphone
startup. See `VALIDATION.md` for the checks actually performed.

This is a usable first rebuild, **not full QPrompt feature parity**. Windows and
Apple Silicon macOS native builds and real-engine speech tests pass. Linux and
Intel Mac execution still need validation on those systems. No comparative
performance claim against QPrompt has been established.
Not yet ported: Word/ODT/HTML rich import, rich-text formatting, spellcheck, global
hotkeys, network remotes, localization, session recordings, and mobile builds.
The bundled fonts cover common Latin/Greek/Cyrillic text; comprehensive CJK/complex
script shaping and right-to-left editing need further font/rendering work.

## Implementation

Six direct crates: `eframe` (native GPU UI), `cpal` (native audio), `libloading`
(local Vosk library), `serde`, `serde_json` (portable session data and engine results),
and `rfd` (native file browsing).
They have transitive dependencies, pinned in Cargo.lock. There is no webview,
JavaScript UI, Qt/KDE, Python runtime, cloud SDK, updater, telemetry, or runtime asset
download. Rust libraries link into the executable. Vosk and the language model are
the substantial external runtime assets needed for offline recognition.

`app.rs` owns the interface; `model.rs` owns playback; `follower.rs` owns bounded
speech alignment; `voice.rs` isolates capture and the small unsafe Vosk FFI;
`storage.rs` owns portable paths and atomic saves. License: GPL-3.0-only, consistent
with the source project. See `LICENSE` and `THIRD-PARTY.md`.

## Repeatable packaged checks

After packaging, `python scripts/check-package.py dist/<platform-folder>` checks the actual packaged executable against the pinned recorded-speech fixture. The setup script downloads and verifies this fixture along with the speech assets. On Linux, install `xvfb` and `x11-utils`, then run `xvfb-run -a python3 scripts/check-package.py dist/technobabble-linux-x86_64 --linux-window`. This checks window creation, not real audio hardware or Wayland integration. On an interactive Mac, `python3 scripts/check-macos.py dist/technobabble-darwin-arm64` also checks native window creation and microphone metadata.

Build and package from the `technobabble/` directory so its Cargo configuration is applied. Packaging discovers Cargo's actual target directory, including a `CARGO_TARGET_DIR` override.
