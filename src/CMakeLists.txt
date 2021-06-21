set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_INCLUDE_CURRENT_DIRS ON)

set(qprompt_SRC
    main.cpp
    prompter/documenthandler.cpp
    prompter/timer/promptertimer.cpp
    prompter/markersmodel.cpp
    resources.qrc
)
add_executable(qprompt ${qprompt_SRC})
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
install(TARGETS qprompt ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
install(PROGRAMS com.cuperino.qprompt.desktop DESTINATION ${KDE_INSTALL_APPDIR})
install(FILES com.cuperino.qprompt.appdata.xml DESTINATION ${KDE_INSTALL_METAINFODIR})
