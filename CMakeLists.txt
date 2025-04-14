#**************************************************************************
#
# QPrompt
# Copyright (C) 2020-2025 Javier O. Cordero Pérez
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


cmake_minimum_required(VERSION 3.22)

include(FetchContent)

set(RELEASE_SERVICE_VERSION_MAJOR "2")
set(RELEASE_SERVICE_VERSION_MINOR "0")
set(RELEASE_SERVICE_VERSION_MICRO "0")
set(RELEASE_SERVICE_VERSION "${RELEASE_SERVICE_VERSION_MAJOR}.${RELEASE_SERVICE_VERSION_MINOR}.${RELEASE_SERVICE_VERSION_MICRO}")

project(qprompt
    VERSION ${RELEASE_SERVICE_VERSION}
    DESCRIPTION "Teleprompter software for all video creators"
    HOMEPAGE_URL "https://qprompt.app/"
    LANGUAGES CXX)

set(WASM ON)
set(KF_IGNORE_PLATFORM_CHECK ON)

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

set(QT_DEFAULT_MAJOR_VERSION 6)
# Qt 6.6.2 for Ubuntu 24.10, tho ideally we'd use 6.7.2.
set(QT_MIN_VERSION 6.6.2)
# Enabling newer ECM appears to break AutoMOC...
if (WIN32)
    set(ECM_MIN_VERSION 5.83.0)
else()
    set(ECM_MIN_VERSION 5.68.0)
endif()
# All other KF should go with the latest versions
set(KF_MIN_VERSION 6.5.0)
set(KF_PREFFERED_VERSION 6.8.0)
if (APPLE)
    set(APPLE_SUPPRESS_X11_WARNING ON)
endif()
# ------------------------- BEGIN: lists to maintain manually -------------------------
# Directories where Qt Creator can find modules and Kirigami's QML files
list(APPEND QML_DIRS "build/dist/lib/x86_64-linux-gnu/qml")
list(APPEND KIRIGAMI_DIRS "build/dist/lib/x86_64-linux-gnu/qml/org/kde/kirigami")
# Directories where Qt Creator can find these files on your system.
#   (This setting is cached in variable QML_IMPORT_DIR, see below. Delete
#   ${BUIL_DIR}/CMakeCache.txt to make make changes here effective.)
if (UNIX AND NOT APPLE AND NOT ANDROID)
    list(APPEND QML_DIRS "/usr/lib/x86_64-linux-gnu/qt6/qml")
    list(APPEND KIRIGAMI_DIRS "/usr/lib/x86_64-linux-gnu/qml/org/kde/kirigami")
elseif (UNIX AND APPLE)
    list(APPEND QML_DIRS "/opt/homebrew/lib/qml")
    list(APPEND KIRIGAMI_DIRS "/opt/homebrew/lib/qml/org/kde/kirigami")
elseif (WIN32)
    list(APPEND QML_DIRS "C:/CraftRoot/qml")
    list(APPEND KIRIGAMI_DIRS "C:/CraftRoot/qml/org/kde/kirigami")
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
    set(CMAKE_BUILD_TYPE "RelWithDebInfo")
endif()

list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")

# Send compiled program and library binaries to "build/bin"
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

find_package(ECM ${ECM_MIN_VERSION} REQUIRED NO_MODULE)
list(APPEND CMAKE_MODULE_PATH ${ECM_MODULE_PATH})
find_package(QT NAMES Qt6)

find_package(Git QUIET)
if(GIT_FOUND AND EXISTS "${PROJECT_SOURCE_DIR}/.git")
    option(GIT_SUBMODULE "Check submodules during build" ON)
    if(GIT_SUBMODULE)
        message(STATUS "Updating submodules")
        execute_process(COMMAND ${GIT_EXECUTABLE} submodule update --init --recursive
                        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                        RESULT_VARIABLE GIT_SUBMOD_RESULT)
    endif()
