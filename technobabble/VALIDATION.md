# Validation — 3 November 2026

## Version 0.1.1: native browsing and flip shortcut

- Open and Save As now use native OS file browsers through `rfd`, with text filters,
  existing-script directory selection, overwrite confirmation, and cancellation.
- Windows UI checks navigated folders and opened a test script; Save As opened
  from Ctrl+Shift+S, and cancellation preserved the document.
- F toggles vertical flip. Visually verified downward motion during flipped timed
  playback while logical script progress remains forward. M and F are available
  in the main preview and independent output window.
- Fixed preview focus blocking playback shortcuts, plus fast Ctrl/Cmd chords whose
  modifiers were released before the frame processed them. Space and F were checked
  in the Windows preview. Text editing still suppresses prompting shortcuts.
- Windows and Apple Silicon release builds, all 10 tests, and strict Clippy passed
  after these changes. Mac file-dialog interaction awaits a local hands-on check.
- Linux native builds/testing are deferred at the user's request.

Host: Windows x86_64; Rust 1.99.1. Original repository merge conflicts were present
before this work and were left unchanged. All implementation files and build
products are under `rust-prompter/`.

Additional native host: Apple M2 Pro Mac mini, macOS 27.2, Rust 1.99.1. Remote
project: `/Users/fin/Dev/rust-prompter`. Rust was installed in `.toolchain/` inside
that directory with `--no-modify-path`; no shell startup files were changed.

## Apple Silicon validation completed

- Native `cargo test --locked`: all 10 tests passed.
- Native release compilation, `cargo fmt --check`, and strict all-target Clippy passed.
- Setup ran with system Python 3.9.6. Replaced Python 3.11-only hashing and corrected
  upstream Vosk's `libvosk.dyld` archive name to the application's `libvosk.dylib`.
  Setup now checks that the required native library was actually extracted.
- Created and ad-hoc signed the `.app`; `codesign --verify --deep --strict` passed.
- The **packaged app executable**, using its adjacent model/runtime and portable
  path discovery, passed the recorded-audio test with 15 accepted follow matches.
  Warm runs took about 0.88–1.08 seconds including 0.26–0.48 seconds model load.
- LaunchServices opened the native application. CoreGraphics confirmed its
  1280 × 852 window. This is window-creation verification, not a visual UI review:
  remote window screenshot capture was unavailable.
- `scripts/check-macos.py` repeats signature, microphone-metadata, packaged speech,
  and non-zero-sized native-window checks without changing system permissions.

## Completed

- `cargo fmt --check`.
- `cargo clippy --locked --all-targets -- -D warnings`.
- `cargo test --locked`: 10 tests passing. Covers countdown timing, end/loop/reverse
  behavior, malformed settings, UTF-8/UTF-16 and binary rejection, atomic replacement,
  speech alignment, repeated phrases, Unicode punctuation, no accidental backward
  jumps, and reversible mirror geometry without changing the original layout.
- `cargo build --release --locked`: Windows executable built successfully.
- Real Vosk integration: bundled model loaded, recorded PCM fixture decoded, and
  resulting hypotheses passed through the Rust script follower. 15 accepted matches.
  A release run took about 2.43 seconds total including 1.38 seconds model loading.
  Timing varies by machine; this is not an end-to-end microphone latency benchmark.
- Windows native interface launched and inspected through accessibility and screen
  capture. Editable script, display controls, voice tuning controls, and preview
  present. Horizontal mirror visually verified. Corrected theme mismatch and
  inspected the final dark release interface.
- Packaged release completed timed playback and stopped at the script end. Separate
  output window opened; its fullscreen and Escape return were visually checked.
  Clean application exit wrote the portable recovery file successfully.
- Live default microphone opened through CPAL and reached Listening state; stopped
  after the check. This validates microphone startup, not spoken accuracy for a
  human speaker. No microphone recording was persisted.
- SHA-256-verified Windows voice setup script ran successfully. Portable package
  assembled including model, runtime, application license, and Rust dependency notices.
- Python packaging/setup scripts passed syntax compilation.

## Measurements

Initial release executable: about 4.15 MiB. Portable folder including voice assets
and license notices: about 126.34 MiB. Idle startup working set observed around
111 MiB with microphone off. These are snapshots, not guaranteed ceilings.

