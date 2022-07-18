/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2020-2022 Javier O. Cordero Pérez
 **
 ** This file is part of QPrompt.
 **
 ** This program is free software: you can redistribute it and/or modify
 ** it under the terms of the GNU General Public License as published by
 ** the Free Software Foundation, version 3 of the License.
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

    property alias fontDialog: fontDialog
    property alias colorDialog: colorDialog
    property alias highlightDialog: highlightDialog
    property alias viewport: viewport
    property alias prompter: viewport.prompter
    property alias editor: viewport.editor
    property alias countdown: viewport.countdown
    property alias overlay: viewport.overlay
    property alias document: viewport.document
    property alias openDialog: viewport.openDialog
    property alias prompterBackground: viewport.prompterBackground
    property alias find: viewport.find
    property alias key_configuration_overlay: key_configuration_overlay
    property alias displaySettings: displaySettings
    property alias sideDrawer: sideDrawer
    property int hideDecorations: 1

    // Unused signal. Leaving for reference.
    //signal test( bool data )

    title: "QPrompt"
    padding: 0

    onBackRequested: close()

    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.Window
    Kirigami.Theme.backgroundColor: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0)
    // Kirigami.Theme.backgroundColor: themeSwitch.checked ? "#00b9d795" : "#00000000"
    // Kirigami.Theme.textColor: themeSwitch.checked ? "#465c2b" : "#ffffff"
    // Kirigami.Theme.highlightColor: themeSwitch.checked ? "#89e51c" : "#ffffff"

    actions {
        main: Kirigami.Action {
            id: promptingButton
            text: i18n("Start prompter")
            iconName: Qt.application.layoutDirection === Qt.RightToLeft ? "go-next-rtl" : "go-next"
            icon.source: Qt.application.layoutDirection === Qt.RightToLeft ? "icons/go-previous.svg" : "icons/go-next.svg"
            onTriggered: prompter.toggle()
        }
        left: Kirigami.Action {
            id: decreaseVelocityButton
            enabled: Kirigami.Settings.isMobile
            text: pageStack.globalToolBar.actualStyle === Kirigami.ApplicationHeaderStyle.None ? i18n("Decrease velocity") : ""
            iconName: Qt.application.layoutDirection === Qt.RightToLeft ? "go-previous-rtl" : "go-previous"
            icon.source: Qt.application.layoutDirection === Qt.RightToLeft ? "icons/go-next.svg" : "icons/go-previous.svg"
            onTriggered: parseInt(prompter.state) === Prompter.States.Prompting ? viewport.prompter.decreaseVelocity(false) : prompter.goToPreviousMarker()
        }
        right: Kirigami.Action {
            id: increaseVelocityButton
            enabled: Kirigami.Settings.isMobile
            text: pageStack.globalToolBar.actualStyle === Kirigami.ApplicationHeaderStyle.None ? i18n("Increase velocity") : ""
            iconName: Qt.application.layoutDirection === Qt.RightToLeft ? "go-next-rtl" : "go-next"
            icon.source: Qt.application.layoutDirection === Qt.RightToLeft ? "icons/go-previous.svg" : "icons/go-next.svg"
            onTriggered: parseInt(prompter.state) === Prompter.States.Prompting ? viewport.prompter.increaseVelocity(false) : prompter.goToNextMarker()
        }
        contextualActions: [
        // This may have not been a right design choice. It needs user beta testers' validation. Disabling for initial release.
//        Kirigami.Action {
//            id: wysiwygButton
//            //visible: false
//            text: i18nc("English acronym for What You See is What You Get", "WYSIWYG")
//            //enabled: parseInt(prompter.state)===Prompter.States.Editing
//            checkable: true
//            checked: viewport.prompter.__wysiwyg
//            tooltip: viewport.prompter.__wysiwyg ? i18n("\"What you see is what you get\" mode is On") : i18n("\"What you see is what you get\" mode is Off")
//            onTriggered: viewport.prompter.toggleWysiwyg()
//        },
        Kirigami.Action {
            id: readRegionButton
            text: i18nc("Reading region indicates where a talent should be reading from", "Reading region")
            //onTriggered: viewport.overlay.toggle()
            tooltip: i18nc("Reading region indicates where a talent should be reading from", "Change reading region placement")

            Kirigami.Action {
                id: readRegionTopButton
                iconName: "go-up"
                text: i18nc("Align reading region to top of prompter", "Top")
                enabled: parseInt(viewport.overlay.positionState)!==ReadRegionOverlay.PositionStates.Top
                tooltip: i18n("Move reading region to the top, convenient for use with webcams")
                onTriggered: {
                    viewport.overlay.positionState = ReadRegionOverlay.PositionStates.Top
                    contextDrawer.close()
                }
            }
            Kirigami.Action {
                id: readRegionMiddleButton
                iconName: "list-remove"
                text: i18nc("Align reading region to vertical center of prompter", "Middle")
                enabled: parseInt(viewport.overlay.positionState)!==ReadRegionOverlay.PositionStates.Middle
                tooltip: i18n("Move reading region to the vertical center")
                onTriggered: {
                    viewport.overlay.positionState = ReadRegionOverlay.PositionStates.Middle
                    contextDrawer.close()
                }
            }
            Kirigami.Action {
                id: readRegionBottomButton
                iconName: "go-down"
                text: i18nc("Align reading region to bottom of prompter", "Bottom")
                enabled: parseInt(viewport.overlay.positionState)!==ReadRegionOverlay.PositionStates.Bottom
                tooltip: i18n("Move reading region to the bottom")
                onTriggered: {
                    viewport.overlay.positionState = ReadRegionOverlay.PositionStates.Bottom
                    contextDrawer.close()
                }
            }
            Kirigami.Action {
                id: readRegionFreeButton
                iconName: "handle-sort"
                text: i18nc("Refers to free placement. Enables drag and drop positioning of reading region.", "Free")
                enabled: parseInt(viewport.overlay.positionState)!==ReadRegionOverlay.PositionStates.Free
                tooltip: i18n("Move reading region freely by dragging and dropping")
                onTriggered: {
                    viewport.overlay.positionState = ReadRegionOverlay.PositionStates.Free
                    contextDrawer.close()
                }
            }
            Kirigami.Action {
                id: readRegionCustomButton
                iconName: "dialog-ok-apply"
                text: i18nc("Fix positioning of reading region to what was set in \"Free placement\" mode", "Custom")
                enabled: parseInt(viewport.overlay.positionState)!==ReadRegionOverlay.PositionStates.Fixed
                tooltip: i18n("Fix reading region to the position set using free placement mode")
                onTriggered: {
                    viewport.overlay.positionState = ReadRegionOverlay.PositionStates.Fixed
                    contextDrawer.close()
                }
            }
            Kirigami.Action {
                displayComponent: Kirigami.SwipeListItem {
                    activeTextColor: "#FFFFFF"
                    activeBackgroundColor: "#797979"
                    actions: [
                        Kirigami.Action {
                            iconName: (Qt.LeftToRight ? "go-next" : "go-previous");
                            onTriggered: viewport.overlay.toggleLinesInRegion(true)
                        },
                        Kirigami.Action {
                            iconName: (Qt.LeftToRight ? "go-previous" : "go-next");
                            onTriggered: viewport.overlay.toggleLinesInRegion(false)
                        }
                    ]
                    onClicked: viewport.overlay.toggleLinesInRegion(false)
                    Label {
                        id: label
                        text: i18nc("Height of reading region relative to single line height. E.g. Height: 2.5", "Height: %1", viewport.overlay.linesInRegion)
                    }
                }
            }
            // Commenting out because there's no way to hide an empty sub-menu in mobile interface and distinction between Normal and Auto is confusing.
            // Kirigami.Action {
            //     id: hideDecorationsButton
            //     text: ["osx"].indexOf(Qt.platform.os)!==-1 || enabled ? i18n("Window frame") : i18n("Prompter mode")
            //     enabled: !fullScreenPlatform
            //     visible: enabled
            //     tooltip: i18n("Auto hide window decorations when not editing and read region is set to top")
            //     iconName: enabled ? (hideDecorations===0 ? "window" : (hideDecorations===1 ? "draw-rectangle" : "gnumeric-object-rectangle")) : ""
            //     Kirigami.Action {
            //         text: i18n("Normal frame")
            //         tooltip: i18n("Shows windows frame when in windowed mode")
            //         iconName: "window"
            //         enabled: parent.enabled && hideDecorations!==0
            //         visible: parent.enabled
            //         onTriggered: {
            //             hideDecorations = 0
            //             parent.text = text
            //         }
            //     }
            //     Kirigami.Action {
            //         text: i18n("Auto hide")
            //         tooltip: i18n("Auto hide window decorations when not editing and read region is set to top")
            //         iconName: "draw-rectangle"
            //         enabled: parent.enabled && hideDecorations!==1
            //         visible: parent.enabled
            //         onTriggered: {
            //             hideDecorations = 1
            //             parent.text = text
            //         }
            //     }
            //     Kirigami.Action {
            //         text: i18n("Always hidden")
            //         tooltip: i18n("Always hide window decorations")
            //         iconName: "gnumeric-object-rectangle"
            //         enabled: parent.enabled && hideDecorations!==2
            //         visible: parent.enabled
            //         onTriggered: {
            //             hideDecorations = 2
            //             parent.text = text
            //         }
            //     }
            // }
        },
        Kirigami.Action {
            id: readRegionStyleButton

            text: i18nc("Indicators highlight reading region", "Indicators")
            tooltip: i18nc("Indicators highlight reading region", "Change reading region indicators")

            Kirigami.Action {
                id: readRegionLeftPointerButton
                text: i18nc("Shows pointer to the left of the reading region", "Left pointer")
                iconName: "go-next"
                tooltip: i18n("Left pointer indicates reading region")
                enabled: parseInt(overlay.styleState)!==ReadRegionOverlay.PointerStates.LeftPointer
                onTriggered: {
                    overlay.styleState = ReadRegionOverlay.PointerStates.LeftPointer
                    contextDrawer.close()
                }
            }
            Kirigami.Action {
                id: readRegionRightPointerButton
                text: i18nc("Shows pointer to the right of the reading region", "Right pointer")
                iconName: "go-previous"
                tooltip: i18n("Right pointer indicates reading region")
                enabled: parseInt(overlay.styleState)!==ReadRegionOverlay.PointerStates.RightPointer
                onTriggered: {
                    overlay.styleState = ReadRegionOverlay.PointerStates.RightPointer
                    contextDrawer.close()
                }
            }
            Kirigami.Action {
                id: readRegionPointersButton
                text: i18nc("Shows pointers to the left and right of the reading region", "Both pointers")
                iconName: "transform-move-horizontal"
                tooltip: i18n("Left and right pointers indicate reading region")
                enabled: parseInt(overlay.styleState)!==ReadRegionOverlay.PointerStates.Pointers
                onTriggered: {
                    overlay.styleState = ReadRegionOverlay.PointerStates.Pointers
                    contextDrawer.close()
                }
            }
            Kirigami.Action {
                id: readRegionBarsButton
                text: i18nc("Translucent bars indicate reading region", "Bar")
                iconName: "list-remove"
                tooltip: i18n("Translucent bars indicate reading region")
                enabled: parseInt(overlay.styleState)!==ReadRegionOverlay.PointerStates.Bars
                onTriggered: {
                    overlay.styleState = ReadRegionOverlay.PointerStates.Bars
                    contextDrawer.close()
                }
            }
            Kirigami.Action {
                id: readRegionBarsLeftButton
                text: i18nc("Translucent bars and left pointer indicate reading region", "Bar && left")
                iconName: "sidebar-collapse-right"
                tooltip: i18n("Translucent bars and left pointer indicate reading region")
                enabled: parseInt(overlay.styleState)!==ReadRegionOverlay.PointerStates.BarsLeft
                onTriggered: {
                    overlay.styleState = ReadRegionOverlay.PointerStates.BarsLeft
                    contextDrawer.close()
                }
            }
            Kirigami.Action {
                id: readRegionBarsRightButton
                text: i18nc("Translucent bars and right pointer indicate reading region", "Bar && right")
                iconName: "sidebar-collapse-left"
                tooltip: i18n("Translucent bars and right pointer indicate reading region")
                enabled: parseInt(overlay.styleState)!==ReadRegionOverlay.PointerStates.BarsRight
                onTriggered: {
                    overlay.styleState = ReadRegionOverlay.PointerStates.BarsRight
                    contextDrawer.close()
                }
            }
            Kirigami.Action {
                id: readRegionAllButton
                text: i18nc("Enable all reading region indicators", "All")
                iconName: "auto-transition"
                tooltip: i18nc("Enable all reading region indicators", "Use all reading region indicators")
                enabled: parseInt(overlay.styleState)!==ReadRegionOverlay.PointerStates.All
                onTriggered: {
                    overlay.styleState = ReadRegionOverlay.PointerStates.All
                    contextDrawer.close()
                }
            }
            Kirigami.Action {
                id: readRegionNoneButton
                text: i18nc("Disable all reading region indicators", "Hidden")
                iconName: "format-justify-center"
                tooltip: i18nc("Disable all reading region indicators", "Disable reading region indicators")
                enabled: parseInt(overlay.styleState)!==ReadRegionOverlay.PointerStates.None
                onTriggered: {
                    overlay.styleState = ReadRegionOverlay.PointerStates.None
                    contextDrawer.close()
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
                iconName: "keyframe"
                text: i18n("Stopwatch")
                onTriggered: {
                    viewport.timer.stopwatch = !viewport.timer.stopwatch
                    // contextDrawer.close()
                }
            }
            Kirigami.Action {
                id: enableETAButton
                checkable: true
                checked: viewport.timer.eta
                iconName: "player-time"
                text: i18nc("Estimated Time of Arrival", "ETA")
                onTriggered: {
                    viewport.timer.eta = !viewport.timer.eta
                    // contextDrawer.close()
                }
            }
            Kirigami.Action {
                id: timerColorButton
                text: i18nc("Color of timer text", "Timer color")
                iconName: "format-text-color"
                onTriggered: {
                    viewport.timer.setColor()
                    contextDrawer.close()
                }
            }
            Kirigami.Action {
                id: clearTimerColorButton
                text: i18nc("Reset color of timer text back to default", "Clear color")
                iconName: "tool_color_eraser"
                enabled: !Qt.colorEqual(viewport.timer.textColor, '#AAA')
                onTriggered: {
                    viewport.timer.clearColor()
                    contextDrawer.close()
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
                text: i18nc("Enables automatic alignment of prompter and text with the reading region", "Auto frame")
                iconName: "transform-move-vertical"
                onTriggered: {
                    viewport.countdown.frame = !viewport.countdown.frame
                    //// Future: Implement way to way to prevent Kirigami.Action from closing parent Action menu.
                    //if (viewport.countdown.enabled)
                    //    // Use of implemented feature might go here.
                    // contextDrawer.close()
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
                    // contextDrawer.close()
                }
            }
            Kirigami.Action {
                id: autoStartCountdownButton
                enabled: enableCountdownButton.enabled && viewport.countdown.enabled
                checkable: true
                checked: viewport.countdown.autoStart && enableCountdownButton.checked
                text: i18nc("Auto start countdown upon prompter getting started", "Auto start")
                iconName: "chronometer"
                tooltip: i18n("Start countdown automatically")
                onTriggered: {
                    viewport.countdown.autoStart = !viewport.countdown.autoStart
                    // contextDrawer.close()
                }
            }
            Kirigami.Action {
                id: setCountdownButton
                enabled: enableCountdownButton.enabled && viewport.countdown.enabled
                text: i18nc("Configure countdown duration", "Set duration")
                iconName: "keyframe-add"
                onTriggered: {
                    viewport.countdown.configuration.open()
                    contextDrawer.close()
                }
            }
        },
        Kirigami.Action {
            id: flipButton

            function updateButton(context) {
                text = context.shortName
                //iconName = context.iconName
            }

            text: i18nc("Prompter orientation and mirroring", "Orientation")

            //Kirigami.Action {
                //readonly property string shortName: i18n("No Flip")
                //text: i18n("No flip")
                //iconName: "window"
                //enabled: viewport.prompter.__flipX || viewport.prompter.__flipY
                //onTriggered: {
                    //parent.updateButton(this)
                    //viewport.prompter.__flipX = false
                    //viewport.prompter.__flipY = false
                    //contextDrawer.close()
                //}
            //}
            Kirigami.Action {
                //readonly property string shortName: i18n("H Flip")
                text: i18nc("Mirrors prompter horizontally", "Horizontal mirror")
                //iconName: "object-flip-horizontal"
                //enabled: !viewport.prompter.__flipX || viewport.prompter.__flipY
                checkable: true
                checked: viewport.prompter.__flipX
                onTriggered: {
                    //parent.updateButton(this)
                    //viewport.prompter.__flipX = true
                    //viewport.prompter.__flipY = false
                    viewport.prompter.__flipX = !viewport.prompter.__flipX
                    contextDrawer.close()
                }
            }
            Kirigami.Action {
                //readonly property string shortName: i18n("V Flip")
                text: i18nc("Mirrors prompter vertically", "Vertical mirror")
                //iconName: "object-flip-vertical"
                //enabled: viewport.prompter.__flipX || !viewport.prompter.__flipY
                checkable: true
                checked: viewport.prompter.__flipY
                onTriggered: {
                    //parent.updateButton(this)
                    //viewport.prompter.__flipX = false
                    //viewport.prompter.__flipY = true
                    viewport.prompter.__flipY = !viewport.prompter.__flipY
                    contextDrawer.close()
                }
            }
            //Kirigami.Action {
                //readonly property string shortName: i18n("HV Flip") text: i18n("180° rotation")
                //iconName: Qt.LeftToRight ? "object-rotate-left" : "object-rotate-right"
                //enabled: !(viewport.prompter.__flipX && viewport.prompter.__flipY)
                //onTriggered: {
                    //parent.updateButton(this)
                    //viewport.prompter.__flipX = true
                    //viewport.prompter.__flipY = true
                    //contextDrawer.close()
                //}
            //}
            Kirigami.Action {
                text: i18nc("Prompter rotation is disabled", "Don't rotate")
                iconName: "window"
                enabled: viewport.forcedOrientation!==0
                onTriggered: {
                    //if (viewport.forcedOrientation!==1)
                    viewport.forcedOrientation = 0
                    contextDrawer.close()
                }
            }
            Kirigami.Action {
                text: i18nc("Rotate prompter 90 degrees to the right", "90° clockwise")
                iconName: "object-rotate-right"
                enabled: viewport.forcedOrientation!==1
                onTriggered: {
                    //if (viewport.forcedOrientation!==1)
                    viewport.forcedOrientation = 1
                    contextDrawer.close()
                }
            }
            Kirigami.Action {
                text: i18nc("Rotate prompter 90 degrees to the left", "90° counter")
                iconName: "object-rotate-left"
                enabled: viewport.forcedOrientation!==2
                onTriggered: {
                    //if (viewport.forcedOrientation!==2)
                    viewport.forcedOrientation = 2
                    contextDrawer.close()
                }
            }
            //Kirigami.Action {
                //text: i18n("Inverted")
                //iconName: Qt.LeftToRight ? "object-rotate-left" : "object-rotate-right"
                //enabled: viewport.forcedOrientation!==3
                //onTriggered: {
                    ////if (viewport.forcedOrientation!==3)
                    //viewport.forcedOrientation = 3
                    //contextDrawer.close()
                //}
            //}
        },
        Kirigami.Action {
            id: loadBackgroundButton
            text: i18nc("Background refers to what appears behind the prompter", "Background")
            Kirigami.Action {
                id: changeBackgroundImageButton
                text: i18nc("Set background image", "Set image")
                iconName: "insert-image"
                onTriggered: {
                    prompterBackground.loadBackgroundImage()
                    contextDrawer.close()
                }
            }
            Kirigami.Action {
                id: changeBackgroundColorButton
                text: i18nc("Set background color tint", "Set color")
                iconName: "format-fill-color"
                onTriggered: {
                    prompterBackground.backgroundColorDialog.open()
                    contextDrawer.close()
                }
            }
            Kirigami.Action {
                id: clearBackgroundButton
                text: i18nc("Set background settings back to default", "Clear")
                enabled: prompterBackground.hasBackground
                iconName: "tool_color_eraser"
                onTriggered: {
                    prompterBackground.clearBackground()
                    contextDrawer.close()
                }
            }
        },
        Kirigami.Action {
            id: displaySettings
            visible: !Kirigami.Settings.isMobile || 'linux'===Qt.platform.os
            text: i18nc("Screens refers to computer displays", "Screens")

            Kirigami.Action {
                displayComponent: ListView {
                    height: contentHeight>580 ? 580 : contentHeight
                    model: Qt.application.screens
                    delegate: Kirigami.SwipeListItem {
                        id: display
                        property string name: model.name
                        property int flipSetting: projectionManager.getDisplayFlip(display.name)
                        function toggleDisplayFlip() {
                            flipSetting = (flipSetting+1)%5
                            projectionManager.putDisplayFlip(display.name, flipSetting)
                        }
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
                        Label {
                            id: label
                            text: switch (flipSetting) {
                                case 0 : return display.name + " : " + i18nc("Screen is disabled", "Off");
                                case 1 : return display.name + " : " + i18nc("Screen is enabled but mirroring is disabled", "No Mirror");
                                case 2 : return display.name + " : " + i18nc("Horizontal mirroring", "H Mirror");
                                case 3 : return display.name + " : " + i18nc("Vertical mirroring", "V Mirror");
                                case 4 : return display.name + " : " + i18nc("Horizontal and vertical mirroring", "HV Mirror");
                            }
                        }
                    }
                }
            }
            Kirigami.Action {
                text: i18nc("Enable scaling prompter copies being projected onto displays", "Scale projections")
                checkable: true
                checked: projectionManager.reScale
                onTriggered: {
                    projectionManager.reScale = !projectionManager.reScale
                    contextDrawer.close()
                }
            }
            Kirigami.Action {
                text: i18nc("Preview projecting prompter copies onto displays", "Preview projections")
                tooltip: i18n("Project prompter copies onto extended displays")
                enabled: parseInt(prompter.state)===Prompter.States.Editing
                onTriggered: {
                    projectionManager.preview()
                    contextDrawer.close()
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
            onTriggered: {
                root.__fullScreen = !root.__fullScreen
                contextDrawer.close()
            }
        }
        ]
    }

    // Editor Toolbar
    footer: EditorToolbar {
        id: editorToolbar
    }

    PrompterView {
        id: viewport
        height: (forcedOrientation && forcedOrientation!==3 ? parent.width : (root.theforce && !forcedOrientation ? 3 : 1) * parent.height) + (Kirigami.Settings.isMobile ? 68 : 0)
        // anchors.bottomMargin: Kirigami.Settings.isMobile ? -68 : 0
        width: (forcedOrientation && forcedOrientation!==3 ? parent.height : (root.theforce && !forcedOrientation ? 0.3 : 1) * parent.width)
        x: (forcedOrientation===1 || forcedOrientation===3 ? parent.width : (root.theforce && !forcedOrientation ? width*1.165 : 0))
        y: (forcedOrientation===2 || forcedOrientation===3 ? parent.height : - (root.theforce && !forcedOrientation ? height/4 : 0))
        transform: Rotation {
            origin.x: 0; origin.y: 0;
            angle: switch (viewport.forcedOrientation) {
                case 1: return 90;
                case 2: return -90;
                case 3: return 180;
                default: return 0;
            }
            //Behavior on angle {
                //enabled: true
                //animation: NumberAnimation {
                    //duration: Kirigami.Units.longDuration
                    //easing.type: Easing.OutQuad
                //}
            //}
        }
        //Behavior on x {
            //enabled: true
            //animation: NumberAnimation {
                //duration: Kirigami.Units.longDuration
                //easing.type: Easing.OutQuad
            //}
        //}
        //Behavior on y {
            //enabled: true
            //animation: NumberAnimation {
                //duration: Kirigami.Units.longDuration
                //easing.type: Easing.OutQuad
            //}
        //}
        //Behavior on width {
            //enabled: viewport.forcedOrientation
            //animation: NumberAnimation {
                //duration: Kirigami.Units.longDuration
                //easing.type: Easing.OutQuad
            //}
        //}
        //Behavior on height {
            //enabled: viewport.forcedOrientation
            //animation: NumberAnimation {
                //duration: Kirigami.Units.longDuration
                //easing.type: Easing.OutQuad
            //}
        //}
        //// Workaround to make regular Page let its contents be covered by action buttons.
        //anchors.bottomMargin: pageStack.globalToolBar.actualStyle === Kirigami.ApplicationHeaderStyle.None ? -68 : 0
        prompter.performFileOperations: true
        property alias toolbar: editorToolbar
    }

    // The following rectangles add a background that is shown behind the mobile action buttons when the user is in desktop mode but the action buttons are showing. These also improve contrast with the editor toolbar when opacity is active.
    // Action buttons are only supposed to be shown in desktop mode if the user is in fullscreen and not in the prompter's editing state, but there is a bug in Kirigami that causes it to appear under some circumstances or all of the time in desktop operating systems. Behavior varies from system to system.
    Rectangle {
        anchors.left: parent.left;
        anchors.right: parent.right;
        anchors.top: prompterCutOffLine.bottom;
        // By extending over the editor we avoid seeing a cutoff in opaque mode and improve contrast
        height: 68 + editor.height
        color: Kirigami.Theme.alternateBackgroundColor.a===0 ? Qt.rgba(appTheme.__backgroundColor.r*2/3, appTheme.__backgroundColor.g*2/3, appTheme.__backgroundColor.b*2/3, 1)
                    : Qt.rgba(Kirigami.Theme.alternateBackgroundColor.r*2/3, Kirigami.Theme.alternateBackgroundColor.g*2/3, Kirigami.Theme.alternateBackgroundColor.b*2/3, 1)
        opacity: root.__opacity * 0.4 + 0.6
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            onWheel: (wheel)=>viewport.mouse.wheel(wheel)
        }
    }
    // The cut off line renders as a solid and doesn't cover the other rectangles to improve performance.
    Rectangle {
        id: prompterCutOffLine
        color: Qt.rgba(Kirigami.Theme.activeBackgroundColor.r/4, Kirigami.Theme.activeBackgroundColor.g/8, Kirigami.Theme.activeBackgroundColor.b/6, 1)
        height: 3
        //height: Kirigami.Settings.isMobile ? 3 : 2
        anchors.left: parent.left;
        anchors.right: parent.right;
        //anchors.top: viewport.bottom;
        y: parent.height
    }

    // progress: parseInt(viewport.prompter.state)===Prompter.States.Prompting ? viewport.prompter.progress : undefined

    Labs.FontDialog {
        id: fontDialog
        //monospacedFonts: true
        //nonScalableFonts: true
        //proportionalFonts: true
        font: Qt.font({
            family: viewport.prompter.document.fontFamily,

            bold: viewport.prompter.document.bold,
            italic: viewport.prompter.document.italic,
            underline: viewport.prompter.document.underline,
            strikeout: viewport.prompter.document.strike,

            //overline: viewport.prompter.document.overline,
            //weight: viewport.prompter.document.weight,
            //capitalization: viewport.prompter.document.capitalization,
            //letterSpacing: viewport.prompter.document.letterSpacing,
            //wordSpacing: viewport.prompter.document.wordSpacing,
            //kerning: viewport.prompter.document.kerning,
            //preferShaping: viewport.prompter.document.preferShaping,
            //hintingPreference: viewport.prompter.document.hintingPreference,
            //styleName: viewport.prompter.document.styleName

            pointSize: ((editorToolbar.fontSizeSlider.value - editorToolbar.fontSizeSlider.from) * (72 - 6) / (editorToolbar.fontSizeSlider.to - editorToolbar.fontSizeSlider.from)) + 6
        })
        onAccepted: {
            viewport.prompter.document.fontFamily = font.family;

            viewport.prompter.document.bold = font.bold;
            viewport.prompter.document.italic = font.italic;
            viewport.prompter.document.underline = font.underline;
            viewport.prompter.document.strike = font.strikeout;

            //viewport.prompter.document.overline = font.overline;
            //viewport.prompter.document.weight = font.weight;
            //viewport.prompter.document.capitalization = font.capitalization;
            //viewport.prompter.document.letterSpacing = font.letterSpacing;
            //viewport.prompter.document.wordSpacing = font.wordSpacing;
            //viewport.prompter.document.kerning = font.kerning;
            //viewport.prompter.document.preferShaping = font.preferShaping;
            //viewport.prompter.document.hintingPreference = font.hintingPreference;
            //viewport.prompter.document.styleName = font.styleName;

            editorToolbar.fontSizeSlider.value = ((font.pointSize - 6) * (editorToolbar.fontSizeSlider.to - editorToolbar.fontSizeSlider.from) / (72 - 6)) + editorToolbar.fontSizeSlider.from
        }
    }

    ColorDialog {
        id: colorDialog
        showAlphaChannel: false
    }

    ColorDialog {
        id: highlightDialog
        showAlphaChannel: false
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
