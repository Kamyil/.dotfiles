import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Networking
import "."

Item {
    id: root
    implicitWidth: 340
    implicitHeight: 610

    property var info: ({})
    property real previousRx: 0
    property real previousTx: 0
    property real previousTime: 0
    property string previousInterface: ""
    property real receiveRate: 0
    property real sendRate: 0
    property var pingSamples: []
    property int pingLoss: 0
    property string dnsProvider: "DHCP"
    property string feedback: ""
    property string selectedSsid: ""
    property string selectedInterface: ""
    property var scanQueue: []
    property string scanInterface: ""
    property var networkIndexes: ({})
    property string speedPhase: ""
    property string downloadMbps: "—"
    property string uploadMbps: "—"
    readonly property bool scanning: adapters.running || scan.running || scanQueue.length > 0
    readonly property bool speedRunning: speedPhase !== ""
    readonly property string helperDir: Quickshell.env("HOME") + "/.config/quickshell/"

    function parseKeyValues(text) {
        const result = {}
        for (const line of text.trim().split("\n")) {
            const separator = line.indexOf("\t")
            if (separator > 0)
                result[line.slice(0, separator)] = line.slice(separator + 1)
        }
        return result
    }

    function updateDetails(text) {
        const next = parseKeyValues(text)
        const now = Date.now() / 1000
        if (next.iface === previousInterface && previousTime > 0) {
            const elapsed = now - previousTime
            receiveRate = Math.max(0, (Number(next.rx_bytes || 0) - previousRx) / elapsed)
            sendRate = Math.max(0, (Number(next.tx_bytes || 0) - previousTx) / elapsed)
        } else {
            receiveRate = 0
            sendRate = 0
            pingSamples = []
        }
        previousInterface = next.iface || ""
        previousRx = Number(next.rx_bytes || 0)
        previousTx = Number(next.tx_bytes || 0)
        previousTime = now
        const ping = Number(next.internet_ping_ms)
        let samples = pingSamples.slice()
        samples.push(isFinite(ping) && ping > 0 ? ping : -1)
        if (samples.length > 24) samples.shift()
        pingSamples = samples
        let lost = 0
        for (const sample of samples) if (sample < 0) ++lost
        pingLoss = samples.length ? Math.round(lost * 100 / samples.length) : 0
        info = next
    }

    function averagePing() {
        const valid = pingSamples.filter(value => value >= 0).slice(-5)
        if (!valid.length) return "—"
        return (valid.reduce((sum, value) => sum + value, 0) / valid.length).toFixed(1) + " ms"
    }

    function formatBytes(value) {
        let number = Number(value || 0)
        const units = ["B", "KB", "MB", "GB", "TB"]
        let unit = 0
        while (number >= 1000 && unit < units.length - 1) { number /= 1000; ++unit }
        return number.toFixed(unit < 2 ? 0 : 2) + " " + units[unit]
    }

    function formatRate(value) { return formatBytes(value) + "/s" }

    function refreshNetworks() {
        if (scanning) return
        networks.clear()
        networkIndexes = ({})
        adapters.running = true
    }

    function startNextScan() {
        if (!scanQueue.length) { scanInterface = ""; return }
        scanInterface = scanQueue.shift()
        scan.command = ["nmcli", "-m", "multiline", "-f", "IN-USE,SECURITY,SIGNAL,SSID", "device", "wifi", "list", "ifname", scanInterface, "--rescan", "yes"]
        scan.running = true
    }

    function addNetwork(record) {
        if (!record.ssid) return
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
        networks.append({ active: record.active, interfaceName: scanInterface, security: record.security, signal: record.signal, ssid: record.ssid })
    }

    function parseScan(text) {
        let record = null
        for (const line of text.split("\n")) {
            const separator = line.indexOf(":")
            if (separator < 0) continue
            const field = line.slice(0, separator).trim()
            const value = line.slice(separator + 1).trim()
            if (field === "IN-USE") { if (record) addNetwork(record); record = { active: value === "*", security: "", signal: 0, ssid: "" } }
            else if (record && field === "SECURITY") record.security = value
            else if (record && field === "SIGNAL") record.signal = Number(value)
            else if (record && field === "SSID") record.ssid = value
        }
        if (record) addNetwork(record)
    }

    function connectNetwork(ssid, interfaceName, passphrase) {
        feedback = "Connecting to " + ssid + "…"
        const args = ["nmcli", "device", "wifi", "connect", ssid]
        if (passphrase.length) args.push("password", passphrase)
        args.push("ifname", interfaceName)
        action.command = args
        action.running = true
    }

    function setDns(provider, servers) {
        feedback = "Setting DNS to " + provider + "…"
        dnsAction.command = [helperDir + "network-dns.sh", provider]
        if (servers) dnsAction.command.push(servers)
        dnsAction.running = true
    }

    function runSpeedTest() {
        downloadMbps = "…"
        uploadMbps = "…"
        speedPhase = "down"
        speed.command = [helperDir + "network-speedtest.sh", speedPhase]
        speed.running = true
        speedTimeout.restart()
    }

    function nextSpeedPhase() {
        speedTimeout.stop()
        if (speedPhase === "down") {
            speedPhase = "up"
            speed.command = [helperDir + "network-speedtest.sh", speedPhase]
            speed.running = true
            speedTimeout.restart()
        } else speedPhase = ""
    }

    ListModel { id: networks }

    Process {
        id: details
        command: [root.helperDir + "network-status.sh"]
        stdout: StdioCollector { onStreamFinished: root.updateDetails(text) }
    }
    Timer { interval: 1500; running: true; repeat: true; triggeredOnStart: true; onTriggered: if (!details.running) details.running = true }

    Process {
        id: dnsStatus
        command: [root.helperDir + "network-dns.sh"]
        stdout: StdioCollector { onStreamFinished: if (text.trim()) root.dnsProvider = text.trim() }
        stderr: StdioCollector { onStreamFinished: if (text.trim()) root.feedback = text.trim() }
    }
    Timer { interval: 5000; running: true; repeat: true; triggeredOnStart: true; onTriggered: if (!dnsStatus.running && !dnsAction.running) dnsStatus.running = true }

    Process {
        id: dnsAction
        stdout: StdioCollector { onStreamFinished: if (text.trim()) root.dnsProvider = text.trim() }
        stderr: StdioCollector { onStreamFinished: if (text.trim()) root.feedback = text.trim() }
        onExited: dnsStatus.running = true
    }

    Process {
        id: speed
        stdout: SplitParser { onRead: line => { const value = Number(line); if (isFinite(value)) { if (root.speedPhase === "down") root.downloadMbps = line; else root.uploadMbps = line } } }
        stderr: StdioCollector { onStreamFinished: if (text.trim()) root.feedback = text.trim() }
        onExited: root.nextSpeedPhase()
    }
    Timer { id: speedTimeout; interval: 5000; onTriggered: speed.running = false }

    Process {
        id: adapters
        command: ["nmcli", "-t", "-e", "no", "-f", "DEVICE,TYPE", "device", "status"]
        stdout: StdioCollector { onStreamFinished: {
            const interfaces = []
            for (const line of text.trim().split("\n")) { const fields = line.split(":"); if (fields.length >= 2 && fields[1] === "wifi") interfaces.push(fields[0]) }
            root.scanQueue = interfaces
        } }
        onExited: root.startNextScan()
    }
    Process {
        id: scan
        stdout: StdioCollector { onStreamFinished: root.parseScan(text) }
        onExited: root.startNextScan()
    }
    Process {
        id: action
        stdout: StdioCollector { onStreamFinished: root.feedback = text.trim() }
        stderr: StdioCollector { onStreamFinished: if (text.trim()) root.feedback = text.trim() }
        onExited: refreshDelay.restart()
    }
    Timer { id: refreshDelay; interval: 1200; onTriggered: root.refreshNetworks() }

    component PanelButton: Button {
        id: control
        property bool selected: false

        implicitHeight: 30
        leftPadding: 12
        rightPadding: 12
        topPadding: 6
        bottomPadding: 6
        opacity: enabled ? 1 : 0.45

        contentItem: Text {
            text: control.text
            color: control.selected ? Theme.background : Theme.foreground
            font.family: Theme.fontFamily
            font.pixelSize: 10
            font.weight: control.selected ? Font.DemiBold : Font.Medium
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        background: Rectangle {
            radius: 7
            color: control.selected ? Theme.accent
                : control.down ? Theme.hover
                : control.hovered ? Theme.elevated
                : "transparent"
            border.color: control.selected ? Theme.accent : control.hovered ? Theme.muted : Theme.border
            border.width: 1

            Behavior on color { ColorAnimation { duration: 100 } }
            Behavior on border.color { ColorAnimation { duration: 100 } }
        }
    }

    component MetricLabel: Text { color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 10 }
    component MetricValue: Text { color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: 10; horizontalAlignment: Text.AlignRight }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            Text { text: root.info.type === "ethernet" ? "󰈀" : root.info.type === "wifi" ? "󰤨" : "󰤮"; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: 27 }
            ColumnLayout {
                spacing: 1; Layout.fillWidth: true
                Text { text: root.info.type === "ethernet" ? "Ethernet" : root.info.ssid || (root.info.iface ? "Wi-Fi" : "Disconnected"); color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: 15; font.bold: true; elide: Text.ElideRight; Layout.fillWidth: true }
                Text { text: root.info.iface ? "ROUTING CRUMBS" : "NO CONNECTION"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 9; font.bold: true; font.letterSpacing: 1.4 }
            }
            Rectangle {
                visible: !!root.info.speed || !!root.info.bitrate
                implicitWidth: speedBadge.implicitWidth + 12; implicitHeight: 24; radius: 7; color: "transparent"; border.color: Theme.border
                Text { id: speedBadge; anchors.centerIn: parent; text: root.info.speed ? root.info.speed + "mbit" : root.info.bitrate || ""; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 10 }
            }
        }

        GridLayout {
            visible: !!root.info.iface
            Layout.fillWidth: true; columns: 4; columnSpacing: 12; rowSpacing: 7
            MetricLabel { text: "Ping" } MetricValue { text: root.averagePing(); Layout.fillWidth: true }
            MetricLabel { text: "Packet Loss" } MetricValue { text: root.pingLoss + "%"; color: root.pingLoss ? Theme.danger : Theme.foreground; Layout.fillWidth: true }
            MetricLabel { text: "Receiving" } MetricValue { text: root.formatRate(root.receiveRate); Layout.fillWidth: true }
            MetricLabel { text: "Sending" } MetricValue { text: root.formatRate(root.sendRate); Layout.fillWidth: true }
            MetricLabel { text: "Downloaded" } MetricValue { text: root.formatBytes(root.info.rx_bytes); Layout.fillWidth: true }
            MetricLabel { text: "Uploaded" } MetricValue { text: root.formatBytes(root.info.tx_bytes); Layout.fillWidth: true }
            MetricLabel { text: "IP Address" } MetricValue { text: root.info.ip || "—"; Layout.fillWidth: true }
            MetricLabel { text: "Gateway" } MetricValue { text: root.info.gateway || "—"; Layout.fillWidth: true }
        }

        Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Theme.border }

        RowLayout {
            Layout.fillWidth: true
            Text { text: "SPEED TEST"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 9; font.bold: true; Layout.fillWidth: true }
            PanelButton { text: root.speedRunning ? "Running…" : "Run"; enabled: !root.speedRunning && !!root.info.iface; onClicked: root.runSpeedTest() }
        }
        GridLayout {
            visible: root.downloadMbps !== "—" || root.uploadMbps !== "—"
            Layout.fillWidth: true; columns: 4; columnSpacing: 12
            MetricLabel { text: "Download" } MetricValue { text: root.downloadMbps + (root.downloadMbps === "…" ? "" : " Mbps"); Layout.fillWidth: true }
            MetricLabel { text: "Upload" } MetricValue { text: root.uploadMbps + (root.uploadMbps === "…" ? "" : " Mbps"); Layout.fillWidth: true }
        }

        Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Theme.border }
        Text { text: "DNS PROVIDER"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 9; font.bold: true }
        RowLayout {
            Layout.fillWidth: true; spacing: 6
            Repeater {
                model: ["DHCP", "Cloudflare", "Google", "Custom"]
                delegate: PanelButton {
                    required property string modelData
                    text: modelData
                    Layout.fillWidth: true
                    selected: root.dnsProvider === modelData
                    onClicked: modelData === "Custom" ? customDns.open() : root.setDns(modelData, "")
                }
            }
        }

        Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Theme.border }
        RowLayout {
            Layout.fillWidth: true
            Text { text: "WI-FI NETWORKS"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 9; font.bold: true; Layout.fillWidth: true }
            Text {
                text: root.scanning ? "Scanning…" : "Refresh"; color: root.scanning ? Theme.muted : Theme.accent; font.family: Theme.fontFamily; font.pixelSize: 9
                MouseArea { anchors.fill: parent; anchors.margins: -8; enabled: !root.scanning; cursorShape: Qt.PointingHandCursor; onClicked: root.refreshNetworks() }
            }
        }
        ScrollView {
            Layout.fillWidth: true; Layout.fillHeight: true; clip: true; ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ColumnLayout {
                width: parent.width; spacing: 2
                Repeater {
                    model: networks
                    delegate: ActionRow {
                        required property bool active; required property string interfaceName; required property string security; required property int signal; required property string ssid
                        title: ssid; subtitle: interfaceName + " · " + (active ? "connected" : security.length ? "secured" : "open")
                        icon: signal >= 75 ? "󰤨" : signal >= 50 ? "󰤥" : signal >= 25 ? "󰤢" : "󰤟"
                        trailing: active ? "Disconnect" : "Connect"; selected: active
                        onClicked: {
                            if (active) { action.command = ["nmcli", "device", "disconnect", interfaceName]; action.running = true }
                            else if (!security.length) root.connectNetwork(ssid, interfaceName, "")
                            else { root.selectedSsid = ssid; root.selectedInterface = interfaceName; password.text = ""; credentials.open() }
                        }
                    }
                }
            }
        }
        Text { visible: root.feedback.length > 0; text: root.feedback; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 9; elide: Text.ElideRight; Layout.fillWidth: true }
    }

    Dialog {
        id: credentials; anchors.centerIn: parent; modal: true; title: "Connect to " + root.selectedSsid; standardButtons: Dialog.Ok | Dialog.Cancel
        onAccepted: root.connectNetwork(root.selectedSsid, root.selectedInterface, password.text)
        background: Rectangle { color: Theme.elevated; border.color: Theme.border; radius: 10 }
        TextField { id: password; width: 260; placeholderText: "Password (blank for saved network)"; echoMode: TextInput.Password; color: Theme.foreground; selectByMouse: true; onAccepted: credentials.accept() }
    }
    Dialog {
        id: customDns; anchors.centerIn: parent; modal: true; title: "Custom DNS servers"; standardButtons: Dialog.Ok | Dialog.Cancel
        onOpened: dnsServers.forceActiveFocus()
        onAccepted: root.setDns("Custom", dnsServers.text)
        background: Rectangle { color: Theme.elevated; border.color: Theme.border; radius: 10 }
        TextField { id: dnsServers; width: 280; placeholderText: "1.1.1.1 2606:4700:4700::1111"; color: Theme.foreground; selectByMouse: true; onAccepted: customDns.accept() }
    }

    Component.onCompleted: refreshNetworks()
}
