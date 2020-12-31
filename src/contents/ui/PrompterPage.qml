/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2020 Javier O. Cordero Pérez
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
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import Qt.labs.platform 1.1

Kirigami.ScrollablePage {
    id: prompterPage
    property alias italic: prompter.italic
    //anchors.fill: parent
    title: "QPrompt"
    actions {
        main: Kirigami.Action {
            id: promptingButton
            text: i18n("Start prompting")
            iconName: Qt.application.layoutDirection === Qt.RightToLeft ? "go-previous" : "go-next"
            onTriggered: prompter.toggle()
        }
        left: Kirigami.Action {
            id: decreaseVelocityButton
            enabled: false
            text: pageStack.globalToolBar.actualStyle === Kirigami.ApplicationHeaderStyle.None ? i18n("Decrease velocity") : ""
            iconName: Qt.application.layoutDirection === Qt.RightToLeft ? "go-next" : "go-previous"
            onTriggered: prompter.decreaseVelocity(false)
        }
        right: Kirigami.Action {
            id: increaseVelocityButton
            enabled: false
            text: pageStack.globalToolBar.actualStyle === Kirigami.ApplicationHeaderStyle.None ? i18n("Increase velocity") : ""
            iconName: Qt.application.layoutDirection === Qt.RightToLeft ? "go-previous" : "go-next"
            onTriggered: prompter.increaseVelocity(false)
        }
        // Use action toolbar instead?
        //ActionToolBar
        contextualActions: [
        Kirigami.Action {
            id: wysiwygButton
            text: i18n("WYSIWYG")
            checkable: true
            checked: prompter.__wysiwyg
            tooltip: prompter.__wysiwyg ? i18n("\"What you see is what you get\" mode is On") : i18n("\"What you see is what you get\" mode Off")
            onTriggered: {
                prompter.__wysiwyg = !prompter.__wysiwyg
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
                iconName: "refresh"
                readonly property string shortName: "No Flip"
                onTriggered: {
                    parent.updateButton(this)
                    prompter.__flipX = false
                    prompter.__flipY = false
                }
                enabled: prompter.__flipX || prompter.__flipY
            }
            Kirigami.Action {
                text: i18n("Horizontal Flip")
                iconName: "refresh"
                readonly property string shortName: "H Flip"
                onTriggered: {
                    parent.updateButton(this)
                    prompter.__flipX = true
                    prompter.__flipY = false
                }
                enabled: (!prompter.__flipX) || prompter.__flipY
            }
            Kirigami.Action {
                text: i18n("Vertical Flip")
                iconName: "refresh"
                readonly property string shortName: "V Flip"
                onTriggered: {
                    parent.updateButton(this)
                    prompter.__flipX = false
                    prompter.__flipY = true
                }
                enabled: prompter.__flipX || !prompter.__flipY
            }
            Kirigami.Action {
                text: i18n("180° rotation")
                iconName: "refresh"
                readonly property string shortName: "HV Flip"
                onTriggered: {
                    parent.updateButton(this)
                    prompter.__flipX = true
                    prompter.__flipY = true
                }
                enabled: !(prompter.__flipX && prompter.__flipY)
            }
        },
        Kirigami.Action {
            id: readRegionButton
            text: i18n("Reading region")
            //onTriggered: overlay.toggle()
            tooltip: i18n("Change reading region placement")
            
            Kirigami.Action {
                id: readRegionTopButton
                iconName: "go-up"
                text: i18n("Top")
                onTriggered: overlay.positionState = "top"
                enabled: overlay.positionState!=="top"
                tooltip: i18n("Move reading region to the top, convenient for use with webcams")
            }
            Kirigami.Action {
                id: readRegionMiddleButton
                iconName: "remove"
                text: i18n("Middle")
                onTriggered: overlay.positionState = "middle"
                enabled: overlay.positionState!=="middle"
                tooltip: i18n("Move reading region to the vertical center")
            }
            Kirigami.Action {
                id: readRegionBottomButton
                iconName: "go-down"
                text: i18n("Bottom")
                onTriggered: overlay.positionState = "bottom"
                enabled: overlay.positionState!=="bottom"
                tooltip: i18n("Move reading region to the bottom")
            }
            Kirigami.Action {
                id: readRegionFreeButton
                iconName: "gtk-edit"
                text: i18n("Free")
                onTriggered: overlay.positionState = "free"
                enabled: overlay.positionState!=="free"
                tooltip: i18n("Move reading region freely by dragging and dropping")
            }
            Kirigami.Action {
                id: readRegionCustomButton
                iconName: "gtk-apply"
                text: i18n("Custom")
                onTriggered: overlay.positionState = "fixed"
                enabled: overlay.positionState!=="fixed"
                tooltip: i18n("Fix reading region to the position set using free placement mode")
            }
        },
        Kirigami.Action {
            id: readRegionStyleButton
            text: i18n("Pointers")
            tooltip: i18n("Change pointers that indicate reading region")
            
            Kirigami.Action {
                id: readRegionTrianglesButton
                text: i18n("Triangles")
                onTriggered: overlay.styleState = "triangles"
                tooltip: i18n("Mark reading area using bars")
                enabled: overlay.styleState!=="triangles"
            }
            Kirigami.Action {
                id: readRegionLeftTriangleButton
                text: i18n("Left Triangle")
                onTriggered: overlay.styleState = "leftTriangle"
                tooltip: i18n("Left triangle points towards reading region")
                enabled: overlay.styleState!=="leftTriangle"
            }
            Kirigami.Action {
                id: readRegionRightTriangleButton
                text: i18n("Right Triangle")
                onTriggered: overlay.styleState = "rightTriangle"
                tooltip: i18n("Right triangle points towards reading region")
                enabled: overlay.styleState!=="rightTriangle"
            }
            Kirigami.Action {
                id: readRegionBarsButton
                text: i18n("Bars")
                onTriggered: overlay.styleState = "bars"
                tooltip: i18n("Mark reading region using translucent bars")
                enabled: overlay.styleState!=="bars"
            }
            Kirigami.Action {
                id: readRegionBarsLeftButton
                text: i18n("Bars && Left Triangle")
                onTriggered: overlay.styleState = "barsLeft"
                tooltip: i18n("Mark reading region using translucent bars and left triangle")
                enabled: overlay.styleState!=="barsLeft"
            }
            Kirigami.Action {
                id: readRegionBarsRightButton
                text: i18n("Bars && Right Triangle")
                onTriggered: overlay.styleState = "barsRight"
                tooltip: i18n("Mark reading region using translucent bars and right triangle")
                enabled: overlay.styleState!=="barsRight"
            }
            Kirigami.Action {
                id: readRegionAllButton
                text: i18n("All")
                onTriggered: overlay.styleState = "all"
                tooltip: i18n("Use triangles to point towards reading region")
                enabled: overlay.styleState!=="all"
            }
            Kirigami.Action {
                id: readRegionNoneButton
                text: i18n("None")
                onTriggered: overlay.styleState = "none"
                tooltip: i18n("Disable reading region entirely")
                enabled: overlay.styleState!=="none"
            }
        },
        Kirigami.Action {
            id: loadBackgroundButton
            text: i18n("Background")
            
            Kirigami.Action {
                id: changeBackgroundImageButton
                text: i18n("Set Image")
                onTriggered: appTheme.loadBackgroundImage()
            }
            Kirigami.Action {
                id: changeBackgroundColorButton
                text: i18n("Set Color")
                onTriggered: backgroundColorDialog.open()
            }
            Kirigami.Action {
                id: clearBackgroundButton
                text: i18n("Clear Background")
                enabled: appTheme.hasBackground
                onTriggered: appTheme.clearBackground()
            }
        }
        //Kirigami.Action {
        //    id: countdownConfigButton
        //    text: i18n("Countdown")
        //    tooltip: i18n("Set countdown timer")
        //    //onTriggered: 
        //}//,
        //Kirigami.Action {
        //    id: projectionConfigButton
        //    text: i18n("Clone")
        //    tooltip: i18n("Duplicate teleprompter contents into separate screens")
        //    onTriggered: projectionWindow.visible = !projectionWindow.visible
        //}
        ]
    }
    
    Countdown {
        id: countdown
        z: 3
    }
    
    ReadRegionOverlay {
        id: overlay
        z: 1
    }
    
    //TimerClock {
    //id: timer
    //z: 4
    //}
    
    Prompter {
        id: prompter
        z: 0
    }
    
    // Editor Toolbar
    footer: ToolBar {
        id: toolbar
        enabled: visibility!==Kirigami.ApplicationWindow.FullScreen
        height: enabled ? implicitHeight : 0
        background: Rectangle {
            color: appTheme.__backgroundColor
        }
        GridLayout {
            anchors.fill: parent
            columns: width / bookmarkToggleButton.implicitWidth - 1
            ToolButton {
                id: bookmarkToggleButton
                //text: i18n("Bookmark")
                icon.name: "bookmarks"
                icon.color: appTheme.__iconColor
                onClicked: prompter.bookmark()
            }
            ToolButton {
                //text: i18n("Undo")
                icon.name: "edit-undo"
                icon.color: appTheme.__iconColor
                onClicked: prompter.undo()
            }
            ToolButton {
                //text: i18n("Redo")f
                icon.name: "edit-redo"
                icon.color: appTheme.__iconColor
                onClicked: prompter.redo()
            }
            ToolButton {
                //text: i18n("&Copy")
                icon.name: "edit-copy"
                icon.color: appTheme.__iconColor
                onClicked: prompter.copy()
            }
            ToolButton {
                //text: i18n("Cut")
                icon.name: "edit-cut"
                icon.color: appTheme.__iconColor
                onClicked: prompter.cut()
            }
            ToolButton {
                //text: i18n("&Paste")
                icon.name: "edit-paste"
                icon.color: appTheme.__iconColor
                onClicked: prompter.paste()
            }
            ToolButton {
                //text: i18n("&Bold")
                icon.name: "gtk-bold"
                icon.color: appTheme.__iconColor
                onClicked: prompter.bold = !prompter.bold
            }
            ToolButton {
                //text: i18n("&Italic")
                icon.name: "gtk-italic"
                icon.color: appTheme.__iconColor
                onClicked: prompter.italic = !prompter.italic
            }
            ToolButton {
                //Text {
                //text: i18n("Underline")
                //color: appTheme.__iconColor
                //anchors.fill: parent
                //fontSizeMode: Text.Fit
                //horizontalAlignment: Text.AlignHCenter
                //verticalAlignment: Text.AlignVCenter
                //}
                //text: i18n("&Underline")
                icon.name: "gtk-underline"
                icon.color: appTheme.__iconColor
                onClicked: prompter.underline = !prompter.underline
            }
            ToolButton {
                //text: i18n("&Left")
                icon.name: "gtk-justify-left"
                icon.color: appTheme.__iconColor
                onClicked: prompter.alignment = Text.AlignLeft
            }
            ToolButton {
                //text: i18n("&Center")
                icon.name: "gtk-justify-center"
                icon.color: appTheme.__iconColor
                onClicked: prompter.alignment = Text.AlignHCenter
            }
            ToolButton {
                //text: i18n("&Right")
                icon.name: "gtk-justify-right"
                icon.color: appTheme.__iconColor
                onClicked: prompter.alignment = Text.AlignRight
            }
        }
    }
    
    //Kirigami.OverlaySheet {
    //id: sheet
    //onSheetOpenChanged: page.actions.main.checked = sheetOpen
    //Label {
    //wrapMode: Text.WordWrap
    //text: "Lorem ipsum dolor sit amet"
    //}
    //}
    
    function openFile() {
        openDialog.open()
    }
    
    FileDialog {
        id: openDialog
        fileMode: FileDialog.OpenFile
        selectedNameFilter.index: 1
        nameFilters: ["Text files (*.txt)", "HTML files (*.html *.htm)"]
        folder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
        onAccepted: prompter.load(file)
    }
    
    FileDialog {
        id: saveDialog
        fileMode: FileDialog.SaveFile
        defaultSuffix: prompter.fileType
            nameFilters: openDialog.nameFilters
            selectedNameFilter.index: prompter.fileType === "txt" ? 0 : 1
            folder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
            onAccepted: prompter.saveAs(file)
    }
    
    // Prompter Page Component {
    Component {
        id: projectionWindow
        ProjectionWindow {}
    }

}
