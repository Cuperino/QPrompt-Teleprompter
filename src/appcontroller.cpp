#include "appcontroller.h"

#if defined(Q_OS_UNIX) && !defined(Q_OS_APPLE) && !defined(Q_OS_ANDROID) && !defined(Q_OS_WASM)
// Used to provide global shortcuts in KDE Plasma
#include <KGlobalAccel>
#define Use_GlobalAccel = 1
#endif

AppController::AppController(QObject *parent) : QObject(parent)
    , m_hotkeys(new GlobalHotkeys(this))
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
}

AppController *AppController::create(QQmlEngine *qmlEngine, QJSEngine *)
{
    static auto singleton = new AppController();
    Q_ASSERT(qmlEngine->thread() == singleton->thread());
    return singleton;
}

AbstractInputSource::AbstractInputSource(AppController *controller)
    : QObject(controller)
    , m_controller(controller)
{
}

void AbstractInputSource::m_initializeSource()
{
    connect(this, &AbstractInputSource::togglePrompter, m_controller, &AppController::togglePrompter);
    connect(this, &AbstractInputSource::increaseVelocity, m_controller, &AppController::increaseVelocity);
    connect(this, &AbstractInputSource::decreaseVelocity, m_controller, &AppController::decreaseVelocity);
    connect(this, &AbstractInputSource::pause, m_controller, &AppController::pause);
    connect(this, &AbstractInputSource::stop, m_controller, &AppController::stop);
    connect(this, &AbstractInputSource::setVelocity, m_controller, &AppController::setVelocity);
    connect(this, &AbstractInputSource::reverse, m_controller, &AppController::reverse);
    connect(this, &AbstractInputSource::rewind, m_controller, &AppController::rewind);
    connect(this, &AbstractInputSource::fastForward, m_controller, &AppController::fastForward);
    connect(this, &AbstractInputSource::skipBackwards, m_controller, &AppController::skipBackwards);
    connect(this, &AbstractInputSource::skipForwards, m_controller, &AppController::skipForwards);
    connect(this, &AbstractInputSource::previousMarker, m_controller, &AppController::previousMarker);
    connect(this, &AbstractInputSource::nextMarker, m_controller, &AppController::nextMarker);
}

GlobalHotkeys::GlobalHotkeys(AppController *controller) : AbstractInputSource(controller)
#if defined(QHotkey_FOUND)
    , m_togglePrompterHotkey(new QHotkey(this))
    , m_increaseVelocityHotkey(new QHotkey(this))
    , m_decreaseVelocityHotkey(new QHotkey(this))
    , m_pauseHotkey(new QHotkey(this))
    , m_stopHotkey(new QHotkey(this))
    , m_reverseHotkey(new QHotkey(this))
    , m_rewindHotkey(new QHotkey(this))
    , m_fastForwardHotkey(new QHotkey(this))
    , m_skipBackwardsHotkey(new QHotkey(this))
    , m_skipForwardsHotkey(new QHotkey(this))
    , m_previousMarkerHotkey(new QHotkey(this))
    , m_nextMarkerHotkey(new QHotkey(this))
    , m_setVelocityToNeg10Hotkey(new QHotkey(this))
    , m_setVelocityToNeg9Hotkey(new QHotkey(this))
    , m_setVelocityToNeg8Hotkey(new QHotkey(this))
    , m_setVelocityToNeg7Hotkey(new QHotkey(this))
    , m_setVelocityToNeg6Hotkey(new QHotkey(this))
    , m_setVelocityToNeg5Hotkey(new QHotkey(this))
    , m_setVelocityToNeg4Hotkey(new QHotkey(this))
    , m_setVelocityToNeg3Hotkey(new QHotkey(this))
    , m_setVelocityToNeg2Hotkey(new QHotkey(this))
    , m_setVelocityToNeg1Hotkey(new QHotkey(this))
    , m_setVelocityTo0Hotkey(new QHotkey(this))
    , m_setVelocityTo1Hotkey(new QHotkey(this))
    , m_setVelocityTo2Hotkey(new QHotkey(this))
    , m_setVelocityTo3Hotkey(new QHotkey(this))
    , m_setVelocityTo4Hotkey(new QHotkey(this))
    , m_setVelocityTo5Hotkey(new QHotkey(this))
    , m_setVelocityTo6Hotkey(new QHotkey(this))
    , m_setVelocityTo7Hotkey(new QHotkey(this))
    , m_setVelocityTo8Hotkey(new QHotkey(this))
    , m_setVelocityTo9Hotkey(new QHotkey(this))
    , m_setVelocityTo10Hotkey(new QHotkey(this))
