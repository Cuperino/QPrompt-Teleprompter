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

import QtQuick 2.15
import org.kde.kirigami 2.9 as Kirigami
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import Qt.labs.platform 1.1
//import QtQuick.Dialogs 1.3 as QmlDialogs
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import QtGraphicalEffects 1.15

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
    property real __baseSpeed: baseSpeedSlider.value
    property real __curvature: baseAccelerationSlider.value
    
    title: prompterPage.document.fileName + (prompterPage.document.modified?"*":"") + " - " + aboutData.displayName
    width: 960  // Keep bellow 1024, preferably at 960, for usability with common 4:3 resolutions
    height: 728  // Keep and test at 728 so that it works well with 1366x768 screens.
    minimumWidth: 480
    minimumHeight: 380
    // Changing the theme in this way does not affect the whole app for some reason.
    //Material.theme: Material.Light
    //Material.theme: themeSwitch.checked ? Material.Dark : Material.Light
    background: Rectangle {
        id: appTheme
        property bool hasBackground: appTheme.color!==__backgroundColor || backgroundImage.opacity>0//backgroundImage.visible
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
        Behavior on color {
            enabled: true
            animation: ColorAnimation {
                duration: 2800
                easing.type: Easing.OutExpo
            }
        }
        Image {
            id: backgroundImage
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            opacity: 0
            visible: opacity!==0
            autoTransform: true
            asynchronous: true
            mipmap: false
            
            onStatusChanged: {
                if (backgroundImage.status === Image.Ready && !backgroundImage.opacity)
                    backgroundImage.opacity = 0.72*parent.opacity
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
                duration: Kirigami.Units.longDuration
                easing.type: Easing.OutQuad
            }
        }
    }
    
    // Full screen
    visibility: __autoFullScreen ? prompterVisibility : Kirigami.ApplicationWindow.AutomaticVisibility

    // Open save dialog on closing
    onClosing: {
        if (prompterPage.document.modified) {
            quitDialog.open()
            close.accepted = false
        }
    }
    
    function loadAboutPage() {
        if (root.pageStack.layers.depth < 2)
            root.pageStack.layers.push(aboutPageComponent, {aboutData: aboutData})
    }
    
    // Left Global Drawer
    globalDrawer: Kirigami.GlobalDrawer {
        id: globalMenu
        
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
                shortcut: "Ctrl+N"
                onTriggered: prompterPage.document.newDocument()
            },
            Kirigami.Action {
                text: i18n("Open")
                iconName: "folder"
                shortcut: "Ctrl+O"
                onTriggered: prompterPage.document.open()
            },
            Kirigami.Action {
                text: i18n("Save")
                iconName: "folder"
                shortcut: "Ctrl+S"
                onTriggered: prompterPage.document.saveDialog()
            },
            Kirigami.Action {
                text: i18n("Save As")
                iconName: "folder"
                shortcut: "Ctrl+Shift+S"
                onTriggered: prompterPage.document.saveAsDialog()
            },
            //Kirigami.Action {
                //text: i18n("Recent Files")
                //iconName: "view-list-icons"
                //Kirigami.Action {
                    //text: i18n("View Action 1")
                    //onTriggered: showPassiveNotification(i18n("View Action 1 clicked"))
                //}
            //},
            Kirigami.Action {
                text: i18n("About") + " " + aboutData.displayName
                iconName: "help-about"
                onTriggered: loadAboutPage()
            },
            Kirigami.Action {
                text: i18n("&Quit")
                iconName: "close"
                shortcut: "Ctrl+Q"
                onTriggered: close()
            }
        ]
        topContent: RowLayout {
            Button {
                text: i18n("Instructions")
                flat: true
                onClicked: {
                    prompterPage.document.loadInstructions()
                    globalMenu.close()
                    showPassiveNotification(i18n("User guide loaded"))
                }
            }
            Button {
                text: i18n("Theme")
                flat: true
                onClicked: {
                    showPassiveNotification(i18n("Live theme mode switching has not yet been implemented."))
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
                value: 2
                to: 10
                stepSize: 0.1
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
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
                onTriggered: prompterPage.document.newDocument()
            }
            MenuItem {
                text: i18n("&Open")
                onTriggered: prompterPage.document.open()
            }
            MenuItem {
                text: i18n("&Save")
                onTriggered: prompterPage.document.saveDialog()
            }
            MenuItem {
                text: i18n("Save As...")
                onTriggered: prompterPage.document.saveAsDialog()
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
                enabled: prompterPage.editor.selectedText
                onTriggered: prompterPage.editor.copy()
            }
            MenuItem {
                text: i18n("Cu&t")
                enabled: prompterPage.editor.selectedText
                onTriggered: prompterPage.editor.cut()
            }
            MenuItem {
                text: i18n("&Paste")
                enabled: prompterPage.editor.canPaste
                onTriggered: prompterPage.editor.paste()
            }
        }
        
        Menu {
            title: i18n("V&iew")
            
            MenuItem {
                id: autoFullScreenCheckbox
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
                checked: prompterPage.document.bold
                onTriggered: prompterPage.document.bold = !prompterPage.document.bold
            }
            MenuItem {
                text: i18n("&Italic")
                checkable: true
                checked: prompterPage.document.italic
                onTriggered: prompterPage.document.italic = !prompterPage.document.italic
            }
            MenuItem {
                text: i18n("&Underline")
                checkable: true
                checked: prompterPage.document.underline
                onTriggered: prompterPage.document.underline = !prompterPage.document.underline
            }
            MenuSeparator { }
            MenuItem {
                text: Qt.application.layoutDirection===Qt.LeftToRight ? i18n("&Left") : i18n("&Right")
                checkable: true
                checked: Qt.application.layoutDirection===Qt.LeftToRight ? prompterPage.document.alignment === Qt.AlignLeft : prompterPage.document.alignment === Qt.AlignRight
                onTriggered: {
                    if (Qt.application.layoutDirection===Qt.LeftToRight)
                        prompterPage.document.alignment = Qt.AlignLeft
                    else
                        prompterPage.document.alignment = Qt.AlignRight
                }
            }
            MenuItem {
                text: i18n("&Center")
                checkable: true
                checked: prompterPage.document.alignment === Qt.AlignHCenter
                onTriggered: prompterPage.document.alignment = Qt.AlignHCenter
            }
            MenuItem {
                text: Qt.application.layoutDirection===Qt.LeftToRight ? i18n("&Right") : i18n("&Left")
                checkable: true
                checked: Qt.application.layoutDirection===Qt.LeftToRight ? prompterPage.document.alignment === Qt.AlignRight : prompterPage.document.alignment === Qt.AlignLeft
                onTriggered: {
                    if (Qt.application.layoutDirection===Qt.LeftToRight)
                        prompterPage.document.alignment = Qt.AlignRight
                    else
                        prompterPage.document.alignment = Qt.AlignLeft
                }
            }
            MenuItem {
                text: i18n("&Justify")
                checkable: true
                checked: prompterPage.document.alignment === Qt.AlignJustify
                onTriggered: prompterPage.document.alignment = Qt.AlignJustify
            }
            MenuSeparator { }
            MenuItem {
                text: i18n("Character")
                onTriggered: prompterPage.fontDialog.open();
            }
            MenuItem {
                text: i18n("Font Color")
                onTriggered: prompterPage.colorDialog.open()
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
            title: i18n("&Help")
            
            MenuItem {
                text: i18n("&Report Bug...")
                onTriggered: Qt.openUrlExternally("https://github.com/Cuperino/QPrompt/issues")
                icon.name: "tools-report-bug"
            }
            MenuSeparator { }
            //MenuItem {
            //    text: i18n("&Get Studio Edition")
            //    onTriggered: Qt.openUrlExternally("https://cuperino.com/qprompt")
            //    icon.name: "software-center"
            //}
            //MenuSeparator { }
            MenuItem {
                text: i18n("&About QPrompt")
                onTriggered: root.loadAboutPage()
                icon.source: "qrc:/images/logo.png"
            }
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
    pageStack.initialPage: prompterPageComponent
    // Auto hide global toolbar on fullscreen
    pageStack.globalToolBar.style: visibility===Kirigami.ApplicationWindow.FullScreen ? Kirigami.ApplicationHeaderStyle.None :  Kirigami.ApplicationHeaderStyle.Auto
    // The following is not possible in the current version of Kirigami, but it should be:
    //pageStack.globalToolBar.background: Rectangle {
        //color: appTheme.__backgroundColor
    //}
    property alias prompterPage: root.pageStack.currentItem
    // End of Kirigami PageStack configuration
    
    // Patch current page's events to outside its scope.
    //Connections {
        //target: pageStack.currentItem
        ////onTest: {  // Old syntax, use to support 5.12 and lower.
        //function onTest(data) {
            //console.log("Connection successful, received:", data)
        //}
    //}

    /*Binding {
        //target: pageStack.layers.item
        //target: pageStack.initialPage
        //target: pageStack.layers.currentItem
        //target: prompter
        property: "italic"
        value: root.italic
    }*/
    
    // Prompter Page Contents
    //pageStack.initialPage:

    // Prompter Page Component {
    Component {
        id: prompterPageComponent
        PrompterPage {}
    }

    // About Page Component
    Component {
        id: aboutPageComponent
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
    
    FileDialog {
        id: openBackgroundDialog
        fileMode: FileDialog.OpenFile
        selectedNameFilter.index: 0
        nameFilters: ["JPEG image (*.jpg *.jpeg *.JPG *.JPEG)", "PNG image (*.png *.PNG)", "GIF animation (*.gif *.GIF)"]
        folder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
        onAccepted: appTheme.setBackgroundImage(file)
        onRejected: appTheme.hasBackground = false
    }

    MessageDialog {
        id : quitDialog
        title: i18n("Quit?")
        text: i18n("The file has been modified. Quit anyway?")
        buttons: (MessageDialog.Yes | MessageDialog.No)
        onYesClicked: Qt.quit()
    }
}
