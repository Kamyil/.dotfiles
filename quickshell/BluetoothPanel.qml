import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Bluetooth
import Quickshell.Services.Pipewire
import "."

Item {
    id: root
    implicitWidth: 340
    implicitHeight: 430

    readonly property bool hasAdapters: Bluetooth.adapters.values.length > 0
    readonly property bool powered: {
        for (const adapter of Bluetooth.adapters.values) {
            if (adapter.enabled)
                return true
        }
        return false
    }
    readonly property bool discovering: {
        for (const adapter of Bluetooth.adapters.values) {
            if (adapter.discovering)
                return true
        }
        return false
    }
    readonly property var audioSinks: (Pipewire.nodes ? Pipewire.nodes.values : []).filter(node => node && node.isSink && !node.isStream)


    function switchAudioOutput(device) {
        if (!device || !device.address)
            return false
        const address = String(device.address).toLowerCase()
        const underscored = address.replace(/:/g, "_")
        for (const node of audioSinks) {
            const props = node && node.properties ? node.properties : ({})
            const blob = String(node.name || "") + " " + String(node.description || "") + " " + JSON.stringify(props)
            const normalized = blob.toLowerCase()
            if (normalized.includes(address) || normalized.includes(underscored)) {
                Pipewire.preferredDefaultAudioSink = node
                return true
            }
        }
        return false
    }

    PwObjectTracker { objects: root.audioSinks }

    function setPowered(value) {
        for (const adapter of Bluetooth.adapters.values)
            adapter.enabled = value
    }

    function setDiscovery(value) {
        for (const adapter of Bluetooth.adapters.values) {
            if (adapter.enabled)
                adapter.discovering = value
        }
        if (value)
            discoveryStop.restart()
        else
            discoveryStop.stop()
    }

    function deviceCount() {
        let count = 0
        for (const adapter of Bluetooth.adapters.values)
            count += adapter.devices.values.length
        return count
    }

    Timer {
        id: discoveryStop
        interval: 15000
        onTriggered: root.setDiscovery(false)
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        Heading {
            title: "Bluetooth"
            subtitle: !root.hasAdapters ? "No Bluetooth adapters found"
                : root.discovering ? "Looking for nearby devices…"
                : root.powered ? "Choose a device to pair or connect" : "Bluetooth is off"
        }

        SwitchRow {
            title: "Bluetooth"
            subtitle: Bluetooth.adapters.values.length > 1
                ? Bluetooth.adapters.values.length + " adapters"
                : root.hasAdapters ? Bluetooth.adapters.values[0].name : "No adapter"
            checked: root.powered
            onToggled: value => root.setPowered(value)
        }

        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "DEVICES"
                color: Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: 9
                font.weight: Font.DemiBold
                Layout.fillWidth: true
            }
            Text {
                text: root.discovering ? "Stop discovery" : "Find devices"
                color: root.powered ? Theme.accent : Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: 9
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -8
                    cursorShape: Qt.PointingHandCursor
                    enabled: root.powered
                    onClicked: root.setDiscovery(!root.discovering)
                }
            }
        }

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: deviceColumns.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: deviceColumns
                width: parent.width
                spacing: 8

                Repeater {
                    model: Bluetooth.adapters
                    delegate: ColumnLayout {
                        id: adapterSection
                        required property var modelData
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            Layout.fillWidth: true
                            text: adapterSection.modelData.name
                            color: adapterSection.modelData.enabled ? Theme.muted : Theme.danger
                            font.family: Theme.fontFamily
                            font.pixelSize: 9
                            elide: Text.ElideRight
                        }

                        Repeater {
                            model: adapterSection.modelData.devices
                            delegate: ActionRow {
                                id: deviceRow
                                required property var modelData
                                property bool profileConnectSucceeded: false
                                readonly property bool pairingActive: pairProcess.running && !profileConnectSucceeded

                                title: modelData.deviceName || modelData.name || modelData.address
                                subtitle: pairingActive ? "pairing"
                                    : modelData.connected
                                        ? (modelData.batteryAvailable ? "connected · " + Math.round(modelData.battery * 100) + "% battery" : "connected")
                                    : modelData.paired ? (modelData.trusted ? "remembered · right-click to forget" : "paired · right-click to forget")
                                    : "nearby"
                                icon: pairingActive ? "" : modelData.connected ? "󰂱" : modelData.paired ? "󰂯" : ""
                                trailing: pairingActive ? "Pairing…"
                                    : modelData.connected ? "Disconnect"
                                    : modelData.paired ? "Connect" : "Pair & connect"
                                selected: modelData.connected && !pairingActive
                                onClicked: {
                                    if (pairingActive) {
                                        return
                                    } else if (modelData.connected) {
                                        modelData.disconnect()
                                    } else if (modelData.paired) {
                                        modelData.trusted = true
                                        modelData.connect()
                                    } else {
                                        profileConnectSucceeded = false
                                        root.setDiscovery(false)
                                        pairLaunch.restart()
                                    }
                                }

                                TapHandler {
                                    acceptedButtons: Qt.RightButton
                                    onTapped: if (deviceRow.modelData.paired && !deviceRow.modelData.connected) deviceRow.modelData.forget()
                                }

                                Timer {
                                    id: pairLaunch
                                    interval: 300
                                    onTriggered: {
                                        pairProcess.command = ["bluetoothctl", "--agent", "NoInputNoOutput", "--timeout", "30",
                                            "pair", deviceRow.modelData.address]
                                        pairProcess.running = true
                                    }
                                }

                                Process {
                                    id: pairProcess
                                }

                                Process {
                                    id: profileConnect
                                    onExited: {
                                        if (deviceRow.modelData.connected) {
                                            deviceRow.profileConnectSucceeded = true
                                            deviceRow.modelData.trusted = true
                                        }
                                    }

                                }

                                Timer {
                                    id: audioSwitchRetry
                                    interval: 500
                                    repeat: true
                                    property int attempts: 0
                                    onTriggered: {
                                        attempts++
                                        if (!deviceRow.modelData.connected
                                                || root.switchAudioOutput(deviceRow.modelData)
                                                || attempts >= 10)
                                            stop()
                                    }
                                }

                                Connections {
                                    target: deviceRow.modelData
                                    function onPairedChanged() {
                                        if (deviceRow.modelData.paired && pairProcess.running && !profileConnect.running) {
                                            profileConnect.command = ["bluetoothctl", "--timeout", "10", "connect",
                                                deviceRow.modelData.address, "0000110b-0000-1000-8000-00805f9b34fb"]
                                            profileConnect.running = true
                                        }
                                    }
                                    function onConnectedChanged() {
                                        if (deviceRow.modelData.connected) {
                                            audioSwitchRetry.attempts = 0
                                            audioSwitchRetry.restart()
                                        } else {
                                            audioSwitchRetry.stop()
                                        }
                                    }
                                }
                            }
                        }

                        Text {
                            visible: adapterSection.modelData.enabled && adapterSection.modelData.devices.values.length === 0
                            Layout.fillWidth: true
                            text: root.discovering ? "Searching…" : "No devices found on this adapter"
                            color: Theme.muted
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                        }
                    }
                }

                Text {
                    visible: root.hasAdapters && root.deviceCount() === 0 && !root.powered
                    Layout.fillWidth: true
                    text: "Turn Bluetooth on to see nearby and remembered devices."
                    color: Theme.muted
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    wrapMode: Text.WordWrap
                }
            }
        }
    }
}
