/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2023 Javier O. Cordero Pérez
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

import com.cuperino.qprompt.qmlutil 1.0

MouseArea {
    id: cursorAutoHide
    enabled: !root.pageStack.currentItem.editor.focus
    acceptedButtons: Qt.NoButton
    hoverEnabled: parseInt(root.pageStack.currentItem.prompter.state)===Prompter.States.Prompting
    onPositionChanged: function (mouse) {
        cursorUtil.restoreCursor();
        restart();
    }
    function reset() {
        timer.stop();
        cursorUtil.restoreCursor();
    }
    function restart() {
        if (parseInt(root.pageStack.currentItem.prompter.state)===Prompter.States.Prompting)
            timer.restart();
    }
    Timer {
        id: timer
        running: false
        interval: 1000
        triggeredOnStart: false
        onTriggered: {
            cursorUtil.hideCursor();
            stop();
            console.log("hid")
        }
    }
    QmlUtil {
        id: cursorUtil
    }
}
