#**************************************************************************
#
# QPrompt
# Copyright (C) 2020-2021 Javier O. Cordero Pérez
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


cmake_minimum_required(VERSION 3.16)

set(RELEASE_SERVICE_VERSION_MAJOR "1")
set(RELEASE_SERVICE_VERSION_MINOR "1")
set(RELEASE_SERVICE_VERSION_MICRO "0")
set(RELEASE_SERVICE_VERSION "${RELEASE_SERVICE_VERSION_MAJOR}.${RELEASE_SERVICE_VERSION_MINOR}.${RELEASE_SERVICE_VERSION_MICRO}")
project(qprompt VERSION ${RELEASE_SERVICE_VERSION})

# Find includes in corresponding build directories
set(CMAKE_INCLUDE_CURRENT_DIR ON)
# Instruct CMake to create code from Qt designer ui files
set(CMAKE_AUTOUIC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 17)
#set(CMAKE_CXX_STANDARD 20)
# Instruct CMake to run moc automatically when needed.
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

# QT 5.12 for Ubuntu 20.04
#set(QT_MIN_VERSION 5.12.0)
set(QT_MIN_VERSION 5.15.2)
#set(QT_DISABLE_DEPRECATED_BEFORE 5.15.2)
# KF5 5.68 for Ubuntu 20.04
# Use 5.83 to have current ecm_add_app_icon syntax
if (WIN32)
    set(ECM_MIN_VERSION 5.83.0)
else()
    set(ECM_MIN_VERSION 5.68.0)
endif()
set(KF_MIN_VERSION 5.68.0)

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
# ------------------------- END: lists to maintain manually -------------------------

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

if(ANDROID)
    set(ANDROID_PACKAGE_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/android)
	if(NOT ANDROID_ABIS)
		set(ANDROID_ABIS "armeabi-v7a") # arm64-v8a
	endif()
else()
set(DBINARY_ICONS_RESOURCE ON)
endif()

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "MinSizeRel")
endif()

# Send compiled program and library binaries to "build/bin"
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

find_package(ECM ${ECM_MIN_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})
if(ANDROID)
    find_package(Qt5 ${QT5_MIN_VERSION} REQUIRED NO_MODULE COMPONENTS
        Core
        Quick
        Svg
        Gui
        QuickControls2
        Network
        AndroidExtras
        VirtualKeyboard
        QmlImportScanner  # Used to get static QML. Gets ignored if not a static build
        QuickCompiler
    )
    find_package(KF5 ${KF_MIN_VERSION} REQUIRED COMPONENTS
        Kirigami2
        I18n  # NO_MODULE
        CoreAddons
    )
elseif(WASM OR IOS)
    find_package(Qt5 ${QT5_MIN_VERSION} REQUIRED NO_MODULE COMPONENTS
        Core
        Quick
        Svg
        Gui
        QuickControls2
        #QmlImportScanner  # Used to get static QML. Gets ignored if not a static build
        #QuickCompiler
    )
    find_package(KF5 ${KF_MIN_VERSION} REQUIRED COMPONENTS
        Kirigami2
        I18n  # NO_MODULE
        CoreAddons
    )
else()
    find_package(Qt5 ${QT5_MIN_VERSION} REQUIRED NO_MODULE COMPONENTS
        Core
        Quick
        Svg
        Gui
        QuickControls2
        Network
        Widgets
    )
    find_package(Qt5 ${QT5_MIN_VERSION} NO_MODULE COMPONENTS
        QmlImportScanner  # Used to get static QML. Gets ignored if not a static build
        QuickCompiler
    )
    find_package(KF5 ${KF_MIN_VERSION} REQUIRED COMPONENTS
        Kirigami2
        I18n  # NO_MODULE
        CoreAddons
        IconThemes
    )
endif()


if (WIN32 OR UNIX) # AND NOT ANDROID
    include(KDEInstallDirs)
    include(KDECMakeSettings)
    include(ECMInstallIcons)
    include(ECMAddAppIcon)
