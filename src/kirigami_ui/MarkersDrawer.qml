/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2021 Javier O. Cordero Pérez
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

Kirigami.OverlayDrawer {
    id: sideDrawer
    background: Rectangle {
        color: "#282828" // appTheme.__backgroundColor
        opacity: 0.92
    }
    width: 260
    //width: popupContent.implicitWidth
    modal: true
    handleVisible: false
    edge: Qt.application.layoutDirection===Qt.LeftToRight ? Qt.LeftEdge : Qt.RightEdge
    leftPadding: 0
    rightPadding: 0
    bottomPadding: 0
    topPadding: 0
    parent: prompterPage.viewport

    function toggle() {
        if (drawerOpen)
            close()
        else {
            prompter.document.parse()
            open()
        }
    }

    Component {
        id: markerDelegateComponent
        Kirigami.SwipeListItem {
            supportsMouseEvents: true
            onPressed: prompter.goTo(model.position)
            Label {
                text: model.text
            }
            /*actions: [
            Kirigami.Action {
                icon.name: "document-properties"
                onTriggered: {
                    print("Edit clicked")
                    // Select marker in document
                    // Open marker edit dialog
                }
            },
            Kirigami.Action {
                enabled: model.link !== ""
                icon.name: "insert-link"
                onTriggered: {
                    print("Test link")
                    // Send test HTTP request
                }
            }
            ]*/
        }
    }

    ColumnLayout {
        id: popupContent
        width: parent.width
        height: parent.height
        spacing: 0
        ListView {
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: 2
            model: prompterPage.document.markers()
            delegate: markerDelegateComponent
            clip: true
            ScrollBar.vertical: ScrollBar { }
        }
        Kirigami.BasicListItem {
            Layout.alignment: Qt.AlignBottom
            icon: Qt.application.layoutDirection===Qt.LeftToRight ? "view-left-close" : "view-right-close"
            text: i18n("Close Marker List")
            onClicked: {
                sideDrawer.close();
                console.log(prompterPage.document.markers())
                //console.log(prompterPage.document.markers)
            }
        }
    }
}
