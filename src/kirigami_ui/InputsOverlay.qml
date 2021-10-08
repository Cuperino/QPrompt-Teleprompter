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
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Kirigami.OverlaySheet {
    id: key_configuration_overlay
    onSheetOpenChanged: prompterPage.actions.main.checked = sheetOpen

    background: Rectangle {
        color: appTheme.__backgroundColor
        anchors.fill: parent
    }
    header: Kirigami.Heading {
        text: i18n("Key Bindings")
        level: 1
    }

    GridLayout {
        id: buttonGrid
        width: parent.width
        columns: 2

        // Toggle all buttons off
        function toggleButtonsOff() {
            for (let i=1; i<children.length; i+=2)
                children[i].item.checked = false;
        }
        Component.onCompleted: {
            keyInputTogglePrompter.setSource("KeyInputButton.qml", { "text": "F9" });
            keyInputDecreaseVelocity.setSource("KeyInputButton.qml", { "text": "Up Arrow" });
            keyInputIncreaseVelocity.setSource("KeyInputButton.qml", { "text": "Down Arrow" });
            keyInputPlayPause.setSource("KeyInputButton.qml", { "text": "Spacebar" });
            keyInputMoveBackwards.setSource("KeyInputButton.qml", { "text": "Page Up" });
            keyInputMoveForward.setSource("KeyInputButton.qml", { "text": "Page Down" });
        }
        Connections {
            target: keyInputTogglePrompter.item
            function onToggleButtonsOff() { buttonGrid.toggleButtonsOff(); }
            function onSetKey(key) { prompter.keys.toggle=key; }
        }
        Connections {
            target: keyInputDecreaseVelocity.item
            function onToggleButtonsOff() { buttonGrid.toggleButtonsOff(); }
            function onSetKey(key) { prompter.keys.decreaseVelocity = key; }
        }
        Connections {
            target: keyInputIncreaseVelocity.item
            function onToggleButtonsOff() { buttonGrid.toggleButtonsOff(); }
            function onSetKey(key) { prompter.keys.increaseVelocity = key; }
        }
        Connections {
            target: keyInputPlayPause.item
            function onToggleButtonsOff() { buttonGrid.toggleButtonsOff(); }
            function onSetKey(key) { prompter.keys.pause = key; }
        }
        Connections {
            target: keyInputMoveBackwards.item
            function onToggleButtonsOff() { buttonGrid.toggleButtonsOff(); }
            function onSetKey(key) { prompter.keys.skipBackwards = key; }
        }
        Connections {
            target: keyInputMoveForward.item
            function onToggleButtonsOff() { buttonGrid.toggleButtonsOff(); }
            function onSetKey(key) { prompter.keys.skipForward = key; }
        }

        Label {
            text: i18n("Toggle Prompter State")
        }
        Loader {
            id: keyInputTogglePrompter
            asynchronous: true
            Layout.fillWidth: true
        }
        Label {
            text: i18n("Decrease Velocity")
        }
        Loader {
            id: keyInputDecreaseVelocity
            asynchronous: true
            Layout.fillWidth: true
        }
        Label {
            text: i18n("Increase Velocity")
        }
        Loader {
            id: keyInputIncreaseVelocity
            asynchronous: true
            Layout.fillWidth: true
        }
        Label {
            text: i18n("Play/Pause")
        }
        Loader {
            id: keyInputPlayPause
            asynchronous: true
            Layout.fillWidth: true
        }
        Label {
            text: i18n("Move Backwards")
        }
        Loader {
            id: keyInputMoveBackwards
            asynchronous: true
            Layout.fillWidth: true
        }
        Label {
            text: i18n("Move Forward")
        }
        Loader {
            id: keyInputMoveForward
            asynchronous: true
            Layout.fillWidth: true
        }
        /*
        Label {
            text: i18n("Go to Previous Marker")
        }
        Loader {
            id: keyInputHome
            asynchronous: true
            Layout.fillWidth: true
        }
        Label {
            text: i18n("Go to Next Marker")
        }
        Loader {
            id: keyInputEnd
            asynchronous: true
            Layout.fillWidth: true
        }
        */
    }
}
