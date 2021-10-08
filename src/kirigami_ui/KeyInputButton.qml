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
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Button {
    id: keyInputButton

    signal toggleButtonsOff()
    signal setKey(var key)

    checkable: true
    flat: true
    Layout.fillWidth: true
    onClicked: {
        if (checked) {
            keyInputButton.toggleButtonsOff()
            checked = true
        }
    }
    Keys.onPressed: {
        if (checked) {
            if (isValidInput(event.key)) {
                keyInputButton.setKey(event.key);
                text = getKeyText(event);
            }
            event.accepted = true;
        }
        keyInputButton.toggleButtonsOff();
    }
    // Validate input
    function isValidInput(input) {
        let flag = false;
        Object.values(prompter.keys).every(assignedKey => {
            flag = assignedKey===input;
            return !flag;
        });
        return !flag && [Qt.Key_Escape, Qt.Key_Super_L, Qt.Key_Super_R, Qt.Key_Meta].indexOf(input)===-1
    }
    // Get key text
    function getKeyText(event) {
        let text = "";
        switch (event.key) {
            case Qt.Key_Escape: text = i18n("ESC"); break;
            case Qt.Key_Space: text = i18n("Spacebar"); break;
            case Qt.Key_Up: text = i18n("Up Arrow"); break;
            case Qt.Key_Down: text = i18n("Down Arrow"); break;
            case Qt.Key_Left: text = i18n("Left Arrow"); break;
            case Qt.Key_Right: text = i18n("Right Arrow"); break;
            case Qt.Key_Tab: text = i18n("Tab"); break;
            case Qt.Key_Backtab: text = i18n("Backtab"); break;
            case Qt.Key_PageUp: text = i18n("Page Up"); break;
            case Qt.Key_PageDown: text = i18n("Page Down"); break;
            case Qt.Key_Home: text = i18n("Home"); break;
            case Qt.Key_End: text = i18n("End"); break;
            case Qt.Key_Backspace: text = i18n("Backspace"); break;
            case Qt.Key_Delete: text = i18n("Delete"); break;
            case Qt.Key_Insert: text = i18n("Insert"); break;
            case Qt.Key_Enter: text = i18n("Enter"); break;
            case Qt.Key_Return: text = i18n("Enter"); break;
            case Qt.Key_Control: text = Qt.platform.os==="osx" || Qt.platform.os==="ios" || Qt.platform.os==="tvos" || Qt.platform.os==="ipados" ? i18n("Command") : i18n("Control"); break;
            case Qt.Key_Super_L: text = Qt.platform.os==="osx" || Qt.platform.os==="ios" || Qt.platform.os==="tvos" || Qt.platform.os==="ipados" ? i18n("Left Control") : (Qt.platform.os==="windows" || Qt.platform.os==="winrt" ? i18n("Left Windows") : (Qt.platform.os==="linux" || Qt.platform.os==="unix" ? i18n("Left Super") : i18n("Left Meta"))); break;
            case Qt.Key_Super_R: text = Qt.platform.os==="osx" || Qt.platform.os==="ios" || Qt.platform.os==="tvos" || Qt.platform.os==="ipados" ? i18n("Right Control") : (Qt.platform.os==="windows" || Qt.platform.os==="winrt" ? i18n("Right Windows") : (Qt.platform.os==="linux" || Qt.platform.os==="unix" ? i18n("Right Super") : i18n("Right Meta"))); break;
            case Qt.Key_Meta: text = Qt.platform.os==="osx" || Qt.platform.os==="ios" || Qt.platform.os==="tvos" || Qt.platform.os==="ipados" ? i18n("Control") : (Qt.platform.os==="windows" || Qt.platform.os==="winrt" ? i18n("Windows") : (Qt.platform.os==="linux" || Qt.platform.os==="unix" ? i18n("Super") : i18n("Meta"))); break;
            case Qt.Key_Alt: text = i18n("Alt"); break;
            case Qt.Key_AltGr: text = i18n("AltGr"); break;
            case Qt.Key_Shift: text = i18n("Shift"); break;
            case Qt.Key_NumLock: text = i18n("Number Lock"); break;
            case Qt.Key_CapsLock: text = i18n("Caps Lock"); break;
            case Qt.Key_ScrollLock: text = i18n("Scroll Lock"); break;
            case Qt.Key_F1: text = i18n("F1"); break;
            case Qt.Key_F2: text = i18n("F2"); break;
            case Qt.Key_F3: text = i18n("F3"); break;
            case Qt.Key_F4: text = i18n("F4"); break;
            case Qt.Key_F5: text = i18n("F5"); break;
            case Qt.Key_F6: text = i18n("F6"); break;
            case Qt.Key_F7: text = i18n("F7"); break;
            case Qt.Key_F8: text = i18n("F8"); break;
            case Qt.Key_F9: text = i18n("F9"); break;
            case Qt.Key_F10: text = i18n("F10"); break;
            case Qt.Key_F11: text = i18n("F11"); break;
            case Qt.Key_F12: text = i18n("F12"); break;
            case Qt.Key_F13: text = i18n("F13"); break;
            case Qt.Key_F14: text = i18n("F14"); break;
            case Qt.Key_F15: text = i18n("F15"); break;
            case Qt.Key_F16: text = i18n("F16"); break;
            case Qt.Key_F17: text = i18n("F17"); break;
            case Qt.Key_F18: text = i18n("F18"); break;
            case Qt.Key_F19: text = i18n("F19"); break;
            case Qt.Key_F20: text = i18n("F20"); break;
            case Qt.Key_F21: text = i18n("F21"); break;
            case Qt.Key_F22: text = i18n("F22"); break;
            case Qt.Key_F23: text = i18n("F23"); break;
            case Qt.Key_F24: text = i18n("F24"); break;
            case Qt.Key_F25: text = i18n("F25"); break;
            case Qt.Key_F26: text = i18n("F26"); break;
            case Qt.Key_F27: text = i18n("F27"); break;
            case Qt.Key_F28: text = i18n("F28"); break;
            case Qt.Key_F29: text = i18n("F29"); break;
            case Qt.Key_F30: text = i18n("F30"); break;
            case Qt.Key_F31: text = i18n("F31"); break;
            case Qt.Key_F32: text = i18n("F32"); break;
            case Qt.Key_F33: text = i18n("F33"); break;
            case Qt.Key_F34: text = i18n("F34"); break;
            case Qt.Key_F35: text = i18n("F35"); break;
            case Qt.Key_HomePage: text = i18n("Home Page"); break;
            case Qt.Key_LaunchMail: text = i18n("E-mail"); break;
            case Qt.Key_Refresh: text = i18n("Refresh"); break;
            case Qt.Key_Search: text = i18n("Search"); break;
            case Qt.Key_Zoom: text = i18n("Zoom"); break;
            case Qt.Key_Print: text = i18n("Print"); break;
            default:
                text = event.text==="" ? event.key : event.text;
        }
        return text
    }
}
