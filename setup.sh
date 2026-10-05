#!/bin/bash

#**************************************************************************
#
# QPrompt
# Copyright (C) 2024-2026 Javier O. Cordero Pérez
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

# Stop at the first failure
set -eo pipefail

ARCHITECTURE="$(uname -m)"
# KDE Frameworks 6.24 (Kirigami, KCoreAddons, KGlobalAccel) requires Qt 6.8.0 or
# newer. Capped at the 6.8.x series so the Linux packages keep working on Debian.
DEFAULT_QT_VER=6.8.3
echo -e "\nArchitecture: $ARCHITECTURE"

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    QT_VER=$DEFAULT_QT_VER
    PLATFORM="linux"
    CMAKE_INSTALL_PREFIX="/usr"
    if [ "$ARCHITECTURE" == "aarch64" ]; then
        COMPILER="gcc_arm64"
    else
        COMPILER="gcc_64"
    fi
    CMAKE=~/Qt/Tools/CMake/bin/cmake
    CPACK=~/Qt/Tools/CMake/bin/cpack
    PATH=$PATH:~/Qt/Tools/QtInstallerFramework/4.8/bin
elif [[ "$OSTYPE" == "darwin"* ]]; then
    QT_VER=$DEFAULT_QT_VER
    PLATFORM="macos"
    COMPILER="macos"
    CMAKE=~/Qt/Tools/CMake/CMake.app/Contents/bin/cmake
    CPACK=~/Qt/Tools/CMake/CMake.app/Contents/bin/cpack
    PATH=$PATH:~/Qt/Tools/QtInstallerFramework/4.8/bin
