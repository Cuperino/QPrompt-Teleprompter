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
import QtQuick.Shapes 1.15
import QtQuick.Window 2.0
import Qt.labs.platform 1.0
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.12

import com.cuperino.qprompt.document 1.0

Kirigami.ApplicationWindow {
    id: root
    
    property bool __autoFullScreen: false
    property bool __translucidBackground: false
    property int prompterVisibility: Kirigami.ApplicationWindow.AutomaticVisibility
    
    title: document.fileName + " - QPrompt"
    
    minimumWidth: 480
    minimumHeight: 380
    // Changing the theme in this way does not affect the whole app for some reason.
    //Material.theme: Material.Light
    background: Rectangle {
        id: appBackground
        property color __color: parent.Material.theme===Material.Light ? "#fafafa" : "#424242"
        color: __color
        opacity: 1
        
        Behavior on opacity {
            enabled: true
            animation: NumberAnimation {
                duration: 250
                easing.type: Easing.OutQuad
            }
        }
    }
    // Full screen
    visibility: __autoFullScreen ? prompterVisibility : Kirigami.ApplicationWindow.AutomaticVisibility
    onVisibilityChanged: {
        if (visibility!==Kirigami.ApplicationWindow.FullScreen)
            console.log("left fullscreen");
            //position = prompter.positionAt(0, prompter.position + readRegion.__placement*overlay.height)
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
        title: "QPrompt"
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
            title: "QPrompt"
            actions {
                main: Kirigami.Action {
                    id: promptingButton
                    text: i18n("Start prompting")
                    iconName: "go-next"
                    onTriggered: prompter.toggle()
                }
                left: Kirigami.Action {
                    id: decreaseVelocityButton
                    enabled: false
                    iconName: "go-previous"
                    onTriggered: prompter.decreaseVelocity(false)
                }
                right: Kirigami.Action {
                    id: increaseVelocityButton
                    enabled: false
                    iconName: "go-next"
                    onTriggered: prompter.increaseVelocity(false)
                }
                // Use action toolbar instead?
                //ActionToolBar
                contextualActions: [
                
                    Kirigami.Action {
                        id: wysiwygButton
                        text: prompter.__wysiwyg ? i18n("WYSIWYG: On") : i18n("WYSIWYG: Off")
                        iconName: "edit-left"
                        checkable: true
                        checked: prompter.__wysiwyg
                        tooltip: prompter.__wysiwyg ? i18n("\"What you see is what you get\" mode is On") : i18n("\"What you see is what you get\" mode Off")
                        onTriggered: prompter.__wysiwyg = !prompter.__wysiwyg
                    },
                    Kirigami.Action {
                        id: flipButton
                        text: i18n("Flip")
                        iconName: "refresh"

                        function updateButton(context) {
                            text = context.shortName
                            iconName = context.iconName
                        }
                        
                        Kirigami.Action {
                            text: i18n("No Flip")
                            iconName: "refresh"
                            readonly property string shortName: "No Flip"
                            onTriggered: {
                                parent.updateButton(this)
                                prompter.__flipX = false
                                prompter.__flipY = false
                            }
                        }
                        Kirigami.Action {
                            text: i18n("Horizontal Flip")
                            iconName: "refresh"
                            readonly property string shortName: "H Flip"
                            onTriggered: {
                                parent.updateButton(this)
                                prompter.__flipX = true
                                prompter.__flipY = false
                            }
                        }
                        Kirigami.Action {
                            text: i18n("Vertical Flip")
                            iconName: "refresh"
                            readonly property string shortName: "V Flip"
                            onTriggered: {
                                parent.updateButton(this)
                                prompter.__flipX = false
                                prompter.__flipY = true
                            }
                        }
                        Kirigami.Action {
                            text: i18n("180° rotation")
                            iconName: "refresh"
                            readonly property string shortName: "HV Flip"
                            onTriggered: {
                                parent.updateButton(this)
                                prompter.__flipX = true
                                prompter.__flipY = true
                            }
                        }
                        //onTriggered: {
                            //if (prompter.__flipX && prompter.__flipY) {
                                //prompter.__flipX = false
                                //prompter.__flipY = false
                                //text = i18n("No Flip")
                                //showPassiveNotification(i18n("No Flip"))
                            //}
                            //else if (prompter.__flipY) {
                                //prompter.__flipX = true
                                //text = i18n("XY Flip")
                                //showPassiveNotification(i18n("180° rotation"))
                            //}
                            //else if (prompter.__flipX) {
                                //prompter.__flipX = false
                                //prompter.__flipY = true
                                //text = i18n("Y Flip")
                                //showPassiveNotification(i18n("Vertical Flip"))
                            //}
                            //else {
                                //prompter.__flipX = true
                                //text = i18n("X Flip")
                                //showPassiveNotification(i18n("Horizontal Flip"))
                            //}
                        //}
                    },
                    Kirigami.Action {
                        id: readRegionButton
                        iconName: "middle"
                        text: i18n("Region")
                        onTriggered: overlay.toggle()
                        tooltip: i18n("Toggle read line position")
                    }
                ]
            }
            
            ReadRegionOverlay {
                id: overlay
            }
            
            Prompter {
                id: prompter
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
                        onClicked: prompter.bookmark()
                    }
                    ToolButton {
                        //text: i18n("Undo")
                        icon.name: "edit-undo"
                        icon.color: palette.buttonText
                        onClicked: prompter.undo()
                    }
                    ToolButton {
                        //text: i18n("Redo")f
                        icon.name: "edit-redo"
                        icon.color: palette.buttonText
                        onClicked: prompter.redo()
                    }
                    ToolButton {
                        //text: i18n("&Copy")
                        icon.name: "edit-copy"
                        icon.color: palette.buttonText
                        onClicked: prompter.copy()
                    }
                    ToolButton {
                        //text: i18n("Cut")
                        icon.name: "edit-cut"
                        icon.color: palette.buttonText
                        onClicked: prompter.cut()
                    }
                    ToolButton {
                        //text: i18n("&Paste")
                        icon.name: "edit-paste"
                        icon.color: palette.buttonText
                        onClicked: prompter.paste()
                    }
                    ToolButton {
                        //text: i18n("&Bold")
                        icon.name: "gtk-bold"
                        icon.color: palette.buttonText
                        onClicked: prompter.bold = !prompter.bold
                    }
                    ToolButton {
                        //text: i18n("&Italic")
                        icon.name: "gtk-italic"
                        icon.color: palette.buttonText
                        onClicked: prompter.italic = !prompter.italic
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
                        onClicked: prompter.underline = !prompter.underline
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
                enabled: prompter.selectedText
                onTriggered: prompter.copy()
            }
            MenuItem {
                text: qsTr("Cu&t")
                enabled: prompter.selectedText
                onTriggered: prompter.cut()
            }
            MenuItem {
                text: qsTr("&Paste")
                enabled: prompter.canPaste
                onTriggered: prompter.paste()
            }
        }
        
        Menu {
            title: qsTr("V&iew")
            
            MenuItem {
                text: qsTr("&Auto full screen")
                checkable: true
                checked: root.__autoFullScreen
                onTriggered: root.__autoFullScreen = !root.__autoFullScreen
            }
            MenuItem {
                text: qsTr("Make background &translucid")
                checkable: true
                checked: root.__translucidBackground
                onTriggered: root.__translucidBackground = !root.__translucidBackground
            }
        }
        Menu {
            title: qsTr("F&ormat")

            MenuItem {
                text: qsTr("&Bold")
                checkable: true
                checked: prompter.bold
                onTriggered: prompter.bold = !prompter.bold
            }
            MenuItem {
                text: qsTr("&Italic")
                checkable: true
                checked: prompter.italic
                onTriggered: prompter.italic = !prompter.italic
            }
            MenuItem {
                text: qsTr("&Underline")
                checkable: true
                checked: prompter.underline
                onTriggered: prompter.underline = !prompter.underline
            }
        }
    }
    
    FileDialog {
        id: openDialog
        fileMode: FileDialog.OpenFile
        selectedNameFilter.index: 1
        nameFilters: ["Text files (*.txt)", "HTML files (*.html *.htm)"]
        folder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
        onAccepted: prompter.load(file)
    }

    FileDialog {
        id: saveDialog
        fileMode: FileDialog.SaveFile
        defaultSuffix: prompter.fileType
        nameFilters: openDialog.nameFilters
        selectedNameFilter.index: prompter.fileType === "txt" ? 0 : 1
        folder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
        onAccepted: prompter.saveAs(file)
    }

    MessageDialog {
        id : quitDialog
        title: qsTr("Quit?")
        text: qsTr("The file has been modified. Quit anyway?")
        buttons: (MessageDialog.Yes | MessageDialog.No)
        onYesClicked: Qt.quit()
    }

    // Open save dialog on closing
    onClosing: {
        if (prompter.modified) {
            quitDialog.open()
            close.accepted = false
        }
    }
}
