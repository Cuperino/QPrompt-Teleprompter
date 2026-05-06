/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2026 Javier O. Cordero Pérez
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

#include "globalhotkeys.h"

#include "appcontroller.h"

#if defined(Q_OS_UNIX) && !defined(Q_OS_APPLE) && !defined(Q_OS_ANDROID) && !defined(Q_OS_WASM)
// Used to provide global shortcuts in KDE Plasma
#include <KGlobalAccel>
#define Use_GlobalAccel = 1
#endif
#include <QCoreApplication>
#include <QSettings>

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

QString GlobalHotkeys::globalShortcutKey(Action action)
{
    QList<QKeySequence> shortcuts;
#if !defined(QHotkey_FOUND) && !defined(Use_GlobalAccel)
    Q_UNUSED(action)
    return "";
#else
    const QString platform = QGuiApplication::platformName();
    switch (action) {
    case TogglePrompter:
#ifdef QHotkey_FOUND
    if (platform != "wayland")
        return m_togglePrompterHotkey->shortcut().toString();
#endif
#ifdef Use_GlobalAccel
    shortcuts = KGlobalAccel::self()->shortcut(m_togglePrompterAction);
    if (shortcuts.isEmpty())
        return "";
    return shortcuts.constFirst().toString();
#endif
    break;
    case IncreaseVelocity:
#ifdef QHotkey_FOUND
    if (platform != "wayland")
        return m_increaseVelocityHotkey->shortcut().toString();
#endif
#ifdef Use_GlobalAccel
    shortcuts = KGlobalAccel::self()->shortcut(m_increaseVelocityAction);
    if (shortcuts.isEmpty())
        return "";
    return shortcuts.constFirst().toString();
#endif
    break;
    case DecreaseVelocity:
#ifdef QHotkey_FOUND
    if (platform != "wayland")
        return m_decreaseVelocityHotkey->shortcut().toString();
#endif
#ifdef Use_GlobalAccel
    shortcuts = KGlobalAccel::self()->shortcut(m_decreaseVelocityAction);
    if (shortcuts.isEmpty())
        return "";
    return shortcuts.constFirst().toString();
#endif
    break;
    case Pause:
#ifdef QHotkey_FOUND
    if (platform != "wayland")
        return m_pauseHotkey->shortcut().toString();
#endif
#ifdef Use_GlobalAccel
    shortcuts = KGlobalAccel::self()->shortcut(m_pauseAction);
    if (shortcuts.isEmpty())
        return "";
    return shortcuts.constFirst().toString();
#endif
    break;
    case Stop:
#ifdef QHotkey_FOUND
    if (platform != "wayland")
        return m_stopHotkey->shortcut().toString();
#endif
#ifdef Use_GlobalAccel
    shortcuts = KGlobalAccel::self()->shortcut(m_stopAction);
    if (shortcuts.isEmpty())
        return "";
    return shortcuts.constFirst().toString();
#endif
    break;
    case Reverse:
#ifdef QHotkey_FOUND
    if (platform != "wayland")
        return m_reverseHotkey->shortcut().toString();
#endif
#ifdef Use_GlobalAccel
    shortcuts = KGlobalAccel::self()->shortcut(m_reverseAction);
    if (shortcuts.isEmpty())
        return "";
    return shortcuts.constFirst().toString();
#endif
    break;
    case Rewind:
#ifdef QHotkey_FOUND
    if (platform != "wayland")
        return m_rewindHotkey->shortcut().toString();
#endif
#ifdef Use_GlobalAccel
    shortcuts = KGlobalAccel::self()->shortcut(m_rewindAction);
    if (shortcuts.isEmpty())
        return "";
    return shortcuts.constFirst().toString();
#endif
    break;
    case FastForward:
#ifdef QHotkey_FOUND
    if (platform != "wayland")
        return m_fastForwardHotkey->shortcut().toString();
#endif
#ifdef Use_GlobalAccel
    shortcuts = KGlobalAccel::self()->shortcut(m_fastForwardAction);
    if (shortcuts.isEmpty())
        return "";
    return shortcuts.constFirst().toString();
#endif
    break;
    case SkipBackwards:
#ifdef QHotkey_FOUND
    if (platform != "wayland")
        return m_skipBackwardsHotkey->shortcut().toString();
#endif
#ifdef Use_GlobalAccel
    shortcuts = KGlobalAccel::self()->shortcut(m_skipBackwardsAction);
    if (shortcuts.isEmpty())
        return "";
    return shortcuts.constFirst().toString();
#endif
    break;
    case SkipForwards:
#ifdef QHotkey_FOUND
    if (platform != "wayland")
        return m_skipForwardsHotkey->shortcut().toString();
#endif
#ifdef Use_GlobalAccel
    shortcuts = KGlobalAccel::self()->shortcut(m_skipForwardsAction);
    if (shortcuts.isEmpty())
        return "";
    return shortcuts.constFirst().toString();
#endif
    break;
    case PreviousMarker:
#ifdef QHotkey_FOUND
    if (platform != "wayland")
        return m_previousMarkerHotkey->shortcut().toString();
#endif
#ifdef Use_GlobalAccel
    shortcuts = KGlobalAccel::self()->shortcut(m_previousMarkerAction);
    if (shortcuts.isEmpty())
        return "";
    return shortcuts.constFirst().toString();
#endif
    break;
    case NextMarker:
#ifdef QHotkey_FOUND
    if (platform != "wayland")
        return m_nextMarkerHotkey->shortcut().toString();
#endif
#ifdef Use_GlobalAccel
    shortcuts = KGlobalAccel::self()->shortcut(m_nextMarkerAction);
    if (shortcuts.isEmpty())
        return "";
    return shortcuts.constFirst().toString();
#endif
    break;
    case VelocityToNeg10:
#ifdef QHotkey_FOUND
    if (platform != "wayland")
        return m_setVelocityToNeg10Hotkey->shortcut().toString();
#endif
#ifdef Use_GlobalAccel
    shortcuts = KGlobalAccel::self()->shortcut(m_setVelocityToNeg10Action);
    if (shortcuts.isEmpty())
        return "";
    return shortcuts.constFirst().toString();
#endif
    break;
    case VelocityToNeg9:
#ifdef QHotkey_FOUND
    if (platform != "wayland")
        return m_setVelocityToNeg9Hotkey->shortcut().toString();
#endif
#ifdef Use_GlobalAccel
    shortcuts = KGlobalAccel::self()->shortcut(m_setVelocityToNeg9Action);
    if (shortcuts.isEmpty())
        return "";
    return shortcuts.constFirst().toString();
#endif
    break;
    case VelocityToNeg8:
#ifdef QHotkey_FOUND
    if (platform != "wayland")
        return m_setVelocityToNeg8Hotkey->shortcut().toString();
#endif
#ifdef Use_GlobalAccel
    shortcuts = KGlobalAccel::self()->shortcut(m_setVelocityToNeg8Action);
    if (shortcuts.isEmpty())
        return "";
    return shortcuts.constFirst().toString();
#endif
    break;
    case VelocityToNeg7:
#ifdef QHotkey_FOUND
    if (platform != "wayland")
        return m_setVelocityToNeg7Hotkey->shortcut().toString();
#endif
#ifdef Use_GlobalAccel
    shortcuts = KGlobalAccel::self()->shortcut(m_setVelocityToNeg7Action);
    if (shortcuts.isEmpty())
        return "";
    return shortcuts.constFirst().toString();
#endif
    break;
    case VelocityToNeg6:
#ifdef QHotkey_FOUND
    if (platform != "wayland")
        return m_setVelocityToNeg6Hotkey->shortcut().toString();
#endif
#ifdef Use_GlobalAccel
    shortcuts = KGlobalAccel::self()->shortcut(m_setVelocityToNeg6Action);
    if (shortcuts.isEmpty())
        return "";
    return shortcuts.constFirst().toString();
#endif
    break;
    case VelocityToNeg5:
#ifdef QHotkey_FOUND
    if (platform != "wayland")
        return m_setVelocityToNeg5Hotkey->shortcut().toString();
#endif
#ifdef Use_GlobalAccel
    shortcuts = KGlobalAccel::self()->shortcut(m_setVelocityToNeg5Action);
    if (shortcuts.isEmpty())
        return "";
    return shortcuts.constFirst().toString();
#endif
    break;
    case VelocityToNeg4:
#ifdef QHotkey_FOUND
    if (platform != "wayland")
        return m_setVelocityToNeg4Hotkey->shortcut().toString();
#endif
#ifdef Use_GlobalAccel
    shortcuts = KGlobalAccel::self()->shortcut(m_setVelocityToNeg4Action);
    if (shortcuts.isEmpty())
        return "";
    return shortcuts.constFirst().toString();
#endif
    break;
    case VelocityToNeg3:
#ifdef QHotkey_FOUND
    if (platform != "wayland")
        return m_setVelocityToNeg3Hotkey->shortcut().toString();
#endif
#ifdef Use_GlobalAccel
    shortcuts = KGlobalAccel::self()->shortcut(m_setVelocityToNeg3Action);
    if (shortcuts.isEmpty())
        return "";
    return shortcuts.constFirst().toString();
#endif
    break;
    case VelocityToNeg2:
#ifdef QHotkey_FOUND
    if (platform != "wayland")
        return m_setVelocityToNeg2Hotkey->shortcut().toString();
#endif
#ifdef Use_GlobalAccel
    shortcuts = KGlobalAccel::self()->shortcut(m_setVelocityToNeg2Action);
    if (shortcuts.isEmpty())
        return "";
    return shortcuts.constFirst().toString();
#endif
    break;
    case VelocityToNeg1:
#ifdef QHotkey_FOUND
    if (platform != "wayland")
        return m_setVelocityToNeg1Hotkey->shortcut().toString();
#endif
#ifdef Use_GlobalAccel
    shortcuts = KGlobalAccel::self()->shortcut(m_setVelocityToNeg1Action);
    if (shortcuts.isEmpty())
        return "";
    return shortcuts.constFirst().toString();
#endif
    break;
    case VelocityTo0:
#ifdef QHotkey_FOUND
    if (platform != "wayland")
        return m_setVelocityTo0Hotkey->shortcut().toString();
#endif
#ifdef Use_GlobalAccel
    shortcuts = KGlobalAccel::self()->shortcut(m_setVelocityTo0Action);
    if (shortcuts.isEmpty())
        return "";
    return shortcuts.constFirst().toString();
#endif
    break;
    case VelocityTo1:
#ifdef QHotkey_FOUND
    if (platform != "wayland")
        return m_setVelocityTo1Hotkey->shortcut().toString();
#endif
#ifdef Use_GlobalAccel
    shortcuts = KGlobalAccel::self()->shortcut(m_setVelocityTo1Action);
    if (shortcuts.isEmpty())
        return "";
    return shortcuts.constFirst().toString();
#endif
    break;
    case VelocityTo2:
#ifdef QHotkey_FOUND
    if (platform != "wayland")
        return m_setVelocityTo2Hotkey->shortcut().toString();
#endif
#ifdef Use_GlobalAccel
    shortcuts = KGlobalAccel::self()->shortcut(m_setVelocityTo2Action);
    if (shortcuts.isEmpty())
        return "";
    return shortcuts.constFirst().toString();
#endif
    break;
    case VelocityTo3:
#ifdef QHotkey_FOUND
    if (platform != "wayland")
        return m_setVelocityTo3Hotkey->shortcut().toString();
#endif
#ifdef Use_GlobalAccel
    shortcuts = KGlobalAccel::self()->shortcut(m_setVelocityTo3Action);
    if (shortcuts.isEmpty())
        return "";
    return shortcuts.constFirst().toString();
#endif
    break;
    case VelocityTo4:
#ifdef QHotkey_FOUND
    if (platform != "wayland")
        return m_setVelocityTo4Hotkey->shortcut().toString();
#endif
#ifdef Use_GlobalAccel
    shortcuts = KGlobalAccel::self()->shortcut(m_setVelocityTo4Action);
    if (shortcuts.isEmpty())
        return "";
    return shortcuts.constFirst().toString();
#endif
    break;
    case VelocityTo5:
#ifdef QHotkey_FOUND
    if (platform != "wayland")
        return m_setVelocityTo5Hotkey->shortcut().toString();
#endif
#ifdef Use_GlobalAccel
    shortcuts = KGlobalAccel::self()->shortcut(m_setVelocityTo5Action);
    if (shortcuts.isEmpty())
        return "";
    return shortcuts.constFirst().toString();
#endif
    break;
    case VelocityTo6:
#ifdef QHotkey_FOUND
    if (platform != "wayland")
        return m_setVelocityTo6Hotkey->shortcut().toString();
#endif
#ifdef Use_GlobalAccel
    shortcuts = KGlobalAccel::self()->shortcut(m_setVelocityTo6Action);
    if (shortcuts.isEmpty())
        return "";
    return shortcuts.constFirst().toString();
#endif
    break;
    case VelocityTo7:
#ifdef QHotkey_FOUND
    if (platform != "wayland")
        return m_setVelocityTo7Hotkey->shortcut().toString();
#endif
#ifdef Use_GlobalAccel
    shortcuts = KGlobalAccel::self()->shortcut(m_setVelocityTo7Action);
    if (shortcuts.isEmpty())
        return "";
    return shortcuts.constFirst().toString();
#endif
    break;
    case VelocityTo8:
#ifdef QHotkey_FOUND
    if (platform != "wayland")
        return m_setVelocityTo8Hotkey->shortcut().toString();
#endif
#ifdef Use_GlobalAccel
    shortcuts = KGlobalAccel::self()->shortcut(m_setVelocityTo8Action);
    if (shortcuts.isEmpty())
        return "";
    return shortcuts.constFirst().toString();
#endif
    break;
    case VelocityTo9:
#ifdef QHotkey_FOUND
    if (platform != "wayland")
        return m_setVelocityTo9Hotkey->shortcut().toString();
#endif
#ifdef Use_GlobalAccel
    shortcuts = KGlobalAccel::self()->shortcut(m_setVelocityTo9Action);
    if (shortcuts.isEmpty())
        return "";
    return shortcuts.constFirst().toString();
#endif
    break;
    case VelocityTo10:
#ifdef QHotkey_FOUND
    if (platform != "wayland")
        return m_setVelocityTo10Hotkey->shortcut().toString();
#endif
#ifdef Use_GlobalAccel
    shortcuts = KGlobalAccel::self()->shortcut(m_setVelocityTo10Action);
    if (shortcuts.isEmpty())
        return "";
    return shortcuts.constFirst().toString();
#endif
    break;
    };
    Q_UNREACHABLE();
#endif
}

