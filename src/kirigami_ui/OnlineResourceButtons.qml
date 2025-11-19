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
import QtQuick.Layouts 1.12

RowLayout {
    id: row
    spacing: 0
    ToolButton {
        readonly property url uri: "https://qprompt.app"
        icon.source: "qrc:/qt/qml/com/cuperino/qprompt/icons/map-globe.svg"
        flat: true
        onClicked: Qt.openUrlExternally(uri)
        ToolTip.text: qsTr("Website")
        Layout.fillWidth: true
    }
    ToolButton {
        readonly property url uri: "https://docs.qprompt.app"
        icon.source: "qrc:/qt/qml/com/cuperino/qprompt/icons/insert-endnote.svg"
        flat: true
        onClicked: Qt.openUrlExternally(uri)
        ToolTip.text: qsTr("Documentation")
        Layout.fillWidth: true
    }
    ToolButton {
        readonly property url uri: "https://forum.qprompt.app"
        icon.source: "qrc:/qt/qml/com/cuperino/qprompt/icons/question.svg"
        flat: true
        onClicked: Qt.openUrlExternally(uri)
        ToolTip.text: qsTr("Forum")
        Layout.fillWidth: true
    }
    ToolButton {
        readonly property url uri: "https://feedback.qprompt.app"
        icon.source: "qrc:/qt/qml/com/cuperino/qprompt/icons/tools-report-bug.svg"
        flat: true
        onClicked: Qt.openUrlExternally(uri)
        ToolTip.text: qsTr("Feedback")
        Layout.fillWidth: true
    }
    ToolButton {
        readonly property url uri: "https://l10n.qprompt.app"
        icon.source: "qrc:/qt/qml/com/cuperino/qprompt/icons/amarok_change_language.svg"
        flat: true
        onClicked: Qt.openUrlExternally(uri)
        ToolTip.text: qsTr("Translations")
        Layout.fillWidth: true
    }
    ToolButton {
        readonly property url uri: "https://donate.qprompt.app"
        icon.source: "qrc:/qt/qml/com/cuperino/qprompt/icons/love-amarok.svg"
        flat: true
        onClicked: Qt.openUrlExternally(uri)
        ToolTip.text: qsTr("Donate")
        Layout.fillWidth: true
    }
}
