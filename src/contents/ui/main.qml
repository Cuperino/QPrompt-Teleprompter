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
//import QColor 1.0
//import Qt.Math 1.0

import com.cuperino.qprompt.document 1.0

Kirigami.ApplicationWindow {
    id: root

    title: i18n("QPrompt")
    minimumWidth: 480
    minimumHeight: 380

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
        //Kirigami.Page {
            title: i18n("QPrompt")

            actions {
                main: Kirigami.Action {
                    text: i18n("Start Prompting")
                    iconName: "go-next"
                    onTriggered: showPassiveNotification(i18n("Prompt started"))
                }
                left: Kirigami.Action {
                    iconName: "go-previous"
                    onTriggered: showPassiveNotification(i18n("Decrease Velocity"))
                }
                right: Kirigami.Action {
                    iconName: "go-next"
                    onTriggered: showPassiveNotification(i18n("Increase Velocity"))
                }
                // Use action toolbar instead?
                //ActionToolBar
                contextualActions: [
                    Kirigami.Action {
                        text: i18n("&Copy")
                        iconName: "copy"
                        onTriggered: editor.copy()
                    },
                    Kirigami.Action {
                        text: i18n("Cut")
                        iconName: "cut"
                        onTriggered: editor.cut()
                    },
                    Kirigami.Action {
                        text: i18n("&Paste")
                        iconName: "paste"
                        onTriggered: editor.paste()
                    },
                    Kirigami.Action {
                        text: i18n("&Bold")
                        iconName: "bold"
                        onTriggered: document.bold = !document.bold
                    },
                    Kirigami.Action {
                        text: i18n("&Italic")
                        iconName: "italic"
                        onTriggered: document.italic = !document.italic
                    },
                    Kirigami.Action {
                        text: i18n("&Underline")
                        iconName: "underline"
                        onTriggered: document.underline = !document.underline
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
                //enabled: false
                property double __opacity: 0.4
                property color __color: 'black'
//                 anchors.fill: parent
                anchors {
                    left: editor.left
                    top: parent.top
                    bottom: parent.bottom
                }
                width: editor.width
                //MouseArea {
                //    anchors.fill: parent
                //    cursorShape: Qt.CrossCursor
                //    propagateComposedEvents: true
                //}
                Item {
                    id: readRegion
                    property double __placement: 0.5
                    height: 21 * prompter.__vw
                    y: readRegion.__placement * (overlay.height - readRegion.height)
                    anchors.left: parent.left
                    anchors.right: parent.right
                    MouseArea {
                        anchors.fill: parent
                        drag.target: parent
                        drag.axis: Drag.YAxis
                        drag.smoothed: false
                        drag.minimumY: 0
                        drag.maximumY: overlay.height - this.height
                        cursorShape: Qt.PointingHandCursor
                        onReleased: {
                            readRegion.__placement = readRegion.y / (overlay.height - readRegion.height)
                        }
                    }
                    Item {
                        id: triangles
                        property double __opacity: 0.4
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
                            anchors.right: parent.parent.right
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
                contentY: __destination
                onFlickStarted: {
                    console.log("Flick started")
                    //motion.enabled = false
                    //contentY = contentY
                }
                onFlickEnded: {
                    console.log("Flick ended")
                    //motion.enabled = true
                    //contentY: __destination
                }
                
                //property int __time_to_arival: (prompter.contentHeight - prompter.position)
                flickableDirection: Flickable.VerticalFlick
                anchors.fill: parent

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
                    
                    // Key bindings                 
                    Keys.onPressed: {
                        switch (event.key) {
                            //case Qt.Key_S:
                            case Qt.Key_Down:
                                event.accepted = true;
                                prompter.__i++
                                //prompter.__time_to_arival = 5000
                                //prompter.position = prompter.position
                                //prompter.position = prompter.contentHeight - prompter.height
                                showPassiveNotification(i18n("Increase Velocity"));
                                break;
                            //case Qt.Key_W:
                            case Qt.Key_Up:
                                event.accepted = true;
                                prompter.__i--
                                //prompter.__time_to_arival = 50
                                //prompter.position = prompter.position
                                //prompter.position = 0
                                showPassiveNotification(i18n("Decrease Velocity"));
                                break;
                            case Qt.Key_Space:
                                showPassiveNotification(i18n("Toggle Playback"));
                                console.log(motion.paused)
                                //motion.paused = !motion.paused
                                //if (motion.paused)
                                    //motion.resume()
                                //else
                                    //motion.pause()
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
                    
                    // Make links responsive
                    onLinkActivated: Qt.openUrlExternally(link)
                }
                //ScrollBar.vertical: ScrollBar {
                ////ScrollIndicator.vertical: ScrollIndicator{
                    //id: scroller
                    //policy: ScrollBar.AlwaysOn
                    //position: 1
                //}
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
            }
            //Kirigami.OverlaySheet {
                //id: sheet
                //onSheetOpenChanged: page.actions.main.checked = sheetOpen
                //Label {
                    //wrapMode: Text.WordWrap
                    //text: "Lorem ipsum dolor sit amet"
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
