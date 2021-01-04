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

/****************************************************************************
 **
 ** Copyright (C) 2017 The Qt Company Ltd.
 ** Contact: https://www.qt.io/licensing/
 **
 ** This file contains code originating from examples from the Qt Toolkit.
 **
 ** $QT_BEGIN_LICENSE:BSD$
 ** Commercial License Usage
 ** Licensees holding valid commercial Qt licenses may use this file in
 ** accordance with the commercial license agreement provided with the
 ** Software or, alternatively, in accordance with the terms contained in
 ** a written agreement between you and The Qt Company. For licensing terms
 ** and conditions see https://www.qt.io/terms-conditions. For further
 ** information use the contact form at https://www.qt.io/contact-us.
 **
 ** BSD License Usage
 ** Alternatively, you may use this file under the terms of the BSD license
 ** as follows:
 **
 ** "Redistribution and use in source and binary forms, with or without
 ** modification, are permitted provided that the following conditions are
 ** met:
 **   * Redistributions of source code must retain the above copyright
 **     notice, this list of conditions and the following disclaimer.
 **   * Redistributions in binary form must reproduce the above copyright
 **     notice, this list of conditions and the following disclaimer in
 **     the documentation and/or other materials provided with the
 **     distribution.
 **   * Neither the name of The Qt Company Ltd nor the names of its
 **     contributors may be used to endorse or promote products derived
 **     from this software without specific prior written permission.
 **
 **
 ** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 ** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 ** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 ** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 ** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 ** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 ** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 ** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 ** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 ** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 ** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
 **
 ** $QT_END_LICENSE$
 **
 ****************************************************************************/

import QtQuick 2.15
import org.kde.kirigami 2.9 as Kirigami
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import Qt.labs.platform 1.1
import QtGraphicalEffects 1.15

import com.cuperino.qprompt.document 1.0


