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
import QtQuick.Controls 2.15
import QtQuick.Shapes 1.15

Item {
    id: countdown
    property bool running: false
    visible: false
    property int __iterations: 1
    property int  __disappearWithin: 1
    readonly property real __vh: parent.height / 100
    readonly property real __vw: parent.width / 100
    readonly property real __minv: __vw<__vh ? __vw : __vh
    readonly property real __maxv: __vw>__vh ? __vw : __vh
    anchors {
        left: parent.left
        right: parent.right
        top: parent.top
        //bottom: parent.bottom
    }
    height: prompter.height
    
    Rectangle {
        anchors.fill: parent
        opacity: 0.78
        color: "#333"
    }
    
    Canvas {
        id: canvas
        anchors.fill: parent
        
        property int __iteration: __iterations - 1
        property real rotations: 0
        // __countdownRadius is of the size from the center to any corner, which is also the hypotenuse formed by taking half of the width and height as hicks (catetos).
        readonly property real __hypotenuse: Math.sqrt(Math.pow(parent.height/2, 2)+Math.pow(parent.width/2, 2))
        
        onRotationsChanged: requestPaint()
        
        onPaint: {
            const centreX = prompter.centreX;
            const centreY = prompter.centreY;
            // Initial canvas values
            const ctx = getContext("2d");
            ctx.reset();
            ctx.fillStyle = "rgba(127, 127, 127, 0.3)";
            ctx.lineWidth = 6;
            // Background Animation
            ctx.beginPath();
            ctx.moveTo(centreX, centreY);
            ctx.arc(centreX, centreY, __hypotenuse, -Math.PI/2, Math.PI*rotations-Math.PI/2, false);
            ctx.lineTo(centreX, centreY);
            ctx.fill();
            // Horizontal Line
            ctx.lineCap = 'butt';
            ctx.strokeStyle = "#282828";
            ctx.beginPath();
            ctx.moveTo(centreX, 0);
            ctx.lineTo(centreX, height);
            ctx.stroke();
            // Vertical Line
            ctx.beginPath();
            ctx.moveTo(0, centreY);
            ctx.lineTo(width, centreY);
            ctx.stroke();
            // Background Radial Line
            ctx.strokeStyle = "#000";
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
        
        NumberAnimation {
            id: countdownAnimation
            running: countdown.running
            target: canvas
            property: "rotations"
            from: 0;
            to: 2;
            duration: 1000;
            // Uncomment loops to debug animation
            //loops: Animation.Infinite
            easing.type: Easing.Linear
            alwaysRunToEnd: true
            onStarted: {
                if (canvas.__iteration===countdown.__disappearWithin) {
                    dissolveOut.running = true
                }
            }
            onFinished: {
                if (countdown.running && canvas.__iteration>0) {
                    canvas.__iteration--;
                    console.log(canvas.__iteration);
                    running = true;
                } else {
                    state: "ready"
                    canvas.__iteration = countdown.__iterations;
                    prompter.state = "prompting"
                    //untdown.visible = false
                    //owPassiveNotification(i18n("Prompting Started"));
                }
            }
        }
        
        NumberAnimation {
            id: dissolveOut
            running: false
            target: countdown
            property: "opacity"
            from: 1
            to: 0
            duration: 1000
            easing.type: Easing.InQuint
        }
    }
    
    Label {
        anchors.fill: parent
        text: String(canvas.__iteration+1)
        font.pixelSize: 42*__minv
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: "#FFF"
    }
    
    states: [
    State {
        name: "ready"
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
            __iteration: 0
        }
    },
    State {
        name: "running"
        PropertyChanges {
            target: countdownAnimation
            running: true
        }
        PropertyChanges {
            target: canvas
            __iteration: countdown.__iterations - 1
//             __iteration: 2
        }
        PropertyChanges {
            target: countdown
            running: countdown.__iterations>0
            visible: countdown.__iterations>0
            opacity: countdown.__iterations>0
//             __iteration: countdown.__iterations - 1
        }
        PropertyChanges {
            target: dissolveOut
            running: false
        }
    }
    ]
    state: "ready"
}
