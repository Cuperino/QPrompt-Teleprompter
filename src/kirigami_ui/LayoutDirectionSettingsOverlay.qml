/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2023 Javier O. Cordero Pérez
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
import QtQuick.Controls.Material 2.12
import QtCore

Kirigami.OverlaySheet {
    property alias value: layoutSelector.highlightedIndex
    header: Kirigami.Heading {
        text: i18n("Layout direction")
        level: 1
    }
    ColumnLayout {
        RowLayout {
            Label {
                text: i18nc("Label at layout direction settings overlay", "Current layout")
            }
            ComboBox {
                id: layoutSelector
                property int initial: 0
                readonly property bool dirty: initial !== layoutSelector.currentIndex
                Settings {
                    category: "ui"
                    property alias layout: layoutSelector.currentIndex
                }
                model: ["Automatic (determined by the operating system)", "Right to Left", "Left to Right"]
                popup: Popup {
                    width: parent.width
                    implicitHeight: contentItem.implicitHeight
                    y: parent.height - 1
                    z: 103
                    padding: 1
                    contentItem: ListView {
                        clip: true
                        implicitHeight: contentHeight
                        model: layoutSelector.popup.visible ? layoutSelector.delegateModel : null
                        currentIndex: layoutSelector.currentIndex
                    }
                }
                onActivated: {
                    dirty = true;
                }
                Layout.fillWidth: true
                Material.theme: Material.Dark
                Component.onCompleted: {
                    initial = layoutSelector.currentIndex;
                }
            }
        }
    }
    onSheetOpenChanged: {
        if (!sheetOpen && layoutSelector.dirty)
            restartDialog.visible = true;
    }
}