elif [[ "$OSTYPE" == "win32" || "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    QT_VER=$DEFAULT_QT_VER
    PLATFORM="windows"
    CMAKE_INSTALL_PREFIX="install"
    if [ "$ARCHITECTURE" == "aarch64" ]; then
        COMPILER="msvc2022_arm64"
    else
        COMPILER="msvc2022_64"
    fi
    if [[ "$OSTYPE" == "cygwin" ]]; then
    CMAKE="/c/Qt/Tools/CMake_64/bin/cmake.exe"
    CPACK="/c/Qt/Tools/CMake_64/bin/cpack.exe"
    else
    CMAKE=C:\\Qt\\Tools\\CMake_64\\bin\\cmake.exe
    CPACK=C:\\Qt\\Tools\\CMake_64\\bin\\cpack.exe
    fi
elif [[ "$OSTYPE" == "freebsd"* ]]; then
    QT_VER=$DEFAULT_QT_VER
    PLATFORM="freebsd"
    CMAKE_INSTALL_PREFIX="/usr"
    COMPILER="gcc"
    CMAKE=cmake
    CPACK=cpack
else
    QT_VER=$DEFAULT_QT_VER
    PLATFORM="unix"
    CMAKE_INSTALL_PREFIX="/usr"
    COMPILER="gcc"
    CMAKE=cmake
    CPACK=cpack
fi

# Build in parallel. cmake --build invokes the native build tool without -j
# unless it is told otherwise, so with the default Makefiles generator every
# build below would compile one file at a time. CMAKE_BUILD_PARALLEL_LEVEL is
# honoured by every cmake --build call, on every generator. Set it yourself to
# cap the job count, for instance on a machine short on memory.
if [ -z "$CMAKE_BUILD_PARALLEL_LEVEL" ]; then
    if command -v nproc >/dev/null 2>&1; then
        CMAKE_BUILD_PARALLEL_LEVEL="$(nproc)"
    elif sysctl -n hw.ncpu >/dev/null 2>&1; then
        CMAKE_BUILD_PARALLEL_LEVEL="$(sysctl -n hw.ncpu)"
    elif [ -n "$NUMBER_OF_PROCESSORS" ]; then
        CMAKE_BUILD_PARALLEL_LEVEL="$NUMBER_OF_PROCESSORS"
    else
        CMAKE_BUILD_PARALLEL_LEVEL=4
    fi
fi
export CMAKE_BUILD_PARALLEL_LEVEL

CMAKE_CONFIGURATION_TYPES="Debug;Release;RelWithDebInfo;MinSizeRel"
CMAKE_BUILD_TYPE=$1
if [ "$CMAKE_BUILD_TYPE" == "" ]; then
    if [[ "$PLATFORM" == "windows" || "$PLATFORM" == "macos" ]]; then
        CMAKE_BUILD_TYPE="Release"
    else
        CMAKE_BUILD_TYPE="RelWithDebInfo"
    fi
fi
CMAKE_PREFIX_PATH=$2
if [ "$CMAKE_PREFIX_PATH" == "" ]; then
    if [[ "$OSTYPE" == "win32" ]]; then
        CMAKE_PREFIX_PATH="C:\\Qt\\$QT_VER\\$COMPILER\\"
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        CMAKE_PREFIX_PATH=/c/Qt/$QT_VER/$COMPILER/
    else
        CMAKE_PREFIX_PATH=~/Qt/$QT_VER/$COMPILER/
    fi
fi

if [[ "$PLATFORM" == "macos" ]]; then
    CMAKE_INSTALL_PREFIX=$CMAKE_PREFIX_PATH
fi

cat << EOF
usage: $0 <CMAKE_BUILD_TYPE> <CMAKE_PREFIX_PATH> [CLEAR | CLEAR_ALL]

Settings:
 * CMAKE_BUILD_TYPE: $CMAKE_BUILD_TYPE
 * CMAKE_PREFIX_PATH: $CMAKE_PREFIX_PATH
 * CMAKE_BUILD_PARALLEL_LEVEL: $CMAKE_BUILD_PARALLEL_LEVEL

Setup script for building QPrompt
This script assumes you've already installed the following dependencies:

 For all platforms:
 > Git
 > Bash
 > Qt 6 ($QT_VER for $COMPILER should be installed)
 > CMake (from the Qt Maintenance Tool on Windows and Mac
          and accessible from PATH for all other systens)

 On Ubuntu and Debian Linux, install the following:
 > sudo apt install build-essential git cmake libgl-dev libegl-dev libxkbcommon-x11-dev
   (this script also installs libxkbcommon-dev, libx11-dev and libhunspell-dev,
    unless QPROMPT_SKIP_APT=1)

 For Windows:
 > Visual Studio (Community Edition)
 >> Desktop Development with C++
 >> C++ ATL
 >> Windows SDK
EOF

QT_MAJOR_VERSION=6
CLEAR_ARG="${@: -1}"
if [ "$CLEAR_ARG" == "CLEAR" ]; then
    CLEAR=true
    CLEAR_ALL=false
elif [ "$CLEAR_ARG" == "CLEAR_ALL" ]; then
    CLEAR=true
    CLEAR_ALL=true
else
    CLEAR=false
    CLEAR_ALL=false
fi

# Constants
if [[ "$PLATFORM" == "windows" ]]; then
    AppDir=""
    AppDirUsr="install"
else
    AppDir="install"
    AppDirUsr="install/usr"
fi
if [[ "$PLATFORM" != "macos" ]]; then
    mkdir -p $AppDirUsr
fi

# Get software version
QP_VER_MAJOR=$(cat CMakeLists.txt | grep RELEASE_SERVICE_VERSION_MAJOR | tr -d -c 0-9)
QP_VER_MINOR=$(cat CMakeLists.txt | grep RELEASE_SERVICE_VERSION_MINOR | tr -d -c 0-9)
QP_VER_MICRO=$(cat CMakeLists.txt | grep RELEASE_SERVICE_VERSION_MICRO | tr -d -c 0-9)

echo -e "\nBuild directory is ./build"
if $CLEAR_ALL # QPrompt and dependencies
    then
    rm -dRf ./build ./install
elif $CLEAR # QPrompt
    then
    rm -dRf ./build
fi
mkdir -p build install

echo "Downloading git submodules"
# sync first so a clone made before the KDE submodules moved to the GitHub
# mirrors picks up the new URLs instead of failing against the old ones.
git submodule sync --recursive
git submodule update --init --recursive

# Build dependencies that are not part of Qt. pkg-config is what finds Hunspell:
# there is no FindHunspell module, so CMake reaches it only through
# pkg_check_modules, and without pkg-config spell checking is quietly compiled
# out. Set QPROMPT_SKIP_APT=1 where the packages are already in place, such as a
# CI container that has no sudo and must not prompt.
if [[ "$PLATFORM" == "linux" && "$QPROMPT_SKIP_APT" != "1" ]]; then
    APT_SUDO=""
    if [ "$(id -u)" != "0" ]; then
        APT_SUDO="sudo"
    fi
    # env, not a prefix assignment: sudo resets the environment by default, so
    # DEBIAN_FRONTEND would not reach apt-get.
    # update first: on a fresh install the package index can be too stale for
    # apt-get install to resolve these names.
    $APT_SUDO env DEBIAN_FRONTEND=noninteractive apt-get update
    $APT_SUDO env DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential git curl ca-certificates pkg-config cmake extra-cmake-modules libgl-dev libegl-dev libglx-dev libxkbcommon-dev libxkbcommon-x11-dev libx11-dev libhunspell-dev appstream
fi
if [[ "$PLATFORM" == "windows" ]]; then
    # Download and extract gettext binary
    FILENAME="gettext0.25-iconv1.17-shared-64.zip"
    curl -Lo build/$FILENAME "https://github.com/mlocati/gettext-iconv-windows/releases/download/v0.25-v1.17/$FILENAME"
    unzip -o build/$FILENAME -d "$CMAKE_PREFIX_PATH"
fi

# KDE Frameworks
tier_0="
    ./3rdparty/extra-cmake-modules
"
if [[ "$PLATFORM" == "linux" ]]; then
    # KGlobalAccel is built here rather than taken from the distribution:
    # Debian 13's libkf6globalaccel-dev is built against Debian's Qt, so mixing
    # it with the Qt this script builds against would put two Qt builds in the
    # same process. KCrash is not built at all: the Linux build never links
    # KF6::Crash (main.cpp only calls it under a KF6Crash_FOUND define that no
    # CMake rule sets), so there is nothing to deploy.
    tier_1="
       ./3rdparty/kcoreaddons
       ./3rdparty/kglobalaccel
       ./3rdparty/kirigami
    "
fi

for dependency in $tier_0 $tier_1; do
    echo -e "\n\n~~~" $dependency "~~~\n"
    if $CLEAR_ALL; then
        rm -dRf $dependency/build
    fi
    # BUILD_PYTHON_BINDINGS is OFF because QPrompt only needs the C++ libraries
    $CMAKE -DCMAKE_CONFIGURATION_TYPES=$CMAKE_CONFIGURATION_TYPES -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE -DCMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH -DCMAKE_INSTALL_PREFIX=$CMAKE_INSTALL_PREFIX -DBUILD_TESTING=OFF -DBUILD_DOC=OFF -DBUILD_QCH=OFF -DBUILD_PYTHON_BINDINGS=OFF -B ./$dependency/build ./$dependency/
    $CMAKE --build ./$dependency/build --config $CMAKE_BUILD_TYPE
    if [[ "$PLATFORM" == "macos" ]]; then
        $CMAKE --install ./$dependency/build
    else
        DESTDIR=$AppDir $CMAKE --install ./$dependency/build
        cp -r $AppDirUsr/* $CMAKE_PREFIX_PATH
    fi
done

echo "QHotkey"
if $CLEAR_ALL; then
    rm -dRf 3rdparty/QHotkey/build
fi
$CMAKE -DCMAKE_CONFIGURATION_TYPES=$CMAKE_CONFIGURATION_TYPES -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE -DCMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH -DCMAKE_INSTALL_PREFIX=$CMAKE_INSTALL_PREFIX -DBUILD_SHARED_LIBS=ON -DQT_DEFAULT_MAJOR_VERSION=$QT_MAJOR_VERSION -B ./3rdparty/QHotkey/build ./3rdparty/QHotkey/
$CMAKE --build ./3rdparty/QHotkey/build --config $CMAKE_BUILD_TYPE
if [[ "$PLATFORM" == "macos" ]]; then
    $CMAKE --install ./3rdparty/QHotkey/build
else
    DESTDIR=$AppDir $CMAKE --install ./3rdparty/QHotkey/build
    cp -r $AppDirUsr/* $CMAKE_PREFIX_PATH
fi

echo "QPrompt"
# QPROMPT_BUNDLE_HUNSPELL_DICTIONARIES is spelled out as OFF so a value cached
# by an earlier AppImage build in the same tree cannot put dictionaries into the
# DEB. Only dist/appimage/build-appimage.sh turns it on, through
# QPROMPT_CMAKE_ARGS, and that build skips CPack.
$CMAKE -DCMAKE_CONFIGURATION_TYPES=$CMAKE_CONFIGURATION_TYPES -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE -DCMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH -DCMAKE_INSTALL_PREFIX=$CMAKE_INSTALL_PREFIX -DQPROMPT_BUNDLE_HUNSPELL_DICTIONARIES=OFF $QPROMPT_CMAKE_ARGS -B ./build .
$CMAKE --build ./build --config $CMAKE_BUILD_TYPE
if [[ "$PLATFORM" == "macos" ]]; then
    $CMAKE --install ./build
else
    DESTDIR=$AppDir $CMAKE --install ./build
fi

# Packaging. dist/appimage/build-appimage.sh sets QPROMPT_SKIP_CPACK=1: it
# packages the staged tree itself and has no use for a DEB.
if [[ "$QPROMPT_SKIP_CPACK" == "1" ]]; then
    echo -e "\nQPROMPT_SKIP_CPACK=1, skipping CPack."
    exit 0
fi

# Copy Qt libraries into install directory
if [[ "$PLATFORM" == "windows" ]]; then
    PATH=$PATH:"C:\Program Files (x86)\NSIS"
    if [[ "$OSTYPE" == "cygwin" ]]; then
    $CMAKE_PREFIX_PATH/bin/windeployqt.exe ./install/bin/QPrompt.exe
    else
    $CMAKE_PREFIX_PATH/bin/windeployqt.exe ./install/bin/$CMAKE_BUILD_TYPE/QPrompt.exe
    fi
    cd build
    $CPACK
    cd ..
elif [[ "$PLATFORM" == "macos" ]]; then
    cd build
    $CPACK
    cd ..
elif [[ "$PLATFORM" == "linux" ]]; then
    # Build Deb package
    cd build
    $CPACK
    cd ..
fi
