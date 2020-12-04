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
import org.kde.kirigami 2.9 as Kirigami
import QtQuick.Controls 2.15
import QtQuick.Shapes 1.15
import QtQuick.Window 2.0
import Qt.labs.platform 1.0
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

import com.cuperino.qprompt.document 1.0

Kirigami.ApplicationWindow {
    id: root
    property bool __autoFullScreen: false
    property bool __translucidBackground: false
    property int prompterVisibility: Kirigami.ApplicationWindow.AutomaticVisibility

    title: document.fileName + " - " + aboutData.displayName
    
    minimumWidth: 480
    minimumHeight: 380
    // Changing the theme in this way does not affect the whole app for some reason.
    //Material.theme: Material.Light
    //Material.theme: themeSwitch.checked ? Material.Dark : Material.Light
    background: Rectangle {
        id: appTheme
        property color __backgroundColor: parent.Material.theme===Material.Light ? "#fafafa" : "#303030"
        property color __fontColor: parent.Material.theme===Material.Light ? "#212121" : "#fff"
        property color __iconColor: parent.Material.theme===Material.Light ? "232629" : "#c3c7d1"
        color: __backgroundColor
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
    onWindowTitleChanged: {
        root.setIcon(

        )
    }
    onVisibilityChanged: {
        if (visibility!==Kirigami.ApplicationWindow.FullScreen)
            console.log("left fullscreen");
            //position = prompter.positionAt(0, prompter.position + readRegion.__placement*overlay.height)
    }

    globalDrawer: Kirigami.GlobalDrawer {
        property int bannerCounter: 0
        // isMenu: true
        title: aboutData.displayName
        titleIcon: "qrc:/images/logo.png"
        bannerVisible: true
        background: Rectangle {
            color: appTheme.__backgroundColor
            opacity: 1
        }
        onBannerClicked: {
            bannerCounter++;
            if (!(bannerCounter%10)) {
                // Insert Easter egg here.
            }
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
                text: i18n("Recent Files")
                iconName: "view-list-icons"
                Kirigami.Action {
                    text: i18n("View Action 1")
                    onTriggered: showPassiveNotification(i18n("View Action 1 clicked"))
                }
            },
            Kirigami.Action {
                text: i18n("About") + " " + aboutData.displayName
                iconName: "help-about"
                onTriggered: {
                    if (root.pageStack.layers.depth < 2) {
                        root.pageStack.layers.push(aboutPage)
                        //root.pageStack.layers.currentItem.aboutData = aboutData
                        //root.pageStack.layers.currentItem.aboutData.licenses.concat(aboutData.licenses)
                    }
                }
            },
            Kirigami.Action {
                text: i18n("&Quit")
                iconName: "close"
                onTriggered: close()
            }
        ]
        topContent: RowLayout {
            Button {
                text: i18n("Instructions")
            }
            Button {
                text: i18n("Change Theme")
            }
        }
        //Kirigami.ActionToolBar {
            //Kirigami.Action {
                //text: i18n("View Action 1")
                //onTriggered: showPassiveNotification(i18n("View Action 1 clicked"))
            //},
            //Kirigami.Action {
                //text: i18n("View Action 2")
                //onTriggered: showPassiveNotification(i18n("View Action 2 clicked"))
            //}
        //}
        content: [
            Label {
                text: i18n("Base speed:") + " " + baseSpeedSlider.value.toFixed(2)
                Layout.leftMargin: 8
                Layout.rightMargin: 8
            },
            Slider {
                id: baseSpeedSlider
                from: 0.1
                value: 0.5
                to: 2
                stepSize: 0.1
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                onMoved: {}
            },
            Label {
                text: i18n("Acceleration curve:") + " " + baseAccelerationSlider.value.toFixed(2)
                Layout.leftMargin: 8
                Layout.rightMargin: 8
            },
            Slider {
                id: baseAccelerationSlider
                from: 0.5
                value: 1.2
                to: 3
                stepSize: 0.05
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                onMoved: {}
            }
        ]
    }

    contextDrawer: Kirigami.ContextDrawer {
        id: contextDrawer
        background: Rectangle {
            color: appTheme.__backgroundColor
        }
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
                        text: i18n("WYSIWYG")
                        checkable: true
                        checked: prompter.__wysiwyg
                        tooltip: prompter.__wysiwyg ? i18n("\"What you see is what you get\" mode is On") : i18n("\"What you see is what you get\" mode Off")
                        onTriggered: {
                            prompter.__wysiwyg = !prompter.__wysiwyg
                        }
                    },
                    Kirigami.Action {
                        id: flipButton
                        text: i18n("Flip")

                        function updateButton(context) {
                            text = context.shortName
                            //iconName = context.iconName
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
                            enabled: prompter.__flipX || prompter.__flipY
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
                            enabled: (!prompter.__flipX) || prompter.__flipY
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
                            enabled: prompter.__flipX || !prompter.__flipY
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
                            enabled: !(prompter.__flipX && prompter.__flipY)
                        }
                    },
                    Kirigami.Action {
                        id: readRegionButton
                        text: i18n("Reading region")
                        //onTriggered: overlay.toggle()
                        tooltip: i18n("Change reading region placement")

                        Kirigami.Action {
                            id: readRegionTopButton
                            iconName: "go-up"
                            text: i18n("Top")
                            onTriggered: overlay.positionState = "top"
                            enabled: overlay.positionState!=="top"
                            tooltip: i18n("Move reading region to the top, convenient for use with webcams")
                        }
                        Kirigami.Action {
                            id: readRegionMiddleButton
                            iconName: "remove"
                            text: i18n("Middle")
                            onTriggered: overlay.positionState = "middle"
                            enabled: overlay.positionState!=="middle"
                            tooltip: i18n("Move reading region to the vertical center")
                        }
                        Kirigami.Action {
                            id: readRegionBottomButton
                            iconName: "go-down"
                            text: i18n("Bottom")
                            onTriggered: overlay.positionState = "bottom"
                            enabled: overlay.positionState!=="bottom"
                            tooltip: i18n("Move reading region to the bottom")
                        }
                        Kirigami.Action {
                            id: readRegionFreeButton
                            iconName: "gtk-edit"
                            text: i18n("Free")
                            onTriggered: overlay.positionState = "free"
                            enabled: overlay.positionState!=="free"
                            tooltip: i18n("Move reading region freely by dragging and droping")
                        }
                        Kirigami.Action {
                            id: readRegionCustomButton
                            iconName: "gtk-apply"
                            text: i18n("Custom")
                            onTriggered: overlay.positionState = "fixed"
                            enabled: overlay.positionState!=="fixed"
                            tooltip: i18n("Fix reading region to the position set using free placement mode")
                        }
                    },
                    Kirigami.Action {
                        id: readRegionStyleButton
                        text: i18n("Pointers")
                        tooltip: i18n("Change pointers that indicate reading region")

                        Kirigami.Action {
                            id: readRegionTrianglesButton
                            text: i18n("Triangles")
                            onTriggered: overlay.styleState = "triangles"
                            tooltip: i18n("Mark reading area using bars")
                            enabled: overlay.styleState!=="triangles"
                        }
                        Kirigami.Action {
                            id: readRegionLeftTriangleButton
                            text: i18n("Left Triangle")
                            onTriggered: overlay.styleState = "leftTriangle"
                            tooltip: i18n("Left triangle points towards reading region")
                            enabled: overlay.styleState!=="leftTriangle"
                        }
                        Kirigami.Action {
                            id: readRegionRightTriangleButton
                            text: i18n("Right Triangle")
                            onTriggered: overlay.styleState = "rightTriangle"
                            tooltip: i18n("Right triangle points towards reading region")
                            enabled: overlay.styleState!=="rightTriangle"
                        }
                        Kirigami.Action {
                            id: readRegionBarsButton
                            text: i18n("Bars")
                            onTriggered: overlay.styleState = "bars"
                            tooltip: i18n("Mark reading region using translucid bars")
                            enabled: overlay.styleState!=="bars"
                        }
                        Kirigami.Action {
                            id: readRegionAllButton
                            text: i18n("All")
                            onTriggered: overlay.styleState = "all"
                            tooltip: i18n("Use triangles to point towards reading region")
                            enabled: overlay.styleState!=="all"
                        }
                        Kirigami.Action {
                            id: readRegionNoneButton
                            text: i18n("None")
                            onTriggered: overlay.styleState = "none"
                            tooltip: i18n("Disable reading region entirelly")
                            enabled: overlay.styleState!=="none"
                        }
                    }
//                    Kirigami.Action {
//                        id: readRegionButton
//                        iconName: "middle"
//                        text: i18n("Region")
//                        onTriggered: overlay.toggle()
//                        tooltip: i18n("Toggle read line position")
//                    }
                ]
            }
            
            Countdown {
                id: countdown
            }

            ReadRegionOverlay {
                id: overlay
            }

            TimerClock {
                id: timer
            }

            Prompter {
                id: prompter
            }
            
            footer: ToolBar {   
                id: toolbar
                
                background: Rectangle {
                    color: appTheme.__backgroundColor
                }
                RowLayout {
                    anchors.fill: parent
                    ToolButton {
                        //text: i18n("Bookmark")
                        icon.name: "bookmarks"
                        icon.color: appTheme.__iconColor
                        onClicked: prompter.bookmark()
                    }
                    ToolButton {
                        //text: i18n("Undo")
                        icon.name: "edit-undo"
                        icon.color: appTheme.__iconColor
                        onClicked: prompter.undo()
                    }
                    ToolButton {
                        //text: i18n("Redo")f
                        icon.name: "edit-redo"
                        icon.color: appTheme.__iconColor
                        onClicked: prompter.redo()
                    }
                    ToolButton {
                        //text: i18n("&Copy")
                        icon.name: "edit-copy"
                        icon.color: appTheme.__iconColor
                        onClicked: prompter.copy()
                    }
                    ToolButton {
                        //text: i18n("Cut")
                        icon.name: "edit-cut"
                        icon.color: appTheme.__iconColor
                        onClicked: prompter.cut()
                    }
                    ToolButton {
                        //text: i18n("&Paste")
                        icon.name: "edit-paste"
                        icon.color: appTheme.__iconColor
                        onClicked: prompter.paste()
                    }
                    ToolButton {
                        //text: i18n("&Bold")
                        icon.name: "gtk-bold"
                        icon.color: appTheme.__iconColor
                        onClicked: prompter.bold = !prompter.bold
                    }
                    ToolButton {
                        //text: i18n("&Italic")
                        icon.name: "gtk-italic"
                        icon.color: appTheme.__iconColor
                        onClicked: prompter.italic = !prompter.italic
                    }
                    ToolButton {
                        //Text {
                        //text: i18n("Underline")
                        //color: appTheme.__iconColor
                        //anchors.fill: parent
                        //fontSizeMode: Text.Fit
                        //horizontalAlignment: Text.AlignHCenter
                        //verticalAlignment: Text.AlignVCenter
                        //}
                        //text: i18n("&Underline")
                        icon.name: "gtk-underline"
                        icon.color: appTheme.__iconColor
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
    
    /*menuBar: */MenuBar {
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
        Menu {
            title: i18n("&Help")
            MenuItem { text: i18n("&Report Bug...") }
            MenuItem { text: i18n("&Get Studio Edition") }
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

    // About Page
    Component {
        id: aboutPage
        AboutPage {}
    }
}
