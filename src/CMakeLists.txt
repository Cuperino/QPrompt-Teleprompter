#**************************************************************************
#
# QPrompt
# Copyright (C) 2020-2023 Javier O. Cordero Pérez
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

#include(ECMPoQmTools)
#ecm_create_qm_loader(qprompt_QM_LOADER ../locale/qprompt.pot)

if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
    qt_standard_project_setup()

    qt_add_executable(${PROJECT_NAME}
        main.cpp
        systemfontchooserdialog.h
        systemfontchooserdialog.cpp
    )
    qt_wrap_ui(${PROJECT_NAME}
        qt/systemfontchooserdialog.ui
    )
    #qt_add_resources(${PROJECT_NAME} "configuration"
    #    PREFIX "/"
    #    FILES
    #        qtquickcontrols2.conf
    #    ASSETS
    #)
    qt_add_qml_module(
        ${PROJECT_NAME}
        URI com.cuperino.qprompt
        VERSION 1.0
        # SHARED
        # [PLUGIN_TARGET plugin_target]
        # [OUTPUT_DIRECTORY output_dir]
        RESOURCE_PREFIX /qt/qml/
        # [CLASS_NAME class_name]
        # [TYPEINFO typeinfo]
        IMPORTS
        "QtQuick.Controls.Material"
        "org.kde.kirigami"
    #    DEPENDENCIES

        SOURCES
        qmlutil.hpp
        abstractunits.hpp
        documenthandler.h
        documenthandler.cpp
        marker.hpp
        markersmodel.h
        markersmodel.cpp

        QML_FILES
        # Kirigami UI QML
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
        # Prompter QML
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
        # Other QML
        qt/WindowDragger.qml

        RESOURCES
        # Settings
        qtquickcontrols2.conf
        # Logos
        images/qprompt.png
        images/qprompt-logo-wireframe.png
        # Pointers
        images/left_hand.png
        images/right_hand.png
        # Fonts
        fonts/icons/fontello.ttf
        fonts/editor/dejavu-sans/DejaVuSans.ttf
        fonts/editor/Libertinus/static/OTF/LibertinusSans-Regular.otf
        fonts/editor/OpenDyslexic-Bold.otf
        fonts/editor/ScheherazadeNew/ScheherazadeNew-Regular.ttf
        fonts/editor/Kalpurush/Kalpurush.ttf
        fonts/editor/Palanquin-Regular.ttf
        # fonts/editor/Libertinus/static/OTF/LibertinusSerif-Regular.otf
        fonts/editor/SourceHanSans/SourceHanSans-Regular.ttc
        # Documents
        documents/untitled.html
        documents/welcome_ar.html
        documents/welcome_cs.html
        documents/welcome_de.html
        documents/welcome_en.html
        documents/welcome_es.html
        documents/welcome_fi.html
        documents/welcome_fr.html
        documents/welcome_it.html
        documents/welcome_ja.html
        documents/welcome_ko.html
        documents/welcome_nl.html
        documents/welcome_oc.html
        documents/welcome_pl.html
        documents/welcome_pt.html
        documents/welcome_ru.html
        documents/welcome_zh.html
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
        icons/16/mail-mark-unread.svg
        icons/16/draw-star.svg
        icons/16/edit-find.svg
        icons/16/edit-find-replace.svg
        icons/16/format-text-direction-rtl.svg
        icons/16/format-text-direction-ltr.svg
        icons/16/view-fullscreen.svg
        icons/16/empty.svg
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
    #    [OUTPUT_TARGETS out_targets_var]
    #    [DESIGNER_SUPPORTED]
    #    [FOLLOW_FOREIGN_VERSIONING]
    #    [NAMESPACE namespace]
    #    [NO_PLUGIN]
    #    [NO_PLUGIN_OPTIONAL]
    #    [NO_CREATE_PLUGIN_TARGET]
    #    [NO_GENERATE_PLUGIN_SOURCE]
    #    [NO_RESOURCE_TARGET_PATH]
    #    [NO_IMPORT_SCAN]
#        ENABLE_TYPE_COMPILER
    #    [TYPE_COMPILER_NAMESPACE namespace]
    #    [QMLTC_EXPORT_DIRECTIVE export_macro]
    #    [QMLTC_EXPORT_FILE_NAME header_defining_export_macro]
    )
    set_target_properties(${PROJECT_NAME} PROPERTIES
        MACOSX_BUNDLE_GUI_IDENTIFIER com.cuperino.qprompt
        MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
        MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
        MACOSX_BUNDLE TRUE
        WIN32_EXECUTABLE TRUE
        QML_CACHEGEN_DIRECT_CALLS ON
        QT_QMLCACHEGEN_ARGUMENTS "--verbose"
        # QT_QMLCACHEGEN_ARGUMENTS "--direct-calls"
    )
    # Kirigami UI QML
    set_source_files_properties(kirigami_ui/AboutPage.qml PROPERTIES
        QT_RESOURCE_ALIAS AboutPage.qml
    )
    set_source_files_properties(kirigami_ui/PathsPage.qml PROPERTIES
        QT_RESOURCE_ALIAS PathsPage.qml
    )
    set_source_files_properties(kirigami_ui/PrompterPage.qml PROPERTIES
        QT_RESOURCE_ALIAS PrompterPage.qml
    )
    set_source_files_properties(kirigami_ui/TelemetryPage.qml PROPERTIES
        QT_RESOURCE_ALIAS TelemetryPage.qml
    )
    set_source_files_properties(kirigami_ui/RemotePage.qml PROPERTIES
        QT_RESOURCE_ALIAS RemotePage.qml
    )
    set_source_files_properties(kirigami_ui/EditorPage.qml PROPERTIES
        QT_RESOURCE_ALIAS EditorPage.qml
    )
    set_source_files_properties(kirigami_ui/MarkersDrawer.qml PROPERTIES
        QT_RESOURCE_ALIAS MarkersDrawer.qml
    )
    set_source_files_properties(kirigami_ui/InputsOverlay.qml PROPERTIES
        QT_RESOURCE_ALIAS InputsOverlay.qml
    )
    set_source_files_properties(kirigami_ui/KeyInputButton.qml PROPERTIES
        QT_RESOURCE_ALIAS KeyInputButton.qml
    )
    set_source_files_properties(kirigami_ui/WheelSettingsOverlay.qml PROPERTIES
        QT_RESOURCE_ALIAS WheelSettingsOverlay.qml
    )
    set_source_files_properties(kirigami_ui/LayoutDirectionSettingsOverlay.qml PROPERTIES
        QT_RESOURCE_ALIAS LayoutDirectionSettingsOverlay.qml
    )
    # Prompter QML
    set_source_files_properties(prompter/PrompterView.qml PROPERTIES
        QT_RESOURCE_ALIAS PrompterView.qml
    )
    set_source_files_properties(prompter/Prompter.qml PROPERTIES
        QT_RESOURCE_ALIAS Prompter.qml
    )
    set_source_files_properties(prompter/ProgressIndicator.qml PROPERTIES
        QT_RESOURCE_ALIAS ProgressIndicator.qml
    )
    set_source_files_properties(prompter/Countdown.qml PROPERTIES
        QT_RESOURCE_ALIAS Countdown.qml
    )
    set_source_files_properties(prompter/TimerClock.qml PROPERTIES
        QT_RESOURCE_ALIAS TimerClock.qml
    )
    set_source_files_properties(prompter/ReadRegionOverlay.qml PROPERTIES
        QT_RESOURCE_ALIAS ReadRegionOverlay.qml
    )
    set_source_files_properties(prompter/PrompterBackground.qml PROPERTIES
        QT_RESOURCE_ALIAS PrompterBackground.qml
    )
    set_source_files_properties(prompter/Remote.qml PROPERTIES
        QT_RESOURCE_ALIAS Remote.qml
    )
    set_source_files_properties(prompter/Flip.qml PROPERTIES
        QT_RESOURCE_ALIAS Flip.qml
    )
    set_source_files_properties(prompter/ProjectionsManager.qml PROPERTIES
        QT_RESOURCE_ALIAS ProjectionsManager.qml
    )
    set_source_files_properties(prompter/Find.qml PROPERTIES
        QT_RESOURCE_ALIAS Find.qml
    )
    set_source_files_properties(prompter/CursorAutoHide.qml PROPERTIES
        QT_RESOURCE_ALIAS CursorAutoHide.qml
    )
    set_source_files_properties(prompter/PointerSettings.qml PROPERTIES
        QT_RESOURCE_ALIAS PointerSettings.qml
    )
    # Other QML
    set_source_files_properties(qt/WindowDragger.qml PROPERTIES
        QT_RESOURCE_ALIAS PointerSettings.qml
    )
    # Fonts
    set_source_files_properties(fonts/icons/fontello.ttf PROPERTIES
        QT_RESOURCE_ALIAS fonts/fontello.ttf
    )
    set_source_files_properties(fonts/editor/dejavu-sans/DejaVuSans.ttf PROPERTIES
        QT_RESOURCE_ALIAS fonts/dejavu-sans.ttf
    )
    set_source_files_properties(fonts/editor/Libertinus/static/OTF/LibertinusSans-Regular.otf PROPERTIES
        QT_RESOURCE_ALIAS fonts/libertinus-sans.otf
    )
    set_source_files_properties(fonts/editor/OpenDyslexic-Bold.otf PROPERTIES
        QT_RESOURCE_ALIAS fonts/opendyslexic-bold.otf´
    )
    set_source_files_properties(fonts/editor/ScheherazadeNew/ScheherazadeNew-Regular.ttf PROPERTIES
        QT_RESOURCE_ALIAS fonts/scheherazadenew-regular.ttf
    )
    set_source_files_properties(fonts/editor/Kalpurush/Kalpurush.ttf PROPERTIES
        QT_RESOURCE_ALIAS fonts/kalpurush.ttf
    )
    set_source_files_properties(fonts/editor/Palanquin-Regular.ttf PROPERTIES
        QT_RESOURCE_ALIAS fonts/palanquin.ttf
    )
    #set_source_files_properties(Libertinus/static/OTF/LibertinusSerif-Regular.otf PROPERTIES
    #    QT_RESOURCE_ALIAS fonts/libertinus-serif.otf
    #)
    # Documents
    set_source_files_properties(documents/untitled.html PROPERTIES
        QT_RESOURCE_ALIAS untitled.html
    )
    set_source_files_properties(documents/untitled.html PROPERTIES
        QT_RESOURCE_ALIAS blank.html
    )
    set_source_files_properties(documents/welcome_ar.html PROPERTIES
        QT_RESOURCE_ALIAS welcome_ar.html
    )
    set_source_files_properties(documents/welcome_cs.html PROPERTIES
        QT_RESOURCE_ALIAS welcome_cs.html
    )
    set_source_files_properties(documents/welcome_de.html PROPERTIES
        QT_RESOURCE_ALIAS welcome_de.html
    )
    set_source_files_properties(documents/welcome_en.html PROPERTIES
        QT_RESOURCE_ALIAS welcome_en.html
    )
    set_source_files_properties(documents/welcome_es.html PROPERTIES
        QT_RESOURCE_ALIAS welcome_es.html
    )
    set_source_files_properties(documents/welcome_fi.html PROPERTIES
        QT_RESOURCE_ALIAS welcome_fi.html
    )
    set_source_files_properties(documents/welcome_fr.html PROPERTIES
        QT_RESOURCE_ALIAS welcome_fr.html
    )
    set_source_files_properties(documents/welcome_it.html PROPERTIES
        QT_RESOURCE_ALIAS welcome_it.html
    )
    set_source_files_properties(documents/welcome_ja.html PROPERTIES
        QT_RESOURCE_ALIAS welcome_ja.html
    )
    set_source_files_properties(documents/welcome_ko.html PROPERTIES
        QT_RESOURCE_ALIAS welcome_ko.html
    )
    set_source_files_properties(documents/welcome_nl.html PROPERTIES
        QT_RESOURCE_ALIAS welcome_nl.html
    )
    set_source_files_properties(documents/welcome_oc.html PROPERTIES
        QT_RESOURCE_ALIAS welcome_oc.html
    )
    set_source_files_properties(documents/welcome_pl.html PROPERTIES
        QT_RESOURCE_ALIAS welcome_pl.html
    )
    set_source_files_properties(documents/welcome_pt.html PROPERTIES
        QT_RESOURCE_ALIAS welcome_pt.html
    )
    set_source_files_properties(documents/welcome_ru.html PROPERTIES
        QT_RESOURCE_ALIAS welcome_ru.html
    )
    set_source_files_properties(documents/welcome_zh.html PROPERTIES
        QT_RESOURCE_ALIAS welcome_zh.html
    )
    # RESOURCES
    set_source_files_properties(icons/16/go-next.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/go-next.svg
    )
    set_source_files_properties(icons/16/go-previous.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/go-previous.svg
    )
    set_source_files_properties(icons/16/go-up.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/go-up.svg
    )
    set_source_files_properties(icons/16/go-down.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/go-down.svg
    )
    set_source_files_properties(icons/16/list-remove.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/list-remove.svg
    )
    set_source_files_properties(icons/16/dialog-ok-apply.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/dialog-ok-apply.svg
    )
    set_source_files_properties(icons/16/window.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/window.svg
    )
    set_source_files_properties(icons/16/draw-rectangle.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/draw-rectangle.svg
    )
    set_source_files_properties(icons/16/transform-move-horizontal.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/transform-move-horizontal.svg
    )
    set_source_files_properties(icons/16/transform-move-vertical.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/transform-move-vertical.svg
    )
    set_source_files_properties(icons/16/sidebar-collapse-right.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/sidebar-collapse-right.svg
    )
    set_source_files_properties(icons/16/sidebar-collapse-left.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/sidebar-collapse-left.svg
    )
    set_source_files_properties(icons/16/format-justify-center.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/format-justify-center.svg
    )
    set_source_files_properties(icons/16/view-list-text.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/view-list-text.svg
    )
    set_source_files_properties(icons/16/view-list-text-rtl.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/view-list-text-rtl.svg
    )
    set_source_files_properties(icons/16/keyframe.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/keyframe.svg
    )
    set_source_files_properties(icons/16/player-time.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/player-time.svg
    )
    set_source_files_properties(icons/16/format-text-color.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/format-text-color.svg
    )
    set_source_files_properties(icons/16/chronometer.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/chronometer.svg
    )
    set_source_files_properties(icons/16/chronometer-pause.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/chronometer-pause.svg
    )
    set_source_files_properties(icons/16/keyframe-add.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/keyframe-add.svg
    )
    set_source_files_properties(icons/16/object-flip-horizontal.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/object-flip-horizontal.svg
    )
    set_source_files_properties(icons/16/object-flip-vertical.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/object-flip-vertical.svg
    )
    set_source_files_properties(icons/16/object-rotate-left.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/object-rotate-left.svg
    )
    set_source_files_properties(icons/16/object-rotate-right.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/object-rotate-right.svg
    )
    set_source_files_properties(icons/16/insert-image.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/insert-image.svg
    )
    set_source_files_properties(icons/16/fill-color.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/fill-color.svg
    )
    set_source_files_properties(icons/16/document-new.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/document-new.svg
    )
    set_source_files_properties(icons/16/document-save.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/document-save.svg
    )
    set_source_files_properties(icons/16/document-save-as.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/document-save-as.svg
    )
    set_source_files_properties(icons/16/document-open.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/document-open.svg
    )
    set_source_files_properties(icons/16/document-open-recent.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/document-open-recent.svg
    )
    set_source_files_properties(icons/16/document-open-remote.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/document-open-remote.svg
    )
    set_source_files_properties(icons/16/format-font-size-more.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/format-font-size-more.svg
    )
    set_source_files_properties(icons/16/edit-clear-history.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/edit-clear-history.svg
    )
    set_source_files_properties(icons/16/configure.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/configure.svg
    )
    set_source_files_properties(icons/16/help-about.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/help-about.svg
    )
    set_source_files_properties(icons/16/application-exit.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/application-exit.svg
    )
    set_source_files_properties(icons/16/document-properties.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/document-properties.svg
    )
    set_source_files_properties(icons/16/paint-none.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/paint-none.svg
    )
    set_source_files_properties(icons/16/filename-bpm-amarok.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/filename-bpm-amarok.svg
    )
    set_source_files_properties(icons/16/gnumeric-object-scrollbar.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/gnumeric-object-scrollbar.svg
    )
    set_source_files_properties(icons/16/circular-arrow-shape.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/circular-arrow-shape.svg
    )
    set_source_files_properties(icons/16/key-enter.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/key-enter.svg
    )
    set_source_files_properties(icons/16/edit-opacity.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/edit-opacity.svg
    )
    set_source_files_properties(icons/16/mail-mark-unread.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/mail-mark-unread.svg
    )
    set_source_files_properties(icons/16/draw-star.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/draw-star.svg
    )
    set_source_files_properties(icons/16/edit-find.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/edit-find.svg
    )
    set_source_files_properties(icons/16/edit-find.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/edit-find.svg
    )
    set_source_files_properties(icons/16/edit-find-replace.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/edit-find-replace.svg
    )
    set_source_files_properties(icons/16/format-text-direction-rtl.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/format-text-direction-rtl.svg
    )
    set_source_files_properties(icons/16/format-text-direction-ltr.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/format-text-direction-ltr.svg
    )
    set_source_files_properties(icons/16/view-fullscreen.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/view-fullscreen.svg
    )
    set_source_files_properties(icons/16/empty.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/empty.svg
    )
    set_source_files_properties(icons/22/handle-sort.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/handle-sort.svg
    )
    set_source_files_properties(icons/22/gnumeric-object-rectangle.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/gnumeric-object-rectangle.svg
    )
    set_source_files_properties(icons/22/tool_color_eraser.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/tool_color_eraser.svg
    )
    set_source_files_properties(icons/22/newline.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/newline.svg
    )
    set_source_files_properties(icons/22/auto-transition.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/auto-transition.svg
    )
    set_source_files_properties(icons/22/auto-transition.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/auto-transition.svg
    )
    set_source_files_properties(icons/22/view-left-close.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/view-left-close.svg
    )
    set_source_files_properties(icons/22/view-right-close.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/view-right-close.svg
    )
    set_source_files_properties(icons/22/transform-browse.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/transform-browse.svg
    )
    set_source_files_properties(icons/22/contrast.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/contrast.svg
    )
    set_source_files_properties(icons/22/window-pin.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/window-pin.svg
    )
    set_source_files_properties(icons/22/window-unpin.svg PROPERTIES
        QT_RESOURCE_ALIAS icons/window-unpin.svg
    )
