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
# usage: dist/appimage/build-appimage.sh
#
# Builds QPrompt with setup.sh and packages the result as
# QPrompt-<version>-<arch>-Linux.AppImage, with embedded update information,
# a .zsync delta file and, when a signing key is named, a GPG signature.
#
# Run it from the top of a QPrompt checkout. Build on Debian 13: that is the
# oldest system the AppImages are supported on, and the glibc check below
# enforces it.
#
# Environment:
#   QPROMPT_SIGN_KEY        GPG key ID to sign the AppImage with. Unset means
#                           an unsigned build.
#   APPIMAGETOOL_SIGN_PASSPHRASE
#                           Passphrase for that key, read by appimagetool.
#   QPROMPT_QT_DIR          Qt prefix. Defaults to ~/Qt/<ver>/<compiler>.
#   QPROMPT_GLIBC_FLOOR     Highest glibc version the build may require
#                           (default 2.41, which is Debian 13's).
#   QPROMPT_SKIP_APT        Passed through to setup.sh.
#   QPROMPT_SKIP_BUILD      Skip setup.sh and package the existing build tree.
#                           For iterating on the packaging steps alone.
#
#**************************************************************************

set -eo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$(cd "$HERE/../.." && pwd)"
cd "$SOURCE_DIR"

QT_VER="$(grep -m1 '^DEFAULT_QT_VER=' setup.sh | cut -d= -f2)"
GLIBC_FLOOR="${QPROMPT_GLIBC_FLOOR:-2.41}"

ARCH="$(uname -m)"
case "$ARCH" in
    x86_64)
        COMPILER="gcc_64"
        LIBARCH="x86_64-linux-gnu"
        ;;
    aarch64)
        COMPILER="gcc_arm64"
        LIBARCH="aarch64-linux-gnu"
        ;;
    *)
        echo "build-appimage.sh: unsupported architecture '$ARCH'" >&2
        exit 1
        ;;
esac

QT="${QPROMPT_QT_DIR:-$HOME/Qt/$QT_VER/$COMPILER}"
if [ ! -d "$QT" ]; then
    echo "build-appimage.sh: Qt prefix not found at $QT" >&2
    echo "Install Qt $QT_VER for $COMPILER, or point QPROMPT_QT_DIR at it." >&2
    exit 1
fi

# Version, read the same way setup.sh reads it. A build that is not sitting on a
# release tag carries the short commit hash, so a development build can never be
# mistaken for a release.
VER_MAJOR="$(grep RELEASE_SERVICE_VERSION_MAJOR CMakeLists.txt | tr -d -c 0-9)"
VER_MINOR="$(grep RELEASE_SERVICE_VERSION_MINOR CMakeLists.txt | tr -d -c 0-9)"
VER_MICRO="$(grep RELEASE_SERVICE_VERSION_MICRO CMakeLists.txt | tr -d -c 0-9)"
VER="$VER_MAJOR.$VER_MINOR.$VER_MICRO"
if ! git describe --exact-match --tags HEAD >/dev/null 2>&1; then
    VER="$VER-$(git log -1 --format=%h)"
fi
APPIMAGE="QPrompt-$VER-$ARCH-Linux.AppImage"
# Both outputs land in the build directory, next to the DEB that CPack writes
# there, rather than in the top of the checkout.
APPIMAGE_PATH="build/$APPIMAGE"

echo "=== QPrompt $VER for $ARCH, Qt from $QT"

#--------------------------------------------------------------------------
# 1. Tools this script needs
#--------------------------------------------------------------------------
# Packaging and the checks need more than the build does, and the libraries the
# bundle picks up from the host have to be installed for linuxdeploy to find
# them. These are installed rather than reported, like setup.sh does for the
# build dependencies. Set QPROMPT_SKIP_APT=1 to leave it alone, which is also
# what happens on a distribution without apt; the check below still names
# whatever is missing.
QPROMPT_APT_PACKAGES=(
    curl ca-certificates file binutils
    desktop-file-utils appstream
    libxcb-cursor0 libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-render-util0
    libwayland-client0 libwayland-cursor0 libwayland-egl1
    libdbus-1-3 libfontconfig1
)
if [ -n "$QPROMPT_SIGN_KEY" ]; then
    QPROMPT_APT_PACKAGES+=(gnupg)
