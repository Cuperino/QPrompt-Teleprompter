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

import org.kde.kirigami 2.9 as Kirigami

Kirigami.AboutPage {
    globalToolBarStyle: Kirigami.ApplicationHeaderStyle.Titles
    getInvolvedUrl: "https://l10n.qprompt.app/"

    mainAction: Kirigami.Action {
        icon.name: !Kirigami.Settings.isMobile && pageStack.globalToolBar.actualStyle === Kirigami.ApplicationHeaderStyle.None ? 'go-previous' : (['android', 'ios', 'tvos'].indexOf(Qt.platform.os)===-1 ? "mail-mark-unread" : "draw-star")
        onTriggered: {
            if (!Kirigami.Settings.isMobile && pageStack.globalToolBar.actualStyle === Kirigami.ApplicationHeaderStyle.None)
                root.pageStack.layers.clear()
            else if (Qt.platform.os === 'android')
                Qt.openUrlExternally("https://play.google.com/store/apps/details?id=com.cuperino.qprompt")
            else if (Qt.platform.os === 'ios' || Qt.platform.os === 'tvos')
                Qt.openUrlExternally("https://apps.apple.com/us/app/qprompt/id##########")
            else
                Qt.openUrlExternally("https://feedback.qprompt.app")
        }
    }
}
