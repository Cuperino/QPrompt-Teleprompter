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

#include "appcontroller.h"

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

QString AppController::globalShortcutKey(GlobalHotkeys::Action action)
{
    return m_hotkeys->globalShortcutKey(action);
}

void AppController::setGlobalShortcut(Qt::Key key, Qt::KeyboardModifiers modifiers, GlobalHotkeys::Action action)
{
    m_hotkeys->setGlobalShortcut(key, modifiers, action);
}