void GlobalHotkeys::setGlobalShortcut(Qt::Key key, Qt::KeyboardModifiers modifiers, Action action)
{
    m_setGlobalShortcut(key, modifiers, action);
}

void GlobalHotkeys::m_initializeSource() {
    // Readable name
    m_togglePrompterAction->setObjectName(QLatin1String("togglePrompter"));
    m_increaseVelocityAction->setObjectName(QLatin1String("increaseVelocity"));
    m_decreaseVelocityAction->setObjectName(QLatin1String("decreaseVelocity"));
    m_pauseAction->setObjectName(QLatin1String("pause"));
    m_stopAction->setObjectName(QLatin1String("stop"));
    m_reverseAction->setObjectName(QLatin1String("reverse"));
    m_rewindAction->setObjectName(QLatin1String("rewind"));
    m_fastForwardAction->setObjectName(QLatin1String("fastForward"));
    m_skipBackwardsAction->setObjectName(QLatin1String("skipBackwards"));
    m_skipForwardsAction->setObjectName(QLatin1String("skipForwards"));
    m_previousMarkerAction->setObjectName(QLatin1String("previousMarker"));
    m_nextMarkerAction->setObjectName(QLatin1String("nextMarker"));
    m_setVelocityToNeg10Action->setObjectName(QLatin1String("setVelocityToNeg10"));
    m_setVelocityToNeg9Action->setObjectName(QLatin1String("setVelocityToNeg9"));
    m_setVelocityToNeg8Action->setObjectName(QLatin1String("setVelocityToNeg8"));
    m_setVelocityToNeg7Action->setObjectName(QLatin1String("setVelocityToNeg7"));
    m_setVelocityToNeg6Action->setObjectName(QLatin1String("setVelocityToNeg6"));
    m_setVelocityToNeg5Action->setObjectName(QLatin1String("setVelocityToNeg5"));
    m_setVelocityToNeg4Action->setObjectName(QLatin1String("setVelocityToNeg4"));
    m_setVelocityToNeg3Action->setObjectName(QLatin1String("setVelocityToNeg3"));
    m_setVelocityToNeg2Action->setObjectName(QLatin1String("setVelocityToNeg2"));
    m_setVelocityToNeg1Action->setObjectName(QLatin1String("setVelocityToNeg1"));
    m_setVelocityTo0Action->setObjectName(QLatin1String("setVelocityTo0"));
    m_setVelocityTo1Action->setObjectName(QLatin1String("setVelocityTo1"));
    m_setVelocityTo2Action->setObjectName(QLatin1String("setVelocityTo2"));
    m_setVelocityTo3Action->setObjectName(QLatin1String("setVelocityTo3"));
    m_setVelocityTo4Action->setObjectName(QLatin1String("setVelocityTo4"));
    m_setVelocityTo5Action->setObjectName(QLatin1String("setVelocityTo5"));
    m_setVelocityTo6Action->setObjectName(QLatin1String("setVelocityTo6"));
    m_setVelocityTo7Action->setObjectName(QLatin1String("setVelocityTo7"));
    m_setVelocityTo8Action->setObjectName(QLatin1String("setVelocityTo8"));
    m_setVelocityTo9Action->setObjectName(QLatin1String("setVelocityTo9"));
    m_setVelocityTo10Action->setObjectName(QLatin1String("setVelocityTo10"));

    // Set Global Hotkeys
#if (defined(Q_OS_MACOS) or defined(Q_OS_IOS))
    QSettings settings(QCoreApplication::organizationDomain(), QCoreApplication::applicationName());
#else
    QSettings settings(QCoreApplication::organizationName(), QCoreApplication::applicationName().toLower());
#endif
    Qt::Key key;
    Qt::KeyboardModifier modifier;
    QMetaEnum metaEnum = QMetaEnum::fromType<GlobalHotkeys::Action>();

    key = static_cast<Qt::Key>(settings.value(QLatin1String("hotkey/key") + metaEnum.valueToKey(TogglePrompter), Qt::Key_F9).toInt());
    modifier = static_cast<Qt::KeyboardModifier>(settings.value(QLatin1String("hotkey/mod") + metaEnum.valueToKey(TogglePrompter), Qt::ControlModifier).toInt());
    m_setGlobalShortcut(key, modifier, TogglePrompter, true);

    key = static_cast<Qt::Key>(settings.value(QLatin1String("hotkey/key") + metaEnum.valueToKey(IncreaseVelocity), Qt::Key_Down).toInt());
    modifier = static_cast<Qt::KeyboardModifier>(settings.value(QLatin1String("hotkey/mod") + metaEnum.valueToKey(IncreaseVelocity), Qt::ControlModifier).toInt());
    m_setGlobalShortcut(key, modifier, IncreaseVelocity, true);

    key = static_cast<Qt::Key>(settings.value(QLatin1String("hotkey/key") + metaEnum.valueToKey(DecreaseVelocity), Qt::Key_Up).toInt());
    modifier = static_cast<Qt::KeyboardModifier>(settings.value(QLatin1String("hotkey/mod") + metaEnum.valueToKey(DecreaseVelocity), Qt::ControlModifier).toInt());
    m_setGlobalShortcut(key, modifier, DecreaseVelocity, true);

    key = static_cast<Qt::Key>(settings.value(QLatin1String("hotkey/key") + metaEnum.valueToKey(Pause), Qt::Key_Space).toInt());
    modifier = static_cast<Qt::KeyboardModifier>(settings.value(QLatin1String("hotkey/mod") + metaEnum.valueToKey(Pause), Qt::ControlModifier).toInt());
    m_setGlobalShortcut(key, modifier, Pause, true);

    key = static_cast<Qt::Key>(settings.value(QLatin1String("hotkey/key") + metaEnum.valueToKey(Stop), Qt::Key_Space).toInt());
    modifier = static_cast<Qt::KeyboardModifier>(settings.value(QLatin1String("hotkey/mod") + metaEnum.valueToKey(Stop), Qt::MetaModifier).toInt());
    m_setGlobalShortcut(key, modifier, Stop, true);

    key = static_cast<Qt::Key>(settings.value(QLatin1String("hotkey/key") + metaEnum.valueToKey(Reverse), Qt::Key_Backslash).toInt());
    modifier = static_cast<Qt::KeyboardModifier>(settings.value(QLatin1String("hotkey/mod") + metaEnum.valueToKey(Reverse), Qt::ControlModifier).toInt());
    m_setGlobalShortcut(key, modifier, Reverse, true);

    key = static_cast<Qt::Key>(settings.value(QLatin1String("hotkey/key") + metaEnum.valueToKey(Rewind), Qt::Key_BracketLeft).toInt());
    modifier = static_cast<Qt::KeyboardModifier>(settings.value(QLatin1String("hotkey/mod") + metaEnum.valueToKey(Rewind), Qt::ControlModifier).toInt());
    m_setGlobalShortcut(key, modifier, Rewind, true);

    key = static_cast<Qt::Key>(settings.value(QLatin1String("hotkey/key") + metaEnum.valueToKey(FastForward), Qt::Key_BracketRight).toInt());
    modifier = static_cast<Qt::KeyboardModifier>(settings.value(QLatin1String("hotkey/mod") + metaEnum.valueToKey(FastForward), Qt::ControlModifier).toInt());
    m_setGlobalShortcut(key, modifier, FastForward, true);

    key = static_cast<Qt::Key>(settings.value(QLatin1String("hotkey/key") + metaEnum.valueToKey(SkipBackwards), Qt::Key_PageUp).toInt());
    modifier = static_cast<Qt::KeyboardModifier>(settings.value(QLatin1String("hotkey/mod") + metaEnum.valueToKey(SkipBackwards), Qt::ControlModifier).toInt());
    m_setGlobalShortcut(key, modifier, SkipBackwards, true);

    key = static_cast<Qt::Key>(settings.value(QLatin1String("hotkey/key") + metaEnum.valueToKey(SkipForwards), Qt::Key_PageDown).toInt());
    modifier = static_cast<Qt::KeyboardModifier>(settings.value(QLatin1String("hotkey/mod") + metaEnum.valueToKey(SkipForwards), Qt::ControlModifier).toInt());
    m_setGlobalShortcut(key, modifier, SkipForwards, true);

    key = static_cast<Qt::Key>(settings.value(QLatin1String("hotkey/key") + metaEnum.valueToKey(PreviousMarker), Qt::Key_Comma).toInt());
    modifier = static_cast<Qt::KeyboardModifier>(settings.value(QLatin1String("hotkey/mod") + metaEnum.valueToKey(PreviousMarker), Qt::ControlModifier).toInt());
    m_setGlobalShortcut(key, modifier, PreviousMarker, true);

    key = static_cast<Qt::Key>(settings.value(QLatin1String("hotkey/key") + metaEnum.valueToKey(NextMarker), Qt::Key_Period).toInt());
    modifier = static_cast<Qt::KeyboardModifier>(settings.value(QLatin1String("hotkey/mod") + metaEnum.valueToKey(NextMarker), Qt::ControlModifier).toInt());
    m_setGlobalShortcut(key, modifier, NextMarker, true);

    key = static_cast<Qt::Key>(settings.value(QLatin1String("hotkey/key") + metaEnum.valueToKey(VelocityToNeg10), Qt::Key_0).toInt());
    modifier = static_cast<Qt::KeyboardModifier>(settings.value(QLatin1String("hotkey/mod") + metaEnum.valueToKey(VelocityToNeg10), Qt::AltModifier).toInt());
    m_setGlobalShortcut(key, modifier, VelocityToNeg10, true);

    key = static_cast<Qt::Key>(settings.value(QLatin1String("hotkey/key") + metaEnum.valueToKey(VelocityToNeg9), Qt::Key_9).toInt());
    modifier = static_cast<Qt::KeyboardModifier>(settings.value(QLatin1String("hotkey/mod") + metaEnum.valueToKey(VelocityToNeg9), Qt::AltModifier).toInt());
    m_setGlobalShortcut(key, modifier, VelocityToNeg9, true);

    key = static_cast<Qt::Key>(settings.value(QLatin1String("hotkey/key") + metaEnum.valueToKey(VelocityToNeg8), Qt::Key_8).toInt());
    modifier = static_cast<Qt::KeyboardModifier>(settings.value(QLatin1String("hotkey/mod") + metaEnum.valueToKey(VelocityToNeg8), Qt::AltModifier).toInt());
    m_setGlobalShortcut(key, modifier, VelocityToNeg8, true);

    key = static_cast<Qt::Key>(settings.value(QLatin1String("hotkey/key") + metaEnum.valueToKey(VelocityToNeg7), Qt::Key_7).toInt());
    modifier = static_cast<Qt::KeyboardModifier>(settings.value(QLatin1String("hotkey/mod") + metaEnum.valueToKey(VelocityToNeg7), Qt::AltModifier).toInt());
    m_setGlobalShortcut(key, modifier, VelocityToNeg7, true);

    key = static_cast<Qt::Key>(settings.value(QLatin1String("hotkey/key") + metaEnum.valueToKey(VelocityToNeg6), Qt::Key_6).toInt());
    modifier = static_cast<Qt::KeyboardModifier>(settings.value(QLatin1String("hotkey/mod") + metaEnum.valueToKey(VelocityToNeg6), Qt::AltModifier).toInt());
    m_setGlobalShortcut(key, modifier, VelocityToNeg6, true);

    key = static_cast<Qt::Key>(settings.value(QLatin1String("hotkey/key") + metaEnum.valueToKey(VelocityToNeg5), Qt::Key_5).toInt());
    modifier = static_cast<Qt::KeyboardModifier>(settings.value(QLatin1String("hotkey/mod") + metaEnum.valueToKey(VelocityToNeg5), Qt::AltModifier).toInt());
    m_setGlobalShortcut(key, modifier, VelocityToNeg5, true);

    key = static_cast<Qt::Key>(settings.value(QLatin1String("hotkey/key") + metaEnum.valueToKey(VelocityToNeg4), Qt::Key_4).toInt());
    modifier = static_cast<Qt::KeyboardModifier>(settings.value(QLatin1String("hotkey/mod") + metaEnum.valueToKey(VelocityToNeg4), Qt::AltModifier).toInt());
    m_setGlobalShortcut(key, modifier, VelocityToNeg4, true);

    key = static_cast<Qt::Key>(settings.value(QLatin1String("hotkey/key") + metaEnum.valueToKey(VelocityToNeg3), Qt::Key_3).toInt());
    modifier = static_cast<Qt::KeyboardModifier>(settings.value(QLatin1String("hotkey/mod") + metaEnum.valueToKey(VelocityToNeg3), Qt::AltModifier).toInt());
    m_setGlobalShortcut(key, modifier, VelocityToNeg3, true);

    key = static_cast<Qt::Key>(settings.value(QLatin1String("hotkey/key") + metaEnum.valueToKey(VelocityToNeg2), Qt::Key_2).toInt());
    modifier = static_cast<Qt::KeyboardModifier>(settings.value(QLatin1String("hotkey/mod") + metaEnum.valueToKey(VelocityToNeg2), Qt::AltModifier).toInt());
    m_setGlobalShortcut(key, modifier, VelocityToNeg2, true);

    key = static_cast<Qt::Key>(settings.value(QLatin1String("hotkey/key") + metaEnum.valueToKey(VelocityToNeg1), Qt::Key_1).toInt());
    modifier = static_cast<Qt::KeyboardModifier>(settings.value(QLatin1String("hotkey/mod") + metaEnum.valueToKey(VelocityToNeg1), Qt::AltModifier).toInt());
    m_setGlobalShortcut(key, modifier, VelocityToNeg1, true);

    key = static_cast<Qt::Key>(settings.value(QLatin1String("hotkey/key") + metaEnum.valueToKey(VelocityTo0), Qt::Key_acute).toInt());
    modifier = static_cast<Qt::KeyboardModifier>(settings.value(QLatin1String("hotkey/mod") + metaEnum.valueToKey(VelocityTo0), Qt::ControlModifier).toInt());
    m_setGlobalShortcut(key, modifier, VelocityTo0, true);

    key = static_cast<Qt::Key>(settings.value(QLatin1String("hotkey/key") + metaEnum.valueToKey(VelocityTo1), Qt::Key_1).toInt());
    modifier = static_cast<Qt::KeyboardModifier>(settings.value(QLatin1String("hotkey/mod") + metaEnum.valueToKey(VelocityTo1), Qt::ControlModifier).toInt());
    m_setGlobalShortcut(key, modifier, VelocityTo1, true);

    key = static_cast<Qt::Key>(settings.value(QLatin1String("hotkey/key") + metaEnum.valueToKey(VelocityTo2), Qt::Key_2).toInt());
    modifier = static_cast<Qt::KeyboardModifier>(settings.value(QLatin1String("hotkey/mod") + metaEnum.valueToKey(VelocityTo2), Qt::ControlModifier).toInt());
    m_setGlobalShortcut(key, modifier, VelocityTo2, true);

    key = static_cast<Qt::Key>(settings.value(QLatin1String("hotkey/key") + metaEnum.valueToKey(VelocityTo3), Qt::Key_3).toInt());
    modifier = static_cast<Qt::KeyboardModifier>(settings.value(QLatin1String("hotkey/mod") + metaEnum.valueToKey(VelocityTo3), Qt::ControlModifier).toInt());
    m_setGlobalShortcut(key, modifier, VelocityTo3, true);

    key = static_cast<Qt::Key>(settings.value(QLatin1String("hotkey/key") + metaEnum.valueToKey(VelocityTo4), Qt::Key_4).toInt());
    modifier = static_cast<Qt::KeyboardModifier>(settings.value(QLatin1String("hotkey/mod") + metaEnum.valueToKey(VelocityTo4), Qt::ControlModifier).toInt());
    m_setGlobalShortcut(key, modifier, VelocityTo4, true);

    key = static_cast<Qt::Key>(settings.value(QLatin1String("hotkey/key") + metaEnum.valueToKey(VelocityTo5), Qt::Key_5).toInt());
    modifier = static_cast<Qt::KeyboardModifier>(settings.value(QLatin1String("hotkey/mod") + metaEnum.valueToKey(VelocityTo5), Qt::ControlModifier).toInt());
    m_setGlobalShortcut(key, modifier, VelocityTo5, true);

    key = static_cast<Qt::Key>(settings.value(QLatin1String("hotkey/key") + metaEnum.valueToKey(VelocityTo6), Qt::Key_6).toInt());
    modifier = static_cast<Qt::KeyboardModifier>(settings.value(QLatin1String("hotkey/mod") + metaEnum.valueToKey(VelocityTo6), Qt::ControlModifier).toInt());
    m_setGlobalShortcut(key, modifier, VelocityTo6, true);

    key = static_cast<Qt::Key>(settings.value(QLatin1String("hotkey/key") + metaEnum.valueToKey(VelocityTo7), Qt::Key_7).toInt());
    modifier = static_cast<Qt::KeyboardModifier>(settings.value(QLatin1String("hotkey/mod") + metaEnum.valueToKey(VelocityTo7), Qt::ControlModifier).toInt());
    m_setGlobalShortcut(key, modifier, VelocityTo7, true);

    key = static_cast<Qt::Key>(settings.value(QLatin1String("hotkey/key") + metaEnum.valueToKey(VelocityTo8), Qt::Key_8).toInt());
    modifier = static_cast<Qt::KeyboardModifier>(settings.value(QLatin1String("hotkey/mod") + metaEnum.valueToKey(VelocityTo8), Qt::ControlModifier).toInt());
    m_setGlobalShortcut(key, modifier, VelocityTo8, true);

    key = static_cast<Qt::Key>(settings.value(QLatin1String("hotkey/key") + metaEnum.valueToKey(VelocityTo9), Qt::Key_9).toInt());
    modifier = static_cast<Qt::KeyboardModifier>(settings.value(QLatin1String("hotkey/mod") + metaEnum.valueToKey(VelocityTo9), Qt::ControlModifier).toInt());
    m_setGlobalShortcut(key, modifier, VelocityTo9, true);

    key = static_cast<Qt::Key>(settings.value(QLatin1String("hotkey/key") + metaEnum.valueToKey(VelocityTo10), Qt::Key_0).toInt());
    modifier = static_cast<Qt::KeyboardModifier>(settings.value(QLatin1String("hotkey/mod") + metaEnum.valueToKey(VelocityTo10), Qt::ControlModifier).toInt());
    m_setGlobalShortcut(key, modifier, VelocityTo10, true);

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
    connect(m_setVelocityToNeg6Hotkey, &QHotkey::activated, m_setVelocityToNeg6Action, &QAction::trigger);
    connect(m_setVelocityToNeg5Hotkey, &QHotkey::activated, m_setVelocityToNeg5Action, &QAction::trigger);
    connect(m_setVelocityToNeg4Hotkey, &QHotkey::activated, m_setVelocityToNeg4Action, &QAction::trigger);
    connect(m_setVelocityToNeg3Hotkey, &QHotkey::activated, m_setVelocityToNeg3Action, &QAction::trigger);
    connect(m_setVelocityToNeg2Hotkey, &QHotkey::activated, m_setVelocityToNeg2Action, &QAction::trigger);
    connect(m_setVelocityToNeg1Hotkey, &QHotkey::activated, m_setVelocityToNeg1Action, &QAction::trigger);
    connect(m_setVelocityTo0Hotkey, &QHotkey::activated, m_setVelocityTo0Action, &QAction::trigger);
    connect(m_setVelocityTo1Hotkey, &QHotkey::activated, m_setVelocityTo1Action, &QAction::trigger);
    connect(m_setVelocityTo2Hotkey, &QHotkey::activated, m_setVelocityTo2Action, &QAction::trigger);
    connect(m_setVelocityTo3Hotkey, &QHotkey::activated, m_setVelocityTo3Action, &QAction::trigger);
    connect(m_setVelocityTo4Hotkey, &QHotkey::activated, m_setVelocityTo4Action, &QAction::trigger);
    connect(m_setVelocityTo5Hotkey, &QHotkey::activated, m_setVelocityTo5Action, &QAction::trigger);
    connect(m_setVelocityTo6Hotkey, &QHotkey::activated, m_setVelocityTo6Action, &QAction::trigger);
    connect(m_setVelocityTo7Hotkey, &QHotkey::activated, m_setVelocityTo7Action, &QAction::trigger);
    connect(m_setVelocityTo8Hotkey, &QHotkey::activated, m_setVelocityTo8Action, &QAction::trigger);
    connect(m_setVelocityTo9Hotkey, &QHotkey::activated, m_setVelocityTo9Action, &QAction::trigger);
    connect(m_setVelocityTo10Hotkey, &QHotkey::activated, m_setVelocityTo10Action, &QAction::trigger);
#endif
    AbstractInputSource::m_initializeSource();
}

