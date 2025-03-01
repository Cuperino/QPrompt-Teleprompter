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
import QtCore 6.5
import Qt.labs.platform 1.1 as Labs

import com.cuperino.qprompt 1.0

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
    property alias networkDialog: networkDialog
    property alias prompterBackground: viewport.prompterBackground
    property alias find: viewport.find
    property alias keyConfigurationOverlay: keyConfigurationOverlay
    property alias displaySettings: displaySettings
    property alias markersDrawer: markersDrawer
    property alias countdownConfiguration: countdownConfiguration
    property alias namedMarkerConfiguration: namedMarkerConfiguration
    property alias pointerConfiguration: pointerConfiguration
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

    actions: [
        Kirigami.Action {
            id: promptingButton
            text: qsTr("Start prompter")
            onTriggered: prompter.toggle()
        },
        Kirigami.Action {
            id: decreaseVelocityButton
            enabled: Kirigami.Settings.isMobile
            text: pageStack.globalToolBar.actualStyle === Kirigami.ApplicationHeaderStyle.None ? qsTr("Decrease velocity") : ""
            icon.source: Qt.application.layoutDirection === Qt.RightToLeft ? "../icons/go-next.svg" : "../icons/go-previous.svg"
            onTriggered: {
                if (parseInt(prompter.state) === Prompter.States.Prompting)
                    viewport.prompter.decreaseVelocity(false)
                else
                    prompter.goToPreviousMarker()
                viewport.prompter.focus = true;
            }
        },
        Kirigami.Action {
            id: increaseVelocityButton
            enabled: Kirigami.Settings.isMobile
            text: pageStack.globalToolBar.actualStyle === Kirigami.ApplicationHeaderStyle.None ? qsTr("Increase velocity") : ""
            icon.source: Qt.application.layoutDirection === Qt.RightToLeft ? "../icons/go-previous.svg" : "../icons/go-next.svg"
            onTriggered: {
                if (parseInt(prompter.state) === Prompter.States.Prompting)
                    viewport.prompter.increaseVelocity(false)
                else
                    prompter.goToNextMarker()
                viewport.prompter.restoreFocus()
            }
        },
        Kirigami.Action {
            id: readRegionButton
            text: qsTr("Reading region", "Reading region indicates where a talent should be reading from")
            //onTriggered: viewport.overlay.toggle()
            tooltip: qsTr("Change reading region placement", "Reading region indicates where a talent should be reading from")

            Kirigami.Action {
                id: readRegionTopButton
                icon.name: "go-up"
                icon.source: "../icons/go-up.svg"
                text: qsTr("Top", "Align reading region to top of prompter")
                enabled: parseInt(viewport.overlay.positionState)!==ReadRegionOverlay.PositionStates.Top
                tooltip: qsTr("Move reading region to the top, convenient for use with webcams")
                onTriggered: {
                    viewport.overlay.positionState = ReadRegionOverlay.PositionStates.Top
                    contextDrawer.close()
                    viewport.prompter.restoreFocus()
                }
            }
            Kirigami.Action {
                id: readRegionMiddleButton
                icon.name: "list-remove"
                icon.source: "../icons/list-remove.svg"
                text: qsTr("Middle", "Align reading region to vertical center of prompter")
                enabled: parseInt(viewport.overlay.positionState)!==ReadRegionOverlay.PositionStates.Middle
                tooltip: qsTr("Move reading region to the vertical center")
                onTriggered: {
                    viewport.overlay.positionState = ReadRegionOverlay.PositionStates.Middle
                    contextDrawer.close()
                    viewport.prompter.restoreFocus()
                }
            }
            Kirigami.Action {
                id: readRegionBottomButton
                icon.name: "go-down"
                icon.source: "../icons/go-down.svg"
                text: qsTr("Bottom", "Align reading region to bottom of prompter")
                enabled: parseInt(viewport.overlay.positionState)!==ReadRegionOverlay.PositionStates.Bottom
                tooltip: qsTr("Move reading region to the bottom")
                onTriggered: {
                    viewport.overlay.positionState = ReadRegionOverlay.PositionStates.Bottom
                    contextDrawer.close()
                    viewport.prompter.restoreFocus()
                }
            }
            Kirigami.Action {
                id: readRegionFreeButton
                icon.source: "../icons/empty.svg"
                text: qsTr("Free", "Refers to free placement. Enables drag and drop positioning of reading region.")
                enabled: parseInt(viewport.overlay.positionState)!==ReadRegionOverlay.PositionStates.Free
                tooltip: qsTr("Move reading region freely by dragging and dropping")
                onTriggered: {
                    viewport.overlay.positionState = ReadRegionOverlay.PositionStates.Free
                    contextDrawer.close()
                    viewport.prompter.restoreFocus()
                }
            }
            Kirigami.Action {
                id: readRegionCustomButton
                icon.name: "dialog-ok-apply"
                icon.source: "../icons/dialog-ok-apply.svg"
                text: qsTr("Custom", "Fix positioning of reading region to what was set in \"Free placement\" mode")
                enabled: parseInt(viewport.overlay.positionState)!==ReadRegionOverlay.PositionStates.Fixed
                tooltip: qsTr("Fix reading region to the position set using free placement mode")
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
                            icon.name: Qt.LeftToRight ? "go-next" : "go-previous";
                            icon.source: Qt.LeftToRight ? "../icons/go-next.svg" : "../icons/go-previous.svg"
                            onTriggered: viewport.overlay.toggleLinesInRegion(true)
                        },
                        Kirigami.Action {
                            icon.name: (Qt.LeftToRight ? "go-previous" : "go-next");
                            icon.source: Qt.LeftToRight ? "../icons/go-previous.svg" : "../icons/go-next.svg"
                            onTriggered: viewport.overlay.toggleLinesInRegion(false)
                        }
                    ]
                    onClicked: viewport.overlay.toggleLinesInRegion(false)
                    Label {
                        text: qsTr("Height: %1", "Height of reading region relative to single line height. E.g. Height: 2.5").arg(viewport.overlay.linesInRegion)
                    }
                }
            }
            // Commenting out because there's no way to hide an empty sub-menu in mobile interface and distinction between Normal and Auto is confusing.
            // Kirigami.Action {
            //     id: hideDecorationsButton
            //     text: ["osx"].indexOf(Qt.platform.os)!==-1 || enabled ? qsTr("Window frame") : qsTr("Prompter mode")
            //     enabled: !fullScreenPlatform
            //     visible: enabled
            //     tooltip: qsTr("Auto hide window decorations when not editing and read region is set to top")
            //     icon.name: enabled ? (hideDecorations===0 ? "window" : (hideDecorations===1 ? "draw-rectangle" : "gnumeric-object-rectangle")) : ""
            //     icon.source: enabled ? (hideDecorations===0 ? "../icons/window.svg" : (hideDecorations===1 ? "../icons/draw-rectangle.svg" : "../icons/gnumeric-object-rectangle.svg")) : ""
            //     Kirigami.Action {
            //         text: qsTr("Normal frame")
            //         tooltip: qsTr("Shows windows frame when in windowed mode")
            //         icon.name: "window"
            //         icon.source: "../icons/window.svg"
            //         enabled: parent.enabled && hideDecorations!==0
            //         visible: parent.enabled
            //         onTriggered: {
            //             hideDecorations = 0
            //             parent.text = text
            //         }
            //     }
            //     Kirigami.Action {
            //         text: qsTr("Auto hide")
            //         tooltip: qsTr("Auto hide window decorations when not editing and read region is set to top")
            //         icon.name: "draw-rectangle"
            //         icon.source: "../icons/draw-rectangle.svg"
            //         enabled: parent.enabled && hideDecorations!==1
            //         visible: parent.enabled
            //         onTriggered: {
            //             hideDecorations = 1
            //             parent.text = text
            //         }
            //     }
            //     Kirigami.Action {
            //         text: qsTr("Always hidden")
            //         tooltip: qsTr("Always hide window decorations")
            //         icon.name: "gnumeric-object-rectangle"
            //         icon.source: "../icons/gnumeric-object-rectangle.svg"
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

            text: qsTr("Indicators", "Indicators highlight reading region")
            tooltip: qsTr("Change reading region indicators", "Indicators highlight reading region")

            Kirigami.Action {
                text: qsTr("Pointer Configuration", "Configure reading region pointer indicators")
                onTriggered: {
                    pointerConfiguration.open()
                }
            }
            Kirigami.Action {
                id: readRegionLeftPointerButton
                text: Qt.application.layoutDirection===Qt.LeftToRight ? qsTr("Left pointer", "Shows pointer to the left of the reading region") : qsTr("Right pointer", "Shows pointer to the right of the reading region")
                icon.source: Qt.application.layoutDirection===Qt.LeftToRight ? "../icons/go-next.svg" : "../icons/go-previous.svg"
                tooltip: qsTr("Left pointer indicates reading region")
                enabled: parseInt(overlay.styleState)!==ReadRegionOverlay.PointerStates.LeftPointer && parseInt(overlay.styleState)!==ReadRegionOverlay.PointerStates.BarsLeftPointer
                onTriggered: {
                    overlay.styleState = readRegionBarsButton.checked ? ReadRegionOverlay.PointerStates.BarsLeft : ReadRegionOverlay.PointerStates.LeftPointer
                    contextDrawer.close()
                    viewport.prompter.restoreFocus()
                }
            }
            Kirigami.Action {
                id: readRegionRightPointerButton
                text: Qt.application.layoutDirection===Qt.LeftToRight ? qsTr("Right pointer", "Shows pointer to the right of the reading region") : qsTr("Left pointer", "Shows pointer to the left of the reading region")
                icon.source: Qt.application.layoutDirection===Qt.LeftToRight ? "../icons/go-previous.svg" : "../icons/go-next.svg"
                tooltip: qsTr("Right pointer indicates reading region")
                enabled: parseInt(overlay.styleState)!==ReadRegionOverlay.PointerStates.RightPointer && parseInt(overlay.styleState)!==ReadRegionOverlay.PointerStates.BarsRightPointer
                onTriggered: {
                    overlay.styleState = readRegionBarsButton.checked ? ReadRegionOverlay.PointerStates.BarsRight : ReadRegionOverlay.PointerStates.RightPointer
                    contextDrawer.close()
                    viewport.prompter.restoreFocus()
                }
            }
            Kirigami.Action {
                id: readRegionPointersButton
                text: qsTr("Both pointers", "Shows pointers to the left and right of the reading region")
                icon.source: "../icons/transform-move-horizontal.svg"
                tooltip: qsTr("Left and right pointers indicate reading region")
                enabled: parseInt(overlay.styleState)!==ReadRegionOverlay.PointerStates.Pointers && parseInt(overlay.styleState)!==ReadRegionOverlay.PointerStates.All
                onTriggered: {
                    overlay.styleState = readRegionBarsButton.checked ? ReadRegionOverlay.PointerStates.All : ReadRegionOverlay.PointerStates.Pointers
                    contextDrawer.close()
                    viewport.prompter.restoreFocus()
                }
            }
            Kirigami.Action {
                id: readRegionNoneButton
                text: qsTr("No pointers", "Disable all reading region pointers")
                icon.source: Qt.application.layoutDirection===Qt.LeftToRight ? "../icons/view-list-text.svg" : "../icons/view-list-text-rtl.svg"
                tooltip: qsTr("Disable reading region indicators", "Disable all reading region indicators")
                enabled: parseInt(overlay.styleState)!==ReadRegionOverlay.PointerStates.None && parseInt(overlay.styleState)!==ReadRegionOverlay.PointerStates.Bars
                onTriggered: {
                    overlay.styleState = readRegionBarsButton.checked ? ReadRegionOverlay.PointerStates.Bars : ReadRegionOverlay.PointerStates.None
                    contextDrawer.close()
                    viewport.prompter.restoreFocus()
                }
            }
            Kirigami.Action {
                id: readRegionBarsButton
                text: qsTr("Bars", "Configure reading region pointer indicators")
                checkable: true
                checked: parseInt(overlay.styleState)>ReadRegionOverlay.PointerStates.Pointers
                onTriggered: {
                    if (parseInt(overlay.styleState)>ReadRegionOverlay.PointerStates.Pointers)
                        overlay.styleState = parseInt(overlay.styleState) - 4;
                    else
                        overlay.styleState = parseInt(overlay.styleState) + 4;
                }
            }
        },
        Kirigami.Action {
            id: timerButton
            text: qsTr("Timer")
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
                text: qsTr("Enable timers")
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
                icon.name: "keyframe"
                icon.source: "../icons/keyframe.svg"
                text: qsTr("Stopwatch")
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
                icon.name: "player-time"
                icon.source: "../icons/player-time.svg"
                text: qsTr("ETA", "Estimated Time of Arrival")
                onTriggered: {
                    viewport.timer.eta = checked
                    viewport.prompter.restoreFocus()
                }
            }
            Kirigami.Action {
                id: timerColorButton
                enabled: viewport.timer.timersEnabled
                text: qsTr("Timer color", "Color of timer text")
                icon.name: "format-text-color"
                icon.source: "../icons/format-text-color.svg"
                onTriggered: {
                    viewport.timer.setColor()
                    contextDrawer.close()
                    viewport.prompter.restoreFocus()
                }
            }
            Kirigami.Action {
                id: clearTimerColorButton
                enabled: viewport.timer.timersEnabled && !Qt.colorEqual(viewport.timer.textColor, '#AAA')
                text: qsTr("Clear color", "Reset color of timer text back to default")
                icon.name: "tool_color_eraser"
                icon.source: "../icons/tool_color_eraser.svg"
                onTriggered: {
                    viewport.timer.clearColor()
                    contextDrawer.close()
                    viewport.prompter.restoreFocus()
                }
            }
        },
        Kirigami.Action {
            id: countdownConfigButton
            text: qsTr("Countdown")
            Kirigami.Action {
                id: enableFramingButton
                enabled: !autoStartCountdownButton.checked
                checkable: true
                checked: viewport.countdown.frame && !autoStartCountdownButton.checked
                text: qsTr("Auto frame", "Enables automatic alignment of prompter and text with the reading region")
                icon.name: "transform-move-vertical"
                icon.source: "../icons/transform-move-vertical.svg"
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
                text: qsTr("Countdown")
                icon.name: "chronometer-pause"
                icon.source: "../icons/chronometer-pause.svg"
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
                text: qsTr("Auto start", "Auto start countdown upon prompter getting started")
                icon.name: "chronometer"
                icon.source: "../icons/chronometer.svg"
                tooltip: qsTr("Start countdown automatically")
                onTriggered: {
                    viewport.countdown.autoStart = !viewport.countdown.autoStart
                    // contextDrawer.close()
                    viewport.prompter.restoreFocus()
                }
            }
            Kirigami.Action {
                id: setCountdownButton
                enabled: enableCountdownButton.enabled && viewport.countdown.enabled
                text: qsTr("Set duration", "Configure countdown duration")
                icon.name: "keyframe-add"
                icon.source: "../icons/keyframe-add.svg"
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
                //icon.name = context.icon.name
            }

            text: qsTr("Orientation", "Prompter orientation and mirroring")

            //Kirigami.Action {
                //readonly property string shortName: qsTr("No Flip")
                //text: qsTr("No flip")
                //icon.name: "window"
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
                //readonly property string shortName: qsTr("H Flip")
                text: qsTr("Horizontal mirror", "Mirrors prompter horizontally")
                //icon.name: "object-flip-horizontal"
                //icon.source: "../icons/object-flip-horizontal.svg"
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
                //readonly property string shortName: qsTr("V Flip")
                text: qsTr("Vertical mirror", "Mirrors prompter vertically")
                //icon.name: "object-flip-vertical"
                //icon.source: "../icons/object-flip-vertical.svg"
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
                //readonly property string shortName: qsTr("HV Flip") text: qsTr("180° rotation")
                //icon.name: Qt.LeftToRight ? "object-rotate-left" : "object-rotate-right"
                //icon.source: Qt.LeftToRight ? "../icons/object-rotate-left.svg" : "../icons/object-rotate-right.svg"
                //enabled: !(viewport.prompter.__flipX && viewport.prompter.__flipY)
                //onTriggered: {
                    //parent.updateButton(this)
                    //viewport.prompter.__flipX = true
                    //viewport.prompter.__flipY = true
                    //contextDrawer.close()
                //}
            //}
            Kirigami.Action {
                text: qsTr("Don't rotate", "Prompter rotation is disabled")
                icon.name: "window"
                icon.source: "../icons/window.svg"
                enabled: viewport.forcedOrientation!==0
                onTriggered: {
                    //if (viewport.forcedOrientation!==1)
                    viewport.forcedOrientation = 0
                    contextDrawer.close()
                    viewport.prompter.restoreFocus()
                }
            }
            Kirigami.Action {
                text: qsTr("90° clockwise", "Rotate prompter 90 degrees to the right")
                icon.name: "object-rotate-right"
                icon.source: "../icons/object-rotate-right.svg"
                enabled: viewport.forcedOrientation!==1
                onTriggered: {
                    //if (viewport.forcedOrientation!==1)
                    viewport.forcedOrientation = 1
                    contextDrawer.close()
                    viewport.prompter.restoreFocus()
                }
            }
            Kirigami.Action {
                text: qsTr("90° counter", "Rotate prompter 90 degrees to the left")
                icon.name: "object-rotate-left"
                icon.source: "../icons/object-rotate-left.svg"
                enabled: viewport.forcedOrientation!==2
                onTriggered: {
                    //if (viewport.forcedOrientation!==2)
                    viewport.forcedOrientation = 2
                    contextDrawer.close()
                    viewport.prompter.restoreFocus()
                }
            }
            //Kirigami.Action {
                //text: qsTr("Inverted")
                //icon.name: Qt.LeftToRight ? "object-rotate-left" : "object-rotate-right"
                //icon.source: Qt.LeftToRight ? "../icons/object-rotate-left.svg" : "../icons/object-rotate-right.svg"
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
            text: qsTr("Background", "Background refers to what appears behind the prompter")
            Kirigami.Action {
                id: prompterShadowsButton
                text: qsTr("Shadows", "Enable root.shadows")
                checkable: true
                checked: root.shadows
                onTriggered: {
                    root.shadows = checked
                }
            }
            Kirigami.Action {
                id: changeBackgroundImageButton
                text: qsTr("Set image", "Set background image")
                icon.name: "insert-image"
                icon.source: "../icons/insert-image.svg"
                onTriggered: {
                    prompterBackground.loadBackgroundImage()
                    contextDrawer.close()
                    viewport.prompter.restoreFocus()
                }
            }
            Kirigami.Action {
                id: changeBackgroundColorButton
                text: qsTr("Set color", "Set background color tint")
                icon.name: "fill-color"
                icon.source: "../icons/fill-color.svg"
                onTriggered: {
                    prompterBackground.backgroundColorDialog.open()
                    contextDrawer.close()
                    viewport.prompter.restoreFocus()
                }
            }
            Kirigami.Action {
                id: clearBackgroundButton
                text: qsTr("Clear", "Set background settings back to default")
                enabled: prompterBackground.hasBackground
                icon.name: "tool_color_eraser"
                icon.source: "../icons/tool_color_eraser.svg"
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
            text: qsTr("Screens", "Screens refers to computer displays")

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
                                icon.name: switch (flipSetting) {
                                    case 0 : return "window";
                                    case 1 : return "window-duplicate";
                                    case 2 : return "object-flip-horizontal";
                                    case 3 : return "object-flip-vertical";
                                    case 4 : return (Qt.LeftToRight ? "object-rotate-left" : "object-rotate-right");
                                }
                                icon.source: switch (flipSetting) {
                                    case 0 : return "../icons/window.svg";
                                    case 1 : return "../icons/window-duplicate.svg";
                                    case 2 : return "../icons/object-flip-horizontal.svg";
                                    case 3 : return "../icons/object-flip-vertical.svg";
                                    case 4 : return (Qt.LeftToRight ? "../icons/object-rotate-left.svg" : "../icons/object-rotate-right.svg");
                                }
                                onTriggered: toggleDisplayFlip()
                            }
                        ]
                        onClicked: toggleDisplayFlip()
                        Label {
                            text: switch (flipSetting) {
                                case 0 : return display.name + " : " + qsTr("Off", "Screen is disabled");
                                case 1 : return display.name + " : " + qsTr("No Mirror", "Screen is enabled but mirroring is disabled");
                                case 2 : return display.name + " : " + qsTr("H Mirror", "Horizontal mirroring");
                                case 3 : return display.name + " : " + qsTr("V Mirror", "Vertical mirroring");
                                case 4 : return display.name + " : " + qsTr("HV Mirror", "Horizontal and vertical mirroring");
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
                text: qsTr("Enable projection", "Display prompter copies onto displays")
                //tooltip: qsTr("Display prompter copies onto extended displays")
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
                text: qsTr("Scale projection", "Enable scaling prompter copies being projected onto displays")
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
        //    text: qsTr("Debug")
        //    tooltip: qsTr("Debug Action")
        //    onTriggered: {
        //        console.log("Debug Action")
        //        prompterPage.test( true )
        //        viewport.prompter.restoreFocus()
        //    }
        //},
        Kirigami.Action {
            id: fullscreenButton
            visible: !fullScreenPlatform
            text: root.__fullScreen ? qsTr("Leave Fullscreen") : qsTr("Fullscreen")
            onTriggered: {
                root.__fullScreen = !root.__fullScreen
                contextDrawer.close()
                viewport.prompter.restoreFocus()
            }
        }
    ]

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
        height: (forcedOrientation && forcedOrientation!==3 ? parent.width : (root.theforce && !forcedOrientation ? 3 : 1) * parent.height) // + (Kirigami.Settings.isMobile ? 68 : 0)
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

    Labs.ColorDialog {
        id: colorDialog
        options: Labs.ColorDialog.ShowAlphaChannel
        onVisibleChanged: {
            if (visible)
                cursorAutoHide.reset();
            else
                cursorAutoHide.restart();
        }
    }

    Labs.ColorDialog {
        id: highlightDialog
        options: Labs.ColorDialog.ShowAlphaChannel
        onVisibleChanged: {
            if (visible)
                cursorAutoHide.reset();
            else
                cursorAutoHide.restart();
        }
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

        header: Kirigami.Heading {
            text: qsTr("Countdown Setup")
            level: 1
        }

        RowLayout {
            width: parent.width

            ColumnLayout {
                Label {
                    text: qsTr("Countdown duration")
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
                    text: qsTrp("Disappear within %1 second(s) to go", "", countdown.__disappearWithin);
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
        width: 300
        header: Kirigami.Heading {
            text: qsTr("Skip Key", "Refers to a key on the keyboard used to skip to a user defined marker while prompting")
            level: 1
        }
        onOpened: {
            // When opening overlay, reset key input button's text.
            // Dev: When opening overlay, reset key input button's text to current anchor's key value.
            //row.setMarkerKeyButton.item.text = "";
            column.setMarkerKeyButton.item.text = prompter.document.getMarkerKey();
        }
        onClosed: {
            prompter.restoreFocus();
            if (markersDrawer.reOpen) {
                prompter.document.parse();
                markersDrawer.open();
            }
        }
        ColumnLayout {
            id: column
            property alias setMarkerKeyButton: setMarkerKeyButton
            width: parent.width
            Label {
                text: qsTr("Key to perform skip to this marker", "Refers to a key on the keyboard used to skip to a user defined marker while prompting")
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

    Settings {
        category: "networkDialog"
        property alias url: openUrl.text
        property alias autoReload: networkDialog.autoReload
        property alias autoReloadHours: autoReloadHours.value
        property alias autoReloadMinutes: autoReloadMinutes.value
        property alias autoReloadSeconds: autoReloadSeconds.value
    }
    Timer {
        id: autoReloadTimer
        running: networkDialog.autoReloadRunning
        repeat: true
        triggeredOnStart: false
        interval: 1000 * (3600 * autoReloadHours.value + 60 * autoReloadMinutes.value + autoReloadSeconds.value)
        onTriggered: networkDialog.openFromRemote();
    }
    Kirigami.OverlaySheet {
        id: networkDialog
        header: Kirigami.Heading {
            text: qsTr("Open from network...")
            level: 1
        }
        property bool autoReload: false
        property bool autoReloadRunning: false
        property string nextReloadTime: ""
        function updateNextReloadTime() {
            const date = new Date();
            date.setTime(date.getTime() + autoReloadTimer.interval);
            nextReloadTime = date.toLocaleTimeString();
        }
        function openFromRemote() {
            document.loadFromNetwork(openUrl.text);
            if (!autoReloadRunning)
                editor.lastDocument = ""
            if (autoReload) {
                autoReloadRunning = true;
                updateNextReloadTime();
            }
        }
        function disableAutoReload() {
            networkDialog.autoReloadRunning = false;
        }
        ColumnLayout {
            width: parent.width
            RowLayout {
                Label {
                    text: qsTr("URL:")
                }
                TextField {
                    id: openUrl
                    placeholderText: qsTr("http, https, and ftp protocols supported")
                    Layout.fillWidth: true
                    Layout.leftMargin: Kirigami.Units.smallSpacing
                    Layout.rightMargin: Kirigami.Units.smallSpacing
                    onAccepted: networkDialog.openFromRemote()
                }
            }
            RowLayout {
                Button {
                    id: autoReloadToggle
                    text: qsTr("Auto reload")
                    checkable: true
                    checked: networkDialog.autoReload
                    onToggled: {
                        networkDialog.autoReload = checked;
                        if (!checked)
                            networkDialog.disableAutoReload();
                    }
                    Material.theme: Material.Dark
                }
                Label {
                    text: qsTr("Hours:")
                }
                SpinBox {
                    id: autoReloadHours
                    Layout.fillWidth: true
                    Layout.leftMargin: Kirigami.Units.SmallSpacing
                    Layout.rightMargin: Kirigami.Units.SmallSpacing
                    enabled: networkDialog.autoReload
                    value: 0
                    to: 168
                    onValueModified: {
                        if (value === to) {
                            autoReloadMinutes.value = 0;
                            autoReloadSeconds.value = 0;
                        }
                        // Since this onValueModified will get called regardless of which SpinBox gets modified, this is where and when we update the nextReloadTime
                        networkDialog.updateNextReloadTime();
                    }
                }
                Label {
                    text: qsTr("Minutes:")
                }
                SpinBox {
                    id: autoReloadMinutes
                    Layout.fillWidth: true
                    Layout.leftMargin: Kirigami.Units.SmallSpacing
                    Layout.rightMargin: Kirigami.Units.SmallSpacing
                    enabled: networkDialog.autoReload
                    value: 5
                    from: value>0 || autoReloadMinutes.value>0 || autoReloadHours.value>0 ? -1 : 0
                    to: /*autoReloadHours.value===autoReloadHours.to ? 0 :*/ 60
                    onValueModified: {
                        if (value < 0) {
                            value = 59;
                            --autoReloadHours.value;
                        }
                        else if (value > 59) {
                            value = 0;
                            ++autoReloadHours.value;
                        }
                        autoReloadHours.onValueModified();
                    }
                }
                Label {
                    text: qsTr("Seconds:")
                }
                SpinBox {
                    id: autoReloadSeconds
                    Layout.fillWidth: true
                    Layout.leftMargin: Kirigami.Units.SmallSpacing
                    Layout.rightMargin: Kirigami.Units.SmallSpacing
                    enabled: networkDialog.autoReload
                    value: 0
                    from: value>0 || autoReloadMinutes.value>0 || autoReloadHours.value>0 ? -1 : 1
                    to: /*autoReloadHours.value===autoReloadHours.to ? 0 :*/ 60
                    onValueModified: {
                        if (value < 0) {
                            value = 59;
                            --autoReloadMinutes.value;
                        }
                        else if (value > 59) {
                            value = 0;
                            ++autoReloadMinutes.value;
                        }
                        autoReloadMinutes.onValueModified();
                    }
                }
            }
            RowLayout {
                Label {
                    text: autoReloadTimer.running ?
                              qsTr("Next reload starts at %1", "Next reload starts at 10:11:12").arg(networkDialog.nextReloadTime)
                            : qsTr("Auto reload is not running")
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }
                Button {
                    enabled: openUrl.text !== ""
                    text: qsTr("Load from Network")
                    onClicked: {
                        networkDialog.openFromRemote();
                        networkDialog.close();
                    }
                    Material.theme: Material.Dark
                }
                Button {
                    text: qsTr("Close")
                    onClicked: {
                        networkDialog.close();
                        viewport.prompter.restoreFocus();
                    }
                    Material.theme: Material.Dark
                }
            }
        }
    }

    Kirigami.OverlaySheet {
        id: pointerConfiguration
        header: Kirigami.Heading {
            text: qsTr("Pointer configuration", "Name of section where reding region pointers are configured")
            level: 1
        }
        PointerSettings{
            id: pointerSettings
        }
    }

    //Kirigami.OverlaySheet {
        //id: stepsConfiguration
        //onSheetOpenChanged: {
            //if (!sheetOpen)
                //prompter.focus = true
        //}
        //background: Rectangle {
            ////color: Kirigami.Theme.activeBackgroundColor
            //color: appTheme.__backgroundColor
            //anchors.fill: parent
        //}
        //header: Kirigami.Heading {
            //text: qsTr("Start Velocity")
            //level: 1
        //}

        //ColumnLayout {
            //width: parent.width
            //Label {
                //text: qsTr("Velocity to have when starting to prompt")
            //}
            //RowLayout {
                //SpinBox {
                    //id: defaultSteps
                    //Layout.fillWidth: true
                    //Layout.leftMargin: Kirigami.Units.SmallSpacing
                    //Layout.rightMargin: Kirigami.Units.SmallSpacing
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
