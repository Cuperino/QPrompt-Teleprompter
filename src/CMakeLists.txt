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

if(NOT WIN32)
    include(ECMPoQmTools)
endif()

qt_standard_project_setup(I18N_TRANSLATED_LANGUAGES ar cs de en es fi fr he it ja ko nl oc pl pt_BR pt_PT ru tr uk zh)

set(CMAKE_OSX_DEPLOYMENT_TARGET "10.15")
set(CMAKE_OSX_ARCHITECTURES="x86_64;arm64")

if (ANDROID OR IOS OR WASM)
    qt_add_executable(${PROJECT_NAME}
        main.cpp
    )
else()
    qt_add_executable(${PROJECT_NAME}
        main.cpp
        systemfontchooserdialog.h
        systemfontchooserdialog.cpp
    )
endif()
if (NOT ANDROID AND NOT IOS)
    qt_wrap_ui(${PROJECT_NAME}
        qt/systemfontchooserdialog.ui
    )
endif()

if (NOT ANDROID AND NOT WASM AND NOT IOS)
    set(ICONS_FOLDER ${CMAKE_CURRENT_SOURCE_DIR}/icons/hicolor)
    set(RASTER_ICONS
        ${ICONS_FOLDER}/16-apps-com.cuperino.qprompt.png
        ${ICONS_FOLDER}/32-apps-com.cuperino.qprompt.png
        ${ICONS_FOLDER}/48-apps-com.cuperino.qprompt.png
        ${ICONS_FOLDER}/64-apps-com.cuperino.qprompt.png
        ${ICONS_FOLDER}/128-apps-com.cuperino.qprompt.png
        ${ICONS_FOLDER}/256-apps-com.cuperino.qprompt.png
        ${ICONS_FOLDER}/512-apps-com.cuperino.qprompt.png
        # ${ICONS_FOLDER}/1024-apps-com.cuperino.qprompt.png  # Flatpak has a maximum size of 512
    )
    # set(VECTOR_ICON
    #     ${ICONS_FOLDER}/sc-apps-com.cuperino.qprompt.svg
    # )
    if (NOT APPLE)
        ecm_install_icons(
            ICONS
                ${RASTER_ICONS}
                # ${VECTOR_ICON}
            DESTINATION ${KDE_INSTALL_ICONDIR}
            # THEME hicolor
        )
    endif()
    ecm_add_app_icon(${PROJECT_NAME}
        ICONS ${RASTER_ICONS}
    )
endif()

set(qprompt_cpp
    qmlutil.hpp
    abstractunits.hpp
    marker.hpp
    documenthandler.h documenthandler.cpp
    markersmodel.h markersmodel.cpp
    abstractinputsource.h abstractinputsource.cpp
    globalhotkeys.h globalhotkeys.cpp
    appcontroller.h appcontroller.cpp
    ${qprompt_QM_LOADER}
)
if(HUNSPELL_ENABLED)
    list(APPEND qprompt_cpp
        spellchecker.h spellchecker.cpp
        spellhighlighter.h spellhighlighter.cpp
    )
endif()
if(IOS)
    list(APPEND qprompt_cpp shakedetector.h shakedetector.mm)
    list(APPEND qprompt_cpp iossavedialog.h iossavedialog.mm)
else()
    list(APPEND qprompt_cpp shakedetector.h shakedetector.cpp)
    list(APPEND qprompt_cpp iossavedialog.h iossavedialog.cpp)
endif()
if(WASM)
    list(APPEND qprompt_cpp wasmintegration.h wasmintegration.cpp)
endif()

if (WASM)
    set(qprompt_frontend_sources
        # Kirigami UI Frontend
        kirigami_ui/main.qml
        kirigami_ui/AboutPage.qml
        kirigami_ui/PathsPage.qml
        kirigami_ui/PrompterPage.qml
        kirigami_ui/EditorToolbar.qml
        kirigami_ui/MarkersDrawer.qml
        kirigami_ui/InputsOverlay.qml
        kirigami_ui/KeyInputButton.qml
        kirigami_ui/WheelSettingsOverlay.qml
        kirigami_ui/LayoutDirectionSettingsOverlay.qml
        kirigami_ui/LanguageSettingsOverlay.qml
        kirigami_ui/RecentDocuments.qml
        kirigami_ui/OnlineResourceButtons.qml
    )
