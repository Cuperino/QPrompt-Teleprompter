// "How to use QKeySequence or QKeySequenceEdit from QML?" answer from Nov 16, 2020 by Mark (user 353407 on StackOverflow)
// Link: https://stackoverflow.com/a/64862996/3833454
// License: https://creativecommons.org/licenses/by-sa/4.0/

#ifndef QMLUTIL_H
#define QMLUTIL_H

#include <QObject>
#include <QKeySequence>
#include <QProcess>
#include <QCoreApplication>

// A singleton object to implement C++ functions that can be called from QML
class QmlUtil : public QObject{
   Q_OBJECT
   QML_ELEMENT
public:
    Q_INVOKABLE bool isKeyUnknown(const int key) {
        // weird key codes that appear when modifiers
        // are pressed without accompanying standard keys
        constexpr int NO_KEY_LOW = 16777248;
        constexpr int NO_KEY_HIGH = 16777251;
        if (NO_KEY_LOW <= key && key <= NO_KEY_HIGH) {
           return true;
        }

        if (key == Qt::Key_unknown) {
            return true;
        }

        return false;
    }
    Q_INVOKABLE QString keyToString(const int key, const int modifiers){
        if (!isKeyUnknown(key)) {
            return QKeySequence(key | modifiers).toString();
        } else {
            // Change to "Ctrl+[garbage]" to "Ctrl+_"
            QString modifierOnlyString = QKeySequence(Qt::Key_Underscore | modifiers).toString();

            // Change "Ctrl+_" to "Ctrl+..."
            modifierOnlyString.replace(QString::fromStdString("_"), QString::fromStdString("..."));
            return modifierOnlyString;
        }
    }
    Q_INVOKABLE void restartApplication() {
        QProcess::startDetached(QCoreApplication::applicationFilePath(), {});
        QCoreApplication::quit();
    }
};
#endif // QMLUTIL_H