// Flickable makes the element scrollable and touch friendly
//// Define Flickable element using the flickable property only íf the flickable component (the prompter in this case)
//// has some non standard properties, such as not covering the whole Page. Otherwise, use element like everywhere else
//// and use Kirigami.ScrollablePage instead of page.
//flickable: Flickable {
Flickable {
    //ScrollIndicator.vertical: ScrollIndicator{
    id: prompter
    // Patch through aliases
    property alias editor: editor
    property alias document: document
    property alias textColor: document.textColor
    // Create position alias to make code more readable
    property alias position: prompter.contentY
    //property int __unit: 1
    // Scrolling settings
    property bool __scrollAsDial: root.__scrollAsDial
    property bool __invertArrowKeys: root.__invertArrowKeys
    property bool __invertScrollDirection: root.__invertScrollDirection
    property bool __wysiwyg: true
    property int __i: 1
    property bool __play: true
    property real __baseSpeed: root.__baseSpeed
    property real __curvature: root.__curvature
    //property alias __baseSpeed: parent.__baseSpeed
    //property alias __curvature: parent.__curvature
    property int __lastRecordedPosition: 0
    //property int alignment: Text.AlignCenter
    readonly property real centreX: width / 2;
    readonly property real centreY: height / 2;
    readonly property int __jitterMargin: __i%2
    readonly property bool __possitiveDirection: __i>=0
    readonly property real __vw: width / 100
    readonly property real __speed: __baseSpeed * Math.pow(Math.abs(__i), __curvature)
    readonly property real __velocity: (__possitiveDirection ? 1 : -1) * __speed
    readonly property real __timeToArival: __i ? (((__possitiveDirection ? editor.height-position : position+prompter.height)) / (__speed * __vw)) * 1000 /*<< 7*/ : 0
    readonly property int __destination: __i  ? (__possitiveDirection ? editor.height+prompter.height-__jitterMargin : __jitterMargin)-prompter.height : position
    // origin.y is being roughly approximated. This may not work across all systems and displays...
    readonly property bool __atStart: position<=__jitterMargin-prompter.height+1
    readonly property bool __atEnd: position>=editor.height-__jitterMargin-1
    //readonly property bool __atStart: false  // debug code
    //readonly property bool __atEnd: false  // debug code
    // Background
    property double __opacity: root.__opacity
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
    layer.enabled: true
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

    // Toggle prompter state
    function toggle() {
        // Update position
        var verticalPosition = position + overlay.__readRegionPlacement*overlay.height
        var cursorPosition = editor.positionAt(0, verticalPosition)
        editor.cursorPosition = cursorPosition

        // Enter full screen
        var states = ["editing", "countdown", "prompting"]
        var nextIndex = ( states.indexOf(state) + 1 ) % states.length
        // Skip countdown if countdown.__iterations is 0
        if (states[nextIndex]===states[1] && countdown.__iterations===0)
            nextIndex = ( states.indexOf(state) + 2 ) % states.length
        state = states[nextIndex]

        switch (state) {
            case "editing":
                showPassiveNotification(i18n("Editing"), 850*countdown.__iterations)
                break;
            case "countdown":
            case "prompting":
                showPassiveNotification(i18n("Prompt started"), 850*countdown.__iterations)
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
            //showPassiveNotification(i18n("Decrease Velocity"));
        }
    }
    topMargin: prompter.height
    bottomMargin: prompter.height
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
        leftPadding: 20+2*(x<0?-x:0)
        rightPadding: 20+2*(x>0?x:0)
        topPadding: 0
        bottomPadding: 0
        background: transparent
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
        font.family: "Anjali Old Lipi"
        font.hintingPreference: Font.PreferFullHinting
        // Make links responsive
        onLinkActivated: Qt.openUrlExternally(link)
        // Width drag controls
        //width: prompter.width-2*position.x
        MouseArea {
            acceptedButtons: Qt.RightButton
            anchors.fill: parent
            onClicked: contextMenu.open()
        }
        
        // Draggable width adjustment borders
        Component {
            id: editorSidesBorder
            Rectangle {
                width: 2
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#AA9" }
                    GradientStop { position: 1.0; color: "#776" }
                }
            }
        }
        MouseArea {
            id: leftWidthAdjustmentBar
            scrollGestureEnabled: false
            propagateComposedEvents: true
            hoverEnabled: false
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: Qt.application.layoutDirection===Qt.LeftToRight&&parent.x<0?-2*parent.x:(Qt.application.layoutDirection===Qt.RightToLeft&&parent.x>0?2*parent.x:0)
            width: 25
            drag.target: parent
            drag.axis: Drag.XAxis
            drag.smoothed: false
            drag.minimumX: Qt.application.layoutDirection===Qt.LeftToRight ? 0 : -prompter.width*2/5
            drag.maximumX: Qt.application.layoutDirection===Qt.LeftToRight ? prompter.width*2/5 : 0
            cursorShape: Qt.SizeHorCursor
            Loader {
                sourceComponent: editorSidesBorder
                anchors {top: parent.top; bottom: parent.bottom; horizontalCenter: parent.horizontalCenter}
            }
            onPressed: {
                // Hack: Workaround to prevent covering the editor toolbar's buttons, placed at the window's footer.
                if (mouse.y >= position+prompter.height)
                    mouse.accepted = false
                // Adjust widths
                else if (Qt.application.layoutDirection===Qt.LeftToRight&&parent.x<0 || Qt.application.layoutDirection===Qt.RightToLeft&&parent.x>0)
                    parent.x = -parent.x
            }
            onClicked: {
                mouse.accepted = false
            }
        }
        MouseArea {
            id: rightWidthAdjustmentBar
            scrollGestureEnabled: false
            propagateComposedEvents: true
            hoverEnabled: false
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.rightMargin: Qt.application.layoutDirection===Qt.LeftToRight&&parent.x>0?2*parent.x:(Qt.application.layoutDirection===Qt.RightToLeft&&parent.x<0?-2*parent.x:0)
            width: 25
            drag.target: parent
            drag.axis: Drag.XAxis
            drag.smoothed: false
            drag.minimumX: Qt.application.layoutDirection===Qt.LeftToRight ? -prompter.width*2/5 : 0
            drag.maximumX: Qt.application.layoutDirection===Qt.LeftToRight ? 0 : prompter.width*2/5
            cursorShape: Qt.SizeHorCursor
            Loader {
                sourceComponent: editorSidesBorder
                anchors {top: parent.top; bottom: parent.bottom; horizontalCenter: parent.horizontalCenter}
            }
            onPressed: {
                // Hack: Workaround to prevent covering the editor toolbar's buttons, placed at the window's footer.
                if (mouse.y >= position+prompter.height)
                    mouse.accepted = false
                // Adjust widths
                else if (Qt.application.layoutDirection===Qt.LeftToRight&&parent.x>0 || Qt.application.layoutDirection===Qt.RightToLeft&&parent.x<0)
                    parent.x = -parent.x
            }
            //onClicked: {
                //mouse.accepted = false
            //}
        }
    }
    
    FastBlur {
        anchors.fill: editor
        source: editor
        //radius: 32
        radius: 0
    }

    // Bottom margin hack
    Rectangle {
        id: rect
        anchors.left: editor.left
        anchors.right: editor.right
        anchors.top: editor.bottom
        height: prompter.height
        color: "#000"
        opacity: 0.2
    }

    MouseArea {
        //propagateComposedEvents: false
        acceptedButtons: Qt.NoButton
        hoverEnabled: false
        scrollGestureEnabled: false
        // The following placement allows covering beyond the boundaries of the editor and into the prompter's margins.
        anchors.left: parent.left
        anchors.right: parent.right
        y: -prompter.height
        height: parent.height+2*prompter.height
        // Mouse wheel controls
        onWheel: {
            if (prompter.state==="prompting" && (prompter.__scrollAsDial && !(wheel.modifiers & Qt.ControlModifier) || !prompter.__scrollAsDial && wheel.modifiers & Qt.ControlModifier)) {
                if (wheel.angleDelta.y > 0) {
                    if (prompter.__invertScrollDirection)
                        increaseVelocity();
                    else
                        decreaseVelocity();
                }
                else
                    if (prompter.__invertScrollDirection)
                        decreaseVelocity();
                    else
                        increaseVelocity();
            }
            else {
                // Regular scroll
                const delta = wheel.angleDelta.y/2;
                if (prompter.position-delta > -prompter.height/*0*/ && prompter.position-delta<editor.implicitHeight/*-prompter.height*/) {
                    var i=__i;
                    __i=0;
                    if (prompter.__invertScrollDirection)
                        prompter.position += delta;
                    else
                        prompter.position -= delta;
                    __i=i;
                    prompter.position = prompter.__destination

                }
            }
        }
    }

    DocumentHandler {
        id: document
        property bool isNewFile: false
        document: editor.textDocument
        cursorPosition: editor.cursorPosition
        selectionStart: editor.selectionStart
        selectionEnd: editor.selectionEnd
        textColor: "#FFF"
        Component.onCompleted: {
            if (Qt.application.arguments.length === 2) {
                document.load("file:" + Qt.application.arguments[1]);
                isNewFile = false
            }
            else {
                document.load("qrc:/instructions.html")
                isNewFile = true
            }
        }
        //Component.onCompleted: document.load("qrc:/instructions.html")
        onLoaded: {
            editor.textFormat = format
            editor.text = text
        }
        onError: {
            errorDialog.text = message
            errorDialog.visible = true
        }

        function newDocument() {
            load("qrc:/untitled.html")
            isNewFile = true
            showPassiveNotification(i18n("New document"))
        }
        
        function loadInstructions() {
            document.load("qrc:/instructions.html")
            isNewFile = true
        }
        
        function open() {
            openDialog.open()
        }
        function saveAsDialog() {
            saveDialog.open()
        }
        function saveDialog() {
            if (isNewFile)
                saveAsDialog()
            else// if (modified)
                document.saveAs(document.fileUrl)
        }
    }
    FileDialog {
        id: openDialog
        fileMode: FileDialog.OpenFile
        selectedNameFilter.index: 1
        nameFilters: ["Text files (*.txt)", "HTML files (*.html *.htm)"]
        folder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
        onAccepted: {
            document.load(file)
            document.isNewFile = false
        }
    }
    
    FileDialog {
        id: saveDialog
        fileMode: FileDialog.SaveFile
        defaultSuffix: document.fileType
        nameFilters: openDialog.nameFilters
        // Always in the same format as original file
        //selectedNameFilter.index: document.fileType === "txt" ? 0 : 1
        // Always save as HTML
        selectedNameFilter.index: 1
        folder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
        onAccepted: {
            document.saveAs(file)
            document.isNewFile = false
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

    // Key bindings
    Keys.onPressed: {
        if (prompter.state === "prompting")
            switch (event.key) {
                //case Qt.Key_S:
                case Qt.Key_Down:
                    if (prompter.__invertArrowKeys)
                        prompter.decreaseVelocity(event)                        
                    else
                        prompter.increaseVelocity(event)
                    break;
                    //case Qt.Key_W:
                case Qt.Key_Up:
                    if (prompter.__invertArrowKeys)
                        prompter.increaseVelocity(event)                        
                    else
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
                case Qt.Key_Escape:
                    prompter.toggle();
                    break;
                //default:
                //    // Show key code
                //    showPassiveNotification(event.key)
            }
            //// Undo and redo key bindings
            //if (event.matches(StandardKey.Undo))
            //    document.undo();
            //else if (event.matches(StandardKey.Redo))
            //    document.redo();
        
        // Keys presses that apply the same to all states
        switch (event.key) {
            case Qt.Key_F9:
                prompter.toggle();
                break;
            case Qt.Key_PageUp:
                if (!this.__atStart) {
                    var i=__i;
                    __i=0;
                    //prompter.position -= prompter.height/4
                    prompter.position = prompter.position
                    scrollBar.decrease()
                    __i=i
                    prompter.position = __destination
                }
                break;
            case Qt.Key_PageDown:
                if (!this.__atEnd) {
                    var i=__i;
                    __i=0;
                    //prompter.position += prompter.height/4
                    prompter.position = prompter.position
                    scrollBar.increase()
                    __i=i
                    prompter.position = __destination
                }
                break;
            //case Qt.Key_Home:
            //    showPassiveNotification(i18n("Home Pressed")); break;
            //case Qt.Key_End:
            //    showPassiveNotification(i18n("End Pressed")); break;
        }
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
                z: 2
                __i: 0
                __play: false
                position: position
                // Bottom margin hack
                //topMargin: prompter.height
                //bottomMargin: prompter.height
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
                text: i18n("Skip countdown")
                //iconName: "edit-undo"
            }
            PropertyChanges {
                target: prompter
                z: 0
                position: position
                // Bottom margin hack
                //topMargin: prompter.height
                //bottomMargin: prompter.height
            }
            PropertyChanges {
                target: editor
                selectByMouse: false
            }
            PropertyChanges {
                target: leftWidthAdjustmentBar
                opacity: 0
                enabled: false
            }
            PropertyChanges {
                target: rightWidthAdjustmentBar
                opacity: 0
                enabled: false
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
                z: 0
                position: prompter.__destination
                focus: true
                __play: true
                // Bottom margin hack
                //topMargin: prompter.height
                //bottomMargin: prompter.height
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
            PropertyChanges {
                target: leftWidthAdjustmentBar
                opacity: 0
                enabled: false
            }
            PropertyChanges {
                target: rightWidthAdjustmentBar
                opacity: 0
                enabled: false
            }
        }
    ]
    state: "editing"
    onStateChanged: {
        var pos = prompter.position
        position = pos
    }
    
    // Progress indicator
    ScrollBar.vertical: ProgressIndicator {
        id: scrollBar
    }

}
