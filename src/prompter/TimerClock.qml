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

import com.cuperino.qprompt.promptertimer 1.0

Item {
    id: timer
    property bool stopwatch: false
    property bool eta: false
    property real size: 1
    enabled: stopwatch || eta
    visible: enabled
    clip: true
    readonly property real centreX: prompter.centreX;
    readonly property real centreY: prompter.centreY;
    anchors {
        left: parent.left
        right: parent.right
        top: parent.top
    }
    height: prompter.height
    
    readonly property Scale __flips: Flip{}
    transform: __flips
    
    FontLoader {
        id: monoSpacedFont
        name: "Monospace"
    }
    Item {
        id: stopwatch
        readonly property real centreX: width / 2;
        readonly property real centreY: height / 2;
        readonly property int marginX: 4 * timer.size * prompter.__vw
        readonly property int marginY: 2 * timer.size * prompter.__vw
        readonly property real fontSize: timer.size * prompter.__vw << 3
        x: timer.centreX - centreX
        y: timer.height - height - centreY / 2
        width: promptTime.implicitWidth
        height: (promptTime.visible ? promptTime.implicitHeight : 0) + (etaTimer.visible ? etaTimer.implicitHeight : 0)
        Rectangle {
            id: background
            anchors.fill: parent
            opacity: 0.92
            color: "#131619"
            radius: stopwatch.fontSize
        }
        Label {
            id: promptTime
            visible: timer.stopwatch
            text: i18n("SW") + " " + "00:00:00"
            anchors.top: parent.top
            font.family: monoSpacedFont.name
            font.pixelSize: stopwatch.fontSize
            leftPadding: stopwatch.marginX
            rightPadding: stopwatch.marginX
            topPadding: stopwatch.marginY
            bottomPadding: etaTimer.visible ? 0 : stopwatch.marginY
        }
        Label {
            id: etaTimer
            visible: timer.eta
            text: i18n("ET") + " " + "00:00:00"
            // anchors.top: promptTime.visible ? promptTime.bottom : parent.top
            anchors.bottom: parent.bottom
            font.family: monoSpacedFont.name
            font.pixelSize: stopwatch.fontSize
            leftPadding: stopwatch.marginX
            rightPadding: stopwatch.marginX
            topPadding: promptTime.visible ? 0 : stopwatch.marginY
            bottomPadding: stopwatch.marginY
        }
        MouseArea {
            id: timerDrag
            readonly property int marginY: 3 * timer.size * prompter.__vw
            anchors.fill: parent
            scrollGestureEnabled: false
            acceptedButtons: Qt.LeftButton
            propagateComposedEvents: true
            hoverEnabled: false
            drag.target: parent
            drag.smoothed: false
            drag.minimumX: parent.parent.x-stopwatch.marginX
            drag.maximumX: parent.parent.width-this.width+stopwatch.marginX
            drag.minimumY: parent.parent.y-this.marginY
            drag.maximumY: parent.parent.height-this.height+this.marginY
            cursorShape: (pressed||drag.active||prompter.dragging) ? Qt.ClosedHandCursor : Qt.PointingHandCursor
        }
    }
    
    // This timer implementation is incorrect but it will suffice for now. Results aren't wrong, but they can become so after long periods of time if CPU performance is low, as this does not measure elapsed time but time deltas.
    Timer {
        property int elapsedSeconds: 0 // 3599*100
        interval: 1000; running: true; repeat: true
        onTriggered: {
            ++elapsedSeconds;
            let seconds = elapsedSeconds % 60 / 100;
            let minutes = Math.floor((elapsedSeconds / 60) % 60) / 100;
            let hours = Math.floor((elapsedSeconds / 3600) % 100) / 100;
            promptTime.text = i18n("SW") + " " + (hours).toFixed(2).toString().slice(2)+":"+(minutes).toFixed(2).toString().slice(2)+":"+(seconds).toFixed(2).toString().slice(2);
        }
    }
}
