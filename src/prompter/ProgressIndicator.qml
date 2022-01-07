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

import QtQuick.Controls 2.12
import org.kde.kirigami 2.11 as Kirigami

ScrollBar {
    id: scroller
    leftPadding: 0
    rightPadding: 0
    leftInset: 0
    rightInset: 0
    interactive: parseInt(prompter.state)===Prompter.States.Prompting || parseInt(prompter.state)===Prompter.States.Countdown || Kirigami.Settings.isMobile ? false : true
    stepSize: prompter.height/(4*(editor.height + prompter.topMargin + prompter.bottomMargin))
    policy: ScrollBar.AlwaysOn
}
