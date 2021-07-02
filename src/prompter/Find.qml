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

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.9 as Kirigami

Rectangle {
    property var document
    property bool isOpen: false
    width: find.implicitWidth
    height: isOpen ? find.implicitHeight : 0
    anchors.leftMargin: 87
    anchors.left: parent.left
    anchors.bottom: parent.bottom
    color: "#222"
    Behavior on height {
        enabled: true
        animation: NumberAnimation {
            duration: Kirigami.Units.shortDuration
            easing.type: Easing.OutQuad
        }
    }
    RowLayout {
        id: find
        Button {
            text: "\u24CD"
            flat: true
            onClicked: close()
        }
        TextField {
            id: searchField
            width: 320
            placeholderText: i18n("Search text")
            onTextEdited: {
                find.search(text)
            }
            onAccepted: {
                if (Keys.modifiers & Qt.ShiftModifier)
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
            console.log("Search next")
        }
        function previous() {
            console.log("Search previous")
        }
        function search(text) {
            console.log(text)
        }
    }
    function focusSearch() {
        if (isOpen)
            searchField.focus = true
    }
    function toggle() {
        isOpen = !isOpen
        focusSearch()
    }
    function open() {
        isOpen = true
        focusSearch()
    }
    function close() {
        isOpen = false
    }
}
