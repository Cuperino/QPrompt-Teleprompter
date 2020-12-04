/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2020 Javier O. Cordero Pérez
 **
 ** This program is free software: you can redistribute it and/or modify
 ** it under the terms of the GNU General Public License as published by
 ** the Free Software Foundation, either version 3 of the License, or
 ** (at your option) any later version.
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

#include "promptertimer.h"
#include <QObject>
#include <QString>

PrompterTimer::PrompterTimer(QObject *parent) : QObject(parent)
{

}

// void PrompterTimer::chronometerChanged() {
//
// }
//
// void PrompterTimer::etaChanged() {
//
// }

void PrompterTimer::start() {

}

void PrompterTimer::stop() {

}

void PrompterTimer::reset() {

}

void PrompterTimer::toggle(bool value) {

}

void PrompterTimer::setChronometer(QString value) {

}

void PrompterTimer::setETA(QString value) {

}

QString PrompterTimer::chronometer() {
    return this->m_chronometer;
}

QString PrompterTimer::eta() {
    return this->m_eta;
}