else()
    set(qprompt_SRCS
        main.cpp
        prompter/markersmodel.cpp
        prompter/documenthandler.cpp
        qt/systemfontchooserdialog.cpp
        #${qprompt_QM_LOADER}
    )

    set(qprompt_HDRS
        prompter/marker.hpp
        prompter/markersmodel.h
        prompter/documenthandler.h
        qt/systemfontchooserdialog.h
        qt/abstractunits.hpp
        qt/qmlutil.hpp
    )

    set(qprompt_ASSETS
        assets.qrc
        icons/icons.qrc
        fonts/fonts.qrc
        fonts/chinese.qrc
    )

    qt_wrap_ui(qprompt_SRCS
        qt/systemfontchooserdialog.ui
    )

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
        set(VECTOR_ICON
            ${ICONS_FOLDER}/sc-apps-com.cuperino.qprompt.svg
        )
        ecm_install_icons(
            ICONS
                ${RASTER_ICONS}
                ${VECTOR_ICON}
            DESTINATION ${KDE_INSTALL_ICONDIR}
            # THEME hicolor
        )
        ecm_add_app_icon(qprompt_ICONS
            ICONS ${RASTER_ICONS}
        )
    endif()

    ## Qt5QuickCompiler is an optional dependency. Script must check that it is present before attempting to use
    #if (Qt${QT_VERSION_MAJOR}QuickCompiler_FOUND)
        #qtquick_compiler_add_resources(qprompt_QML_SRCS qml.qrc)
    #else ()
    set(qprompt_QML_SRCS
        qml.qrc
        prompter/pointers/pointers.qrc
    )
    #endif()

    if(ANDROID)
        add_library(${PROJECT_NAME}
            ${qprompt_SRCS} ${qprompt_HDRS} ${qprompt_QML_SRCS} ${qprompt_ASSETS})
    elseif (WASM)
        #cmake -DCMAKE_TOOLCHAIN_FILE=$HOME/emsdk/emscripten/1.38.27/cmake/Modules/Platform/Emscripten.cmake -DCMAKE_BUILD_TYPE=Debug -G "Unix Makefiles" ~/path/to/CMakeLists.txt
        set(DFEATURE_developer_build ON)
        set(DFEATURE_headersclean OFF)
        set(DWARNINGS_ARE_ERRORS OFF)
        set(DFEATURE_precompile_header OFF)
        set(DBUILD_EXAMPLES OFF)
        set(DBUILD_TESTING OFF)
        set(DCMAKE_GENERATOR Ninja)
        #set(DQT_HOST_PATH ~/Qt/6.2.0/wasm_32/)
        #set(Qt5_DIR "~/Qt/6.2.0/wasm_32/lib/cmake/Qt5")
        #set(Qt5Widgets_DIR "~/Qt/6.2.0/wasm_32/lib/cmake/Qt5Widgets")
        #set(Qt5Gui_DIR "~/Qt/6.2.0/wasm_32/lib/cmake/Qt5Gui")
        #set(Qt5Core_DIR "~/Qt/6.2.0/wasm_32/lib/cmake/Qt5Core")
        #set(DCMAKE_TOOLCHAIN_FILE /path/to/emsdk/upstream/emscripten/cmake/Modules/Platform/Emscripten.cmake)
        set(DFEATURE_threads ON)
        set(DFEATURE_debug ON)
        set(DFEATURE_opengles3 ON)
        set(DQT_QMAKE_DEVICE_OPTIONS EMSCRIPTEN_ASYNCIFY=1)

    elseif (WIN32)
        if (MSVC)
            add_definitions(-D_AFXDLL)
            set(CMAKE_MFC_FLAG 2)
            #set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /SUBSYSTEM:WINDOWS /ENTRY:mainCRTStartup")
        endif()
        add_executable(${PROJECT_NAME} WIN32
            ${qprompt_SRCS} ${qprompt_HDRS} ${qprompt_QML_SRCS} ${qprompt_ASSETS} ${qprompt_ICONS})

    elseif (APPLE)
        # These are substituted by CMake into plist.in.
        set(MACOSX_BUNDLE_DISPLAY_NAME "QPrompt")
        set(MACOSX_BUNDLE_INFO_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/Info.plist.in)
        set(MACOSX_BUNDLE_GUI_IDENTIFIER "com.cuperino.qprompt")
        set(MACOSX_BUNDLE_BUNDLE_NAME "QPrompt")
        set(MACOSX_BUNDLE_DISPLAY_NAME "QPrompt")
        set(MACOSX_BUNDLE_INFO_STRING "QPrompt - Teleprompter Software for Content Creators")
        set(MACOSX_BUNDLE_LONG_VERSION_STRING "QPrompt ${RELEASE_SERVICE_VERSION}")
        set(MACOSX_BUNDLE_SHORT_VERSION_STRING "${RELEASE_SERVICE_VERSION_MAJOR}.${RELEASE_SERVICE_VERSION_MINOR}")
        set(MACOSX_BUNDLE_BUNDLE_VERSION "${RELEASE_SERVICE_VERSION}")
        set(MACOSX_BUNDLE_COPYRIGHT "2021-2023 Javier O. Cordero Pérez")
        # The MACOSX_BUNDLE_ICON_FILE variable is added to the Info.plist
        # generated by CMake. This variable contains the .icns file name,
        # without the path.
        set(MACOSX_BUNDLE_ICON_FILE "qprompt.icns")
        # And the following tells CMake where to find and install the file itself.
        set(app_icon_macos "${CMAKE_CURRENT_SOURCE_DIR}/icons/qprompt.icns")
        set_source_files_properties(${app_icon_macos} PROPERTIES MACOSX_PACKAGE_LOCATION "Resources")
        #
        add_executable(${PROJECT_NAME} MACOSX_BUNDLE
            ${qprompt_SRCS} ${qprompt_HDRS} ${qprompt_QML_SRCS} ${qprompt_ASSETS} ${app_icon_macos})

    else() # UNIX
        add_executable(${PROJECT_NAME}
            ${qprompt_SRCS} ${qprompt_HDRS} ${qprompt_QML_SRCS} ${qprompt_ASSETS} ${qprompt_ICONS})
    endif()
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
        Qt${QT_VERSION_MAJOR}::AndroidExtras
        KF6::I18n
        KF6::Kirigami
        KF6::CoreAddons
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
        KF6::I18n
        KF6::Kirigami
        KF6::CoreAddons
    )
