/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2021-2022 Javier O. Cordero Pérez
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
    id: markersDrawer
    property bool reOpen: false
    background: Rectangle {
        color: Qt.rgba(Kirigami.Theme.backgroundColor.r/2, Kirigami.Theme.backgroundColor.g/2, Kirigami.Theme.backgroundColor.b/2, 1)
        // color: appTheme.__backgroundColor
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
        reOpen = false
        if (drawerOpen) {
            close()
        }
        else {
            prompter.document.parse()
            open()
        }
        prompter.restoreFocus()
    }

    Component {
        id: markerDelegateComponent
        Kirigami.SwipeListItem {
            supportsMouseEvents: true
            onPressed: prompter.goTo(model.position)
            Label {
                text: (model.keyLetter ? "(" + model.keyLetter + ") " : "") + model.text
            }
            actions: [
            /*Kirigami.Action {
                enabled: model.url !== "#"
                //visible: enabled
                visible: false
                icon.name: "link"
                onTriggered: {
                    print("URL:", model.url)
                    print("Key:", model.key)
                    // Send test HTTP request
                }
            },*/
            Kirigami.Action {
                visible: !(Qt.platform.os==="android" || Qt.platform.os==="ios")
                icon.name: "document-properties"
                icon.source: "qrc:/icons/document-properties.svg"
                onTriggered: {
                    print("Edit clicked", model.position)
                    // Select marker in document
                    prompter.editMarker(model.position, model.length)
                    reOpen = true;
                    markersDrawer.close()
                    // Open marker edit dialog
                }
            }
            ]
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
            //icon: Qt.application.layoutDirection===Qt.LeftToRight ? "view-left-close" : "view-right-close"
            icon: Qt.application.layoutDirection===Qt.LeftToRight ? "qrc:/icons/view-left-close.svg" : "qrc:/icons/view-right-close.svg"
            text: i18nc("Close sidebar listing user defined markers", "Close Marker List")
            onClicked: {
                markersDrawer.toggle();
                //console.log(prompterPage.document.markers())
            }
        }
    }
}
