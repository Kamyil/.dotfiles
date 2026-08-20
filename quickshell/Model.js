function parseNetworkStatus(raw) {
  var parts = String(raw || "disconnected\t\t\t").replace(/\r?\n+$/, "").split("\t")
  return {
    kind: parts[0] || "disconnected",
    label: parts[1] || "",
    signalStrength: parts[2] ? parseInt(parts[2], 10) : -1,
    frequency: parts[3] || ""
  }
}

function wifiIconFor(strength) {
  var icons = ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"]
  var value = Number(strength)
  if (!isFinite(value)) value = 0
  var index = Math.max(0, Math.min(4, Math.ceil(value / 20) - 1))
  return icons[index]
}

function connectionIcon(kind, signalStrength) {
  if (kind === "wifi") return wifiIconFor(signalStrength)
  if (kind === "ethernet") return "󰈀"
  return "󰤮"
}

function formatHeaderSpeed(mbps) {
  var v = parseInt(mbps, 10)
  if (!isFinite(v) || v < 0) return ""
  if (v >= 1000) return (v / 1000).toFixed(v % 1000 === 0 ? 0 : 1) + "gbit"
  return v + "mbit"
}

function formatHeaderFreq(mhz) {
  var v = parseFloat(mhz)
  if (!isFinite(v) || !v) return ""
  if (v >= 2400 && v < 2500) return "2.4ghz"
  if (v >= 4900 && v < 5925) return "5ghz"
  if (v >= 5925 && v < 7125) return "6ghz"
  if (v >= 57000 && v < 71000) return "60ghz"
  var ghz = v / 1000
  return ghz.toFixed(ghz % 1 === 0 ? 0 : 1) + "ghz"
}

function headerDetail(info) {
  var value = info || {}
  if (value.type === "ethernet") return formatHeaderSpeed(value.speed || "")
  if (value.type === "wifi") return formatHeaderFreq(value.freq || value.frequency || "")
  return ""
}

function bandLabel(band) {
  if (band === "auto") return "Auto"
  if (!band) return ""
  return String(band) + "ghz"
}

function bandSectionTitle(selected, current) {
  if (selected !== "auto") return "WI-FI BAND"
  var label = bandLabel(current)
  return label === "" ? "WI-FI BAND" : "WI-FI BAND: " + label.toUpperCase()
}

function bandTooltip(band) {
  if (band === "auto") return "Let Wi-Fi pick the band"
  return band ? "Stay on " + bandLabel(band) : ""
}

function parseBandStatus(raw) {
  var next = parseKeyValue(raw)
  var tokens = String(next.available || "").split(" ")
  var available = []
  for (var i = 0; i < tokens.length; i++) if (tokens[i] !== "") available.push(tokens[i])
  return { band: next.band || "", selected: next.selected || "auto", available: available }
}

function decodeIwSsid(value) {
  var raw = String(value || "")
  try {
    var encoded = ""
    for (var i = 0; i < raw.length; i++) {
      if (raw[i] === "\\" && raw[i + 1] === "x" && /^[0-9a-f]{2}$/i.test(raw.substring(i + 2, i + 4))) {
        var hex = raw.substring(i + 2, i + 4)
        var byte = parseInt(hex, 16)
        encoded += byte < 32 || byte === 127 ? encodeURIComponent(raw.substring(i, i + 4)) : "%" + hex
        i += 3
      } else if (raw[i] === "\\" && (raw[i + 1] === ":" || raw[i + 1] === "\\")) {
        encoded += encodeURIComponent(raw[i + 1])
        i++
      } else encoded += encodeURIComponent(raw[i])
    }
    return decodeURIComponent(encoded)
  } catch (error) {
    return raw
  }
}

function parseKeyValue(raw) {
  var next = {}
  var lines = String(raw || "").split("\n")
  for (var i = 0; i < lines.length; i++) {
    var line = lines[i]
    if (!line) continue
    var idx = line.indexOf("\t")
    if (idx === -1) continue
    var key = line.substring(0, idx)
    var value = line.substring(idx + 1)
    next[key] = key === "ssid" ? decodeIwSsid(value) : value.trim()
  }
  return next
}

function parseWifiScan(raw) {
  var lines = String(raw || "").split("\n")
  var rows = []
  var row = null
  function flush() {
    if (!row || !row.ssid) return
    rows.push(row)
  }
  for (var i = 0; i < lines.length; i++) {
    var line = lines[i]
    var idx = line.indexOf(":")
    if (idx === -1) continue
    var key = line.substring(0, idx).trim()
    var value = line.substring(idx + 1).trim()
    if (key === "IN-USE") {
      flush()
      row = { active: value === "*", ssid: "", security: "", signal: 0, frequency: "", known: false }
    } else if (row) {
      if (key === "SSID") row.ssid = decodeIwSsid(value)
      else if (key === "SECURITY") row.security = value
      else if (key === "SIGNAL") row.signal = Number(value) || 0
      else if (key === "FREQ") row.frequency = value
    }
  }
  flush()
  return sortWifiRows(rows)
}

