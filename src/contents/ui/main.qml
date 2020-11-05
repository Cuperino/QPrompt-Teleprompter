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
import QtQuick.Window 2.0
import Qt.labs.platform 1.0
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

            // Flickable makes the element scrollable and touch friendly
            //// Define Flickable element using the flickable property only íf the flickable component (the prompter in this case)
            //// has some non standard properties, such as not covering the whole Page. Otherwise, use element like everywhere else
            //// and use Kirigami.ScrollablePage instead of page.
            //flickable: Flickable {
            Flickable {
                id: prompter
                // property int __unit: 1
                property bool __play: true
                property int __i: 0
                property double __vw: prompter.width*0.01
                property double __baseSpeed: 1.0
                property double __curvature: 1.45
                property double __velocity: __baseSpeed * Math.pow(Math.abs(__i), __curvature)
                property double __time_to_arival: __i ? (__i<0 ? prompter.contentY : (prompter.contentHeight-prompter.contentY)) / (Math.abs(__velocity * __vw)) << 9 : 0;
                property int __destination: (__i ? (__i<0 ? __i%2*(__i%2?1:2) : prompter.contentHeight - __i%2*(__i%2?1:2)) : prompter.contentY);

                //
                contentY: __destination

                //property int __time_to_arival: (prompter.contentHeight - prompter.contentY)
                flickableDirection: Flickable.VerticalFlick
                anchors.fill: parent

                Behavior on contentY {
                    NumberAnimation {
                        id: motion
                        //paused: !__play
                        duration: prompter.__time_to_arival
                        //from: "*"
                        //to: "*"
                    }
                    //easing.type: Easing.Linear
                    //finished: {
                    //    prompter.__i = 0
                    //}
                }
                
                TextArea.flickable: TextArea {
                    id: editor
                    textFormat: Qt.RichText
                    wrapMode: TextArea.Wrap
                    readOnly: true
                    text: "QPrompt is a Free Software and open source teleprompter software for professionals."
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
                            case Qt.Key_S:
                            case Qt.Key_Down:
                                prompter.__i++
                                //prompter.__time_to_arival = 5000
                                //prompter.contentY = prompter.contentY
                                //prompter.contentY = prompter.contentHeight - prompter.height
                                showPassiveNotification(i18n("Increase Velocity"));
                                break;
                            case Qt.Key_W:
                            case Qt.Key_Up:
                                prompter.__i--
                                //prompter.__time_to_arival = 50
                                //prompter.contentY = prompter.contentY
                                //prompter.contentY = 0
                                showPassiveNotification(i18n("Decrease Velocity"));
                                break;
                            case Qt.Key_Space:
                                showPassiveNotification(i18n("Toggle Playback"));
                                console.log(motion.paused)
                                motion.paused = !motion.paused
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
