/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2026 Javier O. Cordero Pérez
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

import QtQuick 2.15
import QtQml 2.15
import QtQml.Models 2.15
import org.kde.kirigami 2.11 as Kirigami
import QtCore 6.5

import com.cuperino.qprompt 1.0

QtObject {
    id: root

    readonly property int maxEntries: 30
    readonly property int displayLength: 64
    readonly property int count: recentsModel.count
    property var util: null
    property Kirigami.Action targetAction: null


    property string _serialized: "[]"

    property Settings _settings: Settings {
        category: "recentDocuments"
        property alias data: root._serialized
    }

    property ListModel _model: ListModel {
        id: recentsModel
    }

    property Kirigami.Action _clearAction: Kirigami.Action {
        id: recentsClearAction
        text: qsTr("Clear List", "Main menu action. Clears the list of recently opened documents.")
        icon.name: "edit-clear-history"
        enabled: recentsModel.count > 0
        onTriggered: root.clearAll()
    }

    property Kirigami.Action _separatorAction: Kirigami.Action {
        id: recentsSeparator
        separator: true
    }

    property Component _recentActionComponent: Component {
        Kirigami.Action {
            property string uri: ""
            property bool isRemote: false
            property bool exists: true
            text: root._elideMiddle(uri, root.displayLength)
            tooltip: uri
            enabled: exists
            onTriggered: root.openRequested(uri, isRemote)
        }
    }

    property var _dynamicChildren: []

    onTargetActionChanged: _rebuildChildren()

    signal openRequested(string uri, bool isRemote)

    function _rebuildChildren() {
        if (!targetAction)
            return
        const previous = _dynamicChildren
        const created = []
        const arr = []
        for (var j = 0; j < recentsModel.count; j++) {
            const item = recentsModel.get(j)
            const obj = _recentActionComponent.createObject(targetAction, {
                uri: item.uri,
                isRemote: Boolean(item.isRemote),
                exists: Boolean(item.exists)
            })
            created.push(obj)
            arr.push(obj)
        }
        if (recentsModel.count > 0)
            arr.push(_separatorAction)
        arr.push(_clearAction)
        targetAction.children = arr
        _dynamicChildren = created
        for (var k = 0; k < previous.length; k++) {
            if (previous[k])
                previous[k].destroy()
        }
    }

    function _elideMiddle(text: string, maxChars: int): string {
        const s = text
        if (s.length <= maxChars)
            return s
        const keep = maxChars - 1
        const head = Math.ceil(keep / 2)
        const tail = Math.floor(keep / 2)
        return s.substring(0, head) + "…" + s.substring(s.length - tail)
    }

    function add(uri: string, isRemote: bool) {
        if (!uri)
            return
        const u = uri
        if (!u.length)
            return
        for (var i = 0; i < recentsModel.count; i++) {
            if (recentsModel.get(i).uri === u) {
                if (i !== 0)
                    recentsModel.move(i, 0, 1)
                recentsModel.setProperty(0, "isRemote", isRemote)
                recentsModel.setProperty(0, "exists", true)
                _save()
                _rebuildChildren()
                return
            }
        }
        recentsModel.insert(0, { uri: u, isRemote: isRemote, exists: true })
        while (recentsModel.count > root.maxEntries)
            recentsModel.remove(recentsModel.count - 1)
        _save()
        refreshExistence()
        _rebuildChildren()
    }

    function clearAll() {
        recentsModel.clear()
        _save()
        _rebuildChildren()
    }

    function refreshExistence() {
        var anyChanged = false
        for (var i = 0; i < recentsModel.count; i++) {
            const item = recentsModel.get(i)
            if (item.isRemote) {
                if (!item.exists) {
                    recentsModel.setProperty(i, "exists", true)
                    anyChanged = true
                }
            } else {
                const ok = root.util ? root.util.fileExists(item.uri) : true
                if (item.exists !== ok) {
                    recentsModel.setProperty(i, "exists", ok)
                    anyChanged = true
                }
            }
        }
        if (anyChanged && _dynamicChildren.length === recentsModel.count) {
            for (var j = 0; j < recentsModel.count; j++) {
                const it = recentsModel.get(j)
                _dynamicChildren[j].exists = Boolean(it.exists)
            }
        }
    }

    function _save() {
        const arr = []
        for (var i = 0; i < recentsModel.count; i++) {
            const it = recentsModel.get(i)
            arr.push({ uri: it.uri, isRemote: it.isRemote })
        }
        root._serialized = JSON.stringify(arr)
    }

    function _load() {
        recentsModel.clear()
        try {
            const arr = JSON.parse(root._serialized)
            if (Array.isArray(arr)) {
                for (var i = 0; i < arr.length && i < root.maxEntries; i++) {
                    const entry = arr[i]
                    if (entry && entry.uri)
                        recentsModel.append({
                            uri: String(entry.uri),
                            isRemote: Boolean(entry.isRemote),
                            exists: true
                        })
                }
            }
        } catch (e) {
            recentsModel.clear()
        }
        refreshExistence()
        _rebuildChildren()
    }

    Component.onCompleted: _load()
}