No controlled comparison against the original Qt application was performed.
The implementation reduces framework requirements, caches text layout, bounds
recognition buffering, and avoids continuous repaint while idle. A comparative
claim that it is faster than QPrompt would require matched workload measurements.

## Still requiring target-machine validation

- Linux native compile/package, window creation, audio-device compatibility, and
  X11/Wayland behavior.
- Apple Silicon macOS live microphone permission, human speech following, visual
  UI review, and output-window behavior. Intel Mac native execution is unverified.
- Human-read microphone following across different accents, microphones, and rooms.
- Physical multi-monitor use, long-duration prompting, and detailed accessibility
  testing. Output-window creation/fullscreen was checked on one Windows desktop;
  it is not yet certified for a live shoot.

The Apple Silicon Mac has been reached and built over SSH. Linux native validation
is deferred at the user's request; the source bundle and build commands remain
available for later use.

## Run on the other machines

Extract `dist/rust-prompter-source.zip` to a writable directory. Install a stable
Rust toolchain and Python 3.9 or newer. Run from the extracted `rust-prompter/`:

```sh
cargo test --locked
python3 scripts/package.py
cargo run --release --locked -- --voice-smoke
```

See README for Linux build packages and macOS command-line tools. On macOS, launch
the generated `.app` for live microphone testing so its usage-description metadata
is available. Keep the `voice/` directory beside the `.app`.

Manual acceptance: edit and save a short script, start timed playback, pause, resize
without losing the reading position, test horizontal/vertical mirror, move the
output window to another screen, then enable Voice follow and read aloud. Check
that silence and unrelated speech hold the script; adjust threshold and lead; stop
the microphone; reopen the app and verify recovery. Report build output and any
on-screen errors rather than assuming source portability implies runtime success.

## Technobabble 0.1.2

Renamed the product, executable, native app bundle, output window, and archives. Added a generated icon embedded as a Windows executable resource, native window RGBA data, and Mac ICNS bundle resource. No runtime dependencies were added. Windows and Apple Silicon Mac: all 10 tests and strict Clippy passed. Linux remains deferred.

## Technobabble 0.2.0: calibration and recovery

- Guided quiet-room sampling, separate calibration reading passage, bounded gain/noise-floor recommendations, and pace-based lead/smoothing suggestions.
- Named presenter presets persist with session recovery; old sessions remain compatible.
- Separate silence, mismatch and lost states; stale motion is cleared after silence. Resume from here resets the recognition epoch and local script anchor.
- Last accepted phrase is highlighted separately from the reading lead, including mirrored/flipped output.
- Windows and Apple Silicon Mac: 14 tests, strict all-target Clippy and release builds passed.
- Tests cover clipped/insufficient calibration input, bounded recommendations, preset/legacy session round trips, silence/lost/recovery states, and Unicode phrase boundaries.
- Human-read calibration quality is not yet validated. Recommendations are initial heuristics, not measured end-to-end latency. The calibration passage is English.
- Windows UI: verified calibration introduction, real microphone/model startup, four-second room-noise measurement, reading passage, rejection of insufficient speech, and cancellation back to the unchanged script.
- Real-engine recorded-speech smoke check passed after the changes. Full successful human-read calibration and Mac visual/microphone checks remain manual acceptance items.

## Spoken-text matching and Word import — 3 November 2026

- Windows: 21 unit tests pass, strict `cargo clippy --locked --all-targets -- -D warnings` passes, and the optimized release build passes.
- New tests cover equivalent amounts/decimals/percentages/negative numbers/ordinals/date and abbreviation readings, wrong-amount rejection, pronunciation alias source ranges, DOCX archive/XML rejection and decompressed-size limits, paragraphs/tabs/breaks/table text/entities, direct emphasis and Unicode edits, optional display formatting, and legacy/new session persistence.
- Windows UI checked with an isolated DOCX fixture: paragraph extraction, bold/italic/underline in preview, emphasis off/on, horizontal mirroring and a separate mirrored output window. Test recovery was isolated under `target/feature-check`; the user's normal session was not replaced.
- Real local Vosk engine + recorded PCM + follower smoke test passes with 15 stable matches after speech normalization changes. This fixture checks the existing number-word recognition path; new currency/date forms are covered by deterministic transcript tests, not recorded human readings.
- README documents UK numeric-date ordering, English-only reading rules, aliases, direct-formatting support, import size limits and plain-text save behavior. Font notices are included in packaging.
- New live-presenter currency/date/alias trials, Word files from a wider range of editors, and native macOS/Linux checks remain unverified. Prior platform checks above do not certify these new changes.

