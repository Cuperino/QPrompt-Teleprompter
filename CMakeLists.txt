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
# KF5 5.68 for Ubuntu 20.04
set(KF_MIN_VERSION "5.68.0")

# ------------------------- BEGIN: lists to maintain manually -------------------------

# Directories where Qt Creator can find QML files of Kirigami etc. on your system.
#   (This setting is cached in variable QML_IMPORT_DIR, see below. Delete
#   ${BUIL_DIR}/CMakeCache.txt to make make changes here effective.)
# list(APPEND QML_DIRS "/usr/lib/x86_64-linux-gnu/qt5/qml")
# list(APPEND KIRIGAMI_DIRS "/usr/lib/x86_64-linux-gnu/qt5/qml/org/kde/kirigami.2")

# Configuration Issues are Here
#list(APPEND ECM_MODULE_PATH "3rdparty/extra-cmake-modules/build")

#list(APPEND ECM_MODULE_PATH "/usr/share/ECM/cmake")
#list(APPEND KF5Kirigami2_PATH "/usr/lib/x86_64-linux-gnu/cmake/KF5Kirigami2")
#list(APPEND KF5I18n_PATH "/usr/lib/x86_64-linux-gnu/cmake/KF5I18n")

# ------------------------- END: lists to maintain ma/usr/lib/x86_64-linux-gnu/qt5/nually -------------------------

# Tell Qt Creator where to find QML files.
#   (The build process will work without this, but no code completion etc..)
set(
    QML_IMPORT_PATH "${QML_DIRS}"
    QML_IMPORT_PATH "${KIRIGAMI_DIRS}"
    CACHE STRING "Qt Creator 4.1 extra qml import paths"
)

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
include(FeatureSummary)

find_package(Qt5 ${QT5_MIN_VERSION} REQUIRED COMPONENTS
    Core
    # Test
    Qml
    Gui
    Quick
    QuickControls2
    Widgets
)
find_package(KF5 ${KF_MIN_VERSION} REQUIRED COMPONENTS
    Kirigami2
    I18n
    CoreAddons
    IconThemes
)
#find_package(KF5CoreAddons)
#find_package(KF5I18n NO_MODULE)
#find_package(KF5Kirigami2)

#add_subdirectory("3rdparty/extra-cmake-modules" build/ecm)
#add_subdirectory("3rdparty/kirigami" build/kirigami)
#add_subdirectory("3rdparty/ki18n" build/ki18n)
#add_subdirectory("3rdparty/breeze-icons" build/icons)
#add_subdirectory("3rdparty/calligra/filters/libmsooxml" build/libmsooxml)

add_subdirectory(src build)
ki18n_install(po)

set(ICONS_FOLDER ${CMAKE_CURRENT_SOURCE_DIR}/icons)
set(ICON_FILES
  ${ICONS_FOLDER}/logo.svg
  ${ICONS_FOLDER}/logo.png
)
ecm_add_app_icon(qprompt ICONS ${ICON_FILES})
target_sources(qprompt PRIVATE ${ICONS_SOURCES})

install(PROGRAMS com.cuperino.qprompt.desktop DESTINATION ${KDE_INSTALL_APPDIR})
install(FILES com.cuperino.qprompt.appdata.xml DESTINATION ${KDE_INSTALL_METAINFODIR})
install(FILES images/logo.png DESTINATION ${KDE_INSTALL_FULL_ICONDIR}/hicolor/scalable/apps)

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)
