import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "."

Item {
    id: root
    implicitWidth: 340
    implicitHeight: 300

    property int percentage: 0
    property string state: "unknown"
    property string timeRemaining: ""
    property string energyRate: ""
    property string activeProfile: ""

    function refresh() {
        batteryProc.running = true
        profileProc.running = true
    }

    Process {
        id: batteryProc
        command: ["bash", "-lc", "device=$(upower -e | grep battery | head -n1); test -n \"$device\" && upower -i \"$device\""]
        stdout: StdioCollector {
            onStreamFinished: {
                let match = text.match(/percentage:\s+([0-9]+)%/)
                if (match) root.percentage = Number(match[1])
                match = text.match(/state:\s+([^\n]+)/)
                if (match) root.state = match[1].trim()
                match = text.match(/time to (?:empty|full):\s+([^\n]+)/)
                root.timeRemaining = match ? match[1].trim() : ""
                match = text.match(/energy-rate:\s+([^\n]+)/)
                root.energyRate = match ? match[1].trim() : ""
            }
        }
    }

    Process {
        id: profileProc
        command: ["powerprofilesctl", "get"]
        stdout: StdioCollector { onStreamFinished: root.activeProfile = text.trim() }
    }

    Process {
        id: action
        onExited: refreshDelay.restart()
    }
    Timer { id: refreshDelay; interval: 400; onTriggered: root.refresh() }

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        Heading {
            title: "Battery"
            subtitle: root.state.charAt(0).toUpperCase() + root.state.slice(1) + (root.timeRemaining ? " · " + root.timeRemaining : "")
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 72
            radius: 10
            color: Theme.elevated

            RowLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 12
                Text {
                    text: root.state === "charging" ? "󰂄" : root.percentage > 75 ? "󰁹" : root.percentage > 40 ? "󰁾" : root.percentage > 15 ? "󰁻" : "󰂃"
                    color: root.percentage <= 15 ? Theme.danger : root.state === "charging" ? Theme.good : Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: 25
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Text {
                        text: root.percentage + "%"
                        color: Theme.foreground
                        font.family: Theme.fontFamily
                        font.pixelSize: 18
                        font.weight: Font.DemiBold
                    }
                    Text {
                        text: root.energyRate || "Power information unavailable"
                        color: Theme.muted
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                    }
                }
            }
        }

        Text {
            text: "POWER MODE"
            color: Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: 9
            font.weight: Font.DemiBold
        }

        Repeater {
            model: [
                { name: "power-saver", title: "Power saver", icon: "󰌪" },
                { name: "balanced", title: "Balanced", icon: "󰾅" },
                { name: "performance", title: "Performance", icon: "󰓅" }
            ]
            delegate: ActionRow {
                required property var modelData
                title: modelData.title
                icon: modelData.icon
                trailing: modelData.name === root.activeProfile ? "Selected" : ""
                selected: modelData.name === root.activeProfile
                onClicked: {
                    action.command = ["powerprofilesctl", "set", modelData.name]
                    action.running = true
                }
            }
        }

        Item { Layout.fillHeight: true }
    }

    Component.onCompleted: refresh()
}
