/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2020-2021 Javier O. Cordero Pérez
 **
 ** This file is part of QPrompt.
 **
 ** This program is free software: you can redistribute it and/or modify
 ** it under the terms of the GNU General Public License as published by
 ** the Free Software Foundation, either version 3 of the License, or
 ** (at your option) any later version.
 **
 ** This program is distributed in the hope that it will be useful,
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 ** GNU General Public License for more details.
 **
 ** You should have received a copy of the GNU General Public License
 ** along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **
 ****************************************************************************/


#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS) || defined(Q_OS_WASM) || defined(Q_OS_WATCHOS) || defined(Q_OS_QNX)
#include <QGuiApplication>
#else
#include <QApplication>
#endif
#include <QQmlApplicationEngine>
#include <QtQml>
#include <QtQml/qqml.h>
#include <QUrl>
#include <QFontDatabase>
#include <QDebug>
#include <QQmlFileSelector>
#include <QQuickStyle>
#include <QIcon>

#if defined(Q_OS_IOS) || defined(Q_OS_WASM) || defined(Q_OS_WATCHOS) || defined(Q_OS_QNX)
#include "../3rdparty/kirigami/src/kirigamiplugin.h"
#endif
#include <KLocalizedContext>
#include <KI18n/KLocalizedString>
#include <KCoreAddons/KAboutData>

// #include "qprompt.h"
#include "../qprompt_version.h"
#include "prompter/documenthandler.h"
// #include "prompter/timer/promptertimer.h"
// #include "prompter/markersmodel.h"

#define QPROMPT_URI "com.cuperino.qprompt"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
//     // Do not call before QGuiApplication/QApplication or it will clear default paths
//     qDebug() << QIcon::themeSearchPaths();
//     QIcon::setThemeSearchPath("");

    // These should work on non Linux systems. I'm not sure why they don't...
//     QIcon::setThemeName("breeze");
//     QIcon::setThemeName("breeze-dark");
//     QIcon::setThemeName("/icons/breeze-dark/breeze-icons-dark.rcc");
//     // These icon themes worked under KDE Plasma
//     QIcon::setThemeName("Yaru");
//     QIcon::setThemeName("Tela");

//     // FallbackThemeName has no effect under Linux
//     QIcon::setFallbackThemeName("Tela");

    //     #if defined(Q_OS_WIN) || defined (Q_OS_MACOS)
//     const QStringList themes {"/icons/breeze/breeze-icons.rcc", "/icons/breeze-dark/breeze-icons-dark.rcc"};
//     for(const QString theme : themes ) {
//         const QString themePath = QStandardPaths::locate(QStandardPaths::AppDataLocation, theme);
//         if (!themePath.isEmpty()) {
//             const QString iconSubdir = theme.left(theme.lastIndexOf('/'));
//             if (QResource::registerResource(themePath, iconSubdir)) {
//                 if (QFileInfo::exists(QLatin1Char(':') + iconSubdir + QStringLiteral("/index.theme"))) {
//                     qDebug() << "Loaded icon theme:" << theme;
//                 } else {
//                     qWarning() << "No index.theme found in" << theme;
//                     QResource::unregisterResource(themePath, iconSubdir);
//                 }
//             } else {
//                 qWarning() << "Invalid rcc file" << theme;
//             }
//         }
//     }
//     #endif

#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS) || defined(Q_OS_WASM) || defined(Q_OS_WATCHOS) || defined(Q_OS_QNX)
    QGuiApplication app(argc, argv);
#else
    QApplication app(argc, argv);
#endif
    QCoreApplication::setOrganizationName("Cuperino");
    QCoreApplication::setOrganizationDomain(QPROMPT_URI);
    QCoreApplication::setApplicationName("QPrompt");

    const int currentYear = QDate::currentDate().year();
    KAboutData aboutData("qprompt", "QPrompt",
                         QPROMPT_VERSION_STRING " (" + QString(GIT_BRANCH) + "/" + QString(GIT_COMMIT_HASH) + ")",
                         i18n("Personal teleprompter software for all video makers."),
                         KAboutLicense::GPL_V3,
                         i18n("© %1%2 Javier O. Cordero Pérez", currentYear>2021?"2021-":"", QString::number(currentYear)));
//     QString(GIT_BRANCH) + "/" + QString(GIT_COMMIT_HASH)

    // Overwrite default-generated values of organizationDomain & desktopFileName
    aboutData.setHomepage("https://qprompt.app");
    aboutData.setProductName("cuperino/qprompt");
    aboutData.setBugAddress("https://github.com/Cuperino/QPrompt/issues");
    aboutData.setOrganizationDomain(QPROMPT_URI);
    aboutData.setDesktopFileName(QPROMPT_URI);
    aboutData.addAuthor (
        QString("Javier O. Cordero Pérez"),
        i18n("Author"),
        QString("javiercorderoperez@gmail.com"),
        QString("https://javiercordero.info"),
        QString("cuperino")
    );
    aboutData.setTranslator (
        i18n("Su nombre irá aquí"),
        i18n("name@protonmail.com")
    );
    //aboutData.addLicense(
    //    KAboutLicense::LGPL_V3
    //);
    // Set the application metadata
    KAboutData::setApplicationData(aboutData);

    QFontDatabase fontDatabase;
    if (fontDatabase.addApplicationFont(":/fonts/fontello.ttf") == -1)
        qWarning() << i18n("Failed to load icons from fontello.ttf");

    //qmlRegisterType<PrompterTimer>(QPROMPT_URI + ".promptertimer", 1, 0, "PrompterTimer");
    qmlRegisterType<DocumentHandler>(QPROMPT_URI".document", 1, 0, "DocumentHandler");
    qmlRegisterType<MarkersModel>(QPROMPT_URI".markers", 1, 0, "MarkersModel");
    qRegisterMetaType<Marker>();

    QQmlApplicationEngine engine;
    // #ifdef Q_OS_ANDROID
    // KirigamiPlugin::getInstance().registerTypes();
    // #endif

    // Un-comment to force RightToLeft Layout for debugging purposes
    //app.setLayoutDirection(Qt::RightToLeft);
    app.setWindowIcon(QIcon(":/images/qprompt.png"));
    
    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
    engine.rootContext()->setContextProperty(QStringLiteral("aboutData"), QVariant::fromValue(KAboutData::applicationData()));

//    engine.addImportPath(QStringLiteral("../3rdparty/kirigami/"));
    engine.load(QUrl(QStringLiteral("qrc:///main.qml")));

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
