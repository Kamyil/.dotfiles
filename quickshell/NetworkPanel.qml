import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Networking
import "."

Item {
    id: root
    implicitWidth: 340
    implicitHeight: 420

    property string selectedSsid: ""
    property string selectedInterface: ""
    property string feedback: ""
    property var scanQueue: []
    property string scanInterface: ""
    property var networkIndexes: ({})
    readonly property bool scanning: adapters.running || scan.running || scanQueue.length > 0

    function refresh() {
        if (scanning)
            return
        feedback = ""
        networks.clear()
        networkIndexes = ({})
        adapters.running = true
    }

    function startNextScan() {
        if (scanQueue.length === 0) {
            scanInterface = ""
            return
        }
        scanInterface = scanQueue.shift()
        scan.command = ["nmcli", "-m", "multiline", "-f", "IN-USE,SECURITY,SIGNAL,SSID",
                        "device", "wifi", "list", "ifname", scanInterface, "--rescan", "yes"]
        scan.running = true
    }

    function addNetwork(record) {
        if (!record.ssid)
            return
        const key = scanInterface + "\n" + record.ssid
        const existing = networkIndexes[key]
        if (existing !== undefined) {
            const current = networks.get(existing)
            networks.setProperty(existing, "active", current.active || record.active)
            if (record.signal > current.signal) {
                networks.setProperty(existing, "signal", record.signal)
                networks.setProperty(existing, "security", record.security)
            }
            return
        }
        networkIndexes[key] = networks.count
        networks.append({
            active: record.active,
            interfaceName: scanInterface,
            security: record.security,
            signal: record.signal,
            ssid: record.ssid
        })
    }

    function parseScan(text) {
        let record = null
        for (const line of text.split("\n")) {
            const separator = line.indexOf(":")
            if (separator < 0)
                continue
            const field = line.slice(0, separator).trim()
            const value = line.slice(separator + 1).trim()
            if (field === "IN-USE") {
                if (record)
                    addNetwork(record)
                record = { active: value === "*", security: "", signal: 0, ssid: "" }
            } else if (record && field === "SECURITY") {
                record.security = value
            } else if (record && field === "SIGNAL") {
                record.signal = Number(value)
            } else if (record && field === "SSID") {
                record.ssid = value
            }
        }
        if (record)
            addNetwork(record)
    }

    function connectedSsid() {
        for (let i = 0; i < networks.count; ++i) {
            if (networks.get(i).active)
                return networks.get(i).ssid
        }
        return ""
    }

    function connectNetwork(ssid, interfaceName, password) {
        feedback = "Connecting to " + ssid + " on " + interfaceName + "…"
        const args = ["nmcli", "device", "wifi", "connect", ssid]
        if (password.length > 0)
            args.push("password", password)
        args.push("ifname", interfaceName)
        action.command = args
        action.running = true
    }

    ListModel { id: networks }

    Process {
        id: adapters
        command: ["nmcli", "-t", "-e", "no", "-f", "DEVICE,TYPE", "device", "status"]
        stdout: StdioCollector {
            onStreamFinished: {
                const interfaces = []
                for (const line of text.trim().split("\n")) {
                    const fields = line.split(":")
                    if (fields.length >= 2 && fields[1] === "wifi")
                        interfaces.push(fields[0])
                }
                root.scanQueue = interfaces
                if (interfaces.length === 0)
                    root.feedback = "No Wi-Fi adapters found"
            }
        }
        onExited: root.startNextScan()
    }

    Process {
        id: scan
        stdout: StdioCollector { onStreamFinished: root.parseScan(text) }
        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0)
                    root.feedback = root.scanInterface + ": " + text.trim()
            }
        }
        onExited: root.startNextScan()
    }

    Process {
        id: action
        stdout: StdioCollector { onStreamFinished: root.feedback = text.trim() }
        stderr: StdioCollector { onStreamFinished: if (text.trim().length > 0) root.feedback = text.trim() }
        onExited: refreshDelay.restart()
    }

    Timer {
        id: refreshDelay
        interval: 1200
        onTriggered: root.refresh()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        Heading {
            title: "Wi-Fi"
            subtitle: root.connectedSsid() || "Choose a nearby network"
        }

        SwitchRow {
            title: "Wi-Fi"
            subtitle: Networking.wifiHardwareEnabled ? "Wireless networking" : "Disabled by hardware switch"
            checked: Networking.wifiEnabled
            onToggled: value => {
                Networking.wifiEnabled = value
                refreshDelay.restart()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "NETWORKS"
                color: Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: 9
                font.weight: Font.DemiBold
                Layout.fillWidth: true
            }
            Text {
                text: root.scanning ? "Scanning…" : "Refresh"
                color: root.scanning ? Theme.muted : Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: 9
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -8
                    cursorShape: Qt.PointingHandCursor
                    enabled: !root.scanning
                    onClicked: root.refresh()
                }
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            ColumnLayout {
                width: parent.width
                spacing: 2

                Repeater {
                    model: networks
                    delegate: ActionRow {
                        required property bool active
                        required property string interfaceName
                        required property string security
                        required property int signal
                        required property string ssid

                        title: ssid
                        subtitle: interfaceName + " · " + (active ? "connected" : security.length > 0 ? "secured" : "open")
                        icon: signal >= 75 ? "󰤨" : signal >= 50 ? "󰤥" : signal >= 25 ? "󰤢" : "󰤟"
                        trailing: active ? "Disconnect" : "Connect"
                        selected: active
                        onClicked: {
                            if (active) {
                                action.command = ["nmcli", "device", "disconnect", interfaceName]
                                action.running = true
                            } else if (security.length === 0) {
                                root.connectNetwork(ssid, interfaceName, "")
                            } else {
                                root.selectedSsid = ssid
                                root.selectedInterface = interfaceName
                                password.text = ""
                                credentials.open()
                            }
                        }
                    }
                }
            }
        }

        Text {
            visible: root.feedback.length > 0
            text: root.feedback
            color: Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: 9
            elide: Text.ElideRight
            Layout.fillWidth: true
        }
    }

    Dialog {
        id: credentials
        anchors.centerIn: parent
        modal: true
        title: "Connect to " + root.selectedSsid + " via " + root.selectedInterface
        standardButtons: Dialog.Ok | Dialog.Cancel
        onAccepted: root.connectNetwork(root.selectedSsid, root.selectedInterface, password.text)

        background: Rectangle {
            color: Theme.elevated
            border.color: Theme.border
            radius: 10
        }

        TextField {
            id: password
            width: 260
            placeholderText: "Password (blank for a saved network)"
            echoMode: TextInput.Password
            color: Theme.foreground
            selectByMouse: true
            onAccepted: credentials.accept()
        }
    }

    Component.onCompleted: refresh()
}
