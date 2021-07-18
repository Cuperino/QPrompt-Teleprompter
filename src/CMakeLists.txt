set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_INCLUDE_CURRENT_DIRS ON)

set(qprompt_SRC
    main.cpp
    prompter/documenthandler.cpp
    prompter/timer/promptertimer.cpp
    prompter/markersmodel.cpp
#    resources.qrc
)
#add_executable(qprompt ${qprompt_SRC})
qtquick_compiler_add_resources(RESOURCES resources.qrc) # Used to get static QML.
add_executable(qprompt WIN32 ${qprompt_SRC} ${RESOURCES}) # Used to get static QML.
#add_executable(qprompt ${qprompt_SRC} ${RESOURCES}) # Used to get static QML.
#add_executable(qprompt MACOSX_BUNDLE ${qprompt_SRC} ${RESOURCES}) # Used to get static QML.
target_link_libraries(qprompt
    Qt5::Core
    Qt5::Gui
    Qt5::Qml
    Qt5::Quick
    Qt5::QuickControls2
    Qt5::Widgets
    KF5::I18n
    KF5::Kirigami2
    KF5::CoreAddons
)
qt5_import_qml_plugins(qprompt) # Used to get static QML. Gets ignored if not a static build
install(FILES com.cuperino.qprompt.appdata.xml DESTINATION ${KDE_INSTALL_METAINFODIR})
install(FILES images/qprompt.svg DESTINATION ${KDE_INSTALL_FULL_ICONDIR}/hicolor/scalable/apps)
install(FILES images/qprompt.png DESTINATION ${KDE_INSTALL_FULL_ICONDIR}/hicolor/1024x1024/apps)
install(TARGETS qprompt ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
install(PROGRAMS com.cuperino.qprompt.desktop DESTINATION ${KDE_INSTALL_APPDIR})
