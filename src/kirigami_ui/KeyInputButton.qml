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

import com.cuperino.qprompt.qmlutil 1.0

Button {
    id: keyInputButton

    signal toggleButtonsOff()
    signal setKey(int key, int modifiers)

    // Validate input
    function isValidInput(key, modifiers) {
        const actions = [
            [prompter.keys.increaseVelocity, prompter.keys.increaseVelocityModifiers],
            [prompter.keys.decreaseVelocity, prompter.keys.decreaseVelocityModifiers],
            [prompter.keys.pause, prompter.keys.pauseModifiers],
            [prompter.keys.skipBackwards, prompter.keys.skipBackwardsModifiers],
            [prompter.keys.skipForward, prompter.keys.skipForwardModifiers],
            [prompter.keys.previousMarker, prompter.keys.previousMarkerModifiers],
            [prompter.keys.nextMarker, prompter.keys.nextMarkerModifiers],
            [prompter.keys.toggle, prompter.keys.toggleModifiers]
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
    Keys.onShortcutOverride: {
        if (event.key === Qt.Key_Escape)
            event.accepted = true
    }
    Keys.onPressed: {
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
