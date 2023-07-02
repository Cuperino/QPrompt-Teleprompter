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
import QtQuick.Dialogs 1.2
import Qt.labs.settings 1.0

//import com.cuperino.qprompt.promptertimer 1.0

Item {
    id: clock

    property bool running: false
    property double elapsedMilliseconds: 0
    property double startTime: new Date().getTime() - elapsedMilliseconds
    property double lastTime: startTime
    property bool stopwatch: true
    property bool eta: true
    property real size: 0.5
    property alias textColor: timerSettings.color
    readonly property real centreX: prompter.centreX;
    readonly property real centreY: prompter.centreY;

    function getTimeString(timeInSeconds) {
        const digitalSeconds = Math.ceil(timeInSeconds) % 60 / 100;
        const minutes = (timeInSeconds+1) / 60
        const digitalMinutes = Math.floor(minutes % 60) / 100;
        const digitalHours = Math.floor((minutes / 60) % 100) / 100;
        return (digitalHours).toFixed(2).toString().slice(2)+":"+(digitalMinutes).toFixed(2).toString().slice(2)+":"+(digitalSeconds).toFixed(2).toString().slice(2);
    }
    function startTimer() {
        //console.log("Start timer")
        startTime = new Date().getTime() - elapsedMilliseconds
    }
    function stopTimer() {
        //console.log("Stop timer")
        const currentTime = new Date().getTime()
        elapsedMilliseconds = currentTime - startTime
    }
    function updateTimer() {
        // Update ETA only if ETA is meant to be shown.
        if (clock.eta) {
            let timeToEnd = prompter.__timeToEnd;
            if (!isFinite(timeToEnd) || prompter.__i<0) {
                timeToEnd = 2 * (Math.floor(editor.height+prompter.fontSize-prompter.topMargin-1)-prompter.position) / (prompter.__baseSpeed * Math.pow(Math.abs(prompter.__iDefault), prompter.__curvature) * prompter.fontSize/2 * ((prompter.__vw-prompter.__evw/2) / prompter.__vw));
                if (prompter.__atEnd)
                    timeToEnd = 0
            }
            etaTimer.text = timer.getTimeString(timeToEnd);
        }

        // Update stopwatch timer regardless of stopwatch being shown. This allows getting desired value for talent after a run has been completed with the stopwatch hidden.
        const newLastTime = new Date().getTime()
        if (!running)
            startTime = startTime + newLastTime - lastTime
        lastTime = newLastTime
        elapsedMilliseconds = lastTime - startTime

        // Update stopwatch only if stopwatch is meant to be shown.
        if (clock.stopwatch)
            promptTime.text = timer.getTimeString(elapsedMilliseconds/1000);
    }
    function reset() {
        timer.elapsedMilliseconds = 0;
        startTime = new Date().getTime() - elapsedMilliseconds
        lastTime = startTime
    }
    function setColor() {
        timerColorDialog.open()
    }
    function clearColor() {
        timerSettings.color = "#AAA"
    }

    // Flip
    readonly property Scale __flips: Flip{}
    transform: __flips

    readonly property bool timersEnabled: enabled && (stopwatch || eta)
    enabled: false
    visible: enabled
    clip: true
    anchors.fill: parent
//    height: prompter.height
//    anchors {
//        left: parent.left
//        right: parent.right
//        top: parent.top
//    }

    Settings {
        id: timerSettings
        category: "timer"
        property alias enabled: clock.enabled
        property alias stopwatch: clock.stopwatch
        property alias eta: clock.eta
        property color color: timerColorDialog.currentColor
    }

    Item {
        id: stopwatch
        readonly property real centreX: width / 2;
        readonly property real centreY: height / 2;
        readonly property int marginX: 4 * clock.size * prompter.__vw
        readonly property int marginY: 2 * clock.size * prompter.__vw
        readonly property real fontSize: clock.size * (screen.devicePixelRatio / (root.width/root.height>1 ? 2 : 1)) * prompter.__vw << 3
        property real customRelativeXpos: 0.5
        property real relativeXpos: customRelativeXpos
        x: relativeXpos * (clock.width - stopwatch.width)
        y: overlay.__readRegionPlacement >= 0.5 ? centreY * 2 / 5 : clock.height - height - centreY * 2 / 5
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
                font.family: "Monospace"
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
                font.family: "Monospace"
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
            onReleased: stopwatch.customRelativeXpos = stopwatch.x / (clock.width - stopwatch.width)
        }
    }

    Timer {
        running: clock.enabled
        repeat: true
        triggeredOnStart: true
        interval: 333; // Keep updates at no more than 3fps to improve frame rate.
        onTriggered: updateTimer();
    }

    ColorDialog {
        id: timerColorDialog
        showAlphaChannel: false  // Line required for Android in Qt 5. Remove when refactoring to Qt 6.
        color: '#AAA'
        onAccepted: {
            timerSettings.color = currentColor
        }
        onRejected: {
            currentColor = color
        }
    }
}
