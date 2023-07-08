/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2023 Javier O. Cordero Pérez
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

import QtQuick 2.15
import QtQuick.Shapes 1.15
import QtQuick.Controls.Material 2.12

import com.cuperino.qprompt.abstractunits 1.0

Shape {
    property int prompterState
    property int lineWidth
    property bool configuratorOpen
    property color colorsEditing
    property color colorsReady
    property color colorsPrompting
    width: 1.6 * pointers.__pointerUnit
    anchors.verticalCenter: parent.verticalCenter
    ShapePath {
        strokeWidth: Math.ceil((lineWidth) / 17 * (pointers.__pointerUnit / 2))
        strokeColor: switch (prompterState) {
        case 0:
            return colorsEditing;
        case 3:
            return colorsPrompting;
        default:
            return colorsReady;
        }
        fillColor: "#00000000"
        //fillColor: switch (prompterState) {
        //    case Prompter.States.Editing:
        //        return colorsEditing;
        //    case Prompter.States.Prompting:
        //        return colorsPrompting;
        //    default:
        //        return colorsReady;
        //}
        // Bottom left starting point
        startX: 0; startY: parent.width
        // Center right
        PathLine { x: parent.width; y: 0 }
        // Top left
        PathLine { x: 0; y: -parent.width }
        Behavior on strokeColor {
            enabled: configuratorOpen
            ColorAnimation {
                duration: Units.VeryLongDuration
            }
        }
    }
}
