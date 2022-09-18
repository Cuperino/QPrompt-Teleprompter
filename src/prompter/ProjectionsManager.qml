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
import QtQuick.Controls 2.15
//import QtQuick.Dialogs
import Qt.labs.platform 1.1 as Labs
import QtQuick.Window 2.15
import QtQuick.Layouts 1.12
import Qt.labs.settings 1.0
Item {
    id: projectionManager
    readonly property alias model: projectionModel
    readonly property alias projections: projections
    readonly property alias alertDialog: alertDialog
    readonly property real internalBackgroundOpacity: backgroundOpacity // /2+0.5
    property int defaultDisplayMode: 0
    property real backgroundOpacity: 1
    property color backgroundColor: "#000"
    property bool reScale: true
    property bool isEnabled: false
    property string screensStringified: ""
    property var forwardTo // prompter

    function toggle() {
        isEnabled = !isEnabled;
        if (isEnabled) {
            project();
            const total = projectionModel.count;
            let count = 0;
            for (let i=0; i<total; ++i)
                if (projectionModel.get(i).flip!==0)
                    count++;
            console.log(count)
            if (count===0)
                alertDialog.requestDisplays()
        }
        else
            closeAll();
    }
    function getDisplayFlip(screenName, flipSetting) {
        const totalDisplays = displayModel.count;
        for (var j=0; j<totalDisplays; j++)
            if (displayModel.get(j).name===screenName)
                return displayModel.get(j).flipSetting
        return this.defaultDisplayMode
    }
    function putDisplayFlip(screenName, flipSetting) {
        // Auto maximize main window on display flip selection.
        if (flipSetting && Qt.platform.os!=='windows' && visibility!==Kirigami.ApplicationWindow.FullScreen && !Kirigami.Settings.isMobile)
            root.showMaximized()
        // If configuration exists for element, update it.
        const configuredDisplays = displayModel.count;
        for (var j=0; j<configuredDisplays; j++)
            if (displayModel.get(j).name===screenName) {
                //if (flipSetting && screenName===screen.name)
                    //displayModel.get(j).flipSetting = 0;
                //else
                    displayModel.get(j).flipSetting = flipSetting;
                return;
            }
        // If configuration does not exists, add it.
        displayModel.append({
            "name": screenName,
            "flipSetting": flipSetting
        });
    }
    function addMissingProjections() {
        const totalRegisteredDisplays = displayModel.count,
              totalProjectedDisplays = projectionModel.count;
        let count = 0;
        for (let i=0; i<totalRegisteredDisplays; i++)
            if (displayModel.get(i).flipSetting!==0)
                count++;
        // Alternative behavior: do not auto remove screens on Windows to prevent crash.
        if (Qt.platform.os==="windows") {
            if (totalProjectedDisplays<count)
                project();
        }
        // Behavior for all other OS
        else if (totalProjectedDisplays!==count)
            project();
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
                else
                    flip = this.defaultDisplayMode;
            // Comment the following line to debug with a single screen.
            if (flip>0 /*&& Qt.application.screens[i].name!==screen.name*/)
                projectionModel.append ({
                    "id": i,
                    "screen": Qt.application.screens[i],
                    "name": Qt.application.screens[i].name, // + ' ' + Qt.application.screens[i].model + ' ' + Qt.application.screens[i].manufacturer,
                    "x": Qt.application.screens[i].virtualX,
                    "y": Qt.application.screens[i].virtualY,
                    "width": Qt.application.screens[i].desktopAvailableWidth,
                    "height": Qt.application.screens[i].desktopAvailableHeight,
                    "flip": flip,//.projectionSetting,
                    "p": ""
                });
        }
        //if (projectionModel.count===0 && this.isEnabled && parseInt(forwardTo.prompter.state) === Prompter.States.Editing)
            //alertDialog.requestDisplays();
    }
    function closeAll() {
        return projectionModel.clear()
    }
    function update() {
        const totalRegisteredDisplays = displayModel.count,
              totalProjectedDisplays = projectionModel.count;
        for (var i=0; i<totalRegisteredDisplays; i++)
            for (var j=0; j<totalProjectedDisplays; j++)
                if (displayModel.get(i).name===projectionModel.get(j).name) {
                    //console.log(i, j, projectionModel.get(i).name, projectionModel.get(j).flip)
                    displayModel.get(i).flipSetting = projectionModel.get(j).flip;
                    break;
                }
    }
    function updateFromRoot(screenName, flipSetting) {
        const totalProjectedDisplays = projectionModel.count;
        for (let j=0; j<totalProjectedDisplays; j++) {
            var model = projectionModel.get(j);
            if (model.name===screenName) {
                model.flip = flipSetting;
                break;
            }
        }
        if (projectionManager.isEnabled)
            addMissingProjections();
    }
    Settings {
        property alias enable: projectionManager.isEnabled
        property alias scale: projectionManager.reScale
        property alias screens: projectionManager.screensStringified
        category: "projections"
    }
    Component {
        id: projectionDelegte
        Window {
            id: projectionWindow
            title: i18n("Projection Window")
            transientParent: root
            screen: model.screen
            modality: Qt.NonModal
            x: model.x
            y: model.y
            width: model.width
            height: model.height
            visibility:
                if (!root.visible || (model.name===root.screen.name && Qt.platform.os==="windows"))
                    return ApplicationWindow.Hidden
                else if (['windows', 'osx'].indexOf(Qt.platform.os)===-1)
                    return ApplicationWindow.FullScreen
                else
                    return ApplicationWindow.Maximized
            flags: Qt.FramelessWindowHint
            color: root.__translucidBackground ? "transparent" : "initial"
            onClosing: {
                model.flip = 0;
                projectionManager.update();
                projectionModel.remove(model.index);
                //displayModel.remove(model.index);
            }
            MouseArea {
                enabled: true
                anchors.fill: parent
                cursorShape: model.flip ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                // Keyboard inputs
                focus: true
                onClicked:
                    if (model.flip)
                        projectionManager.forwardTo.prompter.toggle();
                onWheel: (wheel)=>projectionManager.forwardTo.mouse.wheel(wheel)
                Keys.onShortcutOverride: event.accepted = (event.key === Qt.Key_Escape)
                Keys.onEscapePressed: projectionManager.forwardTo.prompter.cancel()
                Keys.forwardTo: projectionManager.forwardTo.prompter
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
                    anchors.left: img.right
                }
                Rectangle {
                    id: leftFill
                    color: backgroundColor
                    opacity: internalBackgroundOpacity
                    anchors.top: topFill.bottom
                    anchors.right: img.left
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
                ShaderEffect {
                    id: img
                    property variant source: projectionManager.forwardTo
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    width: reScale ? parent.width : projectionManager.forwardTo.width
                    height: reScale ? (parent.width / projectionManager.forwardTo.width) * projectionManager.forwardTo.height : projectionManager.forwardTo.height
                    blending: false
                    transform: Scale {
                        origin.y: img.height/2
                        yScale: model.flip===3 || model.flip===4 ? -1 : 1
                        origin.x: img.width/2
                        xScale: model.flip===2 || model.flip===4 ? -1 : 1
                    }
                    Rectangle {
                        color: "#000000"
                        anchors.fill: parent
                        visible: model.flip===0
                        Image {
                            source: "qrc:/images/qprompt.png"
                            fillMode: Image.PreserveAspectFit
                            width: parent.width * 3 / 4
                            height: parent.height * 3 / 4
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
                GridLayout {
                    opacity: parseInt(forwardTo.prompter.state) === Prompter.States.Countdown || parseInt(forwardTo.prompter.state) === Prompter.States.Prompting ? 0.2 : 1
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: 10
                    anchors.bottomMargin: 5
                    Behavior on opacity {
                        enabled: true
                        animation: NumberAnimation {
                            duration: Kirigami.Units.longDuration
                            easing.type: Easing.OutQuad
                        }
                    }
                    Button {
                        id: closeButton
                        text: i18n("Close")
                        flat: parseInt(forwardTo.prompter.state) === Prompter.States.Countdown || parseInt(forwardTo.prompter.state) === Prompter.States.Prompting
                        onClicked: projectionWindow.close()
                        transform: Scale {
                            origin.y: closeButton.height/2
                            origin.x: closeButton.width/2
                            xScale: model.flip===2 || model.flip===4 ? -1 : 1
                            yScale: model.flip===3 || model.flip===4 ? -1 : 1
                        }
                    }
                    Button {
                        id: horizontalFlipButton
                        enabled: model.flip
                        text: i18nc("Mirrors prompter horizontally", "Horizontal mirror")
                        icon.name: "object-flip-horizontal"
                        checkable: true
                        checked: model.flip===2 || model.flip===4
                        flat: parseInt(forwardTo.prompter.state) === Prompter.States.Countdown || parseInt(forwardTo.prompter.state) === Prompter.States.Prompting
                        onClicked: {
                            model.flip = model.flip + (model.flip % 2 ? 1 : -1);
                            projectionManager.update();
                            root.update();
                        }
                        transform: Scale {
                            origin.y: horizontalFlipButton.height/2
                            origin.x: horizontalFlipButton.width/2
                            xScale: model.flip===2 || model.flip===4 ? -1 : 1
                            yScale: model.flip===3 || model.flip===4 ? -1 : 1
                        }
                    }
                    Button {
                        id: verticalFlipButton
                        enabled: model.flip
                        text: i18nc("Mirrors prompter vertically", "Vertical mirror")
                        icon.name: "object-flip-vertical";
                        checkable: true
                        checked: model.flip===3 || model.flip===4
                        flat: parseInt(forwardTo.prompter.state) === Prompter.States.Countdown || parseInt(forwardTo.prompter.state) === Prompter.States.Prompting
                        onClicked: {
                            model.flip = (model.flip + 1) % 4 + 1;
                            projectionManager.update();
                            root.update();
                        }
                        transform: Scale {
                            origin.y: verticalFlipButton.height/2
                            origin.x: verticalFlipButton.width/2
                            xScale: model.flip===2 || model.flip===4 ? -1 : 1
                            yScale: model.flip===3 || model.flip===4 ? -1 : 1
                        }
                    }
                }
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
    Labs.MessageDialog {
        id: alertDialog

        function requestDisplays() {
            alertDialog.text = i18n("For screen projections to show, you must set at least one screen to a projection setting other than \"Off\"")
            alertDialog.detailedText = ""
            alertDialog.icon = StandardIcon.Information
            alertDialog.visible = true
        }
//         function warnSameDisplay(screenName) {
//             alertDialog.text = i18n("You've enabled a screen projection on display \"%1\". Please note this projection will not show unless you place the editor on a different screen.", screenName)
//             //alertDialog.text = i18n("QPrompt will not project to the screen where the editor is at.")
//             //alertDialog.detailedText = i18n("You've enabled a screen projection on display \""+screenName+"\". Please note this projection will not show unless you place the editor on a different screen.")
//             alertDialog.icon = StandardIcon.Warning
//             alertDialog.visible = true
//         }
    }
}
