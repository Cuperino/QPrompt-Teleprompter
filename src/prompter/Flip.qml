/****************************************************************************
 * *
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
import com.cuperino.qprompt.abstractunits 1.0

Scale {
    origin.x: width/2
    origin.y: height/2
    //xScale: parseInt(prompter.state)!==Prompter.States.Editing && prompter.__flipX ? -1 : 1
    //yScale: parseInt(prompter.state)!==Prompter.States.Editing && prompter.__flipY ? -1 : 1
    xScale: prompter.__flipX ? -1 : 1
    yScale: prompter.__flipY ? -1 : 1
    Behavior on xScale {
        enabled: true
        animation: NumberAnimation {
            duration: Units.LongDuration
            easing.type: Easing.OutQuad
        }
    }
    Behavior on yScale {
        enabled: true
        animation: NumberAnimation {
            duration: Units.LongDuration
            easing.type: Easing.OutQuad
        }
    }
}
