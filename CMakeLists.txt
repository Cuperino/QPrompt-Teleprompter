#**************************************************************************
#
# QPrompt
# Copyright (C) 2020-2022 Javier O. Cordero Pérez
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
set(RELEASE_SERVICE_VERSION_MICRO "5")
set(RELEASE_SERVICE_VERSION "${RELEASE_SERVICE_VERSION_MAJOR}.${RELEASE_SERVICE_VERSION_MINOR}.${RELEASE_SERVICE_VERSION_MICRO}")

project(qprompt
    VERSION ${RELEASE_SERVICE_VERSION}
    DESCRIPTION "Teleprompter software for all video creators"
    HOMEPAGE_URL "https://qprompt.app/"
    LANGUAGES CXX)

# Find includes in corresponding build directories
set(CMAKE_INCLUDE_CURRENT_DIR ON)
# Instruct CMake to create code from Qt designer ui files
set(CMAKE_AUTOUIC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
# Leave C++ standard at version 17 to build Ubuntu 18.04 compatible AppImage
set(CMAKE_CXX_STANDARD 17)
# Instruct CMake to run moc automatically when needed
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(QT_DEFAULT_MAJOR_VERSION 5)
set(QT_MIN_VERSION 5.15.2)
# KF5 5.78 for Ubuntu 21.04 and Debian 11, which require no backporting
# KF5 5.68 is used as a hack to allow Snapcraft build on Ubuntu 20.04 core
# Use 5.83 ECM on Windows to make use of ecm_add_app_icon syntax
if (WIN32)
    set(ECM_MIN_VERSION 5.83.0)
else()
    set(ECM_MIN_VERSION 5.68.0)
endif()
set(KF_MIN_VERSION 5.68.0)
if (APPLE)
    set(APPLE_SUPPRESS_X11_WARNING ON)
endif()
# ------------------------- BEGIN: lists to maintain manually -------------------------

# Directories where Qt Creator can find QML files of Kirigami etc. on your system.
#   (This setting is cached in variable QML_IMPORT_DIR, see below. Delete
#   ${BUIL_DIR}/CMakeCache.txt to make make changes here effective.)
if (UNIX AND NOT APPLE AND NOT ANDROID)
    list(APPEND QML_DIRS "/usr/lib/x86_64-linux-gnu/qt5/qml")
    list(APPEND KIRIGAMI_DIRS "/usr/lib/x86_64-linux-gnu/qt5/qml/org/kde/kirigami.2")
elseif (UNIX AND APPLE)
    list(APPEND QML_DIRS "/opt/homebrew/lib/qml")
    list(APPEND KIRIGAMI_DIRS "/opt/homebrew/lib/qml/org/kde/kirigami.2")
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
		set(ANDROID_ABIS "arm64-v8a") # armeabi-v7a
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
find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Core)


find_package(Git QUIET)
if(GIT_FOUND AND EXISTS "${PROJECT_SOURCE_DIR}/.git")
    option(GIT_SUBMODULE "Check submodules during build" ON)
    if(GIT_SUBMODULE)
        message(STATUS "Updating submodules")
        execute_process(COMMAND ${GIT_EXECUTABLE} submodule update --init --recursive
                        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                        RESULT_VARIABLE GIT_SUBMOD_RESULT)
        if(NOT GIT_SUBMOD_RESULT EQUAL "0")
            message(FATAL_ERROR "git submodule update --init failed with ${GIT_SUBMOD_RESULT}, please checkout submodules.")
        endif()
    endif()
endif()


if(ANDROID)
    find_package(Qt${QT_VERSION_MAJOR} ${QT5_MIN_VERSION} REQUIRED NO_MODULE COMPONENTS
        Core
        Quick
        Svg
        Gui
        QuickControls2
        Network
        AndroidExtras
        QmlImportScanner  # Used to get static QML. Gets ignored if not a static build
        QuickCompiler
    )
    find_package(KF5 ${KF_MIN_VERSION} REQUIRED COMPONENTS
        Kirigami2
        I18n
        CoreAddons
    )
elseif(WASM OR IOS)
    find_package(Qt${QT_VERSION_MAJOR} ${QT5_MIN_VERSION} REQUIRED NO_MODULE COMPONENTS
        Core
        Quick
        Svg
        Gui
        QuickControls2
        Network
        QmlImportScanner  # Used to get static QML. Gets ignored if not a static build
        QuickCompiler
    )
    find_package(KF5 ${KF_MIN_VERSION} REQUIRED COMPONENTS
        Kirigami2
        I18n
        CoreAddons
    )
