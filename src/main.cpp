/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2020-2025 Javier O. Cordero Pérez
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

#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS) || defined(Q_OS_WASM) || defined(Q_OS_WATCHOS) || defined(Q_OS_QNX)
#define KIRIGAMI_BUILD_TYPE_STATIC true
#include <kirigamiplugin.h>
#endif
// #include <KLocalizedContext>
// #include <KLocalizedString>
#ifndef Q_OS_WASM
#include <kaboutdata.h>
#endif

#if defined(KF6Crash_FOUND)
#include <KCrash>
#endif

#if defined(QHotkey_FOUND)
#include <QHotkey>
#endif

#if defined(Q_OS_MACOS)
#include <../3rdparty/KDMacTouchBar/src/kdmactouchbar.h>
#endif

#include "../qprompt_version.h"
#include "abstractunits.hpp"
//#include "documenthandler.h"
//#include "qmlutil.hpp"
#include <stdlib.h>

#define QPROMPT_URI "com.cuperino.qprompt"

using namespace Qt::Literals::StringLiterals;

Q_DECL_EXPORT int main(int argc, char *argv[])
{
#if defined(Q_OS_WINDOWS)
    // Workarround for broken opacity bug in DirectX RHIs...
    qputenv("QSG_RHI_BACKEND", QByteArray("opengl"));
#endif

    // Set theme
    qputenv("QT_QUICK_CONTROLS_MATERIAL_THEME", QByteArray("Dark"));
    qputenv("QT_QUICK_CONTROLS_MATERIAL_ACCENT", QByteArray("#3daee9"));

    // Initialize app metadata
    QCoreApplication::setOrganizationName(QString::fromUtf8("Cuperino"));
    QCoreApplication::setOrganizationDomain(QString::fromUtf8(QPROMPT_URI));
    QCoreApplication::setApplicationName(QString::fromUtf8("QPrompt"));

    // Acquire saved settings
#if (defined(Q_OS_MACOS))
    QSettings settings(QCoreApplication::organizationDomain(), QCoreApplication::applicationName());
#else
    QSettings settings(QCoreApplication::organizationName(), QCoreApplication::applicationName().toLower());
#endif

    QQuickStyle::setStyle("Material");
    // Instantiate app
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS) || defined(Q_OS_WASM) || defined(Q_OS_WATCHOS) || defined(Q_OS_QNX)
    QGuiApplication app(argc, argv);
#else
    QApplication app(argc, argv);
#endif

    QTranslator translator;
    // The following code forces the use of a specific language.
    QString language = settings.value("ui/language", "").toString();
    if (language.isEmpty()) {
        if (translator.load(QLatin1String(":/i18n/qprompt_en.qm")))
            app.installTranslator(&translator);
    }
    else {
        auto langCode = language.append(".UTF-8").toStdString();
        qDebug() << langCode;
        qputenv("LANGUAGE", langCode);
        qputenv("LC_ALL", langCode);
        qputenv("LANG", langCode);
        QLocale currLocale(QLocale(langCode.c_str()));
        QLocale::setDefault(currLocale);
        if (translator.load(QLatin1String(":/i18n/qprompt_" + langCode + ".qm")))
            app.installTranslator(&translator);
    }

    // Parse command line arguments
    QCommandLineParser parser;
    parser.setApplicationDescription(
        QLatin1String("Personal teleprompter software for all video makers. Built with ease of use, productivity, and smooth performance in mind."));
    parser.addHelpOption();
    parser.addVersionOption();
    parser.addPositionalArgument(QLatin1String("source"), QLatin1String("file", "File to copy."));
    parser.process(app);
    QStringList positionalArguments = parser.positionalArguments();
    QString fileToOpen = QLatin1String("");
    if (positionalArguments.length())
        fileToOpen = parser.positionalArguments().at(0);

    // Substract from 2 because order in app is intentionally inverted from order in Qt
    app.setLayoutDirection(static_cast<Qt::LayoutDirection>(2 - settings.value("ui/layout", 0).toInt()));

