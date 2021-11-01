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

import QtQuick 2.12
import org.kde.kirigami 2.11 as Kirigami
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.12
import Qt.labs.platform 1.1 as Labs
import QtQuick.Dialogs 1.3
import Qt.labs.settings 1.0

import com.cuperino.qprompt.document 1.0

Kirigami.ApplicationWindow {
    id: root
    property bool __fullScreen: false
    property bool __autoFullScreen: false
    // The following line includes macOS among the list of platforms where full screen buttons are hidden. This is done intentionally because macOS provides its own full screen buttons on the window frame and global menu. We shall not mess with what users of each platform expect.
    property bool fullScreenPlatform: Kirigami.Settings.isMobile || ['android', 'ios', 'wasm', 'tvos', 'qnx', 'ipados', 'osx'].indexOf(Qt.platform.os)!==-1
    //readonly property bool __translucidBackground: !Material.background.a // === 0
    //readonly property bool __translucidBackground: !Kirigami.Theme.backgroundColor.a && ['ios', 'wasm', 'tvos', 'qnx', 'ipados'].indexOf(Qt.platform.os)===-1
    readonly property bool __translucidBackground: true
    readonly property bool themeIsMaterial: Kirigami.Settings.style==="Material" // || Kirigami.Settings.isMobile
    // mobileOrSmallScreen helps determine when to follow mobile behaviors from desktop non-mobile devices
    readonly property bool mobileOrSmallScreen: Kirigami.Settings.isMobile || root.width < 1220
    //readonly property bool __translucidBackground: false
    // Scrolling settings
    property bool __scrollAsDial: false
    property bool __invertArrowKeys: false
    property bool __invertScrollDirection: false
    property bool __noScroll: false
    property bool __telemetry: true
    property bool forceQtTextRenderer: false
    property bool passiveNotifications: true

    //property int prompterVisibility: Kirigami.ApplicationWindow.Maximized
    property double __opacity: 1
    property int __iDefault: 3

    title: root.pageStack.currentItem.document.fileName + (root.pageStack.currentItem.document.modified?"*":"") + " - " + aboutData.displayName
    width: 1220  // Set at 1220 to show all functionality at a glance. Set to 1200 to fit both 1280 4:3 and 1200 height monitors. Keep at or bellow 1024 and at or above 960, for best usability with common 4:3 resolutions
    height: 728  // Keep and test at 728 so that it works well with 1366x768 screens.
    // Making width and height start maximized
    //width: screen.desktopAvailableWidth
    //height: screen.desktopAvailableHeight
    minimumWidth: 480
    minimumHeight: 380

    Settings {
        category: "mainWindow"
        property alias x: root.x
        property alias y: root.y
        property alias width: root.width
        property alias height: root.height
    }
    Settings {
        category: "scroll"
        property alias noScroll: root.__noScroll
        property alias scrollAsDial: root.__scrollAsDial
        property alias invertScrollDirection: root.__invertScrollDirection
        property alias invertArrowKeys: root.__invertArrowKeys
    }
    Settings {
        category: "editor"
        property alias forceQtTextRenderer: root.forceQtTextRenderer
    }
    Settings {
        category: "prompter"
        property alias stepsDefault: root.__iDefault
    }
    Settings {
        category: "background"
        property alias opacity: root.__opacity
    }
    Settings {
        category: "telemetry"
        property alias enable: root.__telemetry
    }

    //// Theme management
    //Material.theme: themeSwitch.checked ? Material.Dark : Material.Light  // This is correct, but it isn't work working, likely because of Kirigami

    // Make backgrounds transparent
    //Material.background: "transparent"
    color: "transparent"
    // More ways to enforce transparency across systems
    //visible: true
    flags: root.pageStack.currentItem.hideDecorations===2 || root.pageStack.currentItem.hideDecorations===1 && root.pageStack.currentItem.overlay.atTop && parseInt(root.pageStack.currentItem.prompter.state)!==Prompter.States.Editing || Qt.platform.os==="osx" && __opacity!==1 ? Qt.FramelessWindowHint : Qt.Window

    background: Rectangle {
        id: appTheme
        color: __backgroundColor
        opacity: root.pageStack.layers.depth > 1 || (!root.__translucidBackground || root.pageStack.currentItem.prompterBackground.opacity===1)
        //readonly property color __fontColor: parent.Material.theme===Material.Light ? "#212121" : "#fff"
        //readonly property color __iconColor: parent.Material.theme===Material.Light ? "#232629" : "#c3c7d1"
        //readonly property color __backgroundColor: __translucidBackground ? (parent.Material.theme===Material.Dark ? "#303030" : "#fafafa") : Kirigami.Theme.backgroundColor
        //readonly property color __backgroundColor: __translucidBackground ? (themeSwitch.checked ? "#303030" : "#fafafa") : Kirigami.Theme.backgroundColor
        property int selection: 0
        //readonly property color __backgroundColor: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 1)
        property color __backgroundColor: switch(appTheme.selection) {
            case 0: return Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 1);
            case 1: return "#303030";
            case 2: return "#FAFAFA";
        }
    }
    
    // Full screen
    visibility: __fullScreen ? Kirigami.ApplicationWindow.FullScreen : (!__autoFullScreen ? Kirigami.ApplicationWindow.AutomaticVisibility : (parseInt(root.pageStack.currentItem.prompter.state)===Prompter.States.Editing ? Kirigami.ApplicationWindow.Maximized : Kirigami.ApplicationWindow.FullScreen))

    // Open save dialog on closing
    onClosing: {
        if (root.pageStack.currentItem.document.modified) {
            quitDialog.open()
            close.accepted = false
        }
    }

    function loadAboutPage() {
        root.pageStack.layers.clear()
        root.pageStack.layers.push(aboutPageComponent, {aboutData: aboutData})
    }
    function loadRemoteControlPage() {
        root.pageStack.layers.clear()
        root.pageStack.layers.push(remoteControlPageComponent, {})
    }
    function loadTelemetryPage() {
        root.pageStack.layers.clear()
        root.pageStack.layers.push(telemetryPageComponent)
    }

    // Left Global Drawer
    globalDrawer: Kirigami.GlobalDrawer {
        id: globalMenu
        
        property int bannerCounter: 0
        // isMenu: true
        title: aboutData.displayName
        titleIcon: "qrc:/images/qprompt.png"
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
                iconName: "document-new"
                shortcut: i18n("Ctrl+N")
                onTriggered: root.pageStack.currentItem.document.newDocument()
            },
            Kirigami.Action {
                text: i18n("&Open")
                iconName: "document-open"
                shortcut: i18n("Ctrl+O")
                onTriggered: root.pageStack.currentItem.document.open()
            },
            Kirigami.Action {
                text: i18n("&Save")
                iconName: "document-save"
                shortcut: i18n("Ctrl+S")
                onTriggered: root.pageStack.currentItem.document.saveDialog()
            },
            Kirigami.Action {
                text: i18n("Save &As")
                iconName: "document-save-as"
                shortcut: i18n("Ctrl+Shift+S")
                onTriggered: root.pageStack.currentItem.document.saveAsDialog()
            },
            Kirigami.Action {
                visible: false
                text: i18n("&Recent Files")
                iconName: "document-open-recent"
                //Kirigami.Action {
                    //text: i18n("View Action 1")
                    //onTriggered: showPassiveNotification(i18n("View Action 1 clicked"))
                //}
            },
            Kirigami.Action {
                text: i18n("&Controls Settings")
                iconName: "transform-browse" // "hand"
                Kirigami.Action {
                    visible: ["android", "ios", "tvos", "ipados", "qnx"].indexOf(Qt.platform.os)===-1
                    text: i18n("Keyboard Inputs")
                    iconName: "key-enter" // "keyboard"
                    onTriggered: {
                        root.pageStack.currentItem.key_configuration_overlay.open()
                    }
                }
                Kirigami.Action {
                    text: i18n("Invert &arrow keys")
                    enabled: !root.__noScroll
                    iconName: "circular-arrow-shape"
                    checkable: true
                    checked: root.__invertArrowKeys
                    onTriggered: root.__invertArrowKeys = !root.__invertArrowKeys
                }
                Kirigami.Action {
                    text: i18n("Invert &scroll direction")
                    enabled: !root.__noScroll
                    iconName: "gnumeric-object-scrollbar"
                    checkable: true
                    checked: root.__invertScrollDirection
                    onTriggered: root.__invertScrollDirection = !root.__invertScrollDirection
                }
                Kirigami.Action {
                    text: i18n("Use scroll as velocity &dial")
                    enabled: !root.__noScroll
                    iconName: "filename-bpm-amarok"
                    // ToolTip.text: i18n("Use mouse and touchpad scroll as speed dial while prompting")
                    checkable: true
                    checked: root.__scrollAsDial
                    onTriggered: root.__scrollAsDial = !root.__scrollAsDial
                }
                Kirigami.Action {
                    text: i18n("Disable scrolling while prompting")
                    iconName: "paint-none"
                    checkable: true
                    checked: root.__noScroll
                    onTriggered: root.__noScroll = !root.__noScroll
                }
            },
            Kirigami.Action {
                text: i18n("Other &Settings")
                iconName: "configure"
                Kirigami.Action {
                    text: i18n("Telemetry")
                    iconName: "document-send"
                    onTriggered: {
                        root.loadTelemetryPage()
                    }
                }
                Kirigami.Action {
                    text: i18n("Force sub-pixel text renderer past 120px")
                    // Hiding option because only Qt text renderer is used on devices of greater pixel density, due to bug in rendering native fonts while scaling is enabled.
                    visible: screen.devicePixelRatio === 1.0
                    checkable: true
                    iconName: "format-font-size-more"
                    checked: root.forceQtTextRenderer
                    onTriggered: root.forceQtTextRenderer = !root.forceQtTextRenderer
                }
                Kirigami.Action {
                    text: i18n("Restore factory defaults")
                    iconName: "edit-clear-history"
                    onTriggered: {
                        showPassiveNotification(i18n("Feature not yet implemented"))
                    }
                }
            },
            Kirigami.Action {
                text: i18n("Abou&t") + " " + aboutData.displayName
                iconName: "help-about"
                onTriggered: loadAboutPage()
            },
            Kirigami.Action {
                visible: !Kirigami.Settings.isMobile
                text: i18n("&Quit")
                iconName: "application-exit"
                shortcut: i18n("Ctrl+Q")
                onTriggered: close()
            }
        ]
        topContent: RowLayout {
            Button {
                text: i18n("Load &Guide")
                flat: true
                onClicked: {
                    root.pageStack.currentItem.document.loadInstructions()
                    globalMenu.close()
                }
            }
            // Button {
            //     text: i18n("Remote")
            //     flat: true
            //     onClicked: {
            //         root.pageStack.layers.push(remoteControlPageComponent, {})
            //         globalMenu.close()
            //     }
            // }
            // Button {
            //     id: themeSwitch
            //     text: i18n("Dark &Mode")
            //     flat: true
            //     onClicked: {
            //         appTheme.selection = (appTheme.selection + 1) % 3;
            //         const bg = Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 1);
            //         console.log(bg);
            //         // If the system theme is active, and its background is either black or the exact same as that of either the material light o dark theme's, skip the system theme.
            //         if (appTheme.selection===0 && (Qt.colorEqual(bg, "#000000") || Qt.colorEqual(bg, "#FAFAFA") || Qt.colorEqual(bg, "#303030")))
            //             appTheme.selection = (appTheme.selection + 1) % 3
            //         showPassiveNotification(i18n("Feature not fully implemented"))
            //     }
            // }
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
        content: []
    }
    
    // QML Window Menu Bar
    /*menuBar: MenuBar {
        height: 26  // Value for my current Plasma theme. IDK if this will work elsewhere.
        
        // Hide menuBar on mobile, on themes with translucid background, on full screen, and when the reading region is on top while not in edit mode.
        // Algebraically optimized logic
        visible: !(Kirigami.Settings.isMobile || root.__translucidBackground || root.visibility===Kirigami.ApplicationWindow.FullScreen || (root.pageStack.currentItem.overlay.atTop && parseInt(root.pageStack.currentItem.prompter.state)!==Prompter.States.Editing))
        // Same thing, readable logic
        //visible: !Kirigami.Settings.isMobile && !root.__translucidBackground && root.visibility!==Kirigami.ApplicationWindow.FullScreen && (!root.pageStack.currentItem.overlay.atTop && parseInt(root.pageStack.currentItem.prompter.state)!==Prompter.States.Editing)
        
        Menu {
            title: i18n("&File")
            MenuItem {
                text: i18n("&New")
                onTriggered: root.pageStack.currentItem.document.newDocument()
            }
            MenuItem {
                text: i18n("&Open")
                onTriggered: root.pageStack.currentItem.document.open()
            }
            MenuItem {
                text: i18n("&Save")
                onTriggered: root.pageStack.currentItem.document.saveDialog()
            }
            MenuItem {
                text: i18n("Save &As")
                onTriggered: root.pageStack.currentItem.document.saveAsDialog()
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
                enabled: root.pageStack.currentItem.editor.canUndo
                onTriggered: root.pageStack.currentItem.editor.undo()
            }
            MenuItem {
                text: i18n("&Redo")
                enabled: root.pageStack.currentItem.editor.canRedo
                onTriggered: root.pageStack.currentItem.editor.redo()
            }
            MenuSeparator { }
            MenuItem {
                text: i18n("&Copy")
                enabled: root.pageStack.currentItem.editor.selectedText
                onTriggered: root.pageStack.currentItem.editor.copy()
            }
            MenuItem {
                text: i18n("Cu&t")
                enabled: root.pageStack.currentItem.editor.selectedText
                onTriggered: root.pageStack.currentItem.editor.cut()
            }
            MenuItem {
                text: i18n("&Paste")
                enabled: root.pageStack.currentItem.editor.canPaste
                onTriggered: root.pageStack.currentItem.editor.paste()
            }
        }
        
        Menu {
            title: i18n("&View")
            
            MenuItem {
                text: i18n("Full &screen")
                visible: !fullScreenPlatform
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
                    checked: parseInt(root.pageStack.currentItem.overlay.styleState) === ReadRegionOverlay.PointerStates.LeftPointer
                    onTriggered: root.pageStack.currentItem.overlay.styleState = ReadRegionOverlay.PointerStates.LeftPointer
                }
                MenuItem {
                    text: i18n("&Right Pointer")
                    checkable: true
                    checked: parseInt(root.pageStack.currentItem.overlay.styleState) === ReadRegionOverlay.PointerStates.RightPointer
                    onTriggered: root.pageStack.currentItem.overlay.styleState = ReadRegionOverlay.PointerStates.RightPointer
                }
                MenuItem {
                    text: i18n("B&oth Pointers")
                    checkable: true
                    checked: parseInt(root.pageStack.currentItem.overlay.styleState) === ReadRegionOverlay.PointerStates.Pointers
                    onTriggered: root.pageStack.currentItem.overlay.styleState = ReadRegionOverlay.PointerStates.Pointers
                }
                MenuSeparator { }
                MenuItem {
                    text: i18n("&Bars")
                    checkable: true
                    checked: parseInt(root.pageStack.currentItem.overlay.styleState) === ReadRegionOverlay.PointerStates.Bars
                    onTriggered: root.pageStack.currentItem.overlay.styleState = ReadRegionOverlay.PointerStates.Bars
                }
                MenuItem {
                    text: i18n("Bars Lef&t")
                    checkable: true
                    checked: parseInt(root.pageStack.currentItem.overlay.styleState) === ReadRegionOverlay.PointerStates.BarsLeft
                    onTriggered: root.pageStack.currentItem.overlay.styleState = ReadRegionOverlay.PointerStates.BarsLeft
                }
                MenuItem {
                    text: i18n("Bars Ri&ght")
                    checkable: true
                    checked: parseInt(root.pageStack.currentItem.overlay.styleState) === ReadRegionOverlay.PointerStates.BarsRight
                    onTriggered: root.pageStack.currentItem.overlay.styleState = ReadRegionOverlay.PointerStates.BarsRight
                }
                MenuSeparator { }
                MenuItem {
                    text: i18n("&All")
                    checkable: true
                    checked: parseInt(root.pageStack.currentItem.overlay.styleState) === ReadRegionOverlay.PointerStates.All
                    onTriggered: root.pageStack.currentItem.overlay.styleState = ReadRegionOverlay.PointerStates.All
                }
                MenuItem {
                    text: i18n("&None")
                    checkable: true
                    checked: parseInt(root.pageStack.currentItem.overlay.styleState) === ReadRegionOverlay.PointerStates.None
                    onTriggered: root.pageStack.currentItem.overlay.styleState = ReadRegionOverlay.PointerStates.None
                }
            }
            Menu {
                title: i18n("Readin&g region")
                MenuItem {
                    text: i18n("&Top")
                    checkable: true
                    checked: parseInt(root.pageStack.currentItem.overlay.positionState) === ReadRegionOverlay.PositionStates.Top
                    onTriggered: root.pageStack.currentItem.overlay.positionState = ReadRegionOverlay.PositionStates.Top
                }
                MenuItem {
                    text: i18n("&Middle")
                    checkable: true
                    checked: parseInt(root.pageStack.currentItem.overlay.positionState) === ReadRegionOverlay.PositionStates.Middle
                    onTriggered: root.pageStack.currentItem.overlay.positionState = ReadRegionOverlay.PositionStates.Middle
                }
                MenuItem {
                    text: i18n("&Bottom")
                    checkable: true
                    checked: parseInt(root.pageStack.currentItem.overlay.positionState) === ReadRegionOverlay.PositionStates.Bottom
                    onTriggered: root.pageStack.currentItem.overlay.positionState = ReadRegionOverlay.PositionStates.Bottom
                }
                MenuSeparator { }
                MenuItem {
                    text: i18n("F&ree placement")
                    checkable: true
                    checked: parseInt(root.pageStack.currentItem.overlay.positionState) === ReadRegionOverlay.PositionStates.Free
                    onTriggered: root.pageStack.currentItem.overlay.positionState = ReadRegionOverlay.PositionStates.Free
                }
                MenuItem {
                    text: i18n("C&ustom (Fixed placement)")
                    checkable: true
                    checked: parseInt(root.pageStack.currentItem.overlay.positionState) === ReadRegionOverlay.PositionStates.Fixed
                    onTriggered: root.pageStack.currentItem.overlay.positionState = ReadRegionOverlay.PositionStates.Fixed
                }
            }
        }
        Menu {
            title: i18n("For&mat")
            
            MenuItem {
                text: i18n("&Bold")
                checkable: true
                checked: root.pageStack.currentItem.document.bold
                onTriggered: root.pageStack.currentItem.document.bold = !root.pageStack.currentItem.document.bold
            }
            MenuItem {
                text: i18n("&Italic")
                checkable: true
                checked: root.pageStack.currentItem.document.italic
                onTriggered: root.pageStack.currentItem.document.italic = !root.pageStack.currentItem.document.italic
            }
            MenuItem {
                text: i18n("&Underline")
                checkable: true
                checked: root.pageStack.currentItem.document.underline
                onTriggered: root.pageStack.currentItem.document.underline = !root.pageStack.currentItem.document.underline
            }
            MenuSeparator { }
            MenuItem {
                text: Qt.application.layoutDirection===Qt.LeftToRight ? i18n("&Left") : i18n("&Right")
                checkable: true
                checked: Qt.application.layoutDirection===Qt.LeftToRight ? root.pageStack.currentItem.document.alignment === Qt.AlignLeft : root.pageStack.currentItem.document.alignment === Qt.AlignRight
                onTriggered: {
                    if (Qt.application.layoutDirection===Qt.LeftToRight)
                        root.pageStack.currentItem.document.alignment = Qt.AlignLeft
                    else
                        root.pageStack.currentItem.document.alignment = Qt.AlignRight
                }
            }
            MenuItem {
                text: i18n("Cen&ter")
                checkable: true
                checked: root.pageStack.currentItem.document.alignment === Qt.AlignHCenter
                onTriggered: root.pageStack.currentItem.document.alignment = Qt.AlignHCenter
            }
            MenuItem {
                text: Qt.application.layoutDirection===Qt.LeftToRight ? i18n("&Right") : i18n("&Left")
                checkable: true
                checked: Qt.application.layoutDirection===Qt.LeftToRight ? root.pageStack.currentItem.document.alignment === Qt.AlignRight : root.pageStack.currentItem.document.alignment === Qt.AlignLeft
                onTriggered: {
                    if (Qt.application.layoutDirection===Qt.LeftToRight)
                        root.pageStack.currentItem.document.alignment = Qt.AlignRight
                    else
                        root.pageStack.currentItem.document.alignment = Qt.AlignLeft
                }
            }
            // Justify is proven to make text harder to read for some readers. So I'm commenting out all text justification options from the program. I'm not removing them, only commenting out in case someone needs to re-enable. This article links to various sources that validate my decision: https://kaiweber.wordpress.com/2010/05/31/ragged-right-or-justified-alignment/ - Javier
            //MenuItem {
            //    text: i18n("&Justify")
            //    checkable: true
            //    checked: root.pageStack.currentItem.document.alignment === Qt.AlignJustify
            //    onTriggered: root.pageStack.currentItem.document.alignment = Qt.AlignJustify
            //}
            MenuSeparator { }
            MenuItem {
                text: i18n("C&haracter")
                onTriggered: root.pageStack.currentItem.fontDialog.open();
            }
            MenuItem {
                text: i18n("Fo&nt Color")
                onTriggered: root.pageStack.currentItem.colorDialog.open()
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
                onTriggered: root.pageStack.currentItem.document.loadInstructions()
            }
            MenuSeparator { }
            MenuItem {
                text: i18n("Abou&t QPrompt")
                onTriggered: root.loadAboutPage()
                icon.source: "qrc:/images/qprompt.png"
            }
        }
    }*/
