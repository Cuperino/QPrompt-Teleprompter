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

option(WASM OFF)
option(SOURCE_DEPENDENCIES_EXCLUSIVELY_FROM_SYSTEM OFF)  # Used only on Linux builds for now

# Find includes in corresponding build directories
# set(CMAKE_INCLUDE_CURRENT_DIR ON)
# Instruct CMake to create code from Qt designer ui files
# set(CMAKE_AUTOUIC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
# Leave C++ standard at version 17 to build Ubuntu 18.04 compatible AppImage
set(CMAKE_CXX_STANDARD 17)
# Instruct CMake to run moc automatically when needed
set(CMAKE_AUTOMOC ON)
# set(CMAKE_AUTORCC ON)set(CMAKE_AUTOMOC ON)

set(QT_DEFAULT_MAJOR_VERSION 6)
# Qt 6.7.2 for Ubuntu 24.10, tho ideally we'd use 6.7.3 or 6.8.x.
set(QT_MIN_VERSION 6.7.2)
# Enabling newer ECM appears to break AutoMOC...
if (WIN32)
    set(ECM_MIN_VERSION 5.83.0)
else()
    set(ECM_MIN_VERSION 5.68.0)
endif()
# Version with minimum required set of features
set(KF_MIN_VERSION 6.9.0)
# Last version known to work
set(KF_PREFFERED_VERSION 6.14.0)
# if (APPLE)
#     set(APPLE_SUPPRESS_X11_WARNING ON)
# endif()
# # ------------------------- BEGIN: lists to maintain manually -------------------------
# # Directories where Qt Creator can find modules and Kirigami's QML files
# list(APPEND QML_DIRS "build/dist/lib/x86_64-linux-gnu/qml")
# list(APPEND KIRIGAMI_DIRS "build/dist/lib/x86_64-linux-gnu/qml/org/kde/kirigami")
# # Directories where Qt Creator can find these files on your system.
# #   (This setting is cached in variable QML_IMPORT_DIR, see below. Delete
# #   ${BUIL_DIR}/CMakeCache.txt to make make changes here effective.)
# if (UNIX AND NOT APPLE AND NOT ANDROID)
#     list(APPEND QML_DIRS "/usr/lib/x86_64-linux-gnu/qt6/qml")
#     list(APPEND KIRIGAMI_DIRS "/usr/lib/x86_64-linux-gnu/qml/org/kde/kirigami")
# elseif (UNIX AND APPLE)
#     list(APPEND QML_DIRS "/opt/homebrew/lib/qml")
#     list(APPEND KIRIGAMI_DIRS "/opt/homebrew/lib/qml/org/kde/kirigami")
# elseif (WIN32)
#     list(APPEND QML_DIRS "C:/CraftRoot/qml")
#     list(APPEND KIRIGAMI_DIRS "C:/CraftRoot/qml/org/kde/kirigami")
# endif()
# # ------------------------- END: lists to maintain manually -------------------------

# # Prevent adding duplicate values at each run of CMake.
# list(REMOVE_DUPLICATES QML_DIRS)

# # Tell Qt Creator where to find QML files.
# # (The build process will work without this, but no code completion etc..)
# # The variable is cached in ${BUILD_DIR}/CMakeCache.txt. We need FORCE to change it there immediately.
# set(
#     QML_IMPORT_PATH ${KIRIGAMI_DIRS}
#     QML_IMPORT_PATH ${QML_DIRS}
#     CACHE STRING "Qt Creator 4.1 extra qml import paths"
#     FORCE
# )

# if(ANDROID)
#     set(ANDROID_PACKAGE_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/android)
#         if(NOT ANDROID_ABIS)
#                 set(ANDROID_ABIS "arm64-v8a") # armeabi-v7a
#         endif()
# else()
# set(DBINARY_ICONS_RESOURCE ON)
# endif()

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "RelWithDebInfo")
endif()

list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")

# Send compiled program and library binaries to "build/bin"
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

find_package(ECM ${ECM_MIN_VERSION} REQUIRED NO_MODULE)
list(APPEND CMAKE_MODULE_PATH ${ECM_MODULE_PATH})
find_package(QT NAMES Qt6)

# find_package(Git QUIET)
# if(GIT_FOUND AND EXISTS "${PROJECT_SOURCE_DIR}/.git")
#     option(GIT_SUBMODULE "Check submodules during build" ON)
#     if(GIT_SUBMODULE)
#         message(STATUS "Updating submodules")
#         execute_process(COMMAND ${GIT_EXECUTABLE} submodule update --init --recursive
#                         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
#                         RESULT_VARIABLE GIT_SUBMOD_RESULT)
#     endif()
# endif()

# Common dependencices
find_package(Qt${QT_VERSION_MAJOR} ${QT_MIN_VERSION} REQUIRED NO_MODULE COMPONENTS
    Core
    Quick
    Svg
    Gui
    QuickControls2
    Network
    # ShaderTools
    # LinguistTools
)

qt_policy(SET QTP0001 NEW)
qt_policy(SET QTP0002 NEW)
qt_policy(SET QTP0003 NEW)
qt_policy(SET QTP0004 NEW)
qt_policy(SET QTP0005 NEW)

if(ANDROID OR IOS OR WASM)
    set(BUILD_SHARED_LIBS OFF)
endif()