#if defined(KF6Crash_FOUND)
    // KCrash::setDrKonqiEnabled(true);
    KCrash::initialize();
    // KCrash::setCrashHandler( KCrash::defaultCrashHandler );
    KCrash::setFlags(KCrash::AutoRestart); // | KCrash::SaferDialog
    // qDebug() << "DrKonqui" << KCrash::isDrKonqiEnabled();
#endif

    const int currentYear = QDate::currentDate().year();
    QString copyrightYear = QString::number(currentYear);
    QString copyrightStatement1 = QStringLiteral("© 2020 Javier O. Cordero Pérez");
    QString copyrightStatement2 = QStringLiteral("© 2020-2025 Javier O. Cordero Pérez"); // , copyrightYear);
#ifndef Q_OS_WASM
    KAboutData aboutData(
        QLatin1String("qprompt"),
        QLatin1String("QPrompt"),
        QPROMPT_VERSION_STRING " (" + QString::fromUtf8(GIT_BRANCH) + "/" + QString::fromUtf8(GIT_COMMIT_HASH) + ")",
        QLatin1String("Personal teleprompter software for all video makers."),
        KAboutLicense::GPL_V3,
        (currentYear <= 2020) ? copyrightStatement1 : copyrightStatement2);
    // Overwrite default-generated values of organizationDomain & desktopFileName
    aboutData.setHomepage(QLatin1String("https://qprompt.app"));
    aboutData.setProductName("cuperino/qprompt");
    aboutData.setBugAddress("https://github.com/Cuperino/QPrompt/issues");
    aboutData.setOrganizationDomain(QByteArray(QPROMPT_URI));
    aboutData.setDesktopFileName(QLatin1String(QPROMPT_URI));
    KAboutPerson author(
        QStringLiteral("Javier O. Cordero Pérez"),
        QLatin1String("Author"),
        QLatin1String("javiercorderoperez@gmail.com"),
        QLatin1String("https://javiercordero.info"),
        QUrl("https://images.pling.com/cache/100x100-2/img/00/00/62/69/17/photo-2023-05-09-17-58-18-c.jpg"));
    aboutData.addAuthor(author);
    aboutData.addCredit(
        QString::fromUtf8("Mark"),
        QLatin1String("Wrote keycode to string QML abstraction"),
        QString::fromUtf8(""),
        QString::fromUtf8(""));
    aboutData.addCredit(QString::fromUtf8("Stuart Scoon <videosmith>"), QLatin1String("Software Tester"));
    aboutData.addCredit(QString::fromUtf8("Elimar Beck"), QLatin1String("Software Tester"));
    auto localeLangName = QLocale().name();
    if (!(language.isEmpty() || language.startsWith(QLatin1String("en"), Qt::CaseInsensitive) || localeLangName.startsWith(QLatin1String("en"), Qt::CaseInsensitive)))
        aboutData.setTranslator(QCoreApplication::translate("NAMES OF TRANSLATORS", "Names of translators"), QCoreApplication::translate("EMAILS OF TRANSLATORS", "Emails of translators"));
    // aboutData.addLicense(
    //     KAboutLicense::LGPL_V3
    //);
    //  Set the application metadata
    KAboutData::setApplicationData(aboutData);
#endif
    // qmlRegisterType<PrompterTimer>(QPROMPT_URI + ".promptertimer", 1, 0, "PrompterTimer");
    //    qmlRegisterType<DocumentHandler>(QPROMPT_URI ".document", 1, 0, "DocumentHandler");
    //    qmlRegisterType<MarkersModel>(QPROMPT_URI ".markers", 1, 0, "MarkersModel");
    //    qmlRegisterType<QmlUtil>(QPROMPT_URI ".qmlutil", 1, 0, "QmlUtil");
    //    qmlRegisterUncreatableType</*AbstractUnits*/>(QPROMPT_URI ".abstractunits", 1, 0, "Units", "Access to Duration enum");
    QQmlApplicationEngine engine;
    // qmlRegisterType<PrompterWindow>(QPROMPT_URI".prompterwindow", 1, 0, "PrompterWindow");

    //    qRegisterMetaType<Marker>();

