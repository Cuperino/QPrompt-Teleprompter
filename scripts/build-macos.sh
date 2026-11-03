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
# Builds a double-clickable QPrompt.app on macOS.
#
# Qt MUST come from the official installer (aqtinstall or the Qt Online
# Installer), not Homebrew: Homebrew splits Qt across many separate Cellar
# formulas linked together with symlinks and ships some of them
# pre-signed, which the project's Qt deploy step (qt_generate_deploy_qml_
# app_script) cannot reassemble into a working bundle - dependencies end
# up missing, broken, or hardcoded to Homebrew's absolute paths, and
# mismatched code signatures make the result refuse to launch under SIP.
# The official installer ships one self-contained tree, which is what
# that deploy step is actually designed against, and includes the real
# macdeployqt.
#
# Install Qt once with:
#   pip3 install aqtinstall
#   python3 -m aqt install-qt mac desktop 6.11.1 clang_64 -O ~/Qt \
#       -m qtmultimedia qtwebsockets qtshadertools
#
# (Qt 6.8.x also works but references the AGL framework that recent Xcode
# SDKs no longer ship; 6.9+ dropped that reference.)
#
#**************************************************************************

set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$SOURCE_DIR/build"
INSTALL_DIR=""
QT_PREFIX=""
SIGNING_IDENTITY="-"
JOBS="$(sysctl -n hw.ncpu 2>/dev/null || echo 4)"
CLEAN=false
RUN_AFTER_BUILD=false
MAKE_PACKAGE=false