## Required-platform verification — 3 November 2026

This supersedes the earlier Linux deferral and the unverified macOS/Linux status for the spoken-text and DOCX changes.

| Platform | Tests / strict Clippy | Native release | Packaged speech | Window check |
| --- | --- | --- | --- | --- |
| Windows 11 Pro x86-64 (10.0.26300) | 21 pass / pass | Pass | 15 stable matches | Visually checked in the preceding feature work |
| Apple Silicon ARM64, macOS 27.2 | 21 pass / pass | Pass; ARM64 Mach-O | 15 stable matches | Native window confirmed; ad-hoc signature and microphone metadata verified |
| Ubuntu 22.04.5 x86-64, glibc 2.35, Docker | 21 pass / pass | Pass | 15 stable matches | X11 window created under Xvfb |

Linux's first UI check exposed a missing `libxkbcommon-x11` runtime library. Installing `libxkbcommon-x11-0` resolved the failure; README and both CI workflows now include this dependency. Linux release artifacts were built inside Ubuntu, not cross-compiled on Windows.

The repository-root CI workflow now covers Windows, Apple Silicon and Linux; the standalone source workflow mirrors it. CI validates formatting, strict Clippy, tests, packaging, recorded speech and Linux window creation. The macOS job asserts ARM64 and checks its signature. These workflow files were prepared and their YAML parsed locally; hosted GitHub Actions have not been triggered in this session.

Packaging now uses Cargo metadata to locate custom build output directories. Voice setup downloads a SHA-256-verified recording for repeatable package smoke checks and rejects unknown CPU architectures rather than assuming x86-64. `check-package.py` waits for the actual packaged process, including Windows GUI executables. Mac window checks match the selected package's executable path.

Updated Windows, Apple Silicon and Linux ZIPs and the source ZIP are in `dist/`. Unix ZIPs are created on their native hosts to retain executable permissions. Mac testing used an isolated copy at `/Users/fin/Dev/technobabble-platform-check-20261103/technobabble`; Linux used an isolated Ubuntu container. Existing presenter recovery files were preserved.

Remaining manual coverage: live microphone capture and permissions on the Mac/Linux desktops, Linux Wayland and desktop portal file browsing, and broader Linux distributions. Xvfb is a headless X11 window check, not a real desktop or audio-hardware test. macOS packages are ad-hoc signed, not Developer ID notarized.

## Presentation presets and configurable remote keys — 3 November 2026

- Added presentation-only presets covering font family/size, column width, line spacing, text/background/guide colours, guide visibility/position, mirror, flip and preferred output screen. Old sessions receive defaults; loading a preset leaves the script and voice calibration intact and pauses playback.
- Added two keyboard bindings per action, learn/cancel/clear/reset controls, exact modifier matching, conflict/reserved-key rejection and held-key repeat suppression. Main preview and output use the same dispatcher; text-field editing and modal/calibration work suppress playback commands.
- 25 Rust tests cover the new preset round trip/clamps, disconnected-screen fallback, rendering style, legacy/new session persistence, key conflicts, modifiers and repeats, alongside existing voice/DOCX tests. Windows, native Apple Silicon and Ubuntu x86-64 tests and strict Clippy pass.
- Windows UI with isolated session data: custom font/spacing/colours/guide rendering, save/replace preset, change spacing and reload to restore it, screen selection, output creation with matching appearance, learned secondary B binding, start/pause in preview and output, and typing B in the editor without starting playback. Recovery JSON contains the preset, screen preference and learned binding.
- Screen enumeration adds the Apache-2.0 `display-info` dependency. Linux build instructions and CI now include `libxcb-randr0-dev` (runtime `libxcb-randr0`). Wayland explicitly uses compositor/manual window placement; automatic screen selection is available on Windows, macOS and X11.
- Packaged speech checks and Linux headless native-window checks remain part of validation. Physical clicker/pedal hardware, mixed-DPI multi-monitor movement, monitor hot-unplug and interactive Mac/Linux shortcut controls have not been hands-on tested. Only one display was available during the Windows UI check; missing-screen fallback is unit-tested.
