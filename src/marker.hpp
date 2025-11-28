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

struct Marker {
    Q_GADGET
    Q_PROPERTY(QString text MEMBER text)
    Q_PROPERTY(QString keyLetter MEMBER keyLetter)
    Q_PROPERTY(QString url MEMBER url)
    Q_PROPERTY(int position MEMBER position)
    Q_PROPERTY(int length MEMBER length)
    Q_PROPERTY(int key MEMBER key)
    Q_PROPERTY(int requestType MEMBER requestType)
public:
    Marker() {
        position = 0;
    };
    explicit Marker(int p)
    {
        position = p;
    };
    // Contents
    QString text;
    QString keyLetter;
    QString url;
    int position = 0;
    int length = 1;
    int key = 0;
    int requestType = 0;
};
Q_DECLARE_METATYPE(Marker);
