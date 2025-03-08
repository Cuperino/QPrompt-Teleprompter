#!/bin/bash

#**************************************************************************
#
# QPrompt
# Copyright (C) 2024-2025 Javier O. Cordero Pérez
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

ARCHITECTURE="$(uname -m)"
QT_VER=6.8.2
echo -e "\nArchitecture: $ARCHITECTURE"

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
   PLATFORM="linux"
   CMAKE_INSTALL_PREFIX="/usr"
   if [ "$ARCHITECTURE" == "aarch64" ]; then
       COMPILER="gcc_arm64"
   else
       COMPILER="gcc_64"
   fi
   CMAKE=cmake
   CPACK=cpack
   PATH=$PATH:~/Qt/Tools/QtInstallerFramework/4.8/bin
elif [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="macos"
    COMPILER="macos"
    CMAKE=~/Qt/Tools/CMake/CMake.app/Contents/bin/cmake
    CPACK=~/Qt/Tools/CMake/CMake.app/Contents/bin/cpack
    PATH=$PATH:~/Qt/Tools/QtInstallerFramework/4.8/bin
elif [[ "$OSTYPE" == "win32" || "$OSTYPE" == "msys" ]]; then
    PLATFORM="windows"
    CMAKE_INSTALL_PREFIX="install"
    if [ "$ARCHITECTURE" == "aarch64" ]; then
        COMPILER="msvc2022_arm64"
    else
        COMPILER="msvc2022_64"
    fi
    CMAKE=C:\\Qt\\Tools\\CMake_64\\bin\\cmake.exe
    CPACK=C:\\Qt\\Tools\\CMake_64\\bin\\cpack.exe
elif [[ "$OSTYPE" == "freebsd"* ]]; then
    PLATFORM="freebsd"
    CMAKE_INSTALL_PREFIX="/usr"
    COMPILER="gcc"
    CMAKE=cmake
    CPACK=cpack
else
    PLATFORM="unix"
    CMAKE_INSTALL_PREFIX="/usr"
    COMPILER="gcc"
    CMAKE=cmake
    CPACK=cpack
fi

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
    elif [[ "$OSTYPE" == "msys" ]]; then
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

Setup script for building QPrompt
This script assumes you've already installed the following dependencies:

 For all platforms:
 > Git
 > Bash
 > Python 3
 > Qt 6 ($QT_VER used by default)

 For Linux:
 > build-essential
 > cmake
 > python3-venv
 > Run: sudo apt install build-essential cmake python3-venv gettext libgl1-mesa-dev libxkbcommon-x11-dev default-libmysqlclient-dev

 For macOS:
 > CMake
 > Homebrew

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
git submodule update --init --recursive

if [[ "$PLATFORM" == "windows" ]]; then
    # Initialize MSVC environment variables
    "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" amd64
fi

# KDE Frameworks
tier_0="
    ./3rdparty/extra-cmake-modules
"
tier_1="
    ./3rdparty/kcoreaddons
    ./3rdparty/kirigami
    ./3rdparty/kcrash
"
tier_2="
"
tier_3="
"
for dependency in $tier_0 $tier_1 $tier_2 $tier_3; do
    echo -e "\n\n~~~" $dependency "~~~\n"
    if $CLEAR_ALL; then
        rm -dRf $dependency/build
    fi
    $CMAKE -DCMAKE_CONFIGURATION_TYPES=$CMAKE_CONFIGURATION_TYPES -DCMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH -DCMAKE_INSTALL_PREFIX=$CMAKE_INSTALL_PREFIX -DBUILD_TESTING=OFF -DBUILD_DOC=OFF -BUILD_QCH=OFF -B ./$dependency/build ./$dependency/
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
$CMAKE -DCMAKE_CONFIGURATION_TYPES=$CMAKE_CONFIGURATION_TYPES -DCMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH -DCMAKE_INSTALL_PREFIX=$CMAKE_INSTALL_PREFIX -DBUILD_SHARED_LIBS=ON -DQT_DEFAULT_MAJOR_VERSION=$QT_MAJOR_VERSION -B ./3rdparty/QHotkey/build ./3rdparty/QHotkey/
$CMAKE --build ./3rdparty/QHotkey/build --config $CMAKE_BUILD_TYPE
if [[ "$PLATFORM" == "macos" ]]; then
    $CMAKE --install ./3rdparty/QHotkey/build
else
    DESTDIR=$AppDir $CMAKE --install ./3rdparty/QHotkey/build
    cp -r $AppDirUsr/* $CMAKE_PREFIX_PATH
fi

echo "QPrompt"
$CMAKE -DCMAKE_CONFIGURATION_TYPES=$CMAKE_CONFIGURATION_TYPES -DCMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH -DCMAKE_INSTALL_PREFIX=$CMAKE_INSTALL_PREFIX -B ./build .
$CMAKE --build ./build --config $CMAKE_BUILD_TYPE
if [[ "$PLATFORM" == "macos" ]]; then
    $CMAKE --install ./build
else
    DESTDIR=$AppDir $CMAKE --install ./build
fi

# Copy Qt libraries into install directory
if [[ "$PLATFORM" == "windows" ]]; then
    PATH=$PATH:"C:\Program Files (x86)\NSIS"
    $CMAKE_PREFIX_PATH/bin/windeployqt.exe ./install/bin/$CMAKE_BUILD_TYPE/QPrompt.exe
    cd build
    $CPACK
    cd ..
elif [[ "$PLATFORM" == "macos" ]]; then
    # $CMAKE_PREFIX_PATH/bin/macdeployqt ./build/bin/QPrompt.app -qmldir=./build/bin -dmg
    cd build
    $CPACK
    cd ..
elif [[ "$PLATFORM" == "linux" ]]; then
    # Copy libraries out from multilib subdirectory
    if [ "$ARCHITECTURE" == "aarch64" ]; then
        cp -r $AppDirUsr/lib/aarch64-linux-gnu/* $CMAKE_PREFIX_PATH/lib/
    fi
    mkdir -p ~/Applications/
    wget -nc -P ~/Applications/ https://github.com/$(wget -q https://github.com/probonopd/go-appimage/releases/expanded_assets/continuous -O - | grep "appimagetool-.*-$ARCHITECTURE.AppImage" | head -n 1 | cut -d '"' -f 2)
    APPIMAGE_TOOL=~/Applications/$(ls ~/Applications/ | grep "appimagetool-.*-$ARCHITECTURE.AppImage")
    if ! command -v $APPIMAGE_TOOL 2>&1 >/dev/null; then
        echo "$APPIMAGE_TOOL could not be found"
        exit 1
    fi
    chmod +x $APPIMAGE_TOOL
    QTDIR=$CMAKE_PREFIX_PATH $APPIMAGE_TOOL deploy $AppDirUsr/share/applications/com.cuperino.qprompt.desktop
    # Turn AppDir into AppImage
    VERSION=v$QP_VER_MAJOR.$QP_VER_MINOR.$QP_VER_MICRO-$(git rev-parse --short HEAD) $APPIMAGE_TOOL $AppDir
    # Build Debian Package
    cd build
    $CPACK
    cd ..
fi
