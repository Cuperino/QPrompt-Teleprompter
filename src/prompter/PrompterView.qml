/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2020-2025 Javier O. Cordero Pérez
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
import QtQuick.Window 2.12
import QtQml.Models 2.12
import QtQuick.Controls 2.12
import QtCore 6.5

import com.cuperino.qprompt 1.0

Item {
    id: viewport

    property alias prompter: prompter
    property alias editor: prompter.editor
    property alias document: prompter.document
    property alias openDialog: prompter.openDialog
    property alias countdown: countdown
    property alias overlay: overlay
    property alias prompterBackground: prompterBackground
    property alias timer: timer
    property alias find: find
    property alias mouse: mouse
    //property bool project: true
    property int forcedOrientation: 0
    property real __baseSpeed: editorToolbar.baseSpeedSlider.value
    property real __curvature: editorToolbar.baseAccelerationSlider.value
    readonly property bool showingControls: root.__isMobile || root.visibility===ApplicationWindow.FullScreen || (overlay.atTop && parseInt(prompter.state)!==Prompter.States.Editing)
    readonly property bool noDistractingAnimation: parseInt(prompter.state)===Prompter.States.Editing || parseInt(prompter.state)===Prompter.States.Standby

    transform: Rotation {
        origin.x: (forcedOrientation && forcedOrientation!==3 ? parent.height/2 : parent.width*0.15);
        origin.y: (forcedOrientation && forcedOrientation!==3 ? parent.width/2 : parent.height);
        axis { x: root.theforce?1:0; y: 0; z: 0 }
        angle: 77
    }

    Find {
        id: find
        document: prompter.document
        z: 6
    }

    Column {
        id: upperControls
        z: 6
        padding: 8
        spacing: 8
        visible: anchors.leftMargin > -upperControls.width
        opacity: switch(parseInt(prompter.state)) {
                case 2: // Countdown
                    return 0.4;
                case 3: // Prompting
                    return 0.1;
                default:
                    return 1;
                }
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: viewport.showingControls ? 0 : -upperControls.width
        Behavior on opacity {
            enabled: parent.visible
            animation: OpacityAnimator {
                duration: Units.ShortDuration
                easing.type: Easing.EaseOut
            }
        }
        Behavior on anchors.leftMargin {
            enabled: viewport.noDistractingAnimation
            animation: NumberAnimation {
                duration: Units.ShortDuration
                easing.type: Easing.EaseOut
            }
        }
        Button {
            enabled: parseInt(prompter.state)!==Prompter.States.Editing
            opacity: enabled ? 1 : 0
            width: 64
            height: 64
            // flat: parseInt(prompter.state)===Prompter.States.Prompting
            icon.source: Qt.application.layoutDirection === Qt.LeftToRight ? "../icons/edit-undo.svg" : "../icons/edit-redo.svg"
            Material.theme: Material.Dark
            onClicked: prompter.cancel()
            Behavior on opacity {
                enabled: upperControls.visible
                animation: OpacityAnimator {
                    duration: Units.ShortDuration
                    easing.type: Easing.EaseOut
                }
            }
        }
    }

    Row {
        id: bottomControls
        z: 6
        spacing: 8
        visible: anchors.bottomMargin > -height
        opacity: if (!root.__isMobile)
                    switch(parseInt(prompter.state)) {
                    case 2: // Countdown
                        return 0.4;
                    case 3: // Prompting
                        return 0.2;
                    default:
                        return 1;
                    }
                else
                     return 1;
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: viewport.showingControls ? 0 : -height
        Behavior on opacity {
            enabled: parent.visible
            animation: OpacityAnimator {
                duration: Units.ShortDuration
                easing.type: Easing.EaseOut
            }
        }
        Behavior on anchors.bottomMargin {
            enabled: viewport.noDistractingAnimation
            animation: NumberAnimation {
                duration: Units.ShortDuration
                easing.type: Easing.EaseOut
            }
        }
        Button {
            enabled: parseInt(prompter.state)===Prompter.States.Prompting
            opacity: enabled ? 1 : 0.2
            width: 64
            height: 64
            anchors.bottom: parent.bottom
            icon.source: Qt.application.layoutDirection === Qt.RightToLeft ? "../icons/go-next.svg" : "../icons/go-previous.svg"
            Material.theme: Material.Dark
            onClicked: prompter.decreaseVelocity(false)
            Behavior on opacity {
                enabled: bottomControls.visible
                animation: OpacityAnimator {
                    duration: Units.ShortDuration
                    easing.type: Easing.EaseOut
                }
            }
        }
        Button {
            width: 82
            height: 82
            anchors.bottom: parent.bottom
            icon.source: parseInt(prompter.state)===Prompter.States.Prompting ? (prompter.__play ? "../icons/media-playback-pause.svg" : "../icons/media-playback-start.svg") :
                                                                                Qt.application.layoutDirection === Qt.RightToLeft ? "../icons/go-previous.svg" : "../icons/go-next.svg"
            Material.theme: Material.Dark
            onClicked:
                if (parseInt(prompter.state)===Prompter.States.Prompting)
                    prompter.pause();
                else
                    prompter.toggle();
        }
        Button {
            enabled: parseInt(prompter.state)===Prompter.States.Prompting
            opacity: enabled ? 1 : 0.2
            width: 64
            height: 64
            anchors.bottom: parent.bottom
            icon.source: Qt.application.layoutDirection === Qt.RightToLeft ? "../icons/go-previous.svg" : "../icons/go-next.svg"
            Material.theme: Material.Dark
            onClicked: prompter.increaseVelocity(false)
            Behavior on opacity {
                enabled: bottomControls.visible
                animation: OpacityAnimator {
                    duration: Units.ShortDuration
                    easing.type: Easing.EaseOut
                }
            }
        }
    }

    Rectangle {
        visible: root.theforce
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: parent.height>>1
        z: 5
        gradient: Gradient {
            GradientStop { position: 0.0; color: appTheme.__backgroundColor }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }

    Countdown {
        id: countdown
        z: 4
        anchors.fill: parent
    }

    TimerClock {
       id: timer
       z: 3
       anchors.fill: parent
    }

    ReadRegionOverlay {
        id: overlay
        z: 2
        anchors.fill: parent
    }

    ShaderEffectSource {
        id: prompterShadowSource
        sourceItem: prompter
    }

    Prompter {
        id: prompter
        property double delta: 16
        anchors.fill: parent
        z: 1
        textColor: colorDialog.acceptedColor
        textBackground: highlightDialog.acceptedColor
        fontSize: (parseInt(prompter.state)===Prompter.States.Editing && !prompter.wysiwyg) ? (Math.pow(editorToolbar.fontSizeSlider.value/185,4)*185) : (Math.pow(editorToolbar.fontWYSIWYGSizeSlider.value/185,4)*185)*prompter.__vw/10
        // fontSize: (parseInt(prompter.state)===Prompter.States.Editing && !prompter.wysiwyg) ? (Math.pow(editorToolbar.fontSizeSlider.value/185,4)*185) : (Math.pow(editorToolbar.fontWYSIWYGSizeSlider.value/185,4)*185)*prompter.__vw/10
        letterSpacing: fontSize * editorToolbar.letterSpacingSlider.value / 81
        wordSpacing: fontSize * editorToolbar.wordSpacingSlider.value / 81
        //Math.pow((fontSizeSlider.value*prompter.__vw),3)
    }

    MouseArea {
        id: mouse
        // Mouse wheel controls
        property int throttledIteration: 0
        //propagateComposedEvents: false
        z: 0
        acceptedButtons: Qt.NoButton
        //hoverEnabled: true
        //scrollGestureEnabled: true//Qt.platform.os==="osx"
        // The following placement allows covering beyond the boundaries of the editor and into the prompter's margins.
        anchors.fill: parent
//        anchors.left: parent.left
//        anchors.right: parent.right
//        y: -prompter.height
//        height: parent.height+2*prompter.height
        cursorShape: Qt.CrossCursor
        onWheel: (wheel) => {
            scroll(wheel);
        }
        function scroll(wheel: var): void {
            if (prompter.__noScroll && parseInt(prompter.state)===Prompter.States.Prompting)
                return;
            else if (parseInt(prompter.state)===Prompter.States.Prompting && (prompter.__scrollAsDial && !(wheel.modifiers & Qt.ControlModifier || wheel.modifiers & Qt.MetaModifier) || !prompter.__scrollAsDial && (wheel.modifiers & Qt.ControlModifier || wheel.modifiers & Qt.MetaModifier))) {
                if (!(prompter.throttleWheel && throttledIteration)) {
                    if (wheel.angleDelta.y > 0) {
                        if (prompter.__invertScrollDirection)
                            prompter.increaseVelocity(wheel);
                        else/* if (prompter.__i>1)*/ {
                            if (!toolbar.onlyPositiveVelocity || prompter.__i>0)
                                prompter.decreaseVelocity(wheel);
                        }
                    }
                    else if (wheel.angleDelta.y < 0) {
                        if (prompter.__invertScrollDirection/* && prompter.__i>1*/) {
                            if (!toolbar.onlyPositiveVelocity || prompter.__i>0)
                                prompter.decreaseVelocity(wheel);
                        }
                        else
                            prompter.increaseVelocity(wheel);
                    }
                    // Do nothing if wheel.angleDelta.y === 0
                }
                throttledIteration = (throttledIteration+1)%prompter.wheelThrottleFactor
            }
            else {
                // Regular scroll
                const delta = (prompter.__invertScrollDirection?-1:1)*wheel.angleDelta.y/2;
                var i=prompter.__i;
                prompter.__i=0;
                if (prompter.position-delta >= -prompter.topMargin && prompter.position-delta<=editor.implicitHeight-(overlay.height-prompter.bottomMargin))
                    prompter.position -= delta;
                // If scroll were to go out of bounds, cap it
                else if (prompter.position-delta > -prompter.topMargin)
                    prompter.position = editor.implicitHeight-(overlay.height-prompter.bottomMargin)
                else
                    prompter.position = -prompter.topMargin
                prompter.__i=i;
                // Resume prompting
                if (parseInt(prompter.state)===Prompter.States.Prompting && prompter.__play)
                    prompter.position = prompter.__destination
            }
        }
    }

    //FastBlur {
    //anchors.fill: prompter
    //source: prompter
    //radius: 32
    //radius: 0
    //}

    PrompterBackground {
        id: prompterBackground
        z: 0
    }

    Settings {
        category: "orientation"
        property alias orientation: viewport.forcedOrientation
    }
}
