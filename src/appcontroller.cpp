#include "appcontroller.h"

#if defined(Q_OS_UNIX) && !defined(Q_OS_APPLE) && !defined(Q_OS_ANDROID) && !defined(Q_OS_WASM)
#include <KGlobalAccel>
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

void AbstractInputSource::initializeSource()
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
    // Holdability
    m_rewindAction->setCheckable(true);
    m_fastForwardAction->setCheckable(true);
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
    // Connections
    connect(m_rewindAction, &QAction::toggled, this, &AbstractInputSource::rewind);
    connect(m_fastForwardAction, &QAction::toggled, this, &AbstractInputSource::fastForward);
    // Connections
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
    // Setup input
    initializeSource();
}

void GlobalHotkeys::initializeSource() {
    AbstractInputSource::initializeSource();
#if defined(Q_OS_UNIX) && !defined(Q_OS_APPLE) && !defined(Q_OS_ANDROID) && !defined(Q_OS_WASM)
    // togglePrompter
    KGlobalAccel::self()->setDefaultShortcut(m_togglePrompterAction, QList<QKeySequence>() << (Qt::Key_F9 | Qt::ControlModifier));
    KGlobalAccel::self()->setShortcut(m_togglePrompterAction, QList<QKeySequence>() << (Qt::Key_F9 | Qt::ControlModifier));
    // increaseVelocity
    KGlobalAccel::self()->setDefaultShortcut(m_increaseVelocityAction, QList<QKeySequence>() << (Qt::Key_Down | Qt::ControlModifier));
    KGlobalAccel::self()->setShortcut(m_increaseVelocityAction, QList<QKeySequence>() << (Qt::Key_Down | Qt::ControlModifier));
    // decreaseVelocity
    KGlobalAccel::self()->setDefaultShortcut(m_decreaseVelocityAction, QList<QKeySequence>() << (Qt::Key_Up | Qt::ControlModifier));
    KGlobalAccel::self()->setShortcut(m_decreaseVelocityAction, QList<QKeySequence>() << (Qt::Key_Up | Qt::ControlModifier));
    // pause
    KGlobalAccel::self()->setDefaultShortcut(m_pauseAction, QList<QKeySequence>() << (Qt::Key_Space | Qt::ControlModifier));
    KGlobalAccel::self()->setShortcut(m_pauseAction, QList<QKeySequence>() << (Qt::Key_Space | Qt::ControlModifier));
    // stop
    KGlobalAccel::self()->setDefaultShortcut(m_stopAction, QList<QKeySequence>() << (Qt::Key_Space | Qt::MetaModifier));
    KGlobalAccel::self()->setShortcut(m_stopAction, QList<QKeySequence>() << (Qt::Key_Space | Qt::MetaModifier));
    // reverse
    KGlobalAccel::self()->setDefaultShortcut(m_reverseAction, QList<QKeySequence>() << (Qt::Key_Backslash | Qt::ControlModifier));
    KGlobalAccel::self()->setShortcut(m_reverseAction, QList<QKeySequence>() << (Qt::Key_Backslash | Qt::ControlModifier));
    // rewind
    KGlobalAccel::self()->setDefaultShortcut(m_rewindAction, QList<QKeySequence>() << (Qt::Key_BracketLeft | Qt::ControlModifier));
    KGlobalAccel::self()->setShortcut(m_rewindAction, QList<QKeySequence>() << (Qt::Key_BracketLeft | Qt::ControlModifier));
    // fastForward
    KGlobalAccel::self()->setDefaultShortcut(m_fastForwardAction, QList<QKeySequence>() << (Qt::Key_BracketRight | Qt::ControlModifier));
    KGlobalAccel::self()->setShortcut(m_fastForwardAction, QList<QKeySequence>() << (Qt::Key_BracketRight | Qt::ControlModifier));
    // skipBackwards
    KGlobalAccel::self()->setDefaultShortcut(m_skipBackwardsAction, QList<QKeySequence>() << (Qt::Key_PageUp | Qt::ControlModifier));
    KGlobalAccel::self()->setShortcut(m_skipBackwardsAction, QList<QKeySequence>() << (Qt::Key_PageUp | Qt::ControlModifier));
    // skipForwards
    KGlobalAccel::self()->setDefaultShortcut(m_skipForwardsAction, QList<QKeySequence>() << (Qt::Key_PageDown | Qt::ControlModifier));
    KGlobalAccel::self()->setShortcut(m_skipForwardsAction, QList<QKeySequence>() << (Qt::Key_PageDown | Qt::ControlModifier));
    // previousMarker
    KGlobalAccel::self()->setDefaultShortcut(m_previousMarkerAction, QList<QKeySequence>() << (Qt::Key_Comma | Qt::ControlModifier));
    KGlobalAccel::self()->setShortcut(m_previousMarkerAction, QList<QKeySequence>() << (Qt::Key_Comma | Qt::ControlModifier));
    // nextMarker
    KGlobalAccel::self()->setDefaultShortcut(m_nextMarkerAction, QList<QKeySequence>() << (Qt::Key_Period | Qt::ControlModifier));
    KGlobalAccel::self()->setShortcut(m_nextMarkerAction, QList<QKeySequence>() << (Qt::Key_Period | Qt::ControlModifier));
    // setVelocity
    KGlobalAccel::self()->setDefaultShortcut(m_setVelocityToNeg10Action, QList<QKeySequence>() << (Qt::Key_0 | Qt::AltModifier));
    KGlobalAccel::self()->setShortcut(m_setVelocityToNeg10Action, QList<QKeySequence>() << (Qt::Key_0 | Qt::AltModifier));
    KGlobalAccel::self()->setDefaultShortcut(m_setVelocityToNeg9Action, QList<QKeySequence>() << (Qt::Key_9 | Qt::AltModifier));
    KGlobalAccel::self()->setShortcut(m_setVelocityToNeg9Action, QList<QKeySequence>() << (Qt::Key_9 | Qt::AltModifier));
    KGlobalAccel::self()->setDefaultShortcut(m_setVelocityToNeg8Action, QList<QKeySequence>() << (Qt::Key_8 | Qt::AltModifier));
    KGlobalAccel::self()->setShortcut(m_setVelocityToNeg8Action, QList<QKeySequence>() << (Qt::Key_8 | Qt::AltModifier));
    KGlobalAccel::self()->setDefaultShortcut(m_setVelocityToNeg7Action, QList<QKeySequence>() << (Qt::Key_7 | Qt::AltModifier));
    KGlobalAccel::self()->setShortcut(m_setVelocityToNeg7Action, QList<QKeySequence>() << (Qt::Key_7 | Qt::AltModifier));
    KGlobalAccel::self()->setDefaultShortcut(m_setVelocityToNeg6Action, QList<QKeySequence>() << (Qt::Key_6 | Qt::AltModifier));
    KGlobalAccel::self()->setShortcut(m_setVelocityToNeg6Action, QList<QKeySequence>() << (Qt::Key_6 | Qt::AltModifier));
    KGlobalAccel::self()->setDefaultShortcut(m_setVelocityToNeg5Action, QList<QKeySequence>() << (Qt::Key_5 | Qt::AltModifier));
    KGlobalAccel::self()->setShortcut(m_setVelocityToNeg5Action, QList<QKeySequence>() << (Qt::Key_5 | Qt::AltModifier));
    KGlobalAccel::self()->setDefaultShortcut(m_setVelocityToNeg4Action, QList<QKeySequence>() << (Qt::Key_4 | Qt::AltModifier));
    KGlobalAccel::self()->setShortcut(m_setVelocityToNeg4Action, QList<QKeySequence>() << (Qt::Key_4 | Qt::AltModifier));
    KGlobalAccel::self()->setDefaultShortcut(m_setVelocityToNeg3Action, QList<QKeySequence>() << (Qt::Key_3 | Qt::ControlModifier));
    KGlobalAccel::self()->setShortcut(m_setVelocityToNeg3Action, QList<QKeySequence>() << (Qt::Key_3 | Qt::AltModifier));
    KGlobalAccel::self()->setDefaultShortcut(m_setVelocityToNeg2Action, QList<QKeySequence>() << (Qt::Key_2 | Qt::AltModifier));
    KGlobalAccel::self()->setShortcut(m_setVelocityToNeg2Action, QList<QKeySequence>() << (Qt::Key_2 | Qt::AltModifier));
    KGlobalAccel::self()->setDefaultShortcut(m_setVelocityToNeg1Action, QList<QKeySequence>() << (Qt::Key_1 | Qt::AltModifier));
    KGlobalAccel::self()->setShortcut(m_setVelocityToNeg1Action, QList<QKeySequence>() << (Qt::Key_1 | Qt::AltModifier));
    KGlobalAccel::self()->setDefaultShortcut(m_setVelocityTo0Action, QList<QKeySequence>() << (Qt::Key_acute | Qt::ControlModifier));
    KGlobalAccel::self()->setShortcut(m_setVelocityTo0Action, QList<QKeySequence>() << (Qt::Key_acute | Qt::ControlModifier));
    KGlobalAccel::self()->setDefaultShortcut(m_setVelocityTo1Action, QList<QKeySequence>() << (Qt::Key_1 | Qt::ControlModifier));
    KGlobalAccel::self()->setShortcut(m_setVelocityTo1Action, QList<QKeySequence>() << (Qt::Key_1 | Qt::ControlModifier));
    KGlobalAccel::self()->setDefaultShortcut(m_setVelocityTo2Action, QList<QKeySequence>() << (Qt::Key_2 | Qt::ControlModifier));
    KGlobalAccel::self()->setShortcut(m_setVelocityTo2Action, QList<QKeySequence>() << (Qt::Key_2 | Qt::ControlModifier));
    KGlobalAccel::self()->setDefaultShortcut(m_setVelocityTo3Action, QList<QKeySequence>() << (Qt::Key_3 | Qt::ControlModifier));
    KGlobalAccel::self()->setShortcut(m_setVelocityTo3Action, QList<QKeySequence>() << (Qt::Key_3 | Qt::ControlModifier));
    KGlobalAccel::self()->setDefaultShortcut(m_setVelocityTo4Action, QList<QKeySequence>() << (Qt::Key_4 | Qt::ControlModifier));
    KGlobalAccel::self()->setShortcut(m_setVelocityTo4Action, QList<QKeySequence>() << (Qt::Key_4 | Qt::ControlModifier));
    KGlobalAccel::self()->setDefaultShortcut(m_setVelocityTo5Action, QList<QKeySequence>() << (Qt::Key_5 | Qt::ControlModifier));
    KGlobalAccel::self()->setShortcut(m_setVelocityTo5Action, QList<QKeySequence>() << (Qt::Key_5 | Qt::ControlModifier));
    KGlobalAccel::self()->setDefaultShortcut(m_setVelocityTo6Action, QList<QKeySequence>() << (Qt::Key_6 | Qt::ControlModifier));
    KGlobalAccel::self()->setShortcut(m_setVelocityTo6Action, QList<QKeySequence>() << (Qt::Key_6 | Qt::ControlModifier));
    KGlobalAccel::self()->setDefaultShortcut(m_setVelocityTo7Action, QList<QKeySequence>() << (Qt::Key_7 | Qt::ControlModifier));
    KGlobalAccel::self()->setShortcut(m_setVelocityTo7Action, QList<QKeySequence>() << (Qt::Key_7 | Qt::ControlModifier));
    KGlobalAccel::self()->setDefaultShortcut(m_setVelocityTo8Action, QList<QKeySequence>() << (Qt::Key_8 | Qt::ControlModifier));
    KGlobalAccel::self()->setShortcut(m_setVelocityTo8Action, QList<QKeySequence>() << (Qt::Key_8 | Qt::ControlModifier));
    KGlobalAccel::self()->setDefaultShortcut(m_setVelocityTo9Action, QList<QKeySequence>() << (Qt::Key_9 | Qt::ControlModifier));
    KGlobalAccel::self()->setShortcut(m_setVelocityTo9Action, QList<QKeySequence>() << (Qt::Key_9 | Qt::ControlModifier));
    KGlobalAccel::self()->setDefaultShortcut(m_setVelocityTo10Action, QList<QKeySequence>() << (Qt::Key_0 | Qt::ControlModifier));
    KGlobalAccel::self()->setShortcut(m_setVelocityTo10Action, QList<QKeySequence>() << (Qt::Key_0 | Qt::ControlModifier));
#endif
    return 0;
}