#endif
    , m_togglePrompterAction(new QAction(tr("Toggle Prompter"), this))
    , m_increaseVelocityAction(new QAction(tr("Increase Velocity"), this))
    , m_decreaseVelocityAction(new QAction(tr("Decrease Velocity"), this))
    , m_pauseAction(new QAction(tr("Pause"), this))
    , m_stopAction(new QAction(tr("Stop"), this))
    , m_reverseAction(new QAction(tr("Reverse"), this))
    , m_rewindAction(new QAction(tr("Rewind"), this))
    , m_fastForwardAction(new QAction(tr("Fast Forward"), this))
    , m_skipBackwardsAction(new QAction(tr("Skip Backwards"), this))
    , m_skipForwardsAction(new QAction(tr("Skip Forwards"), this))
    , m_previousMarkerAction(new QAction(tr("Previous Marker"), this))
    , m_nextMarkerAction(new QAction(tr("Next Marker"), this))
    , m_setVelocityToNeg10Action(new QAction(tr("Set Velocity to -10"), this))
    , m_setVelocityToNeg9Action(new QAction(tr("Set Velocity to -9"), this))
    , m_setVelocityToNeg8Action(new QAction(tr("Set Velocity to -8"), this))
    , m_setVelocityToNeg7Action(new QAction(tr("Set Velocity to -7"), this))
    , m_setVelocityToNeg6Action(new QAction(tr("Set Velocity to -6"), this))
    , m_setVelocityToNeg5Action(new QAction(tr("Set Velocity to -5"), this))
    , m_setVelocityToNeg4Action(new QAction(tr("Set Velocity to -4"), this))
    , m_setVelocityToNeg3Action(new QAction(tr("Set Velocity to -3"), this))
    , m_setVelocityToNeg2Action(new QAction(tr("Set Velocity to -2"), this))
    , m_setVelocityToNeg1Action(new QAction(tr("Set Velocity to -1"), this))
    , m_setVelocityTo0Action(new QAction(tr("Set Velocity to 0"), this))
    , m_setVelocityTo1Action(new QAction(tr("Set Velocity to 1"), this))
    , m_setVelocityTo2Action(new QAction(tr("Set Velocity to 2"), this))
    , m_setVelocityTo3Action(new QAction(tr("Set Velocity to 3"), this))
    , m_setVelocityTo4Action(new QAction(tr("Set Velocity to 4"), this))
    , m_setVelocityTo5Action(new QAction(tr("Set Velocity to 5"), this))
    , m_setVelocityTo6Action(new QAction(tr("Set Velocity to 6"), this))
    , m_setVelocityTo7Action(new QAction(tr("Set Velocity to 7"), this))
    , m_setVelocityTo8Action(new QAction(tr("Set Velocity to 8"), this))
    , m_setVelocityTo9Action(new QAction(tr("Set Velocity to 9"), this))
    , m_setVelocityTo10Action(new QAction(tr("Set Velocity to 10"), this))
{
    // Setup input
    m_initializeSource();
}