elseif(HAIKU)
    find_package(Qt${QT_VERSION_MAJOR} ${QT5_MIN_VERSION} REQUIRED NO_MODULE COMPONENTS
        Core
        Quick
        Svg
        Gui
        QuickControls2
        Network
        Widgets
    )
    # By requiring newer Qt version to use QML compiler, Snap can be built without it.
    find_package(Qt${QT_VERSION_MAJOR} ${QT5_MIN_VERSION} NO_MODULE COMPONENTS
        QmlImportScanner  # Used to get static QML. Gets ignored if not a static build
        QuickCompiler
    )
    find_package(KF5 ${KF_MIN_VERSION} REQUIRED COMPONENTS
        Kirigami2
        I18n
        CoreAddons
        IconThemes
    )
    find_package(KF5Crash ${REQUIRED_KF5_VERSION} CONFIG QUIET)
        set_package_properties(KF5Crash PROPERTIES
        DESCRIPTION "Graceful handling of application crashes."
        TYPE OPTIONAL
    )
elseif(WIN32 OR APPLE)
    find_package(Qt${QT_VERSION_MAJOR} ${QT5_MIN_VERSION} REQUIRED NO_MODULE COMPONENTS
        Core
        Quick
        Svg
        Gui
        QuickControls2
        Network
        Widgets
        QmlImportScanner  # Used to get static QML. Gets ignored if not a static build
        QuickCompiler
    )
    find_package(KF5 ${KF_MIN_VERSION} REQUIRED COMPONENTS
        Kirigami2
        I18n
        CoreAddons
    )
    find_package(KF5Crash ${KF_MIN_VERSION} COMPONENTS)
    set_package_properties(KF5Crash PROPERTIES
        DESCRIPTION "Graceful handling of application crashes."
        TYPE OPTIONAL
    )
    find_package(QHotkey 1.5.0 COMPONENTS
        QHotkey
    )
    # KDMacTouchBar (Mac only)
    if(APPLE AND NOT IOS)
        if (NOT EXISTS "${PROJECT_SOURCE_DIR}/3rdparty/KDMacTouchBar/CMakeLists.txt")
            message(FATAL_ERROR "KDMacTouchBar was not downloaded. GIT_SUBMODULE was turned off or failed.")
        endif()
        add_subdirectory("3rdparty/KDMacTouchBar" build/kdmactouchbar)
    endif()
else()
    find_package(Qt${QT_VERSION_MAJOR} ${QT5_MIN_VERSION} REQUIRED NO_MODULE COMPONENTS
        Core
        Quick
        Svg
        Gui
        QuickControls2
        Network
        Widgets
        X11Extras
    )
    #find_package(Qt${QT_VERSION_MAJOR} ${QT5_MIN_VERSION} NO_MODULE COMPONENTS
        #QmlImportScanner  # Used to get static QML. Gets ignored if not a static build
        #QuickCompiler
    #)
    find_package(KF5 ${KF_MIN_VERSION} REQUIRED COMPONENTS
        Kirigami2
        I18n
        CoreAddons
        IconThemes
    )
    find_package(KF5Crash ${REQUIRED_KF5_VERSION} COMPONENTS)
    set_package_properties(KF5Crash PROPERTIES
        DESCRIPTION "Graceful handling of application crashes."
        TYPE OPTIONAL
    )
    find_package(QHotkey 1.5.0 COMPONENTS
        QHotkey
    )
endif()

if (WIN32 OR UNIX) # AND NOT ANDROID
    include(KDEInstallDirs)
    include(KDECMakeSettings)
    include(ECMInstallIcons)
    include(ECMAddAppIcon)
    include(ECMGenerateHeaders)
endif()
include(KDECompilerSettings NO_POLICY_SCOPE)
include(KDEClangFormat)
include(ECMQtDeclareLoggingCategory)
include(ECMSetupVersion)
include(ECMSourceVersionControl)
include(ECMPoQmTools)
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
    add_definitions(-DGIT_COMMIT_HASH="${PROJECT_VERSION}")
    add_definitions(-DGIT_BRANCH="Stable")
endif()

ecm_setup_version(${PROJECT_VERSION}
    VARIABLE_PREFIX QPROMPT
    VERSION_HEADER "${CMAKE_CURRENT_BINARY_DIR}/qprompt_version.h"
)

# LICENSING
set(LICENSE_FILE "COPYING")
set(README_FILE "README.md")
set(DESCRIPTION_FILE "DESCRIPTION.txt")
list(APPEND DOCS ${LICENSE_FILE} ${README_FILE} ${DESCRIPTION_FILE} "COPYING.ASSETS")

set(DOC_INSTALL_DIR "doc/qprompt")

add_subdirectory(src build)
ki18n_install(po)

if (ANDROID)
    configure_file(${ANDROID_PACKAGE_SOURCE_DIR}/version.gradle.in ${CMAKE_BINARY_DIR}/version.gradle)
endif()

if (WIN32 OR UNIX) # AND NOT ANDROID
    install(FILES com.cuperino.qprompt.appdata.xml DESTINATION ${KDE_INSTALL_METAINFODIR})
    install(PROGRAMS com.cuperino.qprompt.desktop DESTINATION ${KDE_INSTALL_APPDIR})
    install(FILES ${DOCS} DESTINATION ${DOC_INSTALL_DIR})
