/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2020-2022 Javier O. Cordero Pérez
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

#include "qglobal.h"
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS) || defined(Q_OS_WASM) || defined(Q_OS_WATCHOS) || defined(Q_OS_QNX)
#include <QGuiApplication>
#else
#include <QApplication>
#include <QtWidgets>
#endif
#include <QDebug>
#include <QFontDatabase>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQmlFileSelector>
#include <QQuickStyle>
#include <QQuickView>
#include <QSettings>
#include <QUrl>
#include <QtQml/qqml.h>
#include <QtQml>
//#include "appwindow.h"

#if defined(Q_OS_IOS) || defined(Q_OS_WASM) || defined(Q_OS_WATCHOS) || defined(Q_OS_QNX)
#include "../3rdparty/kirigami/src/kirigamiplugin.h"
#endif
#include <KLocalizedContext>
#include <KLocalizedString>
#include <kaboutdata.h>

#if defined(KF5Crash_FOUND)
#include <KCrash>
#endif

#if defined(QHotkey_FOUND)
#include <QHotkey>
#endif

#if defined(Q_OS_MACOS)
#include <../3rdparty/KDMacTouchBar/src/kdmactouchbar.h>
#endif

#include "../qprompt_version.h"
#include "prompter/documenthandler.h"
#include "prompter/inputmanager.h"
#include "qt/abstractunits.hpp"
#include "qt/qmlutil.hpp"
#include <stdlib.h>

#define QPROMPT_URI "com.cuperino.qprompt"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS) || defined(Q_OS_WASM) || defined(Q_OS_WATCHOS) || defined(Q_OS_QNX)
    QGuiApplication app(argc, argv);
#else
    QApplication app(argc, argv);
#endif

    KLocalizedString::setApplicationDomain("qprompt");
    QCoreApplication::setOrganizationName(QString::fromUtf8("Cuperino"));
    QCoreApplication::setOrganizationDomain(QString::fromUtf8(QPROMPT_URI));
    QCoreApplication::setApplicationName(QString::fromUtf8("QPrompt"));

    QCommandLineParser parser;
    parser.setApplicationDescription(
        i18n("Personal teleprompter software for all video makers. Built with ease of use, productivity, and smooth performance in mind."));
    parser.addHelpOption();
    parser.addVersionOption();
    parser.addPositionalArgument("source", i18nc("file", "File to copy."));
    QCommandLineOption qgsIgnore(QStringList() << "q"
                                               << "qgs_ignore",
                                 i18n("Ignore QSG_RENDER_LOOP environment variable."));
    parser.addOption(qgsIgnore);
    parser.process(app);

    QStringList positionalArguments = parser.positionalArguments();
    QString fileToOpen = "";
    if (positionalArguments.length())
        fileToOpen = parser.positionalArguments().at(0);

    QSettings settings(QCoreApplication::organizationName(), QCoreApplication::applicationName().toLower());
    auto enableProjections = settings.value("projections/enabled", false);

// The following code forces the use of specific renderer modes to enable screen projections to work.
// This hacky must be completely
#if defined(Q_OS_WINDOWS) || defined(Q_OS_MACOS) || defined(Q_OS_LINUX)
    if (enableProjections.toBool())
#if defined(Q_OS_WINDOWS)
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
        qputenv("QSG_RENDER_LOOP", "windows");
#else
        qputenv("QSG_RENDER_LOOP", "basic");
#endif
    else
        qputenv("QSG_RENDER_LOOP", "threaded");
#else // MACOS or LINUX
      // On *nix, setenv needs to override QSG_RENDER_LOOP for it to take effect after qprompt automatically restarts.
      // By default, we do not override environment variables. qgsIgnore is set by the code doing the restart.
        setenv("QSG_RENDER_LOOP", "basic", parser.isSet(qgsIgnore) ? 1 : 0);
#if defined(Q_OS_LINUX)
    // Mac does not currently support threaded mode, forcing it crashes the app on startup.
    else
        setenv("QSG_RENDER_LOOP", "threaded", parser.isSet(qgsIgnore) ? 1 : 0);
#endif
#endif
#endif

    // Substract from 2 because order in app is intentionally inverted from order in Qt
    app.setLayoutDirection(static_cast<Qt::LayoutDirection>(2 - settings.value("ui/layout", 0).toInt()));

