/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2025 Javier O. Cordero Pérez
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
import QtQuick.Controls 2.12

Row {
    Button {
        readonly property url uri: "https://qprompt.app"
        text: "🌐"
        flat: true
        onClicked: Qt.openUrlExternally(uri)
    }
    Button {
        readonly property url uri: "https://docs.qprompt.app"
        text: "🕮"
        flat: true
        onClicked: Qt.openUrlExternally(uri)
    }
    Button {
        readonly property url uri: "https://forum.qprompt.app"
        text: "?"
        flat: true
        onClicked: Qt.openUrlExternally(uri)
    }
    Button {
        readonly property url uri: "https://feedback.qprompt.app"
        text: "🐛"
        flat: true
        onClicked: Qt.openUrlExternally(uri)
        ToolTip.text: uri
    }
    Button {
        readonly property url uri: "https://l10n.qprompt.app"
        text: "🗺"
        flat: true
        onClicked: Qt.openUrlExternally(uri)
    }
    Button {
        readonly property url uri: "https://donate.qprompt.app"
        text: "$"
        flat: true
        onClicked: Qt.openUrlExternally(uri)
    }
}
