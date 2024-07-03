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

Image {
    id: pointerImage
    property int prompterState
    property bool tint
    property int imageVerticalOffset
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
    y: imageVerticalOffset
    width: 8 * pointers.__pointerUnit
    fillMode: Image.PreserveAspectFit
    asynchronous: true
    mipmap: true
    smooth: true
    cache: false
    layer.enabled: tint
    layer.effect: ShaderEffect {
        property variant src: pointerImage
        property color tint: pointerImage.colorValue
        width: pointerImage.width
        height: pointerImage.height
        fragmentShader: "/qt/qml/com/cuperino/qprompt/shaders/tint.frag.qsb"
    }
}