endif()

# CPACK: General Settings
set(CPACK_GENERATOR "DEB")
set(CPACK_PACKAGE_VENDOR "Javier O. Cordero Pérez")
set(CPACK_PACKAGE_CONTACT "javiercorderoperez@gmail.com")
set(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_SOURCE_DIR}/${DESCRIPTION_FILE}")
set(CPACK_RESOURCE_FILE_README "${CMAKE_SOURCE_DIR}/${README_FILE}")

set(ICONS_DIR "${CMAKE_SOURCE_DIR}/icons")
set(IMAGES_DIR "${CMAKE_SOURCE_DIR}/images")
set(COMPRESION_TYPE "xz")

if(UNIX AND NOT ANDROID)
    # CPACK: DEB Specific Settings
    set(CPACK_DEBIAN_PACKAGE_SECTION "Multimedia")
    set(CPACK_DEBIAN_COMPRESSION_TYPE ${COMPRESION_TYPE})
    # Set to dependencies as Debian 11 and Ubuntu 21.04. Chose these two distros as base because Desktop version has ARM support and provided Qt versions require no backporting.
    set(CPACK_DEBIAN_PACKAGE_DEPENDS "libqt5svg5 (>= 5.15.2), libqt5x11extras5 (>= 5.15.2), qml-module-qt-labs-platform (>=5.15.2), qml-module-qtqml (>=5.15.2), qml-module-qtqml-models2 (>=5.15.2), qml-module-qtqml-statemachine (>=5.15.2), qml-module-qtquick-controls (>=5.15.2), qml-module-qtquick-controls2 (>=5.15.2), qml-module-qtquick-dialogs (>=5.15.2), qml-module-qtquick-shapes (>=5.15.2), qml-module-org-kde-kirigami2 (>=5.78.0), libkf5i18n5 (>= 5.78.0), libkf5coreaddons5 (>= 5.78.0), libkf5crash5 (>= 5.78.0)")

    # CPACK: RPM Specific Settings
    set(CPACK_RPM_PACKAGE_LICENSE "GPLv3")
    set(CPACK_RPM_PACKAGE_GROUP "Multimedia/Video")
    set(CPACK_RPM_PACKAGE_REQUIRES "qt5-qtbase >= 5.15.2, qt5-qtx11extras >= 5.15.2, qt5-qtbase-gui >= 5.15.2, qt5-qtdeclarative >= 5.15.2, qt5-qtsvg >= 5.15.2, qt5-qtquickcontrols >= 5.15.2, qt5-qtquickcontrols2 >= 5.15.2, kf5-ki18n >= 5.73.0, kf5-kirigami2 >= 5.73.0, kf5-kcoreaddons >= 5.73.0, kf5-kcrash >= 5.73.0")
    set(CPACK_RPM_COMPRESSION_TYPE ${COMPRESION_TYPE})

elseif(WIN32)
    set(CPACK_GENERATOR "NSIS")
    set(CPACK_PACKAGE_EXECUTABLES "QPrompt" "QPrompt")
    set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_SOURCE_DIR}/${LICENSE_FILE}")
    set(CPACK_NSIS_EXECUTABLES_DIRECTORY "${BIN_INSTALL_DIR}")
    set(CPACK_NSIS_MUI_ICON "${ICONS_DIR}/qprompt.ico")
    set(CPACK_PACKAGE_ICON "${IMAGES_DIR}/installer.bmp")
    set(CPACK_NSIS_MUI_WELCOMEFINISHPAGE_BITMAP "${IMAGES_DIR}/welcome.bmp")
    set(CPACK_NSIS_MUI_UNWELCOMEFINISHPAGE_BITMAP "${IMAGES_DIR}/welcome.bmp")
    set(CPACK_NSIS_MUI_HEADERIMAGE "${IMAGES_DIR}/header.bmp")
    set(CPACK_NSIS_CONTACT ${CPACK_PACKAGE_CONTACT})
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
    set(CPACK_PACKAGE_FILE_NAME "QPrompt-${PROJECT_VERSION}")
    set(CPACK_PACKAGE_ICON "${ICONS_DIR}/qprompt.icns")
    #set(CPACK_DMG_DS_STORE "${IMAGES_DIR}/DSStore")
    set(CPACK_DMG_BACKGROUND_IMAGE "${IMAGES_DIR}/DMGBackground.png")
endif()

include(CPack)

feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES) # INCLUDE_QUIET_PACKAGES

file(GLOB_RECURSE ALL_CLANG_FORMAT_SOURCE_FILES *.cpp *.h *.hpp)
kde_clang_format(${ALL_CLANG_FORMAT_SOURCE_FILES})
