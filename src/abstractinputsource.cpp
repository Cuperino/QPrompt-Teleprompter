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

#include "abstractinputsource.h"

#include "appcontroller.h"

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
