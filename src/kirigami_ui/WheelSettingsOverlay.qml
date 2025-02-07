/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2022 Javier O. Cordero Pérez
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
import org.kde.kirigami 2.11 as Kirigami
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Kirigami.OverlaySheet {
    id: wheelSettings

    header: Kirigami.Heading {
        text: qsTr("Wheel and touchpad scroll settings")
        level: 1
    }

    ColumnLayout {
        RowLayout {
            Label {
                text: qsTr("Use scroll as velocity dial", "Label at wheel settings overlay")
            }
            Button {
                id: useScrollAsDialButton
                text: checked ? qsTr("On") : qsTr("Off")
                checkable: true
                checked: root.__scrollAsDial
                flat: true
                onClicked: root.__scrollAsDial = !root.__scrollAsDial
                Layout.fillWidth: true
                Layout.leftMargin: Kirigami.Units.smallSpacing
                Layout.rightMargin: Kirigami.Units.smallSpacing
            }
        }
        GridLayout {
            width: parent.width
            columns: 2
            ColumnLayout {
                Label {
                    text: qsTr("Enable throttling")
                }
                Button {
                    id: enableThrottleButton
                    text: checked ? qsTr("On") : qsTr("Off")
                    checkable: true
                    checked: root.__throttleWheel
                    flat: true
                    onClicked: root.__throttleWheel = !root.__throttleWheel
                    Layout.fillWidth: true
                    Layout.leftMargin: Kirigami.Units.smallSpacing
                    Layout.rightMargin: Kirigami.Units.smallSpacing
                }
            }
            ColumnLayout {
                enabled: root.__throttleWheel
                Label {
                    text: qsTr("Throttle factor");
                }
                SpinBox {
                    value: root.__wheelThrottleFactor
                    from: 1
                    onValueModified: {
                        focus: true
                        root.__wheelThrottleFactor = value
                    }
                    Layout.fillWidth: true
                    Layout.leftMargin: Kirigami.Units.smallSpacing
                    Layout.rightMargin: Kirigami.Units.smallSpacing
                }
            }
        }
        RowLayout {
            Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: qsTr("Enable throttling for use with touchpads, disable for precise scolling.")
                color: "#EED"
                Layout.leftMargin: Kirigami.Units.smallSpacing
                Layout.rightMargin: Kirigami.Units.smallSpacing
            }
        }
    }
}
