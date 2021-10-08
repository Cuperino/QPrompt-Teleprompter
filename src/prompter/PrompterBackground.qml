/****************************************************************************
 * *
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

import QtQuick 2.12

import Qt.labs.settings 1.0
import QtQuick.Dialogs 1.2
import org.kde.kirigami 2.11 as Kirigami

Rectangle {
    id: prompterBackground
    anchors.fill: parent
    readonly property alias backgroundColorDialog: backgroundColorDialog
    property bool hasBackground: color!==appTheme.__backgroundColor || backgroundImage.opacity>0//backgroundImage.visible
    property var backgroundImage: null
    readonly property real __deepeningFactor: themeSwitch.checked ? 0.89 : 1
    //color: Qt.rgba(appTheme.__backgroundColor.r*__deepeningFactor, appTheme.__backgroundColor.g*__deepeningFactor, appTheme.__backgroundColor.b*__deepeningFactor, appTheme.__backgroundColor.a)
    property alias backgroundColor: backgroundSettings.color
    color: backgroundColor
    opacity: /*backgroundOpacitySlider.pressed ||*/ parent.toolbar.opacitySlider.pressed ? parent.toolbar.opacitySlider.value/100 : 1

    Settings {
        id: backgroundSettings
        category: "background"
        property color color: "#303030" // "#181818"
        property alias image: backgroundImage.source
    }

    function loadBackgroundImage() {
        openBackgroundDialog.open()
    }
    
    function clearBackground() {
        backgroundImage.opacity = 0
        backgroundColor = appTheme.__backgroundColor
        // Reset background image value such that setting is saved
        resetBackground.start()
    }
    // Using timer workaround because behavior animations don't execute signals and high performance is not a requirement for this action.
    Timer {
        id: resetBackground
        interval: 2800
        onTriggered: backgroundImage.source = ""
    }

    function setBackgroundImage(file) {
        if (file) {
            backgroundImage.source = file
        }
    }
    Behavior on color {
        enabled: true
        animation: ColorAnimation {
            duration: resetBackground.interval
            easing.type: Easing.OutExpo
        }
    }
    Image {
        id: backgroundImage
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        opacity: 0
        visible: opacity!==0
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
            currentColor: appTheme.__backgroundColor
            onAccepted: {
                console.log(color)
                prompterBackground.backgroundColor = color
            }
        }

        FileDialog {
            id: openBackgroundDialog
            selectExisting: true
            selectedNameFilter: nameFilters[0]
            nameFilters: ["JPEG image (*.jpg *.jpeg *.JPG *.JPEG)", "PNG image (*.png *.PNG)", "GIF animation (*.gif *.GIF)"]
            folder: shortcuts.pictures
            onAccepted: prompterBackground.setBackgroundImage(openBackgroundDialog.fileUrl)
        }
    }

    Behavior on opacity {
        enabled: true
        animation: NumberAnimation {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.OutQuad
        }
    }
}
