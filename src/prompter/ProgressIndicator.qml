/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2020-2022 Javier O. Cordero Pérez
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
import com.cuperino.qprompt.abstractunits 1.0

ScrollBar {
    id: scroller
    property bool opaqueScroller: [Prompter.States.Prompting, Prompter.States.Countdown].indexOf(parseInt(prompter.state)) === -1
    leftPadding: 0
    rightPadding: 0
    leftInset: 0
    rightInset: 0
    interactive: !opaqueScroller || root.__isMobile ? false : true
    stepSize: prompter.height/(4*(editor.height + prompter.topMargin + prompter.bottomMargin))
    policy: ScrollBar.AlwaysOn
    //opacity: opaqueScroller ? 0.40 : 1
    contentItem: Rectangle {
        implicitWidth: interactive ? 13 : 6
        implicitHeight: 100
        radius: scroller.pressed && !(prompter.__atStart||prompter.__atEnd) ? width / 2 : 0
        color: opaqueScroller ? (scroller.pressed ? "#ffffff" : "#d7d9d7") : "#d7d9d7";
        Behavior on radius {
            enabled: true
            animation: NumberAnimation {
                duration: Units.ShortDuration
                easing.type: Easing.Linear
            }
        }
    }
    background: Rectangle {
        color: "#505050"
    }
}
