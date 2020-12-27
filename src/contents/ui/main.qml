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
import QtQuick.Window 2.15
import Qt.labs.platform 1.1
//import QtQuick.Dialogs 1.3 as QmlDialogs
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

import com.cuperino.qprompt.document 1.0

Kirigami.ApplicationWindow {
    id: root
    property bool __autoFullScreen: false
    property bool __translucidBackground: false
    // Scrolling settings
    property bool __scrollAsDial: false
    property bool __invertArrowKeys: false
    property bool __invertScrollDirection: false
    property bool italic
    
    property int prompterVisibility: Kirigami.ApplicationWindow.AutomaticVisibility
    property double __opacity: 0.8
    property real __baseSpeed: 2
    property real __curvature: 1.2
    
    property var document
    title: document.fileName + " - " + aboutData.displayName
    
    minimumWidth: 480
    minimumHeight: 380
    // Changing the theme in this way does not affect the whole app for some reason.
    //Material.theme: Material.Light
    //Material.theme: themeSwitch.checked ? Material.Dark : Material.Light
    background: Rectangle {
        id: appTheme
        property bool hasBackground: color!==__backgroundColor || backgroundImage.opacity>0//backgroundImage.visible
        property color __backgroundColor: parent.Material.theme===Material.Light ? "#fafafa" : "#303030"
        property color __fontColor: parent.Material.theme===Material.Light ? "#212121" : "#fff"
        property color __iconColor: parent.Material.theme===Material.Light ? "#232629" : "#c3c7d1"
        property var backgroundImage: null
        color: __backgroundColor
        opacity: 1

        function loadBackgroundImage() {
            openBackgroundDialog.open()
        }

        function clearBackground() {
            backgroundImage.opacity = 0
            appTheme.color = appTheme.__backgroundColor
        }
        
        function setBackgroundImage(file) {
            if (file) {
                backgroundImage.source = file
            }
        }

        Image {
            id: backgroundImage
            //visible: opacity!==0
            fillMode: Image.PreserveAspectCrop
            width: parent.width
            height: parent.height
            opacity: 0
            autoTransform: true
            asynchronous: true
            mipmap: false
            
            onStatusChanged: {
                if (backgroundImage.status === Image.Ready && !backgroundImage.opacity)
                    backgroundImage.opacity = parent.opacity/2
            }
            
            Behavior on opacity {
                enabled: true
                animation: NumberAnimation {
                    duration: 2800
                    easing.type: Easing.OutExpo
                }
            }
        }
        
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
    // Open save dialog on closing
    onClosing: {
        if (prompter.modified) {
            quitDialog.open()
            close.accepted = false
        }
    }
    
    // Left Global Drawer
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
                onTriggered: {
                    prompter.newDocument()
                    showPassiveNotification(i18n("New document"))
                }
            },
            Kirigami.Action {
                text: i18n("Open")
                iconName: "folder"
                onTriggered: {
                    console.log(root.pageStack.layers.currentItem)
                    root.pageStack.layers.currentItem.openFile()
                }
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
                    if (root.pageStack.layers.depth < 2)
                        root.pageStack.layers.push(aboutPage, {aboutData: aboutData})
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
                flat: true
                onClicked: {
                    console.log("c1")
                }
            }
            Button {
                text: i18n("Theme")
                flat: true
                onClicked: {
                    console.log("c2")
                }
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
        
        // Slider settings
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
                to: 5
                stepSize: 0.1
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                onMoved: {
                    root.__baseSpeed = value
                }
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
                onMoved: {
                    root.__curvature = value
                }
            },
            Label {
                text: i18n("Background opacity:") + " " + backgroundOpacitySlider.value.toFixed(2)
                enabled: root.__translucidBackground
                visible: parent.Material.background.a === 0
                Layout.leftMargin: 8
                Layout.rightMargin: 8
            },
            RowLayout {
                visible: parent.Material.background.a === 0
                CheckBox {
                    id: checkBackgroundTranslucid
                    checked: root.__translucidBackground
                    onToggled: root.__translucidBackground = !root.__translucidBackground
                }
                Slider {
                    id: backgroundOpacitySlider
                    enabled: root.__translucidBackground
                    from: 0
                    to: 1
                    value: 0.8
                    stepSize: 0.01
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    onMoved: {
                        root.__opacity = value
                    }
                }
            }
        ]
    }
    
    // Window Menu Bar
    /*menuBar:*/ MenuBar {
        Menu {
            title: i18n("&File")
            
            MenuItem {
                text: i18n("&New")
                onTriggered: prompter.newDocument()
            }
            MenuItem {
                text: i18n("&Open")
                onTriggered: openDialog.openFile()
            }
            MenuItem {
                text: i18n("&Save As...")
                onTriggered: saveDialog.open()
            }
            MenuSeparator { }
            MenuItem {
                text: i18n("&Quit")
                onTriggered: close()
            }
        }
        
        Menu {
            title: i18n("&Edit")
            
            MenuItem {
                text: i18n("&Copy")
                enabled: prompter.selectedText
                onTriggered: prompter.copy()
            }
            MenuItem {
                text: i18n("Cu&t")
                enabled: prompter.selectedText
                onTriggered: prompter.cut()
            }
            MenuItem {
                text: i18n("&Paste")
                enabled: prompter.canPaste
                onTriggered: prompter.paste()
            }
        }
        
        Menu {
            title: i18n("V&iew")
            
            MenuItem {
                text: i18n("&Auto full screen")
                checkable: true
                checked: root.__autoFullScreen
                onTriggered: root.__autoFullScreen = !root.__autoFullScreen
            }
            MenuItem {
                text: i18n("Make background &translucid")
                checkable: true
                checked: root.__translucidBackground
                onTriggered: root.__translucidBackground = !root.__translucidBackground
            }
        }
        Menu {
            title: i18n("F&ormat")
            
            MenuItem {
                text: i18n("&Bold")
                checkable: true
                checked: prompter.bold
                onTriggered: prompter.bold = !prompter.bold
            }
            MenuItem {
                text: i18n("&Italic")
                checkable: true
                checked: root.pageStack.layers.item.italic
                onTriggered: root.pageStack.layers.currentItem.italic = !root.pageStack.layers.currentItem.italic
            }
            MenuItem {
                text: i18n("&Underline")
                checkable: true
                checked: prompter.underline
                onTriggered: prompter.underline = !prompter.underline
            }
        }
        Menu {
            title: i18n("Controls")
            
            MenuItem {
                text: i18n("Use mouse and touchpad scroll as speed dial while prompting")
                checkable: true
                checked: root.__scrollAsDial
                onTriggered: root.__scrollAsDial = !root.__scrollAsDial
            }
            MenuSeparator { }
            MenuItem {
                text: i18n("Invert arrow keys")
                checkable: true
                checked: root.__invertArrowKeys
                onTriggered: root.__invertArrowKeys = !root.__invertArrowKeys
            }
            MenuItem {
                text: i18n("Invert scroll direction")
                checkable: true
                checked: root.__invertScrollDirection
                onTriggered: root.__invertScrollDirection = !root.__invertScrollDirection
            }
        }
        Menu {
            //title: i18n("&Help")
            MenuItem { text: i18n("&Report Bug...") }
            MenuItem { text: i18n("&Get Studio Edition") }
        }
        
    }

    // Right Context Drawer
    contextDrawer: Kirigami.ContextDrawer {
        id: contextDrawer
        background: Rectangle {
            color: appTheme.__backgroundColor
        }
    }

    Rectangle {
        visible: visibility!==Kirigami.ApplicationWindow.FullScreen
        color: appTheme.__backgroundColor
        anchors{ top:parent.top; left:parent.left; right: parent.right }
        height: 40
        z: -1
    }
    
    // Kirigami PageStack and PageRow
    pageStack.globalToolBar.toolbarActionAlignment: Qt.AlignHCenter
    pageStack.initialPage: prompterPage
    // Auto hide global toolbar on fullscreen
    pageStack.globalToolBar.style: visibility===Kirigami.ApplicationWindow.FullScreen ? Kirigami.ApplicationHeaderStyle.None :  Kirigami.ApplicationHeaderStyle.Auto
    // The following is not possible in the current version of Kirigami, but it should be:
    //pageStack.globalToolBar.background: Rectangle {
        //color: appTheme.__backgroundColor
    //}
    // End of Kirigami PageStack configuration

    /*Binding {
        //target: pageStack.layers.item
        //target: pageStack.initialPage
        //target: pageStack.layers.currentItem
        //target: prompter
        property: "italic"
        value: root.italic
    }*/
    
    /*Connections {
        target: pageStack.layers.currentItem
        //onEventInComponent: {
            //Bind to actions in outer context
        //}
    }*/
    
    // Prompter Page Contents
    //pageStack.initialPage:

    // Prompter Page Component {
    Component {
        id: prompterPage
        PrompterPage {}
    }

    // About Page Component
    Component {
        id: aboutPage
        AboutPage {}
    }
    
    // Dialogues
    ColorDialog {
        id: backgroundColorDialog
        currentColor: appTheme.__backgroundColor
        onAccepted: {
            console.log(color)
            appTheme.color = color
        }
    }
    
    //FileDialog {
        //id: openDialog
        //fileMode: FileDialog.OpenFile
        //selectedNameFilter.index: 1
        //nameFilters: ["Text files (*.txt)", "HTML files (*.html *.htm)"]
        //folder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
        //onAccepted: prompter.load(file)
    //}
    
    FileDialog {
        id: openBackgroundDialog
        fileMode: FileDialog.OpenFile
        selectedNameFilter.index: 1
        nameFilters: ["JPEG image (*.jpg *.jpeg *.JPG *.JPEG)", "PNG image (*.png *.PNG)", "GIF animation (*.gif *.GIF)"]
        folder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
        onAccepted: appTheme.setBackgroundImage(file)
        onRejected: appTheme.hasBackground = false
    }
    
    //Dialog {
    MessageDialog {
        id : countdownDialog
        //visible: true
        title: "Countdown Settings"
        //standardButtons: StandardButton.Ok | StandardButton.Cancel
        buttons: (MessageDialog.Yes | MessageDialog.No)
        onAccepted: console.log("Accepted")
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
        title: i18n("Quit?")
        text: i18n("The file has been modified. Quit anyway?")
        buttons: (MessageDialog.Yes | MessageDialog.No)
        onYesClicked: Qt.quit()
    }
}
