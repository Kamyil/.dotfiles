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
            title: "OBS Studio"
            subtitle: "Record a display, window, or application with audio"
            icon: "󰑋"
            trailing: "Open"
            onClicked: root.launch(["obs"])
        }

        Item { Layout.fillHeight: true }
    }
}
