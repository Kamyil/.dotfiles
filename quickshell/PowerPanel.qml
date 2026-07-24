import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Services.UPower
import "."

Item {
    id: root
    implicitWidth: 340
    implicitHeight: 360
    readonly property var battery: UPower.displayDevice
    readonly property int percentage: battery && battery.ready ? Math.round(battery.percentage * 100) : 0
    readonly property bool charging: battery && (battery.state === UPowerDeviceState.Charging || battery.state === UPowerDeviceState.PendingCharge)
    readonly property string stateName: !battery || !battery.ready ? "Unavailable"
        : charging ? "Charging"
        : battery.state === UPowerDeviceState.FullyCharged ? "Fully charged"
        : battery.state === UPowerDeviceState.Discharging ? "Discharging" : "Connected"
    readonly property real remainingSeconds: charging ? battery.timeToFull : battery.timeToEmpty
    property string activeProfile: ""

    function duration(seconds) {
        if (!seconds || seconds <= 0) return ""
        const hours = Math.floor(seconds / 3600)
        const minutes = Math.round((seconds % 3600) / 60)
        return (hours > 0 ? hours + "h " : "") + minutes + "m"
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
    Timer { id: refreshDelay; interval: 400; onTriggered: profileProc.running = true }

    ColumnLayout {
        anchors.fill: parent
        spacing: 12
        Heading {
            title: "Battery"
            subtitle: root.stateName + (root.duration(root.remainingSeconds) ? " · " + root.duration(root.remainingSeconds) : "")
        }
        Rectangle {
            Layout.fillWidth: true; implicitHeight: 88; radius: 10; color: Theme.elevated
            RowLayout {
                anchors.fill: parent; anchors.margins: 14; spacing: 12
                Text {
                    text: root.charging ? "󰂄" : root.percentage > 75 ? "󰁹" : root.percentage > 40 ? "󰁾" : root.percentage > 15 ? "󰁻" : "󰂃"
                    color: root.percentage <= 15 ? Theme.danger : root.charging ? Theme.good : Theme.foreground
                    font.family: Theme.fontFamily; font.pixelSize: 27
                }
                ColumnLayout {
                    Layout.fillWidth: true; spacing: 2
                    Text { text: root.percentage + "%"; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: 20; font.weight: Font.DemiBold }
                    Text {
                        text: root.battery && root.battery.ready
                            ? Math.abs(root.battery.changeRate).toFixed(1) + " W" + (root.battery.healthSupported ? " · " + Math.round(root.battery.healthPercentage * 100) + "% health" : "")
                            : "Power information unavailable"
                        color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 9
                    }
                }
            }
        }
        Text { text: "POWER MODE"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 9; font.weight: Font.DemiBold }
        Repeater {
            model: [
                { name: "power-saver", title: "Power saver", icon: "󰌪" },
                { name: "balanced", title: "Balanced", icon: "󰾅" },
                { name: "performance", title: "Performance", icon: "󰓅" }
            ]
            delegate: ActionRow {
                required property var modelData
                title: modelData.title; icon: modelData.icon
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
    Component.onCompleted: profileProc.running = true
}
