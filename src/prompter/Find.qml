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
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import org.kde.kirigami 2.11 as Kirigami

Item {
    property var document
    property bool isOpen: false
    height: isOpen && parseInt(prompter.state)!==Prompter.States.Prompting && parseInt(prompter.state)!==Prompter.States.Countdown ? find.implicitHeight : 0
    visible: height>0
    enabled: visible
    readonly property int searchBarWidth: 660
    readonly property int searchBarMargin: 6
    enum Mode {
        Match,
        Previous,
        Next
    }
    anchors.leftMargin: viewport.width<608 ? 4 : searchBarMargin
    anchors.rightMargin: viewport.width<608 ? 32 : (viewport.width < searchBarWidth ? searchBarMargin : viewport.width - searchBarWidth + searchBarMargin)
    anchors.left: parent.left
    anchors.right: parent.right
    // I am aware that manipulating Y is slower to process, but dynamically switching between top and bottom anchoring is not an option because it overrides height.
    y: Kirigami.Settings.isMobile || overlay.__readRegionPlacement > 0.5 ? 0-find.implicitHeight+height : parent.height-height
    Rectangle {
        id: background
        anchors.left: find.left
        anchors.right: find.right
        anchors.leftMargin: -8
        anchors.rightMargin: -12
        height: Kirigami.Settings.isMobile || overlay.__readRegionPlacement > 0.5 ? find.height : find.height+this.radius
        radius: 12
        opacity: 0.96
        color: "#262626"
        border.width: 2
        border.color: "#222"
        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }
    }
    Behavior on height {
        enabled: true
        animation: NumberAnimation {
            duration: Kirigami.Units.shortDuration
            easing.type: Easing.OutQuad
        }
    }
    RowLayout {
        id: find
        anchors.fill: parent
        spacing: 6
        Button {
            text: "\u24CD"
            flat: true
            onClicked: close()
            Layout.fillHeight: true
        }
        TextField {
            id: searchField
            placeholderText: i18n("Search")
            wrapMode: TextInput.WordWrap
            onTextEdited: find.search(text, Find.Mode.Match)
            selectByMouse: true
            Layout.fillWidth: true
            Keys.onReturnPressed: {
                if (event.modifiers & Qt.ShiftModifier)
                    return find.previous()
                return find.next()
            }
            Keys.onEscapePressed: close()
        }
        Button {
            text: "\u25B2"
            onClicked: find.previous()
        }
        Button {
            text: "\u25BC"
            onClicked: find.next()
        }
        function next() {
            find.search(searchField.text, Find.Mode.Next)
        }
        function previous() {
            find.search(searchField.text, Find.Mode.Previous)
        }
        function search(text, mode) {
            var range
            switch (mode) {
                case Find.Mode.Match:
                    range = document.search(text); break;
                case Find.Mode.Previous:
                    range = document.search(text, false, true); break;
                case Find.Mode.Next:
                    range = document.search(text, true); break;
            }
            if (range.y > range.x)
                editor.select(range.x, range.y)
            else
                editor.cursorPosition = range.x
            if (text.length>0)
                prompter.position = editor.cursorRectangle.y - (overlay.__readRegionPlacement*(overlay.height-overlay.readRegionHeight)+overlay.readRegionHeight/2) + 1
        }
    }
    function focusSearch() {
        if (isOpen) {
            searchField.text = editor.selectedText
            searchField.focus = true
        }
        else {
            // Clear search
            editor.cursorPosition = document.selectionStart
            editor.focus = true
        }
    }
    function toggle() {
        isOpen = !visible
        focusSearch()
    }
    function open() {
        isOpen = true
        focusSearch()
    }
    function close() {
        isOpen = false
        focusSearch()
    }
}