else()
    set(qprompt_frontend_sources
        # Kirigami UI Frontend
        kirigami_ui/main.qml
        kirigami_ui/+android/main.qml
        kirigami_ui/+windows/main.qml
        kirigami_ui/AboutPage.qml
        kirigami_ui/PathsPage.qml
        kirigami_ui/PrompterPage.qml
        kirigami_ui/TelemetryPage.qml
        kirigami_ui/RemotePage.qml
        kirigami_ui/EditorToolbar.qml
        kirigami_ui/MarkersDrawer.qml
        kirigami_ui/InputsOverlay.qml
        kirigami_ui/KeyInputButton.qml
        kirigami_ui/WheelSettingsOverlay.qml
        kirigami_ui/LayoutDirectionSettingsOverlay.qml
        kirigami_ui/LanguageSettingsOverlay.qml
        kirigami_ui/RecentDocuments.qml
        kirigami_ui/OnlineResourceButtons.qml
    )
endif()

set(prompter_sources
    # Prompter component
    prompter/PrompterView.qml
    prompter/Prompter.qml
    prompter/ProgressIndicator.qml
    prompter/Countdown.qml
    prompter/TimerClock.qml
    prompter/ReadRegionOverlay.qml
    prompter/PrompterBackground.qml
    prompter/Flip.qml
    prompter/ProjectionsManager.qml
    prompter/Find.qml
    prompter/CursorAutoHide.qml
    prompter/PointerSettings.qml
    # Pointers
    prompter/pointers/pointer_0.qml
    prompter/pointers/pointer_1.qml
    prompter/pointers/pointer_2.qml
)

set(other_sources
    # Other QML
    qt/WindowDragger.qml
)

if (ANDROID OR IOS)
set(image_files
    # Logos
    images/qprompt.png
    images/qprompt-logo-wireframe.png
    # Pointers
    images/left_hand.png
    images/right_hand.png
)
else()
    set(image_files
        # Logos
        images/qprompt.png
        # Pointers
        images/left_hand.png
        images/right_hand.png
    )
endif()
# Fonts
set(font_files
    fonts/icons/fontello.ttf
    fonts/editor/dejavu-sans/DejaVuSans.ttf
    fonts/editor/LibertinusSans-Regular.otf
    fonts/editor/OpenDyslexic-Bold.otf
    fonts/editor/ScheherazadeNew/ScheherazadeNew-Regular.ttf
    fonts/editor/Kalpurush/Kalpurush.ttf
    fonts/editor/Palanquin-Regular.ttf
    # fonts/editor/Libertinus/static/OTF/LibertinusSerif-Regular.otf
    fonts/editor/SourceHanSans/SourceHanSans-Regular.ttc
    # Color emoji fallback. Qt's WASM platform plugin bundles only DejaVu
    # Sans (no emoji glyphs) and the browser provides no system font
    # fallback, so emoji render as tofu without this. Other platforms have
    # system emoji fonts, but bundling keeps rendering consistent.
    fonts/editor/noto-emoji/NotoColorEmoji-COLRv1.ttf
)
foreach(file IN LISTS font_files)
    get_filename_component(filename ${file} NAME)
    set_source_files_properties(${file} PROPERTIES QT_RESOURCE_ALIAS fonts/${filename})
endforeach()

# Documents
set(document_files
    documents/untitled.html
    documents/welcome_ar.html
    documents/welcome_cs.html
    documents/welcome_de.html
    documents/welcome_en.html
    documents/welcome_es.html
    documents/welcome_fi.html
    documents/welcome_fr.html
    documents/welcome_he.html
    documents/welcome_it.html
    documents/welcome_ja.html
    documents/welcome_ko.html
    documents/welcome_nl.html
    documents/welcome_oc.html
    documents/welcome_pl.html
    documents/welcome_pt_BR.html
    documents/welcome_pt_PT.html
    documents/welcome_ru.html
    documents/welcome_uk.html
    documents/welcome_tr.html
    documents/welcome_zh.html
)
set_source_files_properties(documents/untitled.html PROPERTIES QT_RESOURCE_ALIAS documents/blank.html)