void GlobalHotkeys::m_initializeSource() {
    // Readable name
    m_togglePrompterAction->setObjectName(QStringLiteral("togglePrompter"));
    m_increaseVelocityAction->setObjectName(QStringLiteral("increaseVelocity"));
    m_decreaseVelocityAction->setObjectName(QStringLiteral("decreaseVelocity"));
    m_pauseAction->setObjectName(QStringLiteral("pause"));
    m_stopAction->setObjectName(QStringLiteral("stop"));
    m_reverseAction->setObjectName(QStringLiteral("reverse"));
    m_rewindAction->setObjectName(QStringLiteral("rewind"));
    m_fastForwardAction->setObjectName(QStringLiteral("fastForward"));
    m_skipBackwardsAction->setObjectName(QStringLiteral("skipBackwards"));
    m_skipForwardsAction->setObjectName(QStringLiteral("skipForwards"));
    m_previousMarkerAction->setObjectName(QStringLiteral("previousMarker"));
    m_nextMarkerAction->setObjectName(QStringLiteral("nextMarker"));
    m_setVelocityToNeg10Action->setObjectName(QStringLiteral("setVelocityToNeg10"));
    m_setVelocityToNeg9Action->setObjectName(QStringLiteral("setVelocityToNeg9"));
    m_setVelocityToNeg8Action->setObjectName(QStringLiteral("setVelocityToNeg8"));
    m_setVelocityToNeg7Action->setObjectName(QStringLiteral("setVelocityToNeg7"));
    m_setVelocityToNeg6Action->setObjectName(QStringLiteral("setVelocityToNeg6"));
    m_setVelocityToNeg5Action->setObjectName(QStringLiteral("setVelocityToNeg5"));
    m_setVelocityToNeg4Action->setObjectName(QStringLiteral("setVelocityToNeg4"));
    m_setVelocityToNeg3Action->setObjectName(QStringLiteral("setVelocityToNeg3"));
    m_setVelocityToNeg2Action->setObjectName(QStringLiteral("setVelocityToNeg2"));
    m_setVelocityToNeg1Action->setObjectName(QStringLiteral("setVelocityToNeg1"));
    m_setVelocityTo0Action->setObjectName(QStringLiteral("setVelocityTo0"));
    m_setVelocityTo1Action->setObjectName(QStringLiteral("setVelocityTo1"));
    m_setVelocityTo2Action->setObjectName(QStringLiteral("setVelocityTo2"));
    m_setVelocityTo3Action->setObjectName(QStringLiteral("setVelocityTo3"));
    m_setVelocityTo4Action->setObjectName(QStringLiteral("setVelocityTo4"));
    m_setVelocityTo5Action->setObjectName(QStringLiteral("setVelocityTo5"));
    m_setVelocityTo6Action->setObjectName(QStringLiteral("setVelocityTo6"));
    m_setVelocityTo7Action->setObjectName(QStringLiteral("setVelocityTo7"));
    m_setVelocityTo8Action->setObjectName(QStringLiteral("setVelocityTo8"));
    m_setVelocityTo9Action->setObjectName(QStringLiteral("setVelocityTo9"));
    m_setVelocityTo10Action->setObjectName(QStringLiteral("setVelocityTo10"));

    // Set Global Hotkeys
    m_setShortcut(Qt::Key_F9, Qt::ControlModifier, TogglePrompter);
    m_setShortcut(Qt::Key_Down, Qt::ControlModifier, IncreaseVelocity);
    m_setShortcut(Qt::Key_Up, Qt::ControlModifier, DecreaseVelocity);
    m_setShortcut(Qt::Key_Space, Qt::ControlModifier, Pause);
    m_setShortcut(Qt::Key_Space, Qt::MetaModifier, Stop);
    m_setShortcut(Qt::Key_Backslash, Qt::ControlModifier, Reverse);
    m_setShortcut(Qt::Key_BracketLeft, Qt::ControlModifier, Rewind);
    m_setShortcut(Qt::Key_BracketRight, Qt::ControlModifier, FastForward);
    m_setShortcut(Qt::Key_PageUp, Qt::ControlModifier, SkipBackwards);
    m_setShortcut(Qt::Key_PageDown, Qt::ControlModifier, SkipForwards);
    m_setShortcut(Qt::Key_Comma, Qt::ControlModifier, PreviousMarker);
    m_setShortcut(Qt::Key_Period, Qt::ControlModifier, NextMarker);
    m_setShortcut(Qt::Key_0, Qt::AltModifier, VelocityToNeg10);
    m_setShortcut(Qt::Key_9, Qt::AltModifier, VelocityToNeg9);
    m_setShortcut(Qt::Key_8, Qt::AltModifier, VelocityToNeg8);
    m_setShortcut(Qt::Key_7, Qt::AltModifier, VelocityToNeg7);
    m_setShortcut(Qt::Key_6, Qt::AltModifier, VelocityToNeg6);
    m_setShortcut(Qt::Key_5, Qt::AltModifier, VelocityToNeg5);
    m_setShortcut(Qt::Key_4, Qt::AltModifier, VelocityToNeg4);
    m_setShortcut(Qt::Key_3, Qt::AltModifier, VelocityToNeg3);
    m_setShortcut(Qt::Key_2, Qt::AltModifier, VelocityToNeg2);
    m_setShortcut(Qt::Key_1, Qt::AltModifier, VelocityToNeg1);
    m_setShortcut(Qt::Key_acute, Qt::ControlModifier, VelocityTo0);
    m_setShortcut(Qt::Key_1, Qt::ControlModifier, VelocityTo1);
    m_setShortcut(Qt::Key_2, Qt::ControlModifier, VelocityTo2);
    m_setShortcut(Qt::Key_3, Qt::ControlModifier, VelocityTo3);
    m_setShortcut(Qt::Key_4, Qt::ControlModifier, VelocityTo4);
    m_setShortcut(Qt::Key_5, Qt::ControlModifier, VelocityTo5);
    m_setShortcut(Qt::Key_6, Qt::ControlModifier, VelocityTo6);
    m_setShortcut(Qt::Key_7, Qt::ControlModifier, VelocityTo7);
    m_setShortcut(Qt::Key_8, Qt::ControlModifier, VelocityTo8);
    m_setShortcut(Qt::Key_9, Qt::ControlModifier, VelocityTo9);
    m_setShortcut(Qt::Key_0, Qt::ControlModifier, VelocityTo10);

    // Holdability
    m_rewindAction->setCheckable(true);
    m_fastForwardAction->setCheckable(true);

    // Connections for toggle actions
    connect(m_rewindAction, &QAction::toggled, this, &AbstractInputSource::rewind);
    connect(m_fastForwardAction, &QAction::toggled, this, &AbstractInputSource::fastForward);
    // Connections for trigger actions
    connect(m_togglePrompterAction, &QAction::triggered, this, &AbstractInputSource::togglePrompter);
    connect(m_increaseVelocityAction, &QAction::triggered, this, &AbstractInputSource::increaseVelocity);
    connect(m_decreaseVelocityAction, &QAction::triggered, this, &AbstractInputSource::decreaseVelocity);
    connect(m_pauseAction, &QAction::triggered, this, &AbstractInputSource::pause);
    connect(m_stopAction, &QAction::triggered, this, &AbstractInputSource::stop);
    connect(m_reverseAction, &QAction::triggered, this, &AbstractInputSource::reverse);
    connect(m_skipBackwardsAction, &QAction::triggered, this, &AbstractInputSource::skipBackwards);
    connect(m_skipForwardsAction, &QAction::triggered, this, &AbstractInputSource::skipForwards);
    connect(m_previousMarkerAction, &QAction::triggered, this, &AbstractInputSource::previousMarker);
    connect(m_nextMarkerAction, &QAction::triggered, this, &AbstractInputSource::nextMarker);
    connect(m_setVelocityToNeg10Action, &QAction::triggered, [this] () {
        emit AbstractInputSource::setVelocity(-10);
    });
    connect(m_setVelocityToNeg9Action, &QAction::triggered, [this] () {
        emit AbstractInputSource::setVelocity(-9);
    });
    connect(m_setVelocityToNeg8Action, &QAction::triggered, [this] () {
        emit AbstractInputSource::setVelocity(-8);
    });
    connect(m_setVelocityToNeg7Action, &QAction::triggered, [this] () {
        emit AbstractInputSource::setVelocity(-7);
    });
    connect(m_setVelocityToNeg6Action, &QAction::triggered, [this] () {
        emit AbstractInputSource::setVelocity(-6);
    });
    connect(m_setVelocityToNeg5Action, &QAction::triggered, [this] () {
        emit AbstractInputSource::setVelocity(-5);
    });
    connect(m_setVelocityToNeg4Action, &QAction::triggered, [this] () {
        emit AbstractInputSource::setVelocity(-4);
    });
    connect(m_setVelocityToNeg3Action, &QAction::triggered, [this] () {
        emit AbstractInputSource::setVelocity(-3);
    });
    connect(m_setVelocityToNeg2Action, &QAction::triggered, [this] () {
        emit AbstractInputSource::setVelocity(-2);
    });
    connect(m_setVelocityToNeg1Action, &QAction::triggered, [this] () {
        emit AbstractInputSource::setVelocity(-1);
    });
    connect(m_setVelocityTo0Action, &QAction::triggered, [this] () {
        emit AbstractInputSource::setVelocity(0);
    });
    connect(m_setVelocityTo1Action, &QAction::triggered, [this] () {
        emit AbstractInputSource::setVelocity(1);
    });
    connect(m_setVelocityTo2Action, &QAction::triggered, [this] () {
        emit AbstractInputSource::setVelocity(2);
    });
    connect(m_setVelocityTo3Action, &QAction::triggered, [this] () {
        emit AbstractInputSource::setVelocity(3);
    });
    connect(m_setVelocityTo4Action, &QAction::triggered, [this] () {
        emit AbstractInputSource::setVelocity(4);
    });
    connect(m_setVelocityTo5Action, &QAction::triggered, [this] () {
        emit AbstractInputSource::setVelocity(5);
    });
    connect(m_setVelocityTo6Action, &QAction::triggered, [this] () {
        emit AbstractInputSource::setVelocity(6);
    });
    connect(m_setVelocityTo7Action, &QAction::triggered, [this] () {
        emit AbstractInputSource::setVelocity(7);
    });
    connect(m_setVelocityTo8Action, &QAction::triggered, [this] () {
        emit AbstractInputSource::setVelocity(8);
    });
    connect(m_setVelocityTo9Action, &QAction::triggered, [this] () {
        emit AbstractInputSource::setVelocity(9);
    });
    connect(m_setVelocityTo10Action, &QAction::triggered, [this] () {
        emit AbstractInputSource::setVelocity(10);
    });
#if defined(QHotkey_FOUND)
    connect(m_rewindHotkey, &QHotkey::activated, m_rewindAction, &QAction::toggle);
    connect(m_fastForwardHotkey, &QHotkey::activated, m_fastForwardAction, &QAction::toggle);
    connect(m_togglePrompterHotkey, &QHotkey::activated, m_togglePrompterAction, &QAction::trigger);
    connect(m_increaseVelocityHotkey, &QHotkey::activated, m_increaseVelocityAction, &QAction::trigger);
    connect(m_decreaseVelocityHotkey, &QHotkey::activated, m_decreaseVelocityAction, &QAction::trigger);
    connect(m_pauseHotkey, &QHotkey::activated, m_pauseAction, &QAction::trigger);
    connect(m_stopHotkey, &QHotkey::activated, m_stopAction, &QAction::trigger);
    connect(m_reverseHotkey, &QHotkey::activated, m_reverseAction, &QAction::trigger);
    connect(m_skipBackwardsHotkey, &QHotkey::activated, m_skipBackwardsAction, &QAction::trigger);
    connect(m_skipForwardsHotkey, &QHotkey::activated, m_skipForwardsAction, &QAction::trigger);
    connect(m_previousMarkerHotkey, &QHotkey::activated, m_previousMarkerAction, &QAction::trigger);
    connect(m_nextMarkerHotkey, &QHotkey::activated, m_nextMarkerAction, &QAction::trigger);
    connect(m_setVelocityToNeg10Hotkey, &QHotkey::activated, m_setVelocityToNeg10Action, &QAction::trigger);
    connect(m_setVelocityToNeg9Hotkey, &QHotkey::activated, m_setVelocityToNeg9Action, &QAction::trigger);
    connect(m_setVelocityToNeg8Hotkey, &QHotkey::activated, m_setVelocityToNeg8Action, &QAction::trigger);
    connect(m_setVelocityToNeg7Hotkey, &QHotkey::activated, m_setVelocityToNeg7Action, &QAction::trigger);
    connect(m_setVelocityToNeg6Hotkey, &QHotkey::activated, m_nextMarkerAction, &QAction::trigger);
    connect(m_setVelocityToNeg5Hotkey, &QHotkey::activated, m_nextMarkerAction, &QAction::trigger);
    connect(m_setVelocityToNeg4Hotkey, &QHotkey::activated, m_nextMarkerAction, &QAction::trigger);
    connect(m_setVelocityToNeg3Hotkey, &QHotkey::activated, m_nextMarkerAction, &QAction::trigger);
    connect(m_setVelocityToNeg2Hotkey, &QHotkey::activated, m_nextMarkerAction, &QAction::trigger);
    connect(m_setVelocityToNeg1Hotkey, &QHotkey::activated, m_nextMarkerAction, &QAction::trigger);
    connect(m_setVelocityTo0Hotkey, &QHotkey::activated, m_nextMarkerAction, &QAction::trigger);
    connect(m_setVelocityTo1Hotkey, &QHotkey::activated, m_nextMarkerAction, &QAction::trigger);
    connect(m_setVelocityTo2Hotkey, &QHotkey::activated, m_nextMarkerAction, &QAction::trigger);
    connect(m_setVelocityTo3Hotkey, &QHotkey::activated, m_nextMarkerAction, &QAction::trigger);
    connect(m_setVelocityTo4Hotkey, &QHotkey::activated, m_nextMarkerAction, &QAction::trigger);
    connect(m_setVelocityTo5Hotkey, &QHotkey::activated, m_nextMarkerAction, &QAction::trigger);
    connect(m_setVelocityTo6Hotkey, &QHotkey::activated, m_nextMarkerAction, &QAction::trigger);
    connect(m_setVelocityTo7Hotkey, &QHotkey::activated, m_nextMarkerAction, &QAction::trigger);
    connect(m_setVelocityTo8Hotkey, &QHotkey::activated, m_nextMarkerAction, &QAction::trigger);
    connect(m_setVelocityTo9Hotkey, &QHotkey::activated, m_nextMarkerAction, &QAction::trigger);
    connect(m_setVelocityTo10Hotkey, &QHotkey::activated, m_nextMarkerAction, &QAction::trigger);
#endif
    AbstractInputSource::m_initializeSource();
}

