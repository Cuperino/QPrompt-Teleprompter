/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2021-2025 Javier O. Cordero Pérez
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
    height: 680

    header: Kirigami.Heading {
        text: qsTr("Key Bindings", "Title of dialog where users customize keyboard inputs")
        level: 1
    }

    onOpened: {
        cursorAutoHide.restart();
        // When opening overlay, reset key input button's text.
        viewport.editor.enabled = false;
    }
    onClosed: {
        cursorAutoHide.restart();
        buttonGrid.toggleButtonsOff();
        viewport.editor.enabled = true;
        prompter.restoreFocus();
    }

    ColumnLayout {

        TabBar {
            id: inputSettingsTabs
            currentIndex: listView.currentIndex
            TabButton {
                text: qsTr("Keyboard Inputs")
                onClicked: listView.currentIndex = 0
            }
            TabButton {
                text: qsTr("Global Hotkeys")
                onClicked: listView.currentIndex = 1
            }
            Layout.fillWidth: true
            Material.theme: Material.Dark
        }
        Rectangle {
            color: "#292929"
            height: 1
            Layout.fillWidth: true
        }
        ListView {
            id: listView
            clip: true
            model: pointerSettingsTabModel
            currentIndex: PointerSettings.States.Arrow
            orientation: ListView.Horizontal
            highlightRangeMode: ListView.StrictlyEnforceRange
            snapMode: ListView.SnapOneItem
            highlightMoveVelocity: 2000
            maximumFlickVelocity: 20000
            height: keyConfigurationOverlay.height - inputSettingsTabs.height - 68
            cacheBuffer: 1
            keyNavigationEnabled: false
            Layout.fillWidth: true
        }
    }

    ObjectModel {
        id: pointerSettingsTabModel
        Flickable {
            width: listView.width
            height: listView.height
            contentWidth: buttonGrid.width
            contentHeight: buttonGrid.implicitHeight
            clip: true
            GridLayout {
                id: buttonGrid

                width: listView.width
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
                    text: qsTr("Set velocity modifier key", "Key that shifts velocoty to its negative value.")
                }
                ComboBox {
                    id: keyInputSetVelocityModifier
                    model: [
                        qsTr("Alt", "Alt key"),
                        qsTr("Ctrl", "Control key")
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
                    text: qsTr("Set velocity to 0", "Key that sets velocity to a fixed value.")
                }
                Loader {
                    id: keyInputSetVelocity0
                    asynchronous: true
                    Layout.fillWidth: true
                }
                Label {
                    text: qsTr("Set velocity to 1", "Key that sets velocity to a fixed value.")
                }
                Loader {
                    id: keyInputSetVelocity1
                    asynchronous: true
                    Layout.fillWidth: true
                }
                Label {
                    text: qsTr("Set velocity to 2", "Key that sets velocity to a fixed value.")
                }
                Loader {
                    id: keyInputSetVelocity2
                    asynchronous: true
                    Layout.fillWidth: true
                }
                Label {
                    text: qsTr("Set velocity to 3", "Key that sets velocity to a fixed value.")
                }
                Loader {
                    id: keyInputSetVelocity3
                    asynchronous: true
                    Layout.fillWidth: true
                }
                Label {
                    text: qsTr("Set velocity to 4", "Key that sets velocity to a fixed value.")
                }
                Loader {
                    id: keyInputSetVelocity4
                    asynchronous: true
                    Layout.fillWidth: true
                }
                Label {
                    text: qsTr("Set velocity to 5", "Key that sets velocity to a fixed value.")
                }
                Loader {
                    id: keyInputSetVelocity5
                    asynchronous: true
                    Layout.fillWidth: true
                }
                Label {
                    text: qsTr("Set velocity to 6", "Key that sets velocity to a fixed value.")
                }
                Loader {
                    id: keyInputSetVelocity6
                    asynchronous: true
                    Layout.fillWidth: true
                }
                Label {
                    text: qsTr("Set velocity to 7", "Key that sets velocity to a fixed value.")
                }
                Loader {
                    id: keyInputSetVelocity7
                    asynchronous: true
                    Layout.fillWidth: true
                }
                Label {
                    text: qsTr("Set velocity to 8", "Key that sets velocity to a fixed value.")
                }
                Loader {
                    id: keyInputSetVelocity8
                    asynchronous: true
                    Layout.fillWidth: true
                }
                Label {
                    text: qsTr("Set velocity to 9", "Key that sets velocity to a fixed value.")
                }
                Loader {
                    id: keyInputSetVelocity9
                    asynchronous: true
                    Layout.fillWidth: true
                }
                Label {
                    text: qsTr("Set velocity to 10", "Key that sets velocity to a fixed value.")
                }
                Loader {
                    id: keyInputSetVelocity10
                    asynchronous: true
                    Layout.fillWidth: true
                }
            }
        }
        Flickable {
            width: listView.width
            height: listView.height
            contentWidth: hotkeyGrid.width
            contentHeight: hotkeyGrid.implicitHeight
            clip: true
            GridLayout {
                id: hotkeyGrid

                width: listView.width
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
                    hotkeyInputTogglePrompter.setSource("KeyInputButton.qml", { "text": AppController.globalShortcutKey(GlobalHotkeys.TogglePrompter) });
                    hotkeyInputDecreaseVelocity.setSource("KeyInputButton.qml", { "text": AppController.globalShortcutKey(GlobalHotkeys.DecreaseVelocity) });
                    hotkeyInputIncreaseVelocity.setSource("KeyInputButton.qml", { "text": AppController.globalShortcutKey(GlobalHotkeys.IncreaseVelocity) });
                    hotkeyInputStop.setSource("KeyInputButton.qml", { "text": AppController.globalShortcutKey(GlobalHotkeys.Stop) });
                    hotkeyInputPlayPause.setSource("KeyInputButton.qml", { "text": AppController.globalShortcutKey(GlobalHotkeys.Pause) });
                    hotkeyInputReverse.setSource("KeyInputButton.qml", { "text": AppController.globalShortcutKey(GlobalHotkeys.Reverse) });
                    hotkeyInputRewind.setSource("KeyInputButton.qml", { "text": AppController.globalShortcutKey(GlobalHotkeys.Rewind) });
                    hotkeyInputFastForward.setSource("KeyInputButton.qml", { "text": AppController.globalShortcutKey(GlobalHotkeys.FastForward) });
                    hotkeyInputMoveBackwards.setSource("KeyInputButton.qml", { "text": AppController.globalShortcutKey(GlobalHotkeys.SkipBackwards) });
                    hotkeyInputMoveForward.setSource("KeyInputButton.qml", { "text": AppController.globalShortcutKey(GlobalHotkeys.SkipForwards) });
                    hotkeyInputPreviousMarker.setSource("KeyInputButton.qml", { "text": AppController.globalShortcutKey(GlobalHotkeys.PreviousMarker) });
                    hotkeyInputNextMarker.setSource("KeyInputButton.qml", { "text": AppController.globalShortcutKey(GlobalHotkeys.NextMarker) });
                    hotkeyInputSetVelocity0.setSource("KeyInputButton.qml", { "text": AppController.globalShortcutKey(GlobalHotkeys.VelocityTo0) });
                    hotkeyInputSetVelocity1.setSource("KeyInputButton.qml", { "text": AppController.globalShortcutKey(GlobalHotkeys.VelocityTo1) });
                    hotkeyInputSetVelocity2.setSource("KeyInputButton.qml", { "text": AppController.globalShortcutKey(GlobalHotkeys.VelocityTo2) });
                    hotkeyInputSetVelocity3.setSource("KeyInputButton.qml", { "text": AppController.globalShortcutKey(GlobalHotkeys.VelocityTo3) });
                    hotkeyInputSetVelocity4.setSource("KeyInputButton.qml", { "text": AppController.globalShortcutKey(GlobalHotkeys.VelocityTo4) });
                    hotkeyInputSetVelocity5.setSource("KeyInputButton.qml", { "text": AppController.globalShortcutKey(GlobalHotkeys.VelocityTo5) });
                    hotkeyInputSetVelocity6.setSource("KeyInputButton.qml", { "text": AppController.globalShortcutKey(GlobalHotkeys.VelocityTo6) });
                    hotkeyInputSetVelocity7.setSource("KeyInputButton.qml", { "text": AppController.globalShortcutKey(GlobalHotkeys.VelocityTo7) });
                    hotkeyInputSetVelocity8.setSource("KeyInputButton.qml", { "text": AppController.globalShortcutKey(GlobalHotkeys.VelocityTo8) });
                    hotkeyInputSetVelocity9.setSource("KeyInputButton.qml", { "text": AppController.globalShortcutKey(GlobalHotkeys.VelocityTo9) });
                    hotkeyInputSetVelocity10.setSource("KeyInputButton.qml", { "text": AppController.globalShortcutKey(GlobalHotkeys.VelocityTo10) });
                    hotkeyInputSetVelocityNeg1.setSource("KeyInputButton.qml", { "text": AppController.globalShortcutKey(GlobalHotkeys.VelocityToNeg1) });
                    hotkeyInputSetVelocityNeg2.setSource("KeyInputButton.qml", { "text": AppController.globalShortcutKey(GlobalHotkeys.VelocityToNeg2) });
                    hotkeyInputSetVelocityNeg3.setSource("KeyInputButton.qml", { "text": AppController.globalShortcutKey(GlobalHotkeys.VelocityToNeg3) });
                    hotkeyInputSetVelocityNeg4.setSource("KeyInputButton.qml", { "text": AppController.globalShortcutKey(GlobalHotkeys.VelocityToNeg4) });
                    hotkeyInputSetVelocityNeg5.setSource("KeyInputButton.qml", { "text": AppController.globalShortcutKey(GlobalHotkeys.VelocityToNeg5) });
                    hotkeyInputSetVelocityNeg6.setSource("KeyInputButton.qml", { "text": AppController.globalShortcutKey(GlobalHotkeys.VelocityToNeg6) });
                    hotkeyInputSetVelocityNeg7.setSource("KeyInputButton.qml", { "text": AppController.globalShortcutKey(GlobalHotkeys.VelocityToNeg7) });
                    hotkeyInputSetVelocityNeg8.setSource("KeyInputButton.qml", { "text": AppController.globalShortcutKey(GlobalHotkeys.VelocityToNeg8) });
                    hotkeyInputSetVelocityNeg9.setSource("KeyInputButton.qml", { "text": AppController.globalShortcutKey(GlobalHotkeys.VelocityToNeg9) });
                    hotkeyInputSetVelocityNeg10.setSource("KeyInputButton.qml", { "text": AppController.globalShortcutKey(GlobalHotkeys.VelocityToNeg10) });
                }
                Connections {
                    target: hotkeyInputTogglePrompter.item
                    function onToggleButtonsOff() { hotkeyGrid.toggleButtonsOff(); }
                    function onSetKey(key, modifiers) {
                        AppController.setGlobalShortcut(key, modifiers, GlobalHotkeys.TogglePrompter);
                    }
                }
                Connections {
                    target: hotkeyInputDecreaseVelocity.item
                    function onToggleButtonsOff() { hotkeyGrid.toggleButtonsOff(); }
                    function onSetKey(key, modifiers) {
                        AppController.setGlobalShortcut(key, modifiers, GlobalHotkeys.DecreaseVelocity);
                    }
                }
                Connections {
                    target: hotkeyInputIncreaseVelocity.item
                    function onToggleButtonsOff() { hotkeyGrid.toggleButtonsOff(); }
                    function onSetKey(key, modifiers) {
                        AppController.setGlobalShortcut(key, modifiers, GlobalHotkeys.IncreaseVelocity);
                    }
                }
                Connections {
                    target: hotkeyInputStop.item
                    function onToggleButtonsOff() { hotkeyGrid.toggleButtonsOff(); }
                    function onSetKey(key, modifiers) {
                        AppController.setGlobalShortcut(key, modifiers, GlobalHotkeys.Stop);
                    }
                }
                Connections {
                    target: hotkeyInputPlayPause.item
                    function onToggleButtonsOff() { hotkeyGrid.toggleButtonsOff(); }
                    function onSetKey(key, modifiers) {
                        AppController.setGlobalShortcut(key, modifiers, GlobalHotkeys.Pause);
                    }
                }
                Connections {
                    target: hotkeyInputReverse.item
                    function onToggleButtonsOff() { hotkeyGrid.toggleButtonsOff(); }
                    function onSetKey(key, modifiers) {
                        AppController.setGlobalShortcut(key, modifiers, GlobalHotkeys.Reverse);
                    }
                }
                Connections {
                    target: hotkeyInputRewind.item
                    function onToggleButtonsOff() { hotkeyGrid.toggleButtonsOff(); }
                    function onSetKey(key, modifiers) {
                        AppController.setGlobalShortcut(key, modifiers, GlobalHotkeys.Rewind);
                    }
                }
                Connections {
                    target: hotkeyInputFastForward.item
                    function onToggleButtonsOff() { hotkeyGrid.toggleButtonsOff(); }
                    function onSetKey(key, modifiers) {
                        AppController.setGlobalShortcut(key, modifiers, GlobalHotkeys.FastForward);
                    }
                }
                Connections {
                    target: hotkeyInputMoveBackwards.item
                    function onToggleButtonsOff() { hotkeyGrid.toggleButtonsOff(); }
                    function onSetKey(key, modifiers) {
                        AppController.setGlobalShortcut(key, modifiers, GlobalHotkeys.SkipBackwards);
                    }
                }
                Connections {
                    target: hotkeyInputMoveForward.item
                    function onToggleButtonsOff() { hotkeyGrid.toggleButtonsOff(); }
                    function onSetKey(key, modifiers) {
                        AppController.setGlobalShortcut(key, modifiers, GlobalHotkeys.SkipForward);
                    }
                }
                Connections {
                    target: hotkeyInputPreviousMarker.item
                    function onToggleButtonsOff() { hotkeyGrid.toggleButtonsOff(); }
                    function onSetKey(key, modifiers) {
                        AppController.setGlobalShortcut(key, modifiers, GlobalHotkeys.PreviousMarker);
                    }
                }
                Connections {
                    target: hotkeyInputNextMarker.item
                    function onToggleButtonsOff() { hotkeyGrid.toggleButtonsOff(); }
                    function onSetKey(key, modifiers) {
                        AppController.setGlobalShortcut(key, modifiers, GlobalHotkeys.NextMarker);
                    }
                }
                Connections {
                    target: hotkeyInputSetVelocity0.item
                    function onToggleButtonsOff() { hotkeyGrid.toggleButtonsOff(); }
                    function onSetKey(key, modifiers) {
                        AppController.setGlobalShortcut(key, modifiers, GlobalHotkeys.VelocityTo0);
                    }
                }
                Connections {
                    target: hotkeyInputSetVelocity1.item
                    function onToggleButtonsOff() { hotkeyGrid.toggleButtonsOff(); }
                    function onSetKey(key, modifiers) {
                        AppController.setGlobalShortcut(key, modifiers, GlobalHotkeys.VelocityTo1);
                    }
                }
                Connections {
                    target: hotkeyInputSetVelocity2.item
                    function onToggleButtonsOff() { hotkeyGrid.toggleButtonsOff(); }
                    function onSetKey(key, modifiers) {
                        AppController.setGlobalShortcut(key, modifiers, GlobalHotkeys.VelocityTo2);
                    }
                }
                Connections {
                    target: hotkeyInputSetVelocity3.item
                    function onToggleButtonsOff() { hotkeyGrid.toggleButtonsOff(); }
                    function onSetKey(key, modifiers) {
                        AppController.setGlobalShortcut(key, modifiers, GlobalHotkeys.VelocityTo3);
                    }
                }
                Connections {
                    target: hotkeyInputSetVelocity4.item
                    function onToggleButtonsOff() { hotkeyGrid.toggleButtonsOff(); }
                    function onSetKey(key, modifiers) {
                        AppController.setGlobalShortcut(key, modifiers, GlobalHotkeys.VelocityTo4);
                    }
                }
                Connections {
                    target: hotkeyInputSetVelocity5.item
                    function onToggleButtonsOff() { hotkeyGrid.toggleButtonsOff(); }
                    function onSetKey(key, modifiers) {
                        AppController.setGlobalShortcut(key, modifiers, GlobalHotkeys.VelocityTo5);
                    }
                }
                Connections {
                    target: hotkeyInputSetVelocity6.item
                    function onToggleButtonsOff() { hotkeyGrid.toggleButtonsOff(); }
                    function onSetKey(key, modifiers) {
                        AppController.setGlobalShortcut(key, modifiers, GlobalHotkeys.VelocityTo6);
                    }
                }
                Connections {
                    target: hotkeyInputSetVelocity7.item
                    function onToggleButtonsOff() { hotkeyGrid.toggleButtonsOff(); }
                    function onSetKey(key, modifiers) {
                        AppController.setGlobalShortcut(key, modifiers, GlobalHotkeys.VelocityTo7);
                    }
                }
                Connections {
                    target: hotkeyInputSetVelocity8.item
                    function onToggleButtonsOff() { hotkeyGrid.toggleButtonsOff(); }
                    function onSetKey(key, modifiers) {
                        AppController.setGlobalShortcut(key, modifiers, GlobalHotkeys.VelocityTo8);
                    }
                }
                Connections {
                    target: hotkeyInputSetVelocity9.item
                    function onToggleButtonsOff() { hotkeyGrid.toggleButtonsOff(); }
                    function onSetKey(key, modifiers) {
                        AppController.setGlobalShortcut(key, modifiers, GlobalHotkeys.VelocityTo9);
                    }
                }
                Connections {
                    target: hotkeyInputSetVelocity10.item
                    function onToggleButtonsOff() { hotkeyGrid.toggleButtonsOff(); }
                    function onSetKey(key, modifiers) {
                        AppController.setGlobalShortcut(key, modifiers, GlobalHotkeys.VelocityTo10);
                    }
                }
                Connections {
                    target: hotkeyInputSetVelocityNeg1.item
                    function onToggleButtonsOff() { hotkeyGrid.toggleButtonsOff(); }
                    function onSetKey(key, modifiers) {
                        AppController.setGlobalShortcut(key, modifiers, GlobalHotkeys.VelocityToNeg1);
                    }
                }
                Connections {
                    target: hotkeyInputSetVelocityNeg2.item
                    function onToggleButtonsOff() { hotkeyGrid.toggleButtonsOff(); }
                    function onSetKey(key, modifiers) {
                        AppController.setGlobalShortcut(key, modifiers, GlobalHotkeys.VelocityToNeg2);
                    }
                }
                Connections {
                    target: hotkeyInputSetVelocityNeg3.item
                    function onToggleButtonsOff() { hotkeyGrid.toggleButtonsOff(); }
                    function onSetKey(key, modifiers) {
                        AppController.setGlobalShortcut(key, modifiers, GlobalHotkeys.VelocityToNeg3);
                    }
                }
                Connections {
                    target: hotkeyInputSetVelocityNeg4.item
                    function onToggleButtonsOff() { hotkeyGrid.toggleButtonsOff(); }
                    function onSetKey(key, modifiers) {
                        AppController.setGlobalShortcut(key, modifiers, GlobalHotkeys.VelocityToNeg4);
                    }
                }
                Connections {
                    target: hotkeyInputSetVelocityNeg5.item
                    function onToggleButtonsOff() { hotkeyGrid.toggleButtonsOff(); }
                    function onSetKey(key, modifiers) {
                        AppController.setGlobalShortcut(key, modifiers, GlobalHotkeys.VelocityToNeg5);
                    }
                }
                Connections {
                    target: hotkeyInputSetVelocityNeg6.item
                    function onToggleButtonsOff() { hotkeyGrid.toggleButtonsOff(); }
                    function onSetKey(key, modifiers) {
                        AppController.setGlobalShortcut(key, modifiers, GlobalHotkeys.VelocityToNeg6);
                    }
                }
                Connections {
                    target: hotkeyInputSetVelocityNeg7.item
                    function onToggleButtonsOff() { hotkeyGrid.toggleButtonsOff(); }
                    function onSetKey(key, modifiers) {
                        AppController.setGlobalShortcut(key, modifiers, GlobalHotkeys.VelocityToNeg7);
                    }
                }
                Connections {
                    target: hotkeyInputSetVelocityNeg8.item
                    function onToggleButtonsOff() { hotkeyGrid.toggleButtonsOff(); }
                    function onSetKey(key, modifiers) {
                        AppController.setGlobalShortcut(key, modifiers, GlobalHotkeys.VelocityToNeg8);
                    }
                }
                Connections {
                    target: hotkeyInputSetVelocityNeg9.item
                    function onToggleButtonsOff() { hotkeyGrid.toggleButtonsOff(); }
                    function onSetKey(key, modifiers) {
                        AppController.setGlobalShortcut(key, modifiers, GlobalHotkeys.VelocityToNeg9);
                    }
                }
                Connections {
                    target: hotkeyInputSetVelocityNeg10.item
                    function onToggleButtonsOff() { hotkeyGrid.toggleButtonsOff(); }
                    function onSetKey(key, modifiers) {
                        AppController.setGlobalShortcut(key, modifiers, GlobalHotkeys.VelocityToNeg10);
                    }
                }

                Label {
                    text: qsTr("Toggle Prompter State")
                }
                Loader {
                    id: hotkeyInputTogglePrompter
                    asynchronous: true
                    Layout.fillWidth: true
                }
                Label {
                    text: qsTr("Decrease Velocity")
                }
                Loader {
                    id: hotkeyInputDecreaseVelocity
                    asynchronous: true
                    Layout.fillWidth: true
                }
                Label {
                    text: qsTr("Increase Velocity")
                }
                Loader {
                    id: hotkeyInputIncreaseVelocity
                    asynchronous: true
                    Layout.fillWidth: true
                }
                Label {
                    text: qsTr("Stop")
                }
                Loader {
                    id: hotkeyInputStop
                    asynchronous: true
                    Layout.fillWidth: true
                }
                Label {
                    text: qsTr("Play/Pause")
                }
                Loader {
                    id: hotkeyInputPlayPause
                    asynchronous: true
                    Layout.fillWidth: true
                }
                Label {
                    text: qsTr("Reverse")
                }
                Loader {
                    id: hotkeyInputReverse
                    asynchronous: true
                    Layout.fillWidth: true
                }
                Label {
                    text: qsTr("Rewind")
                }
                Loader {
                    id: hotkeyInputRewind
                    asynchronous: true
                    Layout.fillWidth: true
                }
                Label {
                    text: qsTr("Fast Forward")
                }
                Loader {
                    id: hotkeyInputFastForward
                    asynchronous: true
                    Layout.fillWidth: true
                }
                Label {
                    text: qsTr("Move Backwards", "Skip to earlier text while prompting or editing")
                }
                Loader {
                    id: hotkeyInputMoveBackwards
                    asynchronous: true
                    Layout.fillWidth: true
                }
                Label {
                    text: qsTr("Move Forward", "Skip to later text while prompting or editing")
                }
                Loader {
                    id: hotkeyInputMoveForward
                    asynchronous: true
                    Layout.fillWidth: true
                }
                Label {
                    text: qsTr("Go to Previous Marker", "Skip to closest marker behind of current position")
                }
                Loader {
                    id: hotkeyInputPreviousMarker
                    asynchronous: true
                    Layout.fillWidth: true
                }
                Label {
                    text: qsTr("Go to Next Marker", "Skip to closest marker ahead of current position")
                }
                Loader {
                    id: hotkeyInputNextMarker
                    asynchronous: true
                    Layout.fillWidth: true
                }
                // Label {
                //     text: qsTr("Set velocity modifier hotkey", "Hotkey that shifts velocoty to its negative value.")
                // }
                // ComboBox {
                //     id: hotkeyInputSetVelocityModifier
                //     model: [
                //         qsTr("Alt", "Alt hotkey"),
                //         qsTr("Ctrl", "Control hotkey")
                //     ]
                //     z: 1
                //     onActivated: {
                //         switch(currentIndex) {
                //             case 1:
                //                 prompter.keys.setVelocityModifier = Qt.ControlModifier; break;
                //             case 2:
                //                 prompter.keys.setVelocityModifier = Qt.ShiftModifier; break;
                //             case 3:
                //                 prompter.keys.setVelocityModifier = Qt.MetaModifier; break;
                //             case 0:
                //                 prompter.keys.setVelocityModifier = Qt.AltModifier; break;
                //         }
                //         console.log(prompter.keys.setVelocityModifier)
                //     }
                //     Layout.fillWidth: true
                //     Material.theme: Material.Dark
                //     Component.onCompleted: {
                //         switch(prompter.keys.setVelocityModifier) {
                //             case Qt.ControlModifier:
                //                 currentIndex = 1; break;
                //             case Qt.ShiftModifier:
                //                 currentIndex = 2; break;
                //             case Qt.MetaModifier:
                //                 currentIndex = 3; break;
                //             case Qt.AltModifier:
                //             default:
                //                 currentIndex = 0; break;
                //         }
                //     }
                // }
                Label {
                    text: qsTr("Set velocity to 0", "Hotkey that sets velocity to a fixed value.")
                }
                Loader {
                    id: hotkeyInputSetVelocity0
                    asynchronous: true
                    Layout.fillWidth: true
                }
                Label {
                    text: qsTr("Set velocity to 1", "Hotkey that sets velocity to a fixed value.")
                }
                Loader {
                    id: hotkeyInputSetVelocity1
                    asynchronous: true
                    Layout.fillWidth: true
                }
                Label {
                    text: qsTr("Set velocity to 2", "Hotkey that sets velocity to a fixed value.")
                }
                Loader {
                    id: hotkeyInputSetVelocity2
                    asynchronous: true
                    Layout.fillWidth: true
                }
                Label {
                    text: qsTr("Set velocity to 3", "Hotkey that sets velocity to a fixed value.")
                }
                Loader {
                    id: hotkeyInputSetVelocity3
                    asynchronous: true
                    Layout.fillWidth: true
                }
                Label {
                    text: qsTr("Set velocity to 4", "Hotkey that sets velocity to a fixed value.")
                }
                Loader {
                    id: hotkeyInputSetVelocity4
                    asynchronous: true
                    Layout.fillWidth: true
                }
                Label {
                    text: qsTr("Set velocity to 5", "Hotkey that sets velocity to a fixed value.")
                }
                Loader {
                    id: hotkeyInputSetVelocity5
                    asynchronous: true
                    Layout.fillWidth: true
                }
                Label {
                    text: qsTr("Set velocity to 6", "Hotkey that sets velocity to a fixed value.")
                }
                Loader {
                    id: hotkeyInputSetVelocity6
                    asynchronous: true
                    Layout.fillWidth: true
                }
                Label {
                    text: qsTr("Set velocity to 7", "Hotkey that sets velocity to a fixed value.")
                }
                Loader {
                    id: hotkeyInputSetVelocity7
                    asynchronous: true
                    Layout.fillWidth: true
                }
                Label {
                    text: qsTr("Set velocity to 8", "Hotkey that sets velocity to a fixed value.")
                }
                Loader {
                    id: hotkeyInputSetVelocity8
                    asynchronous: true
                    Layout.fillWidth: true
                }
                Label {
                    text: qsTr("Set velocity to 9", "Hotkey that sets velocity to a fixed value.")
                }
                Loader {
                    id: hotkeyInputSetVelocity9
                    asynchronous: true
                    Layout.fillWidth: true
                }
                Label {
                    text: qsTr("Set velocity to 10", "Hotkey that sets velocity to a fixed value.")
                }
                Loader {
                    id: hotkeyInputSetVelocity10
                    asynchronous: true
                    Layout.fillWidth: true
                }
                Label {
                    text: qsTr("Set velocity to -1", "Hotkey that sets velocity to a fixed value.")
                }
                Loader {
                    id: hotkeyInputSetVelocityNeg1
                    asynchronous: true
                    Layout.fillWidth: true
                }
                Label {
                    text: qsTr("Set velocity to -2", "Hotkey that sets velocity to a fixed value.")
                }
                Loader {
                    id: hotkeyInputSetVelocityNeg2
                    asynchronous: true
                    Layout.fillWidth: true
                }
                Label {
                    text: qsTr("Set velocity to -3", "Hotkey that sets velocity to a fixed value.")
                }
                Loader {
                    id: hotkeyInputSetVelocityNeg3
                    asynchronous: true
                    Layout.fillWidth: true
                }
                Label {
                    text: qsTr("Set velocity to -4", "Hotkey that sets velocity to a fixed value.")
                }
                Loader {
                    id: hotkeyInputSetVelocityNeg4
                    asynchronous: true
                    Layout.fillWidth: true
                }
                Label {
                    text: qsTr("Set velocity to -5", "Hotkey that sets velocity to a fixed value.")
                }
                Loader {
                    id: hotkeyInputSetVelocityNeg5
                    asynchronous: true
                    Layout.fillWidth: true
                }
                Label {
                    text: qsTr("Set velocity to -6", "Hotkey that sets velocity to a fixed value.")
                }
                Loader {
                    id: hotkeyInputSetVelocityNeg6
                    asynchronous: true
                    Layout.fillWidth: true
                }
                Label {
                    text: qsTr("Set velocity to -7", "Hotkey that sets velocity to a fixed value.")
                }
                Loader {
                    id: hotkeyInputSetVelocityNeg7
                    asynchronous: true
                    Layout.fillWidth: true
                }
                Label {
                    text: qsTr("Set velocity to -8", "Hotkey that sets velocity to a fixed value.")
                }
                Loader {
                    id: hotkeyInputSetVelocityNeg8
                    asynchronous: true
                    Layout.fillWidth: true
                }
                Label {
                    text: qsTr("Set velocity to -9", "Hotkey that sets velocity to a fixed value.")
                }
                Loader {
                    id: hotkeyInputSetVelocityNeg9
                    asynchronous: true
                    Layout.fillWidth: true
                }
                Label {
                    text: qsTr("Set velocity to -10", "Hotkey that sets velocity to a fixed value.")
                }
                Loader {
                    id: hotkeyInputSetVelocityNeg10
                    asynchronous: true
                    Layout.fillWidth: true
                }
            }
        }

        QmlUtil {
            id: qmlutil
        }
    }
}
