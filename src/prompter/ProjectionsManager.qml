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

import QtQuick 2.15
import org.kde.kirigami 2.9 as Kirigami
import QtQuick.Window 2.15

Item {
    id: projectionManager
    readonly property alias model: projectionModel

    property real backgroundOpacity: 1
    property color backgroundColor: "#000"
    property bool reScale: true

    Component {
        id: projectionDelegte
        Window {
            id: projectionWindow
            title: i18n("Projection Window")
            transientParent: root
            x: model.x
            y: model.y
            width: model.width
            height: model.height
            flags: Qt.FramelessWindowHint
            visibility: Kirigami.ApplicationWindow.FullScreen
            visible: true
            color: "transparent"
            MouseArea {
                anchors.fill:parent
                cursorShape: Qt.ForbiddenCursor
                Rectangle {
                    color: backgroundColor
                    opacity: backgroundOpacity
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.left: parent.left
                    anchors.bottom: img.top
                }
                Rectangle {
                    color: backgroundColor
                    opacity: backgroundOpacity
                    anchors.top: img.bottom
                    anchors.right: parent.right
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                }
                Image {
                    id: img
                    source: model.p
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: (width/sourceSize.width) * sourceSize.height
                    fillMode: reScale ? Image.PreserveAspectFit : Image.Pad
                    asynchronous: true
                    cache: !reScale
                    mirror: model.flip===2 || model.flip===4
                }
            }
            onClosing: {
                projectionModel.clear()
            }
        }
    }

    ListModel {
        id: projectionModel
    }

    ListModel {
        id: displayModel
    }

    Instantiator {
        id: projections
        model: projectionModel
        asynchronous: true
        delegate: projectionDelegte
    }

    function getDisplayFlip(screenName, flipSetting) {
        const totalDisplays = displayModel.count;
        for (var j=0; j<totalDisplays; j++)
            if (displayModel.get(j).name===screenName)
                return displayModel.get(j).flipSetting
        return 0
    }

    function putDisplayFlip(screenName, flipSetting) {
        // If configuration exists for element, update it.
        const totalDisplays = displayModel.count;
        for (var j=0; j<totalDisplays; j++)
            if (displayModel.get(j).name===screenName) {
                displayModel.get(j).flipSetting = flipSetting;
                console.log(displayModel)
                return;
            }
        // If configuration does not exists, add it.
        displayModel.append({
            "name": screenName,
            "flipSetting": flipSetting
        });
        console.log(displayModel)
    }

    function project() {
        console.log("Creating projections")
        projectionModel.clear();
        var flip = 0;
        const totalDisplays = displayModel.count;
        for (var i=0; i<Qt.application.screens.length; i++) {
            for (var j=0; j<totalDisplays; j++)
                if (Qt.application.screens[i].name===displayModel.get(j).name) {
                    flip = displayModel.get(j).flipSetting;
                    break;
                }
                else 
                    flip = 0;
            //if (Qt.application.screens[i].name!==screen.name)
            projectionModel.append ({
                "id": i,
                "name": Qt.application.screens[i].name, // + ' ' + Qt.application.screens[i].model + ' ' + Qt.application.screens[i].manufacturer,
                "x": Qt.application.screens[i].virtualX,
                "y": Qt.application.screens[i].virtualY,
                "width": Qt.application.screens[i].desktopAvailableWidth,
                "height": Qt.application.screens[i].desktopAvailableHeight,
                "flip": flip,//.projectionSetting,
                "p": ""
            });
        }
    }

}