# if(A# find_package(OpenSSL REQUIRED)NDROID)
    # find_package(OpenSSL REQUIRED)
    # find_package(Gradle REQUIRED)
# endif()

if(WIN32 OR APPLE OR ANDROID OR WASM)
    set(BUILD_TESTING OFF)
    # if(NOT WASM)
    #     FetchContent_Declare(
    #       CoreAddons
    #       GIT_REPOSITORY "${CMAKE_SOURCE_DIR}/3rdparty/kcoreaddons"
    #       GIT_TAG        "v${KF_PREFFERED_VERSION}"
    #       SOURCE_DIR submodules/kcoreaddons
    #     )
    #     FetchContent_MakeAvailable(CoreAddons)
    # else()
    #     set(KF_IGNORE_PLATFORM_CHECK ON)
    # endif()
    FetchContent_Declare(
      Kirigami
      GIT_REPOSITORY "${CMAKE_SOURCE_DIR}/3rdparty/kirigami"
      GIT_TAG        "v6.14.1" # "v${KF_PREFFERED_VERSION}"
      SOURCE_DIR submodules/kirigami
    )
    FetchContent_MakeAvailable(Kirigami)
else()
    find_package(KF${QT_VERSION_MAJOR} ${KF_MIN_VERSION} REQUIRED COMPONENTS
        Kirigami
        CoreAddons
    )
endif()

# if(NOT ANDROID AND NOT IOS AND NOT WASM)
#     if(NOT BSD AND NOT SOURCE_DEPENDENCIES_EXCLUSIVELY_FROM_SYSTEM)
#         set(BUILD_SHARED_LIBS ON)
#         FetchContent_Declare(
#           QHotkey
#           GIT_REPOSITORY "${CMAKE_SOURCE_DIR}/3rdparty/QHotkey"
#           GIT_TAG        "6c0e98492c59206139f8490706aadeb8ed033057"
#           SOURCE_DIR submodules/QHotkey
#         )
#         FetchContent_MakeAvailable(QHotkey)
#     else()
#         find_package(QHotkey)
#     endif()
# endif()
# # Desktop only dependencies
# if(NOT ANDROID AND NOT IOS AND NOT WASM)
#     find_package(Qt${QT_VERSION_MAJOR} ${QT_MIN_VERSION} REQUIRED NO_MODULE COMPONENTS
#         Widgets
#     )
# endif()
# Platform specific dependencies
# if(ANDROID)
    # find_package(Qt${QT_VERSION_MAJOR} ${QT_MIN_VERSION} REQUIRED NO_MODULE COMPONENTS
    #     AndroidExtras
    # )
# elseif(HAIKU)
# if(HAIKU)
#     # Haiku OS icons look nice
#     find_package(KF${QT_VERSION_MAJOR} ${KF_MIN_VERSION} REQUIRED COMPONENTS
#         IconThemes
#     )
#     find_package(KF${QT_VERSION_MAJOR}Crash ${REQUIRED_KF${QT_VERSION_MAJOR}_VERSION} CONFIG QUIET)
#         set_package_properties(KF${QT_VERSION_MAJOR}Crash PROPERTIES
#         DESCRIPTION "Graceful handling of application crashes."
#         TYPE OPTIONAL
#     )
# # Windows, MacOS, and FreeBSD
# else()
    # find_package(KF${QT_VERSION_MAJOR}Crash ${REQUIRED_KF${QT_VERSION_MAJOR}_VERSION} COMPONENTS)
    # set_package_properties(KF${QT_VERSION_MAJOR}Crash PROPERTIES
    #     DESCRIPTION "Graceful handling of application crashes."
    #     TYPE OPTIONAL
    # )
    # KDMacTouchBar (Mac only)
    # if(APPLE AND NOT IOS)
    #     if (NOT EXISTS "${PROJECT_SOURCE_DIR}/3rdparty/KDMacTouchBar/CMakeLists.txt")
    #         message(FATAL_ERROR "KDMacTouchBar was not downloaded. GIT_SUBMODULE was turned off or failed.")
    #     endif()
    #     # set(CMAKE_INSTALL_PREFIX ${PROJECT_SOURCE_DIR}/install/usr/)
    #     add_subdirectory("3rdparty/KDMacTouchBar" build/kdmactouchbar)
    # endif()
# endif()

if (WIN32 OR UNIX) # AND NOT ANDROID
    include(KDEInstallDirs)
    include(KDECMakeSettings)
    include(ECMInstallIcons)
    include(ECMAddAppIcon)
    include(ECMGenerateHeaders)
endif()
include(KDECompilerSettings NO_POLICY_SCOPE)
include(KDEClangFormat)
include(ECMAddAndroidApk)
include(ECMQtDeclareLoggingCategory)
include(ECMSetupVersion)
include(ECMSourceVersionControl)
include(ECMPoQmTools)
include(ECMFeatureSummary)

# if (${ECM_SOURCE_UNDER_VERSION_CONTROL})
#     execute_process(
#         COMMAND git rev-parse --abbrev-ref HEAD
#         WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
#         OUTPUT_VARIABLE GIT_BRANCH
#         OUTPUT_STRIP_TRAILING_WHITESPACE
#     )

#     # Get the latest abbreviated commit hash of the working branch
#     execute_process(
#         COMMAND git log -1 --format=%h
#         WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
#         OUTPUT_VARIABLE GIT_COMMIT_HASH
#         OUTPUT_STRIP_TRAILING_WHITESPACE
#     )

