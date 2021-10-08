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

/****************************************************************************
 **
 ** Copyright (C) 2017 The Qt Company Ltd.
 ** Contact: https://www.qt.io/licensing/
 **
 ** This file contains code originating from examples from the Qt Toolkit.
 ** The code from the examples was licensed under the following license:
 **
 ** $QT_BEGIN_LICENSE:BSD$
 ** Commercial License Usage
 ** Licensees holding valid commercial Qt licenses may use this file in
 ** accordance with the commercial license agreement provided with the
 ** Software or, alternatively, in accordance with the terms contained in
 ** a written agreement between you and The Qt Company. For licensing terms
 ** and conditions see https://www.qt.io/terms-conditions. For further
 ** information use the contact form at https://www.qt.io/contact-us.
 **
 ** BSD License Usage
 ** Alternatively, you may use the original examples code in this file under
 ** the terms of the BSD license as follows:
 **
 ** "Redistribution and use in source and binary forms, with or without
 ** modification, are permitted provided that the following conditions are
 ** met:
 **   * Redistributions of source code must retain the above copyright
 **     notice, this list of conditions and the following disclaimer.
 **   * Redistributions in binary form must reproduce the above copyright
 **     notice, this list of conditions and the following disclaimer in
 **     the documentation and/or other materials provided with the
 **     distribution.
 **   * Neither the name of The Qt Company Ltd nor the names of its
 **     contributors may be used to endorse or promote products derived
 **     from this software without specific prior written permission.
 **
 **
 ** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 ** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 ** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 ** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 ** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 ** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 ** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 ** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 ** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 ** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 ** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
 **
 ** $QT_END_LICENSE$
 **
 ****************************************************************************/

import QtQuick 2.12
import org.kde.kirigami 2.11 as Kirigami
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import Qt.labs.settings 1.0

