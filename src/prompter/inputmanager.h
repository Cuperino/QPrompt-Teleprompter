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

#ifndef INPUTMANAGER_H
#define INPUTMANAGER_H

// #include <QKeyCombination>
#include <QObject>

// Classes for QPrompt to be controlled via keyboard, network, gamepad, and other inputs

enum class ProgramAction {
    // Prompter status actions
    TOGGLE_PROMPTER,
    START_PROMPTER,
    STOP_PROMPTER,
    // Prompter animations
    TOGGLE_PLAYBACK,
    PLAY,
    PAUSE,
    STOP,
    INCREASE_VELOCITY,
    DECREASE_VELOCITY,
    // Document updates
    RELOAD_CONTENT,
    APPEND_CONTENT,
    // Font controls
    SET_FONT_SIZE
};

template<typename ActionInput>
class AbstractInputSource
{
public:
    explicit AbstractInputSource() = default;
    explicit AbstractInputSource(const AbstractInputSource &ref) = delete;
    virtual ~AbstractInputSource() = default;

    virtual void setAction(ProgramAction action, ActionInput input) = 0;
    Q_INVOKABLE void clearAction(const ProgramAction &action)
    {
        m_actions[action] = m_defaultActions[action];
        emit actionInputChanged();
    };
    virtual void emitAction(ProgramAction action) = 0;

signals:
    ProgramAction actionInputChanged();
    ProgramAction actionEmmitted();

protected:
    typedef std::map<ProgramAction, ActionInput> Actions;
    const Actions m_defaultActions;
    Actions m_actions;
};

// Keyboard Input
class KeyboardInput : public QObject, public AbstractInputSource<Qt::Key>
{
    // Q_OBJECT
public:
    explicit KeyboardInput(QObject *parent = nullptr);
    explicit KeyboardInput(const KeyboardInput &);
    ~KeyboardInput() = default;

    // Keyboard Global Hotkeys
    Q_INVOKABLE void setAction(ProgramAction action, Qt::Key input) override;
    Q_INVOKABLE void emitAction(ProgramAction action) override;

signals:

private:
};

// Joypad Input
class JoypadInput : public QObject, public AbstractInputSource<uint_fast8_t>
{
public:
    explicit JoypadInput(QObject *parent = nullptr);
    explicit JoypadInput(const JoypadInput &);
    ~JoypadInput() = default;

    // Keyboard Global Hotkeys
    Q_INVOKABLE void setAction(ProgramAction action, uint_fast8_t input) override;
    Q_INVOKABLE void emitAction(ProgramAction action) override;

signals:

private:
};

// We DECLARE_METATYPE instead of specidying Q_OBJECT on child classes
// because the parent class is templated
Q_DECLARE_METATYPE(KeyboardInput);
Q_DECLARE_METATYPE(JoypadInput);

#endif // INPUTMANAGER_H