#     add_definitions(-DGIT_COMMIT_HASH="${GIT_COMMIT_HASH}")
#     add_definitions(-DGIT_BRANCH="${GIT_BRANCH}")

# else()
#     add_definitions(-DGIT_COMMIT_HASH="${PROJECT_VERSION}")
#     add_definitions(-DGIT_BRANCH="Stable")
# endif()

# ecm_setup_version(${PROJECT_VERSION}
#     VARIABLE_PREFIX QPROMPT
#     VERSION_HEADER "${CMAKE_CURRENT_BINARY_DIR}/qprompt_version.h"
# )

# LICENSING
# set(LICENSE_FILE "COPYING")
# set(README_FILE "README.md")
# set(DESCRIPTION_FILE "DESCRIPTION.txt")
# list(APPEND DOCS ${LICENSE_FILE} ${README_FILE} ${DESCRIPTION_FILE} "COPYING.ASSETS")

# set(DOC_INSTALL_DIR "share/doc/qprompt")

# add_subdirectory(src)


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

# if(NOT WIN32)
#     include(ECMPoQmTools)
#     ecm_create_qm_loader(qprompt_QM_LOADER ../po/qprompt.pot)
# endif()

qt_standard_project_setup(REQUIRES 6.7) # I18N_TRANSLATED_LANGUAGES ar cs de es fi fr he it ja ko nl oc pl pt_BR pt_PT ru tr uk zh)

# set(CMAKE_OSX_DEPLOYMENT_TARGET "10.15")
# set(CMAKE_OSX_ARCHITECTURES="x86_64;arm64")

# if (ANDROID OR IOS OR WASM)
    qt_add_executable(${PROJECT_NAME}
        main.cpp
    )
# else()
#     qt_add_executable(${PROJECT_NAME}
#         main.cpp
#         systemfontchooserdialog.h
#         systemfontchooserdialog.cpp
#     )
# endif()
# if (NOT ANDROID AND NOT IOS AND NOT WASM)
#     qt_wrap_ui(${PROJECT_NAME}
#         qt/systemfontchooserdialog.ui
#     )
# endif()

# if (NOT ANDROID AND NOT WASM)
#     set(ICONS_FOLDER ${CMAKE_CURRENT_SOURCE_DIR}/icons/hicolor)
#     set(RASTER_ICONS
#         ${ICONS_FOLDER}/16-apps-com.cuperino.qprompt.png
#         ${ICONS_FOLDER}/32-apps-com.cuperino.qprompt.png
#         ${ICONS_FOLDER}/48-apps-com.cuperino.qprompt.png
#         ${ICONS_FOLDER}/64-apps-com.cuperino.qprompt.png
#         ${ICONS_FOLDER}/128-apps-com.cuperino.qprompt.png
#         ${ICONS_FOLDER}/256-apps-com.cuperino.qprompt.png
#         ${ICONS_FOLDER}/512-apps-com.cuperino.qprompt.png
#         # ${ICONS_FOLDER}/1024-apps-com.cuperino.qprompt.png  # Flatpak has a maximum size of 512
#     )
#     # set(VECTOR_ICON
#     #     ${ICONS_FOLDER}/sc-apps-com.cuperino.qprompt.svg
#     # )
#     if (NOT APPLE)
#         ecm_install_icons(
#             ICONS
#                 ${RASTER_ICONS}
#                 # ${VECTOR_ICON}
#             DESTINATION ${KDE_INSTALL_ICONDIR}
#             # THEME hicolor
#         )
#     endif()
#     ecm_add_app_icon(${PROJECT_NAME}
#         ICONS ${RASTER_ICONS}
#     )
# endif()

set(qprompt_cpp
    qmlutil.hpp
    abstractunits.hpp
    documenthandler.h
    documenthandler.cpp
    marker.hpp
    markersmodel.h
    markersmodel.cpp
    # src/${qprompt_QM_LOADER}
)

set(qprompt_frontend_sources
    # Kirigami UI Frontend
    src/kirigami_ui/main.qml
    src/kirigami_ui/+android/main.qml
    src/kirigami_ui/+windows/main.qml
    src/kirigami_ui/AboutPage.qml
    src/kirigami_ui/PathsPage.qml
    src/kirigami_ui/PrompterPage.qml
    src/kirigami_ui/TelemetryPage.qml
    src/kirigami_ui/RemotePage.qml
    src/kirigami_ui/EditorToolbar.qml
    src/kirigami_ui/MarkersDrawer.qml
    src/kirigami_ui/InputsOverlay.qml
    src/kirigami_ui/KeyInputButton.qml
    src/kirigami_ui/WheelSettingsOverlay.qml
    src/kirigami_ui/LayoutDirectionSettingsOverlay.qml
    src/kirigami_ui/LanguageSettingsOverlay.qml
    src/kirigami_ui/OnlineResourceButtons.qml
)

