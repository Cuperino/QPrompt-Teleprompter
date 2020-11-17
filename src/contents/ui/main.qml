/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2020 Javier O. Cordero Pérez
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
import QtQuick.Shapes 1.15
import QtQuick.Window 2.0
import Qt.labs.platform 1.0
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.12

import com.cuperino.qprompt.document 1.0

Kirigami.ApplicationWindow {
    id: root
    
    property bool __autoFullScreen: false
    property int prompterVisibility: Kirigami.ApplicationWindow.AutomaticVisibility
    
    title: i18n("QPrompt")
    minimumWidth: 480
    minimumHeight: 380
    // Changing the theme in this way does not affect the whole app for some reason.
    //Material.theme: Material.Light
    background: Rectangle {
        id: appBackground
        property color __color: parent.Material.theme===Material.Light ? "#fafafa" : "#424242"
        color: __color
        opacity: 1
    }
    // Full screen
    visibility: __autoFullScreen ? prompterVisibility : Kirigami.ApplicationWindow.AutomaticVisibility
    onVisibilityChanged: {
        if (visibility!==Kirigami.ApplicationWindow.FullScreen)
            console.log("left fullscreen");
            //position = editor.positionAt(0, prompter.position + readRegion.__placement*overlay.height)
    }

    ////The following code should be implemented on the Kirigami framework itself and contributed upstream.
    //MouseArea{
    //    property int prevX: 0
    //    property int prevY: 0
    //
    //    anchors.fill: parent
    //    propagateComposedEvents: true
    //
    //    onPressed: {
    //        prevX=mouse.x
    //        prevY=mouse.y
    //    }
    //    onPositionChanged: {
    //        var deltaX = mouse.x - prevX;
    //
    //        root.x += deltaX;
    //        prevX = mouse.x - deltaX;
    //
    //        var deltaY = mouse.y - prevY
    //        root.y += deltaY;
    //        prevY = mouse.y - deltaY;
    //    }
    //}
    
    globalDrawer: Kirigami.GlobalDrawer {
        title: i18n("QPrompt")
        titleIcon: "applications-graphics"
        background: Rectangle {
            color: appBackground.__color
            opacity: 1
        }
        
        actions: [
            Kirigami.Action {
                text: i18n("New")
                iconName: "folder"
                onTriggered: showPassiveNotification(i18n("New clicked"))
            },
            Kirigami.Action {
                text: i18n("Open")
                iconName: "folder"
                onTriggered: openDialog.open()
            },
            Kirigami.Action {
                text: i18n("Save")
                iconName: "folder"
                onTriggered: showPassiveNotification(i18n("Save clicked"))
            },
            Kirigami.Action {
                text: i18n("Save As")
                iconName: "folder"
                onTriggered: saveDialog.open()
            },
            Kirigami.Action {
                text: i18n("File")
                iconName: "view-list-icons"
                Kirigami.Action {
                    text: i18n("View Action 1")
                    onTriggered: showPassiveNotification(i18n("View Action 1 clicked"))
                }
                Kirigami.Action {
                    text: i18n("View Action 2")
                    onTriggered: showPassiveNotification(i18n("View Action 2 clicked"))
                }
            },
            Kirigami.Action {
                text: i18n("&Quit")
                iconName: "close"
                onTriggered: close()
            }
        ]
    }

    contextDrawer: Kirigami.ContextDrawer {
        id: contextDrawer
    }

    pageStack.initialPage: prompterPage

    Component {
        id: prompterPage

        Kirigami.ScrollablePage {
            title: i18n("QPrompt")
            actions {
                main: Kirigami.Action {
                    id: promptingButton
                    text: i18n("Start prompting")
                    iconName: "go-next"
                    onTriggered: {
                        // Update position
                        var verticalPosition = prompter.position + readRegion.__placement*overlay.height
                        var cursorPosition = editor.positionAt(0, verticalPosition)
                        editor.cursorPosition = cursorPosition

                        // Enter full screen
                        var states = ["editing", "prompting"]
                        var nextIndex = ( states.indexOf(prompter.state) + 1 ) % states.length
                        prompter.state = states[nextIndex]
                        
                        switch (prompter.state) {
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
                }
                left: Kirigami.Action {
                    iconName: "go-previous"
                    onTriggered: prompter.decreaseVelocity(false)
                }
                right: Kirigami.Action {
                    iconName: "go-next"
                    onTriggered: prompter.increaseVelocity(false)
                }
                // Use action toolbar instead?
                //ActionToolBar
                contextualActions: [
                    Kirigami.Action {
                        id: flipButton
                        text: i18n("Flip")
                        iconName: "refresh"
                        onTriggered: {
                            if (prompter.__flipX && prompter.__flipY) {
                                prompter.__flipX = false
                                prompter.__flipY = false
                                text = i18n("No Flip")
                                showPassiveNotification(i18n("No Flip"))
                            }
                            else if (prompter.__flipY) {
                                prompter.__flipX = true
                                text = i18n("XY Flip")
                                showPassiveNotification(i18n("180° rotation"))
                            }
                            else if (prompter.__flipX) {
                                prompter.__flipX = false
                                prompter.__flipY = true
                                text = i18n("Y Flip")
                                showPassiveNotification(i18n("Vertical Flip"))
                            }
                            else {
                                prompter.__flipX = true
                                text = i18n("X Flip")
                                showPassiveNotification(i18n("Horizontal Flip"))
                            }
                        }
                    },
                    Kirigami.Action {
                        id: readRegionButton
                        iconName: "middle"
                        text: i18n("Region")
                        onTriggered: readRegion.toggle()
                        tooltip: i18n("Toggle read line position")
                    }
                ]
            }
            
            Item {
                id: overlay
                property double __opacity: 0
                property color __color: 'black'
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    //bottom: parent.bottom// - prompter.parent.implicitFooterHeight 
                }
                //width: editor.width
                height: prompter.height //prompter.parent.implicitFooterHeight
                MouseArea {
                    id: overlayMouseArea
                    enabled: false
                    anchors.fill: parent
                    cursorShape: Qt.DefaultCursor
                    propagateComposedEvents: true
                }
                Item {
                    id: readRegion
                    enabled: false
                    property double __customPlacement: 0.5
                    property double __placement: __customPlacement
                    height: 21 * prompter.__vw
                    y: readRegion.__placement * (overlay.height - readRegion.height)
                    anchors.left: parent.left
                    anchors.right: parent.right
                    states: [
                        State {
                            name: "top"
                            PropertyChanges {
                                target: readRegion
                                __placement: 0
                            }
                            PropertyChanges {
                                target: readRegionButton
                                text: i18n("Top")
                                iconName: "go-up"
                                //iconName: "gtk-goto-top"
                            }
                        },
                        State {
                            name: "middle"
                            PropertyChanges {
                                target: readRegion
                                __placement: 0.5
                            }
                            PropertyChanges {
                                target: readRegionButton
                                text: i18n("Middle")
                                iconName: "remove"
                            }
                        },
                        State {
                            name: "bottom"
                            PropertyChanges {
                                target: readRegion
                                __placement: 1
                            }
                            PropertyChanges {
                                target: readRegionButton
                                text: i18n("Bottom")
                                iconName: "go-down"
                                //iconName: "gtk-goto-bottom"
                            }
                        },
                        State {
                            name: "free"
                            PropertyChanges {
                                target: overlay
                                __opacity: 0.4
                            }
                            PropertyChanges {
                                target: triangles
                                __opacity: 0.4
                            }
                            PropertyChanges {
                                target: readRegion
                                enabled: true
                            }
                            PropertyChanges {
                                target: triangles
                                __fillColor: "#180000"
                            }
                            PropertyChanges {
                                target: readRegionButton
                                text: i18n("Free")
                                iconName: "gtk-edit"
                            }
                        },
                        State {
                            name: "fixed"
                            PropertyChanges {
                                target: readRegion
                                __placement: readRegion.__placement
                            }
                            PropertyChanges {
                                target: readRegionButton
                                text: i18n("Custom")
                                iconName: "gtk-apply"
                            }
                        }
                    ]
                    state: "middle"
                    function toggle() {
                        var states = ["top", "middle", "bottom", "free", "fixed"]
                        var nextIndex = ( states.indexOf(readRegion.state) + 1 ) % states.length
                        readRegion.state = states[nextIndex]
                    }
                    transitions: [
                        Transition {
                            from: "*"; to: "*"
                            NumberAnimation {
                                targets: readRegion
                                properties: "__placement"; duration: 200; easing.type: Easing.OutQuad
                            }
                            NumberAnimation {
                                targets: triangles
                                properties: "__fillColor"; duration: 250;
                            }
                            NumberAnimation {
                                targets: overlay
                                properties: "__opacity"; duration: 250;
                            }
                        }
                    ]
                    MouseArea {
                        anchors.fill: parent
                        drag.target: parent
                        drag.axis: Drag.YAxis
                        drag.smoothed: false
                        drag.minimumY: 0
                        drag.maximumY: overlay.height - this.height
                        cursorShape: Qt.PointingHandCursor
                        onReleased: {
                            readRegion.__customPlacement = readRegion.y / (overlay.height - readRegion.height)
                        }
                    }
                    Item {
                        id: triangles
                        property double __opacity: 0.08
                        property color __strokeColor: "lightgray"
                        property color __fillColor: "#001800"
                        property double __offsetX: 0.3333
                        property double __stretchX: 0.3333
                        readonly property double __triangleUnit: parent.height / 6
                        Shape {
                            opacity: triangles.__opacity
                            ShapePath {
                                strokeWidth: 3
                                strokeColor: triangles.__strokeColor
                                fillColor: triangles.__fillColor
                                // Top left starting point                                
                                startX: triangles.__offsetX*triangles.__triangleUnit; startY: 1*triangles.__triangleUnit
                                // Bottom left
                                PathLine { x: triangles.__offsetX*triangles.__triangleUnit; y: 5*triangles.__triangleUnit }
                                // Center right
                                PathLine { x: (3*triangles.__stretchX+triangles.__offsetX)*triangles.__triangleUnit; y: 3*triangles.__triangleUnit }
                                // Top left return
                                PathLine { x: triangles.__offsetX*triangles.__triangleUnit; y: 1*triangles.__triangleUnit }
                            }
                        }
                        Shape {
                            opacity: triangles.__opacity
                            x: parent.parent.width
                            ShapePath {
                                strokeWidth: 3
                                strokeColor: triangles.__strokeColor
                                fillColor: triangles.__fillColor
                                // Top right starting point                                
                                startX: -triangles.__offsetX*triangles.__triangleUnit; startY: 1*triangles.__triangleUnit
                                // Bottom right
                                PathLine { x: -triangles.__offsetX*triangles.__triangleUnit; y: 5*triangles.__triangleUnit }
                                // Center left
                                PathLine { x: -(3*triangles.__stretchX+triangles.__offsetX)*triangles.__triangleUnit; y: 3*triangles.__triangleUnit }
                                // Top right return
                                PathLine { x: -triangles.__offsetX*triangles.__triangleUnit; y: 1*triangles.__triangleUnit }
                            }
                        }
                    }
                }
                Rectangle {
                    anchors.top: parent.top
                    anchors.bottom: readRegion.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    opacity: overlay.__opacity
                    color: overlay.__color
                }
                Rectangle {
                    anchors.top: readRegion.bottom
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    opacity: overlay.__opacity
                    color: overlay.__color
                }
            }

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
                    Component.onCompleted: document.load("qrc:/texteditor.html")
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
                            target: readRegion
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

            footer: ToolBar {   
                id: toolbar
                
                background: Rectangle {
                    color: appBackground.__color
                }
                palette.text: "white"
                RowLayout {
                    anchors.fill: parent
                    ToolButton {
                        //text: i18n("Bookmark")
                        icon.name: "bookmarks"
                        icon.color: palette.buttonText
                        onClicked: editor.bookmark()
                    }
                    ToolButton {
                        //text: i18n("Undo")
                        icon.name: "edit-undo"
                        icon.color: palette.buttonText
                        onClicked: editor.undo()
                    }
                    ToolButton {
                        //text: i18n("Redo")
                        icon.name: "edit-redo"
                        icon.color: palette.buttonText
                        onClicked: editor.redo()
                    }
                    ToolButton {
                        //text: i18n("&Copy")
                        icon.name: "edit-copy"
                        icon.color: palette.buttonText
                        onClicked: editor.copy()
                    }
                    ToolButton {
                        //text: i18n("Cut")
                        icon.name: "edit-cut"
                        icon.color: palette.buttonText
                        onClicked: editor.cut()
                    }
                    ToolButton {
                        //text: i18n("&Paste")
                        icon.name: "edit-paste"
                        icon.color: palette.buttonText
                        onClicked: editor.paste()
                    }
                    ToolButton {
                        //text: i18n("&Bold")
                        icon.name: "gtk-bold"
                        icon.color: palette.buttonText
                        onClicked: document.bold = !document.bold
                    }
                    ToolButton {
                        //text: i18n("&Italic")
                        icon.name: "gtk-italic"
                        icon.color: palette.buttonText
                        onClicked: document.italic = !document.italic
                    }
                    ToolButton {
                        //Text {
                            //text: i18n("Underline")
                            //color: palette.buttonText
                            //anchors.fill: parent
                            //fontSizeMode: Text.Fit
                            //horizontalAlignment: Text.AlignHCenter
                            //verticalAlignment: Text.AlignVCenter
                        //}
                        //text: i18n("&Underline")
                        icon.name: "gtk-underline"
                        icon.color: palette.buttonText
                        onClicked: document.underline = !document.underline
                    }
                }
            }
            
            //Kirigami.OverlaySheet {
                //id: sheet
                //onSheetOpenChanged: page.actions.main.checked = sheetOpen
                //Label {
                    //wrapMode: Text.WordWrap
                    //text: "Lorem ipsum dolor sit amet"
                //}
            //}
            // Having a separate layer for backgrounds doesn't work because of QtQuick renderer optimizations.
            //Item {
                //id: backgrounds
                //anchors.fill: parent
                //Rectangle {
                    //id: headerBackgrounds
                    //color: "white"
                    //anchors.top: parent.top
                    //anchors.left: parent.left
                    //anchors.right: parent.right
                    //anchors.bottom: editor.top
                    //height: 50
                //}
                //Rectangle {
                //id: bodyBackgrounds
                //color: "white"
                //opacity: 0.2
                //anchors.fill: prompter
                //}
            //}
        }
    }
    
    MenuBar {
        Menu {
            title: qsTr("&File")

            MenuItem {
                text: qsTr("&Open")
                onTriggered: openDialog.open()
            }
            MenuItem {
                text: qsTr("&Save As...")
                onTriggered: saveDialog.open()
            }
            MenuItem {
                text: qsTr("&Quit")
                onTriggered: close()
            }
        }

        Menu {
            title: qsTr("&Edit")

            MenuItem {
                text: qsTr("&Copy")
                enabled: this.editor.selectedText
                onTriggered: this.editor.copy()
            }
            MenuItem {
                text: qsTr("Cu&t")
                enabled: this.editor.selectedText
                onTriggered: this.editor.cut()
            }
            MenuItem {
                text: qsTr("&Paste")
                enabled: this.editor.canPaste
                onTriggered: this.editor.paste()
            }
        }
        
        Menu {
            title: qsTr("V&iew")
            
            MenuItem {
                text: qsTr("&Auto full screen on start")
                checkable: true
                checked: root.__autoFullScreen
                onTriggered: root.__autoFullScreen = !root.__autoFullScreen
            }
        }
        Menu {
            title: qsTr("F&ormat")

            MenuItem {
                text: qsTr("&Bold")
                checkable: true
                checked: this.prompter.document.bold
                onTriggered: document.bold = !document.bold
            }
            MenuItem {
                text: qsTr("&Italic")
                checkable: true
                checked: document.italic
                onTriggered: document.italic = !document.italic
            }
            MenuItem {
                text: qsTr("&Underline")
                checkable: true
                checked: document.underline
                onTriggered: document.underline = !document.underline
            }
        }
    }

    FileDialog {
        id: openDialog
        fileMode: FileDialog.OpenFile
        selectedNameFilter.index: 1
        nameFilters: ["Text files (*.txt)", "HTML files (*.html *.htm)"]
        folder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
        onAccepted: document.load(file)
    }

    FileDialog {
        id: saveDialog
        fileMode: FileDialog.SaveFile
        defaultSuffix: document.fileType
        nameFilters: openDialog.nameFilters
        selectedNameFilter.index: document.fileType === "txt" ? 0 : 1
        folder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
        onAccepted: document.saveAs(file)
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

    MessageDialog {
        id: errorDialog
    }

    MessageDialog {
        id : quitDialog
        title: qsTr("Quit?")
        text: qsTr("The file has been modified. Quit anyway?")
        buttons: (MessageDialog.Yes | MessageDialog.No)
        onYesClicked: Qt.quit()
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

    // Open save dialog on closing
    onClosing: {
        if (document.modified) {
            quitDialog.open()
            close.accepted = false
        }
    }

}
