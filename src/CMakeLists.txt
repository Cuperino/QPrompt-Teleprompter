add_executable(qprompt main.cpp resources.qrc)
target_link_libraries(qprompt
    Qt5::Core
    Qt5::Gui
    Qt5::Qml
    Qt5::Quick
    Qt5::QuickControls2
    Qt5::Svg
    KF5::I18n)
install(TARGETS qprompt ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
