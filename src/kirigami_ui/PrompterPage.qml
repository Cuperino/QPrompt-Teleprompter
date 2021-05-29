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
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.platform 1.1

Kirigami.Page {
    id: prompterPage
    
    // Unused signal. Leaving for reference.
    //signal test( bool data )

    property alias fontDialog: fontDialog
    property alias colorDialog: colorDialog
    property alias prompter: viewport.prompter
    property alias editor: viewport.editor
    property alias overlay: viewport.overlay
    property alias document: viewport.document
    property alias prompterBackground: viewport.prompterBackground
    property alias key_configuration_overlay: key_configuration_overlay
    property alias telemetry_overlay: telemetry_overlay
    
    property int hideDecorations: 0

    title: "QPrompt"
    globalToolBarStyle: Kirigami.Settings.isMobile ? Kirigami.ApplicationHeaderStyle.None : Kirigami.ApplicationHeaderStyle.ToolBar
    padding: 0

    actions {
        main: Kirigami.Action {
            id: promptingButton
            text: i18n("Start prompter")
            iconName: Qt.application.layoutDirection === Qt.RightToLeft ? "go-previous" : "go-next"
            onTriggered: prompter.toggle()
        }
        left: Kirigami.Action {
            id: decreaseVelocityButton
            enabled: false
            text: pageStack.globalToolBar.actualStyle === Kirigami.ApplicationHeaderStyle.None ? i18n("Decrease velocity") : ""
            iconName: Qt.application.layoutDirection === Qt.RightToLeft ? "go-next" : "go-previous"
            onTriggered: viewport.prompter.decreaseVelocity(false)
        }
        right: Kirigami.Action {
            id: increaseVelocityButton
            enabled: false
            text: pageStack.globalToolBar.actualStyle === Kirigami.ApplicationHeaderStyle.None ? i18n("Increase velocity") : ""
            iconName: Qt.application.layoutDirection === Qt.RightToLeft ? "go-previous" : "go-next"
            onTriggered: viewport.prompter.increaseVelocity(false)
        }
        contextualActions: [
        Kirigami.Action {
            id: wysiwygButton
            text: i18n("WYSIWYG")
            checkable: true
            checked: viewport.prompter.__wysiwyg
            tooltip: viewport.prompter.__wysiwyg ? i18n("\"What you see is what you get\" mode is On") : i18n("\"What you see is what you get\" mode is Off")
            onTriggered: {
                viewport.prompter.__wysiwyg = !viewport.prompter.__wysiwyg
                editor.focus = true
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
                //iconName: "refresh"
                readonly property string shortName: i18n("No Flip")
                onTriggered: {
                    parent.updateButton(this)
                    viewport.prompter.__flipX = false
                    viewport.prompter.__flipY = false
                }
                enabled: viewport.prompter.__flipX || viewport.prompter.__flipY
            }
            Kirigami.Action {
                text: i18n("Horizontal Flip")
                //iconName: "refresh"
                readonly property string shortName: i18n("H Flip")
                onTriggered: {
                    parent.updateButton(this)
                    viewport.prompter.__flipX = true
                    viewport.prompter.__flipY = false
                }
                enabled: (!viewport.prompter.__flipX) || viewport.prompter.__flipY
            }
            Kirigami.Action {
                text: i18n("Vertical Flip")
                //iconName: "refresh"
                readonly property string shortName: i18n("V Flip")
                onTriggered: {
                    parent.updateButton(this)
                    viewport.prompter.__flipX = false
                    viewport.prompter.__flipY = true
                }
                enabled: viewport.prompter.__flipX || !viewport.prompter.__flipY
            }
            Kirigami.Action {
                text: i18n("180° rotation")
                //iconName: "refresh"
                readonly property string shortName: i18n("HV Flip")
                onTriggered: {
                    parent.updateButton(this)
                    viewport.prompter.__flipX = true
                    viewport.prompter.__flipY = true
                }
                enabled: !(viewport.prompter.__flipX && viewport.prompter.__flipY)
            }
        },
        Kirigami.Action {
            id: readRegionButton
            text: i18n("Reading region")
            //onTriggered: viewport.overlay.toggle()
            tooltip: i18n("Change reading region placement")
            
            Kirigami.Action {
                id: readRegionTopButton
                iconName: "go-up"
                text: i18n("Top")
                onTriggered: viewport.overlay.positionState = "top"
                enabled: viewport.overlay.positionState!=="top"
                tooltip: i18n("Move reading region to the top, convenient for use with webcams")
            }
            Kirigami.Action {
                id: readRegionMiddleButton
                iconName: "remove"
                text: i18n("Middle")
                onTriggered: viewport.overlay.positionState = "middle"
                enabled: viewport.overlay.positionState!=="middle"
                tooltip: i18n("Move reading region to the vertical center")
            }
            Kirigami.Action {
                id: readRegionBottomButton
                iconName: "go-down"
                text: i18n("Bottom")
                onTriggered: viewport.overlay.positionState = "bottom"
                enabled: viewport.overlay.positionState!=="bottom"
                tooltip: i18n("Move reading region to the bottom")
            }
            Kirigami.Action {
                id: readRegionFreeButton
                iconName: "gtk-edit"
                text: i18n("Free")
                onTriggered: viewport.overlay.positionState = "free"
                enabled: viewport.overlay.positionState!=="free"
                tooltip: i18n("Move reading region freely by dragging and dropping")
            }
            Kirigami.Action {
                id: readRegionCustomButton
                iconName: "gtk-apply"
                text: i18n("Custom")
                onTriggered: viewport.overlay.positionState = "fixed"
                enabled: viewport.overlay.positionState!=="fixed"
                tooltip: i18n("Fix reading region to the position set using free placement mode")
            }
            Kirigami.Action {
                id: hideDecorationsButton
                text: hideDecorations===0 ? i18n("Frame Settings") : (hideDecorations===1 ? i18n("Auto hide frame") : i18n("Always hide frame"))
                visible: ['android', 'ios', 'wasm', 'tvos', 'qnx', 'ipados'].indexOf(Qt.platform.os)===-1
                tooltip: i18n("Auto hide window decorations when not editing and read region is set to top")
                Kirigami.Action {
                    text: i18n("Normal frame")
                    tooltip: i18n("Shows windows frame when in windowed mode")
                    onTriggered: {
                        hideDecorations = 0
                        parent.text = text
                    }
                }
                Kirigami.Action {
                    text: i18n("Auto hide frame")
                    tooltip: i18n("Auto hide window decorations when not editing and read region is set to top")
                    onTriggered: {
                        hideDecorations = 1
                        parent.text = text
                    }
                }
                Kirigami.Action {
                    text: i18n("Always hide frame")
                    tooltip: i18n("Always hide window decorations")
                    onTriggered: {
                        hideDecorations = 2
                        parent.text = text
                    }
                }
            }
        },
        Kirigami.Action {
            id: readRegionStyleButton
            text: i18n("Pointers")
            tooltip: i18n("Change pointers that indicate reading region")
            
            Kirigami.Action {
                id: readRegionLeftPointerButton
                text: i18n("Left Pointer")
                onTriggered: overlay.styleState = "leftPointer"
                tooltip: i18n("Left pointer indicates reading region")
                enabled: overlay.styleState!=="leftPointer"
            }
            Kirigami.Action {
                id: readRegionRightPointerButton
                text: i18n("Right Pointer")
                onTriggered: overlay.styleState = "rightPointer"
                tooltip: i18n("Right pointer indicates reading region")
                enabled: overlay.styleState!=="rightPointer"
            }
            Kirigami.Action {
                id: readRegionPointersButton
                text: i18n("Both Pointers")
                onTriggered: overlay.styleState = "pointers"
                tooltip: i18n("Left and right pointers indicate reading region")
                enabled: overlay.styleState!=="pointers"
            }
            Kirigami.Action {
                id: readRegionBarsButton
                text: i18n("Bars")
                onTriggered: overlay.styleState = "bars"
                tooltip: i18n("Translucent bars indicate reading region")
                enabled: overlay.styleState!=="bars"
            }
            Kirigami.Action {
                id: readRegionBarsLeftButton
                text: i18n("Bars and Left Pointer")
                onTriggered: overlay.styleState = "barsLeft"
                tooltip: i18n("Translucent bars and left pointer indicate reading region")
                enabled: overlay.styleState!=="barsLeft"
            }
            Kirigami.Action {
                id: readRegionBarsRightButton
                text: i18n("Bars and Right Pointer")
                onTriggered: overlay.styleState = "barsRight"
                tooltip: i18n("Translucent bars and right pointer indicate reading region")
                enabled: overlay.styleState!=="barsRight"
            }
            Kirigami.Action {
                id: readRegionAllButton
                text: i18n("All")
                onTriggered: overlay.styleState = "all"
                tooltip: i18n("Use all reading region indicators")
                enabled: overlay.styleState!=="all"
            }
            Kirigami.Action {
                id: readRegionNoneButton
                text: i18n("None")
                onTriggered: overlay.styleState = "none"
                tooltip: i18n("Disable reading region indicators")
                enabled: overlay.styleState!=="none"
            }
        },
        Kirigami.Action {
            id: loadBackgroundButton
            text: i18n("Background")
            
            Kirigami.Action {
                id: changeBackgroundImageButton
                text: i18n("Set Image")
                onTriggered: prompterBackground.loadBackgroundImage()
            }
            Kirigami.Action {
                id: changeBackgroundColorButton
                text: i18n("Set Color")
                onTriggered: prompterBackground.backgroundColorDialog.open()
            }
            Kirigami.Action {
                id: clearBackgroundButton
                text: i18n("Clear Background")
                enabled: prompterBackground.hasBackground
                onTriggered: prompterBackground.clearBackground()
            }
        },
        Kirigami.Action {
            id: countdownConfigButton
            text: i18n("Countdown")
            Kirigami.Action {
                id: enableFramingButton
                enabled: !autoStartCountdownButton.checked
                checkable: true
                checked: viewport.countdown.frame && !autoStartCountdownButton.checked
                text: i18n("Auto Frame")
                onTriggered: {
                    viewport.countdown.frame = !viewport.countdown.frame
                    //// Future: Implement way to way to prevent Kirigami.Action from closing parent Action menu.
                    //if (viewport.countdown.enabled)
                    //    // Use of implemented feature might go here.
                }
            }
            Kirigami.Action {
                id: enableCountdownButton
                enabled: viewport.countdown.frame
                checkable: true
                checked: viewport.countdown.enabled
                text: i18n("Countdown")
                onTriggered: {
                    viewport.countdown.enabled = !viewport.countdown.enabled
                    //// Future: Implement way to way to prevent Kirigami.Action from closing parent Action menu.
                    //if (viewport.countdown.enabled)
                    //    // Use of implemented feature might go here.
                }
            }
            Kirigami.Action {
                id: autoStartCountdownButton
                enabled: enableCountdownButton.enabled && viewport.countdown.enabled
                checkable: true
                checked: viewport.countdown.autoStart
                text: i18n("Auto Countdown")
                tooltip: i18n("Start countdown automatically")
                onTriggered: viewport.countdown.autoStart = !viewport.countdown.autoStart
            }
            Kirigami.Action {
                id: setCountdownButton
                enabled: enableCountdownButton.enabled && viewport.countdown.enabled
                text: i18n("Set Duration")
                onTriggered: {
                    viewport.countdown.configuration.open()
                }
            }
        },
        Kirigami.Action {
            id: timerButton
            text: i18n("Timer")
            Kirigami.Action {
                id: enableStopwatchButton
                checkable: true
                checked: viewport.timer.stopwatch
                text: i18n("Stopwatch")
                onTriggered: {
                    viewport.timer.stopwatch = !viewport.timer.stopwatch
                }
            }
            Kirigami.Action {
                id: enableETAButton
                checkable: true
                checked: viewport.timer.eta
                text: i18n("ETA")
                onTriggered: {
                    viewport.timer.eta = !viewport.timer.eta
                }
            }
            Kirigami.Action {
                id: timerColorButton
                text: i18n("Timer Color")
                onTriggered: {
                    viewport.timer.setColor()
                }
            }
        },
        //Kirigami.Action {
           //id: projectionConfigButton
           //text: i18n("Clone")
           //tooltip: i18n("Duplicate teleprompter contents into separate screens")
           //onTriggered: projectionWindow.visible = !projectionWindow.visible
        //}
        //Kirigami.Action {
           //id: debug
           //text: i18n("Debug")
           //tooltip: i18n("Debug Action")
           //onTriggered: {
                //console.log("Debug Action")
                //prompterPage.test( true )
           //}
        //}
        Kirigami.Action {
            id: leaveFullscreenButton
            text: i18n("Leave Fullscreen")
            visible: root.__fullScreen
            onTriggered: root.__fullScreen = !root.__fullScreen
        }
        ]
    }

    PrompterView {
        id: viewport
        // Workaround to make regular Page let its contents be covered by action buttons.
        anchors.bottomMargin: Kirigami.Settings.isMobile ? -68 : 0
        property alias toolbar: editorToolbar
    }

    progress: viewport.prompter.state==="prompting" ? viewport.prompter.progress : undefined

    FontDialog {
        id: fontDialog
        options: FontDialog.ScalableFonts|FontDialog.MonospacedFonts|FontDialog.ProportionalFonts
        onAccepted: {
            viewport.prompter.document.fontFamily = font.family;
            //viewport.prompter.document.fontSize = font.pointSize*viewport.prompter.editor.font.pixelSize/6;
        }
    }
    
    ColorDialog {
        id: colorDialog
        currentColor: Kirigami.Theme.textColor
    }
    
//     ShaderEffectSource {
//         id: layerOfLayer
//         width: parent.width; height: parent.height
//         sourceItem: viewport
//         hideSource: true
//     }

//     ProjectionWindow {
//         id: projectionWindow
//     }

    // Editor Toolbar
    footer: EditorToolbar {
        id: editorToolbar
    }

    // Prompter Page Component {
    //Component {
        //id: projectionWindow
        //ProjectionWindow {}
    //}

    Kirigami.OverlayDrawer {
        id: sideDrawer
        background: Rectangle {
            color: appTheme.__backgroundColor
        }
        width: 240
//        width: popupContent.implicitWidth
        edge: Qt.RightEdge
        padding: 0
        leftPadding: 0
        rightPadding: 0
        bottomPadding: 0
        topPadding: 0

        parent: prompterPage.overlay // applicationWindow().overlay

//        header: Kirigami.Heading {
//            text: i18n("Marker List")
//            level: 1
//        }

        // ListModel {
        //     id: nameModel
        //     ListElement { lineNo: 2; linePos: 128; lineName: "Alice" }
        //     ListElement { lineNo: 6; linePos: 386; lineName: "Bob" }
        //     ListElement { lineNo: 8; linePos: 912; lineName: "Marley" }
        //     ListElement { lineNo: 9; linePos: 1000; lineName: "Joe" }
        // }

        Component {
            id: markerDelegateComponent
            Rectangle {
                width: ListView.view.width
                height: 40
                color: appTheme.__backgroundColor
                Text {
                    anchors {
                        fill: parent
                        margins: 5
                    }
                    text: model.lineNo + ", " + model.linePos + " (" + model.lineName + ")"
                    color: "#FFF"
                }
            }
        }

        ColumnLayout {
            id: popupContent
            width: parent.width
            height: parent.height
            spacing: 0
            ListView {
                Layout.fillHeight: true
                Layout.fillWidth: true
                spacing: 2
                model: _markersModel // nameModel
                delegate: markerDelegateComponent
                clip: true
                ScrollBar.vertical: ScrollBar { }
            }
            Kirigami.BasicListItem {
                Layout.alignment: Qt.AlignBottom
                text: i18n("Close Marker List")
                onClicked: {
                    sideDrawer.close();
                }
            }
        }
    }

    Kirigami.OverlaySheet {
        id: key_configuration_overlay
        onSheetOpenChanged: prompterPage.actions.main.checked = sheetOpen
        
        background: Rectangle {
            color: appTheme.__backgroundColor
            anchors.fill: parent
        }
        header: Kirigami.Heading {
            text: i18n("Key Bindings")
            level: 1
        }

        GridLayout {
            width: parent.width
            columns: 2

            // Toggle all buttons off
            function toggleButonsOff() {
                for (let i=1; i<children.length; i+=2)
                    children[i].checked = false;
            }
            // Validate input
            function isValidInput(input) {
                let flag = false;
                Object.values(prompter.keys).every(assignedKey => {
                    flag = assignedKey===input;
                    return !flag;
                });
                return !flag && [Qt.Key_Escape, Qt.Key_Super_L, Qt.Key_Super_R, Qt.Key_Meta].indexOf(input)===-1
            }
            // Get key text
            function getKeyText(event) {
                let text = "";
                switch (event.key) {
                    case Qt.Key_Escape: text = i18n("ESC"); break;
                    case Qt.Key_Space: text = i18n("Spacebar"); break;
                    case Qt.Key_Up: text = i18n("Up Arrow"); break;
                    case Qt.Key_Down: text = i18n("Down Arrow"); break;
                    case Qt.Key_Left: text = i18n("Left Arrow"); break;
                    case Qt.Key_Right: text = i18n("Right Arrow"); break;
                    case Qt.Key_Tab: text = i18n("Tab"); break;
                    case Qt.Key_Backtab: text = i18n("Backtab"); break;
                    case Qt.Key_PageUp: text = i18n("Page Up"); break;
                    case Qt.Key_PageDown: text = i18n("Page Down"); break;
                    case Qt.Key_Home: text = i18n("Home"); break;
                    case Qt.Key_End: text = i18n("End"); break;
                    case Qt.Key_Backspace: text = i18n("Backspace"); break;
                    case Qt.Key_Delete: text = i18n("Delete"); break;
                    case Qt.Key_Insert: text = i18n("Insert"); break;
                    case Qt.Key_Enter: text = i18n("Enter"); break;
                    case Qt.Key_Return: text = i18n("Enter"); break;
                    case Qt.Key_Control: text = Qt.platform.os==="osx" || Qt.platform.os==="ios" || Qt.platform.os==="tvos" || Qt.platform.os==="ipados" ? i18n("Command") : i18n("Control"); break;
                    case Qt.Key_Super_L: text = Qt.platform.os==="osx" || Qt.platform.os==="ios" || Qt.platform.os==="tvos" || Qt.platform.os==="ipados" ? i18n("Left Control") : (Qt.platform.os==="windows" || Qt.platform.os==="winrt" ? i18n("Left Windows") : (Qt.platform.os==="linux" || Qt.platform.os==="unix" ? i18n("Left Super") : i18n("Left Meta"))); break;
                    case Qt.Key_Super_R: text = Qt.platform.os==="osx" || Qt.platform.os==="ios" || Qt.platform.os==="tvos" || Qt.platform.os==="ipados" ? i18n("Right Control") : (Qt.platform.os==="windows" || Qt.platform.os==="winrt" ? i18n("Right Windows") : (Qt.platform.os==="linux" || Qt.platform.os==="unix" ? i18n("Right Super") : i18n("Right Meta"))); break;
                    case Qt.Key_Meta: text = Qt.platform.os==="osx" || Qt.platform.os==="ios" || Qt.platform.os==="tvos" || Qt.platform.os==="ipados" ? i18n("Control") : (Qt.platform.os==="windows" || Qt.platform.os==="winrt" ? i18n("Windows") : (Qt.platform.os==="linux" || Qt.platform.os==="unix" ? i18n("Super") : i18n("Meta"))); break;
                    case Qt.Key_Alt: text = i18n("Alt"); break;
                    case Qt.Key_AltGr: text = i18n("AltGr"); break;
                    case Qt.Key_Shift: text = i18n("Shift"); break;
                    case Qt.Key_NumLock: text = i18n("Number Lock"); break;
                    case Qt.Key_CapsLock: text = i18n("Caps Lock"); break;
                    case Qt.Key_ScrollLock: text = i18n("Scroll Lock"); break;
                    case Qt.Key_F1: text = i18n("F1"); break;
                    case Qt.Key_F2: text = i18n("F2"); break;
                    case Qt.Key_F3: text = i18n("F3"); break;
                    case Qt.Key_F4: text = i18n("F4"); break;
                    case Qt.Key_F5: text = i18n("F5"); break;
                    case Qt.Key_F6: text = i18n("F6"); break;
                    case Qt.Key_F7: text = i18n("F7"); break;
                    case Qt.Key_F8: text = i18n("F8"); break;
                    case Qt.Key_F9: text = i18n("F9"); break;
                    case Qt.Key_F10: text = i18n("F10"); break;
                    case Qt.Key_F11: text = i18n("F11"); break;
                    case Qt.Key_F12: text = i18n("F12"); break;
                    case Qt.Key_F13: text = i18n("F13"); break;
                    case Qt.Key_F14: text = i18n("F14"); break;
                    case Qt.Key_F15: text = i18n("F15"); break;
                    case Qt.Key_F16: text = i18n("F16"); break;
                    case Qt.Key_F17: text = i18n("F17"); break;
                    case Qt.Key_F18: text = i18n("F18"); break;
                    case Qt.Key_F19: text = i18n("F19"); break;
                    case Qt.Key_F20: text = i18n("F20"); break;
                    case Qt.Key_F21: text = i18n("F21"); break;
                    case Qt.Key_F22: text = i18n("F22"); break;
                    case Qt.Key_F23: text = i18n("F23"); break;
                    case Qt.Key_F24: text = i18n("F24"); break;
                    case Qt.Key_F25: text = i18n("F25"); break;
                    case Qt.Key_F26: text = i18n("F26"); break;
                    case Qt.Key_F27: text = i18n("F27"); break;
                    case Qt.Key_F28: text = i18n("F28"); break;
                    case Qt.Key_F29: text = i18n("F29"); break;
                    case Qt.Key_F30: text = i18n("F30"); break;
                    case Qt.Key_F31: text = i18n("F31"); break;
                    case Qt.Key_F32: text = i18n("F32"); break;
                    case Qt.Key_F33: text = i18n("F33"); break;
                    case Qt.Key_F34: text = i18n("F34"); break;
                    case Qt.Key_F35: text = i18n("F35"); break;
                    case Qt.Key_HomePage: text = i18n("Home Page"); break;
                    case Qt.Key_LaunchMail: text = i18n("E-mail"); break;
                    case Qt.Key_Refresh: text = i18n("Refresh"); break;
                    case Qt.Key_Search: text = i18n("Search"); break;
                    case Qt.Key_Zoom: text = i18n("Zoom"); break;
                    case Qt.Key_Print: text = i18n("Print"); break;
                    default:
                        text = event.text==="" ? event.key : event.text;
                }
                return text
            }
            
            Label {
                text: i18n("Toggle Prompter State")
            }
            Button {
                text: i18n("F9")
                checkable: true
                flat: true
                Layout.fillWidth: true
                onClicked: {
                    if (checked) {
                        parent.toggleButonsOff()
                        checked = true
                    }
                }
                Keys.onPressed: {
                    if (checked) {
                        if (parent.isValidInput(event.key)) {
                            prompter.keys.toggle = event.key
                            text = parent.getKeyText(event)
                        }
                        event.accepted = true
                    }
                    parent.toggleButonsOff()
                }
            }
            Label {
                text: i18n("Decrease Velocity")
            }
            Button {
                text: i18n("Up Arrow")
                checkable: true
                flat: true
                Layout.fillWidth: true
                onClicked: {
                    if (checked) {
                        parent.toggleButonsOff()
                        checked = true
                    }
                }
                Keys.onPressed: {
                    if (checked) {
                        if (parent.isValidInput(event.key)) {
                            prompter.keys.decreaseVelocity = event.key
                            text = parent.getKeyText(event)
                        }
                        event.accepted = true
                    }
                    parent.toggleButonsOff()
                }
            }
            Label {
                text: i18n("Increase Velocity")
            }
            Button {
                text: i18n("Down Arrow")
                checkable: true
                flat: true
                Layout.fillWidth: true
                onClicked: {
                    if (checked) {
                        parent.toggleButonsOff()
                        checked = true
                    }
                }
                Keys.onPressed: {
                    if (checked) {
                        if (parent.isValidInput(event.key)) {
                            prompter.keys.increaseVelocity = event.key
                            text = parent.getKeyText(event)
                        }
                        event.accepted = true
                    }
                    parent.toggleButonsOff()
                }
            }
            Label {
                text: i18n("Play/Pause")
            }
            Button {
                text: i18n("Spacebar")
                checkable: true
                flat: true
                Layout.fillWidth: true
                onClicked: {
                    if (checked) {
                        parent.toggleButonsOff()
                        checked = true
                    }
                }
                Keys.onPressed: {
                    if (checked) {
                        if (parent.isValidInput(event.key)) {
                            prompter.keys.pause = event.key
                            text = parent.getKeyText(event)
                        }
                        event.accepted = true
                    }
                    parent.toggleButonsOff()
                }
            }
            Label {
                text: i18n("Scroll Backwards")
            }
            Button {
                text: i18n("Page Up")
                checkable: true
                flat: true
                Layout.fillWidth: true
                onClicked: {
                    if (checked) {
                        parent.toggleButonsOff()
                        checked = true
                    }
                }
                Keys.onPressed: {
                    if (checked) {
                        if (parent.isValidInput(event.key)) {
                            prompter.keys.skipBackwards = event.key
                            text = parent.getKeyText(event)
                        }
                        event.accepted = true
                    }
                    parent.toggleButonsOff()
                }
            }
            Label {
                text: i18n("Scroll Forward")
            }
            Button {
                text: i18n("Page Down")
                checkable: true
                flat: true
                Layout.fillWidth: true
                onClicked: {
                    if (checked) {
                        parent.toggleButonsOff()
                        checked = true
                    }
                }
                Keys.onPressed: {
                    if (checked) {
                        if (parent.isValidInput(event.key)) {
                            prompter.keys.skipForward = event.key
                            text = parent.getKeyText(event)
                        }
                        event.accepted = true
                    }
                    parent.toggleButonsOff()
                }
            }
            /*
            Label {
                text: i18n("Go to Previous Marker")
            }
            Button {
                text: i18n("Home")
                checkable: true
                flat: true
                Layout.fillWidth: true
                onClicked: {
                    if (checked) {
                        parent.toggleButonsOff()
                        checked = true
                    }
                }
                Keys.onPressed: {
                    if (checked) {
                        if (parent.isValidInput(event.key)) {
                            prompter.keys.previousMarker = event.key
                            text = parent.getKeyText(event)
                        }
                        event.accepted = true
                    }
                    parent.toggleButonsOff()
                }
            }
            Label {
                text: i18n("Go to Next Marker")
            }
            Button {
                text: i18n("End")
                checkable: true
                flat: true
                Layout.fillWidth: true
                onClicked: {
                    if (checked) {
                        parent.toggleButonsOff()
                        checked = true
                    }
                }
                Keys.onPressed: {
                    if (checked) {
                        if (parent.isValidInput(event.key)) {
                            prompter.keys.nextMarker = event.key
                            text = parent.getKeyText(event)
                        }
                        event.accepted = true
                    }
                    parent.toggleButonsOff()
                }
            }
            */
        }
    }
    Kirigami.OverlaySheet {
        id: telemetry_overlay
        onSheetOpenChanged: prompterPage.actions.main.checked = sheetOpen
        
        background: Rectangle {
            color: appTheme.__backgroundColor
            anchors.fill: parent
        }
        header: Kirigami.Heading {
            text: i18n("Telemetry Settings")
            level: 1
        }
        
        GridLayout {
            id: telemetry_settings
            width: parent.implicitWidth
            columns: 2
            Label {
                text: i18n("Telemetry")
            }
            Button {
                text: root.__telemetry ? i18n("Enabled") : i18n("Disabled")
                checkable: true
                checked: root.__telemetry
                flat: true
                Layout.fillWidth: true
                onClicked: root.__telemetry = !root.__telemetry
            }
            Label {
                text: ""
            }
            TextArea {
                implicitWidth: parent.width-80
                //height: 300
                background: Item{}
                readOnly: true
                wrapMode: TextEdit.Wrap
                text: i18n("You can help improve QPrompt by contributing information on how you use it. Contributing this information is optional and entirely anonymous. We never collect your personal data, files you use, contents you work with, or information that could identify you.")
            }
            Button {
                text: checked ? i18n("On") : i18n("Off")
                enabled: root.__telemetry
                checkable: true
                checked: root.__telemetry
                flat: true
                Layout.fillWidth: true
                //onClicked: root.__telemetry = !root.__telemetry
            }
                //text: i18n("Information collected once per session")
            TextArea {
                //id: platformTelemetryToggle
                implicitWidth: parent.width-80
                background: Item{}
                readOnly: true
                wrapMode: TextEdit.Wrap
                text: i18n("Basic program and system information")+"\n"+
                " + " + i18n("Application version")+"\n"+
                " + " + i18n("Platform information")+"\n"+
                " + " + i18n("Qt version information")+"\n"+
                " + " + i18n("Locale information (timezone and keyboard layout)")
            }
            Button {
                text: checked ? i18n("On") : i18n("Off")
                enabled: root.__telemetry
                checkable: true
                checked: root.__telemetry
                flat: true
                Layout.fillWidth: true
                //onClicked: root.__telemetry = !root.__telemetry
            }
            TextArea {
                //id: runsTelemetryToggle
                implicitWidth: parent.width-80
                background: Item{}
                readOnly: true
                wrapMode: TextEdit.Wrap
                text: i18n("Program run statistics: Help us study user retention")+"\n"+
                " + " + i18n("Randomly generated install ID")+"\n"+
                " + " + i18n("Launch times")+"\n"+
                " + " + i18n("Usage time")+"\n"+
                " + " + i18n("Locale information (timezone and keyboard layout)")
            }
                //text: i18n("Information collected once per prompt")
            Button {
                text: checked ? i18n("On") : i18n("Off")
                enabled: root.__telemetry
                checkable: true
                checked: root.__telemetry
                flat: true
                Layout.fillWidth: true
                //onClicked: root.__telemetry = !root.__telemetry
            }
            TextArea {
                //id: featureTelemetryToggle
                implicitWidth: parent.width-80
                background: Item{}
                readOnly: true
                wrapMode: TextEdit.Wrap
                text: i18n("Feature use frequency: Help us know what features are most important")+"\n"+
                " + " + i18n("Flip settings")+"\n"+
                " + " + i18n("Reading region settings")+"\n"+
                " + " + i18n("Pointer settings")+"\n"+
                " + " + i18n("Countdown settings")+"\n"+
                " + " + i18n("Keyboard shortcut settings")+"\n"+
                " + " + i18n("Input control settings")+"\n"+
                " + " + i18n("Base speed and acceleration curvature settings")+"\n"+
                " + " + i18n("Background color and opacity settings")+"\n"+
                " + " + i18n("Presence of a background image")
            }
            Button {
                //id: operationsTelemetryToggle
                text: checked ? i18n("On") : i18n("Off")
                enabled: root.__telemetry
                checkable: true
                checked: root.__telemetry
                flat: true
                Layout.fillWidth: true
                //onClicked: root.__telemetry = !root.__telemetry
            }
            TextArea {
                implicitWidth: parent.width-80
                background: Item{}
                readOnly: true
                wrapMode: TextEdit.Wrap
                text: i18n("Help us understand how users operate QPrompt")+"*\n"+
                " + " + i18n("Random session ID")+"\n"+
                " + " + i18n("Session number")+"\n"+
                " + " + i18n("Session prompt number")+"\n"+
                " + " + i18n("Window dimensions")+"\n"+
                " + " + i18n("Prompt area dimensions")+"\n"+
                " + " + i18n("Dimensions of lines of text being prompted")+"\n"+
                " + " + i18n("Font settings per block of lines of text being prompted")+"\n"+
                " + " + i18n("Languages likely present in the text being prompted")+"\n"+
                " + " + i18n("Prompt starting line number and position")+"\n"+
                " + " + i18n("Manual scroll start and end timestamps")+"\n"+
                " + " + i18n("Scroll starting line number and position")+"\n"+
                " + " + i18n("Scroll end line number and position")+"\n"+
                " + " + i18n("Scroll duration")+"\n"+
                " + " + i18n("Prompt duration")+"\n"+
                " + " + i18n("Velocity changes with timestamp")+"\n"+
                " + " + i18n("Source of changes to velocity")+"\n"+
                " + " + i18n("Source of manual changes to scroll position")+"\n\n"+
                "* " + i18n("This information is very important to me, Javier, the project author, and it would help make QPrompt's development sustainable. I've gone the extra mile not to collect any of the actual text or visual contents that you work with, so I ask you: please leave telemetry enabled.")
            }
        }
    }
}