set(icon_files
    # Application-specific raster icon with no Breeze equivalent; still referenced
    # by icon.source. Every other icon is now referenced by icon.name and supplied
    # by the bundled Breeze subset theme (see qprompt_generate_breeze_subset below).
    icons/logos/obs.png
)

foreach(file IN LISTS icon_files doc)
    get_filename_component(filename ${file} NAME)
    set_source_files_properties(${file} PROPERTIES QT_RESOURCE_ALIAS icons/${filename})
endforeach()

# App QML Module
qt_add_qml_module(
    ${PROJECT_NAME}
    URI com.cuperino.qprompt
    VERSION 1.0
    RESOURCE_PREFIX /qt/qml/
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

if (UNIX AND NOT APPLE)
    set(OUTPUT_NAME "qprompt")
else()
    set(OUTPUT_NAME "QPrompt")
endif()
set_target_properties(${PROJECT_NAME} PROPERTIES
    MACOSX_BUNDLE_BUNDLE_NAME "QPrompt"
    MACOSX_BUNDLE_GUI_IDENTIFIER com.cuperino.qprompt
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_COPYRIGHT "Copyright Javier O. Cordero Pérez"
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    OUTPUT_NAME ${OUTPUT_NAME}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
    INTERFACE_LINK_LIBRARIES "KF${QT_VERSION_MAJOR}::Kirigami"
    QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_SOURCE_DIR}/android"
    QT_ANDROID_PACKAGE_NAME "com.cuperino.qprompt"
    QT_QMLCACHEGEN_ARGUMENTS "--only-bytecode"
    # QT_QMLCACHEGEN_ARGUMENTS "--static"  # "--static;--verbose"
    # QT_QMLCACHEGEN_DIRECT_CALLS OFF
    # PLUGIN_TARGET qtlabsplatformplugin inhibits the creation of the backing library, thus headers can't be accessed in direct mode.
    # See issue: https://bugreports.qt.io/browse/QTBUG-117992?focusedId=750577&page=com.atlassian.jira.plugin.system.issuetabpanels%3Acomment-tabpanel#comment-750577
)

# Qt 6.10+ creates Android executables as MODULE libraries. KDECMakeSettings strips
# the "lib" prefix from MODULE targets, but androiddeployqt expects it.
# Also place the binary in BINARY_DIR so it's next to the deployment settings and
# android-build dir, which Qt Creator requires for consistent path resolution.
if (ANDROID)
    set_target_properties(${PROJECT_NAME} PROPERTIES
        PREFIX "lib"
        LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
    )
endif()

if (NOT IOS)
    qt_add_resources(${PROJECT_NAME} "fonts"
        PREFIX "/qt/qml/com/cuperino/qprompt/"
        BIG_RESOURCES
        FILES
        ${font_files}
    )
else()
    qt_add_resources(${PROJECT_NAME} "fonts"
        PREFIX "/qt/qml/com/cuperino/qprompt/"
        FILES
        ${font_files}
    )
endif()

# Bundle a subset of the Breeze icon theme containing only the icons referenced
# by name in the QML, compiled into the binary at :/icons/breeze-internal. With
# QIcon::setThemeName("breeze-internal") (set in main.cpp) this makes icon.name
# lookups resolve on every platform — including Windows, macOS, WASM, Android and
# iOS, none of which provide a system icon theme — without shipping all of Breeze.
include(BreezeIconSubset)
qprompt_generate_breeze_subset(${PROJECT_NAME}
    BREEZE_DIR "${CMAKE_SOURCE_DIR}/3rdparty/breeze-icons"
    QML_DIR "${CMAKE_CURRENT_SOURCE_DIR}"
    OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/breeze-theme"
    CUSTOM_ICON_FILES "${CMAKE_CURRENT_SOURCE_DIR}/icons/16/view-list-text-rtl.svg"
)

# Shader compilation
qt_add_shaders(
    ${PROJECT_NAME}
    "qp_shaders"
    PREFIX "/qt/qml/com/cuperino/qprompt"
    FILES
    "shaders/blur.frag"
    "shaders/shadow.frag"
    "shaders/tint.frag"
)

qt_add_translations(${PROJECT_NAME} SOURCE_TARGETS ${PROJECT_NAME}
    TS_FILE_DIR ${CMAKE_SOURCE_DIR}/po
    PLURALS_TS_FILE ${CMAKE_SOURCE_DIR}/po/qprompt_en.ts
    LUPDATE_OPTIONS -source-language en
    LRELEASE_OPTIONS -compress  # -idbased
)