elseif(HAIKU)
    target_link_libraries(${PROJECT_NAME} PUBLIC
        Qt${QT_VERSION_MAJOR}::Core
        Qt${QT_VERSION_MAJOR}::Quick
        Qt${QT_VERSION_MAJOR}::Gui
        Qt${QT_VERSION_MAJOR}::Svg
        Qt${QT_VERSION_MAJOR}::Qml
        Qt${QT_VERSION_MAJOR}::QuickControls2
        Qt${QT_VERSION_MAJOR}::Network
        Qt${QT_VERSION_MAJOR}::Widgets
        KF6::I18n
        KF6::Kirigami
        KF6::CoreAddons
#        KF6::IconThemes
    )
elseif(WIN32 OR APPLE)
    target_link_libraries(${PROJECT_NAME} PUBLIC
        Qt${QT_VERSION_MAJOR}::Core
        Qt${QT_VERSION_MAJOR}::Quick
        Qt${QT_VERSION_MAJOR}::Gui
        Qt${QT_VERSION_MAJOR}::Svg
        Qt${QT_VERSION_MAJOR}::Qml
        Qt${QT_VERSION_MAJOR}::QuickControls2
        Qt${QT_VERSION_MAJOR}::Network
        Qt${QT_VERSION_MAJOR}::Widgets
        KF6::I18n
        KF6::Kirigami
        KF6::CoreAddons
    )
    if (KF6Crash_FOUND)
        add_definitions(-DKF6Crash_FOUND)
        target_link_libraries(${PROJECT_NAME} LINK_PRIVATE
            KF6::Crash
        )
    endif()