void GlobalHotkeys::m_setGlobalShortcut(Qt::Key key, Qt::KeyboardModifiers modifiers, Action action, bool setAsDefault) {
#if !defined(QHotkey_FOUND) && !defined(Use_GlobalAccel)
    Q_UNUSED(key)
    Q_UNUSED(modifiers)
    Q_UNUSED(action)
    return;
#else

#ifdef QHotkey_FOUND
    // Save QHotkey value
    if(!setAsDefault) {
#if (defined(Q_OS_MACOS) or defined(Q_OS_IOS))
        QSettings settings(QCoreApplication::organizationDomain(), QCoreApplication::applicationName());
#else
        QSettings settings(QCoreApplication::organizationName(), QCoreApplication::applicationName().toLower());
#endif
        QMetaEnum metaEnum = QMetaEnum::fromType<GlobalHotkeys::Action>();
        settings.setValue(QLatin1String("hotkey/key") + metaEnum.valueToKey(action), key);
        settings.setValue(QLatin1String("hotkey/mod") + metaEnum.valueToKey(action), modifiers.toInt());
    }
#endif

    switch (action) {
    case TogglePrompter:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifiers, m_togglePrompterHotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifiers, m_togglePrompterAction, setAsDefault);
#endif
        return;
    case IncreaseVelocity:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifiers, m_increaseVelocityHotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifiers, m_increaseVelocityAction, setAsDefault);
