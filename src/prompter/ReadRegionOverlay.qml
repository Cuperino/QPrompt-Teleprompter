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
import QtCore
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
        LeftPointer,
        RightPointer,
        Pointers,
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
    property string styleState: ReadRegionOverlay.PointerStates.All
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
    ShaderEffectSource {
        id: pointerShadowSource
        sourceItem: readRegion
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

        layer.enabled: root.shadows
        layer.effect: ShaderEffect {
            width: readRegion.width
            height: readRegion.height
            readonly property variant source: pointerShadowSource
            readonly property real angle: 180
            readonly property point offset: Qt.point(pointers.__pointerUnit / 3 * Math.cos(angle), pointers.__pointerUnit / 3 * Math.sin(angle))
            readonly property size delta: Qt.size(offset.x / width, offset.y / height)
            readonly property real darkness: 0.5
            readonly property variant shadow: ShaderEffectSource {
                sourceItem: ShaderEffect {
                    width: readRegion.width
                    height: readRegion.height
                    readonly property size delta: Qt.size(0.0, 4.0 / height)
                    readonly property variant source: ShaderEffectSource {
                        sourceItem: ShaderEffect {
                            width: readRegion.width
                            height: readRegion.height
                            readonly property size delta: Qt.size(4.0 / width, 0.0)
                            readonly property variant source: pointerShadowSource
                            fragmentShader: "/shaders/shaders/blur.frag.qsb"
                        }
                    }
                    fragmentShader: "/shaders/shaders/blur.frag.qsb"
                }
            }
            fragmentShader: "/shaders/shaders/shadow.frag.qsb"
        }

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

            readonly property double __pointerUnit: parent.height / 10
            property double __opacity: 1
            property color __strokeColor: parent.Material.theme===Material.Light ? "#4d94cf" : "#2b72ad"
            property color __fillColor: "#00000000"
            property double __stretchX: 0.3333

            x: prompter.editorXWidth*overlay.width + prompter.editorXOffset*overlay.width
            width: readRegion.width - 2 * prompter.editorXWidth * readRegion.width
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter
            // anchors.top: parent.top
            // anchors.bottom: parent.bottom
            // Debug code
            Item {
                id: pointerDebugTools
                anchors.fill: parent
                opacity: 0
                Rectangle {
                    width: 4
                    color: "red"
                    anchors.right: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                }
                Rectangle {
                    width: 4
                    color: "red"
                    anchors.left: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                }
                // The declaration order of complimentary Animators is important:
                // The animation which starts at the brightest point must be declared last so that it can be cancelled over previous, darker animations, and the opposite isn't true, resulting in a less jarring experience from quickly toggling between animations.
                OpacityAnimator {
                    target: pointerDebugTools;
                    from: pointerDebugTools.opacity
                    to: 0;
                    duration: 500
                    running: !pointerSettings.debug
                    onFinished: {
                        target.opacity = to
                    }
                }
                OpacityAnimator {
                    target: pointerDebugTools;
                    running: pointerSettings.debug
                    duration: 500
                    from: pointerDebugTools.opacity
                    to: 1;
                    onFinished: {
                        target.opacity = to
                    }
                }
            }
            // Debug code ends
            Loader {
                id: leftPointer
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.left
                source: pointerSettings.pointerKind === PointerSettings.States.QML ? pointerSettings.qmlLeftPath : "qrc:/pointers/pointer_" + pointerSettings.pointerKind + ".qml"
            }
            Loader {
                id: rightPointer
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.right
                source: pointerSettings.pointerKind === PointerSettings.States.QML ? (pointerSettings.sameAsLeftPointer ? pointerSettings.qmlLeftPath : pointerSettings.qmlRightPath) : "qrc:/pointers/pointer_" + pointerSettings.pointerKind + ".qml"
            }
            Binding {
                target: leftPointer.item
                property: "prompterState"
                value: parseInt(prompter.state)
            }
            Binding {
                target: rightPointer.item
                property: "prompterState"
                value: parseInt(prompter.state)
            }
            Binding {
                target: leftPointer.item
                property: "configuratorOpen"
                value: pointerConfiguration.sheetOpen
            }
            Binding {
                target: rightPointer.item
                property: "configuratorOpen"
                value: pointerConfiguration.sheetOpen
            }
            Binding {
                target: leftPointer.item
                property: "colorsEditing"
                value: pointerSettings.colorsEditing
            }
            Binding {
                target: rightPointer.item
                property: "colorsEditing"
                value: pointerSettings.colorsEditing
            }
            Binding {
                target: leftPointer.item
                property: "colorsReady"
                value: pointerSettings.colorsReady
            }
            Binding {
                target: rightPointer.item
                property: "colorsReady"
                value: pointerSettings.colorsReady
            }
            Binding {
                target: leftPointer.item
                property: "colorsPrompting"
                value: pointerSettings.colorsPrompting
            }
            Binding {
                target: rightPointer.item
                property: "colorsPrompting"
                value: pointerSettings.colorsPrompting
            }
            Binding {
                target: leftPointer.item
                property: "text"
                value: pointerSettings.textLeftPointer
            }
            Binding {
                target: rightPointer.item
                property: "text"
                value: pointerSettings.sameAsLeftPointer ? pointerSettings.textLeftPointer : pointerSettings.textRightPointer // "▶"
            }
            Binding {
                target: leftPointer.item
                property: "lineWidth"
                value: pointerSettings.arrowLineWidth
            }
            Binding {
                target: rightPointer.item
                property: "lineWidth"
                value: pointerSettings.arrowLineWidth
            }
            Binding {
                target: leftPointer.item
                property: "textVerticalOffset"
                value: readRegion.height * pointerSettings.textVerticalOffset / 2
            }
            Binding {
                target: rightPointer.item
                property: "textVerticalOffset"
                value: readRegion.height * pointerSettings.textVerticalOffset / 2
            }
            Binding {
                target: leftPointer.item
                property: "imageVerticalOffset"
                value: readRegion.height * pointerSettings.imageVerticalOffset / 2
            }
            Binding {
                target: rightPointer.item
                property: "imageVerticalOffset"
                value: readRegion.height * pointerSettings.imageVerticalOffset / 2
            }
            Binding {
                target: leftPointer.item
                property: "font.family"
                value: pointerSettings.textFont
            }
            Binding {
                target: rightPointer.item
                property: "font.family"
                value: pointerSettings.textFont
            }
            Binding {
                target: leftPointer.item
                property: "source"
                value: pointerSettings.imageLeftPath
            }
            Binding {
                target: rightPointer.item
                property: "source"
                value: pointerSettings.sameAsLeftPointer ? pointerSettings.imageLeftPath : pointerSettings.imageRightPath
            }
            Binding {
                target: leftPointer.item
                property: "tint"
                value: pointerSettings.tint
            }
            Binding {
                target: rightPointer.item
                property: "tint"
                value: pointerSettings.tint
            }
            Binding {
                target: rightPointer.item
                property: "transform"
                value: Scale {
                    xScale: pointerSettings.pointerKind === PointerSettings.States.Arrow || pointerSettings.sameAsLeftPointer ? -1 : 1
                    origin.x:  (rightPointer.item.width | rightPointer.item.contentWidth) / 2
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
