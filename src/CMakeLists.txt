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


set(qprompt_SRCS
    main.cpp
    prompter/markersmodel.cpp
    prompter/documenthandler.cpp
    prompter/inputmanager.cpp
    qt/systemfontchooserdialog.cpp
    #${qprompt_QM_LOADER}
)

set(qprompt_HDRS
    prompter/marker.hpp
    prompter/markersmodel.h
    prompter/documenthandler.h
    prompter/inputmanager.h
    qt/systemfontchooserdialog.h
    qt/abstractunits.hpp
    qt/qmlutil.hpp
)

set(qprompt_ASSETS
    assets.qrc
    shaders/shaders.qrc
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
        ${qprompt_SRCS} ${qprompt_HDRS} ${qprompt_QML_SRCS} ${qprompt_ASSETS} ${qprompt_ICONS}
        prompter/inputmanager.h prompter/inputmanager.cpp)
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
        KF${QT_VERSION_MAJOR}::I18n
        KF${QT_VERSION_MAJOR}::Kirigami2
        KF${QT_VERSION_MAJOR}::CoreAddons
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
        KF${QT_VERSION_MAJOR}::I18n
        KF${QT_VERSION_MAJOR}::Kirigami2
        KF${QT_VERSION_MAJOR}::CoreAddons
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
        KF${QT_VERSION_MAJOR}::I18n
        KF${QT_VERSION_MAJOR}::Kirigami2
        KF${QT_VERSION_MAJOR}::CoreAddons
        KF${QT_VERSION_MAJOR}::IconThemes
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
        KF${QT_VERSION_MAJOR}::I18n
        KF${QT_VERSION_MAJOR}::Kirigami2
        KF${QT_VERSION_MAJOR}::CoreAddons
    )
    if (KF5Crash_FOUND)
        add_definitions(-DKF5Crash_FOUND)
        target_link_libraries(${PROJECT_NAME} LINK_PRIVATE
            KF5::Crash
        )
    endif()
    if (QHotkey_FOUND)
        add_definitions(-DQHotkey_FOUND)
        target_link_libraries(${PROJECT_NAME} PUBLIC
            qhotkey
        )
    endif()
    if(APPLE AND NOT IOS)
        target_include_directories(mactouchbar PUBLIC ${kdmactouchbar_SOURCE_DIR}/KDMacTouchBar)
        target_link_directories(mactouchbar PUBLIC ${kdmactouchbar_SOURCE_DIR}/KDMacTouchBar)
        target_link_libraries(${PROJECT_NAME} PUBLIC KDMacTouchBar)
    endif()
else()
    #target_include_directories(${PROJECT_NAME} PUBLIC ${qhotkey_SOURCE_DIR}/QHotkey)
    #target_link_directories(${PROJECT_NAME} PUBLIC ${qhotkey_SOURCE_DIR}/QHotkey)
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
        KF${QT_VERSION_MAJOR}::I18n
        KF${QT_VERSION_MAJOR}::Kirigami2
        KF${QT_VERSION_MAJOR}::CoreAddons
        KF5::IconThemes
    )
    if (KF5Crash_FOUND)
        add_definitions(-DKF5Crash_FOUND)
        target_link_libraries(${PROJECT_NAME} LINK_PRIVATE
            KF5::Crash
        )
    endif()
    if (QHotkey_FOUND)
        add_definitions(-DQHotkey_FOUND)
        target_link_libraries(${PROJECT_NAME} PUBLIC
            qhotkey
        )
    endif()
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
