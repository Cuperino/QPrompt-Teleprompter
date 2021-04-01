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
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import Qt.labs.platform 1.1 as Labs

import com.cuperino.qprompt.document 1.0

Kirigami.ApplicationWindow {
    id: root
    property bool __fullScreen: false
    property bool __autoFullScreen: false
    //readonly property bool __translucidBackground: !Material.background.a // === 0
    readonly property bool __translucidBackground: !Kirigami.Theme.backgroundColor.a
    readonly property bool themeIsMaterial: Kirigami.Settings.style==="Material" // || Kirigami.Settings.isMobile
    //readonly property bool __translucidBackground: false
    // Scrolling settings
    property bool __scrollAsDial: false
    property bool __invertArrowKeys: false
    property bool __invertScrollDirection: false
    property bool __noScroll: false
    property bool italic
    
    //property int prompterVisibility: Kirigami.ApplicationWindow.Maximized
    property double __opacity: 1
    property real __baseSpeed: baseSpeedSlider.value
    property real __curvature: baseAccelerationSlider.value
    
    title: prompterPage.document.fileName + (prompterPage.document.modified?"*":"") + " - " + aboutData.displayName
    width: 1064  // Keep at or bellow 1024 and at or above 960, for best usability with common 4:3 resolutions
    height: 728  // Keep and test at 728 so that it works well with 1366x768 screens.
    // Making width and height start maximized
    //width: screen.desktopAvailableWidth
    //height: screen.desktopAvailableHeight
    minimumWidth: 480
    minimumHeight: 380
    
    //// Theme management
    //Material.theme: themeSwitch.checked ? Material.Dark : Material.Light  // This is correct, but it isn't work working, likely because of Kirigami
    
    // Make backgrounds transparent
    //Material.background: "transparent"
    color: "transparent"
    // More ways to enforce transparency across systems
    //visible: true
    //flags: Qt.FramelessWindowHint
    
    background: Rectangle {
        id: appTheme
        color: __backgroundColor
        opacity: root.pageStack.layers.depth > 1 || (!root.__translucidBackground || prompterPage.prompterBackground.opacity===1)
        //readonly property color __fontColor: parent.Material.theme===Material.Light ? "#212121" : "#fff"
        //readonly property color __iconColor: parent.Material.theme===Material.Light ? "#232629" : "#c3c7d1"
        //readonly property color __backgroundColor: __translucidBackground ? (parent.Material.theme===Material.Dark ? "#303030" : "#fafafa") : Kirigami.Theme.backgroundColor
        readonly property color __backgroundColor: __translucidBackground ? (themeSwitch.checked ? "#303030" : "#fafafa") : Kirigami.Theme.backgroundColor
    }
    
    // Full screen
    visibility: __fullScreen ? Kirigami.ApplicationWindow.FullScreen : (!__autoFullScreen ? Kirigami.ApplicationWindow.AutomaticVisibility : (prompterPage.prompter.state==="editing" ? Kirigami.ApplicationWindow.Maximized : Kirigami.ApplicationWindow.FullScreen))

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
                text: i18n("&New")
                iconName: "folder"
                shortcut: i18n("Ctrl+N")
                onTriggered: prompterPage.document.newDocument()
            },
            Kirigami.Action {
                text: i18n("&Open")
                iconName: "folder"
                shortcut: i18n("Ctrl+O")
                onTriggered: prompterPage.document.open()
            },
            Kirigami.Action {
                text: i18n("&Save")
                iconName: "folder"
                shortcut: i18n("Ctrl+S")
                onTriggered: prompterPage.document.saveDialog()
            },
            Kirigami.Action {
                text: i18n("Save &As")
                iconName: "folder"
                shortcut: i18n("Ctrl+Shift+S")
                onTriggered: prompterPage.document.saveAsDialog()
            },
            Kirigami.Action {
                visible: false
                text: i18n("&Recent Files")
                //iconName: "view-list-icons"
                //Kirigami.Action {
                    //text: i18n("View Action 1")
                    //onTriggered: showPassiveNotification(i18n("View Action 1 clicked"))
                //}
            },
            Kirigami.Action {
                visible: ["android", "ios", "tvos", "ipados", "qnx"].indexOf(Qt.platform.os)===-1
                text: i18n("Configure Inputs")
                iconName: "keyboard"
                onTriggered: {
                    prompterPage.key_configuration_overlay.open()
                }
            },
            Kirigami.Action {
                text: i18n("Abou&t") + " " + aboutData.displayName
                iconName: "help-about"
                onTriggered: loadAboutPage()
            },
            Kirigami.Action {
                text: i18n("&Quit")
                iconName: "close"
                shortcut: i18n("Ctrl+Q")
                onTriggered: close()
            }
        ]
        topContent: RowLayout {
            Button {
                text: i18n("Load &Guide")
                flat: true
                onClicked: {
                    prompterPage.document.loadInstructions()
                    globalMenu.close()
                }
            }
            Button {
                id: themeSwitch
                text: i18n("Dark &Mode")
                visible: false
                //visible: !Kirigami.Settings.isMobile && root.__translucidBackground
                //checked: true
                checked: true
                checkable: true
                flat: true
                onClicked: {
                    showPassiveNotification(i18n("Theme mode switching has not been implemented yet"))
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
                text: i18n("Acceleration curvature:") + " " + baseAccelerationSlider.value.toFixed(2)
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
            }
        ]
    }
    
    // QML Window Menu Bar
    menuBar: MenuBar {
        height: 26  // Value for my current Plasma theme. IDK if this will work elsewhere.
        
        // Hide menuBar on mobile, on themes with translucid background, on full screen, and when the reading region is on top while not in edit mode.
        // Algebraically optimized logic
        visible: !(Kirigami.Settings.isMobile || root.__translucidBackground || root.visibility===Kirigami.ApplicationWindow.FullScreen || (prompterPage.overlay.atTop && prompterPage.prompter.state!=="editing"))
        // Same thing, readable logic
        //visible: !Kirigami.Settings.isMobile && !root.__translucidBackground && root.visibility!==Kirigami.ApplicationWindow.FullScreen && (!prompterPage.overlay.atTop && prompterPage.prompter.state!=="editing")
        
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
                text: i18n("Save &As")
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
                text: i18n("&Undo")
                enabled: prompterPage.editor.canUndo
                onTriggered: prompterPage.editor.undo()
            }
            MenuItem {
                text: i18n("&Redo")
                enabled: prompterPage.editor.canRedo
                onTriggered: prompterPage.editor.redo()
            }
            MenuSeparator { }
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
            title: i18n("&View")
            
            MenuItem {
                text: i18n("Full &screen")
                checkable: true
                checked: root.__fullScreen
                onTriggered: root.__fullScreen = !root.__fullScreen
            }
            //MenuItem {
            //    text: i18n("&Auto full screen")
            //    checkable: true
            //    checked: root.__autoFullScreen
            //    onTriggered: root.__autoFullScreen = !root.__autoFullScreen
            //}
            MenuSeparator { }
            Menu {
                title: i18n("&Pointers")
                MenuItem {
                    text: i18n("&Left Pointer")
                    checkable: true
                    checked: prompterPage.overlay.styleState === "leftPointer"
                    onTriggered: prompterPage.overlay.styleState = "leftPointer"
                }
                MenuItem {
                    text: i18n("&Right Pointer")
                    checkable: true
                    checked: prompterPage.overlay.styleState === "rightPointer"
                    onTriggered: prompterPage.overlay.styleState = "rightPointer"
                }
                MenuItem {
                    text: i18n("B&oth Pointers")
                    checkable: true
                    checked: prompterPage.overlay.styleState === "pointers"
                    onTriggered: prompterPage.overlay.styleState = "pointers"
                }
                MenuSeparator { }
                MenuItem {
                    text: i18n("&Bars")
                    checkable: true
                    checked: prompterPage.overlay.styleState === "bars"
                    onTriggered: prompterPage.overlay.styleState = "bars"
                }
                MenuItem {
                    text: i18n("Bars Lef&t")
                    checkable: true
                    checked: prompterPage.overlay.styleState === "barsLeft"
                    onTriggered: prompterPage.overlay.styleState = "barsLeft"
                }
                MenuItem {
                    text: i18n("Bars Ri&ght")
                    checkable: true
                    checked: prompterPage.overlay.styleState === "barsRight"
                    onTriggered: prompterPage.overlay.styleState = "barsRight"
                }
                MenuSeparator { }
                MenuItem {
                    text: i18n("&All")
                    checkable: true
                    checked: prompterPage.overlay.styleState === "all"
                    onTriggered: prompterPage.overlay.styleState = "all"
                }
                MenuItem {
                    text: i18n("&None")
                    checkable: true
                    checked: prompterPage.overlay.styleState === "none"
                    onTriggered: prompterPage.overlay.styleState = "none"
                }
            }
            Menu {
                title: i18n("Readin&g region")
                MenuItem {
                    text: i18n("&Top")
                    checkable: true
                    checked: prompterPage.overlay.positionState === "top"
                    onTriggered: prompterPage.overlay.positionState = "top"
                }
                MenuItem {
                    text: i18n("&Middle")
                    checkable: true
                    checked: prompterPage.overlay.positionState === "middle"
                    onTriggered: prompterPage.overlay.positionState = "middle"
                }
                MenuItem {
                    text: i18n("&Bottom")
                    checkable: true
                    checked: prompterPage.overlay.positionState === "bottom"
                    onTriggered: prompterPage.overlay.positionState = "bottom"
                }
                MenuSeparator { }
                MenuItem {
                    text: i18n("F&ree placement")
                    checkable: true
                    checked: prompterPage.overlay.positionState === "free"
                    onTriggered: prompterPage.overlay.positionState = "free"
                }
                MenuItem {
                    text: i18n("C&ustom (Fixed placement)")
                    checkable: true
                    checked: prompterPage.overlay.positionState === "fixed"
                    onTriggered: prompterPage.overlay.positionState = "fixed"
                }
            }
        }
        Menu {
            title: i18n("For&mat")
            
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
                text: i18n("Cen&ter")
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
                text: i18n("C&haracter")
                onTriggered: prompterPage.fontDialog.open();
            }
            MenuItem {
                text: i18n("Fo&nt Color")
                onTriggered: prompterPage.colorDialog.open()
            }
        }
        Menu {
            title: i18n("&Controls")
            
            MenuItem {
                text: i18n("Disable scrolling while prompting")
                checkable: true
                checked: root.__noScroll
                onTriggered: root.__noScroll = !root.__noScroll
            }
            MenuItem {
                text: i18n("Use scroll as velocity &dial")
                enabled: !root.__noScroll
                ToolTip.text: i18n("Use mouse and touchpad scroll as speed dial while prompting")
                checkable: true
                checked: root.__scrollAsDial
                onTriggered: root.__scrollAsDial = !root.__scrollAsDial
            }
            MenuSeparator { }
            MenuItem {
                text: i18n("Invert &arrow keys")
                enabled: !root.__noScroll
                checkable: true
                checked: root.__invertArrowKeys
                onTriggered: root.__invertArrowKeys = !root.__invertArrowKeys
            }
            MenuItem {
                text: i18n("Invert &scroll direction")
                enabled: !root.__noScroll
                checkable: true
                checked: root.__invertScrollDirection
                onTriggered: root.__invertScrollDirection = !root.__invertScrollDirection
            }
        }
        Menu {
            title: i18n("&Help")
            
            MenuItem {
                text: i18n("Report &Bug...")
                onTriggered: Qt.openUrlExternally("https://github.com/Cuperino/QPrompt/issues")
                icon.name: "tools-report-bug"
            }
            MenuSeparator { }
            MenuItem {
                visible: false
                text: i18n("Get &Studio Edition")
                onTriggered: Qt.openUrlExternally("https://cuperino.com/qprompt")
                icon.name: "software-center"
            }
            //MenuSeparator { }
            MenuItem {
                text: i18n("Load User &Guide")
                icon.name: "help-info"
                onTriggered: prompterPage.document.loadInstructions()
            }
            MenuSeparator { }
            MenuItem {
                text: i18n("Abou&t QPrompt")
                onTriggered: root.loadAboutPage()
                icon.source: "qrc:/images/logo.png"
            }
        }
    }

    Labs.MenuBar {
        id: nativeMenus
        window: root
        Labs.Menu {
            title: i18n("&File")
            
            Labs.MenuItem {
                text: i18n("&New")
                onTriggered: prompterPage.document.newDocument()
            }
            Labs.MenuItem {
                text: i18n("&Open")
                onTriggered: prompterPage.document.open()
            }
            Labs.MenuItem {
                text: i18n("&Save")
                onTriggered: prompterPage.document.saveDialog()
            }
            Labs.MenuItem {
                text: i18n("Save &As...")
                onTriggered: prompterPage.document.saveAsDialog()
            }
            Labs.MenuSeparator { }
            Labs.MenuItem {
                text: i18n("&Quit")
                onTriggered: close()
            }
        }
        
        Labs.Menu {
            title: i18n("&Edit")
            
            Labs.MenuItem {
                text: i18n("&Undo")
                enabled: prompterPage.editor.canUndo
                onTriggered: prompterPage.editor.undo()
            }
            Labs.MenuItem {
                text: i18n("&Redo")
                enabled: prompterPage.editor.canRedo
                onTriggered: prompterPage.editor.redo()
            }
            Labs.MenuSeparator { }
            Labs.MenuItem {
                text: i18n("&Copy")
                enabled: prompterPage.editor.selectedText
                onTriggered: prompterPage.editor.copy()
            }
            Labs.MenuItem {
                text: i18n("Cu&t")
                enabled: prompterPage.editor.selectedText
                onTriggered: prompterPage.editor.cut()
            }
            Labs.MenuItem {
                text: i18n("&Paste")
                enabled: prompterPage.editor.canPaste
                onTriggered: prompterPage.editor.paste()
            }
        }
        
        Labs.Menu {
            title: i18n("&View")
            
            Labs.MenuItem {
                text: i18n("Full &screen")
                checkable: true
                checked: root.__fullScreen
                onTriggered: root.__fullScreen = !root.__fullScreen
            }
            //Labs.MenuItem {
            //    text: i18n("&Auto full screen")
            //    checkable: true
            //    checked: root.__autoFullScreen
            //    onTriggered: root.__autoFullScreen = !root.__autoFullScreen
            //}
            Labs.MenuSeparator { }
            Labs.Menu {
                title: i18n("&Pointers")
                Labs.MenuItem {
                    text: i18n("&Left Pointer")
                    checkable: true
                    checked: prompterPage.overlay.styleState === "leftPointer"
                    onTriggered: prompterPage.overlay.styleState = "leftPointer"
                }
                Labs.MenuItem {
                    text: i18n("&Right Pointer")
                    checkable: true
                    checked: prompterPage.overlay.styleState === "rightPointer"
                    onTriggered: prompterPage.overlay.styleState = "rightPointer"
                }
                Labs.MenuItem {
                    text: i18n("B&oth Pointers")
                    checkable: true
                    checked: prompterPage.overlay.styleState === "pointers"
                    onTriggered: prompterPage.overlay.styleState = "pointers"
                }
                Labs.MenuSeparator { }
                Labs.MenuItem {
                    text: i18n("&Bars")
                    checkable: true
                    checked: prompterPage.overlay.styleState === "bars"
                    onTriggered: prompterPage.overlay.styleState = "bars"
                }
                Labs.MenuItem {
                    text: i18n("Bars Lef&t")
                    checkable: true
                    checked: prompterPage.overlay.styleState === "barsLeft"
                    onTriggered: prompterPage.overlay.styleState = "barsLeft"
                }
                Labs.MenuItem {
                    text: i18n("Bars Ri&ght")
                    checkable: true
                    checked: prompterPage.overlay.styleState === "barsRight"
                    onTriggered: prompterPage.overlay.styleState = "barsRight"
                }
                Labs.MenuSeparator { }
                Labs.MenuItem {
                    text: i18n("&All")
                    checkable: true
                    checked: prompterPage.overlay.styleState === "all"
                    onTriggered: prompterPage.overlay.styleState = "all"
                }
                Labs.MenuItem {
                    text: i18n("&None")
                    checkable: true
                    checked: prompterPage.overlay.styleState === "none"
                    onTriggered: prompterPage.overlay.styleState = "none"
                }
            }
            Labs.Menu {
                title: i18n("Readin&g region")
                Labs.MenuItem {
                    text: i18n("&Top")
                    checkable: true
                    checked: prompterPage.overlay.positionState === "top"
                    onTriggered: prompterPage.overlay.positionState = "top"
                }
                Labs.MenuItem {
                    text: i18n("&Middle")
                    checkable: true
                    checked: prompterPage.overlay.positionState === "middle"
                    onTriggered: prompterPage.overlay.positionState = "middle"
                }
                Labs.MenuItem {
                    text: i18n("&Bottom")
                    checkable: true
                    checked: prompterPage.overlay.positionState === "bottom"
                    onTriggered: prompterPage.overlay.positionState = "bottom"
                }
                Labs.MenuSeparator { }
                Labs.MenuItem {
                    text: i18n("F&ree placement")
                    checkable: true
                    checked: prompterPage.overlay.positionState === "free"
                    onTriggered: prompterPage.overlay.positionState = "free"
                }
                Labs.MenuItem {
                    text: i18n("C&ustom (Fixed placement)")
                    checkable: true
                    checked: prompterPage.overlay.positionState === "fixed"
                    onTriggered: prompterPage.overlay.positionState = "fixed"
                }
            }
        }
        Labs.Menu {
            title: i18n("For&mat")
            
            Labs.MenuItem {
                text: i18n("&Bold")
                checkable: true
                checked: prompterPage.document.bold
                onTriggered: prompterPage.document.bold = !prompterPage.document.bold
            }
            Labs.MenuItem {
                text: i18n("&Italic")
                checkable: true
                checked: prompterPage.document.italic
                onTriggered: prompterPage.document.italic = !prompterPage.document.italic
            }
            Labs.MenuItem {
                text: i18n("&Underline")
                checkable: true
                checked: prompterPage.document.underline
                onTriggered: prompterPage.document.underline = !prompterPage.document.underline
            }
            Labs.MenuSeparator { }
            Labs.MenuItem {
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
            Labs.MenuItem {
                text: i18n("Cen&ter")
                checkable: true
                checked: prompterPage.document.alignment === Qt.AlignHCenter
                onTriggered: prompterPage.document.alignment = Qt.AlignHCenter
            }
            Labs.MenuItem {
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
            Labs.MenuItem {
                text: i18n("&Justify")
                checkable: true
                checked: prompterPage.document.alignment === Qt.AlignJustify
                onTriggered: prompterPage.document.alignment = Qt.AlignJustify
            }
            Labs.MenuSeparator { }
            Labs.MenuItem {
                text: i18n("C&haracter")
                onTriggered: prompterPage.fontDialog.open();
            }
            Labs.MenuItem {
                text: i18n("Fo&nt Color")
                onTriggered: prompterPage.colorDialog.open()
            }
        }
        Labs.Menu {
            title: i18n("Controls")

            Labs.MenuItem {
                text: i18n("Disable scrolling while prompting")
                checkable: true
                checked: root.__noScroll
                onTriggered: root.__noScroll = !root.__noScroll
            }
            Labs.MenuItem {
                text: i18n("Use scroll as velocity &dial")
                enabled: !root.__noScroll
                checkable: true
                checked: root.__scrollAsDial
                onTriggered: root.__scrollAsDial = !root.__scrollAsDial
            }
            Labs.MenuSeparator { }
            Labs.MenuItem {
                text: i18n("Invert &arrow keys")
                enabled: !root.__noScroll
                checkable: true
                checked: root.__invertArrowKeys
                onTriggered: root.__invertArrowKeys = !root.__invertArrowKeys
            }
            Labs.MenuItem {
                text: i18n("Invert &scroll direction")
                enabled: !root.__noScroll
                checkable: true
                checked: root.__invertScrollDirection
                onTriggered: root.__invertScrollDirection = !root.__invertScrollDirection
            }
        }
        Labs.Menu {
            title: i18n("&Help")
            
            Labs.MenuItem {
                text: i18n("Report &Bug...")
                onTriggered: Qt.openUrlExternally("https://github.com/Cuperino/QPrompt/issues")
                icon.name: "tools-report-bug"
            }
            Labs.MenuSeparator { }
            Labs.MenuItem {
                visible: false
                text: i18n("Get &Studio Edition")
                onTriggered: Qt.openUrlExternally("https://cuperino.com/qprompt")
                icon.name: "software-center"
            }
            //Labs.MenuSeparator { }
            Labs.MenuItem {
                text: i18n("Load User &Guide")
                icon.name: "help-info"
                onTriggered: prompterPage.document.loadInstructions()
            }
            Labs.MenuSeparator { }
            Labs.MenuItem {
                text: i18n("Abou&t QPrompt")
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
        visible: !Kirigami.Settings.isMobile && pageStack.globalToolBar.actualStyle !== Kirigami.ApplicationHeaderStyle.None
        color: appTheme.__backgroundColor
        anchors{ top:parent.top; left:parent.left; right: parent.right }
        height: 40
        z: -1
    }
    
    // Kirigami PageStack and PageRow
    pageStack.globalToolBar.toolbarActionAlignment: Qt.AlignHCenter
    pageStack.initialPage: prompterPageComponent
    // Auto hide global toolbar on fullscreen
    //pageStack.globalToolBar.style: visibility===Kirigami.ApplicationWindow.FullScreen ? Kirigami.ApplicationHeaderStyle.None :  Kirigami.ApplicationHeaderStyle.Auto
    pageStack.globalToolBar.style: visibility===Kirigami.ApplicationWindow.FullScreen && prompterPage.prompter.state!=="editing" ? Kirigami.ApplicationHeaderStyle.None : Kirigami.ApplicationHeaderStyle.ToolBar
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
    Labs.MessageDialog {
        id : quitDialog
        title: i18n("Save Document")
        text: i18n("Save changes to document before closing?")
        buttons: (Labs.MessageDialog.Save | Labs.MessageDialog.Discard | Labs.MessageDialog.Cancel)
        onDiscardClicked: Qt.quit()
        onSaveClicked: prompterPage.document.saveDialog(true)
    }
}
