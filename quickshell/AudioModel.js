function isPlaybackStream(node) {
    if (!node || !node.isStream) return false
    if (node.isSink === true) return true
    var mediaClass = String(node.type || "")
    return mediaClass.indexOf("Stream/Output/Audio") !== -1
        || mediaClass.indexOf("AudioOutStream") !== -1
        || mediaClass.indexOf("Output") !== -1
}

function isAudioSource(node) {
    if (!node) return false
    if (node.audio) return true
    var mediaClass = String(node.type || "")
    return mediaClass.indexOf("Audio/Source") !== -1
        || mediaClass.indexOf("AudioSource") !== -1
        || mediaClass.indexOf("Source") !== -1
}

function listSnapshot(list) {
    return list && list.slice ? list.slice() : []
}

function nodeProps(node) {
    return node && node.ready && node.properties ? node.properties : {}
}

function friendlyDeviceLabel(text) {
    var label = String(text || "").trim()
    label = label.replace(/^sof-soundwire\s+/i, "")
    label = label.replace(/^built-?in audio\s+/i, "")
    label = label.replace(/\s+Output$/i, "")
    label = label.replace(/\s+Input$/i, "")
    label = label.replace(/\bMicrophones\b/g, "Microphone")
    return label
}

function nodeLabel(node) {
    if (!node) return "Unknown"
    var p = nodeProps(node)
    var nickname = friendlyDeviceLabel(node.nickname || node.nick || p["node.nick"] || p["device.profile.description"] || "")
    if (nickname) return nickname
    return friendlyDeviceLabel(node.description || p["node.description"] || node.name || "Unknown")
}

function isHeadphones(node) {
    if (!node) return false
    var p = nodeProps(node)
    var blob = String([node.name, node.description, node.nickname,
        p["device.icon-name"] || "", p["device.product.name"] || "",
        p["node.description"] || "", p["node.nick"] || ""].join(" ")).toLowerCase()
    return blob.indexOf("headphone") !== -1 || blob.indexOf("headset") !== -1
        || blob.indexOf("earbud") !== -1 || blob.indexOf("earphone") !== -1
        || blob.indexOf("airpod") !== -1
}

function sinkGlyph(node) {
    if (!node) return "󰓃"
    if (isHeadphones(node)) return "󰋋"
    var p = nodeProps(node)
    var blob = String([node.name, node.description, node.nickname,
        p["device.icon-name"] || "", p["device.product.name"] || ""].join(" ")).toLowerCase()
    if (blob.indexOf("bluetooth") !== -1) return "󰂯"
    if (blob.indexOf("hdmi") !== -1 || blob.indexOf("display") !== -1) return "󰍹"
    return "󰓃"
}

function sourceGlyph(node) {
    if (!node) return "󰍬"
    var p = nodeProps(node)
    var blob = String([node.name, node.description, node.nickname,
        p["device.icon-name"] || ""].join(" ")).toLowerCase()
    if (blob.indexOf("headset") !== -1) return "󰋋"
    if (blob.indexOf("bluetooth") !== -1) return "󰂯"
    if (blob.indexOf("webcam") !== -1 || blob.indexOf("camera") !== -1) return "󰄀"
    return "󰍬"
}

function rawStreamLabel(node) {
    if (!node) return "Stream"
    var p = nodeProps(node)
    return p["application.name"] || node.description || p["media.name"]
        || p["node.name"] || node.name || "Stream"
}

function friendlyStreamLabel(label) {
    var value = String(label || "").trim()
    if (!value) return "Stream"
    if (value.toLowerCase() === "spotify") return "Spotify"
    return value
}

function outputVolumeName(volume, muted) {
    if (muted) return "Muted"
    var percent = Math.round(Number(volume || 0) * 100)
    if (percent === 0) return "Silenced"
    if (percent >= 100) return "Concert hall"
    if (percent >= 85) return "Party mode"
    if (percent >= 70) return "Cranked up"
    if (percent >= 50) return "Steady groove"
    if (percent >= 30) return "Easy listening"
    if (percent >= 15) return "Murmur"
    return "Whisper"
}

if (typeof module !== "undefined") {
    module.exports = {
        isPlaybackStream: isPlaybackStream,
        isAudioSource: isAudioSource,
        listSnapshot: listSnapshot,
        nodeProps: nodeProps,
        friendlyDeviceLabel: friendlyDeviceLabel,
        nodeLabel: nodeLabel,
        isHeadphones: isHeadphones,
        sinkGlyph: sinkGlyph,
        sourceGlyph: sourceGlyph,
        rawStreamLabel: rawStreamLabel,
        friendlyStreamLabel: friendlyStreamLabel,
        outputVolumeName: outputVolumeName
    }
}
