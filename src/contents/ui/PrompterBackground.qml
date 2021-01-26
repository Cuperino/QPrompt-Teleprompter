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

import QtQuick 2.15
import Qt.labs.platform 1.1
import org.kde.kirigami 2.9 as Kirigami

Rectangle {
    id: prompterBackground
    anchors.fill: parent
    readonly property alias backgroundColorDialog: backgroundColorDialog
    property bool hasBackground: color!==appTheme.__backgroundColor || backgroundImage.opacity>0//backgroundImage.visible
    property var backgroundImage: null
    //color: appTheme.__backgroundColor
    color: Qt.rgba(appTheme.__backgroundColor.r*0.9, appTheme.__backgroundColor.g*0.9, appTheme.__backgroundColor.b*0.9, appTheme.__backgroundColor.a)
    opacity: /*backgroundOpacitySlider.pressed ||*/ parent.toolbar.opacitySlider.pressed ? parent.toolbar.opacitySlider.value/100 : 1
    
    function loadBackgroundImage() {
        openBackgroundDialog.open()
    }
    
    function clearBackground() {
        backgroundImage.opacity = 0
        color = appTheme.__backgroundColor
    }
    
    function setBackgroundImage(file) {
        if (file) {
            backgroundImage.source = file
        }
    }
    Behavior on color {
        enabled: true
        animation: ColorAnimation {
            duration: 2800
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
                prompterBackground.color = color
            }
        }
        
        FileDialog {
            id: openBackgroundDialog
            fileMode: FileDialog.OpenFile
            selectedNameFilter.index: 0
            nameFilters: ["JPEG image (*.jpg *.jpeg *.JPG *.JPEG)", "PNG image (*.png *.PNG)", "GIF animation (*.gif *.GIF)"]
            folder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
            onAccepted: prompterBackground.setBackgroundImage(file)
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
