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

// "QML change image color" answer from Mar 4, 2016 by Paweł Krakowiak (user 3994230 on StackOverflow)
// Link: https://stackoverflow.com/a/35800198/3833454
// License: https://creativecommons.org/licenses/by-sa/3.0/

import QtQuick 2.15

Image {
    id: pointerImage
    property int prompterState
    property bool tint
    property int imageVerticalOffset
    y: imageVerticalOffset
    property color colorsEditing
    property color colorsReady
    property color colorsPrompting
    readonly property color colorValue: switch (prompterState) {
        case 0:
            return colorsEditing;
        case 3:
            return colorsPrompting;
        default:
            return colorsReady;
    }
    width: 8 * pointers.__pointerUnit
    fillMode: Image.PreserveAspectFit
    asynchronous: true
    mipmap: true
    smooth: true
    cache: false
    layer.enabled: tint
    layer.effect: ShaderEffect {
        property variant src: pointerImage
        property real r: pointerImage.colorValue.r * pointerImage.colorValue.a
        property real g: pointerImage.colorValue.g * pointerImage.colorValue.a
        property real b: pointerImage.colorValue.b * pointerImage.colorValue.a
        width: pointerImage.width
        height: pointerImage.height
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
        // avg calibrated to achieve similar color on demo image
        fragmentShader: "
            varying highp vec2 coord;
            uniform sampler2D src;

            uniform lowp float r;
            uniform lowp float g;
            uniform lowp float b;

            void main() {
                lowp vec4 clr = texture2D(src, coord);
                lowp float avg = (clr.r + clr.g + clr.b) / 2.4;
                gl_FragColor = vec4(r * avg, g * avg, b * avg, clr.a);
            }
        "
    }
}
