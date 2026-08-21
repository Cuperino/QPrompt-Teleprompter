#!/bin/bash
#**************************************************************************
#
# QPrompt
# Copyright (C) 2026 Javier O. Cordero Pérez
#
# This file is part of QPrompt.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#**************************************************************************
#
# macOS counterpart to scripts/setup-vosk-dev.ps1: downloads the Vosk
# runtime and the initial English model that CMakeLists.txt's APPLE Voice
# Follow bundling block expects under build/voice-assets.
#
# Vosk's own releases stopped shipping a macOS runtime archive after
# v0.3.42 (the newest release with a vosk-osx-*.zip asset - v0.3.45, used
# on Windows, and the current latest release both only publish Linux/
# Windows/Android archives), so that is the version fetched here. Its
# libvosk.dylib is a universal x86_64+arm64 binary linking only system
# frameworks, so it runs unmodified on both Intel and Apple Silicon Macs
# despite predating this project's Windows runtime version.
#
#**************************************************************************

set -euo pipefail

FORCE_DOWNLOAD=false
SKIP_ENVIRONMENT_INSTRUCTIONS=false
OUTPUT_DIRECTORY=""

usage() {
    cat <<EOF
usage: $(basename "$0") [options]

Options:
  --output-dir <path>            Where to place the assets
                                 (default: <repo>/build/voice-assets)
  --force                        Re-download even if files already exist
  --skip-environment-instructions
                                 Don't print the dev-launch env var block
  -h, --help                     Show this help
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
        --output-dir) OUTPUT_DIRECTORY="$2"; shift 2 ;;
        --force) FORCE_DOWNLOAD=true; shift ;;
        --skip-environment-instructions) SKIP_ENVIRONMENT_INSTRUCTIONS=true; shift ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown argument: $1" >&2; usage >&2; exit 1 ;;
    esac
done

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [ -z "$OUTPUT_DIRECTORY" ]; then
    OUTPUT_DIRECTORY="$SOURCE_DIR/build/voice-assets"
fi
mkdir -p "$OUTPUT_DIRECTORY"
ASSET_ROOT="$(cd "$OUTPUT_DIRECTORY" && pwd)"

RUNTIME_VERSION="0.3.42"
RUNTIME_ARCHIVE="$ASSET_ROOT/vosk-osx-$RUNTIME_VERSION.zip"
MODEL_ARCHIVE="$ASSET_ROOT/vosk-model-small-en-us-0.15.zip"
SAMPLE_AUDIO="$ASSET_ROOT/vosk-test.wav"
LICENSE_FILE="$ASSET_ROOT/VOSK-COPYING"
RUNTIME_DIRECTORY="$ASSET_ROOT/vosk-osx-$RUNTIME_VERSION"
MODEL_DIRECTORY="$ASSET_ROOT/vosk-model-small-en-us-0.15"

get_development_asset() {
    local uri="$1"
    local destination="$2"
    if [ -e "$destination" ] && [ "$FORCE_DOWNLOAD" != true ]; then
        return
    fi
    local partial="$destination.partial"
    curl -sL --fail -o "$partial" "$uri"
    mv -f "$partial" "$destination"
}

get_development_asset \
    "https://github.com/alphacep/vosk-api/releases/download/v$RUNTIME_VERSION/vosk-osx-$RUNTIME_VERSION.zip" \
    "$RUNTIME_ARCHIVE"
get_development_asset \
    "https://alphacephei.com/vosk/models/vosk-model-small-en-us-0.15.zip" \
    "$MODEL_ARCHIVE"
get_development_asset \
    "https://raw.githubusercontent.com/alphacep/vosk-api/master/python/example/test.wav" \
    "$SAMPLE_AUDIO"
get_development_asset \
    "https://raw.githubusercontent.com/alphacep/vosk-api/master/COPYING" \
    "$LICENSE_FILE"

if [ ! -d "$RUNTIME_DIRECTORY" ]; then
    unzip -o -q "$RUNTIME_ARCHIVE" -d "$ASSET_ROOT"
fi
if [ ! -d "$MODEL_DIRECTORY" ]; then
    unzip -o -q "$MODEL_ARCHIVE" -d "$ASSET_ROOT"
fi

LIBRARY_PATH="$RUNTIME_DIRECTORY/libvosk.dylib"
if [ ! -f "$LIBRARY_PATH" ]; then
    echo "The Vosk archive did not contain the expected runtime: $LIBRARY_PATH" >&2
    exit 1
fi
if [ ! -d "$MODEL_DIRECTORY/conf" ]; then
    echo "The Vosk archive did not contain a valid model: $MODEL_DIRECTORY" >&2
    exit 1
fi

echo "Vosk development assets are ready."
echo "Runtime directory: $RUNTIME_DIRECTORY"
echo "Library: $LIBRARY_PATH"
echo "Model: $MODEL_DIRECTORY"
echo "Recorded sample: $SAMPLE_AUDIO"
echo "License: $LICENSE_FILE"
if [ "$SKIP_ENVIRONMENT_INSTRUCTIONS" != true ]; then
    echo ""
    echo "For a development launch in this shell session:"
    echo "  export QPROMPT_VOSK_LIBRARY=\"$LIBRARY_PATH\""
    echo "  export QPROMPT_VOSK_MODEL=\"$MODEL_DIRECTORY\""
fi