endif()
include(KDECompilerSettings NO_POLICY_SCOPE)
include(KDEClangFormat)
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
    add_definitions(-DGIT_BRANCH="Stable")
endif()

ecm_setup_version(${RELEASE_SERVICE_VERSION}
    VARIABLE_PREFIX QPROMPT
    VERSION_HEADER "${CMAKE_CURRENT_BINARY_DIR}/qprompt_version.h"
)

# LICENSING
set(LICENSE_FILE "COPYING")
set(README_FILE "README.md")
set(DESCRIPTION_FILE "DESCRIPTION.txt")
list(APPEND DOCS ${LICENSE_FILE} ${README_FILE} ${DESCRIPTION_FILE} "COPYING.LESSER")

set(DOC_INSTALL_DIR "doc/qprompt")

#add_subdirectory(locale)
add_subdirectory(src build)

if (WIN32 OR UNIX) # AND NOT ANDROID
    install(FILES com.cuperino.qprompt.appdata.xml DESTINATION ${KDE_INSTALL_METAINFODIR})
    install(PROGRAMS com.cuperino.qprompt.desktop DESTINATION ${KDE_INSTALL_APPDIR})
    install(FILES ${DOCS} DESTINATION ${DOC_INSTALL_DIR})
endif()

ki18n_install(po)

# CPACK: General Settings
set(CPACK_GENERATOR "TBZ2")
set(CPACK_PACKAGE_NAME "qprompt")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Personal Teleprompter App")

set(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_SOURCE_DIR}/${DESCRIPTION_FILE}")
set(CPACK_PACKAGE_VENDOR "Cuperino LLC")
set(CPACK_PACKAGE_CONTACT "javiercorderoperez@gmail.com")
set(CPACK_PACKAGE_VERSION_MAJOR "${RELEASE_SERVICE_VERSION_MAJOR}")
set(CPACK_PACKAGE_VERSION_MINOR "${RELEASE_SERVICE_VERSION_MINOR}")
set(CPACK_PACKAGE_VERSION_PATCH "${RELEASE_SERVICE_VERSION_MICRO}")
set(CPACK_PACKAGE_VERSION "${RELEASE_SERVICE_VERSION}")
set(CPACK_RESOURCE_FILE_README "${CMAKE_SOURCE_DIR}/${README_FILE}")

set(ICONS_DIR "${CMAKE_SOURCE_DIR}/icons")
set(IMAGES_DIR "${CMAKE_SOURCE_DIR}/images")
set(PROJECT_URL "https://qprompt.app")
set(COMPRESION_TYPE "xz")

if(UNIX AND NOT ANDROID)
    # CPACK: DEB Specific Settings
    set(CPACK_DEBIAN_PACKAGE_SECTION "Multimedia")
    set(CPACK_DEBIAN_PACKAGE_HOMEPAGE ${PROJECT_URL})
    set(CPACK_DEBIAN_COMPRESSION_TYPE ${COMPRESION_TYPE})
    # Set to dependencies as Ubuntu 21.04. Chose Ubuntu 21.04 as base because Desktop version has ARM support and provided Qt version requires no backporting.
    set(CPACK_DEBIAN_PACKAGE_DEPENDS "libqt5svg5 (>= 5.15.2), qml-module-qt-labs-platform (>=5.15.2), qml-module-qtqml (>=5.15.2), qml-module-qtqml-models2 (>=5.15.2), qml-module-qtqml-statemachine (>=5.15.2), qml-module-qtquick-controls (>=5.15.2), qml-module-qtquick-controls2 (>=5.15.2), qml-module-qtquick-dialogs (>=5.15.2), qml-module-qtquick-shapes (>=5.15.2), qml-module-org-kde-kirigami2 (>=5.78.0), libkf5i18n5 (>= 5.78.0), libkf5coreaddons5 (>= 5.78.0)")

    # CPACK: RPM Specific Settings
    set(CPACK_RPM_PACKAGE_LICENSE "GPLv3")
    set(CPACK_RPM_PACKAGE_GROUP "Multimedia/Video")
    set(CPACK_RPM_PACKAGE_URL ${PROJECT_URL})
    set(CPACK_RPM_COMPRESSION_TYPE ${COMPRESION_TYPE})
    set(CPACK_RPM_PACKAGE_REQUIRES "qt5-qtbase >= 5.15.2, qt5-qtbase-gui >= 5.15.2, qt5-qtdeclarative >= 5.15.2, qt5-qtsvg >= 5.15.2, qt5-qtquickcontrols >= 5.15.2, qt5-qtquickcontrols2 >= 5.15.2, kf5-ki18n >= 5.73.0, kf5-kirigami2 >= 5.73.0, kf5-kcoreaddons >= 5.73.0")

    set(CPACK_SYSTEM_NAME "${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_PROCESSOR}")