set(prompter_sources
    # Prompter component
    src/prompter/PrompterView.qml
    src/prompter/Prompter.qml
    src/prompter/ProgressIndicator.qml
    src/prompter/Countdown.qml
    src/prompter/TimerClock.qml
    src/prompter/ReadRegionOverlay.qml
    src/prompter/PrompterBackground.qml
    src/prompter/Flip.qml
    src/prompter/ProjectionsManager.qml
    src/prompter/Find.qml
    src/prompter/CursorAutoHide.qml
    src/prompter/PointerSettings.qml
    # Pointers
    src/prompter/pointers/pointer_0.qml
    src/prompter/pointers/pointer_1.qml
    src/prompter/pointers/pointer_2.qml
)

set(other_sources
    # Other QML
    src/qt/WindowDragger.qml
)

set(image_files
    # Logos
    src/images/qprompt.png
    src/images/qprompt-logo-wireframe.png
    # Pointers
    src/images/left_hand.png
    src/images/right_hand.png
)

# Fonts
set(font_files
    src/fonts/icons/fontello.ttf
    src/fonts/editor/dejavu-sans/DejaVuSans.ttf
    src/fonts/editor/Libertinus/static/OTF/LibertinusSans-Regular.otf
    src/fonts/editor/OpenDyslexic-Bold.otf
    src/fonts/editor/ScheherazadeNew/ScheherazadeNew-Regular.ttf
    src/fonts/editor/Kalpurush/Kalpurush.ttf
    src/fonts/editor/Palanquin-Regular.ttf
    # fonts/editor/Libertinus/static/OTF/LibertinusSerif-Regular.otf
    src/fonts/editor/SourceHanSans/SourceHanSans-Regular.ttc
)
foreach(file IN LISTS font_files)
    get_filename_component(filename ${file} NAME)
    set_source_files_properties(${file} PROPERTIES QT_RESOURCE_ALIAS fonts/${filename})
endforeach()

# Documents
set(document_files
    src/documents/untitled.html
    src/documents/welcome_ar.html
    src/documents/welcome_cs.html
    src/documents/welcome_de.html
    src/documents/welcome_en.html
    src/documents/welcome_es.html
    src/documents/welcome_fi.html
    src/documents/welcome_fr.html
    src/documents/welcome_he.html
    src/documents/welcome_it.html
    src/documents/welcome_ja.html
    src/documents/welcome_ko.html
    src/documents/welcome_nl.html
    src/documents/welcome_oc.html
    src/documents/welcome_pl.html
    src/documents/welcome_pt_BR.html
    src/documents/welcome_pt_PT.html
    src/documents/welcome_ru.html
    src/documents/welcome_uk.html
    src/documents/welcome_tr.html
    src/documents/welcome_zh.html
)
set_source_files_properties(src/documents/untitled.html PROPERTIES QT_RESOURCE_ALIAS src/documents/blank.html)

set(icon_files
    # Icons
    src/icons/16/go-next.svg
    src/icons/16/go-previous.svg
    src/icons/16/go-up.svg
    src/icons/16/go-down.svg
    src/icons/16/list-remove.svg
    src/icons/16/dialog-ok-apply.svg
    src/icons/16/window.svg
    src/icons/16/draw-rectangle.svg
    src/icons/16/transform-move-horizontal.svg
    src/icons/16/transform-move-vertical.svg
    src/icons/16/sidebar-collapse-right.svg
    src/icons/16/sidebar-collapse-left.svg
    src/icons/16/format-justify-center.svg
    src/icons/16/view-list-text.svg
    src/icons/16/view-list-text-rtl.svg
    src/icons/16/keyframe.svg
    src/icons/16/player-time.svg
    src/icons/16/format-text-color.svg
    src/icons/16/chronometer.svg
    src/icons/16/chronometer-pause.svg
    src/icons/16/keyframe-add.svg
    src/icons/16/object-flip-horizontal.svg
    src/icons/16/object-flip-vertical.svg
    src/icons/16/object-rotate-left.svg
    src/icons/16/object-rotate-right.svg
    src/icons/16/insert-image.svg
    src/icons/16/fill-color.svg
    src/icons/16/window-duplicate.svg
    src/icons/16/document-new.svg
    src/icons/16/document-save.svg
    src/icons/16/document-save-as.svg
    src/icons/16/document-open.svg
    src/icons/16/document-open-recent.svg
    src/icons/16/document-open-remote.svg
    src/icons/16/format-font-size-more.svg
    src/icons/16/edit-clear-history.svg
    src/icons/16/configure.svg
    src/icons/16/help-about.svg
    src/icons/16/application-exit.svg
    src/icons/16/document-properties.svg
    src/icons/16/paint-none.svg
    src/icons/16/filename-bpm-amarok.svg
    src/icons/16/gnumeric-object-scrollbar.svg
    src/icons/16/circular-arrow-shape.svg
    src/icons/16/key-enter.svg
    src/icons/16/edit-opacity.svg
    src/icons/16/edit-undo.svg
    src/icons/16/edit-redo.svg
    src/icons/16/mail-mark-unread.svg
    src/icons/16/media-playback-pause.svg
    src/icons/16/media-playback-start.svg
    src/icons/16/media-playback-stop.svg
    src/icons/16/draw-star.svg
    src/icons/16/edit-find.svg
    src/icons/16/edit-find-replace.svg
    src/icons/16/format-text-direction-rtl.svg
    src/icons/16/format-text-direction-ltr.svg
    src/icons/16/view-fullscreen.svg
    src/icons/16/empty.svg
    src/icons/16/amarok_change_language.svg
    src/icons/22/akonadiconsole.svg
    src/icons/22/handle-sort.svg
    src/icons/22/gnumeric-object-rectangle.svg
    src/icons/22/tool_color_eraser.svg
    src/icons/22/newline.svg
    src/icons/22/auto-transition.svg
    src/icons/22/view-left-close.svg
    src/icons/22/view-right-close.svg
    src/icons/22/transform-browse.svg
    src/icons/22/contrast.svg
    src/icons/22/window-pin.svg
    src/icons/22/window-unpin.svg
    src/icons/24/go-previous-symbolic.svg
    src/icons/24/go-next-symbolic.svg
)