void GlobalHotkeys::m_setShortcut(Qt::Key key, Qt::KeyboardModifier modifier,  Action action) {
#if !defined(QHotkey_FOUND) && !defined(Use_GlobalAccel)
    Q_UNUSED(key)
    Q_UNUSED(modifier)
    Q_UNUSED(action)
    return;
#else
    switch (action) {
    case TogglePrompter:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifier, m_togglePrompterHotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifier, m_togglePrompterAction);
#endif
        return;
    case IncreaseVelocity:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifier, m_increaseVelocityHotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifier, m_increaseVelocityAction);
#endif
        return;
    case DecreaseVelocity:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifier, m_decreaseVelocityHotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifier, m_decreaseVelocityAction);
#endif
        return;
    case Pause:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifier, m_pauseHotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifier, m_pauseAction);
#endif
        return;
    case Stop:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifier, m_stopHotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifier, m_stopAction);
#endif
        return;
    case Reverse:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifier, m_reverseHotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifier, m_reverseAction);
#endif
        return;
    case Rewind:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifier, m_rewindHotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifier, m_rewindAction);
#endif
        return;
    case FastForward:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifier, m_fastForwardHotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifier, m_fastForwardAction);
#endif
        return;
    case SkipBackwards:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifier, m_skipBackwardsHotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifier, m_skipBackwardsAction);
