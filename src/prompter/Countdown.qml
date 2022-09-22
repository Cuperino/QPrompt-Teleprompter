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
import QtQuick.Controls 2.12
import QtQuick.Shapes 1.12
import QtQuick.Layouts 1.12
import Qt.labs.settings 1.0

Item {
    id: countdown
    enum States {
        Standby,
        Ready,
        Running
    }
//    readonly property alias configuration: prompterPage.configuration
    readonly property real __vh: parent.height / 100
    readonly property real __vw: parent.width / 100
    readonly property real __minv: __vw<__vh ? __vw : __vh
    readonly property real __maxv: __vw>__vh ? __vw : __vh
    readonly property int offsetCentre: prompter.editorXOffset*prompter.width+prompter.centreX
    readonly property Scale __flips: Flip{}
    property bool frame: true
    property bool autoStart: false
    property bool running: false
    property int __iterations: 1
    property int __disappearWithin: 1
    enabled: false
    visible: false
    opacity: 0  // Initial opacity should be 0 to prevent animation jitters on first run.
    transform: __flips
    anchors.fill: parent
//    anchors {
//        left: parent.left
//        right: parent.right
//        top: parent.top
//        //bottom: parent.bottom
//    }
//    height: prompter.height
    Settings {
        category: "countdown"
        property alias enabled: countdown.enabled
        property alias frame: countdown.frame
        property alias autoStart: countdown.autoStart
        property alias iterations: countdown.__iterations
        property alias disappearWithin: countdown.__disappearWithin
    }
    Rectangle {
        anchors.fill: parent
        visible: countdown.enabled
        opacity: clock.enabled ? 0.48 : 0.24
        color: "#333"
        Shape {
            id: clock
            anchors.fill: parent

            property int __iteration: countdown.__iterations - 1
            property real rotations: 0
            // __countdownRadius is of the size from the center to any corner, which is also the hypotenuse formed by taking half of the width and height as hicks (catetos).
            readonly property real __hypotenuse: 1.4333*Math.sqrt(Math.pow(prompter.centreY, 2)+Math.pow(prompter.centreX, 2))
            asynchronous: true

            ShapePath {
                fillColor: "#888888";
                strokeColor: "#333";
                strokeWidth: 7 * (prompter.fontSize / 81);
                startX: offsetCentre;
                startY: prompter.centreY
                PathAngleArc {
                    centerX: offsetCentre;
                    centerY: prompter.centreY;
                    radiusX: clock.__hypotenuse;
                    radiusY: -clock.__hypotenuse;
                    startAngle: 90.0
                    sweepAngle: -clock.rotations*180
                    moveToStart: false
                }
            }
            NumberAnimation {
                id: countdownAnimation
                running: countdown.running
                target: clock
                property: "rotations"
                from: 0
                to: 2
                duration: 1000
                // Uncomment loops to debug animation
                //loops: Animation.Infinite
                easing.type: Easing.Linear
                alwaysRunToEnd: true
                onStarted: {
                    if (clock.__iteration===countdown.__disappearWithin-1)
                        dissolveOut.running = true
                }
                onFinished: {
                    if (countdown.running && clock.__iteration>0) {
                        clock.__iteration--;
                        //console.log("onFinished");
                        //console.log(clock.__iteration);
                        running = true;
                    } else {
                        clock.__iteration = countdown.__iterations;
                        if (parseInt(prompter.state)===Prompter.States.Countdown)
                            prompter.state++;
                    }
                }
            }
            NumberAnimation {
                id: dissolveIn
                running: false
                target: countdown
                property: "opacity"
                from: 0
                to: 1
                duration: 200
                alwaysRunToEnd: false
                easing.type: Easing.OutQuint
            }
            NumberAnimation {
                id: dissolveOut
                running: false
                target: countdown
                property: "opacity"
                from: 1
                to: 0
                duration: 1000
                alwaysRunToEnd: true
                easing.type: Easing.InQuint
            }
        }
    }
    Shape {
        id: frame
        anchors.fill: parent
        // Vertical line
        ShapePath {
            strokeColor: "#474747";
            strokeWidth: 7 * (prompter.fontSize / 81);
            fillColor: "transparent";
            startX: offsetCentre;
            startY: 0
            PathLine {
                relativeX: 0;
                y: prompter.height
            }
        }
        // Horizontal line
        ShapePath {
            strokeColor: "#282828";
            strokeWidth: 7 * (prompter.fontSize / 81);
            fillColor: "transparent";
            startX: 0
            startY: overlay.__readRegionPlacement*(height-overlay.readRegionHeight)+overlay.readRegionHeight/2
            PathLine {
                x: prompter.width
                relativeY: 0;
            }
        }
    }
    Label {
        visible: countdown.enabled
//         anchors.fill: parent
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        //anchors.leftMargin: offsetCentre
        //anchors.rightMargin: offsetCentre
        //leftMargin: offsetCentre
        width: editor.width
        x: editor.x + prompter.editorXOffset*prompter.width // +prompter.centreX // -font.pixelSize/4
        text: String(clock.__iteration+1)
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: "#FFF"
        // Make base font size relative to editor's width
        font.pixelSize: clock.__iteration > 98 ? 48*__minv : clock.__iteration > 8 ? 54*__minv : 68*__minv
        font.family: numbersFont.name
        renderType: font.pixelSize < 121 || screen.devicePixelRatio !== 1.0 || root.forceQtTextRenderer ? Text.QtRendering : Text.NativeRendering
        FontLoader {
            id: numbersFont
            source: "fonts/libertinus-sans.otf"
        }
    }
    Shape {
        visible: countdown.enabled
        anchors.fill: parent
        ShapePath {
            strokeColor: "#FFF";
            strokeWidth: 4 * (prompter.fontSize / 81);
            fillColor: "transparent";
            startX: offsetCentre + 74*__minv/2;
            startY: prompter.centreY;
            PathAngleArc {
                centerX: offsetCentre;
                centerY: prompter.centreY;
                radiusX: 74*__minv/2;
                radiusY: -radiusX;
                startAngle: 0.0
                sweepAngle: 360.0
                moveToStart: false
            }
            PathMove {
                x: offsetCentre + 84*__minv/2;
                y: prompter.centreY;
            }
            PathAngleArc {
                centerX: offsetCentre;
                centerY: prompter.centreY;
                radiusX: 84*__minv/2;
                radiusY: -radiusX;
                startAngle: 0.0
                sweepAngle: 360.0
                moveToStart: false
            }
        }
    }
    MouseArea {
        anchors.fill: parent
        enabled: parseInt(prompter.state) === Prompter.States.Countdown || parseInt(prompter.state) === Prompter.States.Standby
        onClicked: prompter.toggle()
    }

    states: [
    State {
        name: Countdown.States.Standby
        PropertyChanges {
            target: countdown
            running: false
            visible: false
            opacity: 0
        }
        PropertyChanges {
            target: dissolveOut
            running: false
        }
        PropertyChanges {
            target: clock
            __iteration: countdown.__iterations - 1
        }
    },
    State {
        name: Countdown.States.Ready
        PropertyChanges {
            target: countdown
            running: false
            visible: true
            opacity: 1
        }
        PropertyChanges {
            target: dissolveIn
            running: true
        }
        PropertyChanges {
            target: dissolveOut
            running: false
        }
        PropertyChanges {
            target: clock
            __iteration: countdown.__iterations - 1
        }
    },
    State {
        name: Countdown.States.Running
        PropertyChanges {
            target: dissolveIn
            running: true
        }
        PropertyChanges {
            target: countdownAnimation
            running: true
        }
        PropertyChanges {
            target: clock
            __iteration: countdown.__iterations - 1
        }
        PropertyChanges {
            target: countdown
            running: countdown.__iterations>0
            visible: countdown.__iterations>0
            opacity: 1
        }
        PropertyChanges {
            target: dissolveOut
            running: countdown.__iterations===countdown.__disappearWithin
        }
    }
    ]
    state: Countdown.States.Standby
    transitions: [
    Transition {
        from: Countdown.States.Standby
        to: Countdown.States.Ready
        SequentialAnimation {
            ScriptAction { scriptName: "paintReady" }
        }
    }
    ]
}
