import QtQuick 2.1
import org.kde.kirigami 2.4 as Kirigami
import QtQuick.Controls 2.0 as Controls

Kirigami.ApplicationWindow {
    id: root

    title: i18n("QThePrompter")

    globalDrawer: Kirigami.GlobalDrawer {
        title: i18n("QThePrompter")
        titleIcon: "applications-graphics"
        actions: [
            Kirigami.Action {
                text: i18n("View")
                iconName: "view-list-icons"
                Kirigami.Action {
                    text: i18n("View Action 1")
                    onTriggered: showPassiveNotification(i18n("View Action 1 clicked"))
                }
                Kirigami.Action {
                    text: i18n("View Action 2")
                    onTriggered: showPassiveNotification(i18n("View Action 2 clicked"))
                }
            },
            Kirigami.Action {
                text: i18n("Action 1")
                onTriggered: showPassiveNotification(i18n("Action 1 clicked"))
            },
            Kirigami.Action {
                text: i18n("Action 2")
                onTriggered: showPassiveNotification(i18n("Action 2 clicked"))
            }
        ]
    }

    contextDrawer: Kirigami.ContextDrawer {
        id: contextDrawer
    }

    pageStack.initialPage: mainPageComponent

    Component {
        id: mainPageComponent

        Kirigami.Page {
            title: i18n("QThePrompter")

            actions {
                main: Kirigami.Action {
                    iconName: "go-home"
                    onTriggered: showPassiveNotification(i18n("Main action triggered"))
                }
                left: Kirigami.Action {
                    iconName: "go-previous"
                    onTriggered: showPassiveNotification(i18n("Left action triggered"))
                }
                right: Kirigami.Action {
                    iconName: "go-next"
                    onTriggered: showPassiveNotification(i18n("Right action triggered"))
                }
                contextualActions: [
                    Kirigami.Action {
                        text: i18n("Contextual Action 1")
                        iconName: "bookmarks"
                        onTriggered: showPassiveNotification(i18n("Contextual action 1 clicked"))
                    },
                    Kirigami.Action {
                        text: i18n("Contextual Action 2")
                        iconName: "folder"
                        enabled: false
                    }
                ]
            }
        }
    }
}
