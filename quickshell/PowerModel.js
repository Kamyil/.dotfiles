function clampIndex(index, length) {
    if (length <= 0) return 0
    return Math.max(0, Math.min(length - 1, Number(index) || 0))
}

function selectProfileIndex(index, delta, profiles) {
    var values = Array.isArray(profiles) ? profiles : []
    if (values.length === 0) return 0
    return clampIndex((Number(index) || 0) + (Number(delta) || 0), values.length)
}

// powerprofilesctl list is intentionally parsed here rather than in QML. The
// command has changed indentation over time, but profile names remain the
// first token on lines ending in a colon.
function parseProfiles(raw, previousIndex) {
    var lines = String(raw || "").split("\n")
    var list = []
    var active = ""
    for (var i = 0; i < lines.length; i++) {
        var line = lines[i].trim()
        if (!line || line.indexOf("CpuDriver:") === 0 || line.indexOf("PlatformDriver:") === 0 || line.indexOf("Degraded:") === 0)
            continue
        var marked = line.charAt(0) === "*"
        if (marked) line = line.substring(1).trim()
        if (!line.endsWith(":")) continue
        var name = line.substring(0, line.length - 1).trim()
        if (!name || name.indexOf(" ") >= 0 || list.indexOf(name) >= 0) continue
        list.push(name)
        if (marked) active = name
    }
    var nextIndex = clampIndex(previousIndex, list.length)
    if (active) {
        var activeIndex = list.indexOf(active)
        if (activeIndex >= 0) nextIndex = activeIndex
    }
    return { profiles: list, activeProfile: active, profileIndex: nextIndex }
}

function profileIcon(name) {
    if (name === "power-saver") return "󰌪"
    if (name === "balanced") return "󰊚"
    if (name === "performance") return "󰓅"
    return "󰂄"
}

function batteryFraction(device) {
    if (!device || !device.isPresent) return 0
    return Math.max(0, Math.min(1, Number(device.percentage) || 0))
}

function chargeThresholdActive(device, onBattery, states) {
    var d = device || {}
    var s = states || {}
    if (!(d && d.isPresent && !onBattery)) return false
    var fraction = batteryFraction(d)
    if (d.state === s.Discharging) return false
    if (d.state === s.PendingCharge) return true
    if (d.state === s.FullyCharged && fraction < 0.99) return true
    if (d.state !== s.Charging || fraction >= 0.99) return false
    return Number(d.changeRate || 0) <= 0.2 || Number(d.timeToFull || 0) >= 8 * 60 * 60
}

function batteryIcon(device, onBattery, states) {
    var d = device || {}
    if (!d.isPresent) return "󰂑"
    var chargingIcons = ["󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"]
    var defaultIcons = ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
    var index = Math.max(0, Math.min(9, Math.floor(batteryFraction(d) * 10)))
    var threshold = chargeThresholdActive(d, onBattery, states)
    if (threshold) return defaultIcons[index]
    if (d.state === states.FullyCharged) return "󰂅"
    return onBattery ? defaultIcons[index] : chargingIcons[index]
}

function modeLabel(device, onBattery, states) {
    var d = device || {}
    if (!d.isPresent) return "Unavailable"
    if (chargeThresholdActive(d, onBattery, states)) return "Charge limit"
    if (onBattery) return "On battery"
    if (batteryFraction(d) >= 0.99 || d.state === states.FullyCharged) return "Fully charged"
    return "Charging"
}

function duration(seconds) {
    var value = Number(seconds) || 0
    if (value <= 0) return ""
    var hours = Math.floor(value / 3600)
    var minutes = Math.round((value % 3600) / 60)
    if (minutes >= 60) { hours += 1; minutes = 0 }
    return (hours > 0 ? hours + "h " : "") + minutes + "m"
}

function watts(value) {
    var number = Number(value)
    return isFinite(number) && number > 0 ? number.toFixed(1) + " W" : ""
}

function energy(value) {
    var number = Number(value)
    return isFinite(number) && number > 0 ? number.toFixed(1) + " Wh" : ""
}

if (typeof module !== "undefined") {
    module.exports = {
        clampIndex: clampIndex,
        selectProfileIndex: selectProfileIndex,
        parseProfiles: parseProfiles,
        profileIcon: profileIcon,
        batteryFraction: batteryFraction,
        chargeThresholdActive: chargeThresholdActive,
        batteryIcon: batteryIcon,
        modeLabel: modeLabel,
        duration: duration,
        watts: watts,
        energy: energy
    }
}
