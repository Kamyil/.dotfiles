import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "."

Item {
    id: root
    implicitWidth: 340
    implicitHeight: 500
    property var notifications: []
    property bool doNotDisturb: false
    signal doNotDisturbChangedByUser(bool value)
    signal clearRequested()

    ColumnLayout {
        anchors.fill: parent
        spacing: 10
        Heading {
            title: "Notifications"
            subtitle: root.notifications.length + (root.notifications.length === 1 ? " notification" : " notifications")
        }
        SwitchRow {
            title: "Do not disturb"
            subtitle: root.doNotDisturb ? "Toasts are suppressed" : "Toasts are enabled"
            checked: root.doNotDisturb
            onToggled: value => root.doNotDisturbChangedByUser(value)
        }
        RowLayout {
            Layout.fillWidth: true
            Text { text: "RECENT"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 9; font.weight: Font.DemiBold; Layout.fillWidth: true }
            Button { visible: root.notifications.length > 0; text: "Clear"; onClicked: root.clearRequested() }
        }
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ColumnLayout {
                width: parent.width
                spacing: 6
                Repeater {
                    model: root.notifications
                    delegate: Rectangle {
                        id: card
                        required property var modelData
                        Layout.fillWidth: true
                        implicitHeight: content.implicitHeight + 20
                        radius: 9
                        color: Theme.elevated
                        RowLayout {
                            id: content
                            anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
                            anchors.margins: 10; spacing: 10
                            Image {
                                visible: source.toString().length > 0
                                source: card.modelData.image || card.modelData.appIcon
                                Layout.preferredWidth: visible ? 34 : 0
                                Layout.preferredHeight: visible ? 34 : 0
                                fillMode: Image.PreserveAspectFit
                            }
                            ColumnLayout {
                                Layout.fillWidth: true; spacing: 3
                                Text { text: card.modelData.appName || "Notification"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 8; elide: Text.ElideRight; Layout.fillWidth: true }
                                Text { text: card.modelData.summary || "Notification"; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: 11; font.weight: Font.DemiBold; wrapMode: Text.Wrap; Layout.fillWidth: true }
                                Text { visible: text.length > 0; text: card.modelData.body || ""; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 9; wrapMode: Text.Wrap; textFormat: Text.PlainText; Layout.fillWidth: true }
                                RowLayout {
                                    visible: card.modelData.actions && card.modelData.actions.length > 0
                                    Repeater {
                                        model: card.modelData.actions
                                        delegate: Button {
                                            required property var modelData
                                            text: modelData.text || modelData.identifier || "Open"
                                            onClicked: modelData.invoke()
                                        }
                                    }
                                }
                            }
                            Button { text: "×"; onClicked: card.modelData.tracked = false }
                        }
                    }
                }
                Text {
                    visible: root.notifications.length === 0
                    text: "You're all caught up."
                    color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 10
                    Layout.alignment: Qt.AlignHCenter; Layout.topMargin: 30
                }
            }
        }
    }
}
