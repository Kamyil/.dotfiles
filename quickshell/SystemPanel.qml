import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import "."

Item {
    id: root
    implicitWidth: 320
    implicitHeight: 280

    property bool canHibernate: false
    signal closeRequested()
    signal lockRequested()
    function execute(command) {
        action.command = command
        action.running = true
        closeDelay.restart()
    }

    Process {
        id: hibernateCheck
        command: ["swapon", "--show", "--noheadings"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.canHibernate = text.trim().length > 0
        }
    }

    Timer {
        id: closeDelay
        interval: 250
        onTriggered: root.closeRequested()
    }

    Process { id: action }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        Heading {
            title: "System"
            subtitle: "Secure this session or finish your work"
        }

        ActionRow {
            title: "Lock"
            subtitle: "Keep applications running and require authentication"
            icon: "󰌾"
            trailing: "Lock"
            onClicked: root.lockRequested()
        }

        ActionRow {
            visible: root.canHibernate
            title: "Hibernate"
            subtitle: "Save this session to disk and power off"
            icon: "󰒲"
            trailing: "Hibernate"
            onClicked: hibernateConfirmation.open()
        }

        Text {
            visible: !root.canHibernate
            Layout.fillWidth: true
            text: "Hibernate unavailable: no active swap was detected."
            color: Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: 9
            wrapMode: Text.WordWrap
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1
            color: Theme.border
        }

        ActionRow {
            title: "Shut down"
            subtitle: "Close the session and power off this computer"
            icon: "󰐥"
            trailing: "Shut down"
            onClicked: shutdownConfirmation.open()
        }

        Item { Layout.fillHeight: true }
    }

    Dialog {
        id: shutdownConfirmation
        anchors.centerIn: parent
        modal: true
        title: "Shut down this computer?"
        standardButtons: Dialog.Yes | Dialog.Cancel
        onAccepted: root.execute(["systemctl", "poweroff"])

        background: Rectangle {
            color: Theme.elevated
            border.color: Theme.border
            radius: 10
        }

        Text {
            width: 250
            text: "Unsaved work will be lost."
            color: Theme.foreground
            font.family: Theme.fontFamily
            font.pixelSize: 11
            wrapMode: Text.WordWrap
        }
    }

    Dialog {
        id: hibernateConfirmation
        anchors.centerIn: parent
        modal: true
        title: "Hibernate this computer?"
        standardButtons: Dialog.Yes | Dialog.Cancel
        onAccepted: root.execute(["systemctl", "hibernate"])

        background: Rectangle {
            color: Theme.elevated
            border.color: Theme.border
            radius: 10
        }

        Text {
            width: 250
            text: "The current session will be saved to disk."
            color: Theme.foreground
            font.family: Theme.fontFamily
            font.pixelSize: 11
            wrapMode: Text.WordWrap
        }
    }
}