elseif(WIN32)
    set(CPACK_GENERATOR "NSIS")
    set(CPACK_PACKAGE_EXECUTABLES "QPrompt" "QPrompt")
    set(CPACK_NSIS_BRANDING_TEXT "QPrompt Teleprompter App")
    set(CPACK_PACKAGE_FILE_NAME "QPrompt ${RELEASE_SERVICE_VERSION}")
    set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_SOURCE_DIR}/${LICENSE_FILE}")
    set(CPACK_NSIS_EXECUTABLES_DIRECTORY "${BIN_INSTALL_DIR}")
    set(CPACK_NSIS_MUI_ICON "${ICONS_DIR}/qprompt.ico")
    set(CPACK_PACKAGE_ICON "${IMAGES_DIR}/installer.bmp")
    set(CPACK_NSIS_MUI_WELCOMEFINISHPAGE_BITMAP "${IMAGES_DIR}/welcome.bmp")
    set(CPACK_NSIS_MUI_UNWELCOMEFINISHPAGE_BITMAP "${IMAGES_DIR}/welcome.bmp")
    set(CPACK_NSIS_MUI_HEADERIMAGE "${IMAGES_DIR}/header.bmp")
    set(CPACK_NSIS_CONTACT ${CPACK_PACKAGE_CONTACT})

    set(CPACK_NSIS_URL_INFO_ABOUT ${PROJECT_URL})
    set(CPACK_NSIS_INSTALLED_ICON_NAME "qprompt${CMAKE_EXECUTABLE_SUFFIX}")
    set(CPACK_NSIS_MENU_LINKS
        "${LICENSE_FILE}" "License"
        "${README_FILE}" "Readme"
    )
    set(CPACK_NSIS_MUI_FINISHPAGE_RUN "${CPACK_NSIS_INSTALLED_ICON_NAME}")

elseif(APPLE AND NOT IOS)
    set(CPACK_GENERATOR "DragNDrop")
    set(CPACK_DMG_FORMAT "UDBZ")
    set(CPACK_DMG_VOLUME_NAME "QPrompt")
    set(CPACK_SYSTEM_NAME "OSX")
    set(CPACK_PACKAGE_FILE_NAME "QPrompt-${RELEASE_SERVICE_VERSION}")
    set(CPACK_PACKAGE_ICON "${ICONS_DIR}/qprompt.icns")
    #set(CPACK_DMG_DS_STORE "${IMAGES_DIR}/DSStore")
    set(CPACK_DMG_BACKGROUND_IMAGE "${IMAGES_DIR}/DMGBackground.png")
endif()

include(CPack)

feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES) # INCLUDE_QUIET_PACKAGES

file(GLOB_RECURSE ALL_CLANG_FORMAT_SOURCE_FILES *.cpp *.h *.hpp)
kde_clang_format(${ALL_CLANG_FORMAT_SOURCE_FILES})
