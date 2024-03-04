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

cat << EOF
usage: $0 [-G <[DEB|AppImage|EXE|DMG]>| -n <levels>][--help][--version]

Setup script for building QPrompt
This script assumes you've already installed the following dependencies:
 * Git
 * CMake
 * Qt 6 Open Source
EOF

CMAKE_BUILD_TYPE="Release"
CMAKE_PREFIX_PATH="~/Qt/6.7.0/gcc_64/"
CMAKE_INSTALL_PREFIX="./install"

echo "Build directory is ./build"
rm -dRf ./build ./install
mkdir -p build install

echo "Downloading git submodules"
git submodule update --init --recursive

echo "Extra CMake Modules"
rm -dRf ./3rdparty/extra-cmake-modules/build
cmake -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE -DCMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH -DCMAKE_INSTALL_PREFIX=$CMAKE_INSTALL_PREFIX -B ./3rdparty/extra-cmake-modules/build ./3rdparty/extra-cmake-modules/
cmake --build ./3rdparty/extra-cmake-modules/build
cmake --install ./3rdparty/extra-cmake-modules/build

# KDE Frameworks
for dependency in ./3rdparty/k*; do
    echo $dependency
    rm -dRf ./$dependency/build
    cmake -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE -DCMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH -DCMAKE_INSTALL_PREFIX=$CMAKE_INSTALL_PREFIX -B ./$dependency/build ./$dependency/
    cmake --build ./$dependency/build
    cmake --install ./$dependency/build
done

echo "QHotkey"
rm -dRf ./3rdparty/QHotkey/build
cmake -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE -DCMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH -DCMAKE_INSTALL_PREFIX=$CMAKE_INSTALL_PREFIX -B ./3rdparty/QHotkey/build ./3rdparty/QHotkey/
cmake --build ./3rdparty/QHotkey/build
cmake --install ./3rdparty/QHotkey/build

echo "QPrompt"
cmake -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE -DCMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH -DCMAKE_INSTALL_PREFIX=$CMAKE_INSTALL_PREFIX -B ./build .
cmake --build ./build
cmake --install ./build
