function toArray(values) {
    if (!values) return []
    if (Array.isArray(values)) return values.slice()
    var length = Number(values.length || 0)
    if (!isFinite(length) || length <= 0) return []
    var result = []
    for (var i = 0; i < length; i++) result.push(values[i])
    return result
}

function deviceLabel(device) {
    if (!device) return ""
    return String(device.deviceName || device.name || "").trim()
}

function isUuidLike(value) {
    var text = String(value || "").trim()
    return text !== "" && (/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(text)
        || /^[0-9a-f]{32}$/i.test(text)
        || /^0x[0-9a-f]{4,32}$/i.test(text)
        || /^0000[0-9a-f]{4}-0000-1000-8000-00805f9b34fb$/i.test(text))
}

function isAddressLike(value) {
    return /^([0-9a-f]{2}[:-]){5}[0-9a-f]{2}$/i.test(String(value || "").trim())
}

function hasHumanName(device) {
    var label = deviceLabel(device)
    return label !== "" && !isUuidLike(label) && !isAddressLike(label)
}

function sortedByLabel(devices) {
    var result = toArray(devices)
    result.sort(function(a, b) { return deviceLabel(a).localeCompare(deviceLabel(b)) })
    return result
}

function deviceLists(devices) {
    var values = toArray(devices)
    var connected = []
    var known = []
    var discovered = []
    for (var i = 0; i < values.length; i++) {
        var device = values[i]
        if (!device || !hasHumanName(device)) continue
        if (device.connected) connected.push(device)
        else if (device.paired || device.bonded || device.trusted) known.push(device)
        else discovered.push(device)
    }
    return {
        connected: sortedByLabel(connected),
        known: sortedByLabel(known),
        discovered: sortedByLabel(discovered)
    }
}

function cloneMap(map) {
    var result = ({})
    for (var key in map || {}) result[key] = map[key]
    return result
}

function pendingAction(actions, address) {
    return address && actions && actions[address] ? actions[address] : ""
}

function withPendingAction(actions, address, action) {
    var result = cloneMap(actions)
    if (!address) return result
    if (action) result[address] = action
    else delete result[address]
    return result
}

function bluetoothSinkMatchesDevice(node, device) {
    if (!node || !node.isSink || node.isStream || !device) return false
    var address = String(device.address || "").toLowerCase().replace(/[^0-9a-f]/g, "")
    var props = node.properties || {}
    var text = [node.name, node.description, node.nickname, node.nick,
        props["node.name"], props["node.description"], props["node.nick"],
        props["device.name"], props["device.description"], props["device.product.name"],
        props["device.alias"], props["device.string"], props["api.bluez5.address"],
        props["bluez5.address"], props["media.name"]].join(" ").toLowerCase()
    if (address && text.replace(/[^0-9a-f]/g, "").indexOf(address) !== -1) return true
    var label = deviceLabel(device).toLowerCase()
    return label !== "" && text.indexOf(label) !== -1
}

function deviceRow(device) {
    if (!device) return null
    return {
        address: device.address || "",
        name: device.name || "",
        deviceName: device.deviceName || "",
        connected: !!device.connected,
        paired: !!device.paired,
        bonded: !!device.bonded,
        trusted: !!device.trusted,
        pairing: !!device.pairing,
        batteryAvailable: !!device.batteryAvailable,
        battery: device.battery !== undefined ? device.battery : 0,
        state: device.state !== undefined ? device.state : -1
    }
}

if (typeof module !== "undefined") module.exports = {
    toArray: toArray,
    deviceLabel: deviceLabel,
    isUuidLike: isUuidLike,
    isAddressLike: isAddressLike,
    hasHumanName: hasHumanName,
    sortedByLabel: sortedByLabel,
    deviceLists: deviceLists,
    cloneMap: cloneMap,
    pendingAction: pendingAction,
    withPendingAction: withPendingAction,
    bluetoothSinkMatchesDevice: bluetoothSinkMatchesDevice,
    deviceRow: deviceRow
}
