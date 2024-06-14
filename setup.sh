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

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
   COMPILER="gcc"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    COMPILER="macos"
elif [[ "$OSTYPE" == "win32" ]]; then
    COMPILER="msvc"
elif [[ "$OSTYPE" == "freebsd"* ]]; then
    COMPILER="gcc"
else
    COMPILER="gcc"
fi

cat << EOF
usage: $0 <CMAKE_BUILD_TYPE> <CMAKE_PREFIX_PATH> [<QT_MAJOR_VERSION> | ] [CLEAR | CLEAR_ALL]

Defaults:
 * CMAKE_BUILD_TYPE: "Release"
 * CMAKE_PREFIX_PATH: "~/Qt/6.7.1/$COMPILER/"
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
        then CMAKE_PREFIX_PATH="~/Qt/6.7.1/$COMPILER/"
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

echo "Build directory is ./build"
if $CLEAR_ALL # QPrompt and dependencies
    then
    rm -dRf ./build ./install
elif $CLEAR # QPrompt
    then
    rm -dRf ./build
fi
mkdir -p build install

if [[ "$OSTYPE" == "darwin"* ]]; then
    brew install ninja
fi

echo "Downloading git submodules"
git submodule update --init --recursive

python3 -m venv docs/venv
source docs/venv/bin/activate
pip3 install -r docs/requirements.txt

echo "Extra CMake Modules"
if $CLEAR_ALL
    then
    rm -dRf ./3rdparty/extra-cmake-modules/build
fi
cmake -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE -DCMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH -DCMAKE_INSTALL_PREFIX=$CMAKE_INSTALL_PREFIX -B ./3rdparty/extra-cmake-modules/build -G Ninja ./3rdparty/extra-cmake-modules/
ninja -C ./3rdparty/extra-cmake-modules/build

# KDE Frameworks
for dependency in ./3rdparty/k*; do
    echo $dependency
    if $CLEAR_ALL
    then
        rm -dRf ./$dependency/build
    fi
    cmake -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE -DCMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH -DCMAKE_INSTALL_PREFIX=$CMAKE_INSTALL_PREFIX -B ./$dependency/build -G Ninja ./$dependency/
    ninja -C ./$dependency/build
done

echo "QHotkey"
if $CLEAR_ALL
then
    rm -dRf ./3rdparty/QHotkey/build
fi
cmake -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE -DCMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH -DCMAKE_INSTALL_PREFIX=$CMAKE_INSTALL_PREFIX -DBUILD_SHARED_LIBS=ON -DQT_DEFAULT_MAJOR_VERSION=${QT_MAJOR_VERSION} -B ./3rdparty/QHotkey/build -G Ninja ./3rdparty/QHotkey/
ninja -C ./3rdparty/QHotkey/build

echo "QPrompt"
cmake -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE -DCMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH -DCMAKE_INSTALL_PREFIX=$CMAKE_INSTALL_PREFIX -B ./build -G Ninja .
ninja -C build