# Bundle Hunspell dictionaries as Qt resources for static builds
# (WASM/Android/iOS) and the macOS DMG. this allows them to be found at
# :/dictionaries/<lang>.{aff,dic}
if(DEFINED QPROMPT_HUNSPELL_DICT_DIR AND (WASM OR ANDROID OR IOS OR (APPLE AND NOT IOS)))
    qprompt_hunspell_add_qrc(${PROJECT_NAME} "${QPROMPT_HUNSPELL_DICT_DIR}")
endif()

# Libraries
if (ANDROID)
    target_link_libraries(${PROJECT_NAME} PRIVATE
        Qt${QT_VERSION_MAJOR}::Core
        Qt${QT_VERSION_MAJOR}::Quick
        Qt${QT_VERSION_MAJOR}::Svg
        Qt${QT_VERSION_MAJOR}::Gui
        Qt${QT_VERSION_MAJOR}::Qml
        Qt${QT_VERSION_MAJOR}::QuickControls2
        Qt${QT_VERSION_MAJOR}::Network
        KF${QT_VERSION_MAJOR}::CoreAddons
        KF${QT_VERSION_MAJOR}::Kirigami
        Kirigamiplugin
    )
elseif (IOS)
    set(CMAKE_OSX_DEPLOYMENT_TARGET 17.0)

    # iOS code signing identity (use "iPhone Developer" for dev builds, "iPhone Distribution" for release)
    set(IOS_CODE_SIGN_IDENTITY "iPhone Developer" CACHE STRING "iOS code signing identity")
    set(IOS_ENTITLEMENTS_FILE "${CMAKE_CURRENT_SOURCE_DIR}/ios/QPrompt.entitlements" CACHE FILEPATH "iOS entitlements file")
    set(IOS_PROVISIONING_PROFILE "" CACHE FILEPATH "Path to iOS provisioning profile (.mobileprovision)")

    # Use custom Info.plist to set display name and app icon references
    set_target_properties(${PROJECT_NAME} PROPERTIES
        MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_SOURCE_DIR}/ios/Info.plist.in"
    )

    # Bundle iOS app icon files
    set(IOS_ICONS_DIR "${CMAKE_CURRENT_SOURCE_DIR}/ios/icons")
    set(IOS_ICON_FILES
        ${IOS_ICONS_DIR}/AppIcon120x120.png
        ${IOS_ICONS_DIR}/AppIcon152x152.png
        ${IOS_ICONS_DIR}/AppIcon167x167.png
        ${IOS_ICONS_DIR}/AppIcon180x180.png
        ${IOS_ICONS_DIR}/AppIcon1024x1024.png
    )
    set_source_files_properties(${IOS_ICON_FILES} PROPERTIES MACOSX_PACKAGE_LOCATION Resources)
    target_sources(${PROJECT_NAME} PRIVATE ${IOS_ICON_FILES})

    target_link_libraries(${PROJECT_NAME} PRIVATE
        Qt${QT_VERSION_MAJOR}::Core
        Qt${QT_VERSION_MAJOR}::Quick
        Qt${QT_VERSION_MAJOR}::Svg
        Qt${QT_VERSION_MAJOR}::Qml
        Qt${QT_VERSION_MAJOR}::QuickControls2
        KF${QT_VERSION_MAJOR}::CoreAddons
        KF${QT_VERSION_MAJOR}::Kirigami
        Kirigamiplugin
    )
elseif (WASM)
    target_compile_options(${PROJECT_NAME} PRIVATE -O3 -flto -sDISABLE_EXCEPTION_THROWING=0 -sDISABLE_EXCEPTION_CATCHING=1)
    target_link_options(${PROJECT_NAME} PRIVATE -flto -fno-except -Oz -sDISABLE_EXCEPTION_THROWING=0 -sDISABLE_EXCEPTION_CATCHING=1)

    # Qt for WASM defaults INITIAL_MEMORY to 50MB, but bundled resources
    # (fonts, hunspell dictionaries, QML cache) push static data past that.
    set_target_properties(${PROJECT_NAME} PROPERTIES QT_WASM_INITIAL_MEMORY "80MB")

    target_link_libraries(${PROJECT_NAME} PRIVATE
        Qt${QT_VERSION_MAJOR}::Core
        Qt${QT_VERSION_MAJOR}::Quick
        Qt${QT_VERSION_MAJOR}::Svg
        Qt${QT_VERSION_MAJOR}::Qml
        Qt${QT_VERSION_MAJOR}::QuickControls2
        KF${QT_VERSION_MAJOR}::Kirigami
        Kirigamiplugin
    )