/*
    Labs.MenuBar {
        id: nativeMenus
        window: root
        Labs.Menu {
            title: i18n("&File")
            
            Labs.MenuItem {
                text: i18n("&New")
                onTriggered: root.pageStack.currentItem.document.newDocument()
            }
            Labs.MenuItem {
                text: i18n("&Open")
                onTriggered: root.pageStack.currentItem.document.open()
            }
            Labs.MenuItem {
                text: i18n("&Save")
                onTriggered: root.pageStack.currentItem.document.saveDialog()
            }
            Labs.MenuItem {
                text: i18n("Save &As...")
                onTriggered: root.pageStack.currentItem.document.saveAsDialog()
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
                enabled: root.pageStack.currentItem.editor.canUndo
                onTriggered: root.pageStack.currentItem.editor.undo()
            }
            Labs.MenuItem {
                text: i18n("&Redo")
                enabled: root.pageStack.currentItem.editor.canRedo
                onTriggered: root.pageStack.currentItem.editor.redo()
            }
            Labs.MenuSeparator { }
            Labs.MenuItem {
                text: i18n("&Copy")
                enabled: root.pageStack.currentItem.editor.selectedText
                onTriggered: root.pageStack.currentItem.editor.copy()
            }
            Labs.MenuItem {
                text: i18n("Cu&t")
                enabled: root.pageStack.currentItem.editor.selectedText
                onTriggered: root.pageStack.currentItem.editor.cut()
            }
            Labs.MenuItem {
                text: i18n("&Paste")
                enabled: root.pageStack.currentItem.editor.canPaste
                onTriggered: root.pageStack.currentItem.editor.paste()
            }
        }
        
        Labs.Menu {
            title: i18n("&View")
            
            Labs.MenuItem {
                text: i18n("Full &screen")
                visible: !fullScreenPlatform
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
                    checked: parseInt(root.pageStack.currentItem.overlay.styleState) === ReadRegionOverlay.PointerStates.LeftPointer
                    onTriggered: root.pageStack.currentItem.overlay.styleState = ReadRegionOverlay.PointerStates.LeftPointer
                }
                Labs.MenuItem {
                    text: i18n("&Right Pointer")
                    checkable: true
                    checked: parseInt(root.pageStack.currentItem.overlay.styleState) === ReadRegionOverlay.PointerStates.RightPointer
                    onTriggered: root.pageStack.currentItem.overlay.styleState = ReadRegionOverlay.PointerStates.RightPointer
                }
                Labs.MenuItem {
                    text: i18n("B&oth Pointers")
                    checkable: true
                    checked: parseInt(root.pageStack.currentItem.overlay.styleState) === ReadRegionOverlay.PointerStates.Pointers
                    onTriggered: root.pageStack.currentItem.overlay.styleState = ReadRegionOverlay.PointerStates.Pointers
                }
                Labs.MenuSeparator { }
                Labs.MenuItem {
                    text: i18n("&Bars")
                    checkable: true
                    checked: parseInt(root.pageStack.currentItem.overlay.styleState) === ReadRegionOverlay.PointerStates.Bars
                    onTriggered: root.pageStack.currentItem.overlay.styleState = ReadRegionOverlay.PointerStates.Bars
                }
                Labs.MenuItem {
                    text: i18n("Bars Lef&t")
                    checkable: true
                    checked: parseInt(root.pageStack.currentItem.overlay.styleState) === ReadRegionOverlay.PointerStates.BarsLeft
                    onTriggered: root.pageStack.currentItem.overlay.styleState = ReadRegionOverlay.PointerStates.BarsLeft
                }
                Labs.MenuItem {
                    text: i18n("Bars Ri&ght")
                    checkable: true
                    checked: parseInt(root.pageStack.currentItem.overlay.styleState) === ReadRegionOverlay.PointerStates.BarsRight
                    onTriggered: root.pageStack.currentItem.overlay.styleState = ReadRegionOverlay.PointerStates.BarsRight
                }
                Labs.MenuSeparator { }
                Labs.MenuItem {
                    text: i18n("&All")
                    checkable: true
                    checked: parseInt(root.pageStack.currentItem.overlay.styleState) === ReadRegionOverlay.PointerStates.All
                    onTriggered: root.pageStack.currentItem.overlay.styleState = ReadRegionOverlay.PointerStates.All
                }
                Labs.MenuItem {
                    text: i18n("&None")
                    checkable: true
                    checked: parseInt(root.pageStack.currentItem.overlay.styleState) === ReadRegionOverlay.PointerStates.None
                    onTriggered: root.pageStack.currentItem.overlay.styleState = ReadRegionOverlay.PointerStates.None
                }
            }
            Labs.Menu {
                title: i18n("Readin&g region")
                Labs.MenuItem {
                    text: i18n("&Top")
                    checkable: true
                    checked: parseInt(root.pageStack.currentItem.overlay.positionState) === ReadRegionOverlay.PositionStates.Top
                    onTriggered: root.pageStack.currentItem.overlay.positionState = ReadRegionOverlay.PositionStates.Top
                }
                Labs.MenuItem {
                    text: i18n("&Middle")
                    checkable: true
                    checked: parseInt(root.pageStack.currentItem.overlay.positionState) === ReadRegionOverlay.PositionStates.Middle
                    onTriggered: root.pageStack.currentItem.overlay.positionState = ReadRegionOverlay.PositionStates.Middle
                }
                Labs.MenuItem {
                    text: i18n("&Bottom")
                    checkable: true
                    checked: parseInt(root.pageStack.currentItem.overlay.positionState) === ReadRegionOverlay.PositionStates.Bottom
                    onTriggered: root.pageStack.currentItem.overlay.positionState = ReadRegionOverlay.PositionStates.Bottom
                }
                Labs.MenuSeparator { }
                Labs.MenuItem {
                    text: i18n("F&ree placement")
                    checkable: true
                    checked: parseInt(root.pageStack.currentItem.overlay.positionState) === ReadRegionOverlay.PositionStates.Free
                    onTriggered: root.pageStack.currentItem.overlay.positionState = ReadRegionOverlay.PositionStates.Free
                }
                Labs.MenuItem {
                    text: i18n("C&ustom (Fixed placement)")
                    checkable: true
                    checked: parseInt(root.pageStack.currentItem.overlay.positionState) === ReadRegionOverlay.PositionStates.Fixed
                    onTriggered: root.pageStack.currentItem.overlay.positionState = ReadRegionOverlay.PositionStates.Fixed
                }
            }
        }
        Labs.Menu {
            title: i18n("For&mat")
            
            Labs.MenuItem {
                text: i18n("&Bold")
                checkable: true
                checked: root.pageStack.currentItem.document.bold
                onTriggered: root.pageStack.currentItem.document.bold = !root.pageStack.currentItem.document.bold
            }
            Labs.MenuItem {
                text: i18n("&Italic")
                checkable: true
                checked: root.pageStack.currentItem.document.italic
                onTriggered: root.pageStack.currentItem.document.italic = !root.pageStack.currentItem.document.italic
            }
            Labs.MenuItem {
                text: i18n("&Underline")
                checkable: true
                checked: root.pageStack.currentItem.document.underline
                onTriggered: root.pageStack.currentItem.document.underline = !root.pageStack.currentItem.document.underline
            }
            Labs.MenuSeparator { }
            Labs.MenuItem {
                text: Qt.application.layoutDirection===Qt.LeftToRight ? i18n("&Left") : i18n("&Right")
                checkable: true
                checked: Qt.application.layoutDirection===Qt.LeftToRight ? root.pageStack.currentItem.document.alignment === Qt.AlignLeft : root.pageStack.currentItem.document.alignment === Qt.AlignRight
                onTriggered: {
                    if (Qt.application.layoutDirection===Qt.LeftToRight)
                        root.pageStack.currentItem.document.alignment = Qt.AlignLeft
                    else
                        root.pageStack.currentItem.document.alignment = Qt.AlignRight
                }
            }
            Labs.MenuItem {
                text: i18n("Cen&ter")
                checkable: true
                checked: root.pageStack.currentItem.document.alignment === Qt.AlignHCenter
                onTriggered: root.pageStack.currentItem.document.alignment = Qt.AlignHCenter
            }
            Labs.MenuItem {
                text: Qt.application.layoutDirection===Qt.LeftToRight ? i18n("&Right") : i18n("&Left")
                checkable: true
                checked: Qt.application.layoutDirection===Qt.LeftToRight ? root.pageStack.currentItem.document.alignment === Qt.AlignRight : root.pageStack.currentItem.document.alignment === Qt.AlignLeft
                onTriggered: {
                    if (Qt.application.layoutDirection===Qt.LeftToRight)
                        root.pageStack.currentItem.document.alignment = Qt.AlignRight
                    else
                        root.pageStack.currentItem.document.alignment = Qt.AlignLeft
                }
            }
            // Justify is proven to make text harder to read for some readers. So I'm commenting out all text justification options from the program. I'm not removing them, only commenting out in case someone needs to re-enable. This article links to various sources that validate my decision: https://kaiweber.wordpress.com/2010/05/31/ragged-right-or-justified-alignment/ - Javier
            //Labs.MenuItem {
            //    text: i18n("&Justify")
            //    checkable: true
            //    checked: root.pageStack.currentItem.document.alignment === Qt.AlignJustify
            //    onTriggered: root.pageStack.currentItem.document.alignment = Qt.AlignJustify
            //}
            Labs.MenuSeparator { }
            Labs.MenuItem {
                text: i18n("C&haracter")
                onTriggered: root.pageStack.currentItem.fontDialog.open();
            }
            Labs.MenuItem {
                text: i18n("Fo&nt Color")
                onTriggered: root.pageStack.currentItem.colorDialog.open()
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
                icon.source: "qrc:/images/qprompt.png"
            }
        }
    }
*/
    // Right Context Drawer
    contextDrawer: Kirigami.ContextDrawer {
        id: contextDrawer
        background: Rectangle {
            color: appTheme.__backgroundColor
        }
    }

    // Top bar background hack
    Rectangle {
        // Uncomment when using a version of kirigami that allows one to use the mobile layout on the desktop, which is needed to be able to hide the top menu bar.
        //visible: !Kirigami.Settings.isMobile && pageStack.globalToolBar.actualStyle !== Kirigami.ApplicationHeaderStyle.None
        visible: !Kirigami.Settings.isMobile
        color: appTheme.__backgroundColor
        anchors{ top:parent.top; left:parent.left; right: parent.right }
        opacity: root.__opacity * 0.4 + 0.6
       height: 40
       z: -1
    }

    // Top bar foreground hack for window dragging
    Item {
        anchors {
            top: parent.top;
            left: parent.left;
        }
        height: 40
        width: 180
        MouseArea {
            enabled: !Kirigami.Settings.isMobile && pageStack.globalToolBar.actualStyle !== Kirigami.ApplicationHeaderStyle.None
            anchors.fill: parent
            property int prevX: 0
            property int prevY: 0
            cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
            onPressed: {
                prevX=mouse.x
                prevY=mouse.y
            }
            onPositionChanged: {
                var deltaX = mouse.x - prevX;

                root.x += deltaX;
                prevX = mouse.x - deltaX;

                var deltaY = mouse.y - prevY
                root.y += deltaY;
                prevY = mouse.y - deltaY;
            }
            onClicked: {
                root.pageStack.layers.clear();
            }
        }
    }
    
    // Kirigami PageStack and PageRow
    pageStack.globalToolBar.toolbarActionAlignment: Qt.AlignHCenter
    pageStack.initialPage: prompterPageComponent
    // Auto hide global toolbar on fullscreen
    //pageStack.globalToolBar.style: visibility===Kirigami.ApplicationWindow.FullScreen ? Kirigami.ApplicationHeaderStyle.None :  Kirigami.ApplicationHeaderStyle.Auto
    pageStack.globalToolBar.style: Kirigami.Settings.isMobile ? (parseInt(root.pageStack.currentItem.prompter.state)===Prompter.States.Editing ? Kirigami.ApplicationHeaderStyle.Breadcrumb : Kirigami.ApplicationHeaderStyle.None) : (parseInt(root.pageStack.currentItem.prompter.state)!==Prompter.States.Editing && (visibility===Kirigami.ApplicationWindow.FullScreen || root.pageStack.currentItem.overlay.atTop) ? Kirigami.ApplicationHeaderStyle.None : Kirigami.ApplicationHeaderStyle.ToolBar)
    
    // The following is not possible in the current version of Kirigami, but it should be:
    //pageStack.globalToolBar.background: Rectangle {
        //color: appTheme.__backgroundColor
    //}
    //property alias prompterPage: root.pageStack.currentItem
    //property alias prompterPage: root.pageStack.layers.currentItem
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

    property int q: 0
    onFrameSwapped: {
        // Check that state is not prompting and editor isn't active.
        // In this implementation we can't detect moving past marker while the editor is active because this feature shares its cursor as a means of detection.
        if (parseInt(root.pageStack.currentItem.prompter.state)===Prompter.States.Prompting && !root.pageStack.currentItem.editor.focus) {
            // Detect when moving past a marker.
            // I'm doing this here because there's no event that occurs on each bit of scroll, and this takes much less CPU than a timer, is more precise and scales better.
            root.pageStack.currentItem.prompter.setCursorAtCurrentPosition()
            root.pageStack.currentItem.editor.cursorPosition = root.pageStack.currentItem.document.nextMarker(root.pageStack.currentItem.editor.cursorPosition).position
            // Here, p is for position
            const p = root.pageStack.currentItem.editor.cursorRectangle.y
            if (q !== p) {
                if (q < p && q !== 0) {
                    const url = root.pageStack.currentItem.document.previousMarker(root.pageStack.currentItem.editor.cursorPosition).url;
                    console.log(url);
                }
                q = p;
            }
        }
        // Update Projections
        const n = projectionManager.model.count;
        if (n)
            root.pageStack.currentItem.viewport.grabToImage(function(p) {
                for (var i=0; i<n; ++i)
                    projectionManager.model.setProperty(i, "p", String(p.url));
            });
    }

    ProjectionsManager {
        id: projectionManager
        backgroundColor: root.pageStack.currentItem.prompterBackground.color
        backgroundOpacity: root.pageStack.currentItem.prompterBackground.opacity
        // Forward to prompter and not editor to prevent editing from projection windows
        forwardTo: root.pageStack.currentItem.prompter
    }

    // Prompter Page Contents
    //pageStack.initialPage:

    // Prompter Page Component {
    Component {
        id: prompterPageComponent
        PrompterPage {}
    }

    // Page Components
    Component {
        id: aboutPageComponent
        AboutPage {}
    }
    Component {
        id: remoteControlPageComponent
        RemotePage {}
    }
    Component {
        id: telemetryPageComponent
        TelemetryPage {}
    }

    // Dialogues
    MessageDialog {
        id : quitDialog
        title: i18n("Save Document")
        text: i18n("Save changes to document before closing?")
        icon: StandardIcon.Question
        standardButtons: StandardButton.Save | StandardButton.Discard | StandardButton.Cancel
        onDiscard: Qt.quit()
        onAccepted: root.pageStack.currentItem.document.saveDialog(true)
        //buttons: (Labs.MessageDialog.Save | Labs.MessageDialog.Discard | Labs.MessageDialog.Cancel)
        //onDiscardClicked: Qt.quit()
        //onSaveClicked: root.pageStack.currentItem.document.saveDialog(true)
    }
}
