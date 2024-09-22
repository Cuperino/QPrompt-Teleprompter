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

import com.cuperino.qprompt 1.0

Kirigami.OverlaySheet {
    id: keyConfigurationOverlay

    width: root.minimumWidth

    header: Kirigami.Heading {
        text: i18nc("Title of dialog where users customize keyboard inputs", "Key Bindings")
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
            text: i18n("Stop")
        }
        Loader {
            id: keyInputStop
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
            text: i18n("Reverse")
        }
        Loader {
            id: keyInputReverse
            asynchronous: true
            Layout.fillWidth: true
        }
        Label {
            text: i18n("Rewind")
        }
        Loader {
            id: keyInputRewind
            asynchronous: true
            Layout.fillWidth: true
        }
        Label {
            text: i18n("Fast Forward")
        }
        Loader {
            id: keyInputFastForward
            asynchronous: true
            Layout.fillWidth: true
        }
        Label {
            text: i18nc("Skip to earlier text while prompting or editing", "Move Backwards")
        }
        Loader {
            id: keyInputMoveBackwards
            asynchronous: true
            Layout.fillWidth: true
        }
        Label {
            text: i18nc("Skip to later text while prompting or editing", "Move Forward")
        }
        Loader {
            id: keyInputMoveForward
            asynchronous: true
            Layout.fillWidth: true
        }
        Label {
            text: i18nc("Skip to closest marker behind of current position", "Go to Previous Marker")
        }
        Loader {
            id: keyInputPreviousMarker
            asynchronous: true
            Layout.fillWidth: true
        }
        Label {
            text: i18nc("Skip to closest marker ahead of current position", "Go to Next Marker")
        }
        Loader {
            id: keyInputNextMarker
            asynchronous: true
            Layout.fillWidth: true
        }
        Label {
            text: i18nc("Hotkey that sets velocity to a fixed value.", "Set velocity to 0")
        }
        Loader {
            id: keyInputSetVelocity0
            asynchronous: true
            Layout.fillWidth: true
        }
        Label {
            text: i18nc("Hotkey that sets velocity to a fixed value.", "Set velocity to 1")
        }
        Loader {
            id: keyInputSetVelocity1
            asynchronous: true
            Layout.fillWidth: true
        }
        Label {
            text: i18nc("Hotkey that sets velocity to a fixed value.", "Set velocity to 2")
        }
        Loader {
            id: keyInputSetVelocity2
            asynchronous: true
            Layout.fillWidth: true
        }
        Label {
            text: i18nc("Hotkey that sets velocity to a fixed value.", "Set velocity to 3")
        }
        Loader {
            id: keyInputSetVelocity3
            asynchronous: true
            Layout.fillWidth: true
        }
        Label {
            text: i18nc("Hotkey that sets velocity to a fixed value.", "Set velocity to 4")
        }
        Loader {
            id: keyInputSetVelocity4
            asynchronous: true
            Layout.fillWidth: true
        }
        Label {
            text: i18nc("Hotkey that sets velocity to a fixed value.", "Set velocity to 5")
        }
        Loader {
            id: keyInputSetVelocity5
            asynchronous: true
            Layout.fillWidth: true
        }
        Label {
            text: i18nc("Hotkey that sets velocity to a fixed value.", "Set velocity to 6")
        }
        Loader {
            id: keyInputSetVelocity6
            asynchronous: true
            Layout.fillWidth: true
        }
        Label {
            text: i18nc("Hotkey that sets velocity to a fixed value.", "Set velocity to 7")
        }
        Loader {
            id: keyInputSetVelocity7
            asynchronous: true
            Layout.fillWidth: true
        }
        Label {
            text: i18nc("Hotkey that sets velocity to a fixed value.", "Set velocity to 8")
        }
        Loader {
            id: keyInputSetVelocity8
            asynchronous: true
            Layout.fillWidth: true
        }
        Label {
            text: i18nc("Hotkey that sets velocity to a fixed value.", "Set velocity to 9")
        }
        Loader {
            id: keyInputSetVelocity9
            asynchronous: true
            Layout.fillWidth: true
        }

        QmlUtil {
            id: qmlutil
        }
    }
}