usage() {
    cat <<EOF
usage: $(basename "$0") [options]

Options:
  --qt-prefix <path>     Qt 6 install prefix, e.g. ~/Qt/6.11.1/macos
                         (default: newest ~/Qt/*/macos found)
  --build-dir <path>     CMake build directory (default: build)
  --install-dir <path>   Where to install the .app bundle
                         (default: <build-dir>/install)
  --identity <id>        Code signing identity (default: "-", ad hoc).
                         Pass a "Developer ID Application: ..." identity
                         to produce a notarizable build.
  --jobs <n>             Parallel build jobs (default: number of CPUs)
  --clean                Remove the build directory first
  --run                  Launch QPrompt.app once the build succeeds
  --package              Wrap the signed .app into a redistributable .dmg
  -h, --help             Show this help
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
        --qt-prefix) QT_PREFIX="$2"; shift 2 ;;
        --build-dir) BUILD_DIR="$2"; shift 2 ;;
        --install-dir) INSTALL_DIR="$2"; shift 2 ;;
        --identity) SIGNING_IDENTITY="$2"; shift 2 ;;
        --jobs) JOBS="$2"; shift 2 ;;
        --clean) CLEAN=true; shift ;;
        --run) RUN_AFTER_BUILD=true; shift ;;
        --package) MAKE_PACKAGE=true; shift ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown argument: $1" >&2; usage >&2; exit 1 ;;
    esac
done

if [ "$(uname)" != "Darwin" ]; then
    echo "This script only builds on macOS." >&2
    exit 1
fi

if [ -z "$QT_PREFIX" ]; then
    QT_PREFIX="$(find "$HOME/Qt" -mindepth 2 -maxdepth 2 -type d -name macos 2>/dev/null | sort -V | tail -1 || true)"
fi
if [ -z "$QT_PREFIX" ] || [ ! -d "$QT_PREFIX" ]; then
    echo "Qt 6 (official installer build) was not found under ~/Qt." >&2
    echo "Install it with:" >&2
    echo "  pip3 install aqtinstall" >&2
    echo "  python3 -m aqt install-qt mac desktop 6.11.1 clang_64 -O ~/Qt \\" >&2
    echo "      -m qtmultimedia qtwebsockets qtshadertools" >&2
    echo "Then pass --qt-prefix ~/Qt/6.11.1/macos, or let this script find it." >&2
    exit 1
fi
if ! command -v brew >/dev/null 2>&1 || ! brew list --versions extra-cmake-modules >/dev/null 2>&1; then
    echo "extra-cmake-modules was not found. Install it with:" >&2
    echo "  brew install extra-cmake-modules" >&2
    exit 1
fi

if [ -z "$INSTALL_DIR" ]; then
    INSTALL_DIR="$BUILD_DIR/install"
fi

if [ "$CLEAN" = true ]; then
    echo "Removing $BUILD_DIR"
    rm -rf "$BUILD_DIR"
fi

GENERATOR_ARGS=()
if command -v ninja >/dev/null 2>&1; then
    GENERATOR_ARGS=(-G Ninja)
fi

echo "Using Qt at $QT_PREFIX"
echo "Updating submodules..."
git -C "$SOURCE_DIR" submodule update --init --recursive

VOSK_ASSET_DIR="$BUILD_DIR/voice-assets"
echo "Fetching Voice Follow (Vosk) assets..."
"$SOURCE_DIR/scripts/setup-vosk-dev.sh" --output-dir "$VOSK_ASSET_DIR" --skip-environment-instructions

echo "Configuring ($BUILD_DIR)..."
cmake -S "$SOURCE_DIR" -B "$BUILD_DIR" "${GENERATOR_ARGS[@]}" \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_PREFIX_PATH="$QT_PREFIX" \
    -DQPROMPT_VOSK_ASSET_DIR="$VOSK_ASSET_DIR"

echo "Building..."
cmake --build "$BUILD_DIR" --parallel "$JOBS"

echo "Installing to $INSTALL_DIR..."
rm -rf "$INSTALL_DIR"
cmake --install "$BUILD_DIR" --prefix "$INSTALL_DIR"

APP_BUNDLE="$INSTALL_DIR/QPrompt.app"
if [ ! -d "$APP_BUNDLE" ]; then
    echo "Install completed but $APP_BUNDLE was not found." >&2
    exit 1
fi

# Kirigami/KCoreAddons are built from source (not part of the Qt
# distribution itself), so unlike every actual Qt library, the deploy
# tool copies them into Contents/Frameworks without touching their
# embedded rpath list - which still points at $QT_PREFIX/lib from the
# build. Since that's a real path on this machine, dyld resolves their
# @rpath/QtCore.framework etc. dependencies against Qt's own copy there
# instead of the one bundled alongside them, loading Qt twice in one
# process and aborting on the resulting duplicate QML module
# registration. Point them at their sibling frameworks instead.
echo "Fixing up Kirigami/KCoreAddons rpaths..."
for lib in "$APP_BUNDLE"/Contents/Frameworks/libKirigami*.dylib "$APP_BUNDLE"/Contents/Frameworks/libKF6CoreAddons.6.dylib; do
    [ -f "$lib" ] || continue
    while IFS= read -r rpath; do
        [ -z "$rpath" ] && continue
        install_name_tool -delete_rpath "$rpath" "$lib" 2>/dev/null || true
    done < <(otool -l "$lib" | grep -A2 LC_RPATH | grep "path " | sed 's/^ *path //;s/ (offset.*//' | grep -v '^@')
    if ! otool -l "$lib" | grep -A2 LC_RPATH | grep -q "@loader_path$"; then
        install_name_tool -add_rpath @loader_path "$lib" 2>/dev/null || true
    fi
done

# The deploy step assembles a correct, self-contained bundle from an
# official Qt install, but doesn't sign it with anything Apple Silicon
# accepts. Ad hoc sign the whole bundle in one pass so it can launch.
echo "Signing $APP_BUNDLE (identity: $SIGNING_IDENTITY)..."
codesign --force --deep --sign "$SIGNING_IDENTITY" "$APP_BUNDLE"
codesign -v "$APP_BUNDLE"

echo ""
echo "Built app: $APP_BUNDLE"

if [ "$MAKE_PACKAGE" = true ]; then
    # CMakeLists.txt already configures CPack's DragNDrop generator for
    # macOS, but `cpack` stages its own fresh `cmake --install` internally
    # and would hit the exact rpath/signing issues fixed above all over
    # again, with no hook to run the fix-up in between. Wrap the bundle
    # we already built, fixed, and signed into a .dmg directly instead.
    PROJECT_VERSION="$(grep -m1 'set(RELEASE_SERVICE_VERSION_MAJOR' "$SOURCE_DIR/CMakeLists.txt" | grep -o '"[0-9]*"' | tr -d '"')"
    PROJECT_VERSION="$PROJECT_VERSION.$(grep -m1 'set(RELEASE_SERVICE_VERSION_MINOR' "$SOURCE_DIR/CMakeLists.txt" | grep -o '"[0-9]*"' | tr -d '"')"
    PROJECT_VERSION="$PROJECT_VERSION.$(grep -m1 'set(RELEASE_SERVICE_VERSION_MICRO' "$SOURCE_DIR/CMakeLists.txt" | grep -o '"[0-9]*"' | tr -d '"')"
    DMG_STAGING="$BUILD_DIR/dmg-staging"
    DMG_PATH="$BUILD_DIR/QPrompt-$PROJECT_VERSION.dmg"

    echo "Packaging $DMG_PATH..."
    rm -rf "$DMG_STAGING" "$DMG_PATH"
    mkdir -p "$DMG_STAGING"
    cp -R "$APP_BUNDLE" "$DMG_STAGING/"
    ln -s /Applications "$DMG_STAGING/Applications"
    hdiutil create -volname "QPrompt" -srcfolder "$DMG_STAGING" -ov -format UDZO "$DMG_PATH"
    rm -rf "$DMG_STAGING"

    echo ""
    echo "Packaged: $DMG_PATH"
fi

if [ "$RUN_AFTER_BUILD" = true ]; then
    echo "Launching QPrompt..."
    open "$APP_BUNDLE"
fi
