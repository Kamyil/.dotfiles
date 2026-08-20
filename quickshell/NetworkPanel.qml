import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Networking
import "."
import "Model.js" as Model

FocusScope {
    id: root
    implicitWidth: 340
    implicitHeight: Math.min(760, panelColumn.implicitHeight)
    focus: true
    activeFocusOnTab: true

    property var info: ({})
    property real prevRxBytes: 0
    property real prevTxBytes: 0
    property real prevSampleTime: 0
    property string prevIface: ""
    property real downloadRate: 0
    property real uploadRate: 0
    property string pingIface: ""
    property var routerPingSamples: []
    property var internetPingSamples: []
    property real routerPingLatency: -1
    property real internetPingLatency: -1
    property int internetPingPacketLoss: 0
    property var wifiNetworks: []
    property string selectedSsid: ""
    property string selectedInterface: ""
    property string selectedSecurity: ""
    readonly property bool selectedEnterprise: /EAP|802-1X|802-1x/.test(selectedSecurity)
    property string passwordText: ""
    property string identityText: ""
    property string failureSsid: ""
    property string failureReason: ""
    property string actionSsid: ""
    property string actionKind: ""
    property string feedback: ""
    property bool scanning: false
    property bool wifiEnabled: true
    property string dnsProvider: "DHCP"
    property string pendingDnsProvider: ""
    property string bandCurrent: ""
    property string bandSelected: "auto"
    property var bandAvailable: []
    property string pendingBand: ""
    property int selectedIndex: -1
    property string focusSection: "dns"
    property int dnsIndex: 0
    readonly property var dnsProviders: ["DHCP", "Cloudflare", "Google", "Custom"]
    readonly property bool busy: actionKind !== ""
    readonly property bool wifiAvailable: scanInterfaces.length > 0
    readonly property bool canSelectBand: info.type === "wifi" && (bandAvailable.length > 1 || bandSelected !== "auto")
    readonly property string bandEffective: pendingBand !== "" ? pendingBand : bandSelected
    readonly property bool bandBusy: pendingBand !== ""
    readonly property string helperDir: Quickshell.env("HOME") + "/.config/quickshell/"
    readonly property string currentIcon: Model.connectionIcon(info.type === "wifi" ? "wifi" : info.type === "ethernet" ? "ethernet" : "disconnected", signalPercent())
    readonly property bool hasInternetPing: internetPingSamples.length > 0
    readonly property bool hasTransferStats: info.rx_bytes !== undefined
    property var scanInterfaces: []
    property var knownConnections: []

    function signalPercent() {
        var value = Number(info.signal)
        if (!isFinite(value)) value = Number(info.signal_dbm)
        if (!isFinite(value)) return 0
        if (value < 0) return Math.max(0, Math.min(100, Math.round((value + 90) * 100 / 60)))
        return Math.max(0, Math.min(100, Math.round(value)))
    }

    function formatBytes(bytes) { return Model.formatBytes(bytes) }
    function formatRate(bytes) { return Model.formatRate(bytes) }
    function formatPing(ms) { return Model.formatPingLatency(ms, hasInternetPing) }
    function formatLoss(value) { return Model.formatPacketLoss(value, hasInternetPing) }
    function requiresCredentials(security) { return Model.requiresCredentials(security) }
    function rowCanForget(row) { return Model.canForgetNetwork(row) }
    function rowIndex(ssid) {
        for (var i = 0; i < wifiNetworks.length; i++) if (wifiNetworks[i].ssid === ssid) return i
        return -1
    }

    function updateDetails(raw) {
        var next = Model.parseKeyValue(raw)
        info = next
        var throughput = Model.throughputState({
            prevIface: prevIface, prevRxBytes: prevRxBytes, prevTxBytes: prevTxBytes,
            prevSampleTime: prevSampleTime, downloadRate: downloadRate, uploadRate: uploadRate
        }, next, Date.now() / 1000)
        prevIface = throughput.prevIface
        prevRxBytes = throughput.prevRxBytes
        prevTxBytes = throughput.prevTxBytes
        prevSampleTime = throughput.prevSampleTime
        downloadRate = throughput.downloadRate
        uploadRate = throughput.uploadRate

        var ping = Model.pingLatencyState({
            pingIface: pingIface, routerPingSamples: routerPingSamples,
            internetPingSamples: internetPingSamples
        }, next, 24, 5)
        pingIface = ping.pingIface
        routerPingSamples = ping.routerPingSamples
        internetPingSamples = ping.internetPingSamples
        routerPingLatency = ping.routerPingLatency
        internetPingLatency = ping.internetPingLatency
        internetPingPacketLoss = ping.internetPingPacketLoss
    }

    function updateKnown(raw) {
        var names = []
        for (const line of String(raw || "").split("\n")) {
            var parts = line.split(":")
            if (parts.length < 2) continue
            var type = parts[parts.length - 1]
            if (type !== "802-11-wireless") continue
            names.push(Model.decodeIwSsid(parts.slice(0, -1).join(":")))
        }
        knownConnections = names
        mergeKnownFlags()
    }

    function mergeKnownFlags() {
        var next = wifiNetworks.slice()
        for (var i = 0; i < next.length; i++) next[i].known = knownConnections.indexOf(next[i].ssid) >= 0
        wifiNetworks = Model.sortWifiRows(next)
        if (selectedIndex >= wifiNetworks.length) selectedIndex = wifiNetworks.length - 1
    }

    function updateScan(raw) {
        var scanned = Model.parseWifiScan(raw)
        var merged = wifiNetworks.slice()
        for (var i = 0; i < scanned.length; i++) {
            var item = scanned[i]
            item.interfaceName = scanInterface
            var found = -1
            for (var j = 0; j < merged.length; j++) {
                if (merged[j].ssid === item.ssid && merged[j].interfaceName === item.interfaceName) { found = j; break }
            }
            if (found < 0) merged.push(item)
            else if (item.signal > merged[found].signal) merged[found] = item
        }
        for (var k = 0; k < merged.length; k++) merged[k].known = knownConnections.indexOf(merged[k].ssid) >= 0
        wifiNetworks = Model.sortWifiRows(merged)
        if (selectedIndex < 0 && wifiNetworks.length) selectedIndex = 0
        scanning = false
    }

    function refreshNetworks() {
        if (scanning || adapters.running || scan.running) return
        wifiNetworks = []
        scanning = true
        adapters.running = true
        known.running = true
    }

    function startNextScan() {
        if (!scanQueue.length) {
            scanInterface = ""
            scanning = false
            return
        }
        scanning = true
        scanInterface = scanQueue.shift()
        scanQueue = scanQueue.slice()
        scan.command = ["nmcli", "-m", "multiline", "-f", "IN-USE,SSID,SECURITY,SIGNAL,FREQ", "device", "wifi", "list", "ifname", scanInterface, "--rescan", "yes"]
        scan.running = true
    }

    function startAction(kind, ssid, command) {
        if (busy || !ssid) return
        actionSsid = ssid
        actionKind = kind
        failureSsid = ""
        failureReason = ""
        action.actionOutput = ""
        if (command && command.length) {
            action.command = command
            action.running = true
        }
        actionTimeout.restart()
    }

    function connectNetwork(ssid, interfaceName, passphrase) {
        var args = ["nmcli", "device", "wifi", "connect", ssid]
        if (passphrase.length) args.push("password", passphrase)
        if (interfaceName) args.push("ifname", interfaceName)
        startAction("connect", ssid, args)
    }

    function connectEnterprise(ssid, identity, passphrase) {
        if (busy || !ssid || !identity || !passphrase) return
        startAction("connect", ssid, [])
        enterprise.secret = passphrase
        enterprise.command = ["bash", "-c", Model.enterpriseConnectScript, "nmcli-eap", ssid, identity]
        enterprise.running = true
    }

    function submitCredentials() {
        if (!selectedSsid || !password.text.length) {
            feedback = "Enter a password"
            return
        }
        if (selectedEnterprise && !identity.text.length) {
            feedback = "Enter an identity"
            identity.forceActiveFocus()
            return
        }
        passwordText = password.text
        identityText = identity.text
        credentials.close()
        if (selectedEnterprise) connectEnterprise(selectedSsid, identity.text, password.text)
        else connectNetwork(selectedSsid, selectedInterface, password.text)
    }

    function disconnectNetwork(ssid, interfaceName) {
        if (!ssid) return
        var args = ["nmcli", "connection", "down", "id", ssid]
        if (!interfaceName) args = ["nmcli", "device", "disconnect", "ifname", info.iface || ""]
        startAction("disconnect", ssid, args)
    }

    function forgetNetwork(row) {
        if (!row || !row.ssid || !rowCanForget(row)) return
        startAction("forget", row.ssid, ["nmcli", "connection", "delete", "id", row.ssid])
    }

    function actionFinished(exitCode, output) {
        actionTimeout.stop()
        if (!actionKind) return
        var ssid = actionSsid
        var kind = actionKind
        actionSsid = ""
        actionKind = ""
        if (exitCode !== 0) {
            failureSsid = ssid
            failureReason = Model.networkFailureReason(output, kind === "connect")
            feedback = failureReason
            if (kind === "connect" && Model.shouldRepromptPassphrase(output, true)) {
                var failed = rowIndex(ssid)
                if (failed >= 0) {
                    selectedInterface = wifiNetworks[failed].interfaceName || ""
                    selectedSecurity = wifiNetworks[failed].security || ""
                }
                selectedSsid = ssid
                credentials.open()
            }
        } else feedback = kind === "connect" ? "Connected to " + ssid : kind === "forget" ? "Forgot " + ssid : "Disconnected"
        refreshDelay.restart()
    }

    function setDns(provider, servers) {
        if (busy || !provider) return
        pendingDnsProvider = provider
        var args = [helperDir + "network-dns.sh", provider]
        if (servers) args.push(servers)
        dnsAction.command = args
        dnsAction.running = true
    }

    function runSpeedTest() {
        if (speedRunning || !info.iface) return
        downloadMbps = "…"
        uploadMbps = "…"
        speedPhase = "down"
        speed.command = [helperDir + "network-speedtest.sh", "down"]
        speed.running = true
    }

    function nextSpeedPhase() {
        if (speedPhase === "down") {
            speedPhase = "up"
            speed.command = [helperDir + "network-speedtest.sh", "up"]
            speed.running = true
        } else speedPhase = ""
    }

    function setBand(band) {
        if (busy || !band) return
        pendingBand = band
        bandAction.command = [helperDir + "network-band.sh", "--set", band]
        bandAction.running = true
    }

    function toggleWifi() {
        if (radio.running) return
        radioAction.command = ["nmcli", "radio", "wifi", wifiEnabled ? "off" : "on"]
        radioAction.running = true
    }

    function activateSelected() {
        if (busy || selectedIndex < 0 || selectedIndex >= wifiNetworks.length) return
        var row = wifiNetworks[selectedIndex]
        if (!row) return
        if (focusSection === "forget" && rowCanForget(row)) return forgetNetwork(row)
        if (row.active) return disconnectNetwork(row.ssid, row.interfaceName)
        if (requiresCredentials(row.security) && !row.known) {
            selectedSsid = row.ssid
            selectedInterface = row.interfaceName || ""
            selectedSecurity = row.security || ""
            passwordText = ""
            identityText = ""
            credentials.open()
        } else connectNetwork(row.ssid, row.interfaceName || "", "")
    }


    function activateDns() {
        var provider = dnsProviders[Math.max(0, Math.min(dnsProviders.length - 1, dnsIndex))]
        if (provider === "Custom") customDns.open()
        else setDns(provider, "")
    }
    function handleKey(event) {
        if (credentials.visible) return
        if (event.key === Qt.Key_Escape) { root.focus = false; event.accepted = true; return }
        if (event.key === Qt.Key_R) { refreshNetworks(); event.accepted = true; return }
        if (event.key === Qt.Key_W) { toggleWifi(); event.accepted = true; return }
        var down = event.key === Qt.Key_Down || event.key === Qt.Key_J
        var up = event.key === Qt.Key_Up || event.key === Qt.Key_K
        if (down || up) {
            if (focusSection === "dns") {
                dnsIndex = Math.max(0, Math.min(dnsProviders.length - 1, dnsIndex + (down ? 1 : -1)))
            } else if (focusSection === "forget" && up) {
                focusSection = "wifi"
            } else {
                if (!wifiNetworks.length) return
                selectedIndex = Math.max(0, Math.min(wifiNetworks.length - 1, selectedIndex + (down ? 1 : -1)))
                focusSection = "wifi"
            }
            event.accepted = true
        } else if (event.key === Qt.Key_Left || event.key === Qt.Key_Right) {
            if (focusSection === "wifi" && event.key === Qt.Key_Right
                    && selectedIndex >= 0 && rowCanForget(wifiNetworks[selectedIndex]))
                focusSection = "forget"
            else if (focusSection === "forget" && event.key === Qt.Key_Left)
                focusSection = "wifi"
            else if (focusSection === "dns")
                dnsIndex = Math.max(0, Math.min(dnsProviders.length - 1, dnsIndex + (event.key === Qt.Key_Right ? 1 : -1)))
            else
                focusSection = focusSection === "wifi" ? "dns" : "wifi"
            event.accepted = true
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
            if (focusSection === "wifi" || focusSection === "forget") activateSelected()
            else if (focusSection === "dns") activateDns()
            event.accepted = true
        }
    }

    Keys.onPressed: (event) => root.handleKey(event)

    property bool speedRunning: speedPhase !== ""
    property string speedPhase: ""
    property string downloadMbps: "—"
    property string uploadMbps: "—"
    property var scanQueue: []
    property string scanInterface: ""

    Process {
        id: details
        command: [root.helperDir + "network-status.sh"]
        stdout: StdioCollector { onStreamFinished: root.updateDetails(text) }
    }
    Timer { interval: 1500; running: root.visible; repeat: true; triggeredOnStart: true; onTriggered: if (!details.running) details.running = true }

    Process {
        id: adapters
        command: ["nmcli", "-t", "-e", "no", "-f", "DEVICE,TYPE", "device", "status"]
        stdout: StdioCollector { onStreamFinished: {
            var interfaces = []
            for (const line of text.trim().split("\n")) {
                var fields = line.split(":")
                if (fields.length >= 2 && fields[1] === "wifi") interfaces.push(fields[0])
            }
            root.scanInterfaces = interfaces
            root.scanQueue = interfaces
        } }
        onExited: { known.running = true; root.startNextScan() }
    }
    Process {
        id: known
        command: ["nmcli", "-t", "-e", "no", "-f", "NAME,TYPE", "connection", "show"]
        stdout: StdioCollector { onStreamFinished: root.updateKnown(text) }
    }
    Process {
        id: scan
        stdout: StdioCollector { onStreamFinished: root.updateScan(text) }
        onExited: root.startNextScan()
    }

    Process {
        id: action
        stdout: StdioCollector { onStreamFinished: { action.actionOutput = text } }
        stderr: StdioCollector { onStreamFinished: { action.actionOutput = text } }
        property string actionOutput: ""
        onExited: root.actionFinished(exitCode, actionOutput)
    }

    Process {
        id: enterprise
        property string secret: ""
        stdinEnabled: true
        onStarted: { write(secret + "\n"); secret = "" }
        onExited: root.actionFinished(exitCode, "")
    }
    Timer {
        id: actionTimeout
        interval: 30000
        onTriggered: {
            if (!root.actionKind) return
            if (action.running) action.running = false
            if (enterprise.running) enterprise.running = false
            root.failureSsid = root.actionSsid
            root.failureReason = "Timed out"
            root.actionSsid = ""
            root.actionKind = ""
            root.refreshNetworks()
        }
    }
    Timer { id: refreshDelay; interval: 1000; onTriggered: root.refreshNetworks() }

    Process {
        id: dnsStatus
        stdout: StdioCollector {
            onStreamFinished: {
                var value = text.trim()
                if (!value) return
                root.dnsProvider = value
                var index = root.dnsProviders.indexOf(value)
                if (index >= 0) root.dnsIndex = index
            }
        }
    }
    Process {
        id: dnsAction
        stdout: StdioCollector { onStreamFinished: if (text.trim()) root.dnsProvider = text.trim() }
        stderr: StdioCollector { onStreamFinished: if (text.trim()) root.feedback = text.trim() }
        onExited: { root.pendingDnsProvider = ""; dnsStatus.running = true }
    }
    Timer { interval: 5000; running: root.visible; repeat: true; triggeredOnStart: true; onTriggered: if (!dnsStatus.running && !dnsAction.running) dnsStatus.running = true }

    Process {
        id: bandStatus
        command: [root.helperDir + "network-band.sh"]
        stdout: StdioCollector { onStreamFinished: {
            var state = Model.parseBandStatus(text)
            root.bandCurrent = state.band
            root.bandSelected = state.selected
            root.bandAvailable = state.available
        } }
    }
    Process {
        id: bandAction
        stderr: StdioCollector { onStreamFinished: if (text.trim()) root.feedback = text.trim() }
        onExited: { root.pendingBand = ""; bandStatus.running = true; details.running = true }
    }
    Timer { interval: 4000; running: root.visible; repeat: true; triggeredOnStart: true; onTriggered: if (!bandStatus.running && info.type === "wifi") bandStatus.running = true }

    Process {
        id: speed
        stdout: SplitParser { onRead: line => { var value = Number(line); if (isFinite(value)) root.speedPhase === "down" ? root.downloadMbps = line : root.uploadMbps = line } }
        stderr: StdioCollector { onStreamFinished: if (text.trim()) root.feedback = text.trim() }
        onExited: root.nextSpeedPhase()
    }
    Process {
        id: radio
        command: ["nmcli", "radio", "wifi"]
        stdout: StdioCollector { onStreamFinished: { var value = text.trim().toLowerCase(); if (value) root.wifiEnabled = value === "enabled" } }
    }
    Process { id: radioAction; onExited: { radio.running = true; refreshDelay.restart() } }

    ColumnLayout {
        id: panelColumn
        anchors.fill: parent
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            Text { text: root.currentIcon; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: 27 }
            ColumnLayout {
                Layout.fillWidth: true; spacing: 1
                Text { text: root.info.type === "wifi" ? (root.info.ssid || "Wi-Fi") : root.info.type === "ethernet" ? "Ethernet" : "Disconnected"; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: 15; font.bold: true; elide: Text.ElideRight; Layout.fillWidth: true }
                Text { text: root.info.iface ? (root.info.type === "wifi" ? "CONNECTED · " + (Model.headerDetail(root.info) || "WI-FI") : "CONNECTED") : "NOT CONNECTED"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 9; font.bold: true; font.letterSpacing: 1.1 }
            }
            ThemeButton { visible: root.info.type === "wifi" || root.wifiAvailable; text: root.wifiEnabled ? "Wi-Fi off" : "Wi-Fi on"; enabled: !radioAction.running; onClicked: root.toggleWifi() }
        }

        GridLayout {
            visible: !!root.info.iface
            Layout.fillWidth: true; columns: 4; columnSpacing: 12; rowSpacing: 7
            component MetricLabel: Text { color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 10 }
            component MetricValue: Text { color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: 10; horizontalAlignment: Text.AlignRight }
            MetricLabel { text: "Ping" } MetricValue { text: root.formatPing(root.internetPingLatency); Layout.fillWidth: true }
            MetricLabel { text: "Packet Loss" } MetricValue { text: root.formatLoss(root.internetPingPacketLoss); color: root.internetPingPacketLoss ? Theme.danger : Theme.foreground; Layout.fillWidth: true }
            MetricLabel { text: "Receiving" } MetricValue { text: root.hasTransferStats ? root.formatRate(root.downloadRate) : "--"; Layout.fillWidth: true }
            MetricLabel { text: "Sending" } MetricValue { text: root.hasTransferStats ? root.formatRate(root.uploadRate) : "--"; Layout.fillWidth: true }
            MetricLabel { text: "Downloaded" } MetricValue { text: root.hasTransferStats ? root.formatBytes(root.info.rx_bytes) : "--"; Layout.fillWidth: true }
            MetricLabel { text: "Uploaded" } MetricValue { text: root.hasTransferStats ? root.formatBytes(root.info.tx_bytes) : "--"; Layout.fillWidth: true }
            MetricLabel { text: "IP Address" } MetricValue { text: root.info.ip || "--"; Layout.fillWidth: true }
            MetricLabel { text: "Gateway" } MetricValue { text: root.info.gateway || "--"; Layout.fillWidth: true }
        }

        Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Theme.border }
        RowLayout {
            Layout.fillWidth: true
            Text { text: "SPEED TEST"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 9; font.bold: true; Layout.fillWidth: true }
            ThemeButton { text: root.speedRunning ? "Running…" : "Run"; enabled: !root.speedRunning && !!root.info.iface; onClicked: root.runSpeedTest() }
        }
        GridLayout {
            visible: root.downloadMbps !== "—" || root.uploadMbps !== "—"
            Layout.fillWidth: true; columns: 4; columnSpacing: 12
            MetricLabel { text: "Download" } MetricValue { text: root.downloadMbps === "…" ? root.downloadMbps : root.downloadMbps + " Mbps"; Layout.fillWidth: true }
            MetricLabel { text: "Upload" } MetricValue { text: root.uploadMbps === "…" ? root.uploadMbps : root.uploadMbps + " Mbps"; Layout.fillWidth: true }
        }

        Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Theme.border }
        Text { text: "WI-FI BAND"; visible: root.canSelectBand; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 9; font.bold: true }
        RowLayout {
            visible: root.canSelectBand; Layout.fillWidth: true; spacing: 6
            Repeater {
                model: ["auto"].concat(root.bandAvailable)
                delegate: ThemeButton {
                    required property string modelData
                    text: Model.bandLabel(modelData)
                    selected: root.bandEffective === modelData
                    enabled: !root.bandBusy
                    Layout.fillWidth: true
                    onClicked: root.setBand(modelData)
                }
            }
        }

        Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Theme.border }
        Text { text: "DNS PROVIDER"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 9; font.bold: true }
        RowLayout {
            Layout.fillWidth: true; spacing: 6
            Repeater {
                model: root.dnsProviders
                delegate: ThemeButton {
                    required property string modelData
                    required property int index
                    text: modelData
                    selected: root.dnsProvider === modelData || (root.focusSection === "dns" && root.dnsIndex === index)
                    Layout.fillWidth: true
                    onClicked: { root.dnsIndex = index; modelData === "Custom" ? customDns.open() : root.setDns(modelData, "") }
                }
            }
        }

        Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Theme.border }
        RowLayout {
            Layout.fillWidth: true
            Text { text: root.scanning ? "SCANNING WI-FI…" : "WI-FI NETWORKS"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 9; font.bold: true; Layout.fillWidth: true }
            ThemeButton { text: root.scanning ? "Scanning…" : "Refresh"; enabled: !root.scanning; onClicked: root.refreshNetworks() }
        }
        ListView {
            id: networkList
            Layout.fillWidth: true; Layout.fillHeight: true; implicitHeight: Math.min(contentHeight, 260); clip: true; spacing: 2
            model: root.wifiNetworks
            currentIndex: root.selectedIndex
            onCurrentIndexChanged: if (currentIndex >= 0) positionViewAtIndex(currentIndex, ListView.Contain)
            delegate: ActionRow {
                required property var modelData
                required property int index
                width: networkList.width
                implicitHeight: modelData && (modelData.known || modelData.active || modelData.security) ? 48 : 40
                title: modelData.ssid || "Hidden network"
                subtitle: {
                    var state = modelData.active ? "connected" : root.actionSsid === modelData.ssid && root.actionKind ? root.actionKind + "ing…" : root.failureSsid === modelData.ssid ? root.failureReason : modelData.known ? "remembered" : "nearby"
                    return (modelData.interfaceName || "Wi-Fi") + " · " + state
                }
                icon: Model.wifiIconFor(modelData.signal)
                trailing: root.rowCanForget(modelData) ? "Forget" : modelData.active ? "Disconnect" : root.requiresCredentials(modelData.security) ? "Connect · password" : "Connect"
                selected: root.selectedIndex === index
                onClicked: { root.selectedIndex = index; root.focusSection = "wifi"; root.activateSelected() }
                TapHandler { acceptedButtons: Qt.RightButton; onTapped: root.forgetNetwork(modelData) }
            }
        }
        Text { visible: root.feedback.length > 0; text: root.feedback; color: root.failureReason.length ? Theme.danger : Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 9; elide: Text.ElideRight; Layout.fillWidth: true }
    }

    ThemeDialog {
        id: credentials
        anchors.centerIn: parent
        title: "Connect to " + root.selectedSsid
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        onOpened: root.selectedEnterprise ? identity.forceActiveFocus() : password.forceActiveFocus()
        onAccepted: root.submitCredentials()
        ColumnLayout {
            spacing: 6
            ThemeTextField { id: identity; visible: root.selectedEnterprise; width: 270; placeholderText: "Identity (user@domain)"; text: root.identityText; onTextChanged: root.identityText = text; onAccepted: password.forceActiveFocus() }
            ThemeTextField { id: password; width: 270; placeholderText: "Password"; echoMode: TextInput.Password; onTextChanged: root.passwordText = text; onAccepted: credentials.accept() }
        }
    }
    ThemeDialog {
        id: customDns
        anchors.centerIn: parent
        title: "Custom DNS servers"
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        onOpened: dnsServers.forceActiveFocus()
        onAccepted: root.setDns("Custom", dnsServers.text)
        ThemeTextField { id: dnsServers; width: 280; placeholderText: "1.1.1.1 2606:4700:4700::1111"; onAccepted: customDns.accept() }
    }

    Component.onCompleted: {
        root.forceActiveFocus()
        root.refreshNetworks()
        radio.running = true
        dnsStatus.running = true
        if (info.type === "wifi") bandStatus.running = true
    }
}
