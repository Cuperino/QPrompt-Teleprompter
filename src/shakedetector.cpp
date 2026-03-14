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

#include "shakedetector.h"

ShakeDetector *ShakeDetector::s_instance = nullptr;

ShakeDetector::ShakeDetector(QObject *parent)
    : QObject(parent)
{
    s_instance = this;
    setupShakeDetection();
}

ShakeDetector *ShakeDetector::instance()
{
    return s_instance;
}

ShakeDetector *ShakeDetector::create(QQmlEngine *engine, QJSEngine *)
{
    if (!s_instance)
        s_instance = new ShakeDetector(engine);
    return s_instance;
}

void ShakeDetector::setupShakeDetection()
{
}

void ShakeDetector::showUndoRedoDialog(bool, bool)
{
    Q_UNREACHABLE();
}
