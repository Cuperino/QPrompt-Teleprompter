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

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Controls.Material
import org.kde.kirigami as Kirigami
import org.kde.kcolorchooser as KColorChooser

// Stands in for QtQuick.Dialogs' ColorDialog with KColorChooser's chooser. Desktops
// show it in a window of its own; WASM, iOS and Android, which present a single
// window, show it inside a Kirigami dialog over the current window.
// Either way the chooser follows the operating system's theme, not QPrompt's.
// selectedColor follows the chooser while it is open, so that changes preview live,
// and returns to the color it had when opened if the choice is rejected.
Item {
    id: root

    property color selectedColor: "white"
    property string title: qsTr("Select Color")
    readonly property alias opened: internal.opened

    signal accepted
    signal rejected

    function open(): void {
        if (internal.opened)
            return;
        internal.initialColor = selectedColor;
        internal.opened = true;
        if (internal.inWindow) {
            // A new dialog each time, as Kirigami.Dialog sizes itself to its
            // content as it is on creation.
            internal.dialog = dialogComponent.createObject(root, { parent: root.QQC2.Overlay.overlay });
            internal.dialog.open();
        }
    }
    function accept(): void {
        if (!internal.opened)
            return;
        internal.opened = false;
        internal.dialog?.close();
        accepted();
    }
    function reject(): void {
        if (!internal.opened)
            return;
        internal.opened = false;
        internal.dialog?.close();
        selectedColor = internal.initialColor;
        rejected();
    }

    // Hidden, so that it takes no space when declared inside a layout.
    visible: false

    QtObject {
        id: internal

        readonly property bool inWindow: ["wasm", "ios", "android"].includes(Qt.platform.os)
        property bool opened: false
        property color initialColor
        property Kirigami.Dialog dialog: null
    }

    // The operating system's colors, which QPrompt's Material theme replaces.
    SystemPalette {
        id: systemPalette
    }
    SystemPalette {
        id: disabledSystemPalette

        colorGroup: SystemPalette.Disabled
    }

    Component {
        id: chooserComponent

        // The chooser's controls use the platform's style (see src/CMakeLists.txt),
        // which takes its palette from the system. What comes from QPrompt's
        // theme instead are Material's fonts and the Kirigami theme.
        KColorChooser.ColorChooserPage {
            id: chooser

            // Setting the initial color passes through intermediate colors,
            // which must not reach selectedColor.
            property bool live: false

            initialColor: internal.initialColor
            showHelpButton: false
            font.family: Qt.application.font.family
            font.pointSize: Qt.application.font.pointSize
            font.weight: Qt.application.font.weight
            Material.theme: Material.System
            Kirigami.Theme.inherit: false
            Kirigami.Theme.textColor: systemPalette.windowText
            Kirigami.Theme.disabledTextColor: disabledSystemPalette.windowText
            Kirigami.Theme.backgroundColor: systemPalette.window
            Kirigami.Theme.alternateBackgroundColor: systemPalette.alternateBase
            Kirigami.Theme.highlightColor: systemPalette.highlight
            Kirigami.Theme.highlightedTextColor: systemPalette.highlightedText
            Kirigami.Theme.focusColor: systemPalette.highlight
            Kirigami.Theme.hoverColor: systemPalette.highlight
            Kirigami.Theme.linkColor: systemPalette.link
            Kirigami.Theme.visitedLinkColor: systemPalette.linkVisited
            Component.onCompleted: Qt.callLater(() => chooser.live = true)
            onColorChanged: {
                if (chooser.live)
                    root.selectedColor = chooser.color;
            }
            onAccepted: {
                root.selectedColor = chooser.color;
                root.accept();
            }
            onRejected: root.reject()
        }
    }

    Loader {
        active: !internal.inWindow
        sourceComponent: Window {
            transientParent: root.Window.window
            flags: Qt.Dialog
            modality: Qt.ApplicationModal
            title: root.title
            color: systemPalette.window
            width: minimumWidth
            height: minimumHeight
            minimumWidth: chooserLoader.implicitWidth
            maximumWidth: chooserLoader.implicitWidth
            minimumHeight: chooserLoader.implicitHeight
            maximumHeight: chooserLoader.implicitHeight
            visible: internal.opened && chooserLoader.status === Loader.Ready
            onClosing: root.reject()

            Loader {
                id: chooserLoader

                anchors.fill: parent
                // A new chooser each time, which starts out at selectedColor.
                active: internal.opened
                sourceComponent: chooserComponent
            }
        }
    }

    Component {
        id: dialogComponent

        Kirigami.Dialog {
            id: dialog

            title: root.title
            // As for the chooser, so that the frame around it matches.
            Material.theme: Material.System
            Kirigami.Theme.inherit: false
            Kirigami.Theme.textColor: systemPalette.windowText
            Kirigami.Theme.disabledTextColor: disabledSystemPalette.windowText
            Kirigami.Theme.backgroundColor: systemPalette.window
            Kirigami.Theme.highlightColor: systemPalette.highlight
            Kirigami.Theme.highlightedTextColor: systemPalette.highlightedText
            background: Kirigami.ShadowedRectangle {
                color: systemPalette.window
                radius: Kirigami.Units.cornerRadius
                shadow.size: radius * 2
                shadow.color: Qt.rgba(0, 0, 0, 0.3)
                shadow.yOffset: 1
                border.width: 1
                border.color: Kirigami.ColorUtils.linearInterpolation(systemPalette.window, systemPalette.windowText, Kirigami.Theme.frameContrast)
            }
            onClosed: {
                root.reject();
                if (internal.dialog === dialog)
                    internal.dialog = null;
                dialog.destroy();
            }

            Loader {
                sourceComponent: chooserComponent
            }
        }
    }
}
