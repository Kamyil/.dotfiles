import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "."

Item {
    id: root
    implicitWidth: 320
    implicitHeight: 250

    signal closeRequested()

    function launch(command) {
        recorderProcess.command = command
        recorderProcess.running = true
        root.closeRequested()
    }

    Process { id: recorderProcess }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        Heading {
            title: "Screen capture"
            subtitle: "Take a screenshot or choose a video recorder"
        }

        ActionRow {
            title: "Satty"
            subtitle: "Select a region, annotate, and copy the screenshot"
            icon: "󰹑"
            trailing: "Capture"
            onClicked: root.launch([Quickshell.env("HOME") + "/.config/hypr/screenshot-area.sh"])
        }

        ActionRow {
            title: "Kooha"
            subtitle: "Simple region, monitor, and audio recording"
            icon: "󰕧"
            trailing: "Open"
            onClicked: root.launch(["kooha"])
        }

        ActionRow {
            title: "GPU Screen Recorder"
            subtitle: "Hardware-accelerated recording and replay"
            icon: "󰑋"
            trailing: "Open"
            onClicked: root.launch(["gpu-screen-recorder-gtk"])
        }

        Item { Layout.fillHeight: true }
    }
}
