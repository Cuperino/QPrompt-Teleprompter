#ifndef PROMPTERWINDOW_H
#define PROMPTERWINDOW_H

#include "qpromptwindow.h"
#include <QQmlComponent>
//#include <QObject>

class PrompterWindow : public QPromptWindow
{
    Q_OBJECT
public:
    PrompterWindow(QQmlEngine *engine, QWindow *parent = 0);
};

#endif // PROMPTERWINDOW_H
