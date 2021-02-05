add_executable(qprompt main.cpp prompter/documenthandler.cpp prompter/timer/promptertimer.cpp resources.qrc)
target_link_libraries(qprompt
    Qt5::Core
    Qt5::Gui
    Qt5::Qml
    Qt5::Quick
    Qt5::QuickControls2
    Qt5::Svg
    Qt5::Widgets
    KF5::I18n
    KF5::Kirigami2
    #KF5::WidgetsAddons
    KF5::CoreAddons
)
install(TARGETS qprompt ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
