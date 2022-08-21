#ifndef PROMPTERWINDOW_H
#define PROMPTERWINDOW_H

#include <QQuickWindow>
#include <QQmlComponent>
//#include <QObject>

class QPromptWindow : public QQuickWindow
{
    Q_OBJECT
public:
    QPromptWindow(QWindow *parent = 0);
    ~QPromptWindow();

protected:
    void resizeEvent(QResizeEvent *e) Q_DECL_OVERRIDE;

    void mousePressEvent(QMouseEvent *e) Q_DECL_OVERRIDE;
    void mouseMoveEvent(QMouseEvent *e) Q_DECL_OVERRIDE;
    void mouseReleaseEvent(QMouseEvent *e) Q_DECL_OVERRIDE;

private:
    void syncScene();
    void draw();

    void onQmlComponentLoadingComplete();
    void updateRootItemSize();

    QOpenGLContext *m_context;

    QQuickRenderControl *m_renderControl;
    QQuickWindow *m_quickWindow;
    QQmlComponent *m_qmlComponent;
    QQuickItem *m_rootItem;
};

#endif // PROMPTERWINDOW_H
