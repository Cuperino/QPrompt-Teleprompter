/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2020 Javier O. Cordero Pérez
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

import QtQuick.Controls 2.15

ScrollBar {
    id: scroller
    policy: ScrollBar.AlwaysOn
    interactive: true
    leftPadding: 0
    rightPadding: 0
    leftInset: 0
    rightInset: 0
    stepSize: (prompter.height)/(/*4*/5*(editor.height + prompter.height))
    //parent: prompter.parent
    //position: -prompter.height / (editor.height + prompter.height)
}
