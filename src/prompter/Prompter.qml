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
 ** The code from the examples was licensed under the following license:
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
 ** Alternatively, you may use the original examples code in this file under
 ** the terms of the BSD license as follows:
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

import QtQuick 2.12
import org.kde.kirigami 2.11 as Kirigami
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.12
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.2
import Qt.labs.platform 1.1 as Labs
import Qt.labs.settings 1.0

import com.cuperino.qprompt.document 1.0

Flickable {
    id: prompter
    // Enums
    enum States {
        Editing,
        Standby,
        Countdown,
        Prompting
    }
    // Patch through aliases
    property alias editor: editor
    property alias document: document
    property alias textColor: document.textColor
    property alias textBackground: document.textBackground
    property alias mouse: mouse
    // Create position alias to make code more readable
    property alias position: prompter.contentY
    // Scrolling settings
    property bool performFileOperations: false
    property bool __scrollAsDial: root.__scrollAsDial
    property bool __invertArrowKeys: root.__invertArrowKeys
    property bool __invertScrollDirection: root.__invertScrollDirection
    property bool __noScroll: root.__noScroll
    property bool __wysiwyg: true
    property alias fontSize: editor.font.pixelSize
    property alias letterSpacing: editor.font.letterSpacing
    property alias wordSpacing: editor.font.wordSpacing
    property int __i: __iDefault
    property int __iBackup: 0
    property bool __play: true
    property int __iDefault:  root.__iDefault
    // Compute slider to decimal separately for performance improvements
    property real __baseSpeed: viewport.__baseSpeed / 100
    property real __curvature: viewport.__curvature / 100
    //property int __lastRecordedPosition: 0
    //property real customContentsPlacement: 0.1
    property real contentsPlacement//: 1-rightWidthAdjustmentBar.x
    readonly property real editorXWidth: Math.abs(editor.x)/prompter.width
    readonly property real editorXOffset: positionHandler.x/prompter.width
    readonly property real centreX: width / 2;
    readonly property real centreY: height / 2;
    readonly property int __jitterMargin: (__i+viewport.__baseSpeed+viewport.__curvature+fontSize)%2
    readonly property bool __possitiveDirection: __i>=0
    readonly property real __vw: width / 100 // prompter viewport width hundredth
    readonly property real __evw: editor.width / 100 // editor viewport width hundredth
    readonly property real __speed: __baseSpeed * Math.pow(Math.abs(__i), __curvature)
    readonly property real __velocity: (__possitiveDirection ? 1 : -1) * __speed
    readonly property real __relativeSpeed: (__speed * fontSize/2 * ((__vw-__evw/2) / __vw)) // Adjust relative to viewport widths and font size.
    readonly property real __travelDistance: position + topMargin - __jitterMargin
    readonly property real __timeToEnd: 2 * (editor.height + fontSize - __travelDistance) / __relativeSpeed // In seconds, used for Timer.
    readonly property real __timeToArival: __i ? ((__possitiveDirection ? __timeToEnd : 2 * __travelDistance / __relativeSpeed)) * 1000 : 0 // In milliseconds, used for animation.
    property real timeToArival: __timeToArival
    readonly property int __destination: __i  ? (__possitiveDirection ? editor.height+fontSize-__jitterMargin : __jitterMargin)-topMargin : position
    // At start and at end rules
    readonly property bool __atStart: position<=__jitterMargin-topMargin+1
    readonly property bool __atEnd: position>=editor.height-topMargin+fontSize+__jitterMargin-1
    // Tools to debug __atStart and __atEnd
    //readonly property bool __atStart: false
    //readonly property bool __atEnd: false
    //Rectangle {
    //    id: startPositionDebug
    //    // Set this value to the same as __atStart's evaluated equation
    //    y: __jitterMargin-topMargin+1
    //    anchors {
    //        id: startPositionDebug
    //        left: parent.left
    //        right: parent.right
    //    }
    //    height: 2
    //    color: "red"
    //}
    //Rectangle {
    //    id: endPositionDebug
    //    // Set this value to the same as __atStart's evaluated equation
    //    y: editor.height-topMargin+fontSize+__jitterMargin-1
    //    anchors {
    //        left: parent.left
    //        right: parent.right
    //    }
    //    height: 2
    //    color: "red"
    //}

    // Background
    property double __opacity: root.__opacity
    // Flips
    property bool __flipX: false
    property bool __flipY: false
    readonly property int __speedLimit: __vw * 100
    readonly property Scale __flips: Flip{}
    // Clipping improves performance on large files and font sizes.
    // It also provides a workaround to the lack of background in the global toolbar when using transparent backgrounds in Material theme.
    clip: true
    transform: __flips
    // Progress indicator
    readonly property real progress: (position+__jitterMargin)/editor.height
    //layer.enabled: true

    // Flick while prompting
    onDragStarted: {
        //console.log("Drag started")
        //console.log(__iBackup, __i, position)
        if (__iBackup===0) {
            __iBackup = __i
            __i = 0
            position = position
        }
    }
    onDragEnded: {
        //console.log("Drag ended")
    }
    onFlickStarted: {
        //console.log("Flick started")
    }
    onMovementEnded: {
        //console.log("Movement ended")
        //console.log(__iBackup, __i, position)
        __i = __iBackup
        if (parseInt(prompter.state)===Prompter.States.Prompting) {
            __iBackup = 0
            position = __destination
        }
        else
           position = position
    }

    flickableDirection: Flickable.VerticalFlick

    Behavior on position {
        id: motion
        enabled: true
        animation: NumberAnimation {
            id: animationX
            duration: timeToArival
            easing.type: Easing.Linear
            onRunningChanged: {
                if (!animationX.running && prompter.__i) {
                    __i = 0
                    root.alert(0)
                    if (!root.__translucidBackground)
                        showPassiveNotification(i18n("Animation Completed"));
                }
            }
        }
    }

    NumberAnimation on position {
        id: reset
        to: __jitterMargin-topMargin+1
        duration: Kirigami.Units.veryLongDuration
        easing.type: Easing.InOutQuart
        function toStart() {
            __i = 0
            position = position
            start()
        }
    }

    // Toggle prompter state
    function toggle() {

        // Switch to next corresponding prompter state, relative to current configuration
        let nextIndex = (parseInt(state) + 1) % (Prompter.States.Prompting + 1)
        if (nextIndex===Prompter.States.Standby) {
            if (!countdown.frame)
                nextIndex = Prompter.States.Prompting
            else if (countdown.autoStart)
                nextIndex = Prompter.States.Countdown
        }
        // Skip countdown if countdown is disabled or iterations are zero
        if (nextIndex===Prompter.States.Countdown && (!countdown.enabled || countdown.__iterations===0))
            nextIndex = Prompter.States.Prompting
        state = nextIndex

        switch (parseInt(state)) {
            case Prompter.States.Editing:
                //showPassiveNotification(i18n("Editing"), 850*countdown.__iterations)
                projectionManager.close();
                editor.focus = true
                break;
            case Prompter.States.Standby:
            case Prompter.States.Countdown:
            case Prompter.States.Prompting:
                prompter.focus = true
                if (projectionManager.model.count===0)
                    projectionManager.project();
                //showPassiveNotification(i18n("Prompt started"), 850*countdown.__iterations)
                if (state!==Prompter.States.Countdown)
                    document.parse()
                break;
        }
        //console.log("toggle state:", state)
    }

    function increaseVelocity(event) {
        event.accepted = true;
        if (this.__atEnd)
            this.__i=0
        else if (this.__velocity < this.__speedLimit) {
            if (this.__play)
                this.__i++
            this.__play = true
            this.position = this.__destination
            //if (!root.__translucidBackground)
            //    showPassiveNotification(i18n("Increase Velocity"));
        }
    }

    function decreaseVelocity(event) {
        event.accepted = true;
        if (this.__atStart)
            this.__i=0
        else if (this.__velocity > -this.__speedLimit) {
            if (this.__play)
                this.__i--
            this.__play = true
            this.position = this.__destination
            //if (!root.__translucidBackground)
            //    showPassiveNotification(i18n("Decrease Velocity"));
        }
    }

    function goTo(cursorPosition) {
        const i = __i;
        __i = __iBackup
        if (parseInt(prompter.state)===Prompter.States.Prompting)
            __iBackup = 0
        // Direct placement in editor
        editor.cursorPosition = cursorPosition
        prompter.position = editor.cursorRectangle.y - (overlay.__readRegionPlacement*(overlay.height-overlay.readRegionHeight)+overlay.readRegionHeight/2) + 1
        __i = i;
        if (prompter.__play && i!==0)
            prompter.position = prompter.__destination
    }

    function goToPreviousMarker() {
        const i = __i;
        __i = __iBackup
        if (parseInt(prompter.state)===Prompter.States.Prompting)
            __iBackup = 0
        setCursorAtCurrentPosition()
        editor.cursorPosition = document.previousMarker(editor.cursorPosition).position
        prompter.position = editor.cursorRectangle.y - (overlay.__readRegionPlacement*(overlay.height-overlay.readRegionHeight)+overlay.readRegionHeight/2) + 1
        __i = i
        if (prompter.__play && i!==0)
            prompter.position = prompter.__destination
    }

    function goToNextMarker() {
        const i = __i;
        __i = __iBackup
        if (parseInt(prompter.state)===Prompter.States.Prompting)
            __iBackup = 0
        setCursorAtCurrentPosition()
        editor.cursorPosition = document.nextMarker(editor.cursorPosition).position
        prompter.position = editor.cursorRectangle.y - (overlay.__readRegionPlacement*(overlay.height-overlay.readRegionHeight)+overlay.readRegionHeight/2) + 1
        __i = i
        if (prompter.__play && i!==0)
            prompter.position = prompter.__destination
    }

    function setContentWidth() {
        //contentsPlacement = Math.abs(editor.x)/prompter.width
        contentsPlacement = (Math.abs(editor.x)-fontSize/2)/(prompter.width-fontSize)
    }

    contentHeight: flickableContent.height
    topMargin: overlay.__readRegionPlacement*(prompter.height-overlay.readRegionHeight)+fontSize
    bottomMargin: (1-overlay.__readRegionPlacement)*(prompter.height-overlay.readRegionHeight)+overlay.readRegionHeight
    function ensureVisible(r)
    {
        if (parseInt(prompter.state) !== Prompter.States.Prompting) {
            if (contentX >= r.x)
                contentX = r.x;
            else if (contentX+width <= r.x+r.width)
                contentX = r.x+r.width-width;
            if (contentY >= r.y)
                contentY = r.y;
            else if (contentY+height <= r.y+r.height)
                contentY = r.y+r.height-height;
        }
    }
    
    MouseArea {
        id: mouse
        //propagateComposedEvents: false
        acceptedButtons: Qt.LeftButton
        hoverEnabled: false
        scrollGestureEnabled: false
        // The following placement allows covering beyond the boundaries of the editor and into the prompter's margins.
        anchors.left: parent.left
        anchors.right: parent.right
        y: -prompter.height
        height: parent.height+2*prompter.height
        cursorShape: (pressed || dragging) ? Qt.ClosedHandCursor : Qt.OpenHandCursor
        // Mouse wheel controls
        property int throttledIteration: 0
        property int throttleIterations: 8
        onWheel: {
            if (prompter.__noScroll && parseInt(prompter.state)===Prompter.States.Prompting)
                return;
            else if (parseInt(prompter.state)===Prompter.States.Prompting && (prompter.__scrollAsDial && !(wheel.modifiers & Qt.ControlModifier) || !prompter.__scrollAsDial && wheel.modifiers & Qt.ControlModifier)) {
                if (!throttledIteration) {
                    if (wheel.angleDelta.y > 0) {
                        if (prompter.__invertScrollDirection)
                            increaseVelocity(wheel);
                        else/* if (prompter.__i>1)*/
                            decreaseVelocity(wheel);
                    }
                    else if (wheel.angleDelta.y < 0) {
                        if (prompter.__invertScrollDirection/* && prompter.__i>1*/)
                            decreaseVelocity(wheel);
                        else
                            increaseVelocity(wheel);
                    }
                    // Do nothing if wheel.angleDelta.y === 0
                }
                throttledIteration = (throttledIteration+1)%throttleIterations
            }
            else {
                // Regular scroll
                const delta = (prompter.__invertScrollDirection?-1:1)*wheel.angleDelta.y/2;
                var i=__i;
                __i=0;
                if (prompter.position-delta >= -prompter.topMargin && prompter.position-delta<=editor.implicitHeight-(overlay.height-prompter.bottomMargin))
                    prompter.position -= delta;
                // If scroll were to go out of bounds, cap it
                else if (prompter.position-delta > -prompter.topMargin)
                    prompter.position = editor.implicitHeight-(overlay.height-prompter.bottomMargin)
                else
                    prompter.position = -prompter.topMargin
                __i=i;
                // Resume prompting
                if (parseInt(prompter.state)===Prompter.States.Prompting && prompter.__play)
                    prompter.position = prompter.__destination
            }
        }
    }
    
    Item {
        id: positionHandler

        // Force positionHandler's position to reset to center on resize.
        x: (editor.x - (width - editor.width)/2) / 2

        // Keep dimensions at their right size, but adjustable
        width: parent.width
        height: editor.implicitHeight

        Item {
            id: flickableContent
            anchors.fill: parent
            TextArea {
                id: editor

                onCursorRectangleChanged: prompter.ensureVisible(cursorRectangle)
                textFormat: Qt.RichText
                wrapMode: TextArea.Wrap
                readOnly: false
                text: i18n("Error loading file...")

                selectByMouse: true
                persistentSelection: true
                selectionColor: "#333d9ef3"
                selectedTextColor: selectionColor
                //selectionColor: document.textBackground
                //selectedTextColor: document.textColor
                leftPadding: 14
                rightPadding: 14
                topPadding: 0
                bottomPadding: 0
                onLinkActivated: console.log(link)

                background: Item {}
                
                // Start with the editor in focus
                focus: true
                
                // Make base font size relative to editor's width
                // Western Fonts
                FontLoader {
                    id: westernSeriousSansfFont
                    source: i18n("fonts/dejavu-sans.otf")
                }
                FontLoader {
                    id: westernHumaneSansFont
                    source: i18n("fonts/libertinus-sans.otf")
                }
                FontLoader {
                    id: westernDyslexicFont
                    source: i18n("fonts/opendyslexic-bold.otf")
                }
                FontLoader {
                    id: asianSeriousSansFont
                    source: i18n("fonts/sourcehansans.ttc")
                }
                FontLoader {
                    id: arabicHumaneSansFont
                    source: i18n("fonts/scheherazadenew-regular.ttf")
                }
                FontLoader {
                    id: devanagariSeriousSansFont
                    source: i18n("fonts/palanquin.ttf")
                }
                FontLoader {
                    id: bangalaHumaneSerifFont
                    source: i18n("fonts/kalpurush.ttf")
                }
                font.family: westernSeriousSansfFont.name
                font.pixelSize: 14
                font.hintingPreference: Font.PreferFullHinting
                font.kerning: true
                font.preferShaping: true
                renderType: font.pixelSize < 121 || Screen.devicePixelRatio !== 1.0 || root.forceQtTextRenderer ? Text.QtRendering : Text.NativeRendering

                function toggleEditorFocus(mouse) {
                    if (!editor.focus) {
                        editor.focus = true;
                        editor.cursorPosition = editor.positionAt(mouse.x, mouse.y)
                    }
                    else
                        prompter.focus = true;
                }

                //Different styles have different padding and background
                //decorations, but since this editor must resemble the
                //teleprompter output, we don't need them.
                x: fontSize/2 + contentsPlacement*(prompter.width-fontSize)

                // Width drag controls
                width: prompter.width-2*Math.abs(x)

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
                
                Rectangle {
                    id: rect
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: editor.bottom
                    height: prompter.bottomMargin
                    color: "#000"
                    opacity: 0.2
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        property int c: 0
                        onClicked: {
                            if (!root.__translucidBackground)
                                showPassiveNotification("Double tap to go back to the start");
                        }
                        onDoubleClicked: {
                            reset.toStart()
                            if (!root.__translucidBackground) {
                                // Run hidePassiveNotification second to avoid Kirigami bug from 5.83.0 that prevents the method from completing execution.
                                //hidePassiveNotification()
                                // Scientist EE
                                let goToStartNotification = "";
                                switch (c++%3) {
                                    case 0: goToStartNotification = "Oh, let's go"; break;
                                    case 1: goToStartNotification = "Oh, take me"; break;
                                    case 2: goToStartNotification = "I'm going"; c=0; break;
                                }
                                goToStartNotification += " " + i18n("back to the start");
                                showPassiveNotification(goToStartNotification);
                            }
                        }
                    }
                }
                DropArea {
                    id: dragTarget
                    property alias dropProxy: dragTarget
                    property bool droppable: false
                    anchors.fill: parent
                    onPositionChanged: {
                        if (drag.hasHtml || drag.hasText)
                            dragTarget.droppable = true
                        else
                            dragTarget.droppable = false
                    }
                    onDropped: {
                        const position = editor.positionAt(drop.x, drop.y)
                        if (drop.hasHtml) {
                            const filteredHtml = document.filterHtml(drop.html)
                            editor.insert(position, filteredHtml)
                        }
                        else if (drop.hasText)
                            editor.insert(position, drop.text)
                    }
                    MouseArea {
                        acceptedButtons: Qt.RightButton
                        anchors.fill: parent
                        onClicked: {
                            if (Kirigami.Settings.isMobile)
                                contextMenu.popup(this)
                            else
                                nativeContextMenu.open()
                        }
                        cursorShape: dragTarget.containsDrag ? (dragTarget.droppable ? Qt.DragCopyCursor : Qt.ForbiddenCursor) : Qt.IBeamCursor
                        drag.target: editor
                    }
                    MouseArea {
                        id: limitedMouse
                        enabled: false
                        acceptedButtons: Qt.LeftButton
                        anchors.fill: parent
                        onDoubleClicked: editor.toggleEditorFocus(mouse);
                        onClicked: if (editor.focus) editor.cursorPosition = editor.positionAt(mouseX, mouseY);
                    }
                }

                MouseArea {
                    id: leftWidthAdjustmentBar
                    opacity: 0.9
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 25
                    acceptedButtons: Qt.LeftButton
                    scrollGestureEnabled: false
                    propagateComposedEvents: true
                    hoverEnabled: false
                    anchors.left: Qt.application.layoutDirection===Qt.LeftToRight ? editor.left : undefined
                    anchors.right: Qt.application.layoutDirection===Qt.RightToLeft ? editor.right : undefined
                    drag.target: editor
                    drag.axis: Drag.XAxis
                    drag.smoothed: false
                    drag.minimumX: fontSize/2 //: -prompter.width*6/20 + width
                    drag.maximumX: prompter.width*6/20 //: -fontSize/2 + width
                    cursorShape: prompter.dragging ? Qt.ClosedHandCursor : ((pressed || drag.active) ? Qt.SplitHCursor : (flicking ? Qt.OpenHandCursor : Qt.SizeHorCursor))
                    Loader {
                        sourceComponent: editorSidesBorder
                        anchors {top: parent.top; bottom: parent.bottom; horizontalCenter: parent.horizontalCenter}
                    }
                    onReleased: prompter.setContentWidth()
                    //onClicked: {
                    //    mouse.accepted = false
                    //}
                }
                MouseArea {
                //Item {
                    id: rightWidthAdjustmentBar
                    opacity: 0.5
                    x: parent.width-width
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 25
                    scrollGestureEnabled: false
                    acceptedButtons: Qt.LeftButton
                    propagateComposedEvents: true
                    hoverEnabled: false
                    drag.target: positionHandler
                    drag.axis: Drag.XAxis
                    drag.smoothed: false
                    drag.minimumX: -editor.x + fontSize/2 //prompter.width - editor.x - editor.width - leftWidthAdjustmentBar.drag.maximumX
                    drag.maximumX: prompter.width - editor.x - parent.width - leftWidthAdjustmentBar.drag.minimumX
                    cursorShape: (pressed||drag.active||prompter.dragging) ? Qt.ClosedHandCursor : flicking ? Qt.OpenHandCursor : (contentsPlacement ? Qt.PointingHandCursor : Qt.OpenHandCursor)
                    Loader {
                        sourceComponent: editorSidesBorder
                        anchors {top: parent.top; bottom: parent.bottom; horizontalCenter: parent.horizontalCenter}
                    }
                    //onPressed: editor.invertDrag = true
                    //onReleased: {
                    //editor.invertDrag   = false
                    //prompter.setContentWidth()
                    //}
                    //}
                }

                Keys.onPressed: {
                    // Prompter related keys are processed first for faster response times.
                    // Assumption: Editor is focused.
                    if (parseInt(prompter.state) === Prompter.States.Prompting) {
                        // Assumption: We're in edit while prompting mode.
                        // If moving cursor would place it out of bounds that are practical for editing, prevent motion and prevent event from floating up to prompter, which would trigger a change in velocity.
                        if (event.key === Qt.Key_Right && editor.cursorPosition > editor.positionAt(editor.width, prompter.position+overlay.height) - 1
                            || event.key === Qt.Key_Left && editor.cursorPosition < editor.positionAt(0, prompter.position) + 1
                            || event.key === Qt.Key_Down && editor.cursorPosition > editor.positionAt(editor.width, prompter.position+overlay.height-editor.cursorRectangle.height-editor.cursorRectangle.height/4)
                            || event.key === Qt.Key_Up && editor.cursorPosition < editor.positionAt(0, prompter.position+1.5*editor.cursorRectangle.height)) {
                            event.accepted = true;
                            return;
                        }
                        // Prevent programmable keys from typing on editor while prompting
                        switch (event.key) {
                            case keys.increaseVelocity:
                            case keys.decreaseVelocity:
                            case keys.pause:
                            case keys.skipBackwards:
                            case keys.skipForward:
                            case keys.previousMarker:
                            case keys.nextMarker:
                            case keys.toggle:
                                // If in edit while prompting mode, ensure arrow keys and space bar don't float up to prompter so editor can make proper use of them.
                                if (event.key === Qt.Key_Up || event.key === Qt.Key_Down || event.key === Qt.Key_Left || event.key === Qt.Key_Right || event.key === Qt.Key_Space) {
                                    event.accepted = false;
                                    return;
                                }
                                // All other actions should float to prompter, preventing the editor from making use of these keys.
                                event.accepted = true;
                                prompter.Keys.onPressed(event);
                                return;
                            // If Escape is pressed while prompting, return focus to prompter, thus leaving edit while prompting mode.
                            case Qt.Key_Escape:
                                event.accepted = true;
                                prompter.focus = true;
                                return;
                        }
                    }
                    // In all modes, editor should...
                    if (event.modifiers & Qt.ControlModifier)
                        switch (event.key) {
                            case Qt.Key_B:
                                document.bold = !document.bold;
                                return;
                            case Qt.Key_U:
                                document.underline = !document.underline;
                                return;
                            case Qt.Key_I:
                                document.italic = !document.italic;
                                return;
                            case Qt.Key_T:
                                document.strike = !document.strike;
                                return;
                            case Qt.Key_L:
                                document.alignment = Qt.AlignLeft;
                                return;
                            case Qt.Key_R:
                                document.alignment = Qt.AlignRight;
                                return;
                            case Qt.Key_E:
                                document.alignment = Qt.AlignCenter;
                                return;
                            // Justify is proven to make text harder to read for some readers. So I'm commenting out all text justification options from the program. I'm not removing them, only commenting out in case someone needs to re-enable. This article links to various sources that validate my decision: https://kaiweber.wordpress.com/2010/05/31/ragged-right-or-justified-alignment/ - Javier
                            //case Qt.Key_J:
                            //    document.alignment = Qt.AlignJustify;
                            //    return;
                        }
                    // If no modifiers are pressed...
                    else
                        switch (event.key) {
                            // Forward these other keys to prompter.
                            case Qt.Key_V:
                                prompter.Keys.onPressed(event);
                                return;
                            // Change item in focus when Tab is pressed. This is an accessibility feature.
                            case Qt.Key_Tab:
                                event.accepted = true;
                                editor.nextItemInFocusChain().forceActiveFocus();
                                return;
                        }
                }
            }
        }
    }

    DocumentHandler {
        id: document
        property bool isNewFile: false
        property bool quitOnSave: false
        document: editor.textDocument
        cursorPosition: editor.cursorPosition
        selectionStart: editor.selectionStart
        selectionEnd: editor.selectionEnd
        textColor: "#FFF"
        textBackground: "#000"
        Component.onCompleted: {
            if (prompter.performFileOperations) {
                if (Qt.application.arguments.length === 2) {
                    document.load("file:" + Qt.application.arguments[1]);
                    isNewFile = false
                    resetDocumentPosition()
                }
                else
                    loadInstructions();
            }
        }
        
        function resetDocumentPosition() {
            prompter.position = -(overlay.__readRegionPlacement*(overlay.height-overlay.readRegionHeight)+overlay.readRegionHeight/2)
        }
        
        onLoaded: {
            editor.textFormat = format
            editor.text = text
            resetDocumentPosition()
        }
        onError: {
            errorDialog.text = message
            errorDialog.visible = true
        }

        function newDocument() {
            document.load("qrc:/untitled.html")
            isNewFile = true
            resetDocumentPosition()
            if (!root.__translucidBackground)
                showPassiveNotification(i18n("New document"))
        }
        
        function loadInstructions() {
            document.load("qrc:/"+i18n("guide_en.html"))
            isNewFile = true
            // Set document position to 0, so we can get to read the instructions faster.
            prompter.position = 0
            if (!root.__translucidBackground)
                showPassiveNotification(i18n("User guide loaded"))
        }
        
        function open() {
            openDialog.open()
        }
        function saveAsDialog() {
            saveDialog.open()
        }
        function saveDialog(quit=false) {
            document.quitOnSave = quit
            if (isNewFile)
                saveAsDialog()
            else {// if (modified)
                document.saveAs(document.fileUrl)
                if (quit)
                    Qt.quit()
            }
        }
    }
    FileDialog {
        id: openDialog
        selectExisting: true
        selectedNameFilter: nameFilters[0]
        nameFilters: [i18n("Hypertext Markup Language (HTML)") + "(*.html *.htm *.xhtml *.HTML *.HTM *.XHTML)",
            i18n("Markdown (MD)") + "(*.md *.MD)",
            i18n("Plain Text (TXT)") + "(*.txt *.text *.TXT *.TEXT)",
            //i18n("OpenDocument Format Text Document (ODT)") + "(*.odt *.ODT)",
            //i18n("AbiWord Document (ABW)") + "(*.abw *.ABW *.zabw *.ZABW)",
            //i18n("Microsoft Word document (DOCX, DOC)") + "(*.docx *.doc *.DOCX *.DOC)",
            //i18n("Apple Pages Document (PAGES)") + "(*.pages *.PAGES)",
            //i18n("Rich Text Format (RTF)") + "(*.rtf *.RTF)",
            //i18n("Portable Document Format (PDF)") + "(*.pdf *.PDF)",
            i18n("All Formats") + "(*.*)"
        ]
        folder: shortcuts.documents
        onAccepted: {
            document.load(openDialog.fileUrl)
            document.isNewFile = false
        }
    }
    
    FileDialog {
        id: saveDialog
        selectExisting: false
        defaultSuffix: document.fileType
        nameFilters: openDialog.nameFilters
        // Always in the same format as original file
        //selectedNameFilter.index: document.fileType === "txt" ? 0 : 1
        // Always save as HTML
        selectedNameFilter: nameFilters[document.fileType === "txt" ? 0 : 1]
        folder: shortcuts.documents
        onAccepted: {
            document.saveAs(saveDialog.fileUrl)
            document.isNewFile = false
            if (document.quitOnSave)
                Qt.quit()
        }
    }
    
    MessageDialog {
        id: errorDialog
    }

    // Context Menu
    Labs.Menu {
        id: nativeContextMenu
        Labs.MenuItem {
            text: i18n("&Copy")
            enabled: editor.selectedText
            onTriggered: editor.copy()
        }
        Labs.MenuItem {
            text: i18n("Cu&t")
            enabled: editor.selectedText
            onTriggered: editor.cut()
        }
        Labs.MenuItem {
            text: i18n("&Paste")
            enabled: editor.canPaste
            onTriggered: document.paste()
        }
        Labs.MenuSeparator {}
        Labs.MenuItem {
            text: i18n("Fo&nt...")
            onTriggered: fontDialog.open()
        }
        Labs.MenuItem {
            text: i18n("Co&lor...")
            onTriggered: colorDialog.open()
        }
        Labs.MenuItem {
            text: i18n("Hi&ghlight...")
            onTriggered: highlightDialog.open()
        }
    }
    Menu {
        id: contextMenu
        background: Rectangle {
            color: "#DD000000"
            implicitWidth: 120
            //implicitHeight: 30
        }
        MenuItem {
            text: i18n("&Undo")
            enabled: prompter.editor.canUndo
            onTriggered: prompter.editor.undo()
        }
        MenuItem {
            text: i18n("Redo")
            enabled: prompter.editor.canRedo
            onTriggered: prompter.editor.redo()
        }
        MenuSeparator {}
        MenuItem {
            text: i18n("&Copy")
            enabled: editor.selectedText
            onTriggered: editor.copy()
        }
        MenuItem {
            text: i18n("Cu&t")
            enabled: editor.selectedText
            onTriggered: editor.cut()
        }
        MenuItem {
            text: i18n("&Paste")
            enabled: editor.canPaste
            onTriggered: document.paste()
        }
        MenuSeparator {}
        MenuItem {
            text: i18n("Fo&nt...")
            onTriggered: fontDialog.open()
        }
        MenuItem {
            text: i18n("Co&lor...")
            onTriggered: colorDialog.open()
        }
        MenuItem {
            text: i18n("Hi&ghlight...")
            onTriggered: highlightDialog.open()
        }
        MenuSeparator {}
    }

    // Configurable keys commands
    property var keys: {
        "increaseVelocity": Qt.Key_Down,
        "decreaseVelocity": Qt.Key_Up,
        "pause": Qt.Key_Space,
        "skipBackwards": Qt.Key_PageUp,
        "skipForward": Qt.Key_PageDown,
        "previousMarker": Qt.Key_Home,
        "nextMarker": Qt.Key_End,
        "toggle": Qt.Key_F9
    };

    Settings {
        category: "flip"
        property alias x: prompter.__flipX
        property alias y: prompter.__flipY
    }

    // Key bindings
    Keys.onPressed: {
        if (parseInt(prompter.state) === Prompter.States.Prompting) {
            switch (event.key) {
                case keys.increaseVelocity:
                case Qt.Key_VolumeDowm:
                    if (prompter.__invertArrowKeys)
                        prompter.decreaseVelocity(event)                        
                    else
                        prompter.increaseVelocity(event)
                    return
                case keys.decreaseVelocity:
                case Qt.Key_VolumeUp:
                    if (prompter.__invertArrowKeys)
                        prompter.increaseVelocity(event)                        
                    else
                        prompter.decreaseVelocity(event)
                    return
                case keys.pause:
                case Qt.Key_SysReq:
                case Qt.Key_Play:
                case Qt.Key_Pause:
                    //if (!root.__translucidBackground)
                    //    showPassiveNotification((i18n("Toggle Playback"));
                    if (prompter.__play) {
                        prompter.__play = false
                        prompter.position = prompter.position
                    }
                    else {
                        prompter.__play = true
                        prompter.position = prompter.__destination
                    }
                    return
                //default:
                //    // Show key code
                //    showPassiveNotification(event.key)
            }
            // Perform keyCode marker search.
            let namedAnchorPosition = document.keySearch(event.key, document.cursorPosition, false, true);
            if (namedAnchorPosition!==-1)
                prompter.goTo(namedAnchorPosition);
            //// Undo and redo key bindings
            //if (event.matches(StandardKey.Undo))
            //    document.undo();
            //else if (event.matches(StandardKey.Redo))
            //    document.redo();
        }
        // If state is not prompting nor editing
        else if (parseInt(prompter.state) !== Prompter.States.Editing)
            switch (event.key) {
                case keys.pause:
                case Qt.Key_SysReq:
                case Qt.Key_Play:
                case Qt.Key_Pause:
                    prompter.toggle();
                    return;
            }

        // Keys presses that apply the same to all states
        switch (event.key) {
            case keys.toggle:
                prompter.toggle();
                return
            case keys.skipBackwards:
                if (event.modifiers & Qt.ControlModifier)
                    prompter.goToPreviousMarker();
                else if (!this.__atStart) {
                    if (prompter.__play && __i!==0)
                        __iBackup = __i
                    __i=0;
                    prompter.position = prompter.position
                    scrollBar.decrease()
                    __i=__iBackup
                    if (prompter.__play)
                        prompter.position = __destination
                    else
                        prompter.position = prompter.position
                }
                return
            case keys.skipForward:
                if (event.modifiers & Qt.ControlModifier)
                    prompter.goToNextMarker();
                else if (!this.__atEnd) {
                    if (prompter.__play && __i!==0)
                        __iBackup = __i
                    __i=0;
                    prompter.position = prompter.position
                    scrollBar.increase()
                    __i=__iBackup
                    if (prompter.__play)
                        prompter.position = __destination
                    else
                        prompter.position = prompter.position
                }
                return
            //case keys.previousMarker:
            //    prompter.goToPreviousMarker();
            //    return
            //case keys.nextMarker:
            //    prompter.goToNextMarker();
            //    return
            case Qt.Key_Escape:
            case Qt.Key_Back:
                if (parseInt(prompter.state) !== Prompter.States.Editing) {
                    prompter.state = Prompter.States.Editing;
                    return
                }
            case Qt.Key_F:
                if (event.modifiers & Qt.ControlModifier)
                    find.open();
                return
            case Qt.Key_V:
                if (event.modifiers & Qt.ControlModifier && event.modifiers & Qt.ShiftModifier) {
                    event.accepted = true
                    document.paste(true);
                }
                else if (event.modifiers & Qt.ControlModifier) {
                    event.accepted = true
                    document.paste();
                }
                return
        }
    }
    states: [
        State {
            name: Prompter.States.Editing
            //PropertyChanges {
            //target: readRegion
            //__placement: readRegion.__placement
            //}
            //PropertyChanges {
            //target: readRegionButton
            //text: i18n("Custom")
            //iconName: "dialog-ok-apply"
            //}
            PropertyChanges {
                target: overlay
                state: ReadRegionOverlay.States.NotPrompting
            }
            PropertyChanges {
                target: countdown
                state: Countdown.States.Standby
            }
            PropertyChanges {
                target: editor
                focus: true
                selectByMouse: true
                activeFocusOnPress: true
                //cursorPosition: editor.positionAt(0, editor.position + 1*overlay.height/2)
            }
            PropertyChanges {
                target: root
                //prompterVisibility: Kirigami.ApplicationWindow.Maximized
            }
            PropertyChanges {
                target: prompter
                z: 2
                __i: 0
                __play: false
                position: position
                timeToArival: 0
            }
        },
        State {
            name: Prompter.States.Standby
            PropertyChanges {
                target: overlay
                state: ReadRegionOverlay.States.Prompting
            }
            PropertyChanges {
                target: countdown
                state: Countdown.States.Ready
            }
            PropertyChanges {
                target: timer
                elapsedSeconds: 0
            }
            //PropertyChanges {
            //    target: root
            //    //prompterVisibility: Kirigami.ApplicationWindow.FullScreen
            //}
            PropertyChanges {
                target: prompterBackground
                opacity: root.__translucidBackground ? root.__opacity : 1
            }
            PropertyChanges {
                target: promptingButton
                text: viewport.countdown.enabled ? i18n("Begin countdown") : i18n("Start prompting")
            }
            PropertyChanges {
                target: prompter
                z: 1
                __iBackup: 0
                position: position
                timeToArival: 0
                focus: true
                //timeToArival: Kirigami.Units.shortDuration
            }
            PropertyChanges {
                target: editor
                selectByMouse: false
                activeFocusOnPress: true
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
        },
        State {
            name: Prompter.States.Countdown
            PropertyChanges {
                target: overlay
                state: ReadRegionOverlay.States.Prompting
            }
            PropertyChanges {
                target: countdown
                state: Countdown.States.Running
            }
            PropertyChanges {
                target: timer
                elapsedSeconds: 0
            }
            PropertyChanges {
                target: root
                //prompterVisibility: Kirigami.ApplicationWindow.FullScreen
            }
            PropertyChanges {
                target: prompterBackground
                opacity: root.__translucidBackground ? root.__opacity : 1
            }
            PropertyChanges {
                target: promptingButton
                text: i18n("Skip countdown")
            }
            PropertyChanges {
                target: prompter
                z: 1
                __iBackup: 0
                position: position
                timeToArival: 0
                focus: true
            }
            PropertyChanges {
                target: editor
                selectByMouse: false
                activeFocusOnPress: true
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
        },
        State {
            name: Prompter.States.Prompting
            PropertyChanges {
                target: overlay
                state: ReadRegionOverlay.States.Prompting
            }
            PropertyChanges {
                target: timer
                running: prompter.__play && prompter.__velocity>0
                elapsedSeconds: 0
            }
            PropertyChanges {
                target: root
                //prompterVisibility: Kirigami.ApplicationWindow.FullScreen
            }
            PropertyChanges {
                target: prompterBackground
                opacity: root.__translucidBackground ? root.__opacity : 1
            }
            PropertyChanges {
                target: promptingButton
                text: i18n("Return to edit mode")
                iconName: Qt.application.layoutDirection===Qt.LeftToRight ? "edit-undo" : "edit-redo"
            }
            PropertyChanges {
                target: prompter
                z: 1
                __i: __iDefault
                __iBackup: 0
                position: prompter.__destination
                focus: true
                __play: true
                timeToArival: __timeToArival
            }
            PropertyChanges {
                target: editor
                selectByMouse: false
                focus: false
                activeFocusOnPress: false
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
            PropertyChanges {
                target: limitedMouse
                enabled: true
            }
        }
    ]
    state: Prompter.States.Editing
    onStateChanged: {
        setCursorAtCurrentPosition()
        var pos = prompter.position
        position = pos
        timer.updateStopwatchText()
    }
    function setCursorAtCurrentPosition() {
        editor.cursorPosition = editor.positionAt(0, position + overlay.__readRegionPlacement*(overlay.height-overlay.readRegionHeight)+overlay.readRegionHeight/2 + 1)
    }
    transitions: [
        Transition {
            to: Prompter.States.Standby
            ScriptAction  {
                // Jump into position
                script: {
                    // Auto frame to current line
                    position = editor.cursorRectangle.y - (overlay.__readRegionPlacement*(overlay.height-overlay.readRegionHeight)+overlay.readRegionHeight/2) + 1
                }
            }
        }
    ]

    // Progress indicator
    ScrollBar.vertical: ProgressIndicator {
        id: scrollBar
    }
}
