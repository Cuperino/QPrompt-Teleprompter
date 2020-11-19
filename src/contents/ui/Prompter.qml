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

import QtQuick 2.12
import org.kde.kirigami 2.4 as Kirigami
import QtQuick.Controls 2.15
import QtQuick.Window 2.0
import Qt.labs.platform 1.0
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.12

import com.cuperino.qprompt.document 1.0


// Flickable makes the element scrollable and touch friendly
//// Define Flickable element using the flickable property only íf the flickable component (the prompter in this case)
//// has some non standard properties, such as not covering the whole Page. Otherwise, use element like everywhere else
//// and use Kirigami.ScrollablePage instead of page.
//flickable: Flickable {
Flickable {
    //ScrollIndicator.vertical: ScrollIndicator{
    id: prompter
    // property int __unit: 1
    property alias position: prompter.contentY
    property alias editor: editor
    property bool __play: true
    property int __i: 1
    property double __baseSpeed: 1.0
    property double __curvature: 1.3
    readonly property int __jitterMargin: 1
    readonly property bool __possitiveDirection: __i>=0
    readonly property double __vw: width / 100
    readonly property double __speed: __baseSpeed * Math.pow(Math.abs(__i), __curvature)
    readonly property double __velocity: (__possitiveDirection ? 1 : -1) * __speed
    readonly property double __timeToArival: __i ? (__possitiveDirection ? contentHeight-position : position) / (__speed * __vw) << 8 : 0
    readonly property int __destination: (__i ? (__possitiveDirection ? contentHeight - __i%(__jitterMargin+1) : __i%(__jitterMargin+1)) : position)
    // origin.y is being roughly approximated. This may not work across all systems and displays...
    readonly property bool __atStart: position<=__jitterMargin+2
    readonly property bool __atEnd: position>=contentHeight-__jitterMargin-2
    // Opacity
    property double __opacity: 0.8
    // Flips
    property bool __flipX: false
    property bool __flipY: false
    readonly property int __speedLimit: __vw * 10
    readonly property Scale __flips: Scale {
        origin.x: editor.width/2
        origin.y: (height-2*implicitFooterHeight+8)/2
        xScale: prompter.state==="prompting" && prompter.__flipX ? -1 : 1
        yScale: prompter.state==="prompting" && prompter.__flipY ? -1 : 1
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
        //motion.enabled = false
        //position = position
    }
    onFlickEnded: {
        //console.log("Flick ended")
        //motion.enabled = true
        //position = __destination
    }
    
    flickableDirection: Flickable.VerticalFlick
    
    Behavior on position {
        id: motion
        enabled: true
        animation: NumberAnimation {
            id: animationX
            duration: prompter.__timeToArival
            easing.type: Easing.Linear
            onRunningChanged: {
                if (!animationX.running && prompter.__i) {
                    prompter.__i = 0
                    showPassiveNotification(i18n("Animation Completed"));
                }
            }
        }
    }
    
    function toggle() {
        // Update position
        var verticalPosition = position + overlay.__readRegionPlacement*overlay.height
        var cursorPosition = editor.positionAt(0, verticalPosition)
        editor.cursorPosition = cursorPosition
        
        // Enter full screen
        var states = ["editing", "prompting"]
        var nextIndex = ( states.indexOf(state) + 1 ) % states.length
        state = states[nextIndex]
        
        switch (state) {
            case "editing":
                showPassiveNotification(i18n("Editing"))
                //root.leaveFullScreen()
                //root.controlsVisible = true
                break;
            case "prompting":
                showPassiveNotification(i18n("Prompt started"))
                //root.showFullScreen()
                //root.controlsVisible = false
                break;
        }
        console.log(editor.lineCount)
    }
    
    function increaseVelocity(event) {
        if (event)
            event.accepted = true;
        if (this.__atEnd)
            this.__i=0
            else
                if (this.__velocity < this.__speedLimit) {
                    this.__i++
                    this.__play = true
                    this.position = this.__destination
                    //this.state = "play"
                    //this.animationState = "play"
                    showPassiveNotification(i18n("Increase Velocity"));
                }
    }
    
    function decreaseVelocity(event) {
        if (event)
            event.accepted = true;
        if (this.__atStart)
            this.__i=0
            else
                if (this.__velocity > -this.__speedLimit) {
                    this.__i--
                    this.__play = true
                    this.position = this.__destination
                    //this.state = "play"
                    //this.animationState = "play"
                    showPassiveNotification(i18n("Decrease Velocity"));
                }
    }
    
    TextArea.flickable: TextArea {
        id: editor
        textFormat: Qt.RichText
        wrapMode: TextArea.Wrap
        readOnly: false
        text: "Error loading file"
        persistentSelection: true
        //Different styles have different padding and background
        //decorations, but since this editor must resemble the
        //teleprompter output, we don't need them.
        leftPadding: 0
        rightPadding: 0
        topPadding: 0
        bottomPadding: 0
        //background: transparent
        //background: Rectangle{
        //    color: QColor(40,41,35,127)
        //}
        //background: Rectangle {
        //color: "#424242"
        //opacity: 0.8
        //}
        // Start with the editor in focus
        focus: true
        // Make base font size relative to editor's width
        font.pixelSize: 10 * prompter.__vw
        
        // Make links responsive
        onLinkActivated: Qt.openUrlExternally(link)
    }
    
    DocumentHandler {
        id: document
        document: editor.textDocument
        cursorPosition: editor.cursorPosition
        selectionStart: editor.selectionStart
        selectionEnd: editor.selectionEnd
        Component.onCompleted: document.load("qrc:/instructions.html")
        onLoaded: {
            editor.text = text
        }
        onError: {
            errorDialog.text = message
            errorDialog.visible = true
        }
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
                    showPassiveNotification(i18n("Toggle Playback"));
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
                case Qt.Key_PageUp:
                    showPassiveNotification(i18n("Page Up Pressed")); break;
                case Qt.Key_PageDown:
                    showPassiveNotification(i18n("Page Down Pressed")); break;
                case Qt.Key_Home:
                    showPassiveNotification(i18n("Home Pressed")); break;
                case Qt.Key_End:
                    showPassiveNotification(i18n("End Pressed")); break;
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
                target: editor
                focus: true
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
            name: "prompting"
            PropertyChanges {
                target: overlay
                __opacity: 0.4
            }
            PropertyChanges {
                target: triangles
                __opacity: 0.4
            }
            PropertyChanges {
                target: overlay
                enabled: false
            }
            PropertyChanges {
                target: root
                prompterVisibility: Kirigami.ApplicationWindow.FullScreen
            }
            PropertyChanges{
                target: appBackground
                opacity: prompter.__opacity
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
                //transform: __flips
                __play: true
            }
            PropertyChanges {
                target: overlayMouseArea
                enabled: true
                cursorShape: Qt.CrossCursor
            }
            //childMode: QState.ParallelStates
            //State {
            //    name: "play"
            //    PropertyChanges {
            //        target: prompter
            //        position: prompter.__destination
            //    }
            //}
            //State {
            //    name: "pause"
            //    PropertyChanges {
            //        target: prompter
            //        position: prompter.position
            //    }
            //}
        }
    ]
    state: "editing"
    transitions: [
        Transition {
            enabled: !root.__autoFullScreen
            from: "*"; to: "*"
            NumberAnimation {
                targets: [triangles, overlay, appBackground]
                properties: "__opacity"; duration: 250;
            }
            //PropertyAnimation {
            //targets: root
            //properties: "visibility"; duration: 250;
            //}
        }
    ]
    
    ScrollBar.vertical: ScrollBar {
        id: scroller
        policy: ScrollBar.AlwaysOn
        interactive: false
        leftPadding: 0
        rightPadding: 0
        leftInset: 0
        rightInset: 0
    }
}
