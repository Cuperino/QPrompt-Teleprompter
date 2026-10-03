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
# usage: fetch-tools.sh [x86_64 | aarch64]
#
# Downloads the three AppImage packaging tools for one architecture into
# dist/appimage/tools and checks them against the digests pinned in
# dist/appimage/tools.sha256. Already present, matching files are kept.
#
# build-appimage.sh calls this, so a local build needs no separate step.
#
#**************************************************************************

set -eo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="$HERE/tools"
SUMS_FILE="$HERE/tools.sha256"

ARCH="${1:-$(uname -m)}"
case "$ARCH" in
    x86_64|aarch64) ;;
    *)
        echo "fetch-tools.sh: unsupported architecture '$ARCH' (expected x86_64 or aarch64)" >&2
        exit 1
        ;;
esac

LINUXDEPLOY_URL="https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous"
PLUGIN_QT_URL="https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous"
APPIMAGETOOL_URL="https://github.com/AppImage/appimagetool/releases/download/continuous"

declare -A SOURCES=(
    ["linuxdeploy-$ARCH.AppImage"]="$LINUXDEPLOY_URL/linuxdeploy-$ARCH.AppImage"
    ["linuxdeploy-plugin-qt-$ARCH.AppImage"]="$PLUGIN_QT_URL/linuxdeploy-plugin-qt-$ARCH.AppImage"
    ["appimagetool-$ARCH.AppImage"]="$APPIMAGETOOL_URL/appimagetool-$ARCH.AppImage"
)

mkdir -p "$TOOLS_DIR"

for name in "${!SOURCES[@]}"; do
    expected="$(awk -v n="$name" '$2 == n { print $1 }' "$SUMS_FILE")"
    if [ -z "$expected" ]; then
        echo "fetch-tools.sh: no digest for $name in $SUMS_FILE" >&2
        exit 1
    fi
    target="$TOOLS_DIR/$name"
    if [ -f "$target" ] && [ "$(sha256sum "$target" | cut -d' ' -f1)" == "$expected" ]; then
        echo "fetch-tools.sh: $name is up to date"
        chmod +x "$target"
        continue
    fi
    echo "fetch-tools.sh: downloading $name"
    curl -fL --retry 3 --progress-bar -o "$target.part" "${SOURCES[$name]}"
    actual="$(sha256sum "$target.part" | cut -d' ' -f1)"
    if [ "$actual" != "$expected" ]; then
        rm -f "$target.part"
        cat >&2 <<EOF
fetch-tools.sh: digest mismatch for $name
  expected $expected
  got      $actual
These tools only ship continuous builds, so upstream has published a new one.
Review the change, then update $SUMS_FILE.
EOF
        exit 1
    fi
    mv "$target.part" "$target"
    chmod +x "$target"
done

echo "fetch-tools.sh: tools for $ARCH ready in $TOOLS_DIR"