#    if (QHotkey_FOUND)
#        add_definitions(-DQHotkey_FOUND)
#        target_link_libraries(${PROJECT_NAME} PUBLIC
#            qhotkey
#        )
#    endif()
    if(APPLE AND NOT IOS)
        target_include_directories(mactouchbar PUBLIC ${kdmactouchbar_SOURCE_DIR}/KDMacTouchBar)
        target_link_directories(mactouchbar PUBLIC ${kdmactouchbar_SOURCE_DIR}/KDMacTouchBar)
        target_link_libraries(${PROJECT_NAME} PUBLIC KDMacTouchBar)
    endif()
else()
    #target_include_directories(${PROJECT_NAME} PUBLIC ${qhotkey_SOURCE_DIR}/QHotkey)
    #target_link_directories(${PROJECT_NAME} PUBLIC ${qhotkey_SOURCE_DIR}/QHotkey)
    if (QT_VERSION_MAJOR EQUAL 5)
        target_link_libraries(${PROJECT_NAME} PUBLIC
            Qt${QT_VERSION_MAJOR}::Core
            Qt${QT_VERSION_MAJOR}::Quick
            Qt${QT_VERSION_MAJOR}::Gui
            Qt${QT_VERSION_MAJOR}::Svg
            Qt${QT_VERSION_MAJOR}::Qml
            Qt${QT_VERSION_MAJOR}::QuickControls2
            Qt${QT_VERSION_MAJOR}::Network
            Qt${QT_VERSION_MAJOR}::Widgets
            Qt${QT_VERSION_MAJOR}::X11Extras
            KF6::I18n
            KF6::Kirigami
            KF6::CoreAddons
        )
    else()
