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
import org.kde.kirigami 2.4 as Kirigami
import QtQuick.Controls 2.15
import QtQuick.Window 2.0
import Qt.labs.platform 1.0
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

import com.cuperino.qprompt.document 1.0


// Flickable makes the element scrollable and touch friendly
//// Define Flickable element using the flickable property only íf the flickable component (the prompter in this case)
//// has some non standard properties, such as not covering the whole Page. Otherwise, use element like everywhere else
//// and use Kirigami.ScrollablePage instead of page.
//flickable: Flickable {
Flickable {
    //ScrollIndicator.vertical: ScrollIndicator{
    id: prompter
    // Text
    property alias bold: document.bold
    property alias italic: document.italic
    property alias underline: document.underline
    property alias modified: document.modified
    property alias fileType: document.fileType
    // property int __unit: 1
    property alias position: prompter.contentY
    property bool __wysiwyg: true
    property bool __play: true
    property int __i: 1
    property real __baseSpeed: 2
    property real __curvature: 1.2
    property int __lastRecordedPosition: 0
    readonly property real centreX: width / 2;
    readonly property real centreY: height / 2;
    readonly property int __jitterMargin: __i%2
    readonly property bool __possitiveDirection: __i>=0
    readonly property real __vw: width / 100
    readonly property real __speed: __baseSpeed * Math.pow(Math.abs(__i), __curvature)
    readonly property real __velocity: (__possitiveDirection ? 1 : -1) * __speed
    readonly property real __timeToArival: __i ? (((__possitiveDirection ? editor.height-position-prompter.height : position+prompter.height)) / (__speed * __vw)) * 1000 /*<< 7*/ : 0
    readonly property int __destination: __i  ? (__possitiveDirection ? editor.height-__jitterMargin : __jitterMargin)-prompter.height : position
    // origin.y is being roughly approximated. This may not work across all systems and displays...
    readonly property bool __atStart: position<=__jitterMargin-prompter.height+1
    readonly property bool __atEnd: position>=editor.height-prompter.height-__jitterMargin-1
    //readonly property bool __atStart: false
    //readonly property bool __atEnd: false
    // Background
    property double __opacity: 0.8
    // Flips
    property bool __flipX: false
    property bool __flipY: false
    readonly property int __speedLimit: __vw * 1000 // 2*width
    readonly property Scale __flips: Scale {
        origin.x: editor.width/2
        origin.y: height/2
        xScale: prompter.state!=="editing" && prompter.__flipX ? -1 : 1
        yScale: prompter.state!=="editing" && prompter.__flipY ? -1 : 1
    }
    transform: __flips
    Behavior on __flips.xScale {
        enabled: true
        animation: NumberAnimation {
            duration: 250
            easing.type: Easing.OutQuad
        }
    }
    Behavior on __flips.yScale {
        enabled: true
        animation: NumberAnimation {
            duration: 250
            easing.type: Easing.OutQuad
        }
    }

    // Prompter animation
    onFlickStarted: {
        //console.log("Flick started")
        motion.enabled = false
        //position = position
    }
    onFlickEnded: {
        //console.log("Flick ended")
        motion.enabled = true
        //position = __destination
    }

    flickableDirection: Flickable.VerticalFlick

    Behavior on position {
        id: motion
        enabled: true
        animation: NumberAnimation {
            id: animationX
            duration: __timeToArival
            easing.type: Easing.Linear
            onRunningChanged: {
                if (!animationX.running && prompter.__i) {
                    __i = 0
                    showPassiveNotification(i18n("Animation Completed"));
                }
                else {
                    //__lastRecordedPosition = position
                    //console.log(__lastRecordedPosition)
                }
            }
        }
    }

    function bookmark(event) {
        editor.bookmark(event)
    }
    function undo(event) {
        editor.undo(event)
    }
    function redo(event) {
        editor.redo(event)
    }
    function copy(event) {
        editor.copy(event)
    }
    function cut(event) {
        editor.cut(event)
    }
    function paste(event) {
        editor.paste(event)
    }
    function load(file) {
        editor.load(file)
    }
    function saveAs(file) {
        editor.saveAs(file)
    }

    function toggle() {
        // Update position
        var verticalPosition = position + overlay.__readRegionPlacement*overlay.height
        var cursorPosition = editor.positionAt(0, verticalPosition)
        editor.cursorPosition = cursorPosition

        // Enter full screen
        var states = ["editing", "countdown", "prompting"]
        var nextIndex = ( states.indexOf(state) + 1 ) % states.length
        state = states[nextIndex]

        switch (state) {
            case "editing":
                showPassiveNotification(i18n("Editing"))
                //root.leaveFullScreen()
                //root.controlsVisible = true
                break;
            case "countdown":
            case "prompting":
                showPassiveNotification(i18n("Prompt started"))
                //root.showFullScreen()
                //root.controlsVisible = false
                break;
        }
    }

    function increaseVelocity(event) {
        if (event)
            event.accepted = true;
        if (this.__atEnd)
            this.__i=0
        else if (this.__velocity < this.__speedLimit) {
            this.__i++
            this.__play = true
            this.position = this.__destination
            //this.state = "play"
            //this.animationState = "play"
            //showPassiveNotification(i18n("Increase Velocity"));
        }
    }

    function decreaseVelocity(event) {
        if (event)
            event.accepted = true;
        if (this.__atStart)
            this.__i=0
        else if (this.__velocity > -this.__speedLimit) {
            this.__i--
            this.__play = true
            this.position = this.__destination
            //this.state = "play"
            //this.animationState = "play"
            //showPassiveNotification(i18n("Decrease Velocity"));
        }
    }
    bottomMargin: prompter.height
    topMargin: prompter.height
    TextArea.flickable: TextArea {
        id: editor
        textFormat: Qt.RichText
        wrapMode: TextArea.Wrap
        readOnly: false
        text: "Error loading file..."
        selectByMouse: true
        persistentSelection: true
        //Different styles have different padding and background
        //decorations, but since this editor must resemble the
        //teleprompter output, we don't need them.
        leftPadding: 20
        rightPadding: 20
        topPadding: 0
        bottomPadding: 0
        //background: transparent
        //background: Rectangle{
        //    color: QColor(40,41,35,127)
        //}
        //ground: Rectangle {
        //color: "#424242"
        //opacity: 0.8
        //}
        // Start with the editor in focus
        focus: true
        // Make base font size relative to editor's width
        font.pixelSize: prompter.state==="editing" && !prompter.__wysiwyg ? 16 : 10 * prompter.__vw

        // Make links responsive
        onLinkActivated: Qt.openUrlExternally(link)

        // Width drag controls
        width: prompter.width - x
        MouseArea {
            acceptedButtons: Qt.RightButton
            anchors.fill: parent
            onClicked: contextMenu.open()
        }
        //
        MouseArea {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 25
            drag.target: parent
            drag.axis: Drag.XAxis
            drag.smoothed: false
            drag.minimumX: 0
            drag.maximumX: prompter.width*2/5
            cursorShape: Qt.SizeHorCursor
            //onReleased: {}
        }
        MouseArea {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 25
            drag.target: parent
            drag.axis: Drag.XAxis
            drag.smoothed: false
            drag.minimumX: -prompter.width*2/5
            drag.maximumX: 0
            cursorShape: Qt.SizeHorCursor
            //onReleased: {}
        }
    }

    contentHeight: prompter.height+editor.implicitHeight

    Rectangle {
        id: rect
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: editor.bottom
        height: parent.height
        color: "#242424"
    }

    MouseArea {
        anchors.fill: parent
        onWheel: {
            if (prompter.state==="prompting" && wheel.modifiers & Qt.ControlModifier) {
                if (wheel.angleDelta.y > 0)
                    increaseVelocity();
                else
                    decreaseVelocity();
            }
            else {
                // Regular scroll
                const delta = wheel.angleDelta.y/2;
                if (prompter.position-delta > -prompter.height/*0*/ && prompter.position-delta<editor.implicitHeight/*-prompter.height*/) {
                    var i=__i;
                    __i=0;
                    prompter.position = prompter.position - delta;
                    __i=i;
                    //prompter.__play = true
                    prompter.position = prompter.__destination

                }
            }
        }
    }

    DocumentHandler {
        id: document
        document: editor.textDocument
        cursorPosition: editor.cursorPosition
        selectionStart: editor.selectionStart
        selectionEnd: editor.selectionEnd
        Component.onCompleted: {
            if (Qt.application.arguments.length === 2)
                document.load("file:" + Qt.application.arguments[1]);
            else
                document.load("qrc:/instructions.html")
        }
        //Component.onCompleted: document.load("qrc:/instructions.html")
        onLoaded: {
            //textArea.textFormat = format
            editor.text = text
        }
        onError: {
            errorDialog.text = message
            errorDialog.visible = true
        }
    }

    MessageDialog {
        id: errorDialog
    }

    // Context Menu
    Menu {
        id: contextMenu

        MenuItem {
            text: qsTr("Copy")
            enabled: editor.selectedText
            onTriggered: editor.copy()
        }
        MenuItem {
            text: qsTr("Cut")
            enabled: editor.selectedText
            onTriggered: editor.cut()
        }
        MenuItem {
            text: qsTr("Paste")
            enabled: editor.canPaste
            onTriggered: editor.paste()
        }

        MenuSeparator {}

        MenuItem {
            text: qsTr("Font...")
            onTriggered: fontDialog.open()
        }

        MenuItem {
            text: qsTr("Color...")
            onTriggered: colorDialog.open()
        }
    }

    FontDialog {
        id: fontDialog
        onAccepted: {
            document.fontFamily = font.family;
            document.fontSize = font.pointSize;
        }
    }

    ColorDialog {
        id: colorDialog
        currentColor: "black"
    }

    // Key bindings
    Keys.onPressed: {
        if (prompter.state === "prompting")
            switch (event.key) {
                //case Qt.Key_S:
                case Qt.Key_Down:
                    prompter.increaseVelocity(event)
                    break;
                    //case Qt.Key_W:
                case Qt.Key_Up:
                    prompter.decreaseVelocity(event)
                    break;
                case Qt.Key_Space:
                    //showPassiveNotification__lastRecordedPosition(i18n("Toggle Playback"));
                    //console.log(motion.paused)
                    //motion.paused = !motion.paused
                    if (prompter.__play/*prompter.state=="play"*/) {
                        prompter.__play = false
                        prompter.position = prompter.position
                        //prompter.state = "pause"
                        //prompter.animationState = "pause"
                        //    motion.resume()
                    }
                    else {
                        prompter.__play = true
                        prompter.position = prompter.__destination
                        //prompter.state = "play"
                        //prompter.animationState = "play"
                        //    motion.pause()
                    }
                    //var states = ["play", "pause"]
                    //var nextIndex = ( states.indexOf(prompter.animationState) + 1 ) % states.length
                    //prompter.animationState = states[nextIndex]
                    break;
                case Qt.Key_Tab:
                    if (event.modifiers & Qt.ShiftModifier)
                        // Not reached...
                        showPassiveNotification(i18n("Shift Tab Pressed"));
                    else
                        showPassiveNotification(i18n("Tab Pressed"));
                    break;
                //case Qt.Key_PageUp:
                //    showPassiveNotification(i18n("Page Up Pressed")); break;
                //case Qt.Key_PageDown:
                //    showPassiveNotification(i18n("Page Down Pressed")); break;
                //case Qt.Key_Home:
                //    showPassiveNotification(i18n("Home Pressed")); break;
                //case Qt.Key_End:
                //    showPassiveNotification(i18n("End Pressed")); break;
                    //default:
                    //    // Show key code
                    //    showPassiveNotification(event.key)
            }
            //// Undo and redo key bindings
            //if (event.matches(StandardKey.Undo))
            //    document.undo();
            //else if (event.matches(StandardKey.Redo))
            //    document.redo();
    }

    states: [
        State {
            name: "editing"
            //PropertyChanges {
            //target: readRegion
            //__placement: readRegion.__placement
            //}
            //PropertyChanges {
            //target: readRegionButton
            //text: i18n("Custom")
            //iconName: "gtk-apply"
            //}
            PropertyChanges {
                target: overlay
                state: "editing"
            }
            PropertyChanges {
                target: countdown
                state: "ready"
            }
            PropertyChanges {
                target: editor
                focus: true
                selectByMouse: true
                //cursorPosition: editor.positionAt(0, editor.position + 1*overlay.height/2)
            }
            PropertyChanges {
                target: root
                prompterVisibility: Kirigami.ApplicationWindow.AutomaticVisibility
            }
            PropertyChanges {
                target: prompter
                __i: 0
            }
        },
        State {
            name: "countdown"
            PropertyChanges {
                target: overlay
                state: "prompting"
            }
            PropertyChanges {
                target: countdown
                state: "running"
            }
            PropertyChanges {
                target: root
                prompterVisibility: Kirigami.ApplicationWindow.FullScreen
            }
            PropertyChanges {
                target: appTheme
                opacity: root.__translucidBackground ? __opacity : 1
            }
            PropertyChanges {
                target: promptingButton
                text: i18n("Return to edit mode")
                iconName: "edit-undo"
            }
            PropertyChanges {
                target: editor
                selectByMouse: false
            }
            //State {
                //name: "prompting"
                //PropertyChanges {
                    //target: prompter
                    //position: prompter.__destination
                    //focus: true
                    //__play: true
                //}
                //PropertyChanges {
                    //target: decreaseVelocityButton
                    //enabled: true
                //}
                //PropertyChanges {
                    //target: increaseVelocityButton
                    //enabled: true
                //}
            //}
            //childMode: QState.ParallelStates
        },
        State {
            name: "prompting"
            PropertyChanges {
                target: overlay
                state: "prompting"
            }
            PropertyChanges {
                target: root
                prompterVisibility: Kirigami.ApplicationWindow.FullScreen
            }
            PropertyChanges {
                target: appTheme
                opacity: root.__translucidBackground ? __opacity : 1
            }
            PropertyChanges {
                target: promptingButton
                text: i18n("Return to edit mode")
                iconName: "edit-undo"
            }
            PropertyChanges {
                target: prompter
                position: prompter.__destination
                focus: true
                __play: true
            }
            PropertyChanges {
                target: editor
                selectByMouse: false
            }
            PropertyChanges {
                target: decreaseVelocityButton
                enabled: true
            }
            PropertyChanges {
                target: increaseVelocityButton
                enabled: true
            }
        }
    ]
    state: "editing"

    // Progress indicator
    ScrollBar.vertical: ProgressIndicator {}

}