fi
if [ "$QPROMPT_SKIP_APT" != "1" ] && command -v apt-get >/dev/null 2>&1; then
    APT_SUDO=""
    if [ "$(id -u)" != "0" ]; then
        APT_SUDO="sudo"
    fi
    echo "=== Installing packaging dependencies"
    $APT_SUDO env DEBIAN_FRONTEND=noninteractive apt-get update
    $APT_SUDO env DEBIAN_FRONTEND=noninteractive apt-get install -y \
        --no-install-recommends "${QPROMPT_APT_PACKAGES[@]}"
fi

# Verified even after installing: apt is absent on other distributions, the
# install may have been skipped, and a tool missing here would otherwise only
# surface once the build has already run.
QPROMPT_MISSING_PACKAGES=()
qprompt_need() {  # qprompt_need <command> <Debian package>
    command -v "$1" >/dev/null 2>&1 || QPROMPT_MISSING_PACKAGES+=("$2")
}
qprompt_need curl curl
qprompt_need objdump binutils
qprompt_need objcopy binutils
qprompt_need strings binutils
qprompt_need desktop-file-validate desktop-file-utils
qprompt_need appstreamcli appstream
if [ -n "$QPROMPT_SIGN_KEY" ]; then
    qprompt_need gpg gnupg
fi
if [ "${#QPROMPT_MISSING_PACKAGES[@]}" -gt 0 ]; then
    readarray -t QPROMPT_MISSING_PACKAGES < \
        <(printf '%s\n' "${QPROMPT_MISSING_PACKAGES[@]}" | sort -u)
    cat >&2 <<EOF
build-appimage.sh: these tools are missing and the build needs them:
  ${QPROMPT_MISSING_PACKAGES[*]}
On Debian 13 install them with:
  sudo apt-get install ${QPROMPT_MISSING_PACKAGES[*]}
EOF
    exit 1
fi

#--------------------------------------------------------------------------
# 2. Packaging tools
#--------------------------------------------------------------------------
"$HERE/fetch-tools.sh" "$ARCH"
TOOLS="$HERE/tools"
LINUXDEPLOY="$TOOLS/linuxdeploy-$ARCH.AppImage"
APPIMAGETOOL="$TOOLS/appimagetool-$ARCH.AppImage"
# linuxdeploy finds its plugins by name, on PATH and next to its own binary.
export PATH="$TOOLS:$PATH"

#--------------------------------------------------------------------------
# 3. Build
#--------------------------------------------------------------------------
# The dictionaries are bundled for the AppImage only: there is no distribution
# inside the image to provide them. CPack is skipped; this script packages the
# staged tree itself.
if [ "$QPROMPT_SKIP_BUILD" == "1" ]; then
    echo "=== QPROMPT_SKIP_BUILD=1, packaging the existing build tree"
    if [ ! -d build ]; then
        echo "build-appimage.sh: no build/ to package." >&2
        exit 1
    fi
else
    QPROMPT_CMAKE_ARGS="-DQPROMPT_BUNDLE_HUNSPELL_DICTIONARIES=ON" \
    QPROMPT_SKIP_CPACK=1 \
        ./setup.sh Release "$QT" CLEAR_ALL
fi

CMAKE=~/Qt/Tools/CMake/bin/cmake
if [ ! -x "$CMAKE" ]; then
    CMAKE=cmake
fi

#--------------------------------------------------------------------------
# 4. Stage QPrompt alone
#--------------------------------------------------------------------------
# setup.sh stages the frameworks into ./install as well, headers and CMake
# config files included. Installing QPrompt's own build tree into a fresh AppDir
# keeps all of that out; linuxdeploy brings in the libraries it actually needs.
echo "=== Staging AppDir"
rm -rf AppDir
DESTDIR="$PWD/AppDir" "$CMAKE" --install build

#--------------------------------------------------------------------------
# 5. Deploy Qt, the frameworks and their dependencies
#--------------------------------------------------------------------------
# setup.sh copies every framework it builds into the Qt prefix, so that prefix
# is the single place linuxdeploy resolves libraries and QML modules from.
export QMAKE="$QT/bin/qmake"
export LD_LIBRARY_PATH="$QT/lib:$QT/lib/$LIBARCH${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export QML_SOURCES_PATHS="$PWD/src"
export QML_MODULES_PATHS="$QT/lib/$LIBARCH/qml"
# waylandcompositor is what pulls in the Wayland shell, decoration and graphics
# integration plugins; without it the wayland platform plugins have nothing to
# load. svg is named explicitly because Qt's SVG icon support is loaded at
# runtime rather than linked.
export EXTRA_QT_MODULES="svg;waylandcompositor"

