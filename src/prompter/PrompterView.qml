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
import QtQuick.Window 2.12
import QtQml.Models 2.12
import Qt.labs.settings 1.0
//import QtGraphicalEffects 1.15

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

    //layer.enabled: true
    // Undersample
    //layer.mipmap: true
    // Oversample
    //layer.samples: 2
    //layer.smooth: true
    // Make texture the size of the largest destinations.
    //layer.textureSize: Qt.size(projectionWindow.width, projectionWindow.height)

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

    Prompter {
        id: prompter
        property double delta: 16
        anchors.fill: parent
        z: 1
        textColor: colorDialog.color
        textBackground: highlightDialog.color
        //fontSize: (parseInt(prompter.state)===Prompter.States.Editing && !prompter.__wysiwyg) ? (Math.pow(editorToolbar.fontSizeSlider.value/185,4)*185) : (Math.pow(editorToolbar.fontWYSIWYGSizeSlider.value/185,4)*185)*prompter.__vw/10
        fontSize: (!prompter.__wysiwyg) ? (Math.pow(editorToolbar.fontSizeSlider.value/185,4)*185) : (Math.pow(editorToolbar.fontWYSIWYGSizeSlider.value/185,4)*185)*prompter.__vw/10
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
        onWheel: (wheel)=> {
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
