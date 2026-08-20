import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth
import Quickshell.Services.Pipewire
import "."
import "BluetoothModel.js" as Model

FocusScope {
    id: root
    implicitWidth: 340
    implicitHeight: Math.min(700, panelColumn.implicitHeight)
    focus: true
    activeFocusOnTab: true

    readonly property var adapters: Bluetooth.adapters && Bluetooth.adapters.values ? Bluetooth.adapters.values : []
    readonly property var adapter: Bluetooth.defaultAdapter || (adapters.length > 0 ? adapters[0] : null)
    readonly property bool hasAdapters: adapters.length > 0
    readonly property bool powered: {
        for (const item of root.adapters) if (item && item.enabled) return true
        return false
    }
    readonly property bool discovering: {
        for (const item of root.adapters) if (item && item.discovering) return true
        return false
    }
    readonly property var devices: Bluetooth.devices && Bluetooth.devices.values
        ? Bluetooth.devices.values : root.adapterDevices()
    readonly property var deviceGroups: Model.deviceLists(devices)
    readonly property var connectedDevices: deviceGroups.connected || []
    readonly property var knownDevices: deviceGroups.known || []
    readonly property var discoveredDevices: deviceGroups.discovered || []
    readonly property var connectedRows: rowsFor(connectedDevices)
    readonly property var knownRows: rowsFor(knownDevices)
    readonly property var discoveredRows: rowsFor(discoveredDevices)
    readonly property var audioSinks: (Pipewire.nodes ? Pipewire.nodes.values : []).filter(node => node && node.isSink && !node.isStream)
    property var pendingActions: ({})
    property bool owesDiscoveryStop: false
    property string pairAddress: ""
    property string focusSection: "header"
    property int selectedIndex: 0
    property bool cursorActive: false
    property string focusedDeviceAddress: ""
    property var pendingAudioOutputDevice: null
    property int pendingAudioOutputAttempts: 0

    function adapterDevices() {
        var result = []
        var seen = ({})
        for (const item of root.adapters) {
            var values = item && item.devices ? item.devices.values : []
            for (const device of Model.toArray(values)) {
                if (!device || !device.address || seen[device.address]) continue
                seen[device.address] = true
                result.push(device)
            }
        }
        return result
    }

    function deviceLabel(device) { return Model.deviceLabel(device) }

    function rowsFor(list) {
        var rows = []
        for (const device of list || []) {
            var row = Model.deviceRow(device)
            if (row) rows.push(row)
        }
        return rows
    }
    function deviceForAddress(address) {
        if (!address) return null
        for (const device of root.devices) if (device && device.address === address) return device
        return null
    }

    function deviceAt(section, index) {
        var list = section === "connected" ? root.connectedDevices
            : section === "known" ? root.knownDevices : root.discoveredDevices
        return index >= 0 && index < list.length ? list[index] : null
    }

    function sectionCount(section) {
        return section === "connected" ? connectedDevices.length
            : section === "known" ? knownDevices.length
            : section === "discovered" ? discoveredDevices.length : 0
    }

    readonly property var visibleSections: {
        var sections = []
        if (connectedDevices.length > 0) sections.push("connected")
        if (knownDevices.length > 0) sections.push("known")
        if (discovering && discoveredDevices.length > 0) sections.push("discovered")
        return sections
    }

    function setPowered(value) {
        for (const item of root.adapters) if (item) item.enabled = value
    }

    function setDiscovery(value) {
        for (const item of root.adapters) {
            if (item && item.enabled) item.discovering = value
        }
        root.owesDiscoveryStop = value
        if (value) discoveryStop.restart()
        else discoveryStop.stop()
    }

    function cloneMap(map) { return Model.cloneMap(map) }
    function pendingAction(address) { return Model.pendingAction(pendingActions, address) }

    function setPendingAction(address, action) {
        if (!address) return
        pendingActions = Model.withPendingAction(pendingActions, address, action)
        if (action) pendingTimeout.restart()
    }

    function syncPendingActions() {
        if (root.owesDiscoveryStop && !root.discovering) root.owesDiscoveryStop = false
        var next = cloneMap(pendingActions)
        var changed = false
        for (const address in next) {
            var action = next[address]
            var device = deviceForAddress(address)
            var done = action === "connecting" && device && device.connected
                || action === "disconnecting" && device && !device.connected
                || action === "forgetting" && (!device || (!device.paired && !device.bonded && !device.trusted))
            if (done) {
                if (action === "connecting") scheduleAudioOutputSwitch(device)
                delete next[address]
                changed = true
            }
        }
        if (changed) pendingActions = next
    }

    function connectDevice(device) {
        if (!device || !device.address || device.connected || pendingAction(device.address) || pairProcess.running) return
        setPendingAction(device.address, "connecting")
        if (device.paired || device.bonded || device.trusted) {
            device.trusted = true
            if (device.connect) device.connect()
            else Quickshell.execDetached(["bluetoothctl", "connect", device.address])
            return
        }
        root.setDiscovery(false)
        pairAddress = device.address
        pairProcess.command = ["bluetoothctl", "--agent", "NoInputNoOutput", "--timeout", "30", "pair", device.address]
        pairProcess.running = true
    }

    function disconnectDevice(device) {
        if (!device || !device.address || !device.connected || pendingAction(device.address)) return
        setPendingAction(device.address, "disconnecting")
        if (device.disconnect) device.disconnect()
        else Quickshell.execDetached(["bluetoothctl", "disconnect", device.address])
    }

    function forgetDevice(device) {
        if (!device || !device.address || pendingAction(device.address)) return
        setPendingAction(device.address, "forgetting")
        if (device.connected && device.disconnect) device.disconnect()
        if (device.forget) device.forget()
        else Quickshell.execDetached(["bluetoothctl", "remove", device.address])
    }

    function activateDevice(device) {
        if (!device) return
        if (device.connected) disconnectDevice(device)
        else connectDevice(device)
    }

    function forgetOrDisconnect(device) {
        if (!device) return
        if (device.connected) disconnectDevice(device)
        else forgetDevice(device)
    }

    function moveCursor(delta) {
        var sections = visibleSections
        if (focusSection === "header") {
            if (delta > 0 && sections.length > 0) {
                focusSection = sections[0]; selectedIndex = 0
            }
            return
        }
        if (sections.length === 0) { focusSection = "header"; selectedIndex = 0; return }
        var sectionIndex = sections.indexOf(focusSection)
        if (sectionIndex < 0) { focusSection = sections[0]; selectedIndex = 0; return }
        var max = sectionCount(focusSection) - 1
        if (delta > 0) {
            if (selectedIndex < max) selectedIndex++
            else if (sectionIndex < sections.length - 1) { focusSection = sections[sectionIndex + 1]; selectedIndex = 0 }
        } else if (selectedIndex > 0) selectedIndex--
        else if (sectionIndex > 0) { focusSection = sections[sectionIndex - 1]; selectedIndex = sectionCount(focusSection) - 1 }
        else { focusSection = "header"; selectedIndex = 0 }
    }

    function activateCursor() {
        if (focusSection === "header") { setPowered(!powered); return }
        activateDevice(deviceAt(focusSection, selectedIndex))
    }

    function deleteSelected() {
        if (focusSection === "known" || focusSection === "connected") forgetDevice(deviceAt(focusSection, selectedIndex))
    }

    function handleKey(event) {
        var down = event.key === Qt.Key_Down || event.key === Qt.Key_J
        var up = event.key === Qt.Key_Up || event.key === Qt.Key_K
        if (down || up) {
            cursorActive = true
            moveCursor(down ? 1 : -1)
            event.accepted = true
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
            if (cursorActive) activateCursor()
            event.accepted = true
        } else if (event.key === Qt.Key_Delete || event.key === Qt.Key_Backspace) {
            if (cursorActive) deleteSelected()
            event.accepted = true
        } else if (event.key === Qt.Key_B) {
            setPowered(!powered)
            event.accepted = true
        }
    }

    function bluetoothAudioSink(device) {
        for (const sink of root.audioSinks) if (Model.bluetoothSinkMatchesDevice(sink, device)) return sink
        return null
    }

    function switchPendingAudioOutput() {
        if (!pendingAudioOutputDevice) return
        var sink = bluetoothAudioSink(pendingAudioOutputDevice)
        if (sink) {
            Pipewire.preferredDefaultAudioSink = sink
            pendingAudioOutputDevice = null
            audioSwitchTimer.stop()
            return
        }
        pendingAudioOutputAttempts++
        if (pendingAudioOutputAttempts >= 10) pendingAudioOutputDevice = null
        else audioSwitchTimer.restart()
    }

    function scheduleAudioOutputSwitch(device) {
        pendingAudioOutputDevice = {
            address: device && device.address ? device.address : "",
            name: device && device.name ? device.name : "",
            deviceName: device && device.deviceName ? device.deviceName : ""
        }
        pendingAudioOutputAttempts = 0
        audioSwitchTimer.restart()
    }

    PwObjectTracker { objects: root.audioSinks }

    Process {
        id: pairProcess
        onExited: {
            pairConnectRetry.attempts = 0
            pairConnectRetry.restart()
        }
    }

    Timer {
        id: pairConnectRetry
        interval: 500
        repeat: true
        property int attempts: 0
        onTriggered: {
            attempts++
            var address = root.pairAddress
            var device = root.deviceForAddress(address)
            if (device && (device.paired || device.bonded || device.trusted)) {
                device.trusted = true
                if (device.connect) device.connect()
                root.pairAddress = ""
                stop()
            } else if (!address || attempts >= 20) {
                root.setPendingAction(address, "")
                root.pairAddress = ""
                stop()
            }
        }
    }

    Timer {
        id: pendingTimeout
        interval: 20000
        onTriggered: root.pendingActions = ({})
    }

    Timer {
        id: pendingSync
        interval: 350
        repeat: true
        running: true
        onTriggered: root.syncPendingActions()
    }

    Timer {
        id: discoveryStop
        interval: 15000
        onTriggered: root.setDiscovery(false)
    }

    Timer {
        id: audioSwitchTimer
        interval: 500
        onTriggered: root.switchPendingAudioOutput()
    }

    Component.onCompleted: {
        root.forceActiveFocus()
        if (root.powered) {
            if (root.discovering) root.owesDiscoveryStop = true
            else root.setDiscovery(true)
        }
    }

    Component.onDestruction: {
        if (!root.owesDiscoveryStop) return
        for (const item of root.adapters) if (item && item.discovering) item.discovering = false
        root.owesDiscoveryStop = false
    }

    onVisibleChanged: if (visible && !activeFocus) forceActiveFocus()

    Keys.onPressed: event => root.handleKey(event)

    ColumnLayout {
        id: panelColumn
        anchors.fill: parent
        spacing: 10

        Heading {
            title: "Bluetooth"
            subtitle: !root.hasAdapters ? "No Bluetooth adapters found"
                : root.discovering ? "Looking for nearby devices…"
                : root.powered ? "Choose a device to pair or connect" : "Bluetooth is off"
        }

        SwitchRow {
            id: powerRow
            title: "Bluetooth"
            subtitle: root.adapters.length > 1 ? root.adapters.length + " adapters"
                : root.adapter ? (root.adapter.name || "Default adapter") : root.hasAdapters ? "Bluetooth adapter" : "No adapter"
            checked: root.powered
            onToggled: root.setPowered(checked)
        }

        ActionRow {
            title: root.discovering ? "Stop discovery" : "Find devices"
            subtitle: root.powered ? "Search for nearby Bluetooth devices" : "Turn Bluetooth on to scan"
            icon: root.discovering ? "󰂰" : ""
            trailing: root.discovering ? "Stop" : "Find"
            selected: root.focusSection === "header" && root.cursorActive
            onClicked: {
                root.cursorActive = true
                root.focusSection = "header"
                root.setDiscovery(!root.discovering)
            }
        }

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            contentHeight: deviceColumn.implicitHeight

            ColumnLayout {
                id: deviceColumn
                width: parent.width
                spacing: 6

                Text {
                    visible: root.connectedDevices.length > 0
                    text: "CONNECTED"
                    color: Theme.muted
                    font.family: Theme.fontFamily
                    font.pixelSize: 9
                    font.weight: Font.DemiBold
                    Layout.fillWidth: true
                }
                Repeater {
                    model: root.connectedRows
                    delegate: DeviceRow {
                        required property var modelData
                        required property int index
                        rowData: modelData
                        section: "connected"
                        rowIndex: index
                    }
                }

                Text {
                    visible: root.knownDevices.length > 0
                    text: "PAIRED"
                    color: Theme.muted
                    font.family: Theme.fontFamily
                    font.pixelSize: 9
                    font.weight: Font.DemiBold
                    Layout.fillWidth: true
                }
                Repeater {
                    model: root.knownRows
                    delegate: DeviceRow {
                        required property var modelData
                        required property int index
                        rowData: modelData
                        section: "known"
                        rowIndex: index
                    }
                }

                Text {
                    visible: root.discovering && root.discoveredDevices.length > 0
                    text: "AVAILABLE"
                    color: Theme.muted
                    font.family: Theme.fontFamily
                    font.pixelSize: 9
                    font.weight: Font.DemiBold
                    Layout.fillWidth: true
                }
                Repeater {
                    model: root.discoveredRows
                    delegate: DeviceRow {
                        required property var modelData
                        required property int index
                        rowData: modelData
                        section: "discovered"
                        rowIndex: index
                    }
                }

                Text {
                    visible: root.connectedDevices.length === 0 && root.knownDevices.length === 0 && root.discoveredDevices.length === 0
                    text: !root.hasAdapters ? "No Bluetooth adapter"
                        : !root.powered ? "Turn Bluetooth on to see nearby and remembered devices."
                        : root.discovering ? "Scanning for devices…" : "No devices found"
                    color: Theme.muted
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }
        }
    }

    component DeviceRow: ActionRow {
        id: row
        required property var rowData
        required property string section
        required property int rowIndex
        readonly property string action: root.pendingAction(rowData ? rowData.address : "")
        readonly property bool isConnected: !!(rowData && rowData.connected)
        readonly property bool isDiscovered: section === "discovered"
        Layout.fillWidth: true
        title: root.deviceLabel(rowData) || "Bluetooth device"
        subtitle: action === "forgetting" ? "Forgetting…"
            : action === "disconnecting" ? "Disconnecting…"
            : action === "connecting" || (rowData && rowData.pairing) ? "Connecting…"
            : isConnected && rowData.batteryAvailable ? "Connected · " + Math.round(rowData.battery * 100) + "% battery"
            : isConnected ? "Connected"
            : isDiscovered ? "Nearby device"
            : "Remembered device"
        icon: isConnected ? "󰂱" : "󰂯"
        trailing: action !== "" ? (action === "forgetting" ? "Forgetting…" : action === "disconnecting" ? "Disconnecting…" : "Connecting…")
            : isConnected ? "Disconnect" : isDiscovered ? "Pair & connect" : "Connect"
        selected: root.cursorActive && root.focusSection === section && root.selectedIndex === rowIndex
        onClicked: {
            root.cursorActive = true
            root.focusSection = section
            root.selectedIndex = rowIndex
            root.activateDevice(root.deviceForAddress(rowData ? rowData.address : ""))
        }
        TapHandler {
            acceptedButtons: Qt.RightButton
            onTapped: {
                var device = root.deviceForAddress(row.rowData ? row.rowData.address : "")
                root.forgetOrDisconnect(device)
            }
        }
    }
}