# The Wayland platform plugins are found rather than named. Qt 6.8 ships them as
# libqwayland-egl.so plus libqwayland-generic.so; Qt 6.10 and newer merged the
# two into a single libqwayland.so. linuxdeploy-plugin-qt fails outright on a
# name that is not there, so ask the Qt in use which ones it has instead of
# hardcoding one layout. Qt's Wayland component has to be installed either way.
WAYLAND_PLUGINS=""
for plugin in "$QT/plugins/platforms"/libqwayland*.so; do
    [ -e "$plugin" ] || continue
    WAYLAND_PLUGINS="${WAYLAND_PLUGINS:+$WAYLAND_PLUGINS;}$(basename "$plugin")"
done
if [ -z "$WAYLAND_PLUGINS" ]; then
    cat >&2 <<EOF
build-appimage.sh: no Wayland platform plugin in $QT/plugins/platforms
QPrompt is supported on Wayland sessions, so the bundle needs one. Install Qt's
Wayland component (qt.qt6.<ver>.addons.qtwayland in the online installer) into
this prefix and run again.
EOF
    exit 1
fi
echo "=== Wayland platform plugins: $WAYLAND_PLUGINS"
# libqoffscreen.so is deployed too. linuxdeploy-plugin-qt leaves it out, but
# every automated check below runs QT_QPA_PLATFORM=offscreen, and without the
# plugin the bundle cannot start headless at all -- it also lets --version work
# over SSH on a machine with no display.
export EXTRA_PLATFORM_PLUGINS="$WAYLAND_PLUGINS;libqoffscreen.so"
# Native file dialogs come from the xdg-desktop-portal and gtk3 platform themes.
export DEPLOY_PLATFORM_THEMES=1

# qmlimportscanner does not see Kirigami's internal imports (notably
# org.kde.kirigami.private.polyfill), so the whole tree is copied in. It has to
# happen before linuxdeploy runs: a plugin copied in afterwards keeps the rpath
# it had in the Qt prefix, finds nothing at that path inside the bundle and
# loads the host's Kirigami instead, which is built against another Qt.
# --deploy-deps-only hands each one to linuxdeploy so its rpath is rewritten and
# its dependencies are deployed, without copying the file again.
KIRIGAMI_SRC="$QT/lib/$LIBARCH/qml/org/kde/kirigami"
DEPLOY_DEPS_ONLY=()
if [ -d "$KIRIGAMI_SRC" ]; then
    echo "=== Completing Kirigami QML modules"
    mkdir -p AppDir/usr/qml/org/kde
    cp -r "$KIRIGAMI_SRC" AppDir/usr/qml/org/kde/
    while IFS= read -r plugin; do
        DEPLOY_DEPS_ONLY+=(--deploy-deps-only="$plugin")
    done < <(find AppDir/usr/qml/org/kde/kirigami -name '*.so')
fi

echo "=== Deploying with linuxdeploy"
"$LINUXDEPLOY" --appdir AppDir \
    --executable AppDir/usr/bin/qprompt \
    --desktop-file AppDir/usr/share/applications/com.cuperino.qprompt.desktop \
    --icon-file AppDir/usr/share/icons/hicolor/256x256/apps/com.cuperino.qprompt.png \
    "${DEPLOY_DEPS_ONLY[@]}" \
    --plugin qt

#--------------------------------------------------------------------------
# 6. Prune development files
#--------------------------------------------------------------------------
# usr/share/doc/qprompt stays: it carries the GPL text and the dictionary
# licences.
echo "=== Pruning development files"
rm -rf AppDir/usr/include
rm -rf AppDir/usr/lib/*/cmake AppDir/usr/lib/cmake
rm -rf AppDir/usr/lib/*/pkgconfig AppDir/usr/lib/pkgconfig

