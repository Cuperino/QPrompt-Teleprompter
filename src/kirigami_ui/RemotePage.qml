/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2021 Javier O. Cordero Pérez
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

Kirigami.Page {
    id: prompterPage
    
    title: "Remote Control"
    globalToolBarStyle: Kirigami.ApplicationHeaderStyle.ToolBar
    // padding: 0
    
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
            
            //Kirigami.Action {
                //id: changeBackgroundImageButton
                //text: i18n("Set Image")
                //onTriggered: prompterBackground.loadBackgroundImage()
            //}
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
                id: enableCountdownButton
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
                enabled: viewport.countdown.enabled
                checkable: true
                checked: viewport.countdown.autoStart
                text: i18n("Auto Countdown")
                tooltip: i18n("Start countdown automatically")
                onTriggered: viewport.countdown.autoStart = !viewport.countdown.autoStart
            }
            Kirigami.Action {
                id: setCountdownButton
                enabled: viewport.countdown.enabled
                text: i18n("Set Duration")
                onTriggered: {
                    viewport.countdown.configuration.open()
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
        //anchors.bottomMargin: Kirigami.Settings.isMobile ? -68 : 0
        property alias toolbar: editorToolbar
    }
    
    progress: 1

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

    // Editor Toolbar
    //footer: EditorToolbar {
        //id: editorToolbar
    //}
}
