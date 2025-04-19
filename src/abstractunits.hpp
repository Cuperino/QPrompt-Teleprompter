/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2022-2025 Javier O. Cordero Pérez
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

#include <QObject>
#include <QQmlEngine>

class AbstractUnits : public QObject
{
    Q_OBJECT
    QML_UNCREATABLE("Cannot create")

public:
    enum Durations { VeryShortDuration = 50, ShortDuration = 100, LongDuration = 200, VeryLongDuration = 400, ToolTipDelay = 700, HumanMoment = 2000 };
    Q_ENUM(Durations)
};
