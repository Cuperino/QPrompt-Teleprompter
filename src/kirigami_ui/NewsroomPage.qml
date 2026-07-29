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

import QtQuick 2.12
import org.kde.kirigami 2.11 as Kirigami
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import com.cuperino.qprompt 1.0

Kirigami.ScrollablePage {
    id: newsroomSettings

    // MosInputSource (AppController.mos); null only in builds without MOS.
    readonly property var mos: AppController.mos ? AppController.mos : null
    // MosInputSource.Status values, kept numeric so this page loads even
    // when the C++ type is not registered.
    readonly property int statusDisabled: 0
    readonly property int statusConnecting: 1
    readonly property int statusConnected: 2
    readonly property int statusError: 3

    title: qsTr("Newsroom (MOS)")

    background: Rectangle {
        color: Kirigami.Theme.alternateBackgroundColor
    }

    ColumnLayout {
        enabled: newsroomSettings.mos !== null
        width: parent.implicitWidth

        Kirigami.Heading {
            text: qsTr("Newsroom integration")
        }
        TextArea {
            background: Item {}
            readOnly: true
            wrapMode: TextEdit.Wrap
            text: qsTr("Connect QPrompt to a newsroom computer system (NCS) using the MOS protocol. "
                       + "The newsroom can then discover this prompter and control playback. "
                       + "Ask your newsroom administrator for the connection details.")
            Layout.fillWidth: true
        }

        Kirigami.InlineMessage {
            Layout.fillWidth: true
            visible: newsroomSettings.mos !== null && newsroomSettings.mos.enabled
            type: newsroomSettings.mos === null ? Kirigami.MessageType.Information
                  : newsroomSettings.mos.status === newsroomSettings.statusConnected ? Kirigami.MessageType.Positive
                  : newsroomSettings.mos.status === newsroomSettings.statusError ? Kirigami.MessageType.Error
                  : Kirigami.MessageType.Information
            text: {
                if (newsroomSettings.mos === null)
                    return "";
                let message;
                switch (newsroomSettings.mos.status) {
                case newsroomSettings.statusConnected:
                    message = qsTr("Connected");
                    if (newsroomSettings.mos.peerDescription.length > 0)
                        message += ": " + newsroomSettings.mos.peerDescription;
                    break;
                case newsroomSettings.statusConnecting:
                    message = qsTr("Connecting…");
                    break;
                case newsroomSettings.statusError:
                    message = qsTr("Error");
                    break;
                default:
                    message = qsTr("Disabled");
                }
                if (newsroomSettings.mos.statusMessage.length > 0)
                    message += "\n" + newsroomSettings.mos.statusMessage;
                return message;
            }
        }

        Switch {
            text: qsTr("Enable MOS newsroom integration")
            checked: newsroomSettings.mos !== null && newsroomSettings.mos.enabled
            onToggled: newsroomSettings.mos.enabled = checked
        }

        GridLayout {
            columns: 2
            Layout.fillWidth: true

            Label {
                text: qsTr("MOS ID")
            }
            TextField {
                id: mosIDField
                Layout.fillWidth: true
                text: newsroomSettings.mos !== null ? newsroomSettings.mos.mosID : ""
                placeholderText: "qprompt.station.example"
                onEditingFinished: newsroomSettings.mos.mosID = text
            }

            Label {
                text: qsTr("NCS ID")
            }
            TextField {
                id: ncsIDField
                Layout.fillWidth: true
                text: newsroomSettings.mos !== null ? newsroomSettings.mos.ncsID : ""
                placeholderText: "ncs.station.example"
                onEditingFinished: newsroomSettings.mos.ncsID = text
            }

            Label {
                text: qsTr("Transport")
            }
            ComboBox {
                id: transportBox
                Layout.fillWidth: true
                textRole: "text"
                valueRole: "value"
                model: {
                    // Values are MosInputSource.Transport.
                    const transports = [
                        { text: qsTr("MOS 4.0 WebSocket"), value: 0 },
                        { text: qsTr("MOS 4.0 WebSocket, passive mode (behind firewall)"), value: 1 }
                    ];
                    if (newsroomSettings.mos !== null && newsroomSettings.mos.tcp28Available)
                        transports.push({ text: qsTr("Legacy MOS 2.8 TCP"), value: 2 });
                    return transports;
                }
                currentIndex: newsroomSettings.mos !== null ? indexOfValue(newsroomSettings.mos.transport) : 0
                onActivated: newsroomSettings.mos.transport = currentValue
            }

            Label {
                text: qsTr("Server")
            }
            TextField {
                id: urlField
                Layout.fillWidth: true
                text: newsroomSettings.mos !== null ? newsroomSettings.mos.endpointUrl : ""
                placeholderText: transportBox.currentValue === 2
                                 ? "tcp://ncs.station.example:10540"
                                 : "ws://ncs.station.example:10540/mos"
                onEditingFinished: newsroomSettings.mos.endpointUrl = text
            }

            Label {
                text: qsTr("Username")
                visible: transportBox.currentValue !== 2 && Qt.platform.os !== "wasm"
            }
            TextField {
                id: usernameField
                Layout.fillWidth: true
                // Browsers cannot set WebSocket request headers, so HTTP
                // Basic authentication is unavailable in the web version.
                visible: transportBox.currentValue !== 2 && Qt.platform.os !== "wasm"
                text: newsroomSettings.mos !== null ? newsroomSettings.mos.username : ""
                placeholderText: qsTr("Optional")
                onEditingFinished: newsroomSettings.mos.username = text
            }

            Label {
                text: qsTr("Password")
                visible: usernameField.visible
            }
            TextField {
                id: passwordField
                Layout.fillWidth: true
                visible: usernameField.visible
                echoMode: TextInput.Password
                text: newsroomSettings.mos !== null ? newsroomSettings.mos.password : ""
                onEditingFinished: newsroomSettings.mos.password = text
            }

            Label {
                text: qsTr("Text encoding")
            }
            ComboBox {
                id: encodingBox
                Layout.fillWidth: true
                textRole: "text"
                valueRole: "value"
                model: [
                    { text: qsTr("UCS-2 (MOS default)"), value: false },
                    { text: "UTF-8", value: true }
                ]
                currentIndex: newsroomSettings.mos !== null && newsroomSettings.mos.utf8Wire ? 1 : 0
                onActivated: newsroomSettings.mos.utf8Wire = currentValue
            }
        }

        Button {
            text: qsTr("Apply and reconnect")
            enabled: newsroomSettings.mos !== null && newsroomSettings.mos.enabled
            onClicked: {
                // Commit fields that still hold focus before reconnecting.
                newsroomSettings.mos.mosID = mosIDField.text;
                newsroomSettings.mos.ncsID = ncsIDField.text;
                newsroomSettings.mos.endpointUrl = urlField.text;
                if (usernameField.visible) {
                    newsroomSettings.mos.username = usernameField.text;
                    newsroomSettings.mos.password = passwordField.text;
                }
                newsroomSettings.mos.applyAndReconnect();
            }
        }

        TextArea {
            background: Item {}
            readOnly: true
            wrapMode: TextEdit.Wrap
            visible: Qt.platform.os === "wasm"
            text: qsTr("Note: when QPrompt runs from a secure (https) page, the browser requires "
                       + "a secure WebSocket address (wss://). Passive mode is recommended for "
                       + "browser use.")
            Layout.fillWidth: true
        }
    }
}
