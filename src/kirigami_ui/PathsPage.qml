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
import org.kde.kirigami 2.11 as Kirigami
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtCore 6.5
import Qt.labs.platform 1.1 as Labs

Kirigami.ScrollablePage {

    id: pathSettings

    property alias sofficePath: sofficePathField.text;
    property string currentlyBrowsing: "soffice";
    readonly property string sofficeActualPath: {
        if (Qt.platform.os === "osx")
            return sofficePath.concat("/Contents/MacOS/soffice");
        else
            return sofficePath;
    }

    title: qsTr("External Tools")

    background: Rectangle {
        color: Kirigami.Theme.alternateBackgroundColor
    }

    Settings {
        id: pathSettingsStorage
        category: "paths"
        property alias soffice: pathSettings.sofficePath
    }
    ColumnLayout {
        id: path_settings
        width: parent.implicitWidth
        Kirigami.Heading {
            text: qsTr("LibreOffice")
        }
        TextArea {
            background: Item{}
            readOnly: true
            wrapMode: TextEdit.Wrap
            text: qsTr("QPrompt can make transparent use of LibreOffice to convert Microsoft Word, "
                       + "Open Document Format, and other office documents into a format QPrompt "
                       + "understands. Install LibreOffice and ensure this field points to its "
                       + "location, so QPrompt can open office documents.")
            Layout.fillWidth: true
        }
        RowLayout {
            Button {
                text: qsTr("Browse for %1", "Browse for PROGRAM").arg("LibreOffice")
                onPressed: {
                    pathSettings.currentlyBrowsing = "soffice";
                    pathsDialog.open();
                }
            }
            TextField {
                id: sofficePathField
                placeholderText: switch(Qt.platform.os) {
                                 case "windows":
                                     return "C:/Program Files/LibreOffice/program/soffice.exe";
                                 case "osx":
                                     return "/Applications/LibreOffice.app";
                                 default:
                                     // Linux, BSD, Unix, QNX...
                                     return "soffice";
                                 }
                text: ""
                Layout.fillWidth: true
                onEditingFinished: {
                    pathSettingsStorage.sync();
                }
            }
        }
    }

    Labs.FileDialog {
        id: pathsDialog
        title: qsTr("Browse for %1", "Browse for PROGRAM").arg(pathSettings.currentlyBrowsing)
        nameFilters: [
            (Qt.platform.os === "windows"
             ? qsTr("Executable (%1)", "Format name (FORMAT_EXTENSION)").arg("EXE") + "(" + "*.exe *.EXE" + ")"
             : (Qt.platform.os === "osx"
                ? qsTr("Executable (%1)", "Format name (FORMAT_EXTENSION)").arg("APP") + "(" + "*.app *.APP" + ")"
                : qsTr("Executable (%1)", "Format name (FORMAT_EXTENSION)").arg("BIN") + "(" + "*.bin *.BIN *" + ")"
                )),
            qsTr("All Formats", "All file formats") + "(*.*)"
        ]
        fileMode: Labs.FileDialog.OpenFile
        onAccepted: {
            if (pathSettings.currentlyBrowsing === "soffice")
                // Convert URL to scheme and remove scheme part (file://)
                pathSettings.sofficePath = pathsDialog.file.toString().slice(Qt.platform.os==="windows" ? 8 : 7);
            pathSettingsStorage.sync();
        }
    }
}
