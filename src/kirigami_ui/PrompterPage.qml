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
import org.kde.kirigami 2.15 as Kirigami
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.platform 1.1

import com.cuperino.qprompt.markers 1.0

Kirigami.Page {
    id: prompterPage
    
    // Unused signal. Leaving for reference.
    //signal test( bool data )

    property alias fontDialog: fontDialog
    property alias colorDialog: colorDialog
    property alias highlightDialog: highlightDialog
    property alias viewport: viewport
    property alias prompter: viewport.prompter
    property alias editor: viewport.editor
    property alias overlay: viewport.overlay
    property alias document: viewport.document
    property alias prompterBackground: viewport.prompterBackground
    property alias find: viewport.find
    property alias key_configuration_overlay: key_configuration_overlay
    property alias displaySettings: displaySettings
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
        // This may have not been a right design choice. It needs user beta testers' validation. Disabling for initial release.
        Kirigami.Action {
            id: wysiwygButton
            visible: false
            text: i18n("WYSIWYG")
            enabled: parseInt(prompter.state)===Prompter.States.Editing
            checkable: true
            checked: viewport.prompter.__wysiwyg
            tooltip: viewport.prompter.__wysiwyg ? i18n("\"What you see is what you get\" mode is On") : i18n("\"What you see is what you get\" mode is Off")
            onTriggered: {
                viewport.prompter.__wysiwyg = !viewport.prompter.__wysiwyg
                editor.focus = true
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
                onTriggered: viewport.overlay.positionState = ReadRegionOverlay.PositionStates.Top
                enabled: parseInt(viewport.overlay.positionState)!==ReadRegionOverlay.PositionStates.Top
                tooltip: i18n("Move reading region to the top, convenient for use with webcams")
            }
            Kirigami.Action {
                id: readRegionMiddleButton
                iconName: "remove"
                text: i18n("Middle")
                onTriggered: viewport.overlay.positionState = ReadRegionOverlay.PositionStates.Middle
                enabled: parseInt(viewport.overlay.positionState)!==ReadRegionOverlay.PositionStates.Middle
                tooltip: i18n("Move reading region to the vertical center")
            }
            Kirigami.Action {
                id: readRegionBottomButton
                iconName: "go-down"
                text: i18n("Bottom")
                onTriggered: viewport.overlay.positionState = ReadRegionOverlay.PositionStates.Bottom
                enabled: parseInt(viewport.overlay.positionState)!==ReadRegionOverlay.PositionStates.Bottom
                tooltip: i18n("Move reading region to the bottom")
            }
            Kirigami.Action {
                id: readRegionFreeButton
                iconName: "gtk-edit"
                text: i18n("Free")
                onTriggered: viewport.overlay.positionState = ReadRegionOverlay.PositionStates.Free
                enabled: parseInt(viewport.overlay.positionState)!==ReadRegionOverlay.PositionStates.Free
                tooltip: i18n("Move reading region freely by dragging and dropping")
            }
            Kirigami.Action {
                id: readRegionCustomButton
                iconName: "gtk-apply"
                text: i18n("Custom")
                onTriggered: viewport.overlay.positionState = ReadRegionOverlay.PositionStates.Fixed
                enabled: parseInt(viewport.overlay.positionState)!==ReadRegionOverlay.PositionStates.Fixed
                tooltip: i18n("Fix reading region to the position set using free placement mode")
            }
            Kirigami.Action {
                id: hideDecorationsButton
                text: hideDecorations===0 ? i18n("Frame Settings") : (hideDecorations===1 ? i18n("Auto hide frame") : i18n("Always hide frame"))
                visible: !fullScreenPlatform
                tooltip: i18n("Auto hide window decorations when not editing and read region is set to top")
                Kirigami.Action {
                    text: i18n("Normal Frame")
                    tooltip: i18n("Shows windows frame when in windowed mode")
                    checkable: true
                    checked: hideDecorations==0
                    onTriggered: {
                        hideDecorations = 0
                        parent.text = text
                    }
                }
                Kirigami.Action {
                    text: i18n("Auto Hide")
                    tooltip: i18n("Auto hide window decorations when not editing and read region is set to top")
                    checkable: true
                    checked: hideDecorations==1
                    onTriggered: {
                        hideDecorations = 1
                        parent.text = text
                    }
                }
                Kirigami.Action {
                    text: i18n("Always Hidden")
                    tooltip: i18n("Always hide window decorations")
                    checkable: true
                    checked: hideDecorations==2
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
                onTriggered: overlay.styleState = ReadRegionOverlay.PointerStates.LeftPointer
                tooltip: i18n("Left pointer indicates reading region")
                enabled: parseInt(overlay.styleState)!==ReadRegionOverlay.PointerStates.LeftPointer
            }
            Kirigami.Action {
                id: readRegionRightPointerButton
                text: i18n("Right Pointer")
                onTriggered: overlay.styleState = ReadRegionOverlay.PointerStates.RightPointer
                tooltip: i18n("Right pointer indicates reading region")
                enabled: parseInt(overlay.styleState)!==ReadRegionOverlay.PointerStates.RightPointer
            }
            Kirigami.Action {
                id: readRegionPointersButton
                text: i18n("Both Pointers")
                onTriggered: overlay.styleState = ReadRegionOverlay.PointerStates.Pointers
                tooltip: i18n("Left and right pointers indicate reading region")
                enabled: parseInt(overlay.styleState)!==ReadRegionOverlay.PointerStates.Pointers
            }
            Kirigami.Action {
                id: readRegionBarsButton
                text: i18n("Bars")
                onTriggered: overlay.styleState = ReadRegionOverlay.PointerStates.Bars
                tooltip: i18n("Translucent bars indicate reading region")
                enabled: parseInt(overlay.styleState)!==ReadRegionOverlay.PointerStates.Bars
            }
            Kirigami.Action {
                id: readRegionBarsLeftButton
                text: i18n("Bars and Left Pointer")
                onTriggered: overlay.styleState = ReadRegionOverlay.PointerStates.BarsLeft
                tooltip: i18n("Translucent bars and left pointer indicate reading region")
                enabled: parseInt(overlay.styleState)!==ReadRegionOverlay.PointerStates.BarsLeft
            }
            Kirigami.Action {
                id: readRegionBarsRightButton
                text: i18n("Bars and Right Pointer")
                onTriggered: overlay.styleState = ReadRegionOverlay.PointerStates.BarsRight
                tooltip: i18n("Translucent bars and right pointer indicate reading region")
                enabled: parseInt(overlay.styleState)!==ReadRegionOverlay.PointerStates.BarsRight
            }
            Kirigami.Action {
                id: readRegionAllButton
                text: i18n("All")
                onTriggered: overlay.styleState = ReadRegionOverlay.PointerStates.All
                tooltip: i18n("Use all reading region indicators")
                enabled: parseInt(overlay.styleState)!==ReadRegionOverlay.PointerStates.All
            }
            Kirigami.Action {
                id: readRegionNoneButton
                text: i18n("None")
                onTriggered: overlay.styleState = ReadRegionOverlay.PointerStates.None
                tooltip: i18n("Disable reading region indicators")
                enabled: parseInt(overlay.styleState)!==ReadRegionOverlay.PointerStates.None
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
            Kirigami.Action {
                id: clearTimerColorButton
                text: i18n("Clear Timer Color")
                enabled: !Qt.colorEqual(viewport.timer.textColor, '#AAA')
                onTriggered: {
                    viewport.timer.clearColor()
                }
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
            id: displaySettings
            visible: !Kirigami.Settings.isMobile
            text: i18n("Screens")

            // This part of the code is nothing but a hack. But hey! It works!
            Kirigami.Action {
                id: bridge
                displayComponent: ListView {
                    height: contentHeight>580 ? 580 : contentHeight
                    flickableDirection: Flickable.VerticalFlick
                    model: Qt.application.screens
                    delegate: Kirigami.BasicListItem {
                        id: displayItem
                        enabled: parseInt(prompter.state)===Prompter.States.Editing
                        label: model.name
                        // enabled: screen.name!==label
                        // readonly property int projectionSetting: enabled ? projectionSetting : 0
                        property int flipSetting: projectionManager.getDisplayFlip(displayItem.label)
                        activeTextColor: "#FFFFFF"
                        activeBackgroundColor: "#797979"
                        //contentItem: Label {
                        //    anchors.verticalCenter: parent.verticalCenter
                        //    text: model.name
                        //}
                        onClicked: displayMenu.open()
                        Menu {
                            id: displayMenu
                            MenuItem {
                                text: i18n("Off")
                                enabled: flipSetting!==0
                                onTriggered: {
                                    flipSetting = 0
                                    onTriggered: projectionManager.putDisplayFlip(displayItem.label, 0)
                                }
                            }
                            MenuItem {
                                text: i18n("No Flip")
                                enabled: flipSetting!==1
                                onTriggered: {
                                    flipSetting = 1
                                    onTriggered: projectionManager.putDisplayFlip(displayItem.label, 1)
                                }
                            }
                            MenuItem {
                                text: i18n("Horizontal Flip")
                                enabled: flipSetting!==2
                                onTriggered: {
                                    flipSetting = 2
                                    onTriggered: projectionManager.putDisplayFlip(displayItem.label, 2)
                                }
                            }
                            MenuItem {
                                text: i18n("Vertical Flip")
                                enabled: flipSetting!==3
                                onTriggered: {
                                    flipSetting = 3
                                    onTriggered: projectionManager.putDisplayFlip(displayItem.label, 3)
                                }
                            }
                            MenuItem {
                                text: i18n("180° rotation")
                                enabled: flipSetting!==4
                                onTriggered: {
                                    flipSetting = 4
                                    onTriggered: projectionManager.putDisplayFlip(displayItem.label, 4)
                                }
                            }
                        }
                    }
                }
            }
            Kirigami.Action {
                text: i18n("Scale Projections")
                checkable: true
                checked: projectionManager.reScale
                onTriggered: {
                    projectionManager.reScale = !projectionManager.reScale
                }
            }
            Kirigami.Action {
                text: i18n("Preview Projections")
                tooltip: i18n("Project prompter duplicates onto extended displays")
                onTriggered: {
                    projectionManager.preview()
                }
            }
        },
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
            id: fullscreenButton
            visible: !fullScreenPlatform
            text: root.__fullScreen ? i18n("Leave Fullscreen") : i18n("Fullscreen")
            onTriggered: root.__fullScreen = !root.__fullScreen
        }
        ]
    }
    PrompterView {
        id: viewport
        // Workaround to make regular Page let its contents be covered by action buttons.
        anchors.bottomMargin: Kirigami.Settings.isMobile ? -68 : 0
        prompter.performFileOperations: true
        property alias toolbar: editorToolbar
    }

    progress: parseInt(viewport.prompter.state)===Prompter.States.Prompting ? viewport.prompter.progress : undefined

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
    
    ColorDialog {
        id: highlightDialog
        currentColor: Kirigami.Theme.backgroundColor
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

    MarkersDrawer {
        id: sideDrawer
    }

    InputsOverlay {
        id: key_configuration_overlay
    }
}