elseif(HAIKU)
    target_link_libraries(${PROJECT_NAME} PRIVATE
        Qt${QT_VERSION_MAJOR}::Core
        Qt${QT_VERSION_MAJOR}::Quick
        Qt${QT_VERSION_MAJOR}::Gui
        Qt${QT_VERSION_MAJOR}::Svg
        Qt${QT_VERSION_MAJOR}::Qml
        Qt${QT_VERSION_MAJOR}::QuickControls2
        Qt${QT_VERSION_MAJOR}::Network
        Qt${QT_VERSION_MAJOR}::Widgets
        KF${QT_VERSION_MAJOR}::CoreAddons
        KF${QT_VERSION_MAJOR}::Kirigami
        KF${QT_VERSION_MAJOR}::IconThemes
        KF${QT_VERSION_MAJOR}::GlobalAccel
    )
elseif(WIN32 OR APPLE AND NOT IOS)
    target_link_libraries(${PROJECT_NAME} PRIVATE
        Qt${QT_VERSION_MAJOR}::Core
        Qt${QT_VERSION_MAJOR}::Quick
        Qt${QT_VERSION_MAJOR}::Gui
        Qt${QT_VERSION_MAJOR}::Svg
        Qt${QT_VERSION_MAJOR}::Qml
        Qt${QT_VERSION_MAJOR}::QuickControls2
        Qt${QT_VERSION_MAJOR}::Network
        Qt${QT_VERSION_MAJOR}::Widgets
        KF${QT_VERSION_MAJOR}::Kirigami
        KF${QT_VERSION_MAJOR}::CoreAddons
    )
else()
    target_link_libraries(${PROJECT_NAME} PRIVATE
        Qt${QT_VERSION_MAJOR}::Core
        Qt${QT_VERSION_MAJOR}::Quick
        Qt${QT_VERSION_MAJOR}::Gui
        Qt${QT_VERSION_MAJOR}::Svg
        Qt${QT_VERSION_MAJOR}::Qml
        Qt${QT_VERSION_MAJOR}::QuickControls2
        Qt${QT_VERSION_MAJOR}::Network
        Qt${QT_VERSION_MAJOR}::Widgets
        KF${QT_VERSION_MAJOR}::CoreAddons
        KF${QT_VERSION_MAJOR}::Kirigami
        KF${QT_VERSION_MAJOR}::GlobalAccel
    )
endif()

if(APPLE AND NOT IOS)
    target_include_directories(mactouchbar PRIVATE ${kdmactouchbar_SOURCE_DIR}/KDMacTouchBar)
    target_link_directories(mactouchbar PRIVATE ${kdmactouchbar_SOURCE_DIR}/KDMacTouchBar)
    target_link_libraries(${PROJECT_NAME} PRIVATE KDMacTouchBar)
endif()
if (QHotkey_FOUND)
    add_definitions(-DQHotkey_FOUND)
    target_link_libraries(${PROJECT_NAME} PRIVATE
        qhotkey
    )
endif()

if(HUNSPELL_ENABLED)
    if(TARGET Hunspell::Hunspell)
        target_link_libraries(${PROJECT_NAME} PRIVATE Hunspell::Hunspell)
    elseif(TARGET hunspell)
        target_link_libraries(${PROJECT_NAME} PRIVATE hunspell)
    elseif(TARGET PkgConfig::HUNSPELL)
        target_link_libraries(${PROJECT_NAME} PRIVATE PkgConfig::HUNSPELL)
    endif()
endif()

execute_process(COMMAND ${CMAKE_PREFIX_PATH}/bin/lconvert -pluralonly ${CMAKE_SOURCE_DIR}/po/qprompt_en.ts)

