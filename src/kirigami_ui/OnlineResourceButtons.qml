import QtQuick 2.12
import QtQuick.Controls 2.12

Row {
    Button {
        readonly property url uri: "https://qprompt.app"
        text: "🌐"
        flat: true
        onClicked: Qt.openUrlExternally(uri)
    }
    Button {
        readonly property url uri: "https://docs.qprompt.app"
        text: "📖"
        flat: true
        onClicked: Qt.openUrlExternally(uri)
    }
    Button {
        readonly property url uri: "https://forum.qprompt.app"
        text: "?"
        flat: true
        onClicked: Qt.openUrlExternally(uri)
    }
    Button {
        readonly property url uri: "https://feedback.qprompt.app"
        text: "🐛"
        flat: true
        onClicked: Qt.openUrlExternally(uri)
        ToolTip.text: uri
    }
    Button {
        readonly property url uri: "https://l10n.qprompt.app"
        text: "🗺"
        flat: true
        onClicked: Qt.openUrlExternally(uri)
    }
    Button {
        readonly property url uri: "https://donate.qprompt.app"
        text: "$"
        flat: true
        onClicked: Qt.openUrlExternally(uri)
    }
}
