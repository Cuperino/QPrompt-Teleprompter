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
import QtQuick.Window 2.15
import QtQml.Models 2.15
//import QtGraphicalEffects 1.15
import org.kde.kirigami 2.9 as Kirigami

Item {
    id: viewport
    
    property alias prompter: prompter
    property alias editor: prompter.editor
    property alias document: prompter.document
    property alias countdown: countdown
    property alias overlay: overlay
    property alias prompterBackground: prompterBackground
    property alias timer: timer
    //property bool project: true

    anchors.fill: parent
    //layer.enabled: true
    // Undersample
    //layer.mipmap: true
    // Oversample
    //layer.samples: 2
    //layer.smooth: true
    // Make texture the size of the largest destinations.
    //layer.textureSize: Qt.size(projectionWindow.width, projectionWindow.height)
    
    Countdown {
        id: countdown
        z: 4
        anchors.fill: parent
    }
    
    ReadRegionOverlay {
        id: overlay
        z: 2
        anchors.fill: parent
    }
    
    TimerClock {
       id: timer
       z: 3
       anchors.fill: parent
    }
    
    Prompter {
        id: prompter
        property double delta: 16
        anchors.fill: parent
        z: 1
        textColor: colorDialog.color
        fontSize:  (prompter.state==="editing" && !prompter.__wysiwyg) ? (Math.pow(editorToolbar.fontSizeSlider.value/185,4)*185) : (Math.pow(editorToolbar.fontWYSIWYGSizeSlider.value/185,4)*185)*prompter.__vw/10
        //Math.pow((fontSizeSlider.value*prompter.__vw),3)
    }
    //FastBlur {
    //anchors.fill: prompter
    //source: prompter
    //radius: 32
    //radius: 0
    //}

    PrompterBackground {
        id: prompterBackground
        z: 0
    }

    ListModel {
        id: projectionModel
    }

    Component {
        id: projectionDelegte
        ProjectionWindow {
            id: projectionWindow
            transientParent: root
            x: model.x
            y: model.y
            width: model.width
            height: model.height
            flags: Qt.FramelessWindowHint
            visibility: Kirigami.ApplicationWindow.FullScreen
            color: "transparent"
            Rectangle {
                color: prompterBackground.color
                opacity: prompterBackground.opacity
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.left: parent.left
                anchors.bottom: img.top
            }
            Rectangle {
                color: prompterBackground.color
                opacity: prompterBackground.opacity
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
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                cache: false
                // mirror: true
            }
            onClosing: {
                projectionModel.clear()
            }
        }
    }

    Instantiator {
        id: projections
        model: projectionModel
        asynchronous: true
        delegate: projectionDelegte
    }

    Timer {
        repeat: true
        running: projectionModel.count
        triggeredOnStart: true
        interval: 17;
        onTriggered: {
            //copySource.scheduleUpdate()
            viewport.grabToImage(function(result) {
                for (var i=0; i<projectionModel.count; ++i)
                    projectionModel.setProperty(i, "p", String(result.url));
                //projectionModel.set(i, {"p": String(result.url)});
                // Most expensive, nothing beats Shader+live. Unfortunately that doesn't work across video cards.
                //copyImage.source = result.url;
            });
        }
    }

    function project() {
        console.log("Creating projections")
        projectionModel.clear();
        for (var i=0; i<Qt.application.screens.length; i++) {
            //if (Qt.application.screens[i].name!==screen.name) {
                projectionModel.append ({
                    "x": Qt.application.screens[i].virtualX,
                    "y": Qt.application.screens[i].virtualY,
                    "width": Qt.application.screens[i].desktopAvailableWidth,
                    "height": Qt.application.screens[i].desktopAvailableHeight,
                    "p": ""
                });
            //}
        }
    }

}