ToolBar {
    id: toolbar

    property bool showFontSpacingOptions: false
    property bool showAnimationConfigOptions: false

    readonly property alias fontSizeSlider: fontSizeSlider
    readonly property alias letterSpacingSlider: letterSpacingSlider
    readonly property alias wordSpacingSlider: wordSpacingSlider
    readonly property alias fontWYSIWYGSizeSlider: fontWYSIWYGSizeSlider
    readonly property alias opacitySlider: opacitySlider
    readonly property alias baseSpeedSlider: baseSpeedSlider
    readonly property alias baseAccelerationSlider: baseAccelerationSlider

    Settings {
        category: "kirigamiUI"
        property alias showFontSpacingOptions: toolbar.showFontSpacingOptions
        property alias showAnimationConfigOptions: toolbar.showAnimationConfigOptions
    }
    Settings {
        category: "prompter"
        property alias baseSpeed: baseSpeedSlider.value
        property alias baseAcceleration: baseAccelerationSlider.value
        property alias fontSize: fontSizeSlider.value
        property alias letterSpacing: letterSpacingSlider.value
        property alias wordSpacing: wordSpacingSlider.value
        //property alias lineHeight: lineHeightSlider.value
        //property alias fontWYSIWYGSizeSlider: fontWYSIWYGSizeSlider.value
    }

    // Hide toolbar when read region is set to bottom and prompter is not in editing state.
    enabled: !(parseInt(prompter.state)!==Prompter.States.Editing && (overlay.atBottom/* || Kirigami.Settings.isMobile*/))
    height: enabled ? implicitHeight : 0
    //Behavior on height {
    //    id: height
    //    enabled: true
    //    animation: NumberAnimation {
    //        duration: Kirigami.Units.shortDuration>>1
    //        easing.type: Easing.OutQuad
    //    }
    //}
    
    FontLoader {
        id: iconFont
        source: "fonts/fontello.ttf"
    }

    background: Rectangle {
        Rectangle {
            color: parseInt(prompter.state)===Prompter.States.Prompting && editor.focus ? "#00AA00" : Kirigami.Theme.activeBackgroundColor
            opacity: parseInt(prompter.state)!==Prompter.States.Editing ? 0.4 : 1
            height: 3
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
        }
        color: Kirigami.Theme.alternateBackgroundColor.a===0 ? appTheme.__backgroundColor : Kirigami.Theme.alternateBackgroundColor
    }
    Component {
        id: textComponent
        Text {
            anchors.fill: parent
            text: parent.parent.text
            font: parent.parent.font
            Kirigami.Theme.colorSet: Kirigami.Theme.Button
            color: parent.parent.enabled ? (parent.parent.down ? /*Kirigami.Theme.positiveTextColor*/Kirigami.Theme.focusColor : (parent.parent.checked ? Kirigami.Theme.focusColor : Kirigami.Theme.textColor)) : (root.themeIsMaterial ? "#888" : Kirigami.Theme.textColor)
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
    }
    Flow {
        id: flow
        anchors.fill: parent
        Row {
            id: anchorsRow
            ToolButton {
                id: bookmarkListButton
                text: "\uF0DB" /*uE804*/
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                checked: sideDrawer.drawerOpen
                onClicked: {
                    find.close()
                    sideDrawer.toggle()
                }
            }
            ToolButton {
                id: searchButton
                // visible: !Kirigami.Settings.isMobile || parseInt(prompter.state)===Prompter.States.Editing
                text: Qt.application.layoutDirection===Qt.LeftToRight ? "\uE847" : "\uE848"
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                onClicked: find.toggle()
                checked: find.visible
            }
            ToolButton {
                id: bookmarkToggleButton
                text: "\uE843"
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                checked: prompter.document.regularMarker
                checkable: true
                onClicked: prompter.document.regularMarker = !prompter.document.regularMarker
            }
            ToolButton {
                id: namedBookmarkButton
                visible: !Kirigami.Settings.isMobile || parseInt(prompter.state)===Prompter.States.Editing
                text: "\uE844"
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                checked: prompter.document.namedMarker
                checkable: true
                onClicked: namedMarkerConfiguration.open()
            }
            //ToolButton {
            //    id: debugButton
            //    text: "\uE846"
            //    contentItem: Loader { sourceComponent: textComponent }
            //    font.family: iconFont.name
            //    font.pointSize: 13
            //    focusPolicy: Qt.TabFocus
            //    onClicked: {}
            //}
            ToolSeparator {
                contentItem.visible: anchorsRow.y === playbackRow.y
            }
        }
        Row {
            id: playbackRow
            visible: !Kirigami.Settings.isMobile || parseInt(prompter.state)!==Prompter.States.Editing
            ToolButton {
                id: previousMarkerButton
                text: "\uE81A"
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                onClicked: prompter.goToPreviousMarker()
            }
            ToolButton {
                id: nextMarkerButton
                text: "\uE818"
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                onClicked: prompter.goToNextMarker()
            }
            ToolSeparator {
                contentItem.visible: playbackRow.y === undoRedoRow.y
            }
        }
        Row {
            id: undoRedoRow
            visible: !Kirigami.Settings.isMobile || parseInt(prompter.state)===Prompter.States.Editing
            ToolButton {
                text: Qt.application.layoutDirection===Qt.LeftToRight?"\uE800":"\uE801"
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                enabled: prompter.editor.canUndo
                onClicked: prompter.editor.undo()
            }
            ToolButton {
                text: Qt.application.layoutDirection===Qt.LeftToRight?"\uE801":"\uE800"
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
                enabled: prompter.editor.canRedo
                onClicked: prompter.editor.redo()
            }
            ToolSeparator {
                contentItem.visible: undoRedoRow.y === editRow.y
            }
        }
        Row {
            id: editRow
            visible: !Kirigami.Settings.isMobile
            ToolButton {
                id: copyButton
                text: "\uF0C5"
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                enabled: prompter.editor.selectedText
                onClicked: prompter.editor.copy()
            }
            ToolButton {
                id: cutButton
                text: "\uE80C"
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                enabled: prompter.editor.selectedText
                onClicked: prompter.editor.cut()
            }
            ToolButton {
                id: pasteButton
                text: "\uF0EA"
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                enabled: prompter.editor.canPaste
                onClicked: prompter.editor.paste()
            }
            ToolSeparator {
                contentItem.visible: editRow.y === formatRow.y
            }
        }
        Row {
            id: formatRow
            visible: !Kirigami.Settings.isMobile || parseInt(prompter.state)===Prompter.States.Editing
            ToolButton {
                id: boldButton
                text: "\uE802"
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                checkable: true
                checked: prompter.document.bold
                onClicked: prompter.document.bold = !prompter.document.bold
            }
            ToolButton {
                id: italicButton
                text: "\uE803"
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                checkable: true
                checked: prompter.document.italic
                onClicked: prompter.document.italic = !prompter.document.italic
            }
            ToolButton {
                id: underlineButton
                text: "\uF0CD"
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                checkable: true
                checked: prompter.document.underline
                onClicked: prompter.document.underline = !prompter.document.underline
            }
            ToolButton {
                id: strikeOutButton
                text: "\uF0CC"
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                checkable: true
                checked: prompter.document.strike
                onClicked: prompter.document.strike = !prompter.document.strike
            }
            ToolSeparator {
                contentItem.visible: formatRow.y === fontRow.y || formatRow.y === alignmentRowMobile.y
            }
        }
        Row {
            id: fontRow
            visible: !Kirigami.Settings.isMobile
            ToolButton {
                id: fontFamilyToolButton
                text: i18n("\uE805")
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
                font.bold: prompter.document.bold
                font.italic: prompter.document.italic
                font.underline: prompter.document.underline
                font.strikeout: prompter.document.strike
                font.overline: prompter.document.regularMarker || prompter.document.namedMarker
                onClicked: {
                    fontDialog.currentFont.family = prompter.document.fontFamily;
                    fontDialog.currentFont.pointSize = prompter.document.fontSize;
                    fontDialog.open();
                }
            }
            ToolButton {
                id: textColorButton
                text: "\uE83F" /*uF1FC*/
                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    Kirigami.Theme.colorSet: Kirigami.Theme.Button
                    color: parent.down ? Kirigami.Theme.positiveTextColor : (parent.checked ? Kirigami.Theme.focusColor : Kirigami.Theme.textColor)
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
                font.family: iconFont.name
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                onClicked: colorDialog.open()
                
                Rectangle {
                    width: aFontMetrics.width + 3
                    height: 2
                    color: prompter.document.textColor
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
            ToolButton {
                id: textBackgroundButton
                text: "\uF1FC" /*u1F3A8*/
                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    Kirigami.Theme.colorSet: Kirigami.Theme.Button
                    color: parent.down ? Kirigami.Theme.positiveTextColor : (parent.checked ? Kirigami.Theme.focusColor : Kirigami.Theme.textColor)
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
                font.family: iconFont.name
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                onClicked: highlightDialog.open()

                Rectangle {
                    width: bFontMetrics.width + 3
                    height: 2
                    color: prompter.document.textBackground
                    parent: textBackgroundButton.contentItem
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.baseline: parent.baseline
                    anchors.baselineOffset: 6

                    TextMetrics {
                        id: bFontMetrics
                        font: textBackgroundButton.font
                        text: textBackgroundButton.text
                    }
                }
            }
            ToolSeparator {
                contentItem.visible: fontRow.y === alignmentRowMobile.y || fontRow.y === alignmentRowDesktop.y
            }
        }
        Row {
            id: alignmentRowDesktop
            visible: !Kirigami.Settings.isMobile
            ToolButton {
                id: alignLeftButton
                text: Qt.application.layoutDirection===Qt.LeftToRight ? "\uE808" : "\uE80A"
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                checkable: true
                checked: Qt.application.layoutDirection===Qt.LeftToRight ? prompter.document.alignment === Qt.AlignLeft : prompter.document.alignment === Qt.AlignRight
                onClicked: {
                    if (Qt.application.layoutDirection===Qt.LeftToRight)
                        prompter.document.alignment = Qt.AlignLeft
                    else
                        prompter.document.alignment = Qt.AlignRight
                }
            }
            ToolButton {
                id: alignCenterButton
                text: "\uE809"
                font.family: iconFont.name
                font.pointSize: 13
                contentItem: Loader { sourceComponent: textComponent }
                focusPolicy: Qt.TabFocus
                checkable: true
                checked: prompter.document.alignment === Qt.AlignHCenter
                onClicked: prompter.document.alignment = Qt.AlignHCenter
            }
            ToolButton {
                id: alignRightButton
                text: Qt.application.layoutDirection===Qt.LeftToRight ? "\uE80A" : "\uE808"
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                checkable: true
                checked: Qt.application.layoutDirection===Qt.LeftToRight ? prompter.document.alignment === Qt.AlignRight : prompter.document.alignment === Qt.AlignLeft
                onClicked: {
                    if (Qt.application.layoutDirection===Qt.LeftToRight)
                        prompter.document.alignment = Qt.AlignRight
                        else
                            prompter.document.alignment = Qt.AlignLeft
                }
            }
            // Justify is proven to make text harder to read for some readers. So I'm commenting out all text justification options from the program. I'm not removing them, only commenting out in case someone needs to re-enable. This article links to various sources that validate my decision: https://kaiweber.wordpress.com/2010/05/31/ragged-right-or-justified-alignment/ - Javier
            //ToolButton {
            //    id: alignJustifyButton
            //    text: "\uE80B"
            //    contentItem: Loader { sourceComponent: textComponent }
            //    font.family: iconFont.name
            //    font.pointSize: 13
            //    focusPolicy: Qt.TabFocus
            //    checkable: true
            //    checked: prompter.document.alignment === Qt.AlignJustify
            //    onClicked: prompter.document.alignment = Qt.AlignJustify
            //}
            ToolSeparator {
                contentItem.visible: alignmentRowDesktop.y === advancedButtonsRow.y
            }
        }
        Row {
            id: alignmentRowMobile
            visible: Kirigami.Settings.isMobile && parseInt(prompter.state)===Prompter.States.Editing
            Menu {
                id: textAlignmentMenu
                background: Rectangle {
                    color: "#DD000000"
                    implicitWidth: 120
                }
                MenuItem {
                    text: Qt.application.layoutDirection===Qt.LeftToRight ? i18n("&Left") : i18n("&Right")
                    enabled: Qt.application.layoutDirection===Qt.LeftToRight ? prompter.document.alignment !== Qt.AlignLeft : prompter.document.alignment !== Qt.AlignRight
                    onTriggered: prompter.document.alignment = Qt.AlignLeft
                }
                MenuItem {
                    text: i18n("C&enter")
                    enabled: !(prompter.document.alignment === Qt.AlignHCenter || (prompter.document.alignment !== Qt.AlignLeft && prompter.document.alignment !== Qt.AlignRight/*&& prompter.document.alignment !== Qt.AlignJustify*/))
                    onTriggered: prompter.document.alignment = Qt.AlignHCenter
                }
                MenuItem {
                    text: Qt.application.layoutDirection===Qt.LeftToRight ? i18n("&Right") : i18n("&Left")
                    enabled: Qt.application.layoutDirection===Qt.LeftToRight ? prompter.document.alignment !== Qt.AlignRight : prompter.document.alignment !== Qt.AlignLeft
                    onTriggered: prompter.document.alignment = Qt.AlignRight
                }
                //MenuItem {
                //    text: i18n("&Justify")
                //    enabled: prompter.document.alignment !== Qt.AlignHustify
                //    onTriggered: prompter.document.alignment = Qt.AlignJustify
                //}
            }
            ToolButton {
                id: mobileAlignLeftButton
                visible: checked
                text: Qt.application.layoutDirection===Qt.LeftToRight ? "\uE808" : "\uE80A"
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                checkable: true
                checked: Qt.application.layoutDirection===Qt.LeftToRight ? prompter.document.alignment === Qt.AlignLeft : prompter.document.alignment === Qt.AlignRight
                onClicked: textAlignmentMenu.popup(this)
            }
            ToolButton {
                id: mobileAlignCenterButton
                visible: checked || !(alignLeftButton.checked||alignRightButton.checked/*||alignJustifyButton.checked*/)
                text: "\uE809"
                font.family: iconFont.name
                font.pointSize: 13
                contentItem: Loader { sourceComponent: textComponent }
                focusPolicy: Qt.TabFocus
                checkable: true
                checked: prompter.document.alignment === Qt.AlignHCenter
                onClicked: textAlignmentMenu.popup(this)
            }
            ToolButton {
                id: mobileAlignRightButton
                visible: checked
                text: Qt.application.layoutDirection===Qt.LeftToRight ? "\uE80A" : "\uE808"
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                checkable: true
                checked: Qt.application.layoutDirection===Qt.LeftToRight ? prompter.document.alignment === Qt.AlignRight : prompter.document.alignment === Qt.AlignLeft
                onClicked: textAlignmentMenu.popup(this)
            }
            // Justify is proven to make text harder to read for some readers. So I'm commenting out all text justification options from the program. I'm not removing them, only commenting out in case someone needs to re-enable. This article links to various sources that validate my decision: https://kaiweber.wordpress.com/2010/05/31/ragged-right-or-justified-alignment/ - Javier
            //ToolButton {
            //    id: mobileAlignJustifyButton
            //    visible: checked
            //    text: "\uE80B"
            //    contentItem: Loader { sourceComponent: textComponent }
            //    font.family: iconFont.name
            //    font.pointSize: 13
            //    focusPolicy: Qt.TabFocus
            //    checkable: true
            //    checked: prompter.document.alignment === Qt.AlignJustify
            //    onClicked: textAlignmentMenu.popup(this)
            //}
            ToolSeparator {
                contentItem.visible: alignmentRowMobile.y === advancedButtonsRow.y
            }
        }
        Row {
            id: advancedButtonsRow
            //visible: parseInt(prompter.state)===Prompter.States.Editing
            ToolButton {
                text: "\uE806"
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                checkable: true
                checked: showFontSpacingOptions
                onClicked: {
                   showFontSpacingOptions = !showFontSpacingOptions
                }
            }
            ToolButton {
                text: "\uE846" /*uF141*/
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                checkable: true
                checked: showAnimationConfigOptions
                onClicked: {
                   showAnimationConfigOptions = !showAnimationConfigOptions
                }
            }
            ToolButton {
                id: __iDefaultButton
                visible: showAnimationConfigOptions
                text: "\uE858"
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                checkable: true
                checked: stepsConfiguration.sheetOpen
                onClicked: stepsConfiguration.open()
            }
        }
        RowLayout {
            enabled: parseInt(prompter.state)===Prompter.States.Prompting
            visible: !Kirigami.Settings.isMobile || enabled // parseInt(prompter.state)!==Prompter.States.Editing
            //ToolButton {
            //    text: "\uE814"
            //    enabled: false
            //    contentItem: Loader { sourceComponent: textComponent }
            //    font.family: iconFont.name
            //    font.pointSize: 13
            //}
            Label {
                text: i18n("Velocity:") + (prompter.__i<0 ? '  -' + (prompter.__i/100).toFixed(2).slice(3) : ' +' + (prompter.__i/100).toFixed(2).slice(2))
                color: Kirigami.Theme.textColor
                Layout.topMargin: 4
                Layout.bottomMargin: 4
                Layout.leftMargin: 8
                Layout.rightMargin: 8
            }
            Slider {
                id: velocityControlSlider
                value: prompter.__i
                to: 20
                from: -velocityControlSlider.to
                stepSize: 1
                focusPolicy: Qt.TabFocus
                onMoved: {
                    if (!(prompter.__atEnd && value>=0 || prompter.__atStart && value<0)) {
                        prompter.__i = value
                        prompter.__play = true
                        prompter.position = prompter.__destination
                    }
                }
            }
        }
        RowLayout {
            visible: root.__translucidBackground && (!Kirigami.Settings.isMobile || (parseInt(prompter.state)!==Prompter.States.Editing && parseInt(prompter.state)!==Prompter.States.Prompting)) // This check isn't optimized in case more prompter states get added in the future, even tho I think that is unlikely.
            ToolButton {
                visible: !Kirigami.Settings.isMobile
                text: "\uE810"
                enabled: false
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
            }
            Label {
                text: i18n("Opacity:") + " " + (root.__opacity/10).toFixed(3).slice(2)
                color: Kirigami.Theme.textColor
                Layout.topMargin: 4
                Layout.bottomMargin: 4
                Layout.leftMargin: 8
                Layout.rightMargin: 8
            }
            Slider {
                id: opacitySlider
                value: 100*root.__opacity
                from: 0
                to: 100
                stepSize: 1
                focusPolicy: Qt.TabFocus
                onMoved: {
                    root.__opacity = value/100
                }
            }
        }
        RowLayout {
            visible: !wysiwygButton.checked && parseInt(prompter.state)===Prompter.States.Editing
            ToolButton {
                text: "\uF088"
                enabled: false
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
            }
            Label {
                text: i18n("Font size while editing:") + " " + (fontSizeSlider.value/1000).toFixed(3).slice(2) + "% (" + prompter.fontSize + ")"
                color: Kirigami.Theme.textColor
                Layout.topMargin: 4
                Layout.bottomMargin: 4
                Layout.leftMargin: 8
                Layout.rightMargin: 8
            }
            Slider {
                id: fontSizeSlider
                focusPolicy: Qt.TabFocus
                from: 90
                value: 100
                to: 158
                stepSize: 1
            }
        }
        RowLayout {
            visible: wysiwygButton.checked || parseInt(prompter.state)!==Prompter.States.Editing
            // enabled: !(parseInt(prompter.state)===Prompter.States.Countdown || parseInt(prompter.state)===Prompter.States.Prompting)
            ToolButton {
                text: "\uF088"
                enabled: false
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
            }
            Label {
                text: i18n("Font size:") /*+ i18n("Font size for prompter:")*/ + " " + (fontWYSIWYGSizeSlider.value/1000).toFixed(3).slice(2) + "% (" + (prompter.fontSize/1000).toFixed(3).slice(2) + ")"
                color: Kirigami.Theme.textColor
                Layout.topMargin: 4
                Layout.bottomMargin: 4
                Layout.leftMargin: 8
                Layout.rightMargin: 8
            }
            Slider {
                id: fontWYSIWYGSizeSlider
                from: 90
                value: 144
                to: 180 // 200
                stepSize: 0.5
                focusPolicy: Qt.TabFocus
            }
        }
        RowLayout {
            visible: height>0
            height: showFontSpacingOptions ? implicitHeight : 0
            clip: true
            Behavior on height{
                enabled: true
                animation: NumberAnimation {
                    duration: Kirigami.Units.shortDuration
                    easing.type: Easing.OutQuad
                }
            }
            ToolButton {
                text: "\uE806"
                enabled: false
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
            }
            Label {
                text: i18n("Line height:") + " " + (lineHeightSlider.value/1000).toFixed(3).slice(2) + "%"
                color: Kirigami.Theme.textColor
                Layout.topMargin: 4
                Layout.bottomMargin: 4
                Layout.rightMargin: 4
            }
            Slider {
                id: lineHeightSlider
                from: 85
                value: 100
                to: 180
                stepSize: 1
                focusPolicy: Qt.TabFocus
                onMoved: prompter.document.setLineHeight(value)
            }
        }
        RowLayout {
            visible: height>0
            height: showFontSpacingOptions ? implicitHeight : 0
            clip: true
            Behavior on height{
                enabled: true
                animation: NumberAnimation {
                    duration: Kirigami.Units.shortDuration
                    easing.type: Easing.OutQuad
                }
            }
            ToolButton {
                text: "\uE807" // W
                enabled: false
                flat: true
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
            }
            Label {
                text: i18n("Word spacing:") + " " + (wordSpacingSlider.value<0 ? '  -' + (wordSpacingSlider.value/100).toFixed(2).slice(3) : ' +' + (wordSpacingSlider.value/100).toFixed(2).slice(2))
                color: Kirigami.Theme.textColor
                Layout.topMargin: 4
                Layout.bottomMargin: 4
                Layout.rightMargin: 4
            }
            Slider {
                id: wordSpacingSlider
                from: 0 // -4
                value: 0
                to: 24
                stepSize: 1
                focusPolicy: Qt.TabFocus
            }
        }
        RowLayout {
            visible: height>0
            height: showFontSpacingOptions ? implicitHeight : 0
            clip: true
            Behavior on height{
                enabled: true
                animation: NumberAnimation {
                    duration: Kirigami.Units.shortDuration
                    easing.type: Easing.OutQuad
                }
            }
            ToolButton {
                text: "\uE807"
                enabled: false
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
            }
            Label {
                text: i18n("Letter spacing:") + " " + (letterSpacingSlider.value<0 ? '  -' + (letterSpacingSlider.value/100).toFixed(2).slice(3) : ' +' + (letterSpacingSlider.value/100).toFixed(2).slice(2))
                color: Kirigami.Theme.textColor
                Layout.topMargin: 4
                Layout.bottomMargin: 4
                Layout.rightMargin: 4
            }
            Slider {
                id: letterSpacingSlider
                from: -12
                value: 0
                to: 12
                stepSize: 1
                focusPolicy: Qt.TabFocus
            }
        }
        RowLayout {
            visible: height>0
            height: showAnimationConfigOptions ? implicitHeight : 0
            clip: true
            Behavior on height{
                enabled: true
                animation: NumberAnimation {
                    duration: Kirigami.Units.shortDuration
                    easing.type: Easing.OutQuad
                }
            }
            ToolButton {
                text: "\uE846"
                enabled: false
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
            }
            Label {
                text: i18n("Base speed:") + " " + (baseSpeedSlider.value/100).toFixed(2)
                color: Kirigami.Theme.textColor
                Layout.topMargin: 4
                Layout.bottomMargin: 4
                Layout.leftMargin: 8
                Layout.rightMargin: 8
            }
            Slider {
                id: baseSpeedSlider
                from: 10
                value: 100
                to: 500
                stepSize: 5
                focusPolicy: Qt.TabFocus
                onMoved: {
                    viewport.__baseSpeed = value;
                    prompter.focus = true;
                    prompter.position = prompter.__destination
                }
            }
        }
        RowLayout {
            visible: height>0
            height: showAnimationConfigOptions ? implicitHeight : 0
            clip: true
            Behavior on height{
                enabled: true
                animation: NumberAnimation {
                    duration: Kirigami.Units.shortDuration
                    easing.type: Easing.OutQuad
                }
            }
            ToolButton {
                text: "\uE846"
                enabled: false
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
            }
            Label {
                text: i18n("Acceleration curve:") + " " + (baseAccelerationSlider.value/100).toFixed(2)
                color: Kirigami.Theme.textColor
                Layout.topMargin: 4
                Layout.bottomMargin: 4
                Layout.leftMargin: 8
                Layout.rightMargin: 8
            }
            Slider {
                id: baseAccelerationSlider
                from: 50
                value: 115
                to: 200
                stepSize: 5
                focusPolicy: Qt.TabFocus
                onMoved: {
                    viewport.__curvature=value;
                    prompter.focus = true;
                    prompter.position = prompter.__destination
                }
            }
        }
    }
    Kirigami.OverlaySheet {
        id: stepsConfiguration
        onSheetOpenChanged: {
            prompterPage.actions.main.checked = sheetOpen;
            if (!sheetOpen)
                prompter.focus = true
        }
        background: Rectangle {
            //color: Kirigami.Theme.activeBackgroundColor
            color: appTheme.__backgroundColor
            anchors.fill: parent
        }
        header: Kirigami.Heading {
            text: i18n("Start Velocity")
            level: 1
        }

        ColumnLayout {
            width: parent.width
            Label {
                text: i18n("Velocity to have when starting to prompt")
            }
            RowLayout {
                SpinBox {
                    id: defaultSteps
                    Layout.fillWidth: true
                    Layout.leftMargin: Kirigami.Units.smallSpacing
                    Layout.rightMargin: Kirigami.Units.smallSpacing
                    value: __iDefault
                    from: 1
                    to: velocityControlSlider.to
                    onValueModified: {
                        __iDefault = value
                    }
                }
                Button {
                    visible: parseInt(prompter.state)===Prompter.States.Prompting && prompter.__velocity>0
                    flat: true
                    text: "Make current velocity default"
                    onClicked: {
                        defaultSteps.value = prompter.__i;
                        __iDefault = prompter.__i;
                    }
                }
            }
        }
    }
    Kirigami.OverlaySheet {
        id: namedMarkerConfiguration
        background: Rectangle {
            //color: Kirigami.Theme.activeBackgroundColor
            color: appTheme.__backgroundColor
            anchors.fill: parent
        }
        header: Kirigami.Heading {
            text: i18n("Skip Key")
            level: 1
        }
        onSheetOpenChanged: {
            prompterPage.actions.main.checked = sheetOpen;
            // When opening overlay, reset key input button's text.
            // Dev: When opening overlay, reset key input button's text to current anchor's key value.
            if (sheetOpen)
                //row.setMarkerKeyButton.item.text = "";
                column.setMarkerKeyButton.item.text = prompter.document.getMarkerKey();
            else
                prompter.focus = true
        }
        ColumnLayout {
            id: column
            width: parent.width
            property alias setMarkerKeyButton: setMarkerKeyButton
            Label {
                text: i18n("Key to perform skip to this marker")
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
                    //console.log(keyCode);
                    prompter.document.setKeyMarker(keyCode);
                    timer.start();
                }
            }
            Timer {
                id: timer
                running: false
                repeat: false
                interval: Kirigami.Units.longDuration
                onTriggered: namedMarkerConfiguration.close()
            }
        }
    }
}
