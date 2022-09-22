/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2020-2022 Javier O. Cordero Pérez
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
import QtQuick.Shapes 1.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.12
import Qt.labs.settings 1.0
import com.cuperino.qprompt.abstractunits 1.0

Item {
    id: overlay
    enum States {
        NotPrompting,
        Prompting
    }
    enum PositionStates {
        Top,
        Middle,
        Bottom,
        Free,
        Fixed
    }
    enum PointerStates {
        None,
        Pointers,
        LeftPointer,
        RightPointer,
        Bars,
        BarsLeft,
        BarsRight,
        All
    }
    readonly property alias readRegionHeight: readRegion.height
    readonly property double __vw: width/100
    readonly property bool atTop: !prompter.__flipY && !__readRegionPlacement || prompter.__flipY && __readRegionPlacement===1
    readonly property bool atBottom: !prompter.__flipY && __readRegionPlacement===1 || prompter.__flipY && !__readRegionPlacement
    readonly property Scale __flips: Flip{}
    property double __opacity: 0.06
    property real linesInRegion: 3
    property color __color: 'black'
    property alias __readRegionPlacement: readRegion.__placement
    property alias enabled: readRegion.enabled
    property bool disableOverlayContrast: false
    property string positionState: ReadRegionOverlay.PositionStates.Middle
    property string styleState: Qt.application.layoutDirection===Qt.LeftToRight ? "barsLeft" : "barsRight"
    function toggleLinesInRegion(reverse) {
        const minSize = 2,
              maxSize = 5;
        if (reverse) {
            linesInRegion -= 0.5
            if (linesInRegion < minSize)
                linesInRegion = maxSize
        }
        else {
            linesInRegion += 0.5
            if (linesInRegion > maxSize)
                linesInRegion = minSize
        }
    }
    transform: __flips
    anchors.fill: parent
//    anchors {
//       left: parent.left
//       right: parent.right
//       top: parent.top
//       //bottom: parent.bottom
//    }
//    height: prompter.height //parent.implicitFooterHeight
    ////width: editor.width
    //height: parent.height //parent.implicitFooterHeight
    //function toggle() {
    //    var states = ["top", "middle", "bottom", "free", "fixed"]
    //    var nextIndex = ( states.indexOf(readRegion.state) + 1 ) % states.length
    //    readRegion.state = states[nextIndex]
    //}

    Settings {
        category: "readRegion"
        property alias state: overlay.positionState
        property alias styleState: overlay.styleState
        property alias placement: readRegion.__customPlacement
        property alias enabled: readRegion.enabled
        property alias linesInRegion: overlay.linesInRegion
        property alias disableOverlayContrast: overlay.disableOverlayContrast
    }
    MouseArea {
        id: overlayMouseArea
        enabled: false
        anchors.fill: parent
        cursorShape: Qt.CrossCursor
        propagateComposedEvents: true
    }
    Item {
        id: readRegion

        // Compute screen middle in relation to overlay's proportions
        // It's not perfect yet but this is a decent approximation for use in full screen tablets.
        readonly property double screenMiddle: (screen.height / overlay.height) * (((screen.height / 2) - 40 - root.y) / screen.height)
        property double __customPlacement: 0.5
        property double __placement: __customPlacement

        enabled: false
        height: (linesInRegion * editorToolbar.lineHeightSlider.value/100 * 1.18 + 0.05) * prompter.fontSize
        y: readRegion.__placement * (overlay.height - readRegion.height)
        anchors.left: parent.left
        anchors.right: parent.right

        MouseArea {
            anchors.fill: parent
            drag.target: parent
            drag.axis: Drag.YAxis
            drag.smoothed: false
            drag.minimumY: 0
            drag.maximumY: overlay.height - this.height
            cursorShape: (pressed||drag.active) ? Qt.ClosedHandCursor : Qt.OpenHandCursor
            onReleased: {
                readRegion.__customPlacement = readRegion.y / (overlay.height - readRegion.height)
            }
        }
        Item {
            id: pointers

            readonly property double __pointerUnit: parent.height / 6
            property double __opacity: 1
            property color __strokeColor: parent.Material.theme===Material.Light ? "#4d94cf" : "#2b72ad"
            property color __fillColor: "#00000000"
            property double __offsetX: 0
            //property double __offsetX: -0.1111
            property double __stretchX: 0.3333

            //layer.enabled: true

            Shape {
                id: leftPointer
                x: prompter.editorXWidth*overlay.width + prompter.editorXOffset*overlay.width - (2.8*pointers.__stretchX+pointers.__offsetX)*pointers.__pointerUnit
                ShapePath {
                    strokeWidth: pointers.__pointerUnit*0.3
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
                x: parent.parent.width - prompter.editorXWidth*overlay.width + prompter.editorXOffset*overlay.width + (2.7*pointers.__stretchX+pointers.__offsetX)*pointers.__pointerUnit
                ShapePath {
                    strokeWidth: pointers.__pointerUnit*0.3
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
                    name: ReadRegionOverlay.PointerStates.None
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
                    name: ReadRegionOverlay.PointerStates.Pointers
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
                    name: ReadRegionOverlay.PointerStates.LeftPointer
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
                    name: ReadRegionOverlay.PointerStates.RightPointer
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
                    name: ReadRegionOverlay.PointerStates.Bars
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
                    name: ReadRegionOverlay.PointerStates.BarsLeft
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
                    name: ReadRegionOverlay.PointerStates.BarsRight
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
                    name: ReadRegionOverlay.PointerStates.All
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
                        duration: Units.ShortDuration
                        easing.type: Easing.OutQuad
                    }
                }
            ]
        }

        states: [
            State {
                name: ReadRegionOverlay.PositionStates.Top
                PropertyChanges {
                    target: readRegion
                    __placement: 0
                }
            },
            State {
                name: ReadRegionOverlay.PositionStates.Middle
                PropertyChanges {
                    target: readRegion
                    __placement: ['android', 'ios', 'tvos', 'qnx', 'ipados'].indexOf(Qt.platform.os)===-1? 0.5 : screenMiddle
                }
            },
            State {
                name: ReadRegionOverlay.PositionStates.Bottom
                PropertyChanges {
                    target: readRegion
                    __placement: 1
                }
            },
            State {
                name: ReadRegionOverlay.PositionStates.Free
                PropertyChanges {
                    target: overlay
                    __opacity: 0.4
                    z: 4
                }
                PropertyChanges {
                    target: pointers
                    // Workaround to ensure pointer color does not remain in its free state setting when changing to other prompter states
                    __strokeColor: parseInt(prompter.state)===Prompter.States.Editing ? "#2a71ad" : "#4d94cf"
                }
                PropertyChanges {
                    target: readRegion
                    enabled: true
                }
            },
            State {
                name: ReadRegionOverlay.PositionStates.Fixed
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
                    duration: Units.ShortDuration
                    easing.type: Easing.OutQuad
                }
                ColorAnimation {
                    targets: [pointers]
                    properties: "__fillColor,__strokeColor"
                    duration: Units.ShortDuration
                    easing.type: Easing.OutQuad
                }
            }
        ]
    }

    Rectangle {
        id: topBar
        anchors.top: parent.top
        anchors.bottom: readRegion.top
        anchors.left: parent.left
        anchors.right: parent.right
        opacity: overlay.__opacity*2/3
        color: overlay.__color
        Rectangle {
            visible: !overlay.disableOverlayContrast
            anchors.fill: parent
            opacity: overlay.__opacity*2/3
            color: "#FFF"
        }
    }

    Rectangle {
        id: bottomBar
        anchors.top: readRegion.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        opacity: overlay.__opacity*2/3
        color: overlay.__color
        Rectangle {
            visible: !overlay.disableOverlayContrast
            anchors.fill: parent
            opacity: overlay.__opacity*2/3
            color: "#FFF"
        }
    }

    states: [
        State {
            name: ReadRegionOverlay.States.Prompting
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
    state: ReadRegionOverlay.States.NotPrompting
    transitions: [
        Transition {
            enabled: !root.__autoFullScreen
            from: "*"; to: "*"
            NumberAnimation {
                targets: [overlay]
                properties: "__opacity"
                duration: Units.LongDuration
            }
        }
    ]
}
