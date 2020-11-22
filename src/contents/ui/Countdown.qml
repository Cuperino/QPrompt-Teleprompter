/****************************************************************************
 * *
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

Rectangle {
    id: countdown
    anchors.fill: parent
    readonly property real __vh: parent.height / 100
    readonly property real __vw: parent.width / 100
    readonly property real __minv: __vw<__vh ? __vw : __vh
    readonly property real __maxv: __vw>__vh ? __vw : __vh
    // __countdownRadius is of the size from the center to any corner, which is also the hypotenuse formed by taking half of the width and height as hicks (catetos).
    readonly property real __countdownRadius: Math.sqrt(Math.pow(parent.height/2, 2)+Math.pow(parent.width/2, 2))
    
    color: "#999999"
    property color __destinationColor: "#222222"
    //opacity: 0.75
    
    Canvas {
        id: canvas
        anchors.fill: parent
        
        property real progress: 0
        
        onProgressChanged: requestPaint()
        
        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            
            const centreX = width / 2;
            const centreY = height / 2;
            
            ctx.beginPath();
            ctx.fillStyle = "#FFF";
            ctx.strokeStyle = "#000";
            ctx.lineWidth = 4;
            //ctx.fillStyle = countdown.__destinationColor;
            ctx.moveTo(centreX, centreY);
            ctx.arc(centreX, centreY, __countdownRadius, -Math.PI/2, 2*Math.PI*progress-Math.PI/2, false);
            ctx.lineTo(centreX, centreY);
            ctx.fill();
        }
        
        NumberAnimation on progress {
            from: 0;
            to: 1;
            duration: 1000;
            easing.type: Easing.Linear
            alwaysRunToEnd: true
            loops: Animation.Infinite
            //loops: 3
            
            onFinished: {
                showPassiveNotification(i18n("Animation Completed"));
            }
        }
    }
}