#endif
        return;
    case DecreaseVelocity:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifiers, m_decreaseVelocityHotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifiers, m_decreaseVelocityAction, setAsDefault);
#endif
        return;
    case Pause:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifiers, m_pauseHotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifiers, m_pauseAction, setAsDefault);
#endif
        return;
    case Stop:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifiers, m_stopHotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifiers, m_stopAction, setAsDefault);
#endif
        return;
    case Reverse:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifiers, m_reverseHotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifiers, m_reverseAction, setAsDefault);
#endif
        return;
    case Rewind:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifiers, m_rewindHotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifiers, m_rewindAction, setAsDefault);
#endif
        return;
    case FastForward:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifiers, m_fastForwardHotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifiers, m_fastForwardAction, setAsDefault);
#endif
        return;
    case SkipBackwards:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifiers, m_skipBackwardsHotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifiers, m_skipBackwardsAction, setAsDefault);
#endif
        return;
    case SkipForwards:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifiers, m_skipForwardsHotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifiers, m_skipForwardsAction, setAsDefault);
#endif
        return;
    case PreviousMarker:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifiers, m_previousMarkerHotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifiers, m_previousMarkerAction, setAsDefault);
#endif
        return;
    case NextMarker:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifiers, m_nextMarkerHotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifiers, m_nextMarkerAction, setAsDefault);