#if defined(KF5Crash_FOUND)
    // KCrash::setDrKonqiEnabled(true);
    KCrash::initialize();
    // KCrash::setCrashHandler( KCrash::defaultCrashHandler );
    KCrash::setFlags(KCrash::AutoRestart); // | KCrash::SaferDialog
    // qDebug() << "DrKonqui" << KCrash::isDrKonqiEnabled();
#endif

    const int currentYear = QDate::currentDate().year();
    QString copyrightYear = QString::number(currentYear);
    QString copyrightStatement1 = i18n("© 2021 Javier O. Cordero Pérez");
    QString copyrightStatement2 = i18n("© 2021-%1 Javier O. Cordero Pérez", copyrightYear);
    KAboutData aboutData("qprompt",
                         "QPrompt",
                         QPROMPT_VERSION_STRING " (" + QString::fromUtf8(GIT_BRANCH) + "/" + QString::fromUtf8(GIT_COMMIT_HASH) + ")",
                         i18n("Personal teleprompter software for all video makers."),
                         KAboutLicense::GPL_V3,
                         // ki18ncp("© 2021-currentYear Author", "© 2021 Javier O. Cordero Pérez", "© 2021-<numid>%1</numid> Javier O. Cordero
                         // Pérez").subs(currentYear).toString());
                         (currentYear <= 2021) ? copyrightStatement1 : copyrightStatement2);
    // Overwrite default-generated values of organizationDomain & desktopFileName
    aboutData.setHomepage("https://qprompt.app");
    aboutData.setProductName("cuperino/qprompt");
    aboutData.setBugAddress("https://github.com/Cuperino/QPrompt/issues");
    aboutData.setOrganizationDomain(QPROMPT_URI);
    aboutData.setDesktopFileName(QPROMPT_URI);
    aboutData.addAuthor(QString::fromUtf8("Javier O. Cordero Pérez"),
                        i18n("Author"),
                        QString::fromUtf8("javiercorderoperez@gmail.com"),
                        QString::fromUtf8("https://javiercordero.info"),
                        QString::fromUtf8("cuperino"));
    aboutData.addCredit(QString::fromUtf8("Mark"),
                        i18n("Wrote keycode to string QML abstraction"),
                        QString::fromUtf8(""),
                        QString::fromUtf8("https://stackoverflow.com/a/64862996/3833454"));
    aboutData.addCredit(QString::fromUtf8("videosmith"), i18nc("Active software tester", "Active tester"));
    aboutData.setTranslator(i18nc("NAME OF TRANSLATORS", "Your names"), i18nc("EMAIL OF TRANSLATORS", "Your emails"));
    // aboutData.addLicense(
    //     KAboutLicense::LGPL_V3
    //);
    //  Set the application metadata
    KAboutData::setApplicationData(aboutData);

    if (QFontDatabase::addApplicationFont(QString::fromUtf8(":/fonts/fontello.ttf")) == -1)
        qWarning() << i18n("Failed to load icons from fontello.ttf");

    // qmlRegisterType<PrompterTimer>(QPROMPT_URI + ".promptertimer", 1, 0, "PrompterTimer");
    qmlRegisterType<DocumentHandler>(QPROMPT_URI ".document", 1, 0, "DocumentHandler");
    qmlRegisterType<MarkersModel>(QPROMPT_URI ".markers", 1, 0, "MarkersModel");
    qmlRegisterType<QmlUtil>(QPROMPT_URI ".qmlutil", 1, 0, "QmlUtil");
    qmlRegisterUncreatableType<AbstractUnits>(QPROMPT_URI ".abstractunits", 1, 0, "Units", "Access to Duration enum");
    qmlRegisterType<KeyboardInput>(QPROMPT_URI ".joypadinput", 1, 0, "KeyboardInput");
    qmlRegisterType<JoypadInput>(QPROMPT_URI ".keyboardinput", 1, 0, "JoypadInput");
    QQmlApplicationEngine engine;
    // qmlRegisterType<PrompterWindow>(QPROMPT_URI".prompterwindow", 1, 0, "PrompterWindow");

    qRegisterMetaType<Marker>();

    // #ifdef Q_OS_ANDROID
    // KirigamiPlugin::getInstance().registerTypes();
    // #endif