#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS) || defined(Q_OS_WASM)
KirigamiPlugin::getInstance().registerTypes();
#endif

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
//    QIcon qpromptIcon(QStringLiteral(":images/qprompt"));
//    QAction *action = new QAction(qpromptIcon, "Toggle");
//    touchBar->addAction(action);
//    // connect(action, &QAction::triggered, this, &MainWindow::activated);
//    touchBar->addSeparator();
//    // Velocity and placement toachbar controls
//    touchBar->setTouchButtonStyle(KDMacTouchBar::IconOnly);
//    // Up
//    QIcon upIcon(QStringLiteral(":icons/go-previous"));
//    QAction *reduceAction = new QAction(upIcon, "Reduce");
//    touchBar->addAction(reduceAction);
//    touchBar->setPrincipialAction(reduceAction);
//    // connect(reduceAction, &QAction::triggered, this, &MainWindow::activated);
//    // Down
//    QIcon downIcon(QStringLiteral(":icons/go-next"));
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
    QHotkey hotkey(QKeySequence(QLatin1String("Meta+Alt+F10")), true, &app);
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

#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
    app.setWindowIcon(QIcon(":/qt/qml/com/cuperino/qprompt/images/qprompt-logo-wireframe.png"));
#else
    app.setWindowIcon(QIcon(":/qt/qml/com/cuperino/qprompt/images/qprompt.png"));
#endif
    // Add path to where KDE modules are installed
    // Linux paths
    engine.addImportPath(QStringLiteral("/lib/x86_64-linux-gnu/qml/"));
    engine.addImportPath(QStringLiteral("../lib/x86_64-linux-gnu/qml/"));
    engine.addImportPath(QStringLiteral("../dist/lib/x86_64-linux-gnu/qml/"));
    // Linux AppImage paths
    engine.addImportPath(QStringLiteral("../usr/lib/x86_64-linux-gnu/qml/"));
    engine.addImportPath(QStringLiteral("../usr/lib/aarch64-linux-gnu/qml/"));
    // Windows paths
    engine.addImportPath(QStringLiteral("../../lib/qml/"));
    engine.addImportPath(QStringLiteral("../lib/qml/"));
    engine.addImportPath(QStringLiteral("./lib/qml/"));
    // MacOS paths
    engine.addImportPath(QStringLiteral("../../../"));
    engine.addImportPath(QStringLiteral("../build/"));
    engine.addImportPath(QStringLiteral("../Resources/qml/"));
    // Send context data from C++ to QML
    // engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
#ifndef Q_OS_WASM
    engine.rootContext()->setContextProperty(QStringLiteral("aboutData"), QVariant::fromValue(KAboutData::applicationData()));
#endif
    if (positionalArguments.length())
        engine.rootContext()->setContextProperty(QStringLiteral("fileToOpen"), fileToOpen);
#if defined(Q_OS_MACOS)
    // engine.addImportPath(QStringLiteral("/opt/homebrew/lib/qml"));
    engine.addImportPath(QStringLiteral("/opt/homebrew/Cellar/kf5-kirigami2/5.95.0/lib/qt6/qml"));
#endif
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
    engine.load(QUrl(u"qrc:/qt/qml/com/cuperino/qprompt/kirigami_ui/main.qml"_s));
#else
    engine.load(QUrl(QStringLiteral("qrc:/qt/qml/com/cuperino/qprompt/kirigami_ui/main.qml")));
#endif

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    // qDebug() << QProcess::systemEnvironme nt();
    return app.exec();
}