endif()

# Common dependencices
find_package(Qt${QT_VERSION_MAJOR} ${QT_MIN_VERSION} REQUIRED NO_MODULE COMPONENTS
    Core
    Quick
    Svg
    Gui
    QuickControls2
    Network
    ShaderTools
    LinguistTools
)

if(ANDROID OR IOS OR WASM)
    set(BUILD_SHARED_LIBS OFF)
endif()

if(WIN32 OR APPLE OR WASM)
    set(BUILD_TESTING OFF)
    if(NOT WASM)
        FetchContent_Declare(
          CoreAddons
          GIT_REPOSITORY "${CMAKE_SOURCE_DIR}/3rdparty/kcoreaddons"
          GIT_TAG        "v${KF_PREFFERED_VERSION}"
          SOURCE_DIR submodules/kcoreaddons
        )
        FetchContent_MakeAvailable(CoreAddons)
    endif()
    FetchContent_Declare(
      Kirigami
      GIT_REPOSITORY "${CMAKE_SOURCE_DIR}/3rdparty/kirigami"
      GIT_TAG        "v${KF_PREFFERED_VERSION}"
      SOURCE_DIR submodules/kirigami
    )
    FetchContent_MakeAvailable(Kirigami)
else()
    find_package(KF${QT_VERSION_MAJOR} ${KF_MIN_VERSION} REQUIRED COMPONENTS
        Kirigami
        CoreAddons
    )
endif()

if(NOT ANDROID AND NOT IOS AND NOT WASM)
    if(NOT BSD)
        set(BUILD_SHARED_LIBS ON)
        FetchContent_Declare(
          QHotkey
          GIT_REPOSITORY "${CMAKE_SOURCE_DIR}/3rdparty/QHotkey"
          GIT_TAG        "1231c4cc9649ec0132d939cb7e139a82b8edeca0"
          SOURCE_DIR submodules/QHotkey
        )
        FetchContent_MakeAvailable(QHotkey)
    else()
        find_package(QHotkey)
    endif()
endif()
# Desktop only dependencies
if(NOT ANDROID AND NOT IOS AND NOT WASM)
    find_package(Qt${QT_VERSION_MAJOR} ${QT_MIN_VERSION} REQUIRED NO_MODULE COMPONENTS
        Widgets
    )
endif()
# Platform specific dependencies
if(ANDROID)
    find_package(Qt${QT_VERSION_MAJOR} ${QT_MIN_VERSION} REQUIRED NO_MODULE COMPONENTS
        AndroidExtras
    )
elseif(HAIKU)
    # Haiku OS icons look nice
    find_package(KF${QT_VERSION_MAJOR} ${KF_MIN_VERSION} REQUIRED COMPONENTS
        IconThemes
    )
    find_package(KF${QT_VERSION_MAJOR}Crash ${REQUIRED_KF${QT_VERSION_MAJOR}_VERSION} CONFIG QUIET)
        set_package_properties(KF${QT_VERSION_MAJOR}Crash PROPERTIES
        DESCRIPTION "Graceful handling of application crashes."
        TYPE OPTIONAL
    )
# Windows, MacOS, and FreeBSD
else()
    find_package(KF${QT_VERSION_MAJOR}Crash ${REQUIRED_KF${QT_VERSION_MAJOR}_VERSION} COMPONENTS)
    set_package_properties(KF${QT_VERSION_MAJOR}Crash PROPERTIES
        DESCRIPTION "Graceful handling of application crashes."
        TYPE OPTIONAL
    )
    # KDMacTouchBar (Mac only)
    if(APPLE AND NOT IOS)
        if (NOT EXISTS "${PROJECT_SOURCE_DIR}/3rdparty/KDMacTouchBar/CMakeLists.txt")
            message(FATAL_ERROR "KDMacTouchBar was not downloaded. GIT_SUBMODULE was turned off or failed.")
        endif()
        # set(CMAKE_INSTALL_PREFIX ${PROJECT_SOURCE_DIR}/install/usr/)
        add_subdirectory("3rdparty/KDMacTouchBar" build/kdmactouchbar)
    endif()
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

