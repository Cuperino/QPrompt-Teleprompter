#include <QApplication>
// #include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <QUrl>
#include <KLocalizedContext>
#include <QFontDatabase>
#include <QDebug>
// #include <QQmlContext>
#include <QQmlFileSelector>
#include <QQuickStyle>

#include "documenthandler.h"


Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);
    QCoreApplication::setOrganizationName("Cuperino");
    QCoreApplication::setOrganizationDomain("javiercordero.info");
    QCoreApplication::setApplicationName("QThePrompter");

    QFontDatabase fontDatabase;
    if (fontDatabase.addApplicationFont(":/fonts/fontello.ttf") == -1)
        qWarning() << "Failed to load fontello.ttf";

    //qmlRegisterType<DocumentHandler>("com.cuperino.qtheprompter", 1, 0, "DocumentHandler");

    QStringList selectors;
#ifdef QT_EXTRA_FILE_SELECTOR
    selectors += QT_EXTRA_FILE_SELECTOR;
#else
    if (app.arguments().contains("-touch"))
        selectors += "touch";
#endif

    QQmlApplicationEngine engine;
    QQmlFileSelector::get(&engine)->setExtraSelectors(selectors);

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
    engine.load(QUrl(QStringLiteral("qrc:///main.qml")));

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
