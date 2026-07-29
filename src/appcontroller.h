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

#if defined(QPROMPT_MOS_ENABLED)
class MosInputSource;
Q_MOC_INCLUDE("mosinputsource.h")
#endif

class AppController : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
#if defined(Q_OS_WASM)
    Q_PROPERTY(WasmIntegration *wasm READ wasm CONSTANT)
#endif
#if defined(QPROMPT_MOS_ENABLED)
    Q_PROPERTY(MosInputSource *mos READ mos CONSTANT)
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
#if defined(QPROMPT_MOS_ENABLED)
    MosInputSource *mos() const;
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
    // Absolute controls for external systems (e.g. MOS roCtrl): enter
    // standby, start or resume prompting, and surface an operator cue.
    void readyPrompter();
    void startPrompter();
    void pausePrompter();
    void signalCue(QString description);
    // Emitted by the prompter (QML calls this signal directly) when the read
    // line crosses a marker; input sources such as MOS listen to report cues.
    void markerPassed(int index, QString name);
private:
    GlobalHotkeys *m_hotkeys;
#if defined(QPROMPT_MOS_ENABLED)
    MosInputSource *m_mos;
#endif
#if defined(Q_OS_WASM)
    WasmIntegration *m_wasm;
#endif
};