foreach(file IN LISTS icon_files doc)
    get_filename_component(filename ${file} NAME)
    set_source_files_properties(${file} PROPERTIES QT_RESOURCE_ALIAS src/icons/${filename})
endforeach()

# App QML Module
qt_add_qml_module(
    ${PROJECT_NAME}
    URI com.cuperino.qprompt
    VERSION 1.0
    IMPORTS
    "QtQuick.Controls.Material"
    DEPENDENCIES
    QtQuick
    SOURCES
    ${qprompt_cpp}
    QML_FILES
    ${qprompt_frontend_sources}
    ${prompter_sources}
    ${other_sources}
    RESOURCES
    ${image_files}
    ${document_files}
    ${icon_files}
    # ${qprompt_ICONS}
)

# if (UNIX AND NOT ANDROID AND NOT APPLE AND NOT WASM)
#     set(OUTPUT_NAME "qprompt")
# elseif(ANDROID)
#     set(OUTPUT_NAME "libqrompt")
# else()
#     set(OUTPUT_NAME "QPrompt")
# endif()
set_target_properties(${PROJECT_NAME} PROPERTIES
    # MACOSX_BUNDLE_BUNDLE_NAME "QPrompt"
    # MACOSX_BUNDLE_GUI_IDENTIFIER com.cuperino.qprompt
    # MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    # MACOSX_BUNDLE_COPYRIGHT "Copyright Javier O. Cordero Pérez"
    # MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    # OUTPUT_NAME ${OUTPUT_NAME}
    # MACOSX_BUNDLE TRUE
    # WIN32_EXECUTABLE TRUE
    INTERFACE_LINK_LIBRARIES "KF${QT_VERSION_MAJOR}::Kirigami" # ;KF${QT_VERSION_MAJOR}::CoreAddons
    # QT_QMLCACHEGEN_ARGUMENTS "--static"  # "--static;--verbose"
    # QT_QMLCACHEGEN_DIRECT_CALLS OFF
    # PLUGIN_TARGET qtlabsplatformplugin inhibits the creation of the backing library, thus headers can't be accessed in direct mode.
    # See issue: https://bugreports.qt.io/browse/QTBUG-117992?focusedId=750577&page=com.atlassian.jira.plugin.system.issuetabpanels%3Acomment-tabpanel#comment-750577
)

# ecm_add_android_apk(${PROJECT_NAME} ANDROID_DIR ${CMAKE_SOURCE_DIR}/android)

# if (NOT IOS AND NOT ANDROID AND NOT WASM)
#     qt_add_resources(${PROJECT_NAME} "fonts"
#         PREFIX "/qt/qml/com/cuperino/qprompt/"
#         BIG_RESOURCES
#         FILES
#         ${font_files}
#     )
# else()
    qt_add_resources(${PROJECT_NAME} "fonts"
        PREFIX "/qt/qml/com/cuperino/qprompt/"
        FILES
        ${font_files}
    )
# endif()

# # Shader compilation
# qt_add_shaders(
#     ${PROJECT_NAME}
#     "qp_shaders"
#     PREFIX "/qt/qml/com/cuperino/qprompt"
#     FILES
#     "shaders/blur.frag"
#     "shaders/shadow.frag"
#     "shaders/tint.frag"
# )

# qt_add_translations(${PROJECT_NAME} SOURCE_TARGETS ${PROJECT_NAME}
#     TS_FILE_DIR ${CMAKE_SOURCE_DIR}/po
#     PLURALS_TS_FILE ${CMAKE_SOURCE_DIR}/po/qprompt_en.ts
#     LUPDATE_OPTIONS -source-language en
#     LRELEASE_OPTIONS -compress  # -idbased
# )

# Libraries
# if (IOS)
#     target_link_libraries(${PROJECT_NAME} PRIVATE
#         Qt${QT_VERSION_MAJOR}::Core
#         Qt${QT_VERSION_MAJOR}::Quick
#         Qt${QT_VERSION_MAJOR}::Svg
#         Qt${QT_VERSION_MAJOR}::Gui
#         Qt${QT_VERSION_MAJOR}::Qml
#         Qt${QT_VERSION_MAJOR}::QuickControls2
#         Qt${QT_VERSION_MAJOR}::Network
#         KF${QT_VERSION_MAJOR}::CoreAddons
#         KF${QT_VERSION_MAJOR}::Kirigami
#         Kirigamiplugin
#     )
# elseif (ANDROID)
    target_link_libraries(${PROJECT_NAME} PRIVATE
        Qt${QT_VERSION_MAJOR}::Core
        Qt${QT_VERSION_MAJOR}::Quick
        Qt${QT_VERSION_MAJOR}::Svg
        Qt${QT_VERSION_MAJOR}::Gui
        Qt${QT_VERSION_MAJOR}::Qml
        Qt${QT_VERSION_MAJOR}::QuickControls2
        Qt${QT_VERSION_MAJOR}::Network
        # KF${QT_VERSION_MAJOR}::CoreAddons
        KF${QT_VERSION_MAJOR}::Kirigami
        # Kirigamiplugin
        # OpenSSL::SSL
    )
