#**************************************************************************
#
# QPrompt
# Copyright (C) 2020-2024 Javier O. Cordero Pérez
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
    ecm_create_qm_loader(qprompt_QM_LOADER ../locale/qprompt.pot)
endif()

qt_standard_project_setup()

qt_add_executable(${PROJECT_NAME}
    main.cpp
    systemfontchooserdialog.h
    systemfontchooserdialog.cpp
)
if (NOT ANDROID)
    qt_wrap_ui(${PROJECT_NAME}
        qt/systemfontchooserdialog.ui
    )
endif()

if (NOT APPLE AND NOT ANDROID)
    set(ICONS_FOLDER ${CMAKE_CURRENT_SOURCE_DIR}/icons/hicolor)
    set(RASTER_ICONS
        ${ICONS_FOLDER}/16-apps-com.cuperino.qprompt.png
        ${ICONS_FOLDER}/32-apps-com.cuperino.qprompt.png
        ${ICONS_FOLDER}/48-apps-com.cuperino.qprompt.png
        ${ICONS_FOLDER}/64-apps-com.cuperino.qprompt.png
        ${ICONS_FOLDER}/128-apps-com.cuperino.qprompt.png
        ${ICONS_FOLDER}/256-apps-com.cuperino.qprompt.png
        ${ICONS_FOLDER}/512-apps-com.cuperino.qprompt.png
        # Commenting 1024 sized icon out because although ECM does support it, Flatpak does not...
        # ${ICONS_FOLDER}/1024-apps-com.cuperino.qprompt.png
    )
    # set(VECTOR_ICON
    #     ${ICONS_FOLDER}/sc-apps-com.cuperino.qprompt.svg
    # )
    ecm_install_icons(
        ICONS
            ${RASTER_ICONS}
            # ${VECTOR_ICON}
        DESTINATION ${KDE_INSTALL_ICONDIR}
        # THEME hicolor
    )
    if (NOT WIN32)
        ecm_add_app_icon(qprompt_ICONS
            ICONS ${RASTER_ICONS}
        )
    endif()
endif()

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
)

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

set(image_files
    # Logos
    images/qprompt.png
    images/qprompt-logo-wireframe.png
    # Pointers
    images/left_hand.png
    images/right_hand.png
)

