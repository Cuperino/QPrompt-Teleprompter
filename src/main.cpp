/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2020-2021 Javier O. Cordero Pérez
 **
 ** This file is part of QPrompt.
 **
 ** This program is free software: you can redistribute it and/or modify
 ** it under the terms of the GNU General Public License as published by
 ** the Free Software Foundation, version 3 of the License.
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

#include "../qprompt_version.h"
#include "prompter/documenthandler.h"
#include "qt/qmlutil.hpp"

#define QPROMPT_URI "com.cuperino.qprompt"

Q_DECL_EXPORT int main(int argc, char *argv[])
{

#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS) || defined(Q_OS_WASM) || defined(Q_OS_WATCHOS) || defined(Q_OS_QNX)
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QGuiApplication app(argc, argv);
#else

#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QApplication app(argc, argv);
#endif
    KLocalizedString::setApplicationDomain("qprompt");
    QCoreApplication::setOrganizationName(QString::fromStdString("Cuperino"));
    QCoreApplication::setOrganizationDomain(QString::fromStdString(QPROMPT_URI));
    QCoreApplication::setApplicationName(QString::fromStdString("QPrompt"));

    const int currentYear = QDate::currentDate().year();
    QString copyrightYear = QString::number(currentYear);
    QString copyrightStatement1 = i18n("© 2021 Javier O. Cordero Pérez");
    QString copyrightStatement2 = i18n("© 2021-%1 Javier O. Cordero Pérez", copyrightYear);
    KAboutData aboutData("qprompt", "QPrompt",
                         QPROMPT_VERSION_STRING " (" + QString::fromStdString(GIT_BRANCH) + "/" + QString::fromStdString(GIT_COMMIT_HASH) + ")",
                         i18n("Personal teleprompter software for all video makers."),
                         KAboutLicense::GPL_V3,
                         // ki18ncp("© 2021-currentYear Author", "© 2021 Javier O. Cordero Pérez", "© 2021-<numid>%1</numid> Javier O. Cordero Pérez").subs(currentYear).toString());
                         (currentYear <= 2021) ? copyrightStatement1 : copyrightStatement2);
    // Overwrite default-generated values of organizationDomain & desktopFileName
    aboutData.setHomepage("https://qprompt.app");
    aboutData.setProductName("cuperino/qprompt");
    aboutData.setBugAddress("https://github.com/Cuperino/QPrompt/issues");
    aboutData.setOrganizationDomain(QPROMPT_URI);
    aboutData.setDesktopFileName(QPROMPT_URI);
    aboutData.addAuthor (
        QString::fromStdString("Javier O. Cordero Pérez"),
        i18n("Author"),
        QString::fromStdString("javiercorderoperez@gmail.com"),
        QString::fromStdString("https://javiercordero.info"),
        QString::fromStdString("cuperino")
    );
    aboutData.addCredit (
        QString::fromStdString("Mark"),
        i18n("Wrote keycode to string QML abstraction"),
        QString::fromStdString(""),
        QString::fromStdString("https://stackoverflow.com/a/64862996/3833454")
    );
    aboutData.setTranslator(i18nc("NAME OF TRANSLATORS", "Your names"), i18nc("EMAIL OF TRANSLATORS", "Your emails"));
    //aboutData.addLicense(
    //    KAboutLicense::LGPL_V3
    //);
    // Set the application metadata
    KAboutData::setApplicationData(aboutData);

    if (QFontDatabase::addApplicationFont(QString::fromStdString(":/fonts/fontello.ttf")) == -1)
        qWarning() << i18n("Failed to load icons from fontello.ttf");

    //qmlRegisterType<PrompterTimer>(QPROMPT_URI + ".promptertimer", 1, 0, "PrompterTimer");
    qmlRegisterType<DocumentHandler>(QPROMPT_URI".document", 1, 0, "DocumentHandler");
    qmlRegisterType<MarkersModel>(QPROMPT_URI".markers", 1, 0, "MarkersModel");
    qmlRegisterType<QmlUtil>(QPROMPT_URI".qmlutil", 1, 0, "QmlUtil");
    qRegisterMetaType<Marker>();

    QQmlApplicationEngine engine;
    // #ifdef Q_OS_ANDROID
    // KirigamiPlugin::getInstance().registerTypes();
    // #endif

    // Un-comment to force RightToLeft Layout for debugging purposes
    //app.setLayoutDirection(Qt::RightToLeft);
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS) || defined(Q_OS_QNX)
    app.setWindowIcon(QIcon(":/images/qprompt-logo-wireframe.png"));
#else
    app.setWindowIcon(QIcon(QString::fromStdString(":/images/qprompt.png")));
#endif
    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
    engine.rootContext()->setContextProperty(QStringLiteral("aboutData"), QVariant::fromValue(KAboutData::applicationData()));

    //engine.addImportPath(QStringLiteral("../3rdparty/kirigami/"));
    //engine.addImportPath(QStringLiteral("/usr/local/lib/qml"));
    engine.addImportPath(QStringLiteral("/opt/homebrew/lib/qml"));
    //engine.addImportPath("/opt/local/lib/qml/org/kde/kirigami.2");
    engine.load(QUrl(QStringLiteral("qrc:///main.qml")));

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

//     qDebug() << QProcess::systemEnvironment();

    return app.exec();
}
