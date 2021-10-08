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

import QtQuick 2.12
import org.kde.kirigami 2.11 as Kirigami
import QtQuick.Controls 2.12
import QtQuick.Shapes 1.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import Qt.labs.settings 1.0

Item {
    id: countdown
    // Enums
    enum States {
        Standby,
        Ready,
        Running
    }
    readonly property alias configuration: configuration
    function requestPaint() {
        canvas.requestPaint()
    }
    enabled: false
    property bool frame: true
    property bool autoStart: false
    property bool running: false
    visible: false
    opacity: 0  // Initial opacity should be 0 to prevent animation jitters on first run.
    property int __iterations: 1
    property int __disappearWithin: 1
    readonly property real __vh: parent.height / 100
    readonly property real __vw: parent.width / 100
    readonly property real __minv: __vw<__vh ? __vw : __vh
    readonly property real __maxv: __vw>__vh ? __vw : __vh
    readonly property Scale __flips: Flip{}
    transform: __flips
    anchors {
        left: parent.left
        right: parent.right
        top: parent.top
        //bottom: parent.bottom
    }
    height: prompter.height

    Settings {
        category: "countdown"
        property alias enabled: countdown.enabled
        property alias frame: countdown.frame
        property alias autoStart: countdown.autoStart
        property alias iterations: countdown.__iterations
        property alias disappearWithin: countdown.__disappearWithin
    }

//     Behavior on opacity {
//         enabled: true
//         animation: NumberAnimation {
//             duration: Kirigami.Units.shortDuration
//             easing.type: Easing.OutQuad
//         }
//     }

    Rectangle {
        anchors.fill: parent
        opacity: canvas.enabled ? 0.48 : 0.24
        //opacity: 0.3
        color: "#333"
    }

    Canvas {
        id: canvas
        anchors.fill: parent

        property int __iteration: countdown.__iterations - 1
        property real rotations: 0
        // __countdownRadius is of the size from the center to any corner, which is also the hypotenuse formed by taking half of the width and height as hicks (catetos).
        readonly property real __hypotenuse: 1.4333*Math.sqrt(Math.pow(parent.height/2, 2)+Math.pow(parent.width/2, 2))

        renderStrategy: Canvas.Cooperative

        onRotationsChanged: requestPaint()
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        onPaint: {
            const centreX = prompter.editorXOffset*prompter.width+prompter.centreX;
            const centreY = prompter.centreY;
            // Initial canvas values
            const ctx = getContext("2d");
            ctx.reset();
            ctx.fillStyle = "rgba(127, 127, 127, 0.3)";
            ctx.lineWidth = 7 * (prompter.fontSize / 81);
            // Background Animation
            ctx.beginPath();
            ctx.moveTo(centreX, centreY);
            ctx.arc(centreX, centreY, __hypotenuse, -Math.PI/2, Math.PI*rotations-Math.PI/2, false);
            ctx.lineTo(centreX, centreY);
            ctx.fill();
            // Vertical Line
            ctx.lineCap = 'butt';
            ctx.strokeStyle = "#474747";
            //ctx.setLineDash([1]);
            ctx.beginPath();
            ctx.moveTo(centreX, 0);
            ctx.lineTo(centreX, height);
            ctx.stroke();
            // Horizontal Line
            //ctx.setLineDash([]);  // Has no effect. Likely a bug in Qt 5's canvas implementation.
            ctx.beginPath();
            ctx.strokeStyle = "#282828";
            ctx.moveTo(0, overlay.__readRegionPlacement*(height-overlay.readRegionHeight)+overlay.readRegionHeight/2);
            ctx.lineTo(width, overlay.__readRegionPlacement*(height-overlay.readRegionHeight)+overlay.readRegionHeight/2);
            ctx.stroke();
            if (canvas.enabled) {
                // Background Radial Line
                ctx.strokeStyle = "#333";
                ctx.lineCap = 'round';
                ctx.beginPath();
                ctx.arc(centreX, centreY, __hypotenuse+ctx.lineWidth, -Math.PI/2, Math.PI*rotations-Math.PI/2, false);
                ctx.lineTo(centreX, centreY);
                ctx.stroke();
                // Concentric circles
                ctx.strokeStyle = "#FFF";
                // Outer circle
                ctx.beginPath();
                ctx.arc(centreX, centreY, 84*__minv/2, 0, 2*Math.PI, false);
                ctx.stroke();
                // Inner circle
                ctx.beginPath();
                ctx.arc(centreX, centreY, 74*__minv/2, 0, 2*Math.PI, false);
                ctx.stroke();
            }
        }

        NumberAnimation {
            id: countdownAnimation
            running: countdown.running
            target: canvas
            property: "rotations"
            from: 0
            to: 2
            duration: 1000
            // Uncomment loops to debug animation
            //loops: Animation.Infinite
            easing.type: Easing.Linear
            alwaysRunToEnd: true
            onStarted: {
                console.log("onStartedRan")
                console.log(canvas.__iteration)
                console.log(countdown.__disappearWithin-1)
                if (canvas.__iteration===countdown.__disappearWithin-1) {
                    console.log("dissolveOut.running")
                    dissolveOut.running = true
                }
            }
            onFinished: {
                if (countdown.running && canvas.__iteration>0) {
                    canvas.__iteration--;
                    console.log("onFinished");
                    console.log(canvas.__iteration);
                    running = true;
                } else {
                    state: "ready"
                    canvas.__iteration = countdown.__iterations;
                    prompter.state++; // = Prompter.States.Prompting;
                    //countdown.visible = false
                    //showPassiveNotification(i18n("Prompting Started"));
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

    Label {
        visible: countdown.enabled
//         anchors.fill: parent
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        text: String(canvas.__iteration+1)
        x: editor.x + prompter.editorXOffset*prompter.width // +prompter.centreX // -font.pixelSize/4
        width: editor.width
        //leftMargin: prompter.editorXOffset*prompter.width+prompter.centreX
        //anchors.leftMargin: prompter.editorXOffset*prompter.width+prompter.centreX
        //anchors.rightMargin: prompter.editorXOffset*prompter.width+prompter.centreX
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: "#FFF"
        // Make base font size relative to editor's width
        font.pixelSize: canvas.__iteration > 98 ? 48*__minv : canvas.__iteration > 8 ? 54*__minv : 68*__minv
        font.family: numbersFont.name
        renderType: font.pixelSize < 121 || screen.devicePixelRatio !== 1.0 || root.forceQtTextRenderer ? Text.QtRendering : Text.NativeRendering
        FontLoader {
            id: numbersFont
            source: i18n("fonts/libertinus-sans.otf")
        }
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
            target: canvas
            //__iteration: 0
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
            target: canvas
            //__iteration: 0
            __iteration: countdown.__iterations - 1
        }
        StateChangeScript {
            name: "paintReady"
            script: {
                canvas.requestPaint()
            }
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
            target: canvas
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
            running: false
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
    
    Kirigami.OverlaySheet {
        id: configuration
        onSheetOpenChanged: prompterPage.actions.main.checked = sheetOpen
        
        background: Rectangle {
            //color: Kirigami.Theme.activeBackgroundColor
            color: appTheme.__backgroundColor
            anchors.fill: parent
        }
        header: Kirigami.Heading {
            text: i18n("Countdown Setup")
            level: 1
        }
        
        RowLayout {
            width: parent.width
            
            ColumnLayout {
                Label {
                    text: i18n("Countdown iterations")
                }
                SpinBox {
                    Layout.fillWidth: true
                    Layout.leftMargin: Kirigami.Units.smallSpacing
                    Layout.rightMargin: Kirigami.Units.smallSpacing
                    value: __iterations
                    from: 1
                    to: 300  // 5*60
                    onValueModified: {
                        focus: true
                        __iterations = value
                        if (__disappearWithin && __disappearWithin >= __iterations)
                            __disappearWithin = __iterations
                    }
                }
            }
            ColumnLayout {
                Label {
                    text: i18np("Disappear within 1 second to go",
                                "Disappear within %1 seconds to go", __disappearWithin);
                }
                SpinBox {
                    Layout.fillWidth: true
                    Layout.leftMargin: Kirigami.Units.smallSpacing
                    Layout.rightMargin: Kirigami.Units.smallSpacing
                    value: __disappearWithin
                    from: 1
                    to: 10
                    onValueModified: {
                        focus: true
                        __disappearWithin = value
                        if (__iterations <= __disappearWithin)
                            __iterations = __disappearWithin
                    }
                }
            }
        }
    }
}
