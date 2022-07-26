import QtQuick 2.12
import org.kde.kirigami 2.11 as Kirigami
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Kirigami.OverlaySheet {
    id: wheelSettings

    header: Kirigami.Heading {
        text: i18n("Wheel and touchpad scroll settings")
        level: 1
    }

    ColumnLayout {
        RowLayout {
            Label {
                text: i18nc("Label at wheel settings overlay", "Use scroll as velocity dial")
            }
            Button {
                id: useScrollAsDialButton
                text: checked ? i18n("On") : i18n("Off")
                checkable: true
                checked: root.__scrollAsDial
                flat: true
                onClicked: root.__scrollAsDial = !root.__scrollAsDial
                Layout.fillWidth: true
                Layout.leftMargin: Kirigami.Units.smallSpacing
                Layout.rightMargin: Kirigami.Units.smallSpacing
            }
        }
        GridLayout {
            width: parent.width
            columns: 2
            ColumnLayout {
                Label {
                    text: i18n("Enable throttling")
                }
                Button {
                    id: enableThrottleButton
                    text: checked ? i18n("On") : i18n("Off")
                    checkable: true
                    checked: root.__throttleWheel
                    flat: true
                    onClicked: root.__throttleWheel = !root.__throttleWheel
                    Layout.fillWidth: true
                    Layout.leftMargin: Kirigami.Units.smallSpacing
                    Layout.rightMargin: Kirigami.Units.smallSpacing
                }
            }
            ColumnLayout {
                enabled: root.__throttleWheel
                Label {
                    text: i18n("Throttle factor");
                }
                SpinBox {
                    value: root.__wheelThrottleFactor
                    from: 1
                    onValueModified: {
                        focus: true
                        root.__wheelThrottleFactor = value
                    }
                    Layout.fillWidth: true
                    Layout.leftMargin: Kirigami.Units.smallSpacing
                    Layout.rightMargin: Kirigami.Units.smallSpacing
                }
            }
        }
        RowLayout {
            Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: i18n("Enable throttling for use with touchpads, disable for precise scolling.")
                color: root.palette.midlight
                Layout.leftMargin: Kirigami.Units.smallSpacing
                Layout.rightMargin: Kirigami.Units.smallSpacing
            }
        }
    }
}