#endif
        return;
    case SkipForwards:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifier, m_skipForwardsHotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifier, m_skipForwardsAction);
#endif
        return;
    case PreviousMarker:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifier, m_previousMarkerHotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifier, m_previousMarkerAction);
#endif
        return;
    case NextMarker:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifier, m_nextMarkerHotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifier, m_nextMarkerAction);
#endif
        return;
    case VelocityToNeg10:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifier, m_setVelocityToNeg10Hotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifier, m_setVelocityToNeg10Action);
#endif
        return;
    case VelocityToNeg9:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifier, m_setVelocityToNeg9Hotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifier, m_setVelocityToNeg9Action);
#endif
        return;
    case VelocityToNeg8:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifier, m_setVelocityToNeg8Hotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifier, m_setVelocityToNeg8Action);
#endif
        return;
    case VelocityToNeg7:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifier, m_setVelocityToNeg7Hotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifier, m_setVelocityToNeg7Action);
#endif
        return;
    case VelocityToNeg6:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifier, m_setVelocityToNeg6Hotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifier, m_setVelocityToNeg6Action);
#endif
        return;
    case VelocityToNeg5:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifier, m_setVelocityToNeg5Hotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifier, m_setVelocityToNeg5Action);