function throughputState(previous, next, now) {
  var prev = previous || {}
  var sample = next || {}
  var iface = sample.iface || ""
  var rx = parseFloat(sample.rx_bytes || "0")
  var tx = parseFloat(sample.tx_bytes || "0")
  var previousTime = Number(prev.prevSampleTime || 0)
  if (iface !== (prev.prevIface || "") || previousTime === 0) {
    return { prevIface: iface, prevRxBytes: rx, prevTxBytes: tx, prevSampleTime: now, downloadRate: 0, uploadRate: 0 }
  }
  var dt = now - previousTime
  var downloadRate = Number(prev.downloadRate || 0)
  var uploadRate = Number(prev.uploadRate || 0)
  if (dt > 0) {
    downloadRate = Math.max(0, (rx - Number(prev.prevRxBytes || 0)) / dt)
    uploadRate = Math.max(0, (tx - Number(prev.prevTxBytes || 0)) / dt)
  }
  return { prevIface: iface, prevRxBytes: rx, prevTxBytes: tx, prevSampleTime: now, downloadRate: downloadRate, uploadRate: uploadRate }
}

function pingSampleValue(raw) {
  var value = parseFloat(raw)
  return !isFinite(value) || value < 0 ? null : value
}

function appendPingSample(samples, raw, limit) {
  var values = Array.isArray(samples) ? samples.slice() : []
  values.push(pingSampleValue(raw))
  while (values.length > limit) values.shift()
  return values
}

function averagePingLatency(samples, limit) {
  var values = Array.isArray(samples) ? samples : []
  var sampleLimit = Math.max(1, parseInt(limit, 10) || values.length || 1)
  var total = 0
  var count = 0
  for (var i = Math.max(0, values.length - sampleLimit); i < values.length; i++) {
    var value = values[i]
    if (typeof value !== "number" || !isFinite(value) || value < 0) continue
    total += value
    count++
  }
  return count > 0 ? total / count : -1
}

function pingPacketLossPercent(samples) {
  var values = Array.isArray(samples) ? samples : []
  if (!values.length) return 0
  var lost = 0
  for (var i = 0; i < values.length; i++) if (values[i] === null) lost++
  return Math.round(lost * 100 / values.length)
}

function formatPacketLoss(percent, hasSamples) {
  if (hasSamples === false) return "--"
  var value = parseInt(percent, 10)
  return !isFinite(value) || value < 0 ? "0%" : value + "%"
}

function pingLatencyState(previous, next, limit, averageLimit) {
  var prev = previous || {}
  var sample = next || {}
  var iface = sample.iface || ""
  var window = Math.max(1, parseInt(limit, 10) || 5)
  var averageWindow = Math.max(1, parseInt(averageLimit, 10) || window)
  var reset = iface === "" || iface !== (prev.pingIface || "")
  var routerSamples = reset ? [] : (prev.routerPingSamples || [])
  var internetSamples = reset ? [] : (prev.internetPingSamples || [])
  routerSamples = sample.router_ping_ms === undefined ? [] : appendPingSample(routerSamples, sample.router_ping_ms, window)
  internetSamples = sample.internet_ping_ms === undefined ? [] : appendPingSample(internetSamples, sample.internet_ping_ms, window)
  return {
    pingIface: iface,
    routerPingSamples: routerSamples,
    internetPingSamples: internetSamples,
    routerPingLatency: averagePingLatency(routerSamples, averageWindow),
    internetPingLatency: averagePingLatency(internetSamples, averageWindow),
    internetPingPacketLoss: pingPacketLossPercent(internetSamples)
  }
}

function formatBytes(bytes) {
  var n = Number(bytes)
  if (!isFinite(n) || n < 0) n = 0
  if (n < 1024) return Math.round(n) + " B"
  if (n < 1024 * 1024) return (n / 1024).toFixed(1) + " KB"
  if (n < 1024 * 1024 * 1024) return (n / (1024 * 1024)).toFixed(1) + " MB"
  return (n / (1024 * 1024 * 1024)).toFixed(2) + " GB"
}

function formatRate(bytesPerSec) { return formatBytes(bytesPerSec) + "/s" }

function formatPingLatency(ms, hasSamples) {
  if (hasSamples === false) return "--"
  var value = parseFloat(ms)
  if (!isFinite(value) || value < 0) return "Timeout"
  return value.toFixed(value > 0 && value < 10 ? 1 : 0) + " ms"
}

