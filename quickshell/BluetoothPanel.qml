import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
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
                            text: adapterSection.modelData.name + " · " + adapterSection.modelData.adapterId
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
                                property bool connectAfterPair: false

                                title: modelData.name || modelData.deviceName || modelData.address
                                subtitle: adapterSection.modelData.adapterId + " · "
                                    + (modelData.connected ? "connected"
                                        : modelData.pairing ? "pairing"
                                        : modelData.paired ? "paired"
                                        : "nearby")
                                icon: modelData.connected ? "󰂱" : modelData.paired ? "󰂯" : ""
                                trailing: modelData.connected ? "Disconnect"
                                    : modelData.pairing ? "Pairing…"
                                    : modelData.paired ? "Connect" : "Pair & connect"
                                selected: modelData.connected
                                onClicked: {
                                    if (modelData.connected) {
                                        modelData.disconnect()
                                    } else if (modelData.paired) {
                                        modelData.trusted = true
                                        modelData.connect()
                                    } else if (!modelData.pairing) {
                                        connectAfterPair = true
                                        modelData.pair()
                                    }
                                }

                                Connections {
                                    target: deviceRow.modelData
                                    function onPairedChanged() {
                                        if (deviceRow.connectAfterPair && deviceRow.modelData.paired) {
                                            deviceRow.connectAfterPair = false
                                            deviceRow.modelData.trusted = true
                                            deviceRow.modelData.connect()
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
