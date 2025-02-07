/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2024 Javier O. Cordero Pérez
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
import QtQuick.Controls.Material 2.12
import QtCore 6.5

Kirigami.OverlaySheet {
    property alias value: languageSelector.highlightedIndex
    header: Kirigami.Heading {
        text: qsTr("Language settings")
        level: 1
    }
    z: 1
    width: root.minimumWidth - 10
    ColumnLayout {
        RowLayout {
            Label {
                text: qsTr("UI Language", "Selector to choose user interface language")
            }
            ComboBox {
                id: languageSelector
                property string language: ""
                property int initialIndex: 0
                property bool dirty: initialIndex !== languageSelector.currentIndex
                textRole: "text"
                valueRole: "value"
                popup: Popup {
                    width: parent.width
                    implicitHeight: (root.height / 2) - 20
                    y: parent.height - 1
                    z: 103
                    padding: 1
                    contentItem: ListView {
                        clip: true
                        implicitHeight: contentHeight
                        model: languageSelector.popup.visible ? languageSelector.delegateModel : null
                        currentIndex: languageSelector.model.indexOf(languageSelector.currentIndex)
                    }
                }
                model: [
                    {
                        "text": qsTr("Use system language", "Language"),
                        "value": ""
                    },
                    {
                        "text": qsTr("English", "Language"),
                        "value": "en_US"
                    },
                    // {
                    //     "text": qsTr("Arabic", "Language"),
                    //     "value": "ar_AE"
                    // },
                    {
                        "text": qsTr("Chinese (Simplified)", "Language"),
                        "value": "zh_CN"
                    },
                    {
                        "text": qsTr("Czech", "Language"),
                        "value": "cs_CZ"
                    },
                    // {
                    //     "text": qsTr("Dutch", "Language"),
                    //     "value": "nl_NL"
                    // },
                    // {
                    //     "text": qsTr("Finnish", "Language"),
                    //     "value": "fi_FI"
                    // },
                    {
                        "text": qsTr("French", "Language"),
                        "value": "fr_FR"
                    },
                    {
                        "text": qsTr("German", "Language"),
                        "value": "de_DE"
                    },
                    // {
                    //     "text": qsTr("Hebrew", "Language"),
                    //     "value": "he-IL"
                    // },
                    // {
                    //     "text": qsTr("Italian", "Language"),
                    //     "value": "it_IT"
                    // },
                    {
                        "text": qsTr("Japanese", "Language"),
                        "value": "ja_JP"
                    },
                    // {
                    //     "text": qsTr("Korean", "Language"),
                    //     "value": "ko_KO"
                    // },
                    // {
                    //     "text": qsTr("Occitan", "Language"),
                    //     "value": "oc_FR"
                    // },
                    // {
                    //     "text": qsTr("Polish", "Language"),
                    //     "value": "pl_PL"
                    // },
                    {
                        "text": qsTr("Portuguese (Brazil)", "Language"),
                        "value": "pt_BR"
                    },
                    {
                        "text": qsTr("Portuguese (Portugal)", "Language"),
                        "value": "pt_PO"
                    },
                    // {
                    //     "text": qsTr("Russian", "Language"),
                    //     "value": "ru_RU"
                    // },
                    {
                        "text": qsTr("Spanish", "Language"),
                        "value": "es_ES"
                    },
                    {
                        "text": qsTr("Turkish", "Language"),
                        "value": "tr_TR"
                    },
                    {
                        "text": qsTr("Ukranian", "Language"),
                        "value": "uk_UA"
                    },
                ]
                onActivated: (index) => {
                    // console.log(languageSelector.currentIndex)
                    // console.log(languageSelector.model[languageSelector.currentIndex].value)
                    languageSelector.language = languageSelector.model[index].value
                    // languageSelector.dirty = true;
                }
                Layout.fillWidth: true
                Material.theme: Material.Dark
                Component.onCompleted: {
                    // console.log(languageSelector.model.length)
                    for (let i=0; i<languageSelector.model.length; i++)
                        if (languageSelector.model[i].value === languageSelector.language) {
                            languageSelector.initialIndex = i;
                            languageSelector.currentIndex = i;
                            break;
                        }
                }
                Settings {
                    category: "ui"
                    property alias language: languageSelector.language
                }
            }
        }
        Label {
            text: qsTr("Is your language not here or it's incomplete?\nHelp us translate QPrompt, visit:")
        }
        Button {
            text: "http://l10n.qprompt.app"
            onClicked: {
                Qt.openUrlExternally(text)
            }
            Material.theme: Material.Dark
        }
    }
    onClosed: {
       if (languageSelector.dirty)
           restartDialog.visible = true;
   }
}
