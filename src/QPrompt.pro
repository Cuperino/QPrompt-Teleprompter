TEMPLATE = app
TARGET = qprompt
QT += quick quickcontrols2 svg network

CONFIG += c++17 qmltypes
QML_IMPORT_NAME = qprompt
QML_IMPORT_MAJOR_VERSION = 1

HEADERS += \
    prompter/documenthandler.h \
    prompter/markersmodel.h

SOURCES += \
    main.cpp \
    documenthandler.cpp \
    markersmodel.cpp

# OTHER_FILES += \
#     kirigami_ui/*.qml \
#     prompter/*.qml

# RESOURCES += \
#     qml.qrc \
#     assetss.qrc

LIBS += \
        ../3rdparty/kirigami/org/kde/kirigami.2/libkirigamiplugin.a \
        ../3rdparty/ki18n/org/kde/ki18n/libki18nplugin.a

DEFINES += QT_DEPRECATED_WARNINGS

qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target