#endif
        return;
    case VelocityToNeg4:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifier, m_setVelocityToNeg4Hotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifier, m_setVelocityToNeg4Action);
#endif
        return;
    case VelocityToNeg3:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifier, m_setVelocityToNeg3Hotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifier, m_setVelocityToNeg3Action);
#endif
        return;
    case VelocityToNeg2:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifier, m_setVelocityToNeg2Hotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifier, m_setVelocityToNeg2Action);
#endif
        return;
    case VelocityToNeg1:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifier, m_setVelocityToNeg1Hotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifier, m_setVelocityToNeg1Action);
#endif
        return;
    case VelocityTo0:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifier, m_setVelocityTo0Hotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifier, m_setVelocityTo0Action);
#endif
        return;
    case VelocityTo1:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifier, m_setVelocityTo1Hotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifier, m_setVelocityTo1Action);
#endif
        return;
    case VelocityTo2:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifier, m_setVelocityTo2Hotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifier, m_setVelocityTo2Action);
#endif
        return;
    case VelocityTo3:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifier, m_setVelocityTo3Hotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifier, m_setVelocityTo3Action);
#endif
        return;
    case VelocityTo4:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifier, m_setVelocityTo4Hotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifier, m_setVelocityTo4Action);
