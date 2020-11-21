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
import QtQuick.Shapes 1.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.0
import Qt.labs.platform 1.0
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

Item {
    id: overlay
    property double __opacity: 0
    property double __trianglesOpacity: 0.08
    property color __color: 'black'
    readonly property double __vw: width/100
    property alias __readRegionPlacement: readRegion.__placement
    property alias enabled: readRegion.enabled
    //anchors.fill: parent
    anchors {
       left: parent.left
       right: parent.right
       top: parent.top
       //bottom: parent.bottom
    }
    ////width: editor.width
    height: prompter.height //parent.implicitFooterHeight
    //height: parent.height //parent.implicitFooterHeight
    function toggle() {
        var states = ["top", "middle", "bottom", "free", "fixed"]
        var nextIndex = ( states.indexOf(readRegion.state) + 1 ) % states.length
        readRegion.state = states[nextIndex]
    }
    MouseArea {
        id: overlayMouseArea
        enabled: false
        anchors.fill: parent
        cursorShape: Qt.DefaultCursor
        propagateComposedEvents: true
    }
    states: [
        State {
            name: "prompting"
            PropertyChanges {
                target: overlay
                __opacity: 0.4
                __trianglesOpacity: 0.4
                enabled: false
            }
            PropertyChanges {
                target: overlayMouseArea
                enabled: true
                cursorShape: Qt.CrossCursor
            }
        }
    ]
    state: "editing"
    transitions: [
        Transition {
            enabled: !root.__autoFullScreen
            from: "*"; to: "*"
            NumberAnimation {
                targets: [overlay]
                properties: "__opacity"; duration: 250;
            }
            //PropertyAnimation {
            //targets: root
            //properties: "visibility"; duration: 250;
            //}
        }
    ]
    Item {
        id: readRegion
        enabled: false
        property double __customPlacement: 0.5
        property double __placement: __customPlacement
        height: 21 * __vw
        y: readRegion.__placement * (overlay.height - readRegion.height)
        anchors.left: parent.left
        anchors.right: parent.right
        states: [
            State {
                name: "top"
                PropertyChanges {
                    target: readRegion
                    __placement: 0
                }
                PropertyChanges {
                    target: readRegionButton
                    text: i18n("Top")
                    iconName: "go-up"
                    //iconName: "gtk-goto-top"
                }
            },
            State {
                name: "middle"
                PropertyChanges {
                    target: readRegion
                    __placement: 0.5
                }
                PropertyChanges {
                    target: readRegionButton
                    text: i18n("Middle")
                    iconName: "remove"
                }
            },
            State {
                name: "bottom"
                PropertyChanges {
                    target: readRegion
                    __placement: 1
                }
                PropertyChanges {
                    target: readRegionButton
                    text: i18n("Bottom")
                    iconName: "go-down"
                    //iconName: "gtk-goto-bottom"
                }
            },
            State {
                name: "free"
                PropertyChanges {
                    target: overlay
                    __opacity: 0.4
                }
                PropertyChanges {
                    target: triangles
                    __opacity: 0.4
                }
                PropertyChanges {
                    target: readRegion
                    enabled: true
                }
                PropertyChanges {
                    target: triangles
                    __fillColor: "#180000"
                }
                PropertyChanges {
                    target: readRegionButton
                    text: i18n("Free")
                    iconName: "gtk-edit"
                }
            },
            State {
                name: "fixed"
                PropertyChanges {
                    target: readRegion
                    __placement: readRegion.__placement
                }
                PropertyChanges {
                    target: readRegionButton
                    text: i18n("Custom")
                    iconName: "gtk-apply"
                }
            }
        ]
        state: "middle"
        transitions: [
            Transition {
                from: "*"; to: "*"
                NumberAnimation {
                    targets: readRegion
                    properties: "__placement"; duration: 200; easing.type: Easing.OutQuad
                }
                NumberAnimation {
                    targets: triangles
                    properties: "__fillColor"; duration: 250;
                }
                NumberAnimation {
                    targets: overlay
                    properties: "__opacity"; duration: 250;
                }
            }
        ]
        MouseArea {
            anchors.fill: parent
            drag.target: parent
            drag.axis: Drag.YAxis
            drag.smoothed: false
            drag.minimumY: 0
            drag.maximumY: overlay.height - this.height
            cursorShape: Qt.PointingHandCursor
            onReleased: {
                readRegion.__customPlacement = readRegion.y / (overlay.height - readRegion.height)
            }
        }
        Item {
            id: triangles
            property double __opacity: overlay.__trianglesOpacity
            property color __strokeColor: "lightgray"
            property color __fillColor: "#001800"
            property double __offsetX: 0.3333
            property double __stretchX: 0.3333
            readonly property double __triangleUnit: parent.height / 6
            Shape {
                opacity: triangles.__opacity
                ShapePath {
                    strokeWidth: 3
                    strokeColor: triangles.__strokeColor
                    fillColor: triangles.__fillColor
                    // Top left starting point                                
                    startX: triangles.__offsetX*triangles.__triangleUnit; startY: 1*triangles.__triangleUnit
                    // Bottom left
                    PathLine { x: triangles.__offsetX*triangles.__triangleUnit; y: 5*triangles.__triangleUnit }
                    // Center right
                    PathLine { x: (3*triangles.__stretchX+triangles.__offsetX)*triangles.__triangleUnit; y: 3*triangles.__triangleUnit }
                    // Top left return
                    PathLine { x: triangles.__offsetX*triangles.__triangleUnit; y: 1*triangles.__triangleUnit }
                }
            }
            Shape {
                opacity: triangles.__opacity
                x: parent.parent.width
                ShapePath {
                    strokeWidth: 3
                    strokeColor: triangles.__strokeColor
                    fillColor: triangles.__fillColor
                    // Top right starting point                                
                    startX: -triangles.__offsetX*triangles.__triangleUnit; startY: 1*triangles.__triangleUnit
                    // Bottom right
                    PathLine { x: -triangles.__offsetX*triangles.__triangleUnit; y: 5*triangles.__triangleUnit }
                    // Center left
                    PathLine { x: -(3*triangles.__stretchX+triangles.__offsetX)*triangles.__triangleUnit; y: 3*triangles.__triangleUnit }
                    // Top right return
                    PathLine { x: -triangles.__offsetX*triangles.__triangleUnit; y: 1*triangles.__triangleUnit }
                }
            }
        }
    }
    Rectangle {
        anchors.top: parent.top
        anchors.bottom: readRegion.top
        anchors.left: parent.left
        anchors.right: parent.right
        opacity: overlay.__opacity
        color: overlay.__color
    }
    Rectangle {
        anchors.top: readRegion.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        opacity: overlay.__opacity
        color: overlay.__color
    }
}