# Installation and bundling
if (APPLE)
    install(TARGETS ${PROJECT_NAME} ${KDE_INSTALL_TARGETS_DEFAULT_ARGS} BUNDLE DESTINATION .)
    if(NOT IOS)
        install(TARGETS KF6CoreAddons ${KDE_INSTALL_TARGETS_DEFAULT_ARGS} FRAMEWORK DESTINATION QPrompt.app/Contents/Frameworks)
    endif()
    install(TARGETS Kirigami ${KDE_INSTALL_TARGETS_DEFAULT_ARGS} FRAMEWORK DESTINATION QPrompt.app/Contents/Frameworks)
    install(DIRECTORY ../build/bin/org DESTINATION QPrompt.app/Contents/Resources/qml)
    install(DIRECTORY ../build/bin/org DESTINATION QPrompt.app/Contents/MacOS/qml)
elseif (WIN32 OR UNIX)
    install(FILES com.cuperino.qprompt.appdata.xml DESTINATION ${KDE_INSTALL_METAINFODIR})
    install(PROGRAMS com.cuperino.qprompt.desktop DESTINATION ${KDE_INSTALL_APPDIR})
    install(TARGETS ${PROJECT_NAME} ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
endif()

if(APPLE AND NOT IOS)
    set(MACOS_SIGNING_IDENTITY "")
    set(EXTRA_DEPLOY_QML_APP_SCRIPT_OPTIONS)
    set(deploy_tool_options_arg "-always-overwrite -appstore-compliant -sign-for-notarization=${MACOS_SIGNING_IDENTITY}")
    list(APPEND EXTRA_DEPLOY_QML_APP_SCRIPT_OPTIONS DEPLOY_TOOL_OPTIONS ${deploy_tool_options_arg})
    qt_generate_deploy_qml_app_script(
        TARGET ${PROJECT_NAME}
        OUTPUT_SCRIPT deploy_script
        ${EXTRA_DEPLOY_QML_APP_SCRIPT_OPTIONS}
        MACOS_BUNDLE_POST_BUILD
    )
elseif(IOS)
    qt_generate_deploy_qml_app_script(
        TARGET ${PROJECT_NAME}
        OUTPUT_SCRIPT deploy_script
        NO_UNSUPPORTED_PLATFORM_ERROR
        DEPLOY_USER_QML_MODULES_ON_UNSUPPORTED_PLATFORM
    )

    # Find provisioning profile if not explicitly set
    if(NOT IOS_PROVISIONING_PROFILE OR IOS_PROVISIONING_PROFILE STREQUAL "")
        file(GLOB _ios_profiles "$ENV{HOME}/Library/Developer/Xcode/UserData/Provisioning Profiles/*.mobileprovision")
        if(_ios_profiles)
            list(GET _ios_profiles 0 IOS_PROVISIONING_PROFILE)
        endif()
    endif()

    # Post-build: embed provisioning profile and codesign the app bundle
    if(IOS_PROVISIONING_PROFILE)
        add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy "${IOS_PROVISIONING_PROFILE}" "$<TARGET_BUNDLE_DIR:${PROJECT_NAME}>/embedded.mobileprovision"
            COMMENT "Embedding provisioning profile into ${PROJECT_NAME}.app"
        )
    else()
        message(WARNING "No iOS provisioning profile found. Set IOS_PROVISIONING_PROFILE to the path of your .mobileprovision file.")
    endif()
    add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND codesign --force --sign "${IOS_CODE_SIGN_IDENTITY}" --entitlements "${IOS_ENTITLEMENTS_FILE}" --timestamp=none --generate-entitlement-der "$<TARGET_BUNDLE_DIR:${PROJECT_NAME}>"
        COMMENT "Code signing ${PROJECT_NAME}.app for iOS"
    )
elseif(WIN32)
    qt_generate_deploy_qml_app_script(
        TARGET ${PROJECT_NAME}
        OUTPUT_SCRIPT deploy_script
        # NO_UNSUPPORTED_PLATFORM_ERROR
        # DEPLOY_USER_QML_MODULES_ON_UNSUPPORTED_PLATFORM
    )
else()
    qt_generate_deploy_qml_app_script(
        TARGET ${PROJECT_NAME}
        OUTPUT_SCRIPT deploy_script
        NO_UNSUPPORTED_PLATFORM_ERROR
    )
endif()
if (NOT UNIX OR APPLE)
    install(SCRIPT ${deploy_script})
endif()