#        target_include_directories(${PROJECT_NAME} PRIVATE
#            ${QT_QMAKE_EXECUTABLE}/../qtdeclarative/src/labs/platform
#        )
        target_link_libraries(${PROJECT_NAME} PRIVATE
            Qt${QT_VERSION_MAJOR}::Core
            Qt${QT_VERSION_MAJOR}::Quick
            Qt${QT_VERSION_MAJOR}::QuickPrivate
            Qt${QT_VERSION_MAJOR}::Gui
#            Qt${QT_VERSION_MAJOR}::GuiPrivate
            Qt${QT_VERSION_MAJOR}::Svg
#            Qt${QT_VERSION_MAJOR}::SvgPrivate
            Qt${QT_VERSION_MAJOR}::Qml
#            Qt${QT_VERSION_MAJOR}::QmlPrivate
            Qt${QT_VERSION_MAJOR}::QuickControls2
#            Qt${QT_VERSION_MAJOR}::QuickControls2Private
            Qt${QT_VERSION_MAJOR}::Network
#            Qt${QT_VERSION_MAJOR}::NetworkPrivate
            Qt${QT_VERSION_MAJOR}::Widgets
#            Qt${QT_VERSION_MAJOR}::WidgetsPrivate
            KF6::I18n
            KF6::Kirigami
            KF6::CoreAddons
        )
    endif()
    if (KF6Crash_FOUND)
        add_definitions(-DKF6Crash_FOUND)
        target_link_libraries(${PROJECT_NAME} LINK_PRIVATE
            KF6::Crash
        )
    endif()
