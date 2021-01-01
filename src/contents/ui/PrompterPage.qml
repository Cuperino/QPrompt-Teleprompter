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
        textColor: colorDialog.color
    }
    
    FontDialog {
        id: fontDialog
        options: FontDialog.ScalableFonts|FontDialog.MonospacedFonts|FontDialog.ProportionalFonts
        onAccepted: {
            prompter.fontFamily = font.family;
            prompter.fontSize = font.pointSize*prompter.font.pixelSize/6;
        }
    }
    
    ColorDialog {
        id: colorDialog
        currentColor: appTheme.__fontColor
        
    }
    
    // Editor Toolbar
    footer: ToolBar {
        id: toolbar
        enabled: visibility!==Kirigami.ApplicationWindow.FullScreen
        height: enabled ? implicitHeight : 0
        background: Rectangle {
            color: appTheme.__backgroundColor
        }
        Flow {
            id: flow
            anchors.fill: parent
            Row {
                id: anchorsRow
                
                ToolButton {
                    id: bookmarkToggleButton
                    //text: "\u2605" // icon-docs
                    //contentItem: Text {
                        //text: parent.text
                        //font: parent.font
                        //color: parent.down ? appTheme.__fontColor : appTheme.__iconColor
                        //horizontalAlignment: Text.AlignHCenter
                        //verticalAlignment: Text.AlignVCenter
                        //elide: Text.ElideRight
                    //}
                    //font.family: "fontello"
                    icon.name: "bookmarks"
                    icon.color: down ? appTheme.__fontColor : appTheme.__iconColor
                    focusPolicy: Qt.TabFocus
                    onClicked: prompter.bookmark()
                }
                ToolSeparator {
                    contentItem.visible: anchorsRow.y === undoRedoRow.y
                }
            }
            Row {
                id: undoRedoRow
                ToolButton {
                    //text: "\u2B8C"
                    //contentItem: Text {
                        //text: parent.text
                        //font: parent.font
                        //color: parent.down ? appTheme.__fontColor : appTheme.__iconColor
                        //horizontalAlignment: Text.AlignHCenter
                        //verticalAlignment: Text.AlignVCenter
                        //elide: Text.ElideRight
                    //}
                    //font.family: "fontello"
                    icon.name: "edit-undo"
                    icon.color: down ? appTheme.__fontColor : appTheme.__iconColor
                    focusPolicy: Qt.TabFocus
                    onClicked: prompter.undo()
                }
                ToolButton {
                    //text: "\u2B8C"
                    //contentItem: Text {
                        //text: parent.text
                        //font: parent.font
                        //color: parent.down ? appTheme.__fontColor : appTheme.__iconColor
                        //horizontalAlignment: Text.AlignHCenter
                        //verticalAlignment: Text.AlignVCenter
                        //elide: Text.ElideRight
                    //}
                    icon.name: "edit-redo"
                    icon.color: down ? appTheme.__fontColor : appTheme.__iconColor
                    onClicked: prompter.redo()
                }
                ToolSeparator {
                    contentItem.visible: undoRedoRow.y === editRow.y
                }
            }
            Row {
                id: editRow
                ToolButton {
                    id: copyButton
                    //text: "\uF0C5" // icon-docs
                    //contentItem: Text {
                        //text: parent.text
                        //font: parent.font
                        //color: parent.down ? appTheme.__fontColor : appTheme.__iconColor
                        //horizontalAlignment: Text.AlignHCenter
                        //verticalAlignment: Text.AlignVCenter
                        //elide: Text.ElideRight
                    //}
                    //font.family: "fontello"
                    icon.name: "edit-copy"
                    icon.color: down ? appTheme.__fontColor : appTheme.__iconColor
                    focusPolicy: Qt.TabFocus
                    enabled: prompter.selectedText
                    onClicked: prompter.copy()
                }
                ToolButton {
                    id: cutButton
                    //text: "\uE802" // icon-scissors
                    //contentItem: Text {
                        //text: parent.text
                        //font: parent.font
                        //color: parent.down ? appTheme.__fontColor : appTheme.__iconColor
                        //horizontalAlignment: Text.AlignHCenter
                        //verticalAlignment: Text.AlignVCenter
                        //elide: Text.ElideRight
                    //}
                    //font.family: "fontello"
                    icon.name: "edit-cut"
                    icon.color: down ? appTheme.__fontColor : appTheme.__iconColor
                    focusPolicy: Qt.TabFocus
                    enabled: prompter.selectedText
                    onClicked: prompter.cut()
                }
                ToolButton {
                    id: pasteButton
                    //text: "\uF0EA" // icon-paste
                    //font.family: "fontello"
                    //contentItem: Text {
                        //text: parent.text
                        //font: parent.font
                        //color: parent.down ? appTheme.__fontColor : appTheme.__iconColor
                        //horizontalAlignment: Text.AlignHCenter
                        //verticalAlignment: Text.AlignVCenter
                        //elide: Text.ElideRight
                    //}
                    icon.name: "edit-paste"
                    icon.color: down ? appTheme.__fontColor : appTheme.__iconColor
                    focusPolicy: Qt.TabFocus
                    enabled: prompter.canPaste
                    onClicked: prompter.paste()
                }
                ToolSeparator {
                    contentItem.visible: editRow.y === formatRow.y
                }
            }
            Row {
                id: formatRow
                ToolButton {
                    id: boldButton
                    text: "\uE800" // icon-bold
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: parent.down ? appTheme.__fontColor : appTheme.__iconColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                    font.family: "fontello"
                    //icon.name: "gtk-bold"
                    //icon.color: down ? appTheme.__fontColor : appTheme.__iconColor
                    focusPolicy: Qt.TabFocus
                    checkable: true
                    checked: prompter.bold
                    onClicked: prompter.bold = !prompter.bold
                }
                ToolButton {
                    id: italicButton
                    text: "\uE801" // icon-italic
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: parent.down ? appTheme.__fontColor : appTheme.__iconColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                    font.family: "fontello"
                    //icon.name: "gtk-italic"
                    //icon.color: down ? appTheme.__fontColor : appTheme.__iconColor
                    focusPolicy: Qt.TabFocus
                    checkable: true
                    checked: prompter.italic
                    onClicked: prompter.italic = !prompter.italic
                }
                ToolButton {
                    id: underlineButton
                    text: "\uF0CD" // icon-underline
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: parent.down ? appTheme.__fontColor : appTheme.__iconColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                    //icon.name: "gtk-underline"
                    //icon.color: down ? appTheme.__fontColor : appTheme.__iconColor
                    font.family: "fontello"
                    focusPolicy: Qt.TabFocus
                    checkable: true
                    checked: prompter.underline
                    onClicked: prompter.underline = !prompter.underline
                }
                ToolSeparator {
                    contentItem.visible: formatRow.y === fontRow.y
                }
            }
            Row {
                id: fontRow
                ToolButton {
                    id: fontFamilyToolButton
                    text: qsTr("\uE808") // icon-font
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: parent.down ? appTheme.__fontColor : appTheme.__iconColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                    font.family: "fontello"
                    font.bold: prompter.bold
                    font.italic: prompter.italic
                    font.underline: prompter.underline
                    onClicked: {
                        fontDialog.currentFont.family = prompter.fontFamily;
                        fontDialog.currentFont.pointSize = prompter.fontSize;
                        fontDialog.open();
                    }
                }
                ToolButton {
                    id: textColorButton
                    text: "\uF1FC" // icon-brush
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: parent.down ? appTheme.__fontColor : appTheme.__iconColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                    font.family: "fontello"
                    focusPolicy: Qt.TabFocus
                    onClicked: colorDialog.open()
                    
                    Rectangle {
                        width: aFontMetrics.width + 3
                        height: 2
                        color: prompter.textColor
                        parent: textColorButton.contentItem
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.baseline: parent.baseline
                        anchors.baselineOffset: 6
                        
                        TextMetrics {
                            id: aFontMetrics
                            font: textColorButton.font
                            text: textColorButton.text
                        }
                    }
                }
                ToolSeparator {
                    contentItem.visible: fontRow.y === alignmentRow.y
                }
            }
            Row {
                id: alignmentRow
                ToolButton {
                    id: alignLeftButton
                    text: "\uE803" // icon-align-left
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: parent.down ? appTheme.__fontColor : appTheme.__iconColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                    font.family: "fontello"
                    focusPolicy: Qt.TabFocus
                    checkable: true
                    checked: prompter.alignment === Qt.AlignLeft
                    onClicked: prompter.alignment = Qt.AlignLeft
                }
                ToolButton {
                    id: alignCenterButton
                    text: "\uE804" // icon-align-center
                    font.family: "fontello"
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: parent.down ? appTheme.__fontColor : appTheme.__iconColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                    focusPolicy: Qt.TabFocus
                    checkable: true
                    checked: prompter.alignment === Qt.AlignHCenter
                    onClicked: prompter.alignment = Qt.AlignHCenter
                }
                ToolButton {
                    id: alignRightButton
                    text: "\uE805" // icon-align-right
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: parent.down ? appTheme.__fontColor : appTheme.__iconColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                    font.family: "fontello"
                    focusPolicy: Qt.TabFocus
                    checkable: true
                    checked: prompter.alignment === Qt.AlignRight
                    onClicked: prompter.alignment = Qt.AlignRight
                }
                ToolButton {
                    id: alignJustifyButton
                    text: "\uE806" // icon-align-justify
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: parent.down ? appTheme.__fontColor : appTheme.__iconColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                    font.family: "fontello"
                    focusPolicy: Qt.TabFocus
                    checkable: true
                    checked: prompter.alignment === Qt.AlignJustify
                    onClicked: prompter.alignment = Qt.AlignJustify
                }
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