#endif
        return;
    case VelocityToNeg10:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifiers, m_setVelocityToNeg10Hotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifiers, m_setVelocityToNeg10Action, setAsDefault);
#endif
        return;
    case VelocityToNeg9:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifiers, m_setVelocityToNeg9Hotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifiers, m_setVelocityToNeg9Action, setAsDefault);
#endif
        return;
    case VelocityToNeg8:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifiers, m_setVelocityToNeg8Hotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifiers, m_setVelocityToNeg8Action, setAsDefault);
#endif
        return;
    case VelocityToNeg7:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifiers, m_setVelocityToNeg7Hotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifiers, m_setVelocityToNeg7Action, setAsDefault);
#endif
        return;
    case VelocityToNeg6:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifiers, m_setVelocityToNeg6Hotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifiers, m_setVelocityToNeg6Action, setAsDefault);
#endif
        return;
    case VelocityToNeg5:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifiers, m_setVelocityToNeg5Hotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifiers, m_setVelocityToNeg5Action, setAsDefault);
#endif
        return;
    case VelocityToNeg4:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifiers, m_setVelocityToNeg4Hotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifiers, m_setVelocityToNeg4Action, setAsDefault);
#endif
        return;
    case VelocityToNeg3:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifiers, m_setVelocityToNeg3Hotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifiers, m_setVelocityToNeg3Action, setAsDefault);
