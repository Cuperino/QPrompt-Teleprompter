/****************************************************************************
 * *
 ** QPrompt
 ** Copyright (C) 2020 Javier O. Cordero Pérez
 **
 ** This file is part of QPrompt.
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

import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: countdown
    
    anchors.fill: parent
    color: "#999999"
    //color: "#333333"
    //opacity: 0.75
    
    PathView {
        anchors.fill: parent
        //model: ContactModel {}
        delegate: delegate
        path: Path {
            startX: 0; startY: 100
            
            PathArc {
                x: 100; y: 200
                radiusX: 100; radiusY: 100
                useLargeArc: true
                direction: PathArc.Clockwise
            }
        }
    }
}
