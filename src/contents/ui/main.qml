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
//import QColor 1.0
//import Qt.Math 1.0

import com.cuperino.qprompt.document 1.0

Kirigami.ApplicationWindow {
    id: root
    
    title: i18n("QPrompt")
    minimumWidth: 480
    minimumHeight: 380
    //visibility: Window.FullScreen

    globalDrawer: Kirigami.GlobalDrawer {
        title: i18n("QPrompt")
        titleIcon: "applications-graphics"
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
                    text: i18n("Start Prompting")
                    iconName: "go-next"
                    onTriggered: {
                        showPassiveNotification(i18n("Prompt started"))
                        // Enter full screen
                        root.showFullScreen()
                        root.controlsVisible = false
                    }
                }
                left: Kirigami.Action {
                    iconName: "go-previous"
                    onTriggered: {
                        showPassiveNotification(i18n("Decrease Velocity"))
                        console.log(Kirigami.Theme.View.backgroundColor)
                    }
                }
                right: Kirigami.Action {
                    iconName: "go-next"
                    onTriggered: showPassiveNotification(i18n("Increase Velocity"))
                }
                // Use action toolbar instead?
                //ActionToolBar
                contextualActions: [
                    Kirigami.Action {
                        id: readRegionButton
                        text: i18n("Region")
                        iconName: "middle"
                        onTriggered: readRegion.toggle()
                        tooltip: i18n("Toggle read line position")
                    }
//                    Kirigami.Action {
//                        text: i18n("LOL")
//                         iconName: "go-next"
//                        onTriggered: showPassiveNotification(i18n("Contextual action 1 clicked"))
//                    }
                ]
            }
            
            Item {
                id: overlay
                property double __opacity: 0
                property color __color: 'black'
                anchors {
                    left: parent.left
                    top: parent.top
                    //bottom: parent.bottom// - prompter.parent.implicitFooterHeight 
                }
                width: editor.implicitWidth
                height: prompter.height //prompter.parent.implicitFooterHeight
                //MouseArea {
                //    anchors.fill: parent
                //    cursorShape: Qt.CrossCursor
                //    propagateComposedEvents: true
                //}
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
                            PropertyAnimation {
                                targets: readRegion
                                properties: "__placement"; duration: 200; easing.type: Easing.OutQuad
                            }
                            PropertyAnimation {
                                targets: overlay
                                properties: "__opacity"; duration: 200; easing.type: Easing.OutQuad
                            }
                            PropertyAnimation {
                                targets: triangles
                                properties: "__fillColor"; duration: 200; easing.type: Easing.OutQuad
                            }
                        }/*,
                        Transition {
                            from: "*"; to: "*"
                            PropertyAnimation {
                                targets: readRegion
                                properties: "__placement"; duration: 200; easing.type: Easing.OutQuad
                            }
                        }*/
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
            
            ScrollBar.vertical: ScrollBar {
                id: scroller
                
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
                property int __i: 0
                property double __baseSpeed: 1.0
                property double __curvature: 1.35
                readonly property double __vw: prompter.width*0.01
                readonly property double __velocity: __baseSpeed * Math.pow(Math.abs(__i), __curvature)
                readonly property double __time_to_arival: __i ? (__i<0 ? prompter.position : (prompter.contentHeight-prompter.position)) / (Math.abs(__velocity * __vw)) << 8 : 0;
                property int __destination: (__i ? (__i<0 ? __i%2 : prompter.contentHeight - __i%2) : prompter.position);

                //
                onFlickStarted: {
                    //console.log("Flick started")
                    //motion.enabled = false
                    //contentY = contentY
                }
                onFlickEnded: {
                    //console.log("Flick ended")
                    //motion.enabled = true
                    //contentY = __destination
                }

                //property int __time_to_arival: (prompter.contentHeight - prompter.position)
                flickableDirection: Flickable.VerticalFlick
//                 anchors.top: parent.top
//                 anchors.left: parent.left
//                 anchors.right: parent.right
//                 anchors.bottom: toolbar.top

                Behavior on position {
                    id: motion
                    enabled: true
                    animation: NumberAnimation {
                        //paused: !__play
                        duration: prompter.__time_to_arival
                        //from: "*"
                        //to: "*"
                        onFinished: {
                            console.log("Animation Completed")
                            prompter.__i = 0
                        }
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
                    background: null

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
                    switch (event.key) {
                        //case Qt.Key_S:
                        case Qt.Key_Down:
                            event.accepted = true;
                            prompter.__i++
                            prompter.contentY = prompter.__destination
                            prompter.__play = true
                            showPassiveNotification(i18n("Increase Velocity"));
                            break;
                        //case Qt.Key_W:
                        case Qt.Key_Up:
                            event.accepted = true;
                            prompter.__i--
                            prompter.contentY = prompter.__destination
                            prompter.__play = true
                            showPassiveNotification(i18n("Decrease Velocity"));
                            break;
                        case Qt.Key_Space:
                            showPassiveNotification(i18n("Toggle Playback"));
                            //console.log(motion.paused)
                            //motion.paused = !motion.paused
                            if (prompter.__play) //{
                                prompter.contentY = prompter.contentY
                                //    motion.resume()
                            //}
                            else //{
                                prompter.contentY = prompter.__destination
                                //    motion.pause()
                            //}
                            prompter.__play = !prompter.__play
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
            }

            footer: ToolBar {
                id: toolbar

                background: null
//                 anchors.bottom: parent.bottom
//                 anchors.left: parent.left
//                 anchors.right: parent.right
                RowLayout {
                    anchors.fill: parent
                    ToolButton {
                        text: i18n("&Copy")
                        icon.name: "copy"
                        onClicked: editor.copy()
                    }
                    ToolButton {
                        text: i18n("Cut")
                        icon.name: "cut"
                        onClicked: editor.cut()
                    }
                    ToolButton {
                        text: i18n("&Paste")
                        icon.name: "paste"
                        onClicked: editor.paste()
                    }
                    ToolButton {
                        text: i18n("&Bold")
                        icon.name: "bold"
                        onClicked: document.bold = !document.bold
                    }
                    ToolButton {
                        text: i18n("&Italic")
                        icon.name: "italic"
                        onClicked: document.italic = !document.italic
                    }
                    ToolButton {
                        text: i18n("&Underline")
                        icon.name: "underline"
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
