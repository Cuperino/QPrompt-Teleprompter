#pragma once

#include <QObject>
#include <QQmlEngine>
#include <QAction>

class AppController;

class AbstractInputSource : public QObject
{
    Q_OBJECT
public:
    AbstractInputSource() = delete;
    AbstractInputSource(AppController *controller);
signals:
    void togglePrompter(bool checked=false);
    void increaseVelocity(bool checked=false);
    void decreaseVelocity(bool checked=false);
    void pause(bool checked=false);
    void stop(bool checked=false);
    void setVelocity(int velocity);
    void reverse(bool checked=false);
    void rewind(bool checked);
    void fastForward(bool checked);
    void skipBackwards(bool checked=false);
    void skipForwards(bool checked=false);
    void previousMarker(bool checked=false);
    void nextMarker(bool checked=false);
protected:
    AppController *m_controller;
    virtual void initializeSource();
};

class GlobalHotkeys : public AbstractInputSource
{
    Q_OBJECT
public:
    GlobalHotkeys(AppController *controller);
protected:
    QAction *m_togglePrompterAction;
    QAction *m_increaseVelocityAction;
    QAction *m_decreaseVelocityAction;
    QAction *m_pauseAction;
    QAction *m_stopAction;
    QAction *m_reverseAction;
    QAction *m_rewindAction;
    QAction *m_fastForwardAction;
    QAction *m_skipBackwardsAction;
    QAction *m_skipForwardsAction;
    QAction *m_previousMarkerAction;
    QAction *m_nextMarkerAction;
    QAction *m_setVelocityToNeg10Action;
    QAction *m_setVelocityToNeg9Action;
    QAction *m_setVelocityToNeg8Action;
    QAction *m_setVelocityToNeg7Action;
    QAction *m_setVelocityToNeg6Action;
    QAction *m_setVelocityToNeg5Action;
    QAction *m_setVelocityToNeg4Action;
    QAction *m_setVelocityToNeg3Action;
    QAction *m_setVelocityToNeg2Action;
    QAction *m_setVelocityToNeg1Action;
    QAction *m_setVelocityTo0Action;
    QAction *m_setVelocityTo1Action;
    QAction *m_setVelocityTo2Action;
    QAction *m_setVelocityTo3Action;
    QAction *m_setVelocityTo4Action;
    QAction *m_setVelocityTo5Action;
    QAction *m_setVelocityTo6Action;
    QAction *m_setVelocityTo7Action;
    QAction *m_setVelocityTo8Action;
    QAction *m_setVelocityTo9Action;
    QAction *m_setVelocityTo10Action;
protected:
    void initializeSource() override;
};

class AppController : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
private:
    explicit AppController(QObject *parent = nullptr);
public:
    static AppController *create(QQmlEngine *qmlEngine, QJSEngine *);
signals:
    // Prompter
    void togglePrompter();
    void increaseVelocity();
    void decreaseVelocity();
    void pause();
    void stop();
    void reverse();
    void rewind();
    void fastForward();
    void skipBackwards();
    void skipForwards();
    void previousMarker();
    void nextMarker();
    void setVelocity(int velocity);
private:
    GlobalHotkeys *m_hotkeys;
};
