TEMPLATE = subdirs
CONFIG += c++17
SUBDIRS = \
        kirigami \
        kcoreaddons \
        ki18n \
        src

kirigami.subdir = 3rdparty/kirigami
kcoreaddons.subdir = 3rdparty/kcoreaddons
ki18n.subdir = 3rdparty/ki18n
src.subdir = src

src.depends = kirigami kcoreaddons ki18n

QT += KCoreAddons KI18n

android: {
    include(3rdparty/kirigami/kirigami.pri)
    include(3rdparty/kcoreaddons/kcoreaddons.pri)
    include(3rdparty/ki18n/ki18n.pri)
    include(src/qprompt.pri)
}
wasm: {
    include(3rdparty/kirigami/kirigami.pri)
    include(3rdparty/kcoreaddons/kcoreaddons.pri)
    include(3rdparty/ki18n/ki18n.pri)
    include(src/qprompt.pri)
}
