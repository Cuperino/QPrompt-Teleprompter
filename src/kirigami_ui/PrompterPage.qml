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
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.2
import Qt.labs.platform 1.1 as Labs

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
                iconName: "list-remove"
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
                iconName: "handle-sort"
                text: i18n("Free")
                onTriggered: viewport.overlay.positionState = ReadRegionOverlay.PositionStates.Free
                enabled: parseInt(viewport.overlay.positionState)!==ReadRegionOverlay.PositionStates.Free
                tooltip: i18n("Move reading region freely by dragging and dropping")
            }
            Kirigami.Action {
                id: readRegionCustomButton
                iconName: "dialog-ok-apply"
                text: i18n("Custom")
                onTriggered: viewport.overlay.positionState = ReadRegionOverlay.PositionStates.Fixed
                enabled: parseInt(viewport.overlay.positionState)!==ReadRegionOverlay.PositionStates.Fixed
                tooltip: i18n("Fix reading region to the position set using free placement mode")
            }
            Kirigami.Action {
                id: hideDecorationsButton
                text: i18n("Window Frame")
                enabled: !fullScreenPlatform
                visible: enabled
                tooltip: i18n("Auto hide window decorations when not editing and read region is set to top")
                iconName: hideDecorations===0 ? "window" : (hideDecorations===1 ? "draw-rectangle" : "gnumeric-object-rectangle")
                Kirigami.Action {
                    text: i18n("Normal frame")
                    tooltip: i18n("Shows windows frame when in windowed mode")
                    iconName: "window"
//                     checkable: true
                    enabled: hideDecorations!==0
                    onTriggered: {
                        hideDecorations = 0
                        parent.text = text
                    }
                }
                Kirigami.Action {
                    text: i18n("Auto hide")
                    tooltip: i18n("Auto hide window decorations when not editing and read region is set to top")
                    iconName: "draw-rectangle"
//                     checkable: true
                    enabled: hideDecorations!==1
                    onTriggered: {
                        hideDecorations = 1
                        parent.text = text
                    }
                }
                Kirigami.Action {
                    text: i18n("Always hidden")
                    tooltip: i18n("Always hide window decorations")
                    iconName: "gnumeric-object-rectangle"
//                     checkable: true
                    enabled: hideDecorations!==2
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
                text: i18n("Left pointer")
                iconName: "go-next"
                onTriggered: overlay.styleState = ReadRegionOverlay.PointerStates.LeftPointer
                tooltip: i18n("Left pointer indicates reading region")
                enabled: parseInt(overlay.styleState)!==ReadRegionOverlay.PointerStates.LeftPointer
            }
            Kirigami.Action {
                id: readRegionRightPointerButton
                text: i18n("Right pointer")
                iconName: "go-previous"
                onTriggered: overlay.styleState = ReadRegionOverlay.PointerStates.RightPointer
                tooltip: i18n("Right pointer indicates reading region")
                enabled: parseInt(overlay.styleState)!==ReadRegionOverlay.PointerStates.RightPointer
            }
            Kirigami.Action {
                id: readRegionPointersButton
                text: i18n("Both pointers")
                iconName: "transform-move-horizontal"
                onTriggered: overlay.styleState = ReadRegionOverlay.PointerStates.Pointers
                tooltip: i18n("Left and right pointers indicate reading region")
                enabled: parseInt(overlay.styleState)!==ReadRegionOverlay.PointerStates.Pointers
            }
            Kirigami.Action {
                id: readRegionBarsButton
                text: i18n("Bar")
                iconName: "list-remove"
                onTriggered: overlay.styleState = ReadRegionOverlay.PointerStates.Bars
                tooltip: i18n("Translucent bars indicate reading region")
                enabled: parseInt(overlay.styleState)!==ReadRegionOverlay.PointerStates.Bars
            }
            Kirigami.Action {
                id: readRegionBarsLeftButton
                text: i18n("Bar && left")
                iconName: "sidebar-collapse-right"
                onTriggered: overlay.styleState = ReadRegionOverlay.PointerStates.BarsLeft
                tooltip: i18n("Translucent bars and left pointer indicate reading region")
                enabled: parseInt(overlay.styleState)!==ReadRegionOverlay.PointerStates.BarsLeft
            }
            Kirigami.Action {
                id: readRegionBarsRightButton
                text: i18n("Bar && right")
                iconName: "sidebar-collapse-left"
                onTriggered: overlay.styleState = ReadRegionOverlay.PointerStates.BarsRight
                tooltip: i18n("Translucent bars and right pointer indicate reading region")
                enabled: parseInt(overlay.styleState)!==ReadRegionOverlay.PointerStates.BarsRight
            }
            Kirigami.Action {
                id: readRegionAllButton
                text: i18n("All")
                iconName: "auto-transition"
                onTriggered: overlay.styleState = ReadRegionOverlay.PointerStates.All
                tooltip: i18n("Use all reading region indicators")
                enabled: parseInt(overlay.styleState)!==ReadRegionOverlay.PointerStates.All
            }
            Kirigami.Action {
                id: readRegionNoneButton
                text: i18n("None")
                iconName: "format-justify-center"
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
                iconName: "keyframe"
                text: i18n("Stopwatch")
                onTriggered: {
                    viewport.timer.stopwatch = !viewport.timer.stopwatch
                }
            }
            Kirigami.Action {
                id: enableETAButton
                checkable: true
                checked: viewport.timer.eta
                iconName: "player-time"
                text: i18n("ETA")
                onTriggered: {
                    viewport.timer.eta = !viewport.timer.eta
                }
            }
            Kirigami.Action {
                id: timerColorButton
                text: i18n("Timer color")
                iconName: "format-text-color"
                onTriggered: {
                    viewport.timer.setColor()
                }
            }
            Kirigami.Action {
                id: clearTimerColorButton
                text: i18n("Clear color")
                iconName: "tool_color_eraser"
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
                text: i18n("Auto frame")
                iconName: "transform-move-vertical"
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
                iconName: "chronometer-pause"
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
                checked: viewport.countdown.autoStart && enableCountdownButton.checked
                text: i18n("Auto start")
                iconName: "chronometer"
                tooltip: i18n("Start countdown automatically")
                onTriggered: viewport.countdown.autoStart = !viewport.countdown.autoStart
            }
            Kirigami.Action {
                id: setCountdownButton
                enabled: enableCountdownButton.enabled && viewport.countdown.enabled
                text: i18n("Set duration")
                iconName: "keyframe-add"
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
                text: i18n("No flip")
                iconName: "window"
                readonly property string shortName: i18n("No Flip")
                onTriggered: {
                    parent.updateButton(this)
                    viewport.prompter.__flipX = false
                    viewport.prompter.__flipY = false
                }
                enabled: viewport.prompter.__flipX || viewport.prompter.__flipY
            }
            Kirigami.Action {
                text: i18n("Horizontal flip")
                iconName: "object-flip-horizontal"
                readonly property string shortName: i18n("H Flip")
                onTriggered: {
                    parent.updateButton(this)
                    viewport.prompter.__flipX = true
                    viewport.prompter.__flipY = false
                }
                enabled: (!viewport.prompter.__flipX) || viewport.prompter.__flipY
            }
            Kirigami.Action {
                text: i18n("Vertical flip")
                iconName: "object-flip-vertical"
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
                iconName: Qt.LeftToRight ? "object-rotate-left" : "object-rotate-right"
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
                text: i18n("Set image")
                iconName: "insert-image"
                onTriggered: prompterBackground.loadBackgroundImage()
            }
            Kirigami.Action {
                id: changeBackgroundColorButton
                text: i18n("Set color")
                iconName: "format-fill-color"
                onTriggered: prompterBackground.backgroundColorDialog.open()
            }
            Kirigami.Action {
                id: clearBackgroundButton
                text: i18n("Clear")
                enabled: prompterBackground.hasBackground
                iconName: "tool_color_eraser"
                onTriggered: prompterBackground.clearBackground()
            }
        },
        Kirigami.Action {
            id: displaySettings
            visible: !Kirigami.Settings.isMobile
            text: i18n("Screens")

            Kirigami.Action {
                displayComponent: ListView {
                    height: contentHeight>580 ? 580 : contentHeight
                    model: Qt.application.screens
                    delegate: Kirigami.SwipeListItem {
                        id: display
                        property string name: model.name
                        property int flipSetting: projectionManager.getDisplayFlip(display.name)
                        enabled: parseInt(prompter.state)===Prompter.States.Editing
                        activeTextColor: "#FFFFFF"
                        activeBackgroundColor: "#797979"
                        actions: [
                            Kirigami.Action {
                                iconName: switch (flipSetting) {
                                    case 0 : return "window";
                                    case 1 : return "window-duplicate";
                                    case 2 : return "object-flip-horizontal";
                                    case 3 : return "object-flip-vertical";
                                    case 4 : return (Qt.LeftToRight ? "object-rotate-left" : "object-rotate-right");
                                }
                                onTriggered: toggleDisplayFlip()
                            }
                        ]
                        onClicked: toggleDisplayFlip()
                        function toggleDisplayFlip() {
                            flipSetting = (flipSetting+1)%5
                            projectionManager.putDisplayFlip(display.name, flipSetting)
                        }
                        Label {
                            id: label
                            text: switch (flipSetting) {
                                case 0 : return display.name + " : " + i18n("Off");
                                case 1 : return display.name + " : " + i18n("No flip");
                                case 2 : return display.name + " : " + i18n("H flip");
                                case 3 : return display.name + " : " + i18n("V flip");
                                case 4 : return display.name + " : " + i18n("HV flip");
                            }
                        }
                    }
                }
            }
            Kirigami.Action {
                text: i18n("Scale projections")
                checkable: true
                checked: projectionManager.reScale
                onTriggered: {
                    projectionManager.reScale = !projectionManager.reScale
                }
            }
            Kirigami.Action {
                text: i18n("Preview projections")
                tooltip: i18n("Project prompter duplicates onto extended displays")
                enabled: parseInt(prompter.state)===Prompter.States.Editing
                onTriggered: {
                    projectionManager.preview()
                }
            }
        },
        //Kirigami.Action {
        //    id: debug
        //    text: i18n("Debug")
        //    tooltip: i18n("Debug Action")
        //    onTriggered: {
        //        console.log("Debug Action")
        //        prompterPage.test( true )
        //    }
        //},
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

    // progress: parseInt(viewport.prompter.state)===Prompter.States.Prompting ? viewport.prompter.progress : undefined

    FontDialog {
        id: fontDialog
        monospacedFonts: true
        nonScalableFonts: true
        proportionalFonts: true
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
