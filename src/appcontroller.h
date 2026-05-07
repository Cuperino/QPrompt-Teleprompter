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

#include "globalhotkeys.h"
#if defined(Q_OS_WASM)
#include "wasmintegration.h"
#endif

#include <QObject>
#include <QQmlEngine>

class AppController : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
#if defined(Q_OS_WASM)
    Q_PROPERTY(WasmIntegration *wasm READ wasm CONSTANT)
#endif
private:
    explicit AppController(QObject *parent = nullptr);
public:
    static AppController *create(QQmlEngine *qmlEngine, QJSEngine *);
    Q_INVOKABLE QString globalShortcutKey(GlobalHotkeys::Action action);
    Q_INVOKABLE void setGlobalShortcut(Qt::Key key, Qt::KeyboardModifiers modifiers, GlobalHotkeys::Action action);
#if defined(Q_OS_WASM)
    WasmIntegration *wasm() const;
#endif
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
#if defined(Q_OS_WASM)
    WasmIntegration *m_wasm;
#endif
};
