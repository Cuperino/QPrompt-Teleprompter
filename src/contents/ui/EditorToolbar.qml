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
 ** Alternatively, you may use this file under the terms of the BSD license
 ** as follows:
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
            //Component {
            //    id: editorButton
            //    ToolButton {
            //        contentItem: Text {
            //            text: parent.text
            //            font: parent.font
            //            color: parent.down ? appTheme.__fontColor : appTheme.__iconColor
            //            horizontalAlignment: Text.AlignHCenter
            //            verticalAlignment: Text.AlignVCenter
            //            elide: Text.ElideRight
            //        }
            //        font.family: "fontello"
            //        font.pointSize: 13
            //        icon.color: down ? appTheme.__fontColor : appTheme.__iconColor
            //        focusPolicy: Qt.TabFocus
            //    }
            //}
            //Loader {
            //    sourceComponent: editorButton
            //    id: bookmarkToggleButton
            //    icon.name: "bookmarks"
            //    icon.color: down ? appTheme.__fontColor : appTheme.__iconColor
            //    onClicked: prompter.bookmark()
            //}
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
                //font.pointSize: 13
                icon.name: "bookmarks"
                icon.color: down ? appTheme.__fontColor : appTheme.__iconColor
                focusPolicy: Qt.TabFocus
                onClicked: {
                    showPassiveNotification(i18n("Markers have not been implemented yet."));
                    prompter.document.marker = !prompter.document.marker
                }
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
                //font.pointSize: 13
                icon.name: Qt.application.layoutDirection===Qt.LeftToRight?"edit-undo":"edit-redo"
                icon.color: down ? appTheme.__fontColor : appTheme.__iconColor
                focusPolicy: Qt.TabFocus
                enabled: prompter.editor.canUndo
                onClicked: prompter.editor.undo()
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
                //font.family: "fontello"
                //font.pointSize: 13
                icon.name: Qt.application.layoutDirection===Qt.LeftToRight?"edit-redo":"edit-undo"
                icon.color: down ? appTheme.__fontColor : appTheme.__iconColor
                enabled: prompter.editor.canRedo
                onClicked: prompter.editor.redo()
            }
            ToolSeparator {
                contentItem.visible: undoRedoRow.y === editRow.y
            }
        }
        Row {
            id: editRow
            ToolButton {
                id: copyButton
                text: "\uF0C5" // icon-docs
                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: parent.down ? appTheme.__fontColor : appTheme.__iconColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
                font.family: "fontello"
                font.pointSize: 13
                //icon.name: "edit-copy"
                //icon.color: down ? appTheme.__fontColor : appTheme.__iconColor
                focusPolicy: Qt.TabFocus
                enabled: prompter.editor.selectedText
                onClicked: prompter.editor.copy()
            }
            ToolButton {
                id: cutButton
                text: "\uE802" // icon-scissors
                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: parent.down ? appTheme.__fontColor : appTheme.__iconColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
                font.family: "fontello"
                font.pointSize: 13
                //icon.name: "edit-cut"
                //icon.color: down ? appTheme.__fontColor : appTheme.__iconColor
                focusPolicy: Qt.TabFocus
                enabled: prompter.editor.selectedText
                onClicked: prompter.editor.cut()
            }
            ToolButton {
                id: pasteButton
                text: "\uF0EA" // icon-paste
                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: parent.down ? appTheme.__fontColor : appTheme.__iconColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
                font.family: "fontello"
                font.pointSize: 13
                //icon.name: "edit-paste"
                //icon.color: down ? appTheme.__fontColor : appTheme.__iconColor
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
                font.pointSize: 13
                //icon.name: "gtk-bold"
                //icon.color: down ? appTheme.__fontColor : appTheme.__iconColor
                focusPolicy: Qt.TabFocus
                checkable: true
                checked: prompter.document.bold
                onClicked: prompter.document.bold = !prompter.document.bold
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
                font.pointSize: 13
                //icon.name: "gtk-italic"
                //icon.color: down ? appTheme.__fontColor : appTheme.__iconColor
                focusPolicy: Qt.TabFocus
                checkable: true
                checked: prompter.document.italic
                onClicked: prompter.document.italic = !prompter.document.italic
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
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                checkable: true
                checked: prompter.document.underline
                onClicked: prompter.document.underline = !prompter.document.underline
            }
            ToolButton {
                id: strikeOutButton
                text: "\uF0CC" // icon-underline
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
                font.pointSize: 13
                font.bold: prompter.document.bold
                font.italic: prompter.document.italic
                font.underline: prompter.document.underline
                onClicked: {
                    fontDialog.currentFont.family = prompter.document.fontFamily;
                    fontDialog.currentFont.pointSize = prompter.document.fontSize;
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
            ToolSeparator {
                contentItem.visible: fontRow.y === alignmentRow.y
            }
        }
        Row {
            id: alignmentRow
            ToolButton {
                id: alignLeftButton
                text: Qt.application.layoutDirection===Qt.LeftToRight ? "\uE803" : "\uE805"
                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: parent.down ? appTheme.__fontColor : appTheme.__iconColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
                font.family: "fontello"
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
                text: "\uE804" // icon-align-center
                font.family: "fontello"
                font.pointSize: 13
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
                checked: prompter.document.alignment === Qt.AlignHCenter
                onClicked: prompter.document.alignment = Qt.AlignHCenter
            }
            ToolButton {
                id: alignRightButton
                text: Qt.application.layoutDirection===Qt.LeftToRight ? "\uE805" : "\uE803"
                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: parent.down ? appTheme.__fontColor : appTheme.__iconColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
                font.family: "fontello"
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
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                checkable: true
                checked: prompter.document.alignment === Qt.AlignJustify
                onClicked: prompter.document.alignment = Qt.AlignJustify
            }
        }
        RowLayout {
            visible: !wysiwygButton.checked && prompter.state!=="prompting"
            Label {
                text: i18n("Font size for editing:") + " " + prompter.fontSize + " (" + (fontSizeSlider.value/1000).toFixed(3).slice(2) + "%)"
                color: appTheme.__fontColor
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
            visible: wysiwygButton.checked || prompter.state==="prompting"
            Label {
                text: i18n("Font size for prompting:") + " " + (prompter.fontSize/1000).toFixed(3).slice(2) + " (" + (fontWYSIWYGSizeSlider.value/1000).toFixed(3).slice(2) + "%)"
                color: appTheme.__fontColor
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
                text: i18n("Velocity:") + (prompter.__i<0 ? '  -' + (prompter.__i/100).toFixed(2).slice(3) : ' +' + (prompter.__i/100).toFixed(2).slice(2))
                color: appTheme.__fontColor
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
                color: appTheme.__fontColor
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
                //handle: Rectangle {
                //x: opacitySlider.leftPadding + opacitySlider.visualPosition * (opacitySlider.availableWidth - width)
                //y: opacitySlider.topPadding + opacitySlider.availableHeight / 2 - height / 2
                //implicitWidth: 26
                //implicitHeight: 26
                //radius: 13
                //color: opacitySlider.pressed ? "#f0f0f0" : "#f6f6f6"
                //border.color: "#bdbebf"
                //}
            }
        }
    }
    readonly property alias fontSizeSlider: fontSizeSlider
    readonly property alias fontWYSIWYGSizeSlider: fontWYSIWYGSizeSlider
    readonly property alias opacitySlider: opacitySlider
}
