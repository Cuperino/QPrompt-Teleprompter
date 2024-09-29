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
        text: i18n("Language settings")
        level: 1
    }
    z: 1
    width: root.minimumWidth - 10
    ColumnLayout {
        RowLayout {
            Label {
                text: i18nc("Selector to choose user interface language", "UI Language")
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
                        "text": i18nc("Language", "Use system language"),
                        "value": ""
                    },
                    {
                        "text": i18nc("Language", "English"),
                        "value": "en_US"
                    },
                    // {
                    //     "text": i18nc("Language", "Arabic"),
                    //     "value": "ar_AE"
                    // },
                    {
                        "text": i18nc("Language", "Chinese (Simplified)"),
                        "value": "zh_CN"
                    },
                    {
                        "text": i18nc("Language", "Czech"),
                        "value": "cs_CZ"
                    },
                    // {
                    //     "text": i18nc("Language", "Dutch"),
                    //     "value": "nl_NL"
                    // },
                    // {
                    //     "text": i18nc("Language", "Finnish"),
                    //     "value": "fi_FI"
                    // },
                    {
                        "text": i18nc("Language", "French"),
                        "value": "fr_FR"
                    },
                    {
                        "text": i18nc("Language", "German"),
                        "value": "de_DE"
                    },
                    // {
                    //     "text": i18nc("Language", "Hebrew"),
                    //     "value": "he-IL"
                    // },
                    // {
                    //     "text": i18nc("Language", "Italian"),
                    //     "value": "it_IT"
                    // },
                    {
                        "text": i18nc("Language", "Japanese"),
                        "value": "ja_JP"
                    },
                    // {
                    //     "text": i18nc("Language", "Korean"),
                    //     "value": "ko_KO"
                    // },
                    // {
                    //     "text": i18nc("Language", "Occitan"),
                    //     "value": "oc_FR"
                    // },
                    // {
                    //     "text": i18nc("Language", "Polish"),
                    //     "value": "pl_PL"
                    // },
                    {
                        "text": i18nc("Language", "Portuguese (Brazil)"),
                        "value": "pt_BR"
                    },
                    {
                        "text": i18nc("Language", "Portuguese (Portugal)"),
                        "value": "pt_PO"
                    },
                    // {
                    //     "text": i18nc("Language", "Russian"),
                    //     "value": "ru_RU"
                    // },
                    {
                        "text": i18nc("Language", "Spanish"),
                        "value": "es_ES"
                    },
                    {
                        "text": i18nc("Language", "Turkish"),
                        "value": "tr_TR"
                    },
                    {
                        "text": i18nc("Language", "Ukranian"),
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
            text: i18n("Is your language not here or it's incomplete?\nHelp us translate QPrompt, visit:")
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