#endif
        return;
    case VelocityToNeg2:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifiers, m_setVelocityToNeg2Hotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifiers, m_setVelocityToNeg2Action, setAsDefault);
#endif
        return;
    case VelocityToNeg1:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifiers, m_setVelocityToNeg1Hotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifiers, m_setVelocityToNeg1Action, setAsDefault);
#endif
        return;
    case VelocityTo0:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifiers, m_setVelocityTo0Hotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifiers, m_setVelocityTo0Action, setAsDefault);
#endif
        return;
    case VelocityTo1:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifiers, m_setVelocityTo1Hotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifiers, m_setVelocityTo1Action, setAsDefault);
#endif
        return;
    case VelocityTo2:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifiers, m_setVelocityTo2Hotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifiers, m_setVelocityTo2Action, setAsDefault);
#endif
        return;
    case VelocityTo3:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifiers, m_setVelocityTo3Hotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifiers, m_setVelocityTo3Action, setAsDefault);
#endif
        return;
    case VelocityTo4:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifiers, m_setVelocityTo4Hotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifiers, m_setVelocityTo4Action, setAsDefault);
#endif
        return;
    case VelocityTo5:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifiers, m_setVelocityTo5Hotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifiers, m_setVelocityTo5Action, setAsDefault);
