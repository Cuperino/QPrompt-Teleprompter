# Third-party components

This rebuild accompanies QPrompt, Copyright © 2020–2026 Javier O. Cordero Pérez.
QPrompt and this rebuild are distributed under GPL-3.0-only; see LICENSE.

The Rust application links these direct libraries and their dependencies:

| Library | Purpose | Declared license |
| --- | --- | --- |
| eframe / egui | Native UI, graphics, accessibility | MIT OR Apache-2.0 |
| rfd | Native file browsing | MIT |
| cpal | Native microphone capture | Apache-2.0 |
| libloading | Speech-library loading | ISC |
| serde / serde_json | Structured local data | MIT OR Apache-2.0 |
| zip | Bounded DOCX archive reading | MIT |
| roxmltree | Namespace-aware Word XML parsing | MIT OR Apache-2.0 |
| display-info | Native output-screen discovery | Apache-2.0 |

DejaVu Sans Bold is embedded for imported Word emphasis. Its original font notice
is in `assets/DejaVu-LICENSE.txt` and copied into packaged `third-party-licenses`.
The font and notice were retained from the original QPrompt source assets.

Cargo.lock records the exact dependency graph. `scripts/collect-licenses.py`
collects available dependency notices into the portable package and writes a
dependency inventory. Consult each component's notice for its terms.

Vosk API is Copyright Alpha Cephei Inc and contributors, Apache-2.0. The English
model `vosk-model-small-en-us-0.15` is listed as Apache-2.0 by its publisher. Its
original README is retained in voice/model. Vosk's upstream license is retained in
voice/VOSK-COPYING or voice/VOSK-LICENSE. The prebuilt Windows runtime also uses
GCC/libstdc++/winpthreads support libraries distributed with the upstream Vosk build;
their licenses and runtime exceptions remain applicable. Preserve the supplied
runtime directory and license notices when distributing.

- https://github.com/alphacep/vosk-api
- https://alphacephei.com/vosk/models
- https://gcc.gnu.org/onlinedocs/libstdc++/manual/license.html
- https://www.mingw-w64.org/license/

Build/setup tools (Rust, Python) are not included in or required by the runtime
package. Modified application source is in this standalone directory; retain or
provide corresponding source when redistributing under GPL.
