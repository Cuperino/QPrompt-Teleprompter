/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2021 Javier O. Cordero Pérez
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

import QtQuick 2.12
import org.kde.kirigami 2.11 as Kirigami
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import Qt.labs.settings 1.0

Kirigami.ScrollablePage {
    background: Rectangle {
        color: Kirigami.Theme.alternateBackgroundColor
    }

    title: "Telemetry Settings"
    //globalToolBarStyle: Kirigami.ApplicationHeaderStyle.ToolBar

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
            text: "The following page is a placeholder. Telemetry has not yet been implemented."
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
            text: i18n("Please help improve QPrompt by sharing information on how you use it. Contributing this information is optional and entirely anonymous. The project nor I will never collect your personal data, files you use, contents you work with, or information that could help identify you.\n- Cuperino (QPrompt's Author)")
        }
        Label {
            text: i18n("Telemetry")
        }
        Button {
            text: root.__telemetry ? i18n("Enabled") : i18n("Disabled")
            checkable: true
            checked: root.__telemetry
            flat: true
            Layout.fillWidth: true
            onClicked: root.__telemetry = !root.__telemetry
        }
        Button {
            id: platformTelemetryToggle
            text: checked ? i18n("On") : i18n("Off")
            enabled: root.__telemetry
            checkable: true
            checked: root.__telemetry
            flat: true
            Layout.fillWidth: true
            //onClicked: root.__telemetry = !root.__telemetry
        }
            //text: i18n("Information collected once per session")
        TextArea {
            implicitWidth: parent.width-80
            background: Item{}
            readOnly: true
            wrapMode: TextEdit.Wrap
            text: i18n("Basic program and system information")+"\n"+
            " + " + i18n("Application version")+"\n"+
            " + " + i18n("Platform information")+"\n"+
            " + " + i18n("Qt version information")+"\n"+
            " + " + i18n("Locale information (timezone and keyboard layout)")
        }
        Button {
            id: runsTelemetryToggle
            text: checked ? i18n("On") : i18n("Off")
            enabled: root.__telemetry
            checkable: true
            checked: root.__telemetry
            flat: true
            Layout.fillWidth: true
            //onClicked: root.__telemetry = !root.__telemetry
        }
        TextArea {
            implicitWidth: parent.width-80
            background: Item{}
            readOnly: true
            wrapMode: TextEdit.Wrap
            text: i18n("Program run statistics: Help us study user retention")+"\n"+
            " + " + i18n("Randomly generated install ID")+"\n"+
            " + " + i18n("Launch times")+"\n"+
            " + " + i18n("Usage time")+"\n"+
            " + " + i18n("Locale information (timezone and keyboard layout)")
        }
            //text: i18n("Information collected once per prompt")
        Button {
            id: featureTelemetryToggle
            text: checked ? i18n("On") : i18n("Off")
            enabled: root.__telemetry
            checkable: true
            checked: root.__telemetry
            flat: true
            Layout.fillWidth: true
            //onClicked: root.__telemetry = !root.__telemetry
        }
        TextArea {
            implicitWidth: parent.width-80
            background: Item{}
            readOnly: true
            wrapMode: TextEdit.Wrap
            text: i18n("Feature use frequency: Help us know what features are most important")+"\n"+
            " + " + i18n("Flip settings")+"\n"+
            " + " + i18n("Reading region settings")+"\n"+
            " + " + i18n("Pointer settings")+"\n"+
            " + " + i18n("Countdown settings")+"\n"+
            " + " + i18n("Keyboard shortcut settings")+"\n"+
            " + " + i18n("Input control settings")+"\n"+
            " + " + i18n("Base speed and acceleration curvature settings")+"\n"+
            " + " + i18n("Background color and opacity settings")+"\n"+
            " + " + i18n("Presence of a background image")
        }
        Button {
            id: operationsTelemetryToggle
            text: checked ? i18n("On") : i18n("Off")
            enabled: root.__telemetry
            checkable: true
            checked: root.__telemetry
            flat: true
            Layout.fillWidth: true
            //onClicked: root.__telemetry = !root.__telemetry
        }
        TextArea {
            implicitWidth: parent.width-80
            background: Item{}
            readOnly: true
            wrapMode: TextEdit.Wrap
            text: i18n("Help us understand how users operate QPrompt")+"*\n"+
            " + " + i18n("Random session ID")+"\n"+
            " + " + i18n("Session number")+"\n"+
            " + " + i18n("Session prompt number")+"\n"+
            " + " + i18n("Window dimensions")+"\n"+
            " + " + i18n("Prompt area dimensions")+"\n"+
            " + " + i18n("Dimensions of lines of text being prompted")+"\n"+
            " + " + i18n("Font settings per block of lines of text being prompted")+"\n"+
            " + " + i18n("Languages likely present in the text being prompted")+"\n"+
            " + " + i18n("Prompt starting line number and position")+"\n"+
            " + " + i18n("Manual scroll start and end timestamps")+"\n"+
            " + " + i18n("Scroll starting line number and position")+"\n"+
            " + " + i18n("Scroll end line number and position")+"\n"+
            " + " + i18n("Scroll duration")+"\n"+
            " + " + i18n("Prompt duration")+"\n"+
            " + " + i18n("Velocity changes with timestamp")+"\n"+
            " + " + i18n("Source of changes to velocity")+"\n"+
            " + " + i18n("Source of manual changes to scroll position")+"\n\n"
        }
        Label {
            text: ""
        }
        TextArea {
            implicitWidth: parent.width-80
            background: Item{}
            readOnly: true
            wrapMode: TextEdit.Wrap
            text: i18n("This information is very important to me, Javier, the project author, and it could help make QPrompt's development sustainable. I've gone the extra mile not to collect any of the actual text and images that you work with, so I ask you: please leave telemetry enabled.")
        }
    }
}
