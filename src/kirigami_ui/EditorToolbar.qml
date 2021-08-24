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

import QtQuick 2.15
import org.kde.kirigami 2.9 as Kirigami
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ToolBar {
    id: toolbar

    property bool showAdvancedOptions: false

    readonly property alias fontSizeSlider: fontSizeSlider
    readonly property alias letterSpacingSlider: letterSpacingSlider
    readonly property alias wordSpacingSlider: wordSpacingSlider
    readonly property alias fontWYSIWYGSizeSlider: fontWYSIWYGSizeSlider
    readonly property alias opacitySlider: opacitySlider
    readonly property alias baseSpeedSlider: baseSpeedSlider
    readonly property alias baseAccelerationSlider: baseAccelerationSlider

    // Hide toolbar when read region is set to bottom and prompter is not in editing state.
    enabled: !(prompter.state!=="editing" && (overlay.atBottom || Kirigami.Settings.isMobile))
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
            color: Kirigami.Theme.activeBackgroundColor
            opacity: prompter.state!=="editing" ? 0.4 : 1
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
            //visible: prompter.state==="editing"
            ToolButton {
                id: bookmarkListButton
                text: "\uE804"
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
                text: "\uE844"
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                checked: prompter.document.marker
                checkable: true
                onClicked: prompter.document.marker = !prompter.document.marker
            }
            //ToolButton {
            //    id: namedBookmarkButton
            //    text: "\uE845"
            //    contentItem: Loader { sourceComponent: textComponent }
            //    font.family: iconFont.name
            //    font.pointSize: 13
            //    focusPolicy: Qt.TabFocus
            //    onClicked: {}
            //}
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
            //visible: prompter.state==="editing"
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
            //visible: prompter.state==="editing"
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
            //visible: prompter.state==="editing"
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
                contentItem.visible: formatRow.y === fontRow.y
            }
        }
        Row {
            id: fontRow
            //visible: prompter.state==="editing"
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
                font.overline: prompter.document.marker
                onClicked: {
                    fontDialog.currentFont.family = prompter.document.fontFamily;
                    fontDialog.currentFont.pointSize = prompter.document.fontSize;
                    fontDialog.open();
                }
            }
            ToolButton {
                id: textColorButton
                text: "\uE83F"
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
                text: "\uF1FC"
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
                contentItem.visible: fontRow.y === alignmentRow.y
            }
        }
        Row {
            id: alignmentRow
            //visible: prompter.state==="editing"
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
            ToolButton {
                id: alignJustifyButton
                text: "\uE80B"
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                checkable: true
                checked: prompter.document.alignment === Qt.AlignJustify
                onClicked: prompter.document.alignment = Qt.AlignJustify
            }
            ToolSeparator {
                contentItem.visible: alignmentRow.y === advancedButtonsRow.y
            }
        }
        Row {
            id: advancedButtonsRow
            //visible: prompter.state==="editing"
            ToolButton {
                id: advancedButton
                text: "\uE846" /*uF141*/
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                checkable: true
                checked: showAdvancedOptions
                onClicked: {
                   showAdvancedOptions = !showAdvancedOptions
                }
            }
        }
        RowLayout {
            visible: !wysiwygButton.checked && prompter.state==="editing"
            Label {
                text: i18n("Font size while editing:") + " " + prompter.fontSize + " (" + (fontSizeSlider.value/1000).toFixed(3).slice(2) + "%)"
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
            visible: wysiwygButton.checked || prompter.state!=="editing"
            // enabled: !(prompter.state==="countdown" || prompter.state==="prompting")
            Label {
                text: i18n("Font size:") /*+ i18n("Font size for prompter:")*/ + " " + (prompter.fontSize/1000).toFixed(3).slice(2) + " (" + (fontWYSIWYGSizeSlider.value/1000).toFixed(3).slice(2) + "%)"
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
            enabled: prompter.state==="prompting"
            Label {
                text: i18n("Steps:") + (prompter.__i<0 ? '  -' + (prompter.__i/100).toFixed(2).slice(3) : ' +' + (prompter.__i/100).toFixed(2).slice(2))
                color: Kirigami.Theme.textColor
                Layout.topMargin: 4
                Layout.bottomMargin: 4
                Layout.leftMargin: 8
                Layout.rightMargin: 8
            }
            Slider {
                id: velocityControlSlider
                value: prompter.__i
                to: 40
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
            visible: root.__translucidBackground
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
            visible: height>0
            height: showAdvancedOptions ? implicitHeight : 0
            clip: true
            Behavior on height{
                enabled: true
                animation: NumberAnimation {
                    duration: Kirigami.Units.shortDuration
                    easing.type: Easing.OutQuad
                }
            }
            ToolButton {
                id: __iDefaultButton
                text: "\uE858"
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                checkable: true
                checked: stepsConfiguration.sheetOpen
                onClicked: stepsConfiguration.open()
            }
            Label {
                text: i18n("Base speed:") + " " + baseSpeedSlider.value.toFixed(2)
                color: Kirigami.Theme.textColor
                Layout.topMargin: 4
                Layout.bottomMargin: 4
                Layout.leftMargin: 8
                Layout.rightMargin: 8
            }
            Slider {
                id: baseSpeedSlider
                from: 0.1
                value: 1
                to: 5
                stepSize: 0.05
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
            height: showAdvancedOptions ? implicitHeight : 0
            clip: true
            Behavior on height{
                enabled: true
                animation: NumberAnimation {
                    duration: Kirigami.Units.shortDuration
                    easing.type: Easing.OutQuad
                }
            }
            Label {
                text: i18n("Acceleration curvature:") + " " + baseAccelerationSlider.value.toFixed(2)
                color: Kirigami.Theme.textColor
                Layout.topMargin: 4
                Layout.bottomMargin: 4
                Layout.leftMargin: 8
                Layout.rightMargin: 8
            }
            Slider {
                id: baseAccelerationSlider
                from: 0.5
                value: 1.15
                to: 2
                stepSize: 0.05
                focusPolicy: Qt.TabFocus
                onMoved: {
                    viewport.__curvature=value;
                    prompter.focus = true;
                    prompter.position = prompter.__destination
                }
            }
        }
        RowLayout {
            visible: height>0
            height: showAdvancedOptions ? implicitHeight : 0
            clip: true
            Behavior on height{
                enabled: true
                animation: NumberAnimation {
                    duration: Kirigami.Units.shortDuration
                    easing.type: Easing.OutQuad
                }
            }
            Label {
                text: i18n("Letter spacing:") + " " + (letterSpacingSlider.value<0 ? '  -' + (letterSpacingSlider.value/100).toFixed(2).slice(3) : ' +' + (letterSpacingSlider.value/100).toFixed(2).slice(2))
                color: Kirigami.Theme.textColor
                Layout.topMargin: 4
                Layout.bottomMargin: 4
                Layout.leftMargin: 8
                Layout.rightMargin: 8
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
            height: showAdvancedOptions ? implicitHeight : 0
            clip: true
            Behavior on height{
                enabled: true
                animation: NumberAnimation {
                    duration: Kirigami.Units.shortDuration
                    easing.type: Easing.OutQuad
                }
            }
            Label {
                text: i18n("Word spacing:") + " " + (wordSpacingSlider.value<0 ? '  -' + (wordSpacingSlider.value/100).toFixed(2).slice(3) : ' +' + (wordSpacingSlider.value/100).toFixed(2).slice(2))
                color: Kirigami.Theme.textColor
                Layout.topMargin: 4
                Layout.bottomMargin: 4
                Layout.leftMargin: 8
                Layout.rightMargin: 8
            }
            Slider {
                id: wordSpacingSlider
                from: -12
                value: 0
                to: 24
                stepSize: 1
                focusPolicy: Qt.TabFocus
            }
        }
    }
    Kirigami.OverlaySheet {
        id: stepsConfiguration
        onSheetOpenChanged: prompterPage.actions.main.checked = sheetOpen

        background: Rectangle {
            //color: Kirigami.Theme.activeBackgroundColor
            color: appTheme.__backgroundColor
            anchors.fill: parent
        }
        header: Kirigami.Heading {
            text: i18n("Steps to use when starting to prompt")
            level: 1
        }

        RowLayout {
            width: parent.width

            ColumnLayout {
                Label {
                    text: i18n("Steps")
                }
                SpinBox {
                    Layout.fillWidth: true
                    Layout.leftMargin: Kirigami.Units.smallSpacing
                    Layout.rightMargin: Kirigami.Units.smallSpacing
                    value: __iDefault
                    from: 1
                    to: velocityControlSlider.to
                    onValueModified: {
                        focus: true
                        __iDefault = value
                    }
                }
            }
        }
    }
}