# elseif (WASM)
#     target_compile_options(${PROJECT_NAME} PRIVATE -O3 -flto -sDISABLE_EXCEPTION_THROWING=0 -sDISABLE_EXCEPTION_CATCHING=0)
#     target_link_options(${PROJECT_NAME} PRIVATE -flto -fno-except -sASYNCIFY -Os -sDISABLE_EXCEPTION_THROWING=0 -sDISABLE_EXCEPTION_CATCHING=0)
#     target_link_libraries(${PROJECT_NAME} PRIVATE
#         Qt${QT_VERSION_MAJOR}::Core
#         Qt${QT_VERSION_MAJOR}::Quick
#         Qt${QT_VERSION_MAJOR}::Svg
#         Qt${QT_VERSION_MAJOR}::Gui
#         Qt${QT_VERSION_MAJOR}::Qml
#         Qt${QT_VERSION_MAJOR}::QuickControls2
#         Qt${QT_VERSION_MAJOR}::Network
#         KF${QT_VERSION_MAJOR}::Kirigami
#         Kirigamiplugin
#     )
# elseif(HAIKU)
#     target_link_libraries(${PROJECT_NAME} PRIVATE
#         Qt${QT_VERSION_MAJOR}::Core
#         Qt${QT_VERSION_MAJOR}::Quick
#         Qt${QT_VERSION_MAJOR}::Gui
#         Qt${QT_VERSION_MAJOR}::Svg
#         Qt${QT_VERSION_MAJOR}::Qml
#         Qt${QT_VERSION_MAJOR}::QuickControls2
#         Qt${QT_VERSION_MAJOR}::Network
#         Qt${QT_VERSION_MAJOR}::Widgets
#         KF${QT_VERSION_MAJOR}::CoreAddons
#         KF${QT_VERSION_MAJOR}::Kirigami
#         KF${QT_VERSION_MAJOR}::IconThemes
#     )
# elseif(WIN32 OR APPLE)
#     target_link_libraries(${PROJECT_NAME} PRIVATE
#         Qt${QT_VERSION_MAJOR}::Core
#         Qt${QT_VERSION_MAJOR}::Quick
#         Qt${QT_VERSION_MAJOR}::Gui
#         Qt${QT_VERSION_MAJOR}::Svg
#         Qt${QT_VERSION_MAJOR}::Qml
#         Qt${QT_VERSION_MAJOR}::QuickControls2
#         Qt${QT_VERSION_MAJOR}::Network
#         Qt${QT_VERSION_MAJOR}::Widgets
#         KF${QT_VERSION_MAJOR}::Kirigami
#         KF${QT_VERSION_MAJOR}::CoreAddons
#     )
# else()
#     target_link_libraries(${PROJECT_NAME} PRIVATE
#         Qt${QT_VERSION_MAJOR}::Core
#         Qt${QT_VERSION_MAJOR}::Quick
#         Qt${QT_VERSION_MAJOR}::Gui
#         Qt${QT_VERSION_MAJOR}::Svg
#         Qt${QT_VERSION_MAJOR}::Qml
#         Qt${QT_VERSION_MAJOR}::QuickControls2
#         Qt${QT_VERSION_MAJOR}::Network
#         Qt${QT_VERSION_MAJOR}::Widgets
#         KF${QT_VERSION_MAJOR}::CoreAddons
#         KF${QT_VERSION_MAJOR}::Kirigami
#     )
# endif()

# if(APPLE AND NOT IOS)
#     target_include_directories(mactouchbar PRIVATE ${kdmactouchbar_SOURCE_DIR}/KDMacTouchBar)
#     target_link_directories(mactouchbar PRIVATE ${kdmactouchbar_SOURCE_DIR}/KDMacTouchBar)
#     target_link_libraries(${PROJECT_NAME} PRIVATE KDMacTouchBar)
# endif()
# if (QHotkey_FOUND)
#     add_definitions(-DQHotkey_FOUND)
#     target_link_libraries(${PROJECT_NAME} PRIVATE
#         qhotkey
#     )
# endif()

# execute_process(COMMAND ${CMAKE_PREFIX_PATH}/bin/lconvert -pluralonly ${CMAKE_SOURCE_DIR}/po/qprompt_en.ts)

