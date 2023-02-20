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
import QtQuick.Dialogs 1.3
//import Qt.labs.platform 1.1 as Labs

import com.cuperino.qprompt.markers 1.0
import com.cuperino.qprompt.abstractunits 1.0

Kirigami.Page {
    id: prompterPage

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
    property alias keyConfigurationOverlay: keyConfigurationOverlay
    property alias displaySettings: displaySettings
    property alias markersDrawer: markersDrawer
    property alias countdownConfiguration: countdownConfiguration
    property alias namedMarkerConfiguration: namedMarkerConfiguration
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
            icon.source: Qt.application.layoutDirection === Qt.RightToLeft ? "icons/go-previous.svg" : "icons/go-next.svg"
            onTriggered: prompter.toggle()
        }
        left: Kirigami.Action {
            id: decreaseVelocityButton
            enabled: Kirigami.Settings.isMobile
            text: pageStack.globalToolBar.actualStyle === Kirigami.ApplicationHeaderStyle.None ? i18n("Decrease velocity") : ""
            icon.source: Qt.application.layoutDirection === Qt.RightToLeft ? "icons/go-next.svg" : "icons/go-previous.svg"
            onTriggered: {
                if (parseInt(prompter.state) === Prompter.States.Prompting)
                    viewport.prompter.decreaseVelocity(false)
                else
                    prompter.goToPreviousMarker()
                viewport.prompter.focus = true;
            }
        }
        right: Kirigami.Action {
            id: increaseVelocityButton
            enabled: Kirigami.Settings.isMobile
            text: pageStack.globalToolBar.actualStyle === Kirigami.ApplicationHeaderStyle.None ? i18n("Increase velocity") : ""
            icon.source: Qt.application.layoutDirection === Qt.RightToLeft ? "icons/go-previous.svg" : "icons/go-next.svg"
            onTriggered: {
                if (parseInt(prompter.state) === Prompter.States.Prompting)
                    viewport.prompter.increaseVelocity(false)
                else
                    prompter.goToNextMarker()
                viewport.prompter.restoreFocus()
            }
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
                icon.source: "icons/go-up.svg"
                text: i18nc("Align reading region to top of prompter", "Top")
                enabled: parseInt(viewport.overlay.positionState)!==ReadRegionOverlay.PositionStates.Top
                tooltip: i18n("Move reading region to the top, convenient for use with webcams")
                onTriggered: {
                    viewport.overlay.positionState = ReadRegionOverlay.PositionStates.Top
                    contextDrawer.close()
                    viewport.prompter.restoreFocus()
                }
            }
            Kirigami.Action {
                id: readRegionMiddleButton
                iconName: "list-remove"
                icon.source: "icons/list-remove.svg"
                text: i18nc("Align reading region to vertical center of prompter", "Middle")
                enabled: parseInt(viewport.overlay.positionState)!==ReadRegionOverlay.PositionStates.Middle
                tooltip: i18n("Move reading region to the vertical center")
                onTriggered: {
                    viewport.overlay.positionState = ReadRegionOverlay.PositionStates.Middle
                    contextDrawer.close()
                    viewport.prompter.restoreFocus()
                }
            }
            Kirigami.Action {
                id: readRegionBottomButton
                iconName: "go-down"
                icon.source: "icons/go-down.svg"
                text: i18nc("Align reading region to bottom of prompter", "Bottom")
                enabled: parseInt(viewport.overlay.positionState)!==ReadRegionOverlay.PositionStates.Bottom
                tooltip: i18n("Move reading region to the bottom")
                onTriggered: {
                    viewport.overlay.positionState = ReadRegionOverlay.PositionStates.Bottom
                    contextDrawer.close()
                    viewport.prompter.restoreFocus()
                }
            }
            Kirigami.Action {
                id: readRegionFreeButton
                iconName: "handle-sort"
                icon.source: "icons/handle-sort.svg"
                text: i18nc("Refers to free placement. Enables drag and drop positioning of reading region.", "Free")
                enabled: parseInt(viewport.overlay.positionState)!==ReadRegionOverlay.PositionStates.Free
                tooltip: i18n("Move reading region freely by dragging and dropping")
                onTriggered: {
                    viewport.overlay.positionState = ReadRegionOverlay.PositionStates.Free
                    contextDrawer.close()
                    viewport.prompter.restoreFocus()
                }
            }
            Kirigami.Action {
                id: readRegionCustomButton
                iconName: "dialog-ok-apply"
                icon.source: "icons/dialog-ok-apply.svg"
                text: i18nc("Fix positioning of reading region to what was set in \"Free placement\" mode", "Custom")
                enabled: parseInt(viewport.overlay.positionState)!==ReadRegionOverlay.PositionStates.Fixed
                tooltip: i18n("Fix reading region to the position set using free placement mode")
                onTriggered: {
                    viewport.overlay.positionState = ReadRegionOverlay.PositionStates.Fixed
                    contextDrawer.close()
                    viewport.prompter.restoreFocus()
                }
            }
            Kirigami.Action {
                displayComponent: Kirigami.SwipeListItem {
                    activeTextColor: "#FFFFFF"
                    activeBackgroundColor: "#797979"
                    actions: [
                        Kirigami.Action {
                            iconName: Qt.LeftToRight ? "go-next" : "go-previous";
                            icon.source: Qt.LeftToRight ? "icons/go-next.svg" : "icons/go-previous.svg"
                            onTriggered: viewport.overlay.toggleLinesInRegion(true)
                        },
                        Kirigami.Action {
                            iconName: (Qt.LeftToRight ? "go-previous" : "go-next");
                            icon.source: Qt.LeftToRight ? "icons/go-previous.svg" : "icons/go-next.svg"
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
            //     icon.source: enabled ? (hideDecorations===0 ? "icons/window.svg" : (hideDecorations===1 ? "icons/draw-rectangle.svg" : "icons/gnumeric-object-rectangle.svg")) : ""
            //     Kirigami.Action {
            //         text: i18n("Normal frame")
            //         tooltip: i18n("Shows windows frame when in windowed mode")
            //         iconName: "window"
            //         icon.source: "icons/window.svg"
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
            //         icon.source: "icons/draw-rectangle.svg"
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
            //         icon.source: "icons/gnumeric-object-rectangle.svg"
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
                icon.source: "icons/go-next.svg"
                tooltip: i18n("Left pointer indicates reading region")
                enabled: parseInt(overlay.styleState)!==ReadRegionOverlay.PointerStates.LeftPointer
                onTriggered: {
                    overlay.styleState = ReadRegionOverlay.PointerStates.LeftPointer
                    contextDrawer.close()
                    viewport.prompter.restoreFocus()
                }
            }
            Kirigami.Action {
                id: readRegionRightPointerButton
                text: i18nc("Shows pointer to the right of the reading region", "Right pointer")
                iconName: "go-previous"
                icon.source: "icons/go-previous.svg"
                tooltip: i18n("Right pointer indicates reading region")
                enabled: parseInt(overlay.styleState)!==ReadRegionOverlay.PointerStates.RightPointer
                onTriggered: {
                    overlay.styleState = ReadRegionOverlay.PointerStates.RightPointer
                    contextDrawer.close()
                    viewport.prompter.restoreFocus()
                }
            }
            Kirigami.Action {
                id: readRegionPointersButton
                text: i18nc("Shows pointers to the left and right of the reading region", "Both pointers")
                iconName: "transform-move-horizontal"
                icon.source: "icons/transform-move-horizontal.svg"
                tooltip: i18n("Left and right pointers indicate reading region")
                enabled: parseInt(overlay.styleState)!==ReadRegionOverlay.PointerStates.Pointers
                onTriggered: {
                    overlay.styleState = ReadRegionOverlay.PointerStates.Pointers
                    contextDrawer.close()
                    viewport.prompter.restoreFocus()
                }
            }
            Kirigami.Action {
                id: readRegionBarsButton
                text: i18nc("Translucent bars indicate reading region", "Bar")
                iconName: "list-remove"
                icon.source: "icons/list-remove.svg"
                tooltip: i18n("Translucent bars indicate reading region")
                enabled: parseInt(overlay.styleState)!==ReadRegionOverlay.PointerStates.Bars
                onTriggered: {
                    overlay.styleState = ReadRegionOverlay.PointerStates.Bars
                    contextDrawer.close()
                    viewport.prompter.restoreFocus()
                }
            }
            Kirigami.Action {
                id: readRegionBarsLeftButton
                text: i18nc("Translucent bars and left pointer indicate reading region", "Bar && left")
                iconName: "sidebar-collapse-right"
                icon.source: "icons/sidebar-collapse-right.svg"
                tooltip: i18n("Translucent bars and left pointer indicate reading region")
                enabled: parseInt(overlay.styleState)!==ReadRegionOverlay.PointerStates.BarsLeft
                onTriggered: {
                    overlay.styleState = ReadRegionOverlay.PointerStates.BarsLeft
                    contextDrawer.close()
                    viewport.prompter.restoreFocus()
                }
            }
            Kirigami.Action {
                id: readRegionBarsRightButton
                text: i18nc("Translucent bars and right pointer indicate reading region", "Bar && right")
                iconName: "sidebar-collapse-left"
                icon.source: "icons/sidebar-collapse-left.svg"
                tooltip: i18n("Translucent bars and right pointer indicate reading region")
                enabled: parseInt(overlay.styleState)!==ReadRegionOverlay.PointerStates.BarsRight
                onTriggered: {
                    overlay.styleState = ReadRegionOverlay.PointerStates.BarsRight
                    contextDrawer.close()
                    viewport.prompter.restoreFocus()
                }
            }
            Kirigami.Action {
                id: readRegionAllButton
                text: i18nc("Enable all reading region indicators", "All")
                iconName: "auto-transition"
                icon.source: "icons/auto-transition.svg"
                tooltip: i18nc("Enable all reading region indicators", "Use all reading region indicators")
                enabled: parseInt(overlay.styleState)!==ReadRegionOverlay.PointerStates.All
                onTriggered: {
                    overlay.styleState = ReadRegionOverlay.PointerStates.All
                    contextDrawer.close()
                    viewport.prompter.restoreFocus()
                }
            }
            Kirigami.Action {
                id: readRegionNoneButton
                text: i18nc("Disable all reading region indicators", "Hidden")
                iconName: "view-list-text"
                icon.source: "icons/view-list-text.svg"
                tooltip: i18nc("Disable all reading region indicators", "Disable reading region indicators")
                enabled: parseInt(overlay.styleState)!==ReadRegionOverlay.PointerStates.None
                onTriggered: {
                    overlay.styleState = ReadRegionOverlay.PointerStates.None
                    contextDrawer.close()
                    viewport.prompter.restoreFocus()
                }
            }
        },
        Kirigami.Action {
            id: timerButton
            text: i18n("Timer")
            // Some speakers want don't want their times visible at all times, but they'd like to
            // know how long it took them to speak, so they enable and disable timers as desired.
            // For the total time to be computed correctly, clock operations, as they exist,
            // need to be running at all times. Running clock operations at all times can result
            // in degraded performance when running on low end hardware and while using
            // screen projections. The following action allows enabling and disabling
            // clock operations without timers having to be visible at all times.
            Kirigami.Action {
                id: enableTimersButton
                checkable: true
                checked: viewport.timer.timersEnabled
                text: i18n("Enable timers")
                onTriggered: {
                    viewport.timer.enabled = checked;
                    viewport.prompter.restoreFocus()
                }
            }
            Kirigami.Action {
                id: enableStopwatchButton
                enabled: viewport.timer.timersEnabled
                checkable: true
                checked: viewport.timer.stopwatch
                iconName: "keyframe"
                icon.source: "icons/keyframe.svg"
                text: i18n("Stopwatch")
                onTriggered: {
                    viewport.timer.stopwatch = checked
                    viewport.prompter.restoreFocus()
                }
            }
            Kirigami.Action {
                id: enableETAButton
                enabled: viewport.timer.timersEnabled
                checkable: true
                checked: viewport.timer.eta
                iconName: "player-time"
                icon.source: "icons/player-time.svg"
                text: i18nc("Estimated Time of Arrival", "ETA")
                onTriggered: {
                    viewport.timer.eta = checked
                    viewport.prompter.restoreFocus()
                }
            }
            Kirigami.Action {
                id: timerColorButton
                enabled: viewport.timer.timersEnabled
                text: i18nc("Color of timer text", "Timer color")
                iconName: "format-text-color"
                icon.source: "icons/format-text-color.svg"
                onTriggered: {
                    viewport.timer.setColor()
                    contextDrawer.close()
                    viewport.prompter.restoreFocus()
                }
            }
            Kirigami.Action {
                id: clearTimerColorButton
                enabled: viewport.timer.timersEnabled && !Qt.colorEqual(viewport.timer.textColor, '#AAA')
                text: i18nc("Reset color of timer text back to default", "Clear color")
                iconName: "tool_color_eraser"
                icon.source: "icons/tool_color_eraser.svg"
                onTriggered: {
                    viewport.timer.clearColor()
                    contextDrawer.close()
                    viewport.prompter.restoreFocus()
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
                icon.source: "icons/transform-move-vertical.svg"
                onTriggered: {
                    viewport.countdown.frame = !viewport.countdown.frame
                    //// Future: Implement way to way to prevent Kirigami.Action from closing parent Action menu.
                    //if (viewport.countdown.enabled)
                    //    // Use of implemented feature might go here.
                    // contextDrawer.close()
                    viewport.prompter.restoreFocus()
                }
            }
            Kirigami.Action {
                id: enableCountdownButton
                enabled: viewport.countdown.frame
                checkable: true
                checked: viewport.countdown.enabled
                text: i18n("Countdown")
                iconName: "chronometer-pause"
                icon.source: "icons/chronometer-pause.svg"
                onTriggered: {
                    viewport.countdown.enabled = !viewport.countdown.enabled
                    //// Future: Implement way to way to prevent Kirigami.Action from closing parent Action menu.
                    //if (viewport.countdown.enabled)
                    //    // Use of implemented feature might go here.
                    // contextDrawer.close()
                    viewport.prompter.restoreFocus()
                }
            }
            Kirigami.Action {
                id: autoStartCountdownButton
                enabled: enableCountdownButton.enabled && viewport.countdown.enabled
                checkable: true
                checked: viewport.countdown.autoStart && enableCountdownButton.checked
                text: i18nc("Auto start countdown upon prompter getting started", "Auto start")
                iconName: "chronometer"
                icon.source: "icons/chronometer.svg"
                tooltip: i18n("Start countdown automatically")
                onTriggered: {
                    viewport.countdown.autoStart = !viewport.countdown.autoStart
                    // contextDrawer.close()
                    viewport.prompter.restoreFocus()
                }
            }
            Kirigami.Action {
                id: setCountdownButton
                enabled: enableCountdownButton.enabled && viewport.countdown.enabled
                text: i18nc("Configure countdown duration", "Set duration")
                iconName: "keyframe-add"
                icon.source: "icons/keyframe-add.svg"
                onTriggered: {
                    countdownConfiguration.open()
                    contextDrawer.close()
                    viewport.prompter.restoreFocus()
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
                    //prompter.restoreFocus()
                //}
            //}
            Kirigami.Action {
                //readonly property string shortName: i18n("H Flip")
                text: i18nc("Mirrors prompter horizontally", "Horizontal mirror")
                //iconName: "object-flip-horizontal"
                //icon.source: "icons/object-flip-horizontal.svg"
                //enabled: !viewport.prompter.__flipX || viewport.prompter.__flipY
                checkable: true
                checked: viewport.prompter.__flipX
                onTriggered: {
                    //parent.updateButton(this)
                    //viewport.prompter.__flipX = true
                    //viewport.prompter.__flipY = false
                    viewport.prompter.__flipX = !viewport.prompter.__flipX
                    contextDrawer.close()
                    viewport.prompter.restoreFocus()
                }
            }
            Kirigami.Action {
                //readonly property string shortName: i18n("V Flip")
                text: i18nc("Mirrors prompter vertically", "Vertical mirror")
                //iconName: "object-flip-vertical"
                //icon.source: "icons/object-flip-vertical.svg"
                //enabled: viewport.prompter.__flipX || !viewport.prompter.__flipY
                checkable: true
                checked: viewport.prompter.__flipY
                onTriggered: {
                    //parent.updateButton(this)
                    //viewport.prompter.__flipX = false
                    //viewport.prompter.__flipY = true
                    viewport.prompter.__flipY = !viewport.prompter.__flipY
                    contextDrawer.close()
                    viewport.prompter.restoreFocus()
                }
            }
            //Kirigami.Action {
                //readonly property string shortName: i18n("HV Flip") text: i18n("180° rotation")
                //iconName: Qt.LeftToRight ? "object-rotate-left" : "object-rotate-right"
                //icon.source: Qt.LeftToRight ? "icons/object-rotate-left.svg" : "icons/object-rotate-right.svg"
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
                icon.source: "icons/window.svg"
                enabled: viewport.forcedOrientation!==0
                onTriggered: {
                    //if (viewport.forcedOrientation!==1)
                    viewport.forcedOrientation = 0
                    contextDrawer.close()
                    viewport.prompter.restoreFocus()
                }
            }
            Kirigami.Action {
                text: i18nc("Rotate prompter 90 degrees to the right", "90° clockwise")
                iconName: "object-rotate-right"
                icon.source: "icons/object-rotate-right.svg"
                enabled: viewport.forcedOrientation!==1
                onTriggered: {
                    //if (viewport.forcedOrientation!==1)
                    viewport.forcedOrientation = 1
                    contextDrawer.close()
                    viewport.prompter.restoreFocus()
                }
            }
            Kirigami.Action {
                text: i18nc("Rotate prompter 90 degrees to the left", "90° counter")
                iconName: "object-rotate-left"
                icon.source: "icons/object-rotate-left.svg"
                enabled: viewport.forcedOrientation!==2
                onTriggered: {
                    //if (viewport.forcedOrientation!==2)
                    viewport.forcedOrientation = 2
                    contextDrawer.close()
                    viewport.prompter.restoreFocus()
                }
            }
            //Kirigami.Action {
                //text: i18n("Inverted")
                //iconName: Qt.LeftToRight ? "object-rotate-left" : "object-rotate-right"
                //icon.source: Qt.LeftToRight ? "icons/object-rotate-left.svg" : "icons/object-rotate-right.svg"
                //enabled: viewport.forcedOrientation!==3
                //onTriggered: {
                    ////if (viewport.forcedOrientation!==3)
                    //viewport.forcedOrientation = 3
                    //contextDrawer.close()
                    //prompter.restoreFocus()
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
                icon.source: "icons/insert-image.svg"
                onTriggered: {
                    prompterBackground.loadBackgroundImage()
                    contextDrawer.close()
                    viewport.prompter.restoreFocus()
                }
            }
            Kirigami.Action {
                id: changeBackgroundColorButton
                text: i18nc("Set background color tint", "Set color")
                iconName: "fill-color"
                icon.source: "icons/fill-color.svg"
                onTriggered: {
                    prompterBackground.backgroundColorDialog.open()
                    contextDrawer.close()
                    viewport.prompter.restoreFocus()
                }
            }
            Kirigami.Action {
                id: clearBackgroundButton
                text: i18nc("Set background settings back to default", "Clear")
                enabled: prompterBackground.hasBackground
                iconName: "tool_color_eraser"
                icon.source: "icons/tool_color_eraser.svg"
                onTriggered: {
                    prompterBackground.clearBackground()
                    contextDrawer.close()
                    viewport.prompter.restoreFocus()
                }
            }
        },
        Kirigami.Action {
            id: displaySettings
            visible: (!Kirigami.Settings.isMobile || Qt.platform.os==='linux') && Qt.platform.os!=='haiku'
            text: i18nc("Screens refers to computer displays", "Screens")

            Kirigami.Action {
                displayComponent: ListView {
                    height: visible ? contentHeight > 580 ? 580 : contentHeight : 0
                    model: Qt.application.screens
                    delegate: Kirigami.SwipeListItem {
                        id: display
                        property string name: model.name
                        property int flipSetting: projectionManager.getDisplayFlip(display.name)
                        function toggleDisplayFlip() {
                            flipSetting = (flipSetting+1)%5
                            projectionManager.putDisplayFlip(display.name, flipSetting)
                            projectionManager.updateFromRoot(display.name, flipSetting)
                        }
                        enabled: Qt.platform.os!=='windows' || display.name!==screen.name// && (parseInt(prompter.state)===Prompter.States.Editing || parseInt(prompter.state)===Prompter.States.Standby)
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
                                icon.source: switch (flipSetting) {
                                    case 0 : return "icons/window.svg";
                                    case 1 : return "icons/window-duplicate.svg";
                                    case 2 : return "icons/object-flip-horizontal.svg";
                                    case 3 : return "icons/object-flip-vertical.svg";
                                    case 4 : return (Qt.LeftToRight ? "icons/object-rotate-left.svg" : "icons/object-rotate-right.svg");
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
                    Component.onCompleted: {
                        // By assigning visible non-declaratively, we ensure the menu's state won't be updated until the next time it's openend
                        visible = projectionManager.isEnabled;
                    }
                }
            }
            Kirigami.Action {
                text: i18nc("Display prompter copies onto displays", "Enable projection")
                //tooltip: i18n("Display prompter copies onto extended displays")
                checkable: true
                checked: projectionManager.isEnabled
                onTriggered: {
                    projectionManager.toggle()
                    contextDrawer.close()
                    viewport.prompter.restoreFocus()
                }
            }
            Kirigami.Action {
                enabled: projectionManager.isEnabled
                text: i18nc("Enable scaling prompter copies being projected onto displays", "Scale projection")
                checkable: true
                checked: projectionManager.reScale
                onTriggered: {
                    projectionManager.reScale = !projectionManager.reScale;
                    contextDrawer.close();
                    viewport.prompter.restoreFocus()
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
        //        viewport.prompter.restoreFocus()
        //    }
        //},
        Kirigami.Action {
            id: fullscreenButton
            visible: !fullScreenPlatform
            text: root.__fullScreen ? i18n("Leave Fullscreen") : i18n("Fullscreen")
            onTriggered: {
                root.__fullScreen = !root.__fullScreen
                contextDrawer.close()
                viewport.prompter.restoreFocus()
            }
        }
        ]
    }

    // Editor Toolbar
    footer: EditorToolbar {
        id: editorToolbar
    }

    Component.onCompleted: {
        //editorToolbar.lineHeightSlider.update()
        //editorToolbar.paragraphSpacingSlider.update()
    }

    PrompterView {
        id: viewport
        property alias toolbar: editorToolbar
        height: (forcedOrientation && forcedOrientation!==3 ? parent.width : (root.theforce && !forcedOrientation ? 3 : 1) * parent.height) + (Kirigami.Settings.isMobile ? 68 : 0)
        // anchors.bottomMargin: Kirigami.Settings.isMobile ? -68 : 0
        width: (forcedOrientation && forcedOrientation!==3 ? parent.height : (root.theforce && !forcedOrientation ? 0.3 : 1) * parent.width)
        x: (forcedOrientation===1 || forcedOrientation===3 ? parent.width : (root.theforce && !forcedOrientation ? width*1.165 : 0))
        y: (forcedOrientation===2 || forcedOrientation===3 ? parent.height : - (root.theforce && !forcedOrientation ? height/4 : 0))

        layer.enabled: projectionManager.isEnabled
        layer.smooth: false
        layer.mipmap: false

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
                    //duration: Units.longDuration
                    //easing.type: Easing.OutQuad
                //}
            //}
        }
        // Workaround to make regular Page let its contents be covered by action buttons.
        anchors.bottomMargin: pageStack.globalToolBar.actualStyle === Kirigami.ApplicationHeaderStyle.None ? -68 : 0
        prompter.performFileOperations: true
        //Behavior on x {
            //enabled: true
            //animation: NumberAnimation {
                //duration: Units.longDuration
                //easing.type: Easing.OutQuad
            //}
        //}
        //Behavior on y {
            //enabled: true
            //animation: NumberAnimation {
                //duration: Units.longDuration
                //easing.type: Easing.OutQuad
            //}
        //}
        //Behavior on width {
            //enabled: viewport.forcedOrientation
            //animation: NumberAnimation {
                //duration: Units.longDuration
                //easing.type: Easing.OutQuad
            //}
        //}
        //Behavior on height {
            //enabled: viewport.forcedOrientation
            //animation: NumberAnimation {
                //duration: Units.longDuration
                //easing.type: Easing.OutQuad
            //}
        //}
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
        id: markersDrawer
    }

    InputsOverlay {
        id: keyConfigurationOverlay
    }

    Kirigami.OverlaySheet {
        id: countdownConfiguration
        onSheetOpenChanged: prompterPage.actions.main.checked = sheetOpen

        header: Kirigami.Heading {
            text: i18n("Countdown Setup")
            level: 1
        }

        RowLayout {
            width: parent.width

            ColumnLayout {
                Label {
                    text: i18n("Countdown iterations")
                }
                SpinBox {
                    value: countdown.__iterations
                    from: 1
                    to: 300  // 5*60
                    onValueModified: {
                        focus: true
                        countdown.__iterations = value
                        if (countdown.__disappearWithin && countdown.__disappearWithin >= countdown.__iterations)
                            countdown.__disappearWithin = countdown.__iterations
                    }
                    Layout.fillWidth: true
                    Layout.leftMargin: Kirigami.Units.smallSpacing
                    Layout.rightMargin: Kirigami.Units.smallSpacing
                }
            }
            ColumnLayout {
                Label {
                    text: i18np("Disappear within 1 second to go",
                                "Disappear within %1 seconds to go", countdown.__disappearWithin);
                }
                SpinBox {
                    value: countdown.__disappearWithin
                    from: 1
                    to: 10
                    onValueModified: {
                        focus: true
                        countdown.__disappearWithin = value
                        if (countdown.__iterations <= countdown.__disappearWithin)
                            countdown.__iterations = countdown.__disappearWithin
                    }
                    Layout.fillWidth: true
                    Layout.leftMargin: Kirigami.Units.smallSpacing
                    Layout.rightMargin: Kirigami.Units.smallSpacing
                }
            }
        }
    }

    Kirigami.OverlaySheet {
        id: namedMarkerConfiguration
        header: Kirigami.Heading {
            text: i18nc("Refers to a key on the keyboard used to skip to a user defined marker while prompting", "Skip Key")
            level: 1
        }
        onSheetOpenChanged: {
            prompterPage.actions.main.checked = sheetOpen;
            // When opening overlay, reset key input button's text.
            // Dev: When opening overlay, reset key input button's text to current anchor's key value.
            if (sheetOpen)
                //row.setMarkerKeyButton.item.text = "";
                column.setMarkerKeyButton.item.text = prompter.document.getMarkerKey();
            else {
                prompter.restoreFocus()
                if (markersDrawer.reOpen) {
                    prompter.document.parse()
                    markersDrawer.open()
                }
            }
        }
        ColumnLayout {
            id: column
            property alias setMarkerKeyButton: setMarkerKeyButton
            width: parent.width
            Label {
                text: i18nc("Refers to a key on the keyboard used to skip to a user defined marker while prompting", "Key to perform skip to this marker")
            }
            Loader {
                id: setMarkerKeyButton
                asynchronous: true
                Layout.fillWidth: true
            }
            Component.onCompleted: {
                setMarkerKeyButton.setSource("KeyInputButton.qml", { "text": "" });
            }
            Connections {
                target: setMarkerKeyButton.item
                function onToggleButtonsOff() { target.checked = false; }
                function onSetKey(keyCode) {
                    prompter.document.setKeyMarker(keyCode);
                    timer.start();
                }
            }
            Timer {
                id: timer
                running: false
                repeat: false
                interval: Units.LongDuration
                onTriggered: namedMarkerConfiguration.close()
            }
        }
    }

    //Kirigami.OverlaySheet {
        //id: stepsConfiguration
        //onSheetOpenChanged: {
            //prompterPage.actions.main.checked = sheetOpen;
            //if (!sheetOpen)
                //prompter.focus = true
        //}
        //background: Rectangle {
            ////color: Kirigami.Theme.activeBackgroundColor
            //color: appTheme.__backgroundColor
            //anchors.fill: parent
        //}
        //header: Kirigami.Heading {
            //text: i18n("Start Velocity")
            //level: 1
        //}

        //ColumnLayout {
            //width: parent.width
            //Label {
                //text: i18n("Velocity to have when starting to prompt")
            //}
            //RowLayout {
                //SpinBox {
                    //id: defaultSteps
                    //Layout.fillWidth: true
                    //Layout.leftMargin: Units.SmallSpacing
                    //Layout.rightMargin: Units.SmallSpacing
                    //value: __iDefault
                    //from: 1
                    //to: velocityControlSlider.to
                    //onValueModified: {
                        //__iDefault = value
                    //}
                //}
                //Button {
                    //visible: parseInt(prompter.state)===Prompter.States.Prompting && prompter.__velocity>0
                    //flat: true
                    //text: "Make current velocity default"
                    //onClicked: {
                        //defaultSteps.value = prompter.__i;
                        //__iDefault = prompter.__i;
                    //}
                //}
            //}
        //}
    //}
}