#endif
        return;
    case VelocityTo6:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifiers, m_setVelocityTo6Hotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifiers, m_setVelocityTo6Action, setAsDefault);
#endif
        return;
    case VelocityTo7:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifiers, m_setVelocityTo7Hotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifiers, m_setVelocityTo7Action, setAsDefault);
#endif
        return;
    case VelocityTo8:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifiers, m_setVelocityTo8Hotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifiers, m_setVelocityTo8Action, setAsDefault);
#endif
        return;
    case VelocityTo9:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifiers, m_setVelocityTo9Hotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifiers, m_setVelocityTo9Action, setAsDefault);
#endif
        return;
    case VelocityTo10:
#ifdef QHotkey_FOUND
        m_setHotkeyShortcut(key, modifiers, m_setVelocityTo10Hotkey);
#endif
#ifdef Use_GlobalAccel
        m_setActionShortcut(key, modifiers, m_setVelocityTo10Action, setAsDefault);
#endif
        return;
    }
    Q_UNREACHABLE();
#endif
}

// Set for QHotkey
#if defined(QHotkey_FOUND)
void GlobalHotkeys::m_setHotkeyShortcut(Qt::Key key, Qt::KeyboardModifiers modifiers, QHotkey *hotkey) {
    hotkey->setShortcut(key, modifiers, true);
}
#endif