function wifiRow(network) {
  if (!network) return null
  var rawSignal = network.signalStrength
  if (rawSignal === undefined || rawSignal === null) rawSignal = network.signal || 0
  var signal = Number(rawSignal)
  if (!isFinite(signal)) signal = 0
  if (signal >= 0 && signal <= 1) signal *= 100
  return {
    connected: !!network.connected,
    known: !!network.known,
    ssid: network.name || network.ssid || "",
    signal: Math.round(Math.max(0, Math.min(100, signal))),
    security: network.security || "",
    frequency: network.frequency || ""
  }
}

function sortWifiRows(rows) {
  var nets = Array.isArray(rows) ? rows.slice() : []
  nets.sort(function(a, b) {
    if (a.connected !== b.connected) return a.connected ? -1 : 1
    if (a.known !== b.known) return a.known ? -1 : 1
    return (b.signal || 0) - (a.signal || 0)
  })
  return nets
}

function wifiSectionTitle(wifiNetworks, index) {
  var networks = Array.isArray(wifiNetworks) ? wifiNetworks : []
  if (index < 0 || index >= networks.length) return ""
  var net = networks[index]
  if (!net) return ""
  if (net.known && index === 0) return "KNOWN NETWORKS"
  if (!net.known && (index === 0 || (networks[index - 1] && networks[index - 1].known))) return "OTHER NETWORKS"
  return ""
}

function requiresCredentials(security, openSecurity, oweSecurity) {
  if (openSecurity !== undefined && security === openSecurity) return false
  if (oweSecurity !== undefined && security === oweSecurity) return false
  var value = String(security || "").toUpperCase()
  return value !== "" && value !== "--" && value !== "OPEN" && value !== "OWE"
}

function canForgetNetwork(network) { return !!(network && network.known && !network.connected) }

var enterpriseConnectScript =
  "u=$(uuidgen); IFS= read -r pw;" +
  " nmcli connection add type wifi con-name \"$1\" ssid \"$1\" connection.uuid \"$u\"" +
  " wifi-sec.key-mgmt wpa-eap 802-1x.eap peap 802-1x.phase2-auth mschapv2" +
  " 802-1x.identity \"$2\" 802-1x.auth-timeout 8 >/dev/null" +
  " && printf 'set 802-1x.password %s\\nsave\\nquit\\n' \"$pw\" | nmcli connection edit uuid \"$u\" >/dev/null" +
  " && nmcli connection up uuid \"$u\"" +
  " || { nmcli connection delete uuid \"$u\" >/dev/null 2>&1; false; }"
function networkFailureReason(reason, needsCredentials, reasons) {
  var r = reasons || {}
  if (needsCredentials && r.NoSecrets !== undefined && reason === r.NoSecrets) return "Passphrase required"
  if (needsCredentials && r.WifiAuthTimeout !== undefined && reason === r.WifiAuthTimeout) return "Wrong password"
  if (r.WifiNetworkLost !== undefined && reason === r.WifiNetworkLost) return "Network lost"
  if (r.WifiClientDisconnected !== undefined && reason === r.WifiClientDisconnected) return "Disconnected"
  if (r.WifiClientFailed !== undefined && reason === r.WifiClientFailed) return "Connection failed"
  var text = String(reason || "")
  if (needsCredentials && /secrets|password|auth/i.test(text)) return "Wrong password"
  if (/lost/i.test(text)) return "Network lost"
  if (/disconnect/i.test(text)) return "Disconnected"
  return text || "Connection failed"
}

function shouldRepromptPassphrase(reason, needsCredentials, reasons) {
  if (!needsCredentials) return false
  var r = reasons || {}
  if (r.NoSecrets !== undefined && reason === r.NoSecrets) return true
  if (r.WifiAuthTimeout !== undefined && reason === r.WifiAuthTimeout) return true
  return /secret|password|auth|timeout/i.test(String(reason || ""))
}

if (typeof module !== "undefined") {
  module.exports = {
    parseNetworkStatus: parseNetworkStatus, wifiIconFor: wifiIconFor, connectionIcon: connectionIcon,
    formatHeaderSpeed: formatHeaderSpeed, formatHeaderFreq: formatHeaderFreq, headerDetail: headerDetail,
    bandLabel: bandLabel, bandSectionTitle: bandSectionTitle, bandTooltip: bandTooltip, parseBandStatus: parseBandStatus,
    decodeIwSsid: decodeIwSsid, parseKeyValue: parseKeyValue, parseWifiScan: parseWifiScan,
    throughputState: throughputState, pingLatencyState: pingLatencyState, pingPacketLossPercent: pingPacketLossPercent,
    formatPacketLoss: formatPacketLoss, formatBytes: formatBytes, formatRate: formatRate, formatPingLatency: formatPingLatency,
    wifiRow: wifiRow, sortWifiRows: sortWifiRows, wifiSectionTitle: wifiSectionTitle, requiresCredentials: requiresCredentials,
    canForgetNetwork: canForgetNetwork, enterpriseConnectScript: enterpriseConnectScript,
    networkFailureReason: networkFailureReason, shouldRepromptPassphrase: shouldRepromptPassphrase
  }
}