#if defined(Q_OS_MACOS)
    // Enable automatic display of dialog prompts on the touchbar.
    KDMacTouchBar::setAutomaticallyCreateMessageBoxTouchBar(true);
//    // Create touchbar for use through all of QPrompt's execusion
//    KDMacTouchBar *touchBar = new KDMacTouchBar();
//    //QMainWindow *mainWindow = nullptr;
//    //foreach(QWidget *widget, app.topLevelWidgets())
//    //    if(widget->inherits("QMainWindow")) {
//    //        mainWindow = qobject_cast<QMainWindow *>(widget);
//    //        break;
//    //    };
//    //KDMacTouchBar *touchBar = new KDMacTouchBar(mainWindow);
//    // Toggle teleprompter state
//    QIcon qpromptIcon(QStringLiteral("://images/qprompt"));
//    QAction *action = new QAction(qpromptIcon, "Toggle");
//    touchBar->addAction(action);
//    // connect(action, &QAction::triggered, this, &MainWindow::activated);
//    touchBar->addSeparator();
//    // Velocity and placement toachbar controls
//    touchBar->setTouchButtonStyle(KDMacTouchBar::IconOnly);
//    // Up
//    QIcon upIcon(QStringLiteral("://icons/go-previous"));
//    QAction *reduceAction = new QAction(upIcon, "Reduce");
//    touchBar->addAction(reduceAction);
//    touchBar->setPrincipialAction(reduceAction);
//    // connect(reduceAction, &QAction::triggered, this, &MainWindow::activated);
//    // Down
//    QIcon downIcon(QStringLiteral("://icons/go-next"));
//    QAction *increaseAction = new QAction(downIcon, "Increase");
//    touchBar->addAction(increaseAction);
//    // connect(increaseAction, &QAction::triggered, this, &MainWindow::activated);
////    touchBar->addSeparator();
////    // Stop prompter
////    QAction *stopAction = new QAction(upIcon, "Stop");
////    touchBar->addAction(stopAction);
////    // connect(stopAction, &QAction::triggered, this, &MainWindow::activated);
#endif

#if defined(QHotkey_FOUND)
    // Toggle transparency of all windows
    QHotkey hotkey(QKeySequence("Meta+Alt+F10"), true, &app);
    QObject::connect(&hotkey, &QHotkey::activated, qApp, [&]() {
        QWindowList windows = app.allWindows();
        QWindow *topWindow = windows.first();
        const bool initiallyOpaque = topWindow->opacity() == 1.0;
        const int windowAmount = windows.length();
        for (int i = 0; i < windowAmount; i++)
            if (initiallyOpaque)
                windows[i]->setOpacity(0.2);
            else
                windows[i]->setOpacity(1.0);
    });
#endif

    // Un-comment to force RightToLeft Layout for debugging purposes
    // app.setLayoutDirection(Qt::RightToLeft);

#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS) || defined(Q_OS_QNX)
    app.setWindowIcon(QIcon(":/images/qprompt-logo-wireframe.png"));
#else
    app.setWindowIcon(QIcon(QString::fromUtf8(":/images/qprompt.png")));
#endif
    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
    engine.rootContext()->setContextProperty(QStringLiteral("aboutData"), QVariant::fromValue(KAboutData::applicationData()));
    if (positionalArguments.length())
        engine.rootContext()->setContextProperty(QStringLiteral("fileToOpen"), fileToOpen);
        // engine.addImportPath(QStringLiteral("../3rdparty/kirigami/"));
        // engine.addImportPath(QStringLiteral("/usr/local/lib/qml"));
        // engine.addImportPath("/opt/local/lib/qml/org/kde/kirigami.2");
#if defined(Q_OS_MACOS)
    // engine.addImportPath(QStringLiteral("/opt/homebrew/lib/qml"));
    engine.addImportPath(QStringLiteral("/opt/homebrew/Cellar/kf5-kirigami2/5.95.0/lib/qt5/qml"));
#endif
    engine.load(QUrl(QStringLiteral("qrc:///main.qml")));

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    // qDebug() << QProcess::systemEnvironment();
    return app.exec();
}
