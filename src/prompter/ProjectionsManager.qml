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
import org.kde.kirigami 2.11 as Kirigami
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.2
import Qt.labs.settings 1.0

Item {
    id: projectionManager
    readonly property alias model: projectionModel

    property int defaultDisplayMode: 0
    property real backgroundOpacity: 1
    readonly property real internalBackgroundOpacity: backgroundOpacity // /2+0.5
    property color backgroundColor: "#000"
    property bool reScale: true
    property bool isPreview: false
    property var forwardTo // prompter

    Settings {
        category: "projections"
        property alias scale: projectionManager.reScale
        property alias projections: projectionModel
    }

    Component {
        id: projectionDelegte
        Window {
            id: projectionWindow
            title: i18n("Projection Window")
            //transientParent: root
            screen: model.screen
            modality: Qt.NonModal
            //x: model.x
            //y: model.y
            //width: model.width
            //height: model.height
            visibility: Qt.platform.os==="osx" ? Kirigami.ApplicationWindow.Maximized : Kirigami.ApplicationWindow.FullScreen
            flags: root.flags
            visible: true
            color: "transparent"

            MouseArea {
                enabled: true
                anchors.fill:parent
                Rectangle {
                    id: topFill
                    color: backgroundColor
                    opacity: internalBackgroundOpacity
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.left: parent.left
                    anchors.bottom: img.top
                }
                Rectangle {
                    id: bottomFill
                    color: backgroundColor
                    opacity: internalBackgroundOpacity
                    anchors.top: img.bottom
                    anchors.right: parent.right
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                }
                Rectangle {
                    id: rightFill
                    color: backgroundColor
                    opacity: internalBackgroundOpacity
                    anchors.top: topFill.bottom
                    anchors.right: parent.right
                    anchors.bottom: bottomFill.top
                    anchors.left: img.left
                }
                Rectangle {
                    id: leftFill
                    color: backgroundColor
                    opacity: internalBackgroundOpacity
                    anchors.top: topFill.bottom
                    anchors.right: img.right
                    anchors.bottom: bottomFill.top
                    anchors.left: parent.left
                }
                // Additional opaque rectangles over but not inside of the surrounding rectangles prevents borders from becoming fully transparent when opacity is set to 0.
                Rectangle {
                    anchors.fill: topFill
                    color: "black"
                    opacity: 0.6
                }
                Rectangle {
                    anchors.fill: bottomFill
                    color: "black"
                    opacity: 0.6
                }
                Rectangle {
                    anchors.fill: rightFill
                    color: "black"
                    opacity: 0.6
                }
                Rectangle {
                    anchors.fill: leftFill
                    color: "black"
                    opacity: 0.6
                }
                // The actual projection
                Image {
                    id: img
                    source: model.p
                    // Keep loading asynchronous. Improve responsiveness of main thread.
                    asynchronous: true
                    // Cache image if it's not being re-scaled so it could be used on n projection without much additional cost.
                    cache: !reScale
                    // Mirror Horizontally: Save time by mirroring image on copy instead of flipping the result
                    mirror: model.flip===2 || model.flip===4
                    // Mirror Vertically: do a transformation for the vertical flip. There's no trick to get a performance gain here.
                    transform: Scale {
                        origin.y: img.paintedHeight/2
                        yScale: model.flip===3 || model.flip===4 ? -1 : 1
                    }
                    // Keep image vertically centered relative to the window's MouseArea, which fills the window.
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    // Set width and height to source size depending on whether or not the image will be re-scaled.
                    fillMode: reScale ? Image.PreserveAspectFit : Image.Pad
                    width: !reScale ? sourceSize.width : parent.width
                    height: !reScale ? sourceSize.height : (parent.width/sourceSize.width) * sourceSize.height
                }
                cursorShape: projectionManager.isPreview ? Qt.ForbiddenCursor : Qt.PointingHandCursor
                onClicked: {
                    if (projectionManager.isPreview)
                        projectionWindow.close();
                    else
                        projectionManager.forwardTo.toggle()
                }

                onWheel: (wheel)=> {
                    projectionManager.forwardTo.mouse.wheel(wheel)
                }
                // Keyboard inputs
                focus: true
                Keys.onShortcutOverride: event.accepted = (event.key === Qt.Key_Escape)
                Keys.onEscapePressed: projectionWindow.close()
                Keys.forwardTo: projectionManager.forwardTo
            }
            onClosing: {
                projectionManager.isPreview = false;
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

    MessageDialog {
        id: alertDialog

        function requestDisplays() {
            alertDialog.text = i18n("For projection previews to display, you need at least one screen set to a projection setting other than \"Off\"")
            alertDialog.detailedText = ""
            alertDialog.icon = StandardIcon.Information
            alertDialog.visible = true
        }

        function warnSameDisplay(screenName) {
            alertDialog.text = i18n("You've enabled a screen projection on display \""+screenName+"\". Please note this projection will not show unless you place the editor on a different screen.")
            //alertDialog.text = i18n("QPrompt will not project to the screen where the editor is at.")
            //alertDialog.detailedText = i18n("You've enabled a screen projection on display \""+screenName+"\". Please note this projection will not show unless you place the editor on a different screen.")
            alertDialog.icon = StandardIcon.Warning
            alertDialog.visible = true
        }
    }

    function getDisplayFlip(screenName, flipSetting) {
        const totalDisplays = displayModel.count;
        for (var j=0; j<totalDisplays; j++)
            if (displayModel.get(j).name===screenName)
                return displayModel.get(j).flipSetting
        return this.defaultDisplayMode
    }

    function putDisplayFlip(screenName, flipSetting) {
//         if (flipSetting) {
//             if (Qt.application.screens.length===1)
//                 alertDialog.requestDisplays()
//             else
//             if (screenName===screen.name)
//                 alertDialog.warnSameDisplay(screenName)
//         }
        // Auto maximize main window on display flip selection.
        if (flipSetting && visibility!==Kirigami.ApplicationWindow.FullScreen)
            root.showMaximized()
        // If configuration exists for element, update it.
        const configuredDisplays = displayModel.count;
        for (var j=0; j<configuredDisplays; j++)
            if (displayModel.get(j).name===screenName) {
                displayModel.get(j).flipSetting = flipSetting;
                // console.log(displayModel)
                return;
            }
        // If configuration does not exists, add it.
        displayModel.append({
            "name": screenName,
            "flipSetting": flipSetting
        });
    }

    function project() {
        projectionModel.clear();
        var flip = this.defaultDisplayMode;
        const totalDisplays = displayModel.count;
        for (var i=0; i<Qt.application.screens.length; i++) {
            for (var j=0; j<totalDisplays; j++)
                if (Qt.application.screens[i].name===displayModel.get(j).name) {
                    flip = displayModel.get(j).flipSetting;
                    break;
                }
            // Comment the following line to debug with a single screen.
            if (flip!==0 /*&& Qt.application.screens[i].name!==screen.name*/)
                projectionModel.append ({
                    "id": i,
                    "screen": Qt.application.screens[i],
                    "name": Qt.application.screens[i].name, // + ' ' + Qt.application.screens[i].model + ' ' + Qt.application.screens[i].manufacturer,
                    //"x": Qt.application.screens[i].virtualX,
                    //"y": Qt.application.screens[i].virtualY,
                    //"width": Qt.application.screens[i].desktopAvailableWidth,
                    //"height": Qt.application.screens[i].desktopAvailableHeight,
                    "flip": flip,//.projectionSetting,
                    "p": ""
                });
        }
        if (projectionModel.count===0 && this.isPreview) {
            alertDialog.requestDisplays();
            this.isPreview = false;
        }
    }

    function close() {
        return projectionModel.clear()
    }

    function preview() {
        if (this.isPreview)
            this.close()
        this.isPreview = true;
        this.project();
    }
}
