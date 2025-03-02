/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2023-2024 Javier O. Cordero Pérez
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

Text {
    id: pointerText
    property int prompterState
    property bool configuratorOpen
    property bool tint
    property color colorsEditing
    property color colorsReady
    property color colorsPrompting
    property int textVerticalOffset
    y: textVerticalOffset
    color: switch (prompterState) {
        case 0:
            return colorsEditing;
        case 3:
            return colorsPrompting;
        default:
            return colorsReady;
    }
    textFormat: Text.PlainText
    renderType: Text.QtRendering
    font.pixelSize: 5 * pointers.__pointerUnit
    font.kerning: false
    layer.enabled: tint
    layer.effect: ShaderEffect {
        property variant src: pointerText
        property color tint: pointerText.color
        width: pointerText.width
        height: pointerText.height
        fragmentShader: "/qt/qml/com/cuperino/qprompt/shaders/tint.frag.qsb"
    }
}
