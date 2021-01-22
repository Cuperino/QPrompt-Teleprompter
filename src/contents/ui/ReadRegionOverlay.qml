/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2020-2021 Javier O. Cordero Pérez
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
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import org.kde.kirigami 2.9 as Kirigami

Item {
    id: overlay
    property double __opacity: 0.06
    property color __color: 'black'
    readonly property double __vw: width/100
    property alias __readRegionPlacement: readRegion.__placement
    property alias enabled: readRegion.enabled
    property string positionState: "middle"
    property string styleState: Qt.application.layoutDirection===Qt.LeftToRight ? "barsLeft" : "barsRight"
    readonly property alias readRegionHeight: readRegion.height
    readonly property Scale __flips: Scale {
        origin.x: width/2
        origin.y: height/2
        xScale: prompter.state!=="editing" && prompter.__flipX ? -1 : 1
        yScale: prompter.state!=="editing" && prompter.__flipY ? -1 : 1
    }
    transform: __flips
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
    //function toggle() {
    //    var states = ["top", "middle", "bottom", "free", "fixed"]
    //    var nextIndex = ( states.indexOf(readRegion.state) + 1 ) % states.length
    //    readRegion.state = states[nextIndex]
    //}
    MouseArea {
        id: overlayMouseArea
        enabled: false
        anchors.fill: parent
        //cursorShape: Qt.DefaultCursor
        propagateComposedEvents: true
    }
    states: [
        State {
            name: "prompting"
            PropertyChanges {
                target: overlay
                __opacity: 0.4
                enabled: false
            }
            //PropertyChanges {
            //    target: overlayMouseArea
            //    enabled: true
            //    cursorShape: Qt.CrossCursor
            //}
        }
    ]
    state: "editing"
    transitions: [
        Transition {
            enabled: !root.__autoFullScreen
            from: "*"; to: "*"
            NumberAnimation {
                targets: [overlay]
                properties: "__opacity"
                duration: Kirigami.Units.longDuration
            }
        }
    ]
    Item {
        id: readRegion
        enabled: false
        property double __customPlacement: 0.5
        property double __placement: __customPlacement
        height: 2.1 * prompter.fontSize
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
            },
            State {
                name: "middle"
                PropertyChanges {
                    target: readRegion
                    __placement: 0.5
                }
            },
            State {
                name: "bottom"
                PropertyChanges {
                    target: readRegion
                    __placement: 1
                }
            },
            State {
                name: "free"
                PropertyChanges {
                    target: overlay
                    __opacity: 0.4
                    z: 3
                }
                PropertyChanges {
                    target: pointers
                    __opacity: 0.4
                }
                PropertyChanges {
                    target: readRegion
                    enabled: true
                }
                PropertyChanges {
                    target: pointers
                    __fillColor: "#180000"
                }
            },
            State {
                name: "fixed"
                PropertyChanges {
                    target: readRegion
                    __placement: readRegion.__customPlacement
                }
            }
        ]
        state: overlay.positionState
        transitions: [
            Transition {
                from: "*"; to: "*"
                NumberAnimation {
                    targets: [readRegion, pointers, overlay]
                    properties: "__placement,__opacity"
                    duration: Kirigami.Units.shortDuration
                    easing.type: Easing.OutQuad
                }
                ColorAnimation {
                    targets: [pointers]
                    properties: "__fillColor,__strokeColor"
                    duration: Kirigami.Units.shortDuration
                    easing.type: Easing.OutQuad
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
            id: pointers
            property double __opacity: 1
            property color __strokeColor: parent.Material.theme===Material.Light ? "#4d94cf" : "#2b72ad"
            property color __fillColor: "#00000000"
            property double __offsetX: 0
            //property double __offsetX: -0.1111
            property double __stretchX: 0.3333
            readonly property double __pointerUnit: parent.height / 6
            Shape {
                id: leftPointer
                x: prompter.editorXOffset*overlay.width - (2.8*pointers.__stretchX+pointers.__offsetX)*pointers.__pointerUnit
                ShapePath {
                    strokeWidth: pointers.__pointerUnit/3
                    strokeColor: pointers.__strokeColor
                    fillColor: pointers.__fillColor
                    // Top left starting point                                
                    startX: pointers.__offsetX*pointers.__pointerUnit; startY: 2*pointers.__pointerUnit
                    // Center right
                    PathLine { x: (3*pointers.__stretchX+pointers.__offsetX)*pointers.__pointerUnit; y: 3*pointers.__pointerUnit }
                    // Bottom left
                    PathLine { x: pointers.__offsetX*pointers.__pointerUnit; y: 4*pointers.__pointerUnit }
                    //// Top left return
                    //PathLine { x: pointers.__offsetX*pointers.__pointerUnit; y: 1*pointers.__pointerUnit }
                }
            }
            Shape {
                id: rightPointer
                x: parent.parent.width - prompter.editorXOffset*overlay.width + (2.7*pointers.__stretchX+pointers.__offsetX)*pointers.__pointerUnit
                ShapePath {
                    strokeWidth: pointers.__pointerUnit/3
                    strokeColor: pointers.__strokeColor
                    fillColor: pointers.__fillColor
                    // Top right starting point                                
                    startX: -pointers.__offsetX*pointers.__pointerUnit; startY: 2*pointers.__pointerUnit
                    // Center left
                    PathLine { x: -(3*pointers.__stretchX+pointers.__offsetX)*pointers.__pointerUnit; y: 3*pointers.__pointerUnit }
                    // Bottom right
                    PathLine { x: -pointers.__offsetX*pointers.__pointerUnit; y: 4*pointers.__pointerUnit }
                    //// Top right return
                    //PathLine { x: -pointers.__offsetX*pointers.__pointerUnit; y: 2*pointers.__pointerUnit }
                }
            }
            states: [
                State {
                    name: "none"
                    PropertyChanges {
                        target: pointers
                        opacity: 0
                    }
                    PropertyChanges {
                        target: topBar
                        opacity: 0
                    }
                    PropertyChanges {
                        target: bottomBar
                        opacity: 0
                    }
                },
                State {
                    name: "pointers"
                    PropertyChanges {
                        target: pointers
                        opacity: __opacity
                    }
                    PropertyChanges {
                        target: topBar
                        opacity: 0
                    }
                    PropertyChanges {
                        target: bottomBar
                        opacity: 0
                    }
                },
                State {
                    name: "leftPointer"
                    PropertyChanges {
                        target: pointers
                        opacity: __opacity
                    }
                    PropertyChanges {
                        target: rightPointer
                        opacity: 0
                    }
                    PropertyChanges {
                        target: topBar
                        opacity: 0
                    }
                    PropertyChanges {
                        target: bottomBar
                        opacity: 0
                    }
                },
                State {
                    name: "rightPointer"
                    PropertyChanges {
                        target: pointers
                        opacity: __opacity
                    }
                    PropertyChanges {
                        target: leftPointer
                        opacity: 0
                    }
                    PropertyChanges {
                        target: topBar
                        opacity: 0
                    }
                    PropertyChanges {
                        target: bottomBar
                        opacity: 0
                    }
                },
                State {
                    name: "bars"
                    PropertyChanges {
                        target: pointers
                        opacity: 0
                    }
                    PropertyChanges {
                        target: topBar
                        opacity: overlay.__opacity
                    }
                    PropertyChanges {
                        target: bottomBar
                        opacity: overlay.__opacity
                    }
                },
                State {
                    name: "barsLeft"
                    PropertyChanges {
                        target: pointers
                        opacity: __opacity
                    }
                    PropertyChanges {
                        target: rightPointer
                        opacity: 0
                    }
                    PropertyChanges {
                        target: topBar
                        opacity: overlay.__opacity
                    }
                    PropertyChanges {
                        target: bottomBar
                        opacity: overlay.__opacity
                    }
                },
                State {
                    name: "barsRight"
                    PropertyChanges {
                        target: pointers
                        opacity: __opacity
                    }
                    PropertyChanges {
                        target: leftPointer
                        opacity: 0
                    }
                    PropertyChanges {
                        target: topBar
                        opacity: overlay.__opacity
                    }
                    PropertyChanges {
                        target: bottomBar
                        opacity: overlay.__opacity
                    }
                },
                State {
                    name: "all"
                    PropertyChanges {
                        target: pointers
                        opacity: __opacity
                    }
                    PropertyChanges {
                        target: topBar
                        opacity: overlay.__opacity
                    }
                    PropertyChanges {
                        target: bottomBar
                        opacity: overlay.__opacity
                    }
                }
            ]
            state: overlay.styleState
            transitions: [
                Transition {
                    from: "*"; to: "*"
                    NumberAnimation {
                        targets: [pointers, leftPointer, rightPointer, topBar, bottomBar]
                        properties: "opacity"
                        duration: Kirigami.Units.shortDuration
                        easing.type: Easing.OutQuad
                    }
                }
            ]
        }
    }
    Rectangle {
        id: topBar
        anchors.top: parent.top
        anchors.bottom: readRegion.top
        anchors.left: parent.left
        anchors.right: parent.right
        opacity: overlay.__opacity
        color: overlay.__color
    }
    Rectangle {
        id: bottomBar
        anchors.top: readRegion.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        opacity: overlay.__opacity
        color: overlay.__color
    }
}
