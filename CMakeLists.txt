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

project(QPrompt)
include(FeatureSummary)

# Find includes in corresponding build directories
set(CMAKE_INCLUDE_CURRENT_DIR ON)
# Instruct CMake to run moc automatically when needed.
set(CMAKE_AUTOMOC ON)
# Instruct CMake to create code from Qt designer ui files
set(CMAKE_AUTOUIC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 17)

# QT 5.15 to be able to use new Connect methods syntax and get rid of warning.
#set(QT5_MIN_VERSION 5.15.2)
# QT 5.12 for Ubuntu 20.04
set(QT_MIN_VERSION "5.12.0")
set(QT_DISABLE_DEPRECATED_BEFORE "0x051520")
# KF5 5.68 for Ubuntu 20.04
set(KF_MIN_VERSION "5.68.0")

# set(CMAKE_WIN32_EXECUTABLE ON)
# set(CMAKE_MACOSX_BUNDLE ON)

# ------------------------- BEGIN: lists to maintain manually -------------------------

# Directories where Qt Creator can find QML files of Kirigami etc. on your system.
#   (This setting is cached in variable QML_IMPORT_DIR, see below. Delete
#   ${BUIL_DIR}/CMakeCache.txt to make make changes here effective.)
# list(APPEND QML_DIRS "/usr/lib/x86_64-linux-gnu/qt5/qml")
# list(APPEND KIRIGAMI_DIRS "/usr/lib/x86_64-linux-gnu/qt5/qml/org/kde/kirigami.2")
# list(APPEND QML_DIRS "C:/CraftRoot/qml")
# list(APPEND KIRIGAMI_DIRS "C:/CraftRoot/qml/org/kde/kirigami.2")

# Configuration Issues are Here
#list(APPEND ECM_MODULE_PATH "3rdparty/extra-cmake-modules/build")

#list(APPEND ECM_MODULE_PATH "/usr/share/ECM/cmake")
#list(APPEND KF5Kirigami2_PATH "/usr/lib/x86_64-linux-gnu/cmake/KF5Kirigami2")
#list(APPEND KF5Kirigami2_PATH "C:/CraftRoot/qml/org/kde/kirigami.2")
#list(APPEND KF5I18n_PATH "/usr/lib/x86_64-linux-gnu/cmake/KF5I18n")

# Prevent adding duplicate values at each run of CMake.
list(REMOVE_DUPLICATES QML_DIRS)

# ------------------------- END: lists to maintain ma/usr/lib/x86_64-linux-gnu/qt5/nually -------------------------

# Tell Qt Creator where to find QML files.
#   (The build process will work without this, but no code completion etc..)
#set(
#    QML_IMPORT_PATH "${QML_DIRS}"
#    QML_IMPORT_PATH "${KIRIGAMI_DIRS}"
#    CACHE STRING "Qt Creator 4.1 extra qml import paths"
#)
# The variable is cached in ${BUILD_DIR}/CMakeCache.txt. We need FORCE to
# change it there immediately. Also, add a comment to the cache file.
set(
    QML_IMPORT_PATH ${KIRIGAMI_DIRS}
    QML_IMPORT_PATH ${QML_DIRS}
    CACHE STRING "Qt Creator 4.1 extra qml import paths"
    FORCE
)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE MinSizeRel CACHE STRING FORCE)
endif()

# Send compiled program and library binaries to "build/bin"
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

#set(ECM_DIR ${ECM_MODULE_PATH})
#set(KF5Kirigami2_DIR ${KF5Kirigami2_PATH})
#set(KF5I18n_DIR ${KF5I18n_PATH})

find_package(ECM ${KF_MIN_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(ECMInstallIcons)
include(ECMAddAppIcon)
include(ECMQtDeclareLoggingCategory)
find_package(Qt5 ${QT5_MIN_VERSION} REQUIRED COMPONENTS
    Core
    Quick
    Test
    Gui
    QuickControls2
    Widgets
    QmlImportScanner  # Used to get static QML. Gets ignored if not a static build
)
find_package(Qt5QuickCompiler)
find_package(KF5 ${KF_MIN_VERSION} REQUIRED COMPONENTS
    Kirigami2
    I18n
    CoreAddons
#    IconThemes
)
#find_package(KF5CoreAddons)
#find_package(KF5I18n NO_MODULE)
#find_package(KF5Kirigami2)

#add_subdirectory("3rdparty/extra-cmake-modules" build/ecm)
#add_subdirectory("3rdparty/kirigami" build/kirigami)
#add_subdirectory("3rdparty/ki18n" build/ki18n)
#add_subdirectory("3rdparty/breeze-icons" build/icons)
#add_subdirectory("3rdparty/calligra/filters/libmsooxml" build/libmsooxml)

ki18n_install(po)

set(ICONS_FOLDER ${CMAKE_CURRENT_SOURCE_DIR}/icons/hicolor)
set(ICON_FILES
  ${ICONS_FOLDER}/1024-apps-com.cuperino.qprompt.png
  ${ICONS_FOLDER}/512-apps-com.cuperino.qprompt.png
  ${ICONS_FOLDER}/256-apps-com.cuperino.qprompt.png
  ${ICONS_FOLDER}/128-apps-com.cuperino.qprompt.png
  ${ICONS_FOLDER}/32-apps-com.cuperino.qprompt.png
  ${ICONS_FOLDER}/sc-apps-com.cuperino.qprompt.svg
#   ${ICONS_FOLDER}/scalable-apps-com.cuperino.qprompt.icns
#   ${ICONS_FOLDER}/qprompt.png
)
ecm_add_app_icon(qprompt ICONS_SOURCES ICONS ${ICON_FILES})

add_subdirectory(src build)
target_sources(qprompt PRIVATE ${ICONS_SOURCES})

install(FILES com.cuperino.qprompt.appdata.xml DESTINATION ${KDE_INSTALL_METAINFODIR})
# install(FILES icons/qprompt.ico DESTINATION ${KDE_INSTALL_FULL_ICONDIR})
# install(FILES icons/qprompt.png DESTINATION ${KDE_INSTALL_FULL_ICONDIR})
# install(FILES icons/qprompt.icns DESTINATION ${KDE_INSTALL_FULL_ICONDIR})
# install(FILES icons/qprompt.svg DESTINATION ${KDE_INSTALL_FULL_ICONDIR}/hicolor/scalable/apps)
install(PROGRAMS com.cuperino.qprompt.desktop DESTINATION ${KDE_INSTALL_APPDIR})

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)
