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
import QtQuick.Controls 2.12
import QtQuick.Shapes 1.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.2
import Qt.labs.settings 1.0

//import com.cuperino.qprompt.promptertimer 1.0

Item {
    id: clock
    property alias running: timer.running
    property alias elapsedSeconds: timer.elapsedSeconds
//     property alias timeToArival: prompter.__timeToArival
    property bool stopwatch: false
    property bool eta: false
    property real size: 0.5
    property alias textColor: timerSettings.color
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

    Settings {
        id: timerSettings
        category: "timer"
        property alias stopwatch: clock.stopwatch
        property alias eta: clock.eta
        property color color: timerColorDialog.currentColor
    }

    FontLoader {
        id: monoSpacedFont
        name: "Monospace"
    }
    Item {
        id: stopwatch
        readonly property real centreX: width / 2;
        readonly property real centreY: height / 2;
        readonly property int marginX: 4 * clock.size * prompter.__vw
        readonly property int marginY: 2 * clock.size * prompter.__vw
        readonly property real fontSize: clock.size * prompter.__vw << 3
        x: clock.centreX - centreX
        y: overlay.__readRegionPlacement < 0.5 ? clock.height - height - centreY / 2 : centreY / 2
        width: clockGrid.implicitWidth
        height: clockGrid.implicitHeight
        Rectangle {
            id: background
            anchors.fill: parent
            opacity: 0.92
            color: "#131619"
            radius: stopwatch.fontSize
        }
        GridLayout {
            id: clockGrid
            rows: 1
            columns: 2
            Label {
                id: promptTime
                visible: clock.stopwatch
                text: /*i18n("SW") + " " +*/ "00:00:00"
                //anchors.top: parent.top
                font.family: monoSpacedFont.name
                font.pixelSize: stopwatch.fontSize
                color: clock.textColor
                leftPadding: stopwatch.marginX
                rightPadding: stopwatch.marginX
                topPadding: stopwatch.marginY
                bottomPadding: stopwatch.marginY
            }
            Label {
                id: etaTimer
                visible: clock.eta
                text: /*i18n("ET") + " " +*/ "00:00:00"
                // anchors.top: promptTime.visible ? promptTime.bottom : parent.top
                //anchors.bottom: parent.bottom
                font.family: monoSpacedFont.name
                font.pixelSize: stopwatch.fontSize
                color: clock.textColor
                leftPadding: stopwatch.marginX
                rightPadding: stopwatch.marginX
                topPadding: stopwatch.marginY
                bottomPadding: stopwatch.marginY
            }
        }
        MouseArea {
            id: timerDrag
            readonly property int marginY: 3 * clock.size * prompter.__vw
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
            onDoubleClicked: clock.reset()
        }
    }
    // This timer implementation is incorrect but it will suffice for now. Results aren't wrong, but they can become so after long periods of time if CPU performance is low, as this does not measure elapsed time but time deltas.
    Timer {
        repeat: true
        running: clock.eta
        triggeredOnStart: true
        interval: 120;
        onTriggered: {
            updateETAText();
        }
    }
    Timer {
        id: timer
        property int elapsedSeconds: 0 // 3599*100
        repeat: true
        running: false
        triggeredOnStart: false
        interval: 1000;
        onTriggered: {
            ++elapsedSeconds;
            parent.updateStopwatchText();
        }
        function getTimeString(timeInSeconds) {
            const digitalSeconds = Math.ceil(timeInSeconds) % 60 / 100;
            const minutes = (timeInSeconds+1) / 60
            const digitalMinutes = Math.floor(minutes % 60) / 100;
            const digitalHours = Math.floor((minutes / 60) % 100) / 100;
            return (digitalHours).toFixed(2).toString().slice(2)+":"+(digitalMinutes).toFixed(2).toString().slice(2)+":"+(digitalSeconds).toFixed(2).toString().slice(2);
        }
    }
    function updateStopwatchText() {
        promptTime.text = /*i18n("SW") + " " +*/ timer.getTimeString(elapsedSeconds);
    }
    function updateETAText() {
        let timeToEnd = prompter.__timeToEnd;
        if (!isFinite(timeToEnd) || prompter.__i<0) {
            timeToEnd = 2 * (Math.floor(editor.height+prompter.fontSize-prompter.topMargin-1)-prompter.position) / (prompter.__baseSpeed * Math.pow(Math.abs(prompter.__iDefault), prompter.__curvature) * prompter.fontSize/2 * ((prompter.__vw-prompter.__evw/2) / prompter.__vw));
            if (prompter.__atEnd)
                timeToEnd = 0
        }
        etaTimer.text = /*i18n("SW") + " " +*/ timer.getTimeString(timeToEnd);
    }
    function reset() {
        timer.elapsedSeconds = 0;
        clock.updateStopwatchText();
    }
    function setColor() {
        timerColorDialog.open()
    }
    function clearColor() {
        timerSettings.color = "#AAA"
    }
    ColorDialog {
        id: timerColorDialog
        color: '#AAA'
        onAccepted: {
            timerSettings.color = currentColor
        }
        onRejected: {
            currentColor = color
        }
    }
}