#    if (QHotkey_FOUND)
#        add_definitions(-DQHotkey_FOUND)
#        target_link_libraries(${PROJECT_NAME} PUBLIC
#            qhotkey
#        )
#    endif()
endif()

# Copy icons that are not font based
if(ANDROID OR APPLE OR WIN32 OR IOS OR WASM)
    # Breeze icons names can be found at https://cdn.kde.org/breeze-icons/icons.html
    kirigami_package_breeze_icons(ICONS
        akonadiconsole
        application-exit
        auto-transition
        chronometer
        chronometer-pause
        circular-arrow-shape
        configure
        contrast
        dialog-ok-apply
        document-new
        document-open
        document-open-recent
        document-save
        document-save-as
        document-send
        draw-rectangle
        draw-star
        edit-clear-history
        edit-opacity
        edit-redo
        edit-undo
        filename-bpm-amarok
        fill-color
        format-font-size-more
        format-justify-center
        format-text-color
        gnumeric-object-rectangle
        gnumeric-object-scrollbar
        go-down
        go-next
        go-previous
        go-up
        handle-sort
        help-about
        insert-image
        key-enter
        keyframe
        keyframe-add
        list-remove
        mail-mark-unread
        newline
        object-flip-horizontal
        object-flip-vertical
        object-rotate-left
        object-rotate-right
        paint-none
        player-time
        sidebar-collapse-left
        sidebar-collapse-right
        tool_color_eraser
        tools-report-bug
        transform-browse
        transform-move-horizontal
        transform-move-vertical
        view-left-close
        view-right-close
        window
        window-duplicate
    )
