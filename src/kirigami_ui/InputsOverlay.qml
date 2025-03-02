/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2021-2024 Javier O. Cordero Pérez
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

import com.cuperino.qprompt 1.0

Kirigami.OverlaySheet {
    id: keyConfigurationOverlay

    width: root.minimumWidth + 70

    header: Kirigami.Heading {
        text: qsTr("Key Bindings", "Title of dialog where users customize keyboard inputs")
        level: 1
    }

    onClosed: {
        buttonGrid.toggleButtonsOff();
    }

    GridLayout {
        id: buttonGrid

        width: parent.width
        columns: 2

        // Toggle all buttons off
        function toggleButtonsOff() {
            for (let i=1; i<children.length; i+=2)
                if (typeof children[i].item !== "undefined") {
                    children[i].item.checked = false;
                    if (children[i].item.text === "[…]")
                        children[i].item.text = "";
                }
        }

        Component.onCompleted: {
            keyInputTogglePrompter.setSource("KeyInputButton.qml", { "text": qmlutil.keyToString(prompter.keys.toggle, prompter.keys.toggleModifiers) });
            keyInputDecreaseVelocity.setSource("KeyInputButton.qml", { "text": qmlutil.keyToString(prompter.keys.decreaseVelocity, prompter.keys.decreaseVelocityModifiers) });
            keyInputIncreaseVelocity.setSource("KeyInputButton.qml", { "text": qmlutil.keyToString(prompter.keys.increaseVelocity, prompter.keys.increaseVelocityModifiers) });
            keyInputStop.setSource("KeyInputButton.qml", { "text": qmlutil.keyToString(prompter.keys.stop, prompter.keys.stopModifiers) });
            keyInputPlayPause.setSource("KeyInputButton.qml", { "text": qmlutil.keyToString(prompter.keys.pause, prompter.keys.pauseModifiers) });
            keyInputReverse.setSource("KeyInputButton.qml", { "text": qmlutil.keyToString(prompter.keys.reverse, prompter.keys.reverseModifiers) });
            keyInputRewind.setSource("KeyInputButton.qml", { "text": qmlutil.keyToString(prompter.keys.rewind, prompter.keys.rewindModifiers) });
            keyInputFastForward.setSource("KeyInputButton.qml", { "text": qmlutil.keyToString(prompter.keys.fastForward, prompter.keys.fastForwardModifiers) });
            keyInputMoveBackwards.setSource("KeyInputButton.qml", { "text": qmlutil.keyToString(prompter.keys.skipBackwards, prompter.keys.skipBackwardsModifiers) });
            keyInputMoveForward.setSource("KeyInputButton.qml", { "text": qmlutil.keyToString(prompter.keys.skipForward, prompter.keys.skipForwardModifiers) });
            keyInputPreviousMarker.setSource("KeyInputButton.qml", { "text": qmlutil.keyToString(prompter.keys.previousMarker, prompter.keys.previousMarkerModifiers) });
            keyInputNextMarker.setSource("KeyInputButton.qml", { "text": qmlutil.keyToString(prompter.keys.nextMarker, prompter.keys.nextMarkerModifiers) });
            keyInputSetVelocity0.setSource("KeyInputButton.qml", { "text": qmlutil.keyToString(prompter.keys.setVelocity0, prompter.keys.setVelocity0Modifiers) });
            keyInputSetVelocity1.setSource("KeyInputButton.qml", { "text": qmlutil.keyToString(prompter.keys.setVelocity1, prompter.keys.setVelocity1Modifiers) });
            keyInputSetVelocity2.setSource("KeyInputButton.qml", { "text": qmlutil.keyToString(prompter.keys.setVelocity2, prompter.keys.setVelocity2Modifiers) });
            keyInputSetVelocity3.setSource("KeyInputButton.qml", { "text": qmlutil.keyToString(prompter.keys.setVelocity3, prompter.keys.setVelocity3Modifiers) });
            keyInputSetVelocity4.setSource("KeyInputButton.qml", { "text": qmlutil.keyToString(prompter.keys.setVelocity4, prompter.keys.setVelocity4Modifiers) });
            keyInputSetVelocity5.setSource("KeyInputButton.qml", { "text": qmlutil.keyToString(prompter.keys.setVelocity5, prompter.keys.setVelocity5Modifiers) });
            keyInputSetVelocity6.setSource("KeyInputButton.qml", { "text": qmlutil.keyToString(prompter.keys.setVelocity6, prompter.keys.setVelocity6Modifiers) });
            keyInputSetVelocity7.setSource("KeyInputButton.qml", { "text": qmlutil.keyToString(prompter.keys.setVelocity7, prompter.keys.setVelocity7Modifiers) });
            keyInputSetVelocity8.setSource("KeyInputButton.qml", { "text": qmlutil.keyToString(prompter.keys.setVelocity8, prompter.keys.setVelocity8Modifiers) });
            keyInputSetVelocity9.setSource("KeyInputButton.qml", { "text": qmlutil.keyToString(prompter.keys.setVelocity9, prompter.keys.setVelocity9Modifiers) });
            keyInputSetVelocity10.setSource("KeyInputButton.qml", { "text": qmlutil.keyToString(prompter.keys.setVelocity10, prompter.keys.setVelocity10Modifiers) });
        }
        Connections {
            target: keyInputTogglePrompter.item
            function onToggleButtonsOff() { buttonGrid.toggleButtonsOff(); }
            function onSetKey(key, modifiers) {
                prompter.keys.toggle = key;
                prompter.keys.toggleModifiers = modifiers;
            }
        }
        Connections {
            target: keyInputDecreaseVelocity.item
            function onToggleButtonsOff() { buttonGrid.toggleButtonsOff(); }
            function onSetKey(key, modifiers) {
                prompter.keys.decreaseVelocity = key;
                prompter.keys.decreaseVelocityModifiers = modifiers;
            }
        }
        Connections {
            target: keyInputIncreaseVelocity.item
            function onToggleButtonsOff() { buttonGrid.toggleButtonsOff(); }
            function onSetKey(key, modifiers) {
                prompter.keys.increaseVelocity = key;
                prompter.keys.increaseVelocityModifiers = modifiers;
            }
        }
        Connections {
            target: keyInputStop.item
            function onToggleButtonsOff() { buttonGrid.toggleButtonsOff(); }
            function onSetKey(key, modifiers) {
                prompter.keys.stop = key;
                prompter.keys.stopModifiers = modifiers;
            }
        }
        Connections {
            target: keyInputPlayPause.item
            function onToggleButtonsOff() { buttonGrid.toggleButtonsOff(); }
            function onSetKey(key, modifiers) {
                prompter.keys.pause = key;
                prompter.keys.pauseModifiers = modifiers;
            }
        }
        Connections {
            target: keyInputReverse.item
            function onToggleButtonsOff() { buttonGrid.toggleButtonsOff(); }
            function onSetKey(key, modifiers) {
                prompter.keys.reverse = key;
                prompter.keys.reverseModifiers = modifiers;
            }
        }
        Connections {
            target: keyInputRewind.item
            function onToggleButtonsOff() { buttonGrid.toggleButtonsOff(); }
            function onSetKey(key, modifiers) {
                prompter.keys.rewind = key;
                prompter.keys.rewindModifiers = modifiers;
            }
        }
        Connections {
            target: keyInputFastForward.item
            function onToggleButtonsOff() { buttonGrid.toggleButtonsOff(); }
            function onSetKey(key, modifiers) {
                prompter.keys.fastForward = key;
                prompter.keys.fastForwardModifiers = modifiers;
            }
        }
        Connections {
            target: keyInputMoveBackwards.item
            function onToggleButtonsOff() { buttonGrid.toggleButtonsOff(); }
            function onSetKey(key, modifiers) {
                prompter.keys.skipBackwards = key;
                prompter.keys.skipBackwardsModifiers = modifiers;
            }
        }
        Connections {
            target: keyInputMoveForward.item
            function onToggleButtonsOff() { buttonGrid.toggleButtonsOff(); }
            function onSetKey(key, modifiers) {
                prompter.keys.skipForward = key;
                prompter.keys.skipForwardModifiers = modifiers;
            }
        }
        Connections {
            target: keyInputPreviousMarker.item
            function onToggleButtonsOff() { buttonGrid.toggleButtonsOff(); }
            function onSetKey(key, modifiers) {
                prompter.keys.previousMarker = key;
                prompter.keys.previousMarkerModifiers = modifiers;
            }
        }
        Connections {
            target: keyInputNextMarker.item
            function onToggleButtonsOff() { buttonGrid.toggleButtonsOff(); }
            function onSetKey(key, modifiers) {
                prompter.keys.nextMarker = key;
                prompter.keys.nextMarkerModifiers = modifiers;
            }
        }
        Connections {
            target: keyInputSetVelocity0.item
            function onToggleButtonsOff() { buttonGrid.toggleButtonsOff(); }
            function onSetKey(key, modifiers) {
                prompter.keys.setVelocity0 = key;
                prompter.keys.setVelocity0Modifiers = modifiers;
            }
        }
        Connections {
            target: keyInputSetVelocity1.item
            function onToggleButtonsOff() { buttonGrid.toggleButtonsOff(); }
            function onSetKey(key, modifiers) {
                prompter.keys.setVelocity1 = key;
                prompter.keys.setVelocity1Modifiers = modifiers;
            }
        }
        Connections {
            target: keyInputSetVelocity2.item
            function onToggleButtonsOff() { buttonGrid.toggleButtonsOff(); }
            function onSetKey(key, modifiers) {
                prompter.keys.setVelocity2 = key;
                prompter.keys.setVelocity2Modifiers = modifiers;
            }
        }
        Connections {
            target: keyInputSetVelocity3.item
            function onToggleButtonsOff() { buttonGrid.toggleButtonsOff(); }
            function onSetKey(key, modifiers) {
                prompter.keys.setVelocity3 = key;
                prompter.keys.setVelocity3Modifiers = modifiers;
            }
        }
        Connections {
            target: keyInputSetVelocity4.item
            function onToggleButtonsOff() { buttonGrid.toggleButtonsOff(); }
            function onSetKey(key, modifiers) {
                prompter.keys.setVelocity4 = key;
                prompter.keys.setVelocity4Modifiers = modifiers;
            }
        }
        Connections {
            target: keyInputSetVelocity5.item
            function onToggleButtonsOff() { buttonGrid.toggleButtonsOff(); }
            function onSetKey(key, modifiers) {
                prompter.keys.setVelocity5 = key;
                prompter.keys.setVelocity5Modifiers = modifiers;
            }
        }
        Connections {
            target: keyInputSetVelocity6.item
            function onToggleButtonsOff() { buttonGrid.toggleButtonsOff(); }
            function onSetKey(key, modifiers) {
                prompter.keys.setVelocity6 = key;
                prompter.keys.setVelocity6Modifiers = modifiers;
            }
        }
        Connections {
            target: keyInputSetVelocity7.item
            function onToggleButtonsOff() { buttonGrid.toggleButtonsOff(); }
            function onSetKey(key, modifiers) {
                prompter.keys.setVelocity7 = key;
                prompter.keys.setVelocity7Modifiers = modifiers;
            }
        }
        Connections {
            target: keyInputSetVelocity8.item
            function onToggleButtonsOff() { buttonGrid.toggleButtonsOff(); }
            function onSetKey(key, modifiers) {
                prompter.keys.setVelocity8 = key;
                prompter.keys.setVelocity8Modifiers = modifiers;
            }
        }
        Connections {
            target: keyInputSetVelocity9.item
            function onToggleButtonsOff() { buttonGrid.toggleButtonsOff(); }
            function onSetKey(key, modifiers) {
                prompter.keys.setVelocity9 = key;
                prompter.keys.setVelocity9Modifiers = modifiers;
            }
        }
        Connections {
            target: keyInputSetVelocity10.item
            function onToggleButtonsOff() { buttonGrid.toggleButtonsOff(); }
            function onSetKey(key, modifiers) {
                prompter.keys.setVelocity10 = key;
                prompter.keys.setVelocity10Modifiers = modifiers;
            }
        }

        Label {
            text: qsTr("Toggle Prompter State")
        }
        Loader {
            id: keyInputTogglePrompter
            asynchronous: true
            Layout.fillWidth: true
        }
        Label {
            text: qsTr("Decrease Velocity")
        }
        Loader {
            id: keyInputDecreaseVelocity
            asynchronous: true
            Layout.fillWidth: true
        }
        Label {
            text: qsTr("Increase Velocity")
        }
        Loader {
            id: keyInputIncreaseVelocity
            asynchronous: true
            Layout.fillWidth: true
        }
        Label {
            text: qsTr("Stop")
        }
        Loader {
            id: keyInputStop
            asynchronous: true
            Layout.fillWidth: true
        }
        Label {
            text: qsTr("Play/Pause")
        }
        Loader {
            id: keyInputPlayPause
            asynchronous: true
            Layout.fillWidth: true
        }
        Label {
            text: qsTr("Reverse")
        }
        Loader {
            id: keyInputReverse
            asynchronous: true
            Layout.fillWidth: true
        }
        Label {
            text: qsTr("Rewind")
        }
        Loader {
            id: keyInputRewind
            asynchronous: true
            Layout.fillWidth: true
        }
        Label {
            text: qsTr("Fast Forward")
        }
        Loader {
            id: keyInputFastForward
            asynchronous: true
            Layout.fillWidth: true
        }
        Label {
            text: qsTr("Move Backwards", "Skip to earlier text while prompting or editing")
        }
        Loader {
            id: keyInputMoveBackwards
            asynchronous: true
            Layout.fillWidth: true
        }
        Label {
            text: qsTr("Move Forward", "Skip to later text while prompting or editing")
        }
        Loader {
            id: keyInputMoveForward
            asynchronous: true
            Layout.fillWidth: true
        }
        Label {
            text: qsTr("Go to Previous Marker", "Skip to closest marker behind of current position")
        }
        Loader {
            id: keyInputPreviousMarker
            asynchronous: true
            Layout.fillWidth: true
        }
        Label {
            text: qsTr("Go to Next Marker", "Skip to closest marker ahead of current position")
        }
        Loader {
            id: keyInputNextMarker
            asynchronous: true
            Layout.fillWidth: true
        }
        Label {
            text: qsTr("Set velocity modifier key", "Hotkey that shifts velocoty to its negative value.")
        }
        ComboBox {
            id: keyInputSetVelocityModifier
            model: [
                qsTr("Ctrl", "Control key"),
                qsTr("Alt", "Alt key")
            ]
            z: 1
            onActivated: {
                switch(currentIndex) {
                    case 1:
                        prompter.keys.setVelocityModifier = Qt.ControlModifier; break;
                    case 2:
                        prompter.keys.setVelocityModifier = Qt.ShiftModifier; break;
                    case 3:
                        prompter.keys.setVelocityModifier = Qt.MetaModifier; break;
                    case 0:
                        prompter.keys.setVelocityModifier = Qt.AltModifier; break;
                }
                console.log(prompter.keys.setVelocityModifier)
            }
            Layout.fillWidth: true
            Material.theme: Material.Dark
            Component.onCompleted: {
                switch(prompter.keys.setVelocityModifier) {
                    case Qt.ControlModifier:
                        currentIndex = 1; break;
                    case Qt.ShiftModifier:
                        currentIndex = 2; break;
                    case Qt.MetaModifier:
                        currentIndex = 3; break;
                    case Qt.AltModifier:
                    default:
                        currentIndex = 0; break;
                }
            }
        }
        Label {
            text: qsTr("Set velocity to 0", "Hotkey that sets velocity to a fixed value.")
        }
        Loader {
            id: keyInputSetVelocity0
            asynchronous: true
            Layout.fillWidth: true
        }
        Label {
            text: qsTr("Set velocity to 1", "Hotkey that sets velocity to a fixed value.")
        }
        Loader {
            id: keyInputSetVelocity1
            asynchronous: true
            Layout.fillWidth: true
        }
        Label {
            text: qsTr("Set velocity to 2", "Hotkey that sets velocity to a fixed value.")
        }
        Loader {
            id: keyInputSetVelocity2
            asynchronous: true
            Layout.fillWidth: true
        }
        Label {
            text: qsTr("Set velocity to 3", "Hotkey that sets velocity to a fixed value.")
        }
        Loader {
            id: keyInputSetVelocity3
            asynchronous: true
            Layout.fillWidth: true
        }
        Label {
            text: qsTr("Set velocity to 4", "Hotkey that sets velocity to a fixed value.")
        }
        Loader {
            id: keyInputSetVelocity4
            asynchronous: true
            Layout.fillWidth: true
        }
        Label {
            text: qsTr("Set velocity to 5", "Hotkey that sets velocity to a fixed value.")
        }
        Loader {
            id: keyInputSetVelocity5
            asynchronous: true
            Layout.fillWidth: true
        }
        Label {
            text: qsTr("Set velocity to 6", "Hotkey that sets velocity to a fixed value.")
        }
        Loader {
            id: keyInputSetVelocity6
            asynchronous: true
            Layout.fillWidth: true
        }
        Label {
            text: qsTr("Set velocity to 7", "Hotkey that sets velocity to a fixed value.")
        }
        Loader {
            id: keyInputSetVelocity7
            asynchronous: true
            Layout.fillWidth: true
        }
        Label {
            text: qsTr("Set velocity to 8", "Hotkey that sets velocity to a fixed value.")
        }
        Loader {
            id: keyInputSetVelocity8
            asynchronous: true
            Layout.fillWidth: true
        }
        Label {
            text: qsTr("Set velocity to 9", "Hotkey that sets velocity to a fixed value.")
        }
        Loader {
            id: keyInputSetVelocity9
            asynchronous: true
            Layout.fillWidth: true
        }
        Label {
            text: qsTr("Set velocity to 10", "Hotkey that sets velocity to a fixed value.")
        }
        Loader {
            id: keyInputSetVelocity10
            asynchronous: true
            Layout.fillWidth: true
        }


        QmlUtil {
            id: qmlutil
        }
    }
}
