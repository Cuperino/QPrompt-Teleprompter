#**************************************************************************
#
# QPrompt
# Copyright (C) 2020-2026 Javier O. Cordero Pérez
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
set(RELEASE_SERVICE_VERSION_MINOR "1")
set(RELEASE_SERVICE_VERSION_MICRO "0")
set(RELEASE_SERVICE_VERSION "${RELEASE_SERVICE_VERSION_MAJOR}.${RELEASE_SERVICE_VERSION_MINOR}.${RELEASE_SERVICE_VERSION_MICRO}")

project(qprompt
    VERSION ${RELEASE_SERVICE_VERSION}
    DESCRIPTION "Teleprompter software for all video creators"
    HOMEPAGE_URL "https://qprompt.app/"
    LANGUAGES CXX)

option(WASM OFF)
option(USE_GIT_DEPENDENCIES_ONLY OFF)
option(SOURCE_DEPENDENCIES_EXCLUSIVELY_FROM_SYSTEM OFF)  # Used only on Linux builds for now
option(QPROMPT_BUILD_TESTS "Build QPrompt unit tests" OFF)

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
# KDE Frameworks 6.24 (the last release supporting Qt 6.8; 6.25+ require Qt 6.9)
# needs at least Qt 6.8.0. We pin the floor to 6.8.2 to match the Qt that Debian
# ships, keeping the frameworks on the 6.8.x series so the Linux packages build.
set(QT_MIN_VERSION 6.8.2)
# Enabling newer ECM appears to break AutoMOC...
if (WIN32)
    set(ECM_MIN_VERSION 5.83.0)
else()
    set(ECM_MIN_VERSION 5.68.0)
endif()
# Version with minimum required set of features
set(KF_MIN_VERSION 6.9.0)
# Last version known to work. 6.24 is the newest KDE Frameworks release that
# still builds against Qt 6.8; 6.25+ require Qt 6.9.
set(KF_PREFFERED_VERSION 6.24.0)
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
    WebSockets
    ShaderTools
    LinguistTools
)

# Voice following remains buildable without microphone support on platforms
# where Qt Multimedia is unavailable. The QML session reports that condition
# instead of making the entire application fail configuration.
find_package(Qt${QT_VERSION_MAJOR} ${QT_MIN_VERSION} QUIET NO_MODULE COMPONENTS Multimedia)

if(ANDROID OR IOS OR WASM)
    # A plain set() here isn't enough: Qt's own toolchain/CMake package
    # machinery forces a BUILD_SHARED_LIBS cache entry of its own earlier in
    # configuration, and a cache write silently drops any same-named normal
    # variable already in scope. KCoreAddons' add_library(KF6CoreAddons)
    # call has no explicit STATIC/SHARED keyword, so it just reads whatever
    # BUILD_SHARED_LIBS resolves to at that point - the surviving cache
    # value of TRUE - and produces a shared libKF6CoreAddons.*.dylib that
    # never gets embedded in the app bundle (no Frameworks dir is created
    # for it), crashing every launch with a dyld "Library not loaded" error
    # once installed on a real device. Force the cache entry instead so
    # nothing can silently resurrect it afterwards.
    set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
    set(DESKTOP_ENABLED OFF)
endif()

