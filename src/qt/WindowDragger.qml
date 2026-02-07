/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2021-2023 Javier O. Cordero Pérez
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

import QtQuick 2.12

// Component for dragging a window
MouseArea {
    enabled: Qt.platform.os!=="android" && Qt.platform.os!=="wasm"
    property var window: parent
    property int prevX: 0
    property int prevY: 0
    cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
    onPressed: (mouse) => {
        if (Qt.platform.os!=="android" && Qt.platform.os!=="wasm") {
            prevX=mouse.x
            prevY=mouse.y
        }
    }
    onPositionChanged: (mouse) => {
        if (Qt.platform.os!=="android" && Qt.platform.os!=="wasm") {
            var deltaX = mouse.x - prevX;

            root.x += deltaX;
            prevX = mouse.x - deltaX;

            var deltaY = mouse.y - prevY
            root.y += deltaY;
            prevY = mouse.y - deltaY;
        }
    }
}
