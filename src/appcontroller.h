#pragma once

#include <QObject>
#include <QQmlEngine>
#include <QAction>
#if defined(QHotkey_FOUND)
#include <QHotkey>
#endif

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
    virtual void m_initializeSource();
};

class GlobalHotkeys : public AbstractInputSource
{
    Q_OBJECT
    QML_ELEMENT
public:
    GlobalHotkeys(AppController *controller);
    enum Action {
        TogglePrompter,
        IncreaseVelocity,
        DecreaseVelocity,
        Pause,
        Stop,
        Reverse,
        Rewind,
        FastForward,
        SkipBackwards,
        SkipForwards,
        PreviousMarker,
        NextMarker,
        VelocityToNeg10,
        VelocityToNeg9,
        VelocityToNeg8,
        VelocityToNeg7,
        VelocityToNeg6,
        VelocityToNeg5,
        VelocityToNeg4,
        VelocityToNeg3,
        VelocityToNeg2,
        VelocityToNeg1,
        VelocityTo0,
        VelocityTo1,
        VelocityTo2,
        VelocityTo3,
        VelocityTo4,
        VelocityTo5,
        VelocityTo6,
        VelocityTo7,
        VelocityTo8,
        VelocityTo9,
        VelocityTo10
    };
    Q_ENUM(Action)
protected:
#if defined(QHotkey_FOUND)
    QHotkey *m_togglePrompterHotkey;
    QHotkey *m_increaseVelocityHotkey;
    QHotkey *m_decreaseVelocityHotkey;
    QHotkey *m_pauseHotkey;
    QHotkey *m_stopHotkey;
    QHotkey *m_reverseHotkey;
    QHotkey *m_rewindHotkey;
    QHotkey *m_fastForwardHotkey;
    QHotkey *m_skipBackwardsHotkey;
    QHotkey *m_skipForwardsHotkey;
    QHotkey *m_previousMarkerHotkey;
    QHotkey *m_nextMarkerHotkey;
    QHotkey *m_setVelocityToNeg10Hotkey;
    QHotkey *m_setVelocityToNeg9Hotkey;
    QHotkey *m_setVelocityToNeg8Hotkey;
    QHotkey *m_setVelocityToNeg7Hotkey;
    QHotkey *m_setVelocityToNeg6Hotkey;
    QHotkey *m_setVelocityToNeg5Hotkey;
    QHotkey *m_setVelocityToNeg4Hotkey;
    QHotkey *m_setVelocityToNeg3Hotkey;
    QHotkey *m_setVelocityToNeg2Hotkey;
    QHotkey *m_setVelocityToNeg1Hotkey;
    QHotkey *m_setVelocityTo0Hotkey;
    QHotkey *m_setVelocityTo1Hotkey;
    QHotkey *m_setVelocityTo2Hotkey;
    QHotkey *m_setVelocityTo3Hotkey;
    QHotkey *m_setVelocityTo4Hotkey;
    QHotkey *m_setVelocityTo5Hotkey;
    QHotkey *m_setVelocityTo6Hotkey;
    QHotkey *m_setVelocityTo7Hotkey;
    QHotkey *m_setVelocityTo8Hotkey;
    QHotkey *m_setVelocityTo9Hotkey;
    QHotkey *m_setVelocityTo10Hotkey;
#endif
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
    void m_initializeSource() override;
private:
    void m_setShortcut(Qt::Key key, Qt::KeyboardModifier modifier, Action action);
    void m_setActionShortcut(Qt::Key key, Qt::KeyboardModifier modifier, QAction *action);
#if defined(QHotkey_FOUND)
    void m_setHotkeyShortcut(Qt::Key key, Qt::KeyboardModifier modifier, QHotkey *hotkey);
#endif
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