# Installation and bundling
# if (APPLE)
#     install(TARGETS ${PROJECT_NAME} ${KDE_INSTALL_TARGETS_DEFAULT_ARGS} BUNDLE DESTINATION .)
#     install(TARGETS KF6CoreAddons ${KDE_INSTALL_TARGETS_DEFAULT_ARGS} FRAMEWORK DESTINATION QPrompt.app/Contents/Frameworks)
#     install(TARGETS Kirigami ${KDE_INSTALL_TARGETS_DEFAULT_ARGS} FRAMEWORK DESTINATION QPrompt.app/Contents/Frameworks)
#     install(DIRECTORY ../build/bin/org DESTINATION QPrompt.app/Contents/Resources/qml)
#     install(DIRECTORY ../build/bin/org DESTINATION QPrompt.app/Contents/MacOS/qml)
# elseif (ANDROID)
    # install(TARGETS ${PROJECT_NAME}
    #     BUNDLE  DESTINATION . # ${KDE_INSTALL_APPDIR}
    #     RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    #     LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    # )
    install(TARGETS ${PROJECT_NAME} ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
# elseif (WIN32 OR UNIX)
#     install(FILES com.cuperino.qprompt.appdata.xml DESTINATION ${KDE_INSTALL_METAINFODIR})
#     install(PROGRAMS com.cuperino.qprompt.desktop DESTINATION ${KDE_INSTALL_APPDIR})
    # install(TARGETS ${PROJECT_NAME} ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
# endif()

# if(APPLE)
#     set(MACOS_SIGNING_IDENTITY "")
#     set(EXTRA_DEPLOY_QML_APP_SCRIPT_OPTIONS)
#     set(deploy_tool_options_arg "-always-overwrite -appstore-compliant -sign-for-notarization=${MACOS_SIGNING_IDENTITY}")
#     list(APPEND EXTRA_DEPLOY_QML_APP_SCRIPT_OPTIONS DEPLOY_TOOL_OPTIONS ${deploy_tool_options_arg})
#     qt_generate_deploy_qml_app_script(
#         TARGET ${PROJECT_NAME}
#         OUTPUT_SCRIPT deploy_script
#         ${EXTRA_DEPLOY_QML_APP_SCRIPT_OPTIONS}
#         MACOS_BUNDLE_POST_BUILD
#     )
# elseif(WIN32)
#     qt_generate_deploy_qml_app_script(
#         TARGET ${PROJECT_NAME}
#         OUTPUT_SCRIPT deploy_script
#         # NO_UNSUPPORTED_PLATFORM_ERROR
#         # DEPLOY_USER_QML_MODULES_ON_UNSUPPORTED_PLATFORM
#     )
# else()
    qt_generate_deploy_qml_app_script(
        TARGET ${PROJECT_NAME}
        OUTPUT_SCRIPT deploy_script
        NO_UNSUPPORTED_PLATFORM_ERROR
        DEPLOY_USER_QML_MODULES_ON_UNSUPPORTED_PLATFORM
    )
# endif()
# if (ANDROID OR APPLE OR NOT UNIX)
    install(SCRIPT ${deploy_script})
# endif()



# if (ANDROID)
    # configure_file(${ANDROID_PACKAGE_SOURCE_DIR}/version.gradle.in ${CMAKE_BINARY_DIR}/version.gradle)
# endif()other_sources

# if (UNIX AND NOT APPLE AND NOT ANDROID)
#     set(DOC_INSTALL_DIR "share/doc/qprompt")
#     set(MAN_INSTALL_DIR "share/man/")
#     install(FILES docs/manpage/qprompt.1 DESTINATION ${MAN_INSTALL_DIR}/man1)
# endif()

# if (WIN32 OR UNIX AND NOT APPLE AND NOT ANDROID)
#     install(FILES com.cuperino.qprompt.appdata.xml DESTINATION ${KDE_INSTALL_METAINFODIR})
#     install(PROGRAMS com.cuperino.qprompt.desktop DESTINATION ${KDE_INSTALL_APPDIR})
#     install(FILES ${DOCS} DESTINATION ${DOC_INSTALL_DIR})
# endif()

# set(CMAKE_INSTALL_MFC_LIBRARIES On)
# set(InstallRequiredSystemLibraries On)
# include(InstallRequiredSystemLibraries)

# set(CMAKE_OSX_DEPLOYMENT_TARGET "10.15")
# set(CMAKE_OSX_ARCHITECTURES="x86_64;arm64")

# if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
#     # CPACK: General Settings
#     set(CPACK_PACKAGE_VENDOR "Javier O. Cordero Pérez")
#     set(CPACK_PACKAGE_CONTACT "javiercorderoperez@gmail.com")
#     set(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_SOURCE_DIR}/${DESCRIPTION_FILE}")
#     set(CPACK_RESOURCE_FILE_README "${CMAKE_SOURCE_DIR}/${README_FILE}")
#     set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_SOURCE_DIR}/${LICENSE_FILE}")  # Displays the license on some installers
#     set(CPACK_VERBATIM_VARIABLES On)
#     set(CPACK_MONOLITHIC_INSTALL On)

#     set(CPACK_RPM_PACKAGE_LICENSE "GPLv3")  # Also used by FreeBSD generator

#     set(ICONS_DIR "${CMAKE_SOURCE_DIR}/src/icons")
#     set(IMAGES_DIR "${CMAKE_SOURCE_DIR}/src/images")
#     set(COMPRESION_TYPE "xz")

#     # CPACK: Archive generator settings
#     set(CPACK_THREADS 0)
#     set(CPACK_ARCHIVE_THREADS 0)

#     if(UNIX AND NOT ANDROID AND NOT APPLE)
#         set(CPACK_GENERATOR "DEB")

#         # CPACK: DEB specific settings
#         set(CPACK_DEBIAN_PACKAGE_SECTION "Multimedia")
#         set(CPACK_DEBIAN_COMPRESSION_TYPE ${COMPRESION_TYPE})
#         set(CPACK_DEBIAN_PACKAGE_DEPENDS "libvulkan-dev (>= 1.4.309), libqt6svg6 (>= 6.7.2), libqt6qmlworkerscript6 (>=6.7.2), qml6-module-qt-labs-platform (>=6.7.2), qml6-module-qtqml (>=6.7.2), qml6-module-qtqml-models (>=6.7.2), qml6-module-qtqml-statemachine (>=6.7.2), qml6-module-qtquick-controls (>=6.7.2), qml6-module-qtcore (>=6.7.2), qml6-module-qt-labs-settings (>=6.7.2), qml6-module-qtquick-dialogs (>=6.7.2), qml6-module-qtquick-shapes (>=6.7.2), libkf6coreaddons6 (>= 6.9.0), libkirigami6 (>= 6.9.0), qml6-module-org-kde-kirigami (>=6.9.0), libkf6i18n6 (>= 6.9.0), libkf6crash6 (>= 6.9.0)")

#         # CPACK: RPM specific settings
#         set(CPACK_RPM_PACKAGE_GROUP "Multimedia/Video")
#         set(CPACK_RPM_PACKAGE_REQUIRES "qt6-qtbase >= 6.7.2, qt6-qtbase-gui >= 6.7.2, qt6-qtdeclarative >= 6.7.2, qt6-qtsvg >= 6.7.2, qt6-qtquickcontrols2 >= 6.7.2, kf6-kcoreaddons >= 6.9.0, kf6-kirigami >= 6.9.0, kf6-kcrash >= 6.9.0")
#         set(CPACK_RPM_COMPRESSION_TYPE ${COMPRESION_TYPE})

#     elseif(WIN32)
#         set(CPACK_GENERATOR "NSIS")
#         set(CPACK_PACKAGE_EXECUTABLES "QPrompt" "QPrompt")
#         set(CPACK_RESOURCE_FILE_LICENSE ${CMAKE_SOURCE_DIR}/${LICENSE_FILE})
#         set(CPACK_NSIS_EXECUTABLES_DIRECTORY ${BIN_INSTALL_DIR})
#         set(CPACK_NSIS_MUI_ICON ${ICONS_DIR}/qprompt.ico)
#         set(CPACK_NSIS_MUI_UNIICON ${ICONS_DIR}/qprompt.ico)
#         set(CPACK_NSIS_INSTALLED_ICON_NAME ${BIN_INSTALL_DIR}/QPrompt.exe)
#         set(CPACK_NSIS_CONTACT ${CPACK_PACKAGE_CONTACT})
#         set(CPACK_NSIS_INSTALLED_ICON_NAME "qprompt${CMAKE_EXECUTABLE_SUFFIX}")
#         set(CPACK_NSIS_MENU_LINKS
#             ${CMAKE_SOURCE_DIR}/${LICENSE_FILE} "License"
#             ${CMAKE_SOURCE_DIR}/${README_FILE} "Readme"
#         )
#         set(CPACK_NSIS_MUI_FINISHPAGE_RUN "${CPACK_NSIS_INSTALLED_ICON_NAME}")

#     elseif(APPLE AND NOT IOS)
#         set(CPACK_GENERATOR "DragNDrop")
#         set(CPACK_DMG_FORMAT "UDBZ")
#         set(CPACK_DMG_VOLUME_NAME "QPrompt")
#         set(CPACK_BUNDLE_NAME "QPrompt")
#         set(CPACK_BUNDLE_ICON "${ICONS_DIR}/qprompt.icns")
#         # set(CPACK_BUNDLE_PLIST "Info.plist")
#         set(CPACK_SYSTEM_NAME "OSX")
#         set(CPACK_PACKAGE_FILE_NAME "QPrompt-${PROJECT_VERSION}")
#         set(CPACK_PACKAGE_ICON "${ICONS_DIR}/qprompt.icns")
#         set(CPACK_DMG_SLA_USE_RESOURCE_FILE_LICENSE ${LICENSE_FILE})
#         #set(CPACK_DMG_DS_STORE "${IMAGES_DIR}/DSStore")
#         set(CPACK_DMG_BACKGROUND_IMAGE "${IMAGES_DIR}/DMGBackground.png")
#         set(CPACK_DMG_DS_STORE_SETUP_SCRIPT "${CMAKE_SOURCE_DIR}/dist/macOS/DS_Store.scpt")

#     elseif(BSD AND NOT APPLE)
#         set(CPACK_FREEBSD_PACKAGE_MAINTAINER ${CPACK_PACKAGE_CONTACT})
#         set(CPACK_FREEBSD_PACKAGE_ORIGIN "multimedia")
#         set(CPACK_FREEBSD_PACKAGE_CATEGORIES "devel/qt6-base, x11-toolkits/qt6-declarative, graphics/qt6-svg, x11-toolkits/qt6-shadertools, multimedia/qt6-multimedia, devel/kf6-kcoreaddons, x11-toolkits/kf6-kirigami, devel/kf6-kcrash, x11-themes/kf6-kiconthemes, x11-toolkits/qhotkey")
#     endif()

#     include(CPack)
# endif()

# if(NOT WASM)
#     feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES) # INCLUDE_QUIET_PACKAGES
# endif()

# file(GLOB_RECURSE ALL_CLANG_FORMAT_SOURCE_FILES *.cpp *.h *.hpp)
# kde_clang_format(${ALL_CLANG_FORMAT_SOURCE_FILES})
