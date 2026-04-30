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

#pragma once

#include "abstractinputsource.h"

#include <QQmlEngine>
#include <QAction>
#if defined(QHotkey_FOUND)
#include <QHotkey>
#endif

class AppController;

class GlobalHotkeys : public AbstractInputSource
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("GlobalHotkeys are only to be interfaced with through the AppController")
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
public:
    QString globalShortcutKey(GlobalHotkeys::Action action);
    void setGlobalShortcut(Qt::Key key, Qt::KeyboardModifiers modifiers, Action action);
protected:
    void m_initializeSource() override;
private:
    void m_setGlobalShortcut(Qt::Key key, Qt::KeyboardModifiers modifiers, Action action, bool setAsDefault=false);
    void m_setActionShortcut(Qt::Key key, Qt::KeyboardModifiers modifiers, QAction *action, bool setAsDefault);
#if defined(QHotkey_FOUND)
    void m_setHotkeyShortcut(Qt::Key key, Qt::KeyboardModifiers modifiers, QHotkey *hotkey);
#endif
};
