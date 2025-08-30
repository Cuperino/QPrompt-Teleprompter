/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2020-2025 Javier O. Cordero Pérez
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

import QtCore 6.5
import QtQuick.Dialogs 6.6
import Qt.labs.platform 1.1 as Labs

import com.cuperino.qprompt 1.0

Rectangle {
    id: prompterBackground
    readonly property alias backgroundColorDialog: backgroundColorDialog
    //readonly property real __deepeningFactor: 0.89
    //readonly property real __deepeningFactor: themeSwitch.checked ? 0.89 : 1
    property bool hasBackground: color!==root.background.__backgroundColor || backgroundImage.opacity>0//backgroundImage.visible
    property var backgroundImage: null
    //color: Qt.rgba(root.background.__backgroundColor.r*__deepeningFactor, root.background.__backgroundColor.g*__deepeningFactor, root.background.__backgroundColor.b*__deepeningFactor, root.background.__backgroundColor.a)
    //property alias backgroundColor: backgroundSettings.color
    //property color backgroundColor: root.background.__backgroundColor
    //property color backgroundColor: root.background.selection ? root.background.__backgroundColor : "#FFFFFF" //: "#FFFFFF"

    // property color backgroundColor: "#303030"
    property color backgroundColor: backgroundColorDialog.selectedColor

    function loadBackgroundImage() {
        openBackgroundDialog.open()
    }
    function clearBackground() {
        backgroundImage.opacity = 0
        backgroundColorDialog.selectedColor = root.background.__backgroundColor
        // Reset background image value such that setting is saved
        resetBackground.start()
    }
    function setBackgroundImage(file) {
        if (file) {
            backgroundImage.source = file
        }
    }

    anchors.fill: parent
    color: backgroundColor
    opacity: /*parent.toolbar.opacitySlider.pressed || projectionManager.isPreview ? */editorToolbar.opacitySlider.value/100 /*: 1 */

    Settings {
        id: backgroundSettings
        // property color color: "#303030" // "#181818"
        //property color color: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 1)
        property alias color: backgroundColorDialog.selectedColor
        property alias image: backgroundImage.source
        category: "background"
    }

    // Using timer workaround because behavior animations don't execute signals and high performance is not a requirement for this action.
    Timer {
        id: resetBackground
        interval: 2800
        onTriggered: backgroundImage.source = ""
    }

    Image {
        id: backgroundImage
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        opacity: 0
        visible: opacity
        autoTransform: true
        asynchronous: true
        mipmap: false

        readonly property Scale __flips: Flip{}
        transform: __flips

        onStatusChanged: {
            if (backgroundImage.status === Image.Ready && !backgroundImage.opacity)
                backgroundImage.opacity = 0.72*parent.opacity
        }

        Behavior on opacity {
            enabled: true
            animation: NumberAnimation {
                duration: 2800
                easing.type: Easing.OutExpo
            }
        }

        ColorDialog {
            id: backgroundColorDialog
            options: Qt.platform.os === "android" ? ColorDialog.ShowAlphaChannel : 0
            property color color: root.background.__backgroundColor
            selectedColor: switch(appTheme.selection) {
                           //case 0: root.background.__backgroundColor
                           //case 0: return Qt.rgba(Material.background.r/4, Material.background.g/4, Material.background.b/4, 1);
                           //case 0: return Qt.rgb(Material.background.r/4, Material.background.g/4, Material.background.b/4);
                           case 0: return "#0C0C0C";
                           case 1: return "#303030";
                           case 2: return "#FAFAFA";
                       }
            onRejected: {
                backgroundColorDialog.selectedColor = backgroundColorDialog.color
            }
            onVisibleChanged: {
                if (visible) {
                    backgroundColorDialog.color = backgroundSettings.color
                    cursorAutoHide.reset();
                }
                else
                    cursorAutoHide.restart();
            }
        }

        Labs.FileDialog {
            id: openBackgroundDialog
            nameFilters: [
              qsTr("JPEG image") + "(*.jpg *.jpeg *.JPG *.JPEG)",
              qsTr("PNG image") + "(*.png *.PNG)",
              qsTr("GIF animation") + "(*.gif *.GIF)"
            ]
            fileMode: Labs.FileDialog.OpenFile
            folder: StandardPaths.writableLocation(StandardPaths.PicturesLocation)
            onAccepted: prompterBackground.setBackgroundImage(openBackgroundDialog.file)
            onVisibleChanged: {
                if (visible)
                    cursorAutoHide.reset();
                else
                    cursorAutoHide.restart();
            }
        }
    }

    Behavior on color {
        enabled: true
        animation: ColorAnimation {
            duration: resetBackground.interval
            easing.type: Easing.OutExpo
        }
    }

    Behavior on opacity {
        enabled: true
        animation: NumberAnimation {
            duration: Units.LongDuration
            easing.type: Easing.OutQuad
        }
    }
}