#endif
        return;
    case VelocityTo5:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifier, m_setVelocityTo5Hotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifier, m_setVelocityTo5Action);
#endif
        return;
    case VelocityTo6:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifier, m_setVelocityTo6Hotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifier, m_setVelocityTo6Action);
#endif
        return;
    case VelocityTo7:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifier, m_setVelocityTo7Hotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifier, m_setVelocityTo7Action);
#endif
        return;
    case VelocityTo8:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifier, m_setVelocityTo8Hotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifier, m_setVelocityTo8Action);
#endif
        return;
    case VelocityTo9:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifier, m_setVelocityTo9Hotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifier, m_setVelocityTo9Action);
#endif
        return;
    case VelocityTo10:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifier, m_setVelocityTo10Hotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifier, m_setVelocityTo10Action);
#endif
        return;
    }
    Q_UNREACHABLE();
#endif
}

#if defined(QHotkey_FOUND)
void GlobalHotkeys::m_setHotkeyShortcut(Qt::Key key, Qt::KeyboardModifier modifier, QHotkey *hotkey) {
    hotkey->setShortcut(key, modifier, true);
}
#endif

#if defined(Use_GlobalAccel)
void GlobalHotkeys::m_setActionShortcut(Qt::Key key, Qt::KeyboardModifier modifier,  QAction *action) {
    QKeyCombination shortcut = key | modifier;
    KGlobalAccel::self()->setDefaultShortcut(action, QList<QKeySequence>() << shortcut);
    KGlobalAccel::self()->setShortcut(action, QList<QKeySequence>() << shortcut);
}
#endif

// #if defined(QHotkey_FOUND)
// void GlobalHotkeys::setShortcut(Qt::Key key, Qt::KeyboardModifier modifier,  QAction *action,  QHotkey *hotkey) {
// #else
// class QHotkey;
// void GlobalHotkeys::setShortcut(Qt::Key key, Qt::KeyboardModifier modifier,  QAction *action,  QHotkey *hotkey=nullptr) {
// #endif
//     QKeyCombination shortcut = key | modifier;
// #if defined(QHotkey_FOUND)
//     hotkey->setShortcut(shortcut, true);
// #else
//     Q_UNUSED(hotkey)
// #endif
// #if defined(Q_OS_UNIX) && !defined(Q_OS_APPLE) && !defined(Q_OS_ANDROID) && !defined(Q_OS_WASM)
//     KGlobalAccel::self()->setDefaultShortcut(action, QList<QKeySequence>() << shortcut);
//     KGlobalAccel::self()->setShortcut(action, QList<QKeySequence>() << shortcut);
// #endif
// }
