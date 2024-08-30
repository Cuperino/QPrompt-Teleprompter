#!/bin/bash
#**************************************************************************
#
# QPrompt
# Copyright (C) 2024 Javier O. Cordero Pérez
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

# cd ..

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
   PLATFORM="linux"
   COMPILER="gcc"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="macos"
    COMPILER="macos"
elif [[ "$OSTYPE" == "win32" || "$OSTYPE" == "msys" ]]; then
    PLATFORM="windows"
    COMPILER="msvc2019_64"
elif [[ "$OSTYPE" == "freebsd"* ]]; then
    PLATFORM="freebsd"
    COMPILER="gcc"
else
    PLATFORM="unix"
    COMPILER="gcc"
fi

cat << EOF
usage: $0 <CMAKE_BUILD_TYPE> <CMAKE_PREFIX_PATH> [<QT_MAJOR_VERSION> | ] [CLEAR | CLEAR_ALL]

Defaults:
 * CMAKE_BUILD_TYPE: "Release"
 * CMAKE_PREFIX_PATH: "~/Qt/6.7.2/$COMPILER/"
 * QT_MAJOR_VERSION: 6

Setup script for building QPrompt
This script assumes you've already installed the following dependencies:
 * Git
 * CMake
 * Qt 6 Open Source
EOF

CMAKE_BUILD_TYPE=$1
if [ "$CMAKE_BUILD_TYPE" == "" ]
    then CMAKE_BUILD_TYPE="Release"
fi
CMAKE_PREFIX_PATH=$2
if [ "$CMAKE_PREFIX_PATH" == "" ]
    then
    if [[ "$OSTYPE" == "win32" ]]; then
        CMAKE_PREFIX_PATH="C:\\Qt\\6.7.2\\$COMPILER"
    elif [[ "$OSTYPE" == "msys" ]]; then
        CMAKE_PREFIX_PATH="/c/Qt/6.7.2/$COMPILER"
    else
        CMAKE_PREFIX_PATH="~/Qt/6.7.2/$COMPILER"
    fi
fi
QT_MAJOR_VERSION=$3
if [ "$QT_MAJOR_VERSION" == "" ]
    then QT_MAJOR_VERSION=6
fi
CLEAR_ARG="${@: -1}"
if [ "$CLEAR_ARG" == "CLEAR" ]
    then
    CLEAR=true
    CLEAR_ALL=false
elif [ "$CLEAR_ARG" == "CLEAR_ALL" ]
    then
    CLEAR=true
    CLEAR_ALL=true
else
    CLEAR=false
    CLEAR_ALL=false
fi

# Constants
CMAKE_INSTALL_PREFIX="$CMAKE_PREFIX_PATH"
ARCHITECTURE="$(uname -m)"
echo -e "\nArchitecture: $ARCHITECTURE"

if [[ "$PLATFORM"=="windows" ]]
then
PATH=$PATH:"C:\Program Files (x86)\NSIS"
$CMAKE_PREFIX_PATH/bin/windeployqt.exe ./build/bin/$CMAKE_BUILD_TYPE/QPrompt.exe
elif [[ "$PLATFORM"=="macos" ]]
$CMAKE_PREFIX_PATH/bin/macdeployqt ./build/bin/QPrompt
else [[ "$PLATFORM"=="macos" ]]
fatal "This platform is unsuported by this build script."
exit
fi

cd build
cpack