set(DOC_INSTALL_DIR "share/doc/qprompt")

add_subdirectory(src build)

if (ANDROID)
    configure_file(${ANDROID_PACKAGE_SOURCE_DIR}/version.gradle.in ${CMAKE_BINARY_DIR}/version.gradle)
endif()

if (UNIX AND NOT APPLE AND NOT ANDROID)
    set(DOC_INSTALL_DIR "share/doc/qprompt")
    set(MAN_INSTALL_DIR "share/man/")
    install(FILES docs/manpage/qprompt.1 DESTINATION ${MAN_INSTALL_DIR}/man1)
endif()

if (WIN32 OR UNIX AND NOT APPLE) # AND NOT ANDROID
    install(FILES com.cuperino.qprompt.appdata.xml DESTINATION ${KDE_INSTALL_METAINFODIR})
    install(PROGRAMS com.cuperino.qprompt.desktop DESTINATION ${KDE_INSTALL_APPDIR})
    install(FILES ${DOCS} DESTINATION ${DOC_INSTALL_DIR})
endif()

if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
    # CPACK: General Settings
    set(CPACK_PACKAGE_VENDOR "Javier O. Cordero Pérez")
    set(CPACK_PACKAGE_CONTACT "javiercorderoperez@gmail.com")
    set(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_SOURCE_DIR}/${DESCRIPTION_FILE}")
    set(CPACK_RESOURCE_FILE_README "${CMAKE_SOURCE_DIR}/${README_FILE}")
    set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_SOURCE_DIR}/${LICENSE_FILE}")  # Displays the license on some installers
    set(CPACK_VERBATIM_VARIABLES On)
    set(CPACK_MONOLITHIC_INSTALL On)

    set(CPACK_RPM_PACKAGE_LICENSE "GPLv3")  # Also used by FreeBSD generator

    set(ICONS_DIR "${CMAKE_SOURCE_DIR}/src/icons")
    set(IMAGES_DIR "${CMAKE_SOURCE_DIR}/src/images")
    set(COMPRESION_TYPE "xz")

    # CPACK: Archive generator settings
    set(CPACK_THREADS 0)
    set(CPACK_ARCHIVE_THREADS 0)

    if(UNIX AND NOT ANDROID AND NOT APPLE)
        set(CPACK_GENERATOR "DEB")

        # CPACK: DEB specific settings
        set(CPACK_DEBIAN_PACKAGE_SECTION "Multimedia")
        set(CPACK_DEBIAN_COMPRESSION_TYPE ${COMPRESION_TYPE})
        set(CPACK_DEBIAN_PACKAGE_DEPENDS "libqt6svg6 (>= 6.6.2), libqt6qmlworkerscript6 (>=6.6.2), qml6-module-qt-labs-platform (>=6.6.2), qml6-module-qtqml (>=6.6.2), qml6-module-qtqml-models (>=6.6.2), qml6-module-qtqml-statemachine (>=6.6.2), qml6-module-qtquick-controls (>=6.6.2), qml6-module-qtquick-dialogs (>=6.6.2), qml6-module-qtquick-shapes (>=6.6.2), libkf6coreaddons6 (>= 6.5.0), libkirigami6 (>= 6.5.0), libkf6i18n6 (>= 6.5.0), libkf6crash6 (>= 6.5.0)")

        # CPACK: RPM specific settings
        set(CPACK_RPM_PACKAGE_GROUP "Multimedia/Video")
        set(CPACK_RPM_PACKAGE_REQUIRES "qt6-qtbase >= 6.7.2, qt6-qtbase-gui >= 6.7.2, qt6-qtdeclarative >= 6.7.2, qt6-qtsvg >= 6.7.2, qt6-qtquickcontrols >= 6.7.2, qt6-qtquickcontrols2 >= 6.7.2, kf6-kcoreaddons >= 6.5.0, kf6-kirigami >= 6.5.0, kf6-kcrash >= 6.5.0")
        set(CPACK_RPM_COMPRESSION_TYPE ${COMPRESION_TYPE})

    elseif(WIN32)
        set(CPACK_GENERATOR "NSIS")
        set(CPACK_PACKAGE_EXECUTABLES "QPrompt" "QPrompt")
        set(CPACK_RESOURCE_FILE_LICENSE ${CMAKE_SOURCE_DIR}/${LICENSE_FILE})
        set(CPACK_NSIS_EXECUTABLES_DIRECTORY ${BIN_INSTALL_DIR})
        set(CPACK_NSIS_MUI_ICON ${ICONS_DIR}/qprompt.ico)
        set(CPACK_NSIS_INSTALLED_ICON_NAME ${BIN_INSTALL_DIR}/QPrompt.exe)
        set(CPACK_NSIS_CONTACT ${CPACK_PACKAGE_CONTACT})
        set(CPACK_NSIS_INSTALLED_ICON_NAME "qprompt${CMAKE_EXECUTABLE_SUFFIX}")
        set(CPACK_NSIS_MENU_LINKS
            ${CMAKE_SOURCE_DIR}/${LICENSE_FILE} "License"
            ${CMAKE_SOURCE_DIR}/${README_FILE} "Readme"
        )
        set(CPACK_NSIS_MUI_FINISHPAGE_RUN "${CPACK_NSIS_INSTALLED_ICON_NAME}")
        set(InstallRequiredSystemLibraries On)

    elseif(APPLE AND NOT IOS)
        set(CPACK_GENERATOR "DragNDrop")
        set(CPACK_DMG_FORMAT "UDBZ")
        set(CPACK_DMG_VOLUME_NAME "QPrompt")
        set(CPACK_BUNDLE_NAME "QPrompt")
        set(CPACK_BUNDLE_ICON "${ICONS_DIR}/qprompt.icns")
        # set(CPACK_BUNDLE_PLIST "Info.plist")
        set(CPACK_SYSTEM_NAME "OSX")
        set(CPACK_PACKAGE_FILE_NAME "QPrompt-${PROJECT_VERSION}")
        set(CPACK_PACKAGE_ICON "${ICONS_DIR}/qprompt.icns")
        set(CPACK_DMG_SLA_USE_RESOURCE_FILE_LICENSE ${LICENSE_FILE})
        #set(CPACK_DMG_DS_STORE "${IMAGES_DIR}/DSStore")
        set(CPACK_DMG_BACKGROUND_IMAGE "${IMAGES_DIR}/DMGBackground.png")

    elseif(BSD AND NOT APPLE)
        set(CPACK_FREEBSD_PACKAGE_MAINTAINER ${CPACK_PACKAGE_CONTACT})
        set(CPACK_FREEBSD_PACKAGE_ORIGIN "multimedia")
        set(CPACK_FREEBSD_PACKAGE_CATEGORIES "devel/qt6-base, x11-toolkits/qt6-declarative, graphics/qt6-svg, x11-toolkits/qt6-shadertools, multimedia/qt6-multimedia, devel/kf6-kcoreaddons, x11-toolkits/kf6-kirigami, devel/kf6-kcrash, x11-themes/kf6-kiconthemes, x11-toolkits/qhotkey")
    endif()

    include(CPack)
endif()

if(NOT WASM)
    feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES) # INCLUDE_QUIET_PACKAGES
endif()

file(GLOB_RECURSE ALL_CLANG_FORMAT_SOURCE_FILES *.cpp *.h *.hpp)
kde_clang_format(${ALL_CLANG_FORMAT_SOURCE_FILES})