#--------------------------------------------------------------------------
# 7. Checks on the AppDir
#--------------------------------------------------------------------------
# Every ELF in the bundle has to resolve its libraries inside the bundle. An
# absolute rpath entry means the file was copied in without being processed by
# linuxdeploy, and at runtime it silently loads the host's library instead of the
# bundled one -- which fails only on a machine whose copy was built against a
# different Qt.
echo "=== Checking rpaths stay inside the bundle"
leaked=""
while IFS= read -r elf; do
    rpath="$(objdump -p "$elf" 2>/dev/null | awk '/RUNPATH|RPATH/ && !seen { print $2; seen = 1 }' || true)"
    [ -n "$rpath" ] || continue
    if printf '%s' "$rpath" | tr ':' '\n' | grep -q '^/'; then
        leaked="$leaked  $elf -> $rpath"$'\n'
    fi
done < <(find AppDir -type f \( -name '*.so*' -o -path '*/bin/*' \))
if [ -n "$leaked" ]; then
    echo "build-appimage.sh: these files point outside the bundle:" >&2
    printf '%s' "$leaked" >&2
    exit 1
fi
echo "  all rpaths are bundle relative"

echo "=== Checking bundled dictionaries"
missing=0
for aff in AppDir/usr/share/hunspell/*.aff; do
    [ -e "$aff" ] || break
    code="$(basename "$aff" .aff)"
    if [ ! -s "AppDir/usr/share/hunspell/$code.dic" ]; then
        echo "  missing or empty dictionary: $code.dic" >&2
        missing=1
    fi
    license_dir="AppDir/usr/share/doc/qprompt/hunspell/$code"
    if [ -z "$(ls -A "$license_dir" 2>/dev/null)" ]; then
        echo "  missing licences for $code (expected files in $license_dir)" >&2
        missing=1
    fi
done
pairs="$(find AppDir/usr/share/hunspell -name '*.aff' 2>/dev/null | wc -l || true)"
if [ "$pairs" != "15" ]; then
    echo "  expected 15 dictionaries in AppDir/usr/share/hunspell, found $pairs" >&2
    missing=1
fi
if [ "$missing" != "0" ]; then
    echo "build-appimage.sh: the bundled dictionaries are incomplete" >&2
    exit 1
fi
echo "  15 dictionaries with licences"

# QNetworkAccessManager loads documents from URLs, and the TLS backend is a
# plugin loaded at runtime: without it every https:// document fails to open.
echo "=== Checking the TLS backend"
if [ ! -e AppDir/usr/plugins/tls/libqopensslbackend.so ]; then
    echo "build-appimage.sh: AppDir/usr/plugins/tls/libqopensslbackend.so is missing," >&2
    echo "so opening an https:// document would fail. Qt's TLS plugin has to be deployed." >&2
    exit 1
fi
echo "  libqopensslbackend.so present"

echo "=== Validating desktop and AppStream metadata"
desktop-file-validate AppDir/usr/share/applications/com.cuperino.qprompt.desktop
# --no-net on purpose: the metadata has to be valid whether or not the project's
# web servers answer right now, and a packaging run must not depend on them.
appstreamcli validate --no-net AppDir/usr/share/metainfo/com.cuperino.qprompt.appdata.xml

echo "=== Checking the glibc floor ($GLIBC_FLOOR)"
# objdump exits non-zero on anything that is not an ELF file, which would take
# find down with it and, under pipefail, abort this script without a word. Both
# stages are allowed to fail; an empty result is caught right below.
glibc_symbols="$(find AppDir -type f \( -name '*.so*' -o -path '*/bin/*' \) \
    -exec objdump -T {} + 2>/dev/null || true)"
highest="$(printf '%s\n' "$glibc_symbols" | grep -o 'GLIBC_[0-9.]*' | sort -Vu | tail -1 || true)"
highest="${highest#GLIBC_}"
if [ -z "$highest" ]; then
    echo "build-appimage.sh: could not read any GLIBC_ version from the AppDir" >&2
    exit 1
fi
if [ "$(printf '%s\n%s\n' "$GLIBC_FLOOR" "$highest" | sort -V | tail -1)" != "$GLIBC_FLOOR" ]; then
    echo "build-appimage.sh: the bundle needs glibc $highest, above the $GLIBC_FLOOR floor." >&2
    echo "Build on Debian 13, or raise QPROMPT_GLIBC_FLOOR deliberately and say so in the release notes." >&2
    exit 1
fi
echo "  highest required: glibc $highest"

#--------------------------------------------------------------------------
# 8. Package
#--------------------------------------------------------------------------
# The update information lets AppImageUpdate, Gear Lever and similar tools fetch
# only the blocks that changed, against the newest published release.
UPDATE_INFO="gh-releases-zsync|Cuperino|QPrompt-Teleprompter|latest|QPrompt-*-$ARCH-Linux.AppImage.zsync"
SIGN_ARGS=()
if [ -n "$QPROMPT_SIGN_KEY" ]; then
    SIGN_ARGS=(--sign --sign-key "$QPROMPT_SIGN_KEY")
    echo "=== Packaging $APPIMAGE_PATH, signed with $QPROMPT_SIGN_KEY"
else
    echo "=== Packaging $APPIMAGE_PATH (unsigned: QPROMPT_SIGN_KEY is not set)"
fi

# -n skips appimagetool's own AppStream check. It runs appstreamcli with network
# access and treats a warning as fatal, so a URL in the metadata being briefly
# unreachable fails the whole build -- a packaging run should not depend on a web
# server answering. The equivalent check ran offline in step 7.
rm -f "$APPIMAGE_PATH" "$APPIMAGE_PATH.zsync"
# Run from the build directory with a bare destination name: appimagetool writes
# the .zsync into its working directory under the destination's base name, so a
# destination with a directory in it would leave the two outputs in different
# places and put that directory into the .zsync's Filename header.
( cd build && ARCH="$ARCH" VERSION="$VER" "$APPIMAGETOOL" -n -u "$UPDATE_INFO" \
    "${SIGN_ARGS[@]}" "$SOURCE_DIR/AppDir" "$APPIMAGE" )

#--------------------------------------------------------------------------
# 9. Checks on the AppImage
#--------------------------------------------------------------------------
if [ ! -f "$APPIMAGE_PATH.zsync" ]; then
    echo "build-appimage.sh: no $APPIMAGE_PATH.zsync was produced." >&2
    echo "appimagetool carries its own zsyncmake, so this means the update" >&2
    echo "information above was not accepted." >&2
    exit 1
fi

echo "=== Smoke testing $APPIMAGE_PATH"
chmod +x "$APPIMAGE_PATH"
QT_QPA_PLATFORM=offscreen "./$APPIMAGE_PATH" --version

# A full start, offscreen, with QML import tracing on. A module the deploy step
# missed shows up here and nowhere else in an automated run.
echo "=== Checking QML imports"
trace="$(mktemp)"
set +e
QT_QPA_PLATFORM=offscreen QML_IMPORT_TRACE=1 timeout 10 "./$APPIMAGE_PATH" >"$trace" 2>&1
status=$?
set -e
# A module that is absent, and a plugin that loads the host's copy of a library
# instead of the bundled one, both surface here and nowhere else in an automated
# run. 124 is timeout's code for "still running", which is what success looks
# like: the app came up and kept running until the timeout killed it.
if grep -qE 'is not installed|module .* not found|Cannot load library|failed to load component|version .Qt_[0-9]' "$trace"; then
    echo "build-appimage.sh: the bundle does not load cleanly:" >&2
    grep -E 'is not installed|module .* not found|Cannot load library|failed to load component|version .Qt_[0-9]' "$trace" >&2
    rm -f "$trace"
    exit 1
fi
if [ "$status" != "124" ] && [ "$status" != "0" ]; then
    echo "build-appimage.sh: the bundle exited with status $status instead of starting up:" >&2
    tail -20 "$trace" >&2
    rm -f "$trace"
    exit 1
fi
rm -f "$trace"
echo "  starts up with no missing QML modules"

if [ -n "$QPROMPT_SIGN_KEY" ]; then
    echo "=== Checking the embedded signature"
    if command -v validate >/dev/null 2>&1; then
        validate "$APPIMAGE_PATH"
    elif objcopy --dump-section .sha256_sig=/dev/stdout "$APPIMAGE_PATH" 2>/dev/null | grep -q 'PGP SIGNATURE'; then
        echo "  signature section present (install AppImageUpdate's 'validate' to verify it)"
    else
        echo "build-appimage.sh: $APPIMAGE_PATH carries no signature although QPROMPT_SIGN_KEY was set" >&2
        exit 1
    fi
fi

echo
echo "=== Done"
ls -la "$APPIMAGE_PATH" "$APPIMAGE_PATH.zsync"
