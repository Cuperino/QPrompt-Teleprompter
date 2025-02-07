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
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtCore 6.5

import org.kde.kirigami 2.11 as Kirigami
import com.cuperino.qprompt 1.0

ToolBar {
    id: toolbar

    property bool showFontSpacingOptions: false
    property bool showAnimationConfigOptions: false
    property bool hideFormattingToolsWhilePrompting: true
    property bool hideFormattingToolsAlways: Qt.platform.os==="linux" && root.__isMobile || Qt.platform.os==="android" || Qt.platform.os==="ios"

    readonly property alias fontSizeSlider: fontSizeSlider
    readonly property alias lineHeightSlider: lineHeightSlider
    readonly property alias letterSpacingSlider: letterSpacingSlider
    readonly property alias wordSpacingSlider: wordSpacingSlider
    readonly property alias paragraphSpacingSlider: paragraphSpacingSlider
    readonly property alias fontWYSIWYGSizeSlider: fontWYSIWYGSizeSlider
    readonly property alias opacitySlider: opacitySlider
    readonly property alias baseSpeedSlider: baseSpeedSlider
    readonly property alias baseAccelerationSlider: baseAccelerationSlider
    readonly property alias onlyPositiveVelocity: positiveVelocity.checked
    readonly property alias windowStaysOnTop: windowStayOnTopButton.value
    readonly property bool showSliderIcons: toolbar.width > 404
    readonly property bool showingFormattingTools: parseInt(viewport.prompter.state)!==Prompter.States.Editing && (!toolbar.hideFormattingToolsWhilePrompting || editor.focus)

    // Hide toolbar when read region is set to bottom and viewport.prompter is not in editing state.
    enabled: !(parseInt(viewport.prompter.state)!==Prompter.States.Editing && (overlay.atBottom && !viewport.forcedOrientation || root.fullScreenOrFakeFullScreen && !editor.focus))
    height: enabled ? implicitHeight : 0
    //Behavior on height {
    //    id: height
    //    enabled: true
    //    animation: NumberAnimation {
    //        duration: Units.ShortDuration>>1
    //        easing.type: Easing.OutQuad
    //    }
    //}
    position: ToolBar.Footer
    background: Rectangle {
        color: Kirigami.Theme.alternateBackgroundColor.a===0 ? root.background.__backgroundColor : Kirigami.Theme.alternateBackgroundColor
        opacity: root.__opacity * 0.4 + 0.6
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            onWheel: (wheel) => {
                viewport.mouse.scroll(wheel)
            }
        }
        Rectangle {
            color: parseInt(viewport.prompter.state)===Prompter.States.Prompting && editor.focus ? "#00AA00" : Kirigami.Theme.activeBackgroundColor
            opacity: parseInt(viewport.prompter.state)!==Prompter.States.Editing ? 0.4 : 1
            height: 3
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
        }
        WindowDragger {
            anchors.fill: parent
            window: root
            cursorShape: root.hideDecorators & Qt.FramelessWindowHint ? (pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor) : Qt.ArrowCursor
        }
    }

    Settings {
        category: "kirigamiUI"
        property alias showFontSpacingOptions: toolbar.showFontSpacingOptions
        property alias showAnimationConfigOptions: toolbar.showAnimationConfigOptions
        property alias onlyPositiveVelocity: positiveVelocity.checked
        property alias hideFormattingToolsAlways: toolbar.hideFormattingToolsAlways
        property alias hideFormattingToolsWhilePrompting: toolbar.hideFormattingToolsWhilePrompting
    }
    Settings {
        category: "viewport.prompter"
        property alias baseSpeed: baseSpeedSlider.value
        property alias baseAcceleration: baseAccelerationSlider.value
        property alias fontSize: fontSizeSlider.value
        property alias letterSpacing: letterSpacingSlider.value
        property alias wordSpacing: wordSpacingSlider.value
        property alias lineHeight: lineHeightSlider.value
        property alias paragraphSpacingSlider: paragraphSpacingSlider.value
        property alias fontWYSIWYGSizeSlider: fontWYSIWYGSizeSlider.value
        property alias windowStaysOnTop: windowStayOnTopButton.checked
    }
    FontLoader {
        id: iconFont
        source: "../fonts/fontello.ttf"
    }
    Component {
        id: textComponent
        Text {
            SystemPalette {
                id: disabledButtonPalette
                colorGroup: SystemPalette.Disabled
            }
            anchors.fill: parent
            text: parent.parent.text
            font: parent.parent.font
            color: parent.parent.enabled ? (parent.parent.down ? /*Kirigami.Theme.positiveTextColor*/Kirigami.Theme.focusColor : (parent.parent.checked ? Kirigami.Theme.focusColor : Kirigami.Theme.textColor)) : disabledButtonPalette.buttonText
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
                visible: root.__isMobile ? root.width > 339 : true // root.width > 458
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                checked: markersDrawer.drawerOpen
                onClicked: {
                    find.close()
                    markersDrawer.toggle()
                }
            }
            ToolButton {
                id: searchButton
                visible: !mobileOrSmallScreen || parseInt(viewport.prompter.state)===Prompter.States.Editing && root.width > 360
                enabled: parseInt(viewport.prompter.state)===Prompter.States.Editing || parseInt(viewport.prompter.state)===Prompter.States.Standby
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
                checked: viewport.prompter.document.regularMarker
                checkable: true
                onClicked: viewport.prompter.document.regularMarker = !viewport.prompter.document.regularMarker
            }
            ToolButton {
                id: namedBookmarkButton
                visible: !root.__isMobile // || parseInt(viewport.prompter.state)===Prompter.States.Editing
                text: "\uE844"
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                checked: viewport.prompter.document.namedMarker
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
                contentItem.visible: root.width>458 ? anchorsRow.y === playbackRow.y : anchorsRow.y === playbackRow.y || anchorsRow.y === advancedButtonsRow.y
            }
        }
        Row {
            id: playbackRow
//            visible: !root.__isMobile || parseInt(viewport.prompter.state)===Prompter.States.Prompting
            visible:
                if (root.__isMobile)
                    return parseInt(viewport.prompter.state)===Prompter.States.Prompting
                else
                    return !toolbar.hideFormattingToolsAlways && (showingFormattingTools || parseInt(viewport.prompter.state)===Prompter.States.Editing) || root.width>489;
//                    if (parseInt(viewport.prompter.state)===Prompter.States.Editing)
//                        return true
//                    else if (root.width>459)
//                        return !toolbar.hideFormattingToolsAlways && showingFormattingTools;
//                    else
//                        return true
                //}
            ToolButton {
                id: previousMarkerButton
                text: "\uE81A"
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                onClicked: viewport.prompter.goToPreviousMarker()
            }
            ToolButton {
                id: nextMarkerButton
                text: "\uE818"
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                onClicked: viewport.prompter.goToNextMarker()
            }
            ToolSeparator {
                contentItem.visible: !root.__isMobile && root.width>458 ? playbackRow.y === undoRedoRow.y || playbackRow.y === advancedButtonsRow.y : playbackRow.y === alignmentRowMobile.y
            }
        }
        Row {
            id: undoRedoRow
            visible: !toolbar.hideFormattingToolsAlways && (root.__isMobile ? parseInt(viewport.prompter.state)===Prompter.States.Editing && Qt.platform.os!=='ios' :  (showingFormattingTools || parseInt(viewport.prompter.state)===Prompter.States.Editing) && root.width>489)
            ToolButton {
                text: Qt.application.layoutDirection===Qt.LeftToRight?"\uE74F":"\uE801"
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                enabled: viewport.prompter.editor.canUndo
                onClicked: viewport.prompter.editor.undo()
            }
            ToolButton {
                text: Qt.application.layoutDirection===Qt.LeftToRight?"\uE801":"\uE74F"
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
                enabled: viewport.prompter.editor.canRedo
                onClicked: viewport.prompter.editor.redo()
            }
            ToolSeparator {
                contentItem.visible: undoRedoRow.y === editRow.y
            }
        }
        Row {
            id: editRow
            visible: !toolbar.hideFormattingToolsAlways && !root.__isMobile && root.width>489 && (showingFormattingTools || parseInt(viewport.prompter.state)===Prompter.States.Editing)
            ToolButton {
                id: copyButton
                text: "\uF0C5"
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                enabled: viewport.prompter.editor.selectedText
                onClicked: viewport.prompter.editor.copy()
            }
            ToolButton {
                id: cutButton
                text: "\uE80C"
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                enabled: viewport.prompter.editor.selectedText
                onClicked: viewport.prompter.editor.cut()
            }
            ToolButton {
                id: pasteButton
                text: "\uF0EA"
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                enabled: viewport.prompter.editor.canPaste
                onClicked: viewport.prompter.editor.paste()
            }
            ToolSeparator {
                contentItem.visible: mobileOrSmallScreen ? editRow.y === alignmentRowMobile.y : editRow.y === formatRow.y
            }
        }
        Row {
            id: alignmentRowMobile
            visible: !toolbar.hideFormattingToolsAlways && (showingFormattingTools || parseInt(viewport.prompter.state)===Prompter.States.Editing) && mobileOrSmallScreen //&&
            Menu {
                id: textAlignmentMenu
                background: Rectangle {
                    color: "#DD000000"
                    implicitWidth: 120
                }
                MenuItem {
                    text: Qt.application.layoutDirection===Qt.LeftToRight ? qsTr("&Left", "Editor actions. Text alignment.") : qsTr("&Right", "Editor actions. Text alignment.")
                    enabled: Qt.application.layoutDirection===Qt.LeftToRight ? viewport.prompter.document.alignment !== Qt.AlignLeft : viewport.prompter.document.alignment !== Qt.AlignRight
                    onTriggered: viewport.prompter.document.alignment = Qt.AlignLeft
                }
                MenuItem {
                    text: qsTr("C&enter", "Editor actions. Text alignment.")
                    enabled: !(viewport.prompter.document.alignment === Qt.AlignHCenter || (viewport.prompter.document.alignment !== Qt.AlignLeft && viewport.prompter.document.alignment !== Qt.AlignRight/*&& viewport.prompter.document.alignment !== Qt.AlignJustify*/))
                    onTriggered: viewport.prompter.document.alignment = Qt.AlignHCenter
                }
                MenuItem {
                    text: Qt.application.layoutDirection===Qt.LeftToRight ? qsTr("&Right", "Editor actions. Text alignment.") : qsTr("&Left", "Editor actions. Text alignment.")
                    enabled: Qt.application.layoutDirection===Qt.LeftToRight ? viewport.prompter.document.alignment !== Qt.AlignRight : viewport.prompter.document.alignment !== Qt.AlignLeft
                    onTriggered: viewport.prompter.document.alignment = Qt.AlignRight
                }
                //MenuItem {
                //    text: qsTr("Editor actions. Text alignment.", "&Justify")
                //    enabled: viewport.prompter.document.alignment !== Qt.AlignHustify
                //    onTriggered: viewport.prompter.document.alignment = Qt.AlignJustify
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
                checked: Qt.application.layoutDirection===Qt.LeftToRight ? viewport.prompter.document.alignment === Qt.AlignLeft : viewport.prompter.document.alignment === Qt.AlignRight
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
                checked: viewport.prompter.document.alignment === Qt.AlignHCenter
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
                checked: Qt.application.layoutDirection===Qt.LeftToRight ? viewport.prompter.document.alignment === Qt.AlignRight : viewport.prompter.document.alignment === Qt.AlignLeft
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
            //    checked: viewport.prompter.document.alignment === Qt.AlignJustify
            //    onClicked: textAlignmentMenu.popup(this)
            //}
            ToolSeparator {
                contentItem.visible: alignmentRowMobile.y === formatRow.y
            }
        }
        Row {
            id: formatRow
            visible: !toolbar.hideFormattingToolsAlways && (!root.__isMobile && showingFormattingTools || parseInt(viewport.prompter.state)===Prompter.States.Editing)
            ToolButton {
                id: boldButton
                text: "\uE802"
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                checkable: true
                checked: viewport.prompter.document.bold
                onClicked: viewport.prompter.document.bold = checked
            }
            ToolButton {
                id: italicButton
                text: "\uE803"
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                checkable: true
                checked: viewport.prompter.document.italic
                onClicked: viewport.prompter.document.italic = checked
            }
            ToolButton {
                id: underlineButton
                text: "\uF0CD"
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                checkable: true
                checked: viewport.prompter.document.underline
                onClicked: viewport.prompter.document.underline = checked
            }
            ToolButton {
                id: strikeOutButton
                text: "\uF0CC"
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                checkable: true
                checked: viewport.prompter.document.strike
                onClicked: viewport.prompter.document.strike = checked
            }
            ToolButton {
                id: verticalAlignmentButton
                text: viewport.prompter.document.superscript ? "Aᵃ" : "Aₐ"
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                checkable: true
                checked: viewport.prompter.document.subscript || viewport.prompter.document.superscript
                onClicked: {
                    if (viewport.prompter.document.subscript)
                        viewport.prompter.document.superscript = true
                    else if (viewport.prompter.document.superscript)
                        viewport.prompter.document.superscript = false
                    else
                        viewport.prompter.document.subscript = true
                }
            }
            //ToolButton {
            //    id: subscriptButton
            //    text: "Aₐ"
            //    contentItem: Loader { sourceComponent: textComponent }
            //    font.family: iconFont.name
            //    font.pointSize: 13
            //    focusPolicy: Qt.TabFocus
            //    checkable: true
            //    checked: viewport.prompter.document.subscript
            //    onClicked: viewport.prompter.document.subscript = checked
            //}
            //ToolButton {
            //    id: superscriptButton
            //    text: "Aᵃ"
            //    contentItem: Loader { sourceComponent: textComponent }
            //    font.family: iconFont.name
            //    font.pointSize: 13
            //    focusPolicy: Qt.TabFocus
            //    checkable: true
            //    checked: viewport.prompter.document.superscript
            //    onClicked: viewport.prompter.document.superscript = checked
            //}
            ToolSeparator {
                contentItem.visible: formatRow.y === fontRow.y
            }
        }
        Row {
            id: fontRow
            visible: !toolbar.hideFormattingToolsAlways && (!root.__isMobile && showingFormattingTools || parseInt(viewport.prompter.state)===Prompter.States.Editing)
            FontLoader {
                id: westernSeriousSansfFont
                source: "../fonts/DejaVuSans.ttf"
            }
            FontLoader {
                id: westernDyslexicFont
                source: "../fonts/OpenDyslexic-Bold.otf"
            }
            FontLoader {
                id: asianSeriousSansFont
                source: "../fonts/SourceHanSans-Regular.ttc"
            }
            FontLoader {
                id: arabicHumaneSansFont
                source: "../fonts/ScheherazadeNew-Regular.ttf"
            }
            FontLoader {
                id: devanagariSeriousSansFont
                source: "../fonts/Palanquin-Regular.ttf"
            }
            FontLoader {
                id: bengaliHumaneSerifFont
                source: "../fonts/Kalpurush.ttf"
            }
            Menu {
                id: fontSelectionMenu
                background: Rectangle {
                    color: "#DD000000"
                    implicitWidth: 280
                }
                MenuSeparator {}
                MenuItem {
                    text: qsTr("DejaVu (default, Roman, Cyrillic)", "FontName (Translatable font details)")
                    onTriggered: viewport.prompter.document.fontFamily = westernSeriousSansfFont.name
                }
                MenuItem {
                    text: qsTr("OpenDyslexic (Roman)", "FontName (Translatable font details)")
                    onTriggered: viewport.prompter.document.fontFamily = westernDyslexicFont.name
                }
                MenuItem {
                    text: qsTr("Source Han Sans (CH, JP, KO)", "FontName (Translatable font details)")
                    onTriggered: viewport.prompter.document.fontFamily = asianSeriousSansFont.name
                }
                MenuItem {
                    text: qsTr("Scheherazade New (Arabic)", "FontName (Translatable font details)")
                    onTriggered: viewport.prompter.document.fontFamily = arabicHumaneSansFont.name
                }
                MenuItem {
                    text: qsTr("Palanquin (Devangari)", "FontName (Translatable font details)")
                    onTriggered: viewport.prompter.document.fontFamily = devanagariSeriousSansFont.name
                }
                MenuItem {
                    text: qsTr("Kalpurush (Bengali)", "FontName (Translatable font details)")
                    onTriggered: viewport.prompter.document.fontFamily = bengaliHumaneSerifFont.name
                }
                MenuSeparator {}
                MenuItem {
                    id: systemFontButton
                    text: qsTr("Choose System Font", "Opens system font selection dialog")
                    // Not using isMobile here, because Linux phones, unlike all others, would provide access to system fonts.
                    enabled: ['android', 'ios', 'wasm', 'tvos', 'qnx', 'ipados'].indexOf(Qt.platform.os)===-1
                    visible: enabled
                    onTriggered: {
                        if (prompterPage.document.showFontDialog())
                            showPassiveNotification(qsTr("No glyphs selected…"));
                    }
                }
                MenuSeparator {
                    visible: systemFontButton.enabled
                }
            }
            ToolButton {
                id: fontFamilyToolButton
                text: "\uE805"
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
                onClicked: {
                    fontSelectionMenu.popup(this)
                }
            }
            ToolButton {
                id: textColorButton
                text: "\uE83F" /*uF1FC*/
                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: parent.down ? Kirigami.Theme.positiveTextColor : (parent.checked ? Kirigami.Theme.focusColor : Kirigami.Theme.textColor)
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
                font.family: iconFont.name
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                onClicked: {
                    colorDialog.color = viewport.prompter.textColor;
                    colorDialog.open();
                }
                Rectangle {
                    width: aFontMetrics.width + 3
                    height: 2
                    color: viewport.prompter.document.textColor
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
                    color: parent.down ? Kirigami.Theme.positiveTextColor : (parent.checked ? Kirigami.Theme.focusColor : Kirigami.Theme.textColor)
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
                font.family: iconFont.name
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                onClicked: {
                    highlightDialog.color = Qt.rgba(0,0,0,0);
                    // if (Qt.colorEqual(highlightDialog.color, "#000000"))
                    //     highlightDialog.color = Qt.rgba(0,0,0,0);
                    // else
                    //     highlightDialog.color = viewport.prompter.textBackground;
                    highlightDialog.open();
                }
                Rectangle {
                    width: bFontMetrics.width + 3
                    height: 2
                    color: viewport.prompter.document.textBackground
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
                contentItem.visible: mobileOrSmallScreen ? fontRow.y === advancedButtonsRow.y : fontRow.y === alignmentRowDesktop.y
            }
        }
        Row {
            id: alignmentRowDesktop
            visible: !toolbar.hideFormattingToolsAlways && !mobileOrSmallScreen && (showingFormattingTools || parseInt(viewport.prompter.state)===Prompter.States.Editing)
            ToolButton {
                id: alignLeftButton
                text: Qt.application.layoutDirection===Qt.LeftToRight ? "\uE808" : "\uE80A"
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                checkable: true
                checked: Qt.application.layoutDirection===Qt.LeftToRight ? viewport.prompter.document.alignment === Qt.AlignLeft : viewport.prompter.document.alignment === Qt.AlignRight
                onClicked: {
                    if (Qt.application.layoutDirection===Qt.LeftToRight)
                        viewport.prompter.document.alignment = Qt.AlignLeft
                    else
                        viewport.prompter.document.alignment = Qt.AlignRight
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
                checked: viewport.prompter.document.alignment === Qt.AlignHCenter
                onClicked: viewport.prompter.document.alignment = Qt.AlignHCenter
            }
            ToolButton {
                id: alignRightButton
                text: Qt.application.layoutDirection===Qt.LeftToRight ? "\uE80A" : "\uE808"
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                checkable: true
                checked: Qt.application.layoutDirection===Qt.LeftToRight ? viewport.prompter.document.alignment === Qt.AlignRight : viewport.prompter.document.alignment === Qt.AlignLeft
                onClicked: {
                    if (Qt.application.layoutDirection===Qt.LeftToRight)
                        viewport.prompter.document.alignment = Qt.AlignRight
                        else
                            viewport.prompter.document.alignment = Qt.AlignLeft
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
            //    checked: viewport.prompter.document.alignment === Qt.AlignJustify
            //    onClicked: viewport.prompter.document.alignment = Qt.AlignJustify
            //}
            ToolSeparator {
                contentItem.visible: alignmentRowDesktop.y === advancedButtonsRow.y
            }
        }
        Row {
            id: advancedButtonsRow
            //visible: parseInt(viewport.prompter.state)===Prompter.States.Editing
            ToolButton {
                id: wheelThrottleSettingsButton
                visible: !(Qt.platform.os==="android" || Qt.platform.os==="ios")
                text: "\uE7FF"
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                checked: viewport.prompter.document.namedMarker
                checkable: true
                onClicked: wheelSettings.open()
            }
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
            //ToolButton {
                //id: __iDefaultButton
                //visible: root.__isMobile ? showAnimationConfigOptions : true
                //text: "\uE858"
                //contentItem: Loader { sourceComponent: textComponent }
                //font.family: iconFont.name
                //font.pointSize: 13
                //focusPolicy: Qt.TabFocus
                //checkable: true
                //checked: stepsConfiguration.opened
                //onClicked: stepsConfiguration.open()
            //}
        }
        RowLayout {
            id: velocityRow
            enabled: parseInt(viewport.prompter.state)===Prompter.States.Prompting
            visible: !root.__isMobile && root.width>1481 /*&& (showingFormattingTools || ! toolbar.hideFormattingToolsAlways)*/ || enabled
            ToolButton {
                id: positiveVelocity
                text: "\u002B"
                visible: showSliderIcons
                enabled: velocityControlSlider.enabled
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
                focusPolicy: Qt.TabFocus
                checkable: true
                checked: true
            }
            Label {
                text: qsTr("Velocity <pre>%1</pre>", "Velocity {VELOCITY_STEPS}").arg(viewport.prompter.__i<0 ? '-' + (viewport.prompter.__i/100).toFixed(2).slice(3) : '+' + (viewport.prompter.__i/100).toFixed(2).slice(2))
                color: Kirigami.Theme.textColor
                Layout.topMargin: 4
                Layout.bottomMargin: -14
                Layout.rightMargin: 3
                Layout.leftMargin: showSliderIcons ? 1 : 8
            }
            Slider {
                id: velocityControlSlider
                value: viewport.prompter.__i
                to: 20
                from: positiveVelocity.checked ? 0 : -velocityControlSlider.to
                stepSize: 1
                focusPolicy: Qt.TabFocus
                onMoved: {
                    if (!(viewport.prompter.__atEnd && value>=0 || viewport.prompter.__atStart && value<0)) {
                        viewport.prompter.__i = value
                        viewport.prompter.__play = true
                        viewport.prompter.position = viewport.prompter.__destination
                    }
                }
            }
        }
        RowLayout {
            visible: root.__translucidBackground && (!root.__isMobile && root.width>(!showingFormattingTools||hideFormattingToolsAlways ? 1195 : 994) || (parseInt(viewport.prompter.state)!==Prompter.States.Editing && parseInt(viewport.prompter.state)!==Prompter.States.Prompting)) // This check isn't optimized in case more viewport.prompter states get added in the future, even tho I think that is unlikely.
            ToolButton {
                id: windowStayOnTopButton
                readonly property bool value: checked && enabled
                visible: !root.__isMobile && showSliderIcons
                text: "\uE810"
                enabled: root.__opacity < 1
                checkable: true
                checked: true
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
            }
            Label {
                text: qsTr("Opacity <pre>%1</pre>", "Opacity {TRANSPARENCY_PERCENTAGE}").arg((root.__opacity/10).toFixed(3).slice(2))
                color: Kirigami.Theme.textColor
                Layout.topMargin: 4
                Layout.bottomMargin: -14
                Layout.rightMargin: 3
                Layout.leftMargin: showSliderIcons ? 1 : 8
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
            height: (parseInt(viewport.prompter.state)===Prompter.States.Editing) ? implicitHeight : 0
            clip: true
            ToolButton {
                enabled: !fontSizeDirectInput.editText
                text: "\uF088"
                //visible: showSliderIcons
                checkable: true
                checked: !viewport.prompter.wysiwyg
                onClicked: {
                    viewport.prompter.toggleWysiwyg()
                    paragraphSpacingSlider.update()
                }
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
            }
            MouseArea {
                id: fontSizeDirectInput
                property bool editText: false
                height: fontSizeLabel.height
                width: fontSizeDirectInput.editText ? fontSizeTextField.width : fontSizeLabel.width
                onDoubleClicked: {
                    fontSizeDirectInput.editText = true;
                }
                function percentageFromFontSize(fontSize: double): double {
                    if (viewport.prompter.wysiwyg)
                        // Inverse of: fontSize = (Math.pow(editorToolbar.fontSizeSlider.value/185,4)*185)*prompter.__vw/10
                        return Math.pow((fontSize * 10 / prompter.__vw) / 185, 1/4) * 185
                    else
                        // Inverse of: fontSize = (Math.pow(editorToolbar.fontSizeSlider.value/185,4)*185)
                        return Math.pow(fontSize / 185, 1/4) * 185
                }
                TextField {
                    id: fontSizeTextField
                    anchors.fill: parent
                    visible: fontSizeDirectInput.editText
                    readOnly: !visible
                    text: ""
                    onVisibleChanged: {
                        if (visible)
                            text = viewport.prompter.fontSize;
                    }
                    onAccepted: {
                        const value = fontSizeDirectInput.percentageFromFontSize(text);
                        if (value > 0) {
                            if (viewport.prompter.wysiwyg)
                                fontWYSIWYGSizeSlider.value = value;
                            else
                                fontSizeSlider.value = value;
                        }
                    }
                    onEditingFinished: {
                        fontSizeDirectInput.editText = false;
                    }
                    Material.theme: Material.Dark
                }
                Label {
                    id: fontSizeLabel
                    visible: !fontSizeDirectInput.editText
                    text: viewport.prompter.wysiwyg ?
                              qsTr("Font size <pre>%1 (%2)</pre>", "Font size 100% (083)").arg((fontWYSIWYGSizeSlider.value/1440).toFixed(3).slice(2)).arg((viewport.prompter.fontSize/1000).toFixed(3).slice(2))
                            : qsTr("Font size <pre>%1 (%2)</pre>", "Font size 100% (083)").arg((fontSizeSlider.value/1000).toFixed(3).slice(2)).arg(viewport.prompter.fontSize)
                    color: Kirigami.Theme.textColor
                    Layout.topMargin: 4
                    Layout.bottomMargin: -14
                    Layout.rightMargin: 3
                    Layout.leftMargin: 1
                }
            }
            Slider {
                id: fontSizeSlider
                visible: !viewport.prompter.wysiwyg
                focusPolicy: Qt.TabFocus
                from: 90
                value: 100
                to: 158
                stepSize: 1
                onMoved: {
                    if (visible) {
                        paragraphSpacingSlider.update();
                        fontSizeDirectInput.editText = false;
                    }
                }
            }
            Slider {
                id: fontWYSIWYGSizeSlider
                visible: viewport.prompter.wysiwyg
                from: 90
                value: 144
                to: 180 // 200
                stepSize: 0.5
                focusPolicy: Qt.TabFocus
                onMoved: {
                    if (visible) {
                        paragraphSpacingSlider.update();
                        fontSizeDirectInput.editText = false;
                    }
                }
            }
        }
        RowLayout {
            visible: height>0
            height: showFontSpacingOptions ? implicitHeight : 0
            clip: true
            Behavior on height{
                enabled: true
                animation: NumberAnimation {
                    duration: Units.ShortDuration
                    easing.type: Easing.OutQuad
                }
            }
            ToolButton {
                text: "\uE806"
                visible: showSliderIcons
                enabled: false
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
            }
            Label {
                text: qsTr("Line height <pre>%1%</pre>", "Line height 100%").arg((lineHeightSlider.value/1000).toFixed(3).slice(2))
                color: Kirigami.Theme.textColor
                Layout.topMargin: 4
                Layout.bottomMargin: -14
                Layout.rightMargin: 3
                Layout.leftMargin: showSliderIcons ? 1 : 8
            }
            Slider {
                id: lineHeightSlider
                from: 85
                value: 100
                to: 180
                stepSize: 1
                focusPolicy: Qt.TabFocus
                onMoved: lineHeightSlider.update()
                function update() {
                    viewport.prompter.document.setLineHeight(value)
                }
            }
        }
        RowLayout {
            visible: height>0
            height: showFontSpacingOptions ? implicitHeight : 0
            clip: true
            Behavior on height{
                enabled: true
                animation: NumberAnimation {
                    duration: Units.ShortDuration
                    easing.type: Easing.OutQuad
                }
            }
            ToolButton {
                text: "\uE806"
                visible: showSliderIcons
                enabled: false
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
            }
            Label {
                text: qsTr("Paragraph spacing <pre>%1%</pre>", "Paragraph spacing ±00").arg((paragraphSpacingSlider.value/10).toFixed(3).slice(2))
                color: Kirigami.Theme.textColor
                Layout.topMargin: 4
                Layout.bottomMargin: -14
                Layout.rightMargin: 3
                Layout.leftMargin: showSliderIcons ? 1 : 8
            }
            Slider {
                id: paragraphSpacingSlider
                from: 0
                value: 0
                to: 2.0
                stepSize: 0.01
                focusPolicy: Qt.TabFocus
                onMoved: update()
                function update() {
                    viewport.prompter.document.setParagraphHeight(viewport.prompter.fontSize * value)
                }
            }
        }
        RowLayout {
            visible: height>0
            height: showFontSpacingOptions ? implicitHeight : 0
            clip: true
            Behavior on height{
                enabled: true
                animation: NumberAnimation {
                    duration: Units.ShortDuration
                    easing.type: Easing.OutQuad
                }
            }
            ToolButton {
                text: "\uE807" // W
                visible: showSliderIcons
                enabled: false
                flat: true
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
            }
            Label {
                text: qsTr("Word spacing <pre>%1</pre>", "Word spacing <pre>±00<pre>").arg((wordSpacingSlider.value<0 ? '-' + (wordSpacingSlider.value/100).toFixed(2).slice(3) : '+' + (wordSpacingSlider.value/100).toFixed(2).slice(2)))
                color: Kirigami.Theme.textColor
                Layout.topMargin: 4
                Layout.bottomMargin: -14
                Layout.rightMargin: 3
                Layout.leftMargin: showSliderIcons ? 1 : 8
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
                    duration: Units.ShortDuration
                    easing.type: Easing.OutQuad
                }
            }
            ToolButton {
                text: "\uE807"
                visible: showSliderIcons
                enabled: false
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
            }
            Label {
                text: qsTr("Letter spacing <pre>%1</pre>", "Letter spacing ±00").arg((letterSpacingSlider.value<0 ? '-' + (letterSpacingSlider.value/100).toFixed(2).slice(3) : '+' + (letterSpacingSlider.value/100).toFixed(2).slice(2)))
                color: Kirigami.Theme.textColor
                Layout.topMargin: 4
                Layout.bottomMargin: -14
                Layout.rightMargin: 3
                Layout.leftMargin: showSliderIcons ? 1 : 8
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
                    duration: Units.ShortDuration
                    easing.type: Easing.OutQuad
                }
            }
            ToolButton {
                text: "\uE846"
                visible: showSliderIcons
                enabled: false
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
            }
            Label {
                text: qsTr("Step speed <pre>%1</pre>", "Step speed 1.00").arg((baseSpeedSlider.value/100).toFixed(2))
                color: Kirigami.Theme.textColor
                Layout.topMargin: 4
                Layout.bottomMargin: -14
                Layout.rightMargin: 3
                Layout.leftMargin: showSliderIcons ? 1 : 8
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
                    viewport.prompter.focus = true;
                    viewport.prompter.position = viewport.prompter.__destination
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
                    duration: Units.ShortDuration
                    easing.type: Easing.OutQuad
                }
            }
            ToolButton {
                text: "\uE846"
                visible: showSliderIcons
                enabled: false
                contentItem: Loader { sourceComponent: textComponent }
                font.family: iconFont.name
                font.pointSize: 13
            }
            Label {
                text: qsTr("Step acceleration <pre>%1</pre>", "Step acceleration 1.15").arg((baseAccelerationSlider.value/100).toFixed(2))
                color: Kirigami.Theme.textColor
                Layout.topMargin: 4
                Layout.bottomMargin: -14
                Layout.rightMargin: 3
                Layout.leftMargin: showSliderIcons ? 1 : 8
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
                    viewport.prompter.focus = true;
                    viewport.prompter.position = viewport.prompter.__destination
                }
            }
        }
        RowLayout {
            Button {
                visible: networkDialog.autoReloadRunning
                text: qsTr("Next reload starts at <pre>%1</pre>", "Next reload starts at 10:11:12").arg(networkDialog.nextReloadTime)
                onClicked: networkDialog.open()
                flat: true
                contentItem: Loader { sourceComponent: textComponent }
                Layout.topMargin: -8
                Layout.bottomMargin: -32
                Layout.rightMargin: 3
                Layout.leftMargin: showSliderIcons ? 1 : 8
            }
        }
    }
}
