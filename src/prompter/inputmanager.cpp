/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2023 Javier O. Cordero Pérez
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

#include "inputmanager.h"

// Keyboard methods
KeyboardInput::KeyboardInput(QObject *parent)
    : QObject{parent}
{
    m_actions = {{ProgramAction::TOGGLE_PROMPTER, Qt::Key_F9},
                 {ProgramAction::STOP_PROMPTER, Qt::Key_Escape},
                 {ProgramAction::TOGGLE_PLAYBACK, Qt::Key_Space},
                 {ProgramAction::INCREASE_VELOCITY, Qt::Key_Down},
                 {ProgramAction::DECREASE_VELOCITY, Qt::Key_Up}};
}

KeyboardInput::KeyboardInput(const KeyboardInput &ref)
    : QObject{ref.parent()}
{
    m_actions = ref.m_actions;
}

void KeyboardInput::setAction(ProgramAction action, Qt::Key input)
{
    Q_UNUSED(input);
    Q_UNUSED(action);
}

void KeyboardInput::emitAction(ProgramAction action)
{
    Q_UNUSED(action);
}

// Joypad methods
JoypadInput::JoypadInput(QObject *parent)
    : QObject{parent}
{
    m_actions = {{ProgramAction::TOGGLE_PROMPTER, 12},
                 {ProgramAction::STOP_PROMPTER, 11},
                 {ProgramAction::TOGGLE_PLAYBACK, 1},
                 {ProgramAction::STOP, 2},
                 {ProgramAction::PLAY, 3},
                 {ProgramAction::PAUSE, 4},
                 {ProgramAction::INCREASE_VELOCITY, 9},
                 {ProgramAction::DECREASE_VELOCITY, 10}};
}

JoypadInput::JoypadInput(const JoypadInput &ref)
    : QObject{ref.parent()}
{
    m_actions = ref.m_actions;
}

void JoypadInput::setAction(ProgramAction action, uint_fast8_t input)
{
    Q_UNUSED(input);
    Q_UNUSED(action);
}

void JoypadInput::emitAction(ProgramAction action)
{
    Q_UNUSED(action);
}