endif()

qt_add_shaders(
    ${PROJECT_NAME}
    "qp_shaders"
    PREFIX
    "/shaders"
    FILES
    "shaders/blur.frag"
    "shaders/shadow.frag"
    "shaders/tint.frag"
)

## Get static QML. Gets ignored if not a static build
#if (QtQmlImportScanner_FOUND)
    #qt_import_qml_plugins(${PROJECT_NAME})
#endif()


# Include KI18N translations
FIND_PROGRAM(GETTEXT_MSGFMT_EXECUTABLE msgfmt)
IF(NOT GETTEXT_MSGFMT_EXECUTABLE)
   MESSAGE(
"------
                NOTE: msgfmt not found. Translations will *not* be installed
------")
ELSE(NOT GETTEXT_MSGFMT_EXECUTABLE)

   SET(catalogname qprompt)

   FILE(GLOB PO_FILES ../po/*.po)
   SET(GMO_FILES)

   FOREACH(_poFile ${PO_FILES})
       GET_FILENAME_COMPONENT(_poFileName ${_poFile} NAME)
       STRING(REGEX REPLACE "^${catalogname}_?" "" _langCode ${_poFileName} )
       STRING(REGEX REPLACE "\\.po$" "" _langCode ${_langCode} )

       IF( _langCode )
           GET_FILENAME_COMPONENT(_lang ${_poFile} NAME_WE)
           SET(_gmoFile ${CMAKE_CURRENT_BINARY_DIR}/${_lang}.gmo)

           ADD_CUSTOM_COMMAND(TARGET ${PROJECT_NAME} # ${_gmoFile}
               COMMAND ${GETTEXT_MSGFMT_EXECUTABLE} --check -o ${_gmoFile} ${_poFile}
               DEPENDS ${_poFile})
           INSTALL(FILES ${_gmoFile} DESTINATION ${LOCALE_INSTALL_DIR}/${_langCode}/LC_MESSAGES/ RENAME ${catalogname}.mo)
           LIST(APPEND GMO_FILES ${_gmoFile})
       ENDIF( _langCode )

   ENDFOREACH(_poFile ${PO_FILES})

   #ADD_CUSTOM_TARGET(translations ALL DEPENDS ${GMO_FILES})

ENDIF(NOT GETTEXT_MSGFMT_EXECUTABLE)


if (WIN32 OR UNIX) # AND NOT ANDROID)
    # install(FILES images/qprompt.svg DESTINATION ${KDE_INSTALL_FULL_ICONDIR}/hicolor/scalable/apps)
    # install(FILES images/qprompt.png DESTINATION ${KDE_INSTALL_FULL_ICONDIR}/hicolor/1024x1024/apps)
    install(FILES com.cuperino.qprompt.appdata.xml DESTINATION ${KDE_INSTALL_METAINFODIR})
    install(PROGRAMS com.cuperino.qprompt.desktop DESTINATION ${KDE_INSTALL_APPDIR})
    if (APPLE)
        install(TARGETS ${PROJECT_NAME} ${KDE_INSTALL_TARGETS_DEFAULT_ARGS} BUNDLE DESTINATION .)
    else()
        install(TARGETS ${PROJECT_NAME} ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
    endif()
endif()