# Fonts
set(font_files
    fonts/icons/fontello.ttf
    fonts/editor/dejavu-sans/DejaVuSans.ttf
    fonts/editor/Libertinus/static/OTF/LibertinusSans-Regular.otf
    fonts/editor/OpenDyslexic-Bold.otf
    fonts/editor/ScheherazadeNew/ScheherazadeNew-Regular.ttf
    fonts/editor/Kalpurush/Kalpurush.ttf
    fonts/editor/Palanquin-Regular.ttf
    # fonts/editor/Libertinus/static/OTF/LibertinusSerif-Regular.otf
    fonts/editor/SourceHanSans/SourceHanSans-Regular.ttc
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
    # Icons
    icons/16/go-next.svg
    icons/16/go-previous.svg
    icons/16/go-up.svg
    icons/16/go-down.svg
    icons/16/list-remove.svg
    icons/16/dialog-ok-apply.svg
    icons/16/window.svg
    icons/16/draw-rectangle.svg
    icons/16/transform-move-horizontal.svg
    icons/16/transform-move-vertical.svg
    icons/16/sidebar-collapse-right.svg
    icons/16/sidebar-collapse-left.svg
    icons/16/format-justify-center.svg
    icons/16/view-list-text.svg
    icons/16/view-list-text-rtl.svg
    icons/16/keyframe.svg
    icons/16/player-time.svg
    icons/16/format-text-color.svg
    icons/16/chronometer.svg
    icons/16/chronometer-pause.svg
    icons/16/keyframe-add.svg
    icons/16/object-flip-horizontal.svg
    icons/16/object-flip-vertical.svg
    icons/16/object-rotate-left.svg
    icons/16/object-rotate-right.svg
    icons/16/insert-image.svg
    icons/16/fill-color.svg
    icons/16/window-duplicate.svg
    icons/16/document-new.svg
    icons/16/document-save.svg
    icons/16/document-save-as.svg
    icons/16/document-open.svg
    icons/16/document-open-recent.svg
    icons/16/document-open-remote.svg
    icons/16/format-font-size-more.svg
    icons/16/edit-clear-history.svg
    icons/16/configure.svg
    icons/16/help-about.svg
    icons/16/application-exit.svg
    icons/16/document-properties.svg
    icons/16/paint-none.svg
    icons/16/filename-bpm-amarok.svg
    icons/16/gnumeric-object-scrollbar.svg
    icons/16/circular-arrow-shape.svg
    icons/16/key-enter.svg
    icons/16/edit-opacity.svg
    icons/16/edit-undo.svg
    icons/16/edit-redo.svg
    icons/16/mail-mark-unread.svg
    icons/16/draw-star.svg
    icons/16/edit-find.svg
    icons/16/edit-find-replace.svg
    icons/16/format-text-direction-rtl.svg
    icons/16/format-text-direction-ltr.svg
    icons/16/view-fullscreen.svg
    icons/16/empty.svg
    icons/16/amarok_change_language.svg
    icons/22/akonadiconsole.svg
    icons/22/handle-sort.svg
    icons/22/gnumeric-object-rectangle.svg
    icons/22/tool_color_eraser.svg
    icons/22/newline.svg
    icons/22/auto-transition.svg
    icons/22/view-left-close.svg
    icons/22/view-right-close.svg
    icons/22/transform-browse.svg
    icons/22/contrast.svg
    icons/22/window-pin.svg
    icons/22/window-unpin.svg
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
    qmlutil.hpp
    abstractunits.hpp
    documenthandler.h
    documenthandler.cpp
    marker.hpp
    markersmodel.h
    markersmodel.cpp
    ${qprompt_QM_LOADER}
    QML_FILES
    ${qprompt_frontend_sources}
    ${prompter_sources}
    ${other_sources}
    RESOURCES
    ${image_files}
    ${document_files}
    ${icon_files}
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
    MACOSX_BUNDLE_ICON_FILE "icons/qprompt.icns"
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    OUTPUT_NAME ${OUTPUT_NAME}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
    # QT_QMLCACHEGEN_ARGUMENTS "--static"  # "--static;--verbose"
    # QT_QMLCACHEGEN_DIRECT_CALLS OFF
    # PLUGIN_TARGET qtlabsplatformplugin inhibits the creation of the backing library, thus headers can't be accessed in direct mode.
    # See issue: https://bugreports.qt.io/browse/QTBUG-117992?focusedId=750577&page=com.atlassian.jira.plugin.system.issuetabpanels%3Acomment-tabpanel#comment-750577
)

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
        Qt${QT_VERSION_MAJOR}::AndroidExtras
        KF${QT_VERSION_MAJOR}::CoreAddons
        KF${QT_VERSION_MAJOR}::Kirigami
    )
elseif (WASM OR IOS)
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
    )
elseif(WIN32 OR APPLE)
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
    )
endif()
# Private header/s that would be used if QT_QMLCACHEGEN_DIRECT_CALLS were turned ON
# - Qt${QT_VERSION_MAJOR}::QuickPrivate

if (QHotkey_FOUND)
    add_definitions(-DQHotkey_FOUND)
    target_link_libraries(${PROJECT_NAME} PRIVATE
        qhotkey
    )
endif()

# Installation and bundling
if (APPLE)
    install(TARGETS ${PROJECT_NAME} ${KDE_INSTALL_TARGETS_DEFAULT_ARGS} BUNDLE DESTINATION .)
elseif (WIN32 OR UNIX)
    install(FILES com.cuperino.qprompt.appdata.xml DESTINATION ${KDE_INSTALL_METAINFODIR})
    install(PROGRAMS com.cuperino.qprompt.desktop DESTINATION ${KDE_INSTALL_APPDIR})
    install(TARGETS ${PROJECT_NAME} ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
endif()

set(deploy_tool_options_arg "")
if(APPLE)
    set(deploy_tool_options_arg "-always-overwrite -appstore-compliant -sign-for-notarization=\"3rd Party Mac Developer Application: <Team Name>\"")
endif()
qt_generate_deploy_qml_app_script(
    TARGET ${PROJECT_NAME}
    OUTPUT_SCRIPT deploy_script
    NO_UNSUPPORTED_PLATFORM_ERROR
    DEPLOY_TOOL_OPTIONS ${deploy_tool_options_arg}
    MACOS_BUNDLE_POST_BUILD
)
if (NOT UNIX OR APPLE)
    install(SCRIPT ${deploy_script})
endif()
