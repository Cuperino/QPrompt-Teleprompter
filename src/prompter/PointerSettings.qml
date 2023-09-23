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

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.2
import QtQuick.Controls.Material 2.12
import QtCore
import Qt.labs.platform 1.1 as Labs

import com.cuperino.qprompt.qmlutil 1.0

ColumnLayout {
    id: pointerSettings

    // State order must match listView contents order
    enum States {
        Arrow,
        Text,
        Image,
        QML
    }

    property alias pointerKind: listView.currentIndex
    property alias colorsEditing: editingColor.value
    property alias colorsReady: readyColor.value
    property alias colorsPrompting: promptingColor.value
    property alias sameAsLeftPointer: sameAsLeftPointerCheck.checked
    property alias debug: debugPointers.checked
    property alias arrowLineWidth: lineWidth.value
    //property alias arrowFillExtent: xFillExtent.value
    //property alias arrowFillOpacity: fillOpacity.value
    property alias textLeftPointer: leftPointerText.value
    property alias textRightPointer: rightPointerText.value
    property alias textFont: fontSelector.currentText
    property alias textVerticalOffset: textVerticalOffsetSlider.value
    property alias imageVerticalOffset: imageVerticalOffsetSlider.value
    property alias imageLeftPath: leftPointerImagePath.value
    property alias imageRightPath: rightPointerImagePath.value
    property alias tint: tintCheck.checked
    property alias qmlLeftPath: leftPointerQmlPath.value
    property alias qmlRightPath: rightPointerQmlPath.value

    states: [
        State {
            name: PointerSettings.States.Arrow
            PropertyChanges {
                target: sameAsLeftPointerCheck
                checked: false
                enabled: false
            }
            PropertyChanges {
                target: tintCheck
                checked: false
                enabled: false
            }

        }
    ]
    state: pointerSettings.pointerKind

    Settings {
        category: "pointers"
        property alias pointerKind: pointerSettings.pointerKind
        property alias colorsEditing: editingColor.text
        property alias colorsReady: readyColor.text
        property alias colorsPrompting: promptingColor.text
        property alias sameAsLeftPointer: pointerSettings.sameAsLeftPointer
        property alias debug: pointerSettings.debug
        property alias arrowLineWidth: pointerSettings.arrowLineWidth
        //property alias arrowFillExtent: pointerSettings.arrowFillExtent
        //property alias arrowFillOpacity: pointerSettings.arrowFillOpacity
        property alias textLeftPointer: leftPointerText.text
        property alias textRightPointer: rightPointerText.text
        property alias textFont: fontSelector.currentIndex
        property alias textVerticalOffset: pointerSettings.textVerticalOffset
        property alias imageVerticalOffset: pointerSettings.imageVerticalOffset
        property alias imageLeftPath: leftPointerImagePath.text
        property alias imageRightPath: rightPointerImagePath.text
        property alias tint: pointerSettings.tint
        property alias qmlLeftPath: leftPointerQmlPath.text
        property alias qmlRightPath: rightPointerQmlPath.text
    }
    Label {
        text: i18n("Colors for prompter states")
        font.pixelSize: 22
    }
    RowLayout {
        id: pointerColorSettings
        Label {
            text: i18n("Editing: ")
        }
        TextField {
            id: editingColor
            property color value: text ? text : placeholderText
            placeholderText: Material.theme===Material.Light ? "#4d94cf" : "#2b72ad"
            onPressed: (event) => {
                pointerColorDialog.source = this
                pointerColorDialog.open()
            }
            Layout.fillWidth: true
        }
        Label {
            text: i18n("Ready: ")
        }
        TextField {
            id: readyColor
            property color value: text ? text : placeholderText
            placeholderText: Material.theme===Material.Light ? "#4d94cf" : "#2b72ad"
            onPressed: (event) => {
                pointerColorDialog.source = this
                pointerColorDialog.open()
            }
            Layout.fillWidth: true
        }
        Label {
            text: i18n("Prompting: ")
        }
        TextField {
            id: promptingColor
            property color value: text ? text : placeholderText
            placeholderText: Material.theme===Material.Light ? "#4d94cf" : "#2b72ad"
            onPressed: (event) => {
                pointerColorDialog.source = this
                pointerColorDialog.open()
            }
            Layout.fillWidth: true
        }
    }
    Label {
        text: i18n("Pointer settings")
        // text: i18n("Pointer mirroring")
        font.pixelSize: 22
    }
    RowLayout {
        CheckBox {
            id: sameAsLeftPointerCheck
            text: i18nc("Uses a mirrored copy of the first pointer as the second pointer", "Reuse left pointer")
        }
        CheckBox {
            id: tintCheck
            text: i18n("Tint")
        }
        CheckBox {
            id: debugPointers
            text: i18n("Guides")
        }
    }
    Rectangle {
        color: "#292929"
        height: 1
        Layout.fillWidth: true
    }
    ListView {
        id: listView
        clip: true
        model: pointerSettingsTabModel
        currentIndex: PointerSettings.States.Arrow
        orientation: ListView.Horizontal
        highlightRangeMode: ListView.StrictlyEnforceRange
        snapMode: ListView.SnapOneItem;
        highlightMoveVelocity: 2000
        maximumFlickVelocity: 20000
        height: 180
        cacheBuffer: 1
        keyNavigationEnabled: false
        Layout.fillWidth: true
    }
    Rectangle {
        color: "#292929"
        height: 1
        Layout.fillWidth: true
    }
    TabBar {
        id: pointerSettingsTabs
        currentIndex: pointerSettings.pointerKind
        TabButton {
            text: i18n("Arrow")
            onClicked: listView.positionViewAtIndex(parseInt(PointerSettings.States.Arrow), ListView.Beginning);
        }
        TabButton {
            text: i18n("Text")
            onClicked: listView.positionViewAtIndex(parseInt(PointerSettings.States.Text), ListView.Beginning);
        }
        TabButton {
            text: i18n("Image")
            onClicked: listView.positionViewAtIndex(parseInt(PointerSettings.States.Image), ListView.Beginning);
        }
        TabButton {
            text: i18n("QML")
            onClicked: listView.positionViewAtIndex(parseInt(PointerSettings.States.QML), ListView.Beginning);
        }
        Layout.fillWidth: true
    }

    ObjectModel {
        id: pointerSettingsTabModel
        ColumnLayout {
            id: arrowTab
            width: listView.width
            height: listView.height
            RowLayout {
                id: lineWidth
                property int value: 15 // the user will see value + 1
                Label {
                    text: i18n("Line width <pre>%1</pre>", ((parent.value+1)/100).toFixed(2).slice(2))
                }
                Slider {
                    value: parent.value
                    from: 0 // 1
                    to: 98 // 99
                    stepSize: 1
                    focusPolicy: Qt.TabFocus
                    onMoved: {
                        parent.value = value
                    }
                    Layout.fillWidth: true
                }
            }
            //RowLayout {
            //    id: xFillExtent
            //    property real value: 0.5
            //    Label {
            //        text: i18n("Fill extent <pre>%1</pre>", (parent.value/10).toFixed(3).slice(2))
            //    }
            //    Slider {
            //        value: 1
            //        from: 0
            //        to: 1
            //        stepSize: 0.01
            //        focusPolicy: Qt.TabFocus
            //        onMoved: {
            //            parent.value = value
            //        }
            //        Layout.fillWidth: true
            //    }
            //}
            //RowLayout {
            //    id: fillOpacity
            //    property real value: 0
            //    Label {
            //        text: i18n("Fill opacity <pre>%1</pre>", (parent.value/10).toFixed(3).slice(2))
            //    }
            //    Slider {
            //        value: 0
            //        from: 0
            //        to: 1
            //        stepSize: 0.01
            //        focusPolicy: Qt.TabFocus
            //        onMoved: {
            //            parent.value = value
            //        }
            //        Layout.fillWidth: true
            //    }
            //}
            Item {
                Layout.fillHeight: true
            }
        }
        ColumnLayout {
            id: textTab
            width: listView.width
            height: listView.height
            RowLayout {
                Label {
                    text: i18n("Left Pointer: ")
                }
                TextField {
                    id: leftPointerText
                    property string value: text ? text : placeholderText
                    text: ""
                    // Skin tone chosen for its lower contrast against both text and background
                    placeholderText: Qt.platform.os==="osx" ? ">" : "\u{1F449}\u{1F3FC}"
                    font.family: pointerSettings.textFont
                    Layout.fillWidth: true
                }
                Label {
                    text: i18n("Right Pointer: ")
                    enabled: !pointerSettings.sameAsLeftPointer
                }
                TextField {
                    id: rightPointerText
                    property string value: text ? text : placeholderText
                    visible: !pointerSettings.sameAsLeftPointer
                    enabled: true
                    text: ""
                    // Skin tone chosen for its lower contrast against both text and background
                    placeholderText: Qt.platform.os==="osx" ? "<" : "\u{1F448}\u{1F3FC}"
                    font.family: pointerSettings.textFont
                    Layout.fillWidth: true
                }
                TextField {
                    id: invertedPreviewField
                    visible: pointerSettings.sameAsLeftPointer
                    enabled: false
                    text: leftPointerText.text
                    horizontalAlignment: Qt.AlignRight
                    placeholderText: leftPointerText.placeholderText
                    font.family: pointerSettings.textFont
                    transform: Scale {
                        xScale: -1
                        origin.x: invertedPreviewField.width / 2
                    }
                    Layout.fillWidth: true
                }
            }
            RowLayout {
                Label {
                    text: i18n("Font: ")
                }
                ComboBox {
                    id: fontSelector
                    model: qmlutil.fontList()
                    font.family: pointerSettings.textFont
                    editable: true
                    popup: Popup {
                        width: parent.width
                        implicitHeight: contentItem.implicitHeight
                        y: parent.height - 1
                        z: 103
                        padding: 1
                        contentItem: ListView {
                            clip: true
                            implicitHeight: contentHeight
                            model: fontSelector.popup.visible ? fontSelector.delegateModel : null
                            currentIndex: fontSelector.highlightedIndex
                            ScrollIndicator.vertical: ScrollIndicator {}
                        }
                    }
                    Component.onCompleted: {
                        if (!fontSelector.currentIndex)
                            currentIndex = indexOfValue("DejaVu Sans");
                    }
                    Layout.fillWidth: true
                    Material.theme: Material.Dark
                }
            }
            RowLayout {
                id: textVerticalOffsetSlider
                property real value: -0.05
                Label {
                    text: i18nc("Vertical offset (line height) 1.00", "Vertical offset <pre>%1</pre>", (parent.value < 0 ? "-" : "+") + (parent.value/10).toFixed(3).slice((parent.value < 0 ? 3 : 2)))
                }
                Slider {
                    value: parent.value
                    from: -1
                    to: 1
                    stepSize: 0.01
                    focusPolicy: Qt.TabFocus
                    onMoved: {
                        parent.value = value
                    }
                    Layout.fillWidth: true
                }
            }
            Item {
                Layout.fillHeight: true
            }
            Layout.fillWidth: true
        }
        ColumnLayout {
            id: imageTab
            width: listView.width
            height: listView.height
            RowLayout {
                Label {
                    text: i18n("Left Pointer: ")
                }
                TextField {
                    id: leftPointerImagePath
                    property url value: text ? text : placeholderText
                    text: ""
                    placeholderText: "qrc:/images/left_hand.png"
                    Layout.fillWidth: true
                }
                Button {
                    text: i18n("Browse")
                    onPressed: {
                        pointerImageFileDialog.source = leftPointerImagePath
                        pointerImageFileDialog.open()
                    }
                    Material.theme: Material.Dark
                }
            }
            RowLayout {
                enabled: !pointerSettings.sameAsLeftPointer
                Label {
                    text: i18n("Right Pointer: ")
                }
                TextField {
                    id: rightPointerImagePath
                    property url value: text ? text : placeholderText
                    visible: !pointerSettings.sameAsLeftPointer
                    enabled: true
                    text: ""
                    placeholderText: "qrc:/images/right_hand.png"
                    Layout.fillWidth: true
                }
                TextField {
                    visible: pointerSettings.sameAsLeftPointer
                    enabled: false
                    text: leftPointerImagePath.text
                    placeholderText: leftPointerImagePath.placeholderText
                    Layout.fillWidth: true
                }
                Button {
                    text: i18n("Browse")
                    onPressed: {
                        pointerImageFileDialog.source = rightPointerImagePath
                        pointerImageFileDialog.open()
                    }
                    Material.theme: Material.Dark
                }
            }
            RowLayout {
                id: imageVerticalOffsetSlider
                property real value: 0
                Label {
                    text: i18nc("Vertical offset (line height) 1.00", "Vertical offset <pre>%1</pre>", (parent.value < 0 ? "-" : "+") + (parent.value/10).toFixed(3).slice((parent.value < 0 ? 3 : 2)))
                }
                Slider {
                    value: parent.value
                    from: -1
                    to: 1
                    stepSize: 0.01
                    focusPolicy: Qt.TabFocus
                    onMoved: {
                        parent.value = value
                    }
                    Layout.fillWidth: true
                }
            }
            Item {
                Layout.fillHeight: true
            }
        }
        ColumnLayout {
            id: customTab
            width: listView.width
            height: listView.height
            RowLayout {
                Label {
                    text: i18n("Use QML scripts to draw pointers")
                }
            }
            RowLayout {
                Label {
                    text: i18n("Left Pointer: ")
                }
                TextField {
                    id: leftPointerQmlPath
                    property url value: text ? text : placeholderText
                    text: ""
                    placeholderText: "qrc:/pointers/pointer_1.qml"
                    Layout.fillWidth: true
                }
                Button {
                    text: i18n("Browse")
                    onPressed: {
                        pointerQmlFileDialog.source = leftPointerQmlPath
                        pointerQmlFileDialog.open()
                    }
                    Material.theme: Material.Dark
                }
            }
            RowLayout {
                enabled: !pointerSettings.sameAsLeftPointer
                Label {
                    text: i18n("Right Pointer: ")
                }
                TextField {
                    id: rightPointerQmlPath
                    property url value: text ? text : placeholderText
                    visible: !pointerSettings.sameAsLeftPointer
                    enabled: true
                    text: ""
                    placeholderText: "qrc:/pointers/pointer_2.qml"
                    Layout.fillWidth: true
                }
                TextField {
                    visible: pointerSettings.sameAsLeftPointer
                    enabled: false
                    text: leftPointerQmlPath.text
                    placeholderText: leftPointerQmlPath.placeholderText
                    Layout.fillWidth: true
                }
                Button {
                    text: i18n("Browse")
                    onPressed: {
                        pointerQmlFileDialog.source = rightPointerQmlPath
                        pointerQmlFileDialog.open()
                    }
                    Material.theme: Material.Dark
                }
            }
            Item {
                Layout.fillHeight: true
            }
        }
    }
    Labs.ColorDialog {
        id: pointerColorDialog
        property var source
        currentColor: appTheme.__backgroundColor
        onAccepted: {
            source.text = color
        }
    }
    Labs.FileDialog {
        id: pointerImageFileDialog
        property var source
        nameFilters: [
          i18n("JPEG image") + "(*.jpg *.jpeg *.JPG *.JPEG)",
          i18n("PNG image") + "(*.png *.PNG)",
          i18n("GIF animation") + "(*.gif *.GIF)",
          i18n("WEBP image") + "(*.webp *.WEBP)"
        ]
        fileMode: Labs.FileDialog.OpenFile
        folder: StandardPaths.writableLocation(StandardPaths.PicturesLocation)
        onAccepted: {
            source.text = file.valueOf()
        }
    }
    Labs.FileDialog {
        id: pointerQmlFileDialog
        property var source
        nameFilters: [
          i18n("QML script") + "(*.qml *.QML)"
        ]
        fileMode: Labs.FileDialog.OpenFile
        folder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
        onAccepted: {
            source.text = file.valueOf()
        }
    }
}
