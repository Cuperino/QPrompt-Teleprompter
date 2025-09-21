/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2023-2025 Javier O. Cordero Pérez
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

import com.cuperino.qprompt 1.0

MouseArea {
    id: cursorAutoHide
    enabled: !root.pageStack.currentItem.editor.activeFocus
    focus: false
    acceptedButtons: Qt.NoButton
    hoverEnabled: parseInt(root.pageStack.currentItem.prompter.state)===Prompter.States.Prompting
    cursorShape: undefined
    onPositionChanged: function (mouse) {
        cursorUtil.restoreCursor();
        restart();
    }
    property var ignored
    function reset() {
        timer.stop();
        cursorUtil.restoreCursor();
    }
    function restart() {
        if (parseInt(root.pageStack.currentItem.prompter.state)===Prompter.States.Prompting && typeof(ignored)!=="undefined" && !ignored.drawerOpen)
            timer.restart();
    }
    function hide() {
        cursorUtil.hideCursor();
    }
    Timer {
        id: timer
        running: false
        interval: 1000
        triggeredOnStart: false
        onTriggered: {
            stop();
            if (root.activeFocusItem === root.pageStack.currentItem.prompter || typeof projectionWindow!=="undefined" && projectionWindow.active)
                cursorUtil.hideCursor();
        }
    }
    QmlUtil {
        id: cursorUtil
    }
}
