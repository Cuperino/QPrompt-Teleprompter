#**************************************************************************
#
# QPrompt
# Copyright (C) 2020-2021 Javier O. Cordero Pérez
#
# This file is part of QPrompt.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
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


cmake_minimum_required(VERSION 3.16)

set(RELEASE_SERVICE_VERSION_MAJOR "1")
set(RELEASE_SERVICE_VERSION_MINOR "0")
set(RELEASE_SERVICE_VERSION_MICRO "0")
set(RELEASE_SERVICE_VERSION "${RELEASE_SERVICE_VERSION_MAJOR}.${RELEASE_SERVICE_VERSION_MINOR}.${RELEASE_SERVICE_VERSION_MICRO}")
project(qprompt VERSION ${RELEASE_SERVICE_VERSION})

# Find includes in corresponding build directories
set(CMAKE_INCLUDE_CURRENT_DIR ON)
# Instruct CMake to create code from Qt designer ui files
set(CMAKE_AUTOUIC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 17)
# Instruct CMake to run moc automatically when needed.
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

# QT 5.15 to be able to use new Connect methods syntax and get rid of warning.
#set(QT5_MIN_VERSION 5.15.2)
# QT 5.12 for Ubuntu 20.04
set(QT_MIN_VERSION 5.12.0)
set(QT_DISABLE_DEPRECATED_BEFORE "0x051520")
# KF5 5.68 for Ubuntu 20.04
# Using 5.83 to have current ecm_add_app_icon syntax
set(ECM_MIN_VERSION 5.82.0)
# set(KF_MIN_VERSION 5.81.0)
set(REQUIRED_KF5_VERSION 5.81.0)

# ------------------------- BEGIN: lists to maintain manually -------------------------

# Directories where Qt Creator can find QML files of Kirigami etc. on your system.
#   (This setting is cached in variable QML_IMPORT_DIR, see below. Delete
#   ${BUIL_DIR}/CMakeCache.txt to make make changes here effective.)
if (UNIX AND NOT APPLE AND NOT ANDROID)
    list(APPEND QML_DIRS "/usr/lib/x86_64-linux-gnu/qt5/qml")
    list(APPEND KIRIGAMI_DIRS "/usr/lib/x86_64-linux-gnu/qt5/qml/org/kde/kirigami.2")
elseif (WIN32)
    list(APPEND QML_DIRS "C:/CraftRoot/qml")
    list(APPEND KIRIGAMI_DIRS "C:/CraftRoot/qml/org/kde/kirigami.2")
endif()
# ------------------------- END: lists to maintain ma/usr/lib/x86_64-linux-gnu/qt5/nually -------------------------

# Prevent adding duplicate values at each run of CMake.
list(REMOVE_DUPLICATES QML_DIRS)

# Tell Qt Creator where to find QML files.
# (The build process will work without this, but no code completion etc..)
# The variable is cached in ${BUILD_DIR}/CMakeCache.txt. We need FORCE to change it there immediately.
set(
    QML_IMPORT_PATH ${KIRIGAMI_DIRS}
    QML_IMPORT_PATH ${QML_DIRS}
    CACHE STRING "Qt Creator 4.1 extra qml import paths"
    FORCE
)

# if(NOT CMAKE_BUILD_TYPE)
#     set(CMAKE_BUILD_TYPE MinSizeRel CACHE STRING FORCE)
# endif()

# Send compiled program and library binaries to "build/bin"
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

find_package(ECM ${ECM_MIN_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})
find_package(Qt5 ${QT5_MIN_VERSION} REQUIRED COMPONENTS
    Core
    Quick
    Test
    Gui
    QuickControls2
    Widgets
    QmlImportScanner  # Used to get static QML. Gets ignored if not a static build
    QuickCompiler
)
find_package(KF5 ${KF_MIN_VERSION} REQUIRED COMPONENTS
    Kirigami2
    I18n  # NO_MODULE
    CoreAddons
#    IconThemes
)

if (WIN32 OR UNIX AND NOT ANDROID)
    include(KDEInstallDirs)
    include(KDECMakeSettings)
endif()
include(KDECompilerSettings NO_POLICY_SCOPE)
include(ECMInstallIcons)
include(ECMAddAppIcon)
include(ECMQtDeclareLoggingCategory)
include(ECMSetupVersion)
include(ECMSourceVersionControl)
include(FeatureSummary)

#add_subdirectory("3rdparty/extra-cmake-modules" build/ecm)
#add_subdirectory("3rdparty/kirigami" build/kirigami)
#add_subdirectory("3rdparty/ki18n" build/ki18n)
#add_subdirectory("3rdparty/breeze-icons" build/icons)
#add_subdirectory("3rdparty/calligra/filters/libmsooxml" build/libmsooxml)

if (${ECM_SOURCE_UNDER_VERSION_CONTROL})
    execute_process(
        COMMAND git rev-parse --abbrev-ref HEAD
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        OUTPUT_VARIABLE GIT_BRANCH
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    # Get the latest abbreviated commit hash of the working branch
    execute_process(
        COMMAND git log -1 --format=%h
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        OUTPUT_VARIABLE GIT_COMMIT_HASH
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    add_definitions(-DGIT_COMMIT_HASH="${GIT_COMMIT_HASH}")
    add_definitions(-DGIT_BRANCH="${GIT_BRANCH}")

else()
    add_definitions(-DGIT_COMMIT_HASH="${RELEASE_SERVICE_VERSION}")
    add_definitions(-DGIT_BRANCH="Development")
endif()

# ecm_setup_version(PROJECT
ecm_setup_version(${RELEASE_SERVICE_VERSION}
    VARIABLE_PREFIX QPROMPT
    VERSION_HEADER "${CMAKE_CURRENT_BINARY_DIR}/qprompt_version.h"
)

add_subdirectory(src build)

# target_sources(qprompt PUBLIC ${ICONS_SOURCES})
# target_sources(qprompt PUBLIC)

if (WIN32 OR UNIX AND NOT ANDROID)
    install(FILES com.cuperino.qprompt.appdata.xml DESTINATION ${KDE_INSTALL_METAINFODIR})
    # install(FILES com.cuperino.qprompt.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})
    install(PROGRAMS com.cuperino.qprompt.desktop DESTINATION ${KDE_INSTALL_APPDIR})
endif()

ki18n_install(po)
feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)
