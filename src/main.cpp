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

#include <QApplication>
// #include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <QtQml/qqml.h>
#include <QUrl>
#include <QFontDatabase>
#include <QDebug>
#include <QQmlFileSelector>
#include <QQuickStyle>
#include <QIcon>

#ifdef Q_OS_ANDROID
#include "../3rdparty/kirigami/src/kirigamiplugin.h"
#endif
#ifdef Q_OS_IOS
#include "../3rdparty/kirigami/src/kirigamiplugin.h"
#endif
#ifdef Q_OS_WASM
#include "../3rdparty/kirigami/src/kirigamiplugin.h"
#endif
#include <KLocalizedContext>
#include <KI18n/KLocalizedString>
#include <KCoreAddons/KAboutData>

#include "prompter/documenthandler.h"
#include "prompter/timer/promptertimer.h"
#include "prompter/markersmodel.h"


Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QCoreApplication::setOrganizationName("Cuperino");
    QCoreApplication::setOrganizationDomain("cuperino.com");
    QCoreApplication::setApplicationName("QPrompt");

    KAboutData aboutData("qprompt", "QPrompt", i18n("1.0 (development build 2)"),
                         i18n("Personal teleprompter software for professional content creators."),
                         KAboutLicense::GPL_V3,
                         //KAboutLicense::Custom,
                         i18n("Copyright 2021, Javier O. Cordero Pérez"), QString(),
                         "https://javiercordero.info");
    // Overwrite default-generated values of organizationDomain & desktopFileName
    aboutData.setOrganizationDomain("cuperino.com");
    aboutData.setDesktopFileName("com.cuperino.com");
    aboutData.addAuthor (
        QString("Javier O. Cordero Pérez"),
        i18n("Lead Developer & Project Manager"),
        QString("cuperino@protonmail.com"),
        QString("https://javiercordero.info"),
        QString("cuperino")
    );
    aboutData.setTranslator (
        i18n("Su nombre irá aquí"),
        i18n("name@protonmail.com")
    );
    //aboutData.addLicense(
    //    KAboutLicense::GPL_V3
    //);
    aboutData.addLicense(
        KAboutLicense::LGPL_V3
    );
    // Set the application metadata
    KAboutData::setApplicationData(aboutData);

    QFontDatabase fontDatabase;
    if (fontDatabase.addApplicationFont(":/fonts/fontello.ttf") == -1)
        qWarning() << i18n("Failed to load icons from fontello.ttf");

//    PlayListModel model;
//    AllUpperCaseProxyModel proxyModel;

    qmlRegisterType<PrompterTimer>("com.cuperino.qprompt.promptertimer", 1, 0, "PrompterTimer");
    qmlRegisterType<DocumentHandler>("com.cuperino.qprompt.document", 1, 0, "DocumentHandler");
//    qmlRegisterType<DocumentHandler>("org.kde.kirigami", 2, 9, "KirigamiPlugin");

    QStringList selectors;
#ifdef QT_EXTRA_FILE_SELECTOR
    selectors += QT_EXTRA_FILE_SELECTOR;
#else
    if (app.arguments().contains("-touch"))
        selectors += "touch";
#endif

    QQmlApplicationEngine engine;
    QQmlFileSelector::get(&engine)->setExtraSelectors(selectors);
    #ifdef Q_OS_ANDROID
    KirigamiPlugin::getInstance().registerTypes();
    #endif
    #ifdef Q_OS_WASM
    KirigamiPlugin::getInstance().registerTypes();
    #endif
    #ifdef Q_OS_WASM
    KirigamiPlugin::getInstance().registerTypes();
    #endif

    // Un-comment to force RightToLeft Layout for debugging purposes
    //app.setLayoutDirection(Qt::RightToLeft);
    app.setWindowIcon(QIcon(":/images/logo.png"));
    
    MarkersModel markersModel;
    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
    engine.rootContext()->setContextProperty(QStringLiteral("aboutData"), QVariant::fromValue(KAboutData::applicationData()));
    engine.rootContext()->setContextProperty("_markersModel", &markersModel);
//    engine.rootContext()->setContextProperty("_cppProxyModel", &proxyModel);

//    engine.addImportPath(QStringLiteral("../3rdparty/kirigami/"));
    engine.load(QUrl(QStringLiteral("qrc:///main.qml")));

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
