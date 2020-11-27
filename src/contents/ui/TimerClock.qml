/****************************************************************************
 **
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
import QtQuick.Shapes 1.15

Item {
    id: timer
    property real size: 1
    readonly property real centreX: prompter.centreX;
    readonly property real centreY: prompter.centreY;
    anchors {
        left: parent.left
        right: parent.right
        top: parent.top
    }
    height: prompter.height
    
    FontLoader {
        id: monoSpacedFont
        name: "Monospace"
    }
    
    Label {
        id: clock
        readonly property real centreX: width / 2;
        readonly property real centreY: height / 2;
        x: timer.centreX - centreX
        y: timer.height - clock.height - centreY/2
        text: "00:00:00"
        background: Rectangle {
            color: "#212121"
            opacity: 0.6
            border.color: "#131619"
            border.width: 1.4 * timer.size * prompter.__vw
            radius: 10 * timer.size * prompter.__vw
        }
        color: "#fcfcf9"
        font.family: monoSpacedFont.name
        font.pixelSize: 10 * timer.size * prompter.__vw
        leftPadding: 4 * timer.size * prompter.__vw
        rightPadding: 4 * timer.size * prompter.__vw
        topPadding: 2 * timer.size * prompter.__vw
        bottomPadding: 2 * timer.size * prompter.__vw
    }
}
