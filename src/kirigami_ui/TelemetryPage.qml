/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2021-2022 Javier O. Cordero Pérez
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
import Qt.labs.settings 1.0

Kirigami.ScrollablePage {

    title: qsTr("Telemetry Settings")
    //globalToolBarStyle: Kirigami.ApplicationHeaderStyle.ToolBar

    background: Rectangle {
        color: Kirigami.Theme.alternateBackgroundColor
    }

    Settings {
        category: "telemetry"
        property alias platformTelemetry: platformTelemetryToggle.checked
        property alias runsTelemetry: runsTelemetryToggle.checked
        property alias featureTelemetry: featureTelemetryToggle.checked
        property alias operationsTelemetry: operationsTelemetryToggle.checked
    }

    GridLayout {
        id: telemetry_settings
        width: parent.implicitWidth
        columns: 2
        Label {
            text: ""
        }
        Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            text: qsTr("The following page is a placeholder. Telemetry has not yet been implemented.")
        }
        Label {
            text: ""
        }
        TextArea {
            implicitWidth: parent.width-80
            //height: 300
            background: Item{}
            readOnly: true
            wrapMode: TextEdit.Wrap
            text: qsTr("Please help improve QPrompt by sharing information on how you use it. Contributing this information is optional and entirely anonymous. The project nor I will never collect your personal data, files you use, contents you work with, or information that could help identify you.\n- Cuperino (QPrompt's Author)")
        }
        Label {
            text: qsTr("Telemetry")
        }
        Button {
            text: root.__telemetry ? qsTr("Enabled") : qsTr("Disabled")
            checkable: true
            checked: root.__telemetry
            flat: true
            onClicked: root.__telemetry = !root.__telemetry
            Layout.fillWidth: true
        }
        Button {
            id: platformTelemetryToggle
            text: checked ? qsTr("On") : qsTr("Off")
            enabled: root.__telemetry
            checkable: true
            checked: root.__telemetry
            flat: true
            Layout.fillWidth: true
            //onClicked: root.__telemetry = !root.__telemetry
        }
            //text: qsTr("Information collected once per session")
        TextArea {
            implicitWidth: parent.width-80
            background: Item{}
            readOnly: true
            wrapMode: TextEdit.Wrap
            text: qsTr("Basic program and system information")+"\n"+
            " + " + qsTr("Application version")+"\n"+
            " + " + qsTr("Platform information")+"\n"+
            " + " + qsTr("Qt version information")+"\n"+
            " + " + qsTr("Locale information (timezone and keyboard layout)")
        }
        Button {
            id: runsTelemetryToggle
            text: checked ? qsTr("On") : qsTr("Off")
            enabled: root.__telemetry
            checkable: true
            checked: root.__telemetry
            flat: true
            //onClicked: root.__telemetry = !root.__telemetry
            Layout.fillWidth: true
        }
        TextArea {
            implicitWidth: parent.width-80
            background: Item{}
            readOnly: true
            wrapMode: TextEdit.Wrap
            text: qsTr("Program run statistics: Help us study user retention")+"\n"+
            " + " + qsTr("Randomly generated install ID")+"\n"+
            " + " + qsTr("Launch times")+"\n"+
            " + " + qsTr("Usage time")+"\n"+
            " + " + qsTr("Locale information (timezone and keyboard layout)")
        }
        //text: qsTr("Information collected once per prompt")
        Button {
            id: featureTelemetryToggle
            text: checked ? qsTr("On") : qsTr("Off")
            enabled: root.__telemetry
            checkable: true
            checked: root.__telemetry
            flat: true
            //onClicked: root.__telemetry = !root.__telemetry
            Layout.fillWidth: true
        }
        TextArea {
            implicitWidth: parent.width-80
            readOnly: true
            background: Item{}
            wrapMode: TextEdit.Wrap
            text: qsTr("Feature use frequency: Help us know what features are most important")+"\n"+
            " + " + qsTr("Flip settings")+"\n"+
            " + " + qsTr("Reading region settings")+"\n"+
            " + " + qsTr("Pointer settings")+"\n"+
            " + " + qsTr("Countdown settings")+"\n"+
            " + " + qsTr("Keyboard shortcut settings")+"\n"+
            " + " + qsTr("Input control settings")+"\n"+
            " + " + qsTr("Base speed and acceleration curvature settings")+"\n"+
            " + " + qsTr("Background color and opacity settings")+"\n"+
            " + " + qsTr("Presence of a background image")
        }
        Button {
            id: operationsTelemetryToggle
            text: checked ? qsTr("On") : qsTr("Off")
            enabled: root.__telemetry
            checkable: true
            checked: root.__telemetry
            flat: true
            //onClicked: root.__telemetry = !root.__telemetry
            Layout.fillWidth: true
        }
        TextArea {
            implicitWidth: parent.width-80
            readOnly: true
            background: Item{}
            wrapMode: TextEdit.Wrap
            text: qsTr("Help us understand how users operate QPrompt")+"*\n"+
            " + " + qsTr("Random session ID")+"\n"+
            " + " + qsTr("Session number")+"\n"+
            " + " + qsTr("Session prompt number")+"\n"+
            " + " + qsTr("Window dimensions")+"\n"+
            " + " + qsTr("Prompt area dimensions")+"\n"+
            " + " + qsTr("Dimensions of lines of text being prompted")+"\n"+
            " + " + qsTr("Font settings per block of lines of text being prompted")+"\n"+
            " + " + qsTr("Languages likely present in the text being prompted")+"\n"+
            " + " + qsTr("Prompt starting line number and position")+"\n"+
            " + " + qsTr("Manual scroll start and end timestamps")+"\n"+
            " + " + qsTr("Scroll starting line number and position")+"\n"+
            " + " + qsTr("Scroll end line number and position")+"\n"+
            " + " + qsTr("Scroll duration")+"\n"+
            " + " + qsTr("Prompt duration")+"\n"+
            " + " + qsTr("Velocity changes with timestamp")+"\n"+
            " + " + qsTr("Source of changes to velocity")+"\n"+
            " + " + qsTr("Source of manual changes to scroll position")+"\n\n"
        }
        Label {
            text: ""
        }
        TextArea {
            implicitWidth: parent.width-80
            readOnly: true
            wrapMode: TextEdit.Wrap
            text: qsTr("This information is very important to me, Javier, the project author, and it could help make QPrompt's development sustainable. I've gone the extra mile not to collect any of the actual text and images that you work with, so I ask you: please leave telemetry enabled.")
            background: Item{}
        }
    }
}
