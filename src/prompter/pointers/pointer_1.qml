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
        property real r: pointerText.color.r * pointerText.color.a
        property real g: pointerText.color.g * pointerText.color.a
        property real b: pointerText.color.b * pointerText.color.a
        width: pointerText.width
        height: pointerText.height
        vertexShader: "
            uniform highp mat4 qt_Matrix;
            attribute highp vec4 qt_Vertex;
            attribute highp vec2 qt_MultiTexCoord0;
            varying highp vec2 coord;

            void main() {
                coord = qt_MultiTexCoord0;
                gl_Position = qt_Matrix * qt_Vertex;
            }
        "
        // avg calibrated to achieve similar color from a yellow emoji
        fragmentShader: "
            varying highp vec2 coord;
            uniform sampler2D src;

            uniform lowp float r;
            uniform lowp float g;
            uniform lowp float b;

            void main() {
                lowp vec4 clr = texture2D(src, coord);
                lowp float avg = (clr.r + clr.g + clr.b) / 2.0;
                gl_FragColor = vec4(r * avg, g * avg, b * avg, clr.a);
            }
        "
    }
}
