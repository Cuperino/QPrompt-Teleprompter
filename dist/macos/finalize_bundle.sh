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

# Runs after Qt's deploy script (macdeployqt) at install time.
#
# 1. Kirigami resolves its QML components (ApplicationWindow.qml, ...) relative
#    to the directory its QML plugin was loaded from. macdeployqt moves that
#    plugin into Contents/PlugIns, where non-code files are not allowed, so the
#    plugin is placed next to its qmldir in Contents/Resources/qml/org/kde/kirigami
#    together with Kirigami's QML files.
# 2. Absolute rpaths pointing at the build machine's Qt installation are removed.
# 3. Every Mach-O binary, framework, and finally the bundle are re-signed with a
#    single Developer ID, because macdeployqt can leave some Qt frameworks
#    (e.g. QtConcurrent, only pulled in by Kirigami) with The Qt Company's
#    signature, which dyld rejects under the hardened runtime.

set -euo pipefail

APP="$1"
IDENTITY="$2"
KIRIGAMI_QML_SRC="$3"   # Build tree's org/kde/kirigami QML module directory

if [ ! -d "$APP" ]; then
    echo "finalize_bundle: $APP not found" >&2
    exit 1
fi

CONTENTS="$APP/Contents"
KIRIGAMI_QML_DST="$CONTENTS/Resources/qml/org/kde/kirigami"
PLUGIN_NAME="libKirigamiplugin.dylib"

is_macho() {
    file -b "$1" | grep -q "Mach-O"
}

# 1. Kirigami QML files and plugin
echo "finalize_bundle: Installing Kirigami QML files into $KIRIGAMI_QML_DST"
mkdir -p "$KIRIGAMI_QML_DST"
rsync -a \
    --exclude '*.dylib' --exclude '*.qrc' --exclude '*.cpp' --exclude 'qmldir' \
    "$KIRIGAMI_QML_SRC/" "$KIRIGAMI_QML_DST/"
# Only add qmldir files that the deploy step didn't already install
rsync -a --ignore-existing --include '*/' --include 'qmldir' --exclude '*' \
    "$KIRIGAMI_QML_SRC/" "$KIRIGAMI_QML_DST/"

if [ -f "$CONTENTS/PlugIns/$PLUGIN_NAME" ]; then
    mv -f "$CONTENTS/PlugIns/$PLUGIN_NAME" "$KIRIGAMI_QML_DST/$PLUGIN_NAME"
fi
PLUGIN="$KIRIGAMI_QML_DST/$PLUGIN_NAME"
if [ ! -f "$PLUGIN" ]; then
    echo "finalize_bundle: $PLUGIN_NAME was not deployed" >&2
    exit 1
fi
# The plugin no longer sits in a sibling of Frameworks, so @loader_path/.. is wrong
for dep in $(otool -L "$PLUGIN" | tail -n +2 | awk '{print $1}' | grep '^@loader_path/\.\./' || true); do
    install_name_tool -change "$dep" "@executable_path/../${dep#@loader_path/../}" "$PLUGIN" 2>/dev/null
done
for rpath in $(otool -l "$PLUGIN" | awk '/cmd LC_RPATH/{getline; getline; print $2}' | grep '^@loader_path/\.\./' || true); do
    install_name_tool -rpath "$rpath" "@executable_path/../${rpath#@loader_path/../}" "$PLUGIN" 2>/dev/null
done

# Collect Mach-O files that aren't a framework's own binary
MACHOS=()
while IFS= read -r -d '' f; do
    is_macho "$f" && MACHOS+=("$f")
done < <(find "$CONTENTS" -type f -not -path "*.framework/*" -print0)

# 2. Strip absolute rpaths (e.g. ~/Qt/<version>/macos/lib)
for f in "${MACHOS[@]}"; do
    for rpath in $(otool -l "$f" | awk '/cmd LC_RPATH/{getline; getline; print $2}' | grep '^/' || true); do
        echo "finalize_bundle: Removing rpath $rpath from ${f#$APP/}"
        install_name_tool -delete_rpath "$rpath" "$f" 2>/dev/null
    done
done

# 3. Sign inside-out
SIGN=(codesign --force --options runtime --timestamp --sign "$IDENTITY")
MAIN_EXECUTABLE="$CONTENTS/MacOS/$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$CONTENTS/Info.plist")"
for f in "${MACHOS[@]}"; do
    [ "$f" == "$MAIN_EXECUTABLE" ] && continue
    "${SIGN[@]}" "$f"
done
while IFS= read -r -d '' fw; do
    "${SIGN[@]}" "$fw"
done < <(find "$CONTENTS/Frameworks" -maxdepth 1 -name "*.framework" -print0)
"${SIGN[@]}" "$APP"

codesign --verify --deep --strict --verbose=1 "$APP"

# Fail the build if anything is still signed by a different team
EXPECTED_TEAM=$(codesign -dv "$APP" 2>&1 | sed -n 's/^TeamIdentifier=//p')
while IFS= read -r -d '' f; do
    is_macho "$f" || continue
    team=$(codesign -dv "$f" 2>&1 | sed -n 's/^TeamIdentifier=//p')
    if [ "$team" != "$EXPECTED_TEAM" ]; then
        echo "finalize_bundle: ${f#$APP/} is signed by team '$team', expected '$EXPECTED_TEAM'" >&2
        exit 1
    fi
done < <(find "$CONTENTS" -type f -print0)
echo "finalize_bundle: All binaries signed by team $EXPECTED_TEAM"