if(WIN32 OR APPLE OR ANDROID OR WASM OR USE_GIT_DEPENDENCIES_ONLY)
    set(BUILD_TESTING OFF)
    # KDE Frameworks 6.24 use C++20 (e.g. std::span in Kirigami's scenegraph).
    # QPrompt itself stays on C++17 (see CMAKE_CXX_STANDARD above) for broad
    # AppImage compatibility, so we raise the standard only for the bundled
    # frameworks built here and restore it right after. KDECompilerSettings only
    # defaults to C++20 when CMAKE_CXX_STANDARD is unset, so without this the
    # frameworks would inherit our 17 and fail to compile.
    set(CMAKE_CXX_STANDARD 20)
    # Both KCoreAddons and Kirigami unconditionally include ECMGenerateQDoc,
    # whose global targets collide when the frameworks share this build tree.
    # QPrompt does not build their API documentation, so use the existing no-op
    # shim for every bundled-framework build, not only WASM.
    list(PREPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/wasm-shims")

    # Emscripten isn't on KDE Frameworks' list of supported platforms, so its
    # platform check would abort configuration of the bundled frameworks. Bypass
    # it so both KCoreAddons and Kirigami can be built for WASM.
    if(WASM)
        set(KF_IGNORE_PLATFORM_CHECK ON)
        # KCoreAddons builds Shiboken/PySide Python bindings by default, which
        # are meaningless for a WASM target and require host-only Python
        # development packages. Force them off before the framework configures.
        set(BUILD_PYTHON_BINDINGS OFF CACHE BOOL "" FORCE)
        # Emscripten identifies as UNIX, so KCoreAddons would default USE_DBUS
        # ON and look for the Qt6DBus module, which Qt for WASM does not ship.
        set(USE_DBUS OFF CACHE BOOL "" FORCE)
        # KCoreAddons probes for dladdr() with check_symbol_exists(); on
        # Emscripten the probe fails and leaves HAVE_DLADDR empty, which makes
        # the framework's add_feature_info(dladdr ${HAVE_DLADDR} ...) call abort
        # with too few arguments. Seed the cache so the probe is skipped and the
        # value stays a defined boolean; dladdr-based libexec lookup has no
        # meaning on WASM anyway.
        set(HAVE_DLADDR 0 CACHE INTERNAL "")
    endif()
    FetchContent_Declare(
      CoreAddons
      GIT_REPOSITORY "${CMAKE_SOURCE_DIR}/3rdparty/kcoreaddons"
      GIT_TAG        "v${KF_PREFFERED_VERSION}"
      SOURCE_DIR submodules/kcoreaddons
    )
    FetchContent_MakeAvailable(CoreAddons)
    if(APPLE)
        # KCoreAddons' KDE-style build sets an absolute INSTALL_NAME_DIR (the
        # Linux/KDE convention). Left as-is, installing QPrompt alongside it
        # bakes that absolute path into QPrompt's own load commands instead
        # of the @rpath reference the macOS app bundle relies on to find its
        # bundled copy in Contents/Frameworks.
        set_target_properties(KF6CoreAddons PROPERTIES INSTALL_NAME_DIR "@rpath")
    endif()
    if(WASM)
        # Several KCoreAddons translation units cannot be built for Emscripten,
        # so drop them from the bundled library. None of these classes are used
        # by Kirigami or QPrompt (which only needs KAboutData), so removing their
        # sources leaves no unresolved references:
        #   * KSharedDataCache (kshareddatacache/ksdclock/ksdcmemory) relies on
        #     POSIX mmap()/mmap64(); Qt for WASM has no shared memory.
        #   * KProcess subclasses QProcess and KSandbox/KListOpenFilesJob/
        #     KProcessList drive it; Qt for WASM disables QProcess. kprocess.h
        #     must leave SOURCES too so AUTOMOC does not try to moc the broken
        #     QProcess subclass.
        #   * KFormat's relative-date formatting needs QTimeZone/QDateTime
        #     time-zone APIs that our Qt for WASM build is compiled without.
        #   * KFileSystemType has no implementation for non-Linux/BSD/Windows
        #     UNIX platforms, and its only in-tree user (KDirWatch) is not pulled
        #     in by Kirigami or QPrompt.
        # The remaining *_unix files (kuser, kshell, kmacroexpander) compile
        # cleanly and are kept.
        get_target_property(_kca_sources KF6CoreAddons SOURCES)
        list(FILTER _kca_sources EXCLUDE REGEX
            "((kshareddatacache|ksdclock|ksdcmemory|klistopenfilesjob_unix|kprocesslist_unix|kprocess|ksandbox|kformat|kformatprivate|kfilesystemtype)\\.cpp|kprocess\\.h)$")
        set_target_properties(KF6CoreAddons PROPERTIES SOURCES "${_kca_sources}")
    endif()
    if(IOS)
        # KCoreAddons' own CMakeLists.txt (3rdparty/kcoreaddons/src/lib/
        # CMakeLists.txt) already guards kuser_unix.cpp, kshell_unix.cpp and
        # kmacroexpander_unix.cpp behind `if (UNIX AND NOT IOS)`, correctly
        # recognizing that their getpwuid()/getpwnam()/getgrgid() calls
        # (real POSIX passwd/group database lookups) don't exist in iOS's
        # sandboxed, single-user runtime even though <pwd.h>/<grp.h> declare
        # them (so the calls compile, then fail to link). What upstream
        # doesn't do is provide an iOS backend to replace them with, so the
        # always-compiled public API files that call into that now-absent
        # backend - kshell.cpp (whose homeDir() also pulls in all of KUser)
        # and kmacroexpander.cpp - are left with unresolved references.
        # Neither Kirigami nor QPrompt (which only needs KAboutData) calls
        # into KShell, KMacroExpander, or KUser, so dropping their sources
        # here leaves nothing unresolved - except kosrelease.cpp, which
        # also calls KShell::splitArgs() to parse /etc/os-release (parsing
        # a file that doesn't exist on iOS anyway); neither Kirigami nor
        # QPrompt use KOSRelease either, so it goes too.
        get_target_property(_kca_sources KF6CoreAddons SOURCES)
        list(FILTER _kca_sources EXCLUDE REGEX "(kshell|kmacroexpander|kosrelease)\\.cpp$")
        set_target_properties(KF6CoreAddons PROPERTIES SOURCES "${_kca_sources}")
    endif()
    if(ANDROID OR IOS)
        # Prevent Kirigami from finding and using OpenMP on Android and iOS.
        # OpenMP is optional (accelerates palette generation in ImageColors)
        # but libomp.so cannot be loaded on Android, causing a startup crash.
        # Pre-set cache variables so FindOpenMP's checks (which use
        # set(... CACHE ...) without FORCE) cannot overwrite them.
        set(CMAKE_DISABLE_FIND_PACKAGE_OpenMP ON CACHE BOOL "" FORCE)
        set(OpenMP_FOUND FALSE CACHE BOOL "" FORCE)
        set(OpenMP_CXX_FOUND FALSE CACHE BOOL "" FORCE)
        set(OpenMP_C_FOUND FALSE CACHE BOOL "" FORCE)
        set(OpenMP_CXX_FLAGS "" CACHE STRING "" FORCE)
        set(OpenMP_C_FLAGS "" CACHE STRING "" FORCE)
    endif()
    FetchContent_Declare(
      Kirigami
      GIT_REPOSITORY "${CMAKE_SOURCE_DIR}/3rdparty/kirigami"
      GIT_TAG        "v${KF_PREFFERED_VERSION}"
      SOURCE_DIR submodules/kirigami
    )
    FetchContent_MakeAvailable(Kirigami)
    if(APPLE)
        # See the matching KF6CoreAddons comment above: Kirigami and
        # KirigamiPlatform are QPrompt's other direct link dependencies built
        # the same way, so they need the same @rpath fix-up.
        foreach(_qprompt_apple_rpath_target Kirigami KirigamiPlatform)
            if(TARGET ${_qprompt_apple_rpath_target})
                set_target_properties(${_qprompt_apple_rpath_target} PROPERTIES INSTALL_NAME_DIR "@rpath")
            endif()
        endforeach()
    endif()
    # Restore QPrompt's own C++ standard for the targets defined afterwards.
    set(CMAKE_CXX_STANDARD 17)
else()
    find_package(KF${QT_VERSION_MAJOR} ${KF_MIN_VERSION} REQUIRED COMPONENTS
        Kirigami
        CoreAddons
        GlobalAccel
    )
endif()

if(NOT ANDROID AND NOT IOS AND NOT WASM)
    if(NOT BSD AND NOT SOURCE_DEPENDENCIES_EXCLUSIVELY_FROM_SYSTEM AND NOT USE_GIT_DEPENDENCIES_ONLY)
        set(BUILD_SHARED_LIBS ON)
        FetchContent_Declare(
          QHotkey
          GIT_REPOSITORY "${CMAKE_SOURCE_DIR}/3rdparty/QHotkey"
          GIT_TAG        "6c0e98492c59206139f8490706aadeb8ed033057"
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
# Hunspell spell checking. Hunspell upstream ships only autotools/MSVC
# project files, so on platforms where a system package or vcpkg/Craft
# install isn't available we build the library straight from the
# submodule sources via HunspellShim. Linux/BSD/Haiku continue to use the
# system package (find_package or pkg-config).
if(WIN32 OR APPLE OR ANDROID OR IOS OR WASM OR USE_GIT_DEPENDENCIES_ONLY)
    include(HunspellShim)
    qprompt_build_hunspell("${CMAKE_SOURCE_DIR}/3rdparty/hunspell")
else()
    find_package(Hunspell)
    if(NOT Hunspell_FOUND)
        find_package(PkgConfig QUIET)
        if(PkgConfig_FOUND)
            pkg_check_modules(HUNSPELL IMPORTED_TARGET hunspell)
        endif()
    endif()
endif()
if(TARGET Hunspell::Hunspell OR TARGET hunspell OR TARGET PkgConfig::HUNSPELL)
    add_compile_definitions(HUNSPELL_ENABLED)
    set(HUNSPELL_ENABLED ON)
endif()

# Bundled Hunspell dictionaries.
#
# Static builds (WASM/Android/iOS) and macOS DMGs embed the dictionaries
# inside the binary as Qt resources (handled in src/CMakeLists.txt). The
# Windows NSIS installer ships them as user-selectable components (handled
# below in the CPack section). Linux is intentionally skipped because
# Hunspell dictionaries are to be provided by the distribution.
if(WASM OR ANDROID OR IOS OR APPLE OR WIN32)
    include(HunspellDictionaries)
    set(QPROMPT_HUNSPELL_DICT_DIR "${CMAKE_BINARY_DIR}/hunspell-dictionaries")
    qprompt_hunspell_fetch_all("${QPROMPT_HUNSPELL_DICT_DIR}")
endif()
# Platform specific dependencies
if(HAIKU)
    # Haiku OS icons look nice
    find_package(KF${QT_VERSION_MAJOR} ${KF_MIN_VERSION} REQUIRED COMPONENTS
        IconThemes
    )
    find_package(KF${QT_VERSION_MAJOR}Crash ${REQUIRED_KF${QT_VERSION_MAJOR}_VERSION} CONFIG QUIET)
        set_package_properties(KF${QT_VERSION_MAJOR}Crash PROPERTIES
        DESCRIPTION "Graceful handling of application crashes."
        TYPE OPTIONAL
    )
# KCrash is not used by the self-contained Windows build. Probe quietly on
# the remaining desktop platforms and enable it only when a package exists.
elseif(NOT WIN32)
    find_package(KF${QT_VERSION_MAJOR}Crash ${REQUIRED_KF${QT_VERSION_MAJOR}_VERSION} CONFIG QUIET)
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
# Emscripten reports itself as UNIX, so KDECompilerSettings injects the
# GNU-ld-only "-Wl,--enable-new-dtags" RPATH flag into the global linker flags.
# wasm-ld rejects unknown arguments, breaking the final link, so strip it here.
if (WASM)
    foreach(_flags CMAKE_EXE_LINKER_FLAGS CMAKE_SHARED_LINKER_FLAGS CMAKE_MODULE_LINKER_FLAGS)
        string(REPLACE "-Wl,--enable-new-dtags" "" ${_flags} "${${_flags}}")
        string(STRIP "${${_flags}}" ${_flags})
    endforeach()
endif()
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

add_subdirectory(src)

if(QPROMPT_BUILD_TESTS)
    enable_testing()
    find_package(Qt${QT_VERSION_MAJOR} ${QT_MIN_VERSION} REQUIRED NO_MODULE COMPONENTS Test)
    add_subdirectory(tests)
endif()

if (ANDROID)
    configure_file(${ANDROID_PACKAGE_SOURCE_DIR}/version.gradle.in ${CMAKE_BINARY_DIR}/version.gradle)
    # Also copy to the src subdirectory so the relative path from android-build-*/build.gradle works
    configure_file(${ANDROID_PACKAGE_SOURCE_DIR}/version.gradle.in ${CMAKE_BINARY_DIR}/src/version.gradle)
endif()

if (UNIX AND NOT APPLE AND NOT IOS AND NOT ANDROID)
    set(DOC_INSTALL_DIR "share/doc/qprompt")
    set(MAN_INSTALL_DIR "share/man/")
    install(FILES docs/manpage/qprompt.1 DESTINATION ${MAN_INSTALL_DIR}/man1)
endif()

if (WIN32 OR UNIX AND NOT APPLE) # AND NOT ANDROID
    install(FILES com.cuperino.qprompt.appdata.xml DESTINATION ${KDE_INSTALL_METAINFODIR})
    install(PROGRAMS com.cuperino.qprompt.desktop DESTINATION ${KDE_INSTALL_APPDIR})
    install(FILES ${DOCS} DESTINATION ${DOC_INSTALL_DIR})
endif()

# Bundle the Windows offline speech runtime and the initial English model so
# an NSIS installation provides Voice Follow without a separate download or
# development environment variables.
if(WIN32)
    option(QPROMPT_BUNDLE_VOSK "Bundle Vosk runtime and English model in Windows packages" ON)
    set(QPROMPT_VOSK_ASSET_DIR "${CMAKE_BINARY_DIR}/voice-assets" CACHE PATH
        "Directory prepared by scripts/setup-vosk-dev.ps1")

    if(QPROMPT_BUNDLE_VOSK)
        set(QPROMPT_VOSK_RUNTIME_DIR "${QPROMPT_VOSK_ASSET_DIR}/vosk-win64-0.3.45")
        set(QPROMPT_VOSK_MODEL_NAME "vosk-model-small-en-us-0.15")
        set(QPROMPT_VOSK_MODEL_DIR "${QPROMPT_VOSK_ASSET_DIR}/${QPROMPT_VOSK_MODEL_NAME}")
        set(QPROMPT_VOSK_RUNTIME_FILES
            "${QPROMPT_VOSK_RUNTIME_DIR}/libvosk.dll"
            "${QPROMPT_VOSK_RUNTIME_DIR}/libgcc_s_seh-1.dll"
            "${QPROMPT_VOSK_RUNTIME_DIR}/libstdc++-6.dll"
            "${QPROMPT_VOSK_RUNTIME_DIR}/libwinpthread-1.dll"
        )

        foreach(required_path IN LISTS QPROMPT_VOSK_RUNTIME_FILES)
            if(NOT EXISTS "${required_path}")
                message(FATAL_ERROR
                    "Voice Follow packaging asset is missing: ${required_path}\n"
                    "Run scripts/setup-vosk-dev.ps1 before configuring QPrompt.")
            endif()
        endforeach()
        if(NOT EXISTS "${QPROMPT_VOSK_MODEL_DIR}/conf/model.conf")
            message(FATAL_ERROR
                "Voice Follow model is missing: ${QPROMPT_VOSK_MODEL_DIR}\n"
                "Run scripts/setup-vosk-dev.ps1 before configuring QPrompt.")
        endif()
        if(NOT EXISTS "${QPROMPT_VOSK_ASSET_DIR}/VOSK-COPYING")
            message(FATAL_ERROR
                "Vosk license file is missing: ${QPROMPT_VOSK_ASSET_DIR}/VOSK-COPYING\n"
                "Run scripts/setup-vosk-dev.ps1 before configuring QPrompt.")
        endif()

        install(FILES ${QPROMPT_VOSK_RUNTIME_FILES}
            DESTINATION "${CMAKE_INSTALL_BINDIR}"
            COMPONENT Unspecified)
        install(DIRECTORY "${QPROMPT_VOSK_MODEL_DIR}/"
            DESTINATION "${CMAKE_INSTALL_BINDIR}/models/${QPROMPT_VOSK_MODEL_NAME}"
            COMPONENT Unspecified)
        install(FILES "${QPROMPT_VOSK_ASSET_DIR}/VOSK-COPYING"
            DESTINATION "${DOC_INSTALL_DIR}/licenses"
            COMPONENT Unspecified)
    endif()
elseif(APPLE AND NOT IOS)
    # Same idea as the Windows block above, but into the .app bundle.
    # QCoreApplication::applicationDirPath() resolves to Contents/MacOS for
    # a bundled app, which is what VoiceFollowSession::defaultLibraryPath()/
    # defaultModelPath() (src/voicefollowsession.cpp) check next to the
    # executable - so that's where the runtime and model need to land.
    #
    # Vosk's own releases stopped shipping a macOS runtime archive after
    # v0.3.42 (the newest release with a vosk-osx-*.zip asset; v0.3.45,
    # used above for Windows, only publishes Linux/Windows/Android
    # archives), so that is the version bundled here. Its libvosk.dylib is
    # a universal x86_64+arm64 binary linking only system frameworks, so
    # it runs unmodified on both Intel and Apple Silicon Macs despite
    # predating the Windows runtime version.
    option(QPROMPT_BUNDLE_VOSK "Bundle Vosk runtime and English model in macOS packages" ON)
    set(QPROMPT_VOSK_ASSET_DIR "${CMAKE_BINARY_DIR}/voice-assets" CACHE PATH
        "Directory prepared by scripts/setup-vosk-dev.sh")

    if(QPROMPT_BUNDLE_VOSK)
        set(QPROMPT_VOSK_RUNTIME_DIR "${QPROMPT_VOSK_ASSET_DIR}/vosk-osx-0.3.42")
        set(QPROMPT_VOSK_MODEL_NAME "vosk-model-small-en-us-0.15")
        set(QPROMPT_VOSK_MODEL_DIR "${QPROMPT_VOSK_ASSET_DIR}/${QPROMPT_VOSK_MODEL_NAME}")
        set(QPROMPT_VOSK_RUNTIME_FILES
            "${QPROMPT_VOSK_RUNTIME_DIR}/libvosk.dylib"
        )

        foreach(required_path IN LISTS QPROMPT_VOSK_RUNTIME_FILES)
            if(NOT EXISTS "${required_path}")
                message(FATAL_ERROR
                    "Voice Follow packaging asset is missing: ${required_path}\n"
                    "Run scripts/setup-vosk-dev.sh before configuring QPrompt.")
            endif()
        endforeach()
        if(NOT EXISTS "${QPROMPT_VOSK_MODEL_DIR}/conf/model.conf")
            message(FATAL_ERROR
                "Voice Follow model is missing: ${QPROMPT_VOSK_MODEL_DIR}\n"
                "Run scripts/setup-vosk-dev.sh before configuring QPrompt.")
        endif()
        if(NOT EXISTS "${QPROMPT_VOSK_ASSET_DIR}/VOSK-COPYING")
            message(FATAL_ERROR
                "Vosk license file is missing: ${QPROMPT_VOSK_ASSET_DIR}/VOSK-COPYING\n"
                "Run scripts/setup-vosk-dev.sh before configuring QPrompt.")
        endif()

        install(FILES ${QPROMPT_VOSK_RUNTIME_FILES}
            DESTINATION "QPrompt.app/Contents/MacOS"
            COMPONENT Unspecified)
        # The model is a directory tree of plain data files, not code. Put
        # it under Contents/Resources (the correct macOS location for
        # bundled resources) rather than directly in Contents/MacOS:
        # `codesign --deep`'s recursive bundle-format detection trips over
        # a full directory tree sitting next to the executable, the same
        # way it did for the Kirigami QML modules (see the comment above
        # the `Contents/Resources/qml` install() call in src/CMakeLists.txt).
        # A symlink at the path defaultModelPath() actually checks keeps
        # that function working unmodified: QDir/QFileInfo follow symlinks
        # transparently, and codesign only sees a plain symlink there
        # rather than a directory tree that looks like a nested bundle.
        install(DIRECTORY "${QPROMPT_VOSK_MODEL_DIR}/"
            DESTINATION "QPrompt.app/Contents/Resources/models/${QPROMPT_VOSK_MODEL_NAME}"
            COMPONENT Unspecified)
        install(CODE "
            execute_process(COMMAND \${CMAKE_COMMAND} -E create_symlink
                ../Resources/models
                \"\${CMAKE_INSTALL_PREFIX}/QPrompt.app/Contents/MacOS/models\")
            " COMPONENT Unspecified)
        install(FILES "${QPROMPT_VOSK_ASSET_DIR}/VOSK-COPYING"
            DESTINATION "QPrompt.app/Contents/Resources/licenses"
            COMPONENT Unspecified)
    endif()
endif()

# QPrompt uses the standard MSVC runtime but does not use MFC. Asking CMake to
# install MFC caused misleading missing-MFC warnings on otherwise complete
# Visual Studio installations.
set(CMAKE_INSTALL_MFC_LIBRARIES Off)
set(InstallRequiredSystemLibraries On)
include(InstallRequiredSystemLibraries)

# "10.15" is a macOS (Catalina) version number and has no meaning as an iOS
# deployment target. CMAKE_OSX_DEPLOYMENT_TARGET doubles as both when
# cross-compiling for iOS, though, so setting it unconditionally silently
# drags the iOS target down to "10.15" too - below 13.0, which is where
# Apple's std::filesystem shim (used by Qt's own QFile/QFileInfo headers)
# becomes available, breaking the iOS build with "'path' is unavailable"
# compiler errors.
if(NOT IOS)
    set(CMAKE_OSX_DEPLOYMENT_TARGET "10.15")
endif()
set(CMAKE_OSX_ARCHITECTURES="x86_64;arm64")

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
        set(CPACK_DEBIAN_PACKAGE_DEPENDS "libvulkan-dev (>= 1.4.309), libqt6svg6 (>= 6.8.2), libqt6qmlworkerscript6 (>=6.8.2), qml6-module-qt-labs-platform (>=6.8.2), qml6-module-qtqml (>=6.8.2), qml6-module-qtqml-models (>=6.8.2), qml6-module-qtqml-statemachine (>=6.8.2), qml6-module-qtquick-controls (>=6.8.2), qml6-module-qtcore (>=6.8.2), qml6-module-qt-labs-settings (>=6.8.2), qml6-module-qtquick-dialogs (>=6.8.2), qml6-module-qtquick-shapes (>=6.8.2), libkf6coreaddons6 (>= 6.9.0), libkirigami6 (>= 6.9.0), qml6-module-org-kde-kirigami (>=6.9.0), libkf6i18n6 (>= 6.9.0), libkf6crash6 (>= 6.9.0)")

        # CPACK: RPM specific settings
        set(CPACK_RPM_PACKAGE_GROUP "Multimedia/Video")
        # set(CPACK_RPM_PACKAGE_REQUIRES "qt6-qtbase >= 6.8.2, qt6-qtbase-gui >= 6.8.2, qt6-qtdeclarative >= 6.8.2, qt6-qtsvg >= 6.8.2, qt6-qtquickcontrols2 >= 6.8.2, kf6-kcoreaddons >= 6.9.0, kf6-kirigami >= 6.9.0, kf6-kcrash >= 6.9.0")
        set(CPACK_RPM_COMPRESSION_TYPE ${COMPRESION_TYPE})

    elseif(WIN32)
        set(CPACK_GENERATOR "NSIS")
        # Qt's generated deployment script runs during a full install. Keep
        # the Windows package monolithic so Qt, QML, Vosk and the speech model
        # are always installed together as one self-contained application.
        set(CPACK_MONOLITHIC_INSTALL ON)
        set(CPACK_PACKAGE_EXECUTABLES "QPrompt" "QPrompt")
        set(CPACK_RESOURCE_FILE_LICENSE ${CMAKE_SOURCE_DIR}/${LICENSE_FILE})
        set(CPACK_NSIS_EXECUTABLES_DIRECTORY ${BIN_INSTALL_DIR})
        set(CPACK_NSIS_MUI_ICON ${ICONS_DIR}/qprompt.ico)
        set(CPACK_NSIS_MUI_UNIICON ${ICONS_DIR}/qprompt.ico)
        set(CPACK_NSIS_INSTALLED_ICON_NAME ${BIN_INSTALL_DIR}/QPrompt.exe)
        set(CPACK_NSIS_CONTACT ${CPACK_PACKAGE_CONTACT})
        set(CPACK_NSIS_INSTALLED_ICON_NAME "qprompt${CMAKE_EXECUTABLE_SUFFIX}")
        set(CPACK_NSIS_MENU_LINKS
            ${CMAKE_SOURCE_DIR}/${LICENSE_FILE} "License"
            ${CMAKE_SOURCE_DIR}/${README_FILE} "Readme"
        )
        set(CPACK_NSIS_MUI_FINISHPAGE_RUN "${CPACK_NSIS_INSTALLED_ICON_NAME}")

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
        set(CPACK_DMG_DS_STORE_SETUP_SCRIPT "${CMAKE_SOURCE_DIR}/dist/macOS/DS_Store.scpt")

    elseif(BSD AND NOT APPLE)
        set(CPACK_FREEBSD_PACKAGE_MAINTAINER ${CPACK_PACKAGE_CONTACT})
        set(CPACK_FREEBSD_PACKAGE_ORIGIN "multimedia")
        set(CPACK_FREEBSD_PACKAGE_CATEGORIES "devel/qt6-base, x11-toolkits/qt6-declarative, graphics/qt6-svg, x11-toolkits/qt6-shadertools, multimedia/qt6-multimedia, devel/kf6-kcoreaddons, x11-toolkits/kf6-kirigami, devel/kf6-kcrash, x11-themes/kf6-kiconthemes, x11-toolkits/qhotkey")
    endif()

    include(CPack)

    # Windows NSIS dictionary components (declared after include(CPack)
    # because cpack_add_component() is provided by CPackComponent which is
    # pulled in by include(CPack)).
    if(WIN32)
        cpack_add_component(Unspecified
            DISPLAY_NAME "QPrompt"
            DESCRIPTION  "QPrompt application files"
            REQUIRED
            HIDDEN
        )
        if(DEFINED QPROMPT_HUNSPELL_DICT_DIR)
            qprompt_hunspell_install_components(
                "${QPROMPT_HUNSPELL_DICT_DIR}"
                "${KDE_INSTALL_DATADIR}/hunspell"
            )
        endif()
    endif()
endif()

# if(NOT WASM)
if(NOT WASM AND NOT IOS)
    feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES) # INCLUDE_QUIET_PACKAGES
endif()

file(GLOB_RECURSE ALL_CLANG_FORMAT_SOURCE_FILES *.cpp *.h *.hpp)
