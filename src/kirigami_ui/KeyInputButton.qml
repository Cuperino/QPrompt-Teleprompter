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
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import com.cuperino.qprompt 1.0

Button {
    id: keyInputButton

    signal toggleButtonsOff()
    signal setKey(int key, int modifiers)

    // Validate input
    function isValidInput(key, modifiers) {
        const actions = [
            [prompter.keys.increaseVelocity, prompter.keys.increaseVelocityModifiers],
            [prompter.keys.decreaseVelocity, prompter.keys.decreaseVelocityModifiers],
            [prompter.keys.stop, prompter.keys.stopModifiers],
            [prompter.keys.pause, prompter.keys.pauseModifiers],
            [prompter.keys.reverse, prompter.keys.reverseModifiers],
            [prompter.keys.rewind, prompter.keys.rewindModifiers],
            [prompter.keys.fastForward, prompter.keys.fastForwardModifiers],
            [prompter.keys.skipBackwards, prompter.keys.skipBackwardsModifiers],
            [prompter.keys.skipForward, prompter.keys.skipForwardModifiers],
            [prompter.keys.previousMarker, prompter.keys.previousMarkerModifiers],
            [prompter.keys.nextMarker, prompter.keys.nextMarkerModifiers],
            [prompter.keys.toggle, prompter.keys.toggleModifiers],
            [prompter.keys.setVelocity0, prompter.keys.setVelocity0Modifiers],
            [prompter.keys.setVelocity1, prompter.keys.setVelocity1Modifiers],
            [prompter.keys.setVelocity2, prompter.keys.setVelocity2Modifiers],
            [prompter.keys.setVelocity3, prompter.keys.setVelocity3Modifiers],
            [prompter.keys.setVelocity4, prompter.keys.setVelocity4Modifiers],
            [prompter.keys.setVelocity5, prompter.keys.setVelocity5Modifiers],
            [prompter.keys.setVelocity6, prompter.keys.setVelocity6Modifiers],
            [prompter.keys.setVelocity7, prompter.keys.setVelocity7Modifiers],
            [prompter.keys.setVelocity8, prompter.keys.setVelocity8Modifiers],
            [prompter.keys.setVelocity9, prompter.keys.setVelocity9Modifiers]
        ]
        // Return invalid if key is in use
        let flag = false;
        for (let i=0; i<actions.length; i++) {
            if ( actions[i][0]===key && actions[i][1]===modifiers ) {
                flag = true;
                break;
            }
        }
        // The following inputs will not be considered valid on their own
        return !flag && [Qt.Key_Escape, Qt.Key_Super_L, Qt.Key_Super_R, Qt.Key_Meta].indexOf(key)===-1
    }

    QmlUtil {
        id: qmlutil
    }

    checkable: true
    flat: true

    onClicked: {
        if (checked) {
            keyInputButton.toggleButtonsOff()
            checked = true
        }
    }

    Layout.fillWidth: true
    Keys.onShortcutOverride: (event) => {
        if (event.key === Qt.Key_Escape)
            event.accepted = true
    }
    Keys.onPressed: (event) => {
        if (checked && [Qt.Key_Super_L, Qt.Key_Super_R, Qt.Key_Meta, Qt.Key_Control, Qt.Key_Shift, Qt.Key_Alt, Qt.Key_AltGr].indexOf(event.key)===-1) {
            if (isValidInput(event.key, event.modifiers)) {
                keyInputButton.setKey(event.key, event.modifiers);
                text = qmlutil.keyToString(event.key, event.modifiers);
            }
            event.accepted = true;
            keyInputButton.toggleButtonsOff();
        }
    }
}