// Set for GlobalAccel
#if defined(Use_GlobalAccel)
void GlobalHotkeys::m_setActionShortcut(Qt::Key key, Qt::KeyboardModifiers modifiers, QAction *action, bool setAsDefault) {
#ifdef QHotkey_FOUND
    if (QGuiApplication::platformName() != "wayland") {
        key = Qt::Key_unknown;
        modifiers = Qt::NoModifier;
    }
#endif
    QKeyCombination shortcut = key | modifiers;
    KGlobalAccel::self()->removeAllShortcuts(action);
    if(setAsDefault) {
        KGlobalAccel::self()->setDefaultShortcut(action, QList<QKeySequence>() << shortcut);
        shortcut = Qt::Key_unknown | Qt::NoModifier;
        KGlobalAccel::self()->setShortcut(action, QList<QKeySequence>() << shortcut);
    }
    else {
        // Preserve default shortcut and update the rest
        const auto defaultShortcut = KGlobalAccel::self()->defaultShortcut(action);
        KGlobalAccel::self()->removeAllShortcuts(action);
        KGlobalAccel::self()->setDefaultShortcut(action, QList<QKeySequence>() << defaultShortcut);
        KGlobalAccel::self()->setShortcut(action, QList<QKeySequence>() << shortcut);
    }
}
#endif
