import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    id: root
    implicitWidth: 560; implicitHeight: 520; color: Theme.surface; radius: Theme.radius
    property var jobs: []
    property string mode: "video"
    property string quality: "best"
    property string audioFormat: "keep"
    property string dest: Quickshell.env("HOME") + "/Downloads"
    property string error: ""
    readonly property string runner: Qt.resolvedUrl("ytdlp-queue").toString().replace("file://", "")
    readonly property string prefs: Qt.resolvedUrl("ytdlp-preferences").toString().replace("file://", "")
    function refresh() { if (!list.running) list.running = true }
    function parse(raw) { try { jobs = JSON.parse(raw || "[]") } catch (e) { jobs = [] } }
    function save() { savePrefs.command = [prefs, "set", JSON.stringify({mode: mode, quality: quality, audioFormat: audioFormat, dest: dest})]; savePrefs.running = true }
    function add() { var value = url.text.trim(); if (!value || addProc.running) return; addProc.command = [runner, "add", value, "--mode", mode, "--quality", quality, "--audio-format", audioFormat, "--dest", dest]; addProc.running = true; url.text = ""; error = "" }
    function cancel(id) { cancelProc.command = [runner, "cancel", String(id)]; cancelProc.running = true }
    function openDestination() { openProc.command = ["xdg-open", dest]; openProc.running = true }
    Process { id: list; command: [root.runner, "list"]; running: true; stdout: StdioCollector { onStreamFinished: root.parse(text) } }
    Process { id: loadPrefs; command: [root.prefs, "get"]; running: true; stdout: StdioCollector { onStreamFinished: { try { var p = JSON.parse(text); root.mode = p.mode || root.mode; root.quality = p.quality || root.quality; root.audioFormat = p.audioFormat || root.audioFormat; root.dest = p.dest || root.dest; destination.text = root.dest } catch (e) {} } } }
    Process { id: savePrefs }
    Process {
        id: addProc
        stderr: StdioCollector { onStreamFinished: { if (text.trim()) root.error = text.trim() } }
        onExited: root.refresh()
    }
    Process { id: cancelProc; onExited: root.refresh() }
    Process { id: openProc }
    Timer { interval: 1000; running: true; repeat: true; onTriggered: root.refresh() }
    ColumnLayout {
        anchors.fill: parent; anchors.margins: 16; spacing: 10
        Heading { title: "yt-dlp"; subtitle: root.error || "Download queue" }
        RowLayout { Layout.fillWidth: true
            ThemeTextField { id: url; Layout.fillWidth: true; placeholderText: "Paste a video URL"; onAccepted: root.add() }
            ThemeButton { text: "Add"; enabled: !!url.text.trim() && !addProc.running; onClicked: root.add() }
        }
        RowLayout { Layout.fillWidth: true
            ComboBox { id: modeBox; Layout.fillWidth: true; model: ["video", "audio"]; onCurrentTextChanged: { root.mode = currentText; root.save() } }
            ComboBox { id: qualityBox; Layout.fillWidth: true; model: ["best", "1080", "720", "480"]; onCurrentTextChanged: { root.quality = currentText; root.save() } }
            ComboBox { id: audioBox; Layout.fillWidth: true; model: ["keep", "mp3", "m4a", "opus", "flac", "wav"]; onCurrentTextChanged: { root.audioFormat = currentText; root.save() } }
        }
        RowLayout { Layout.fillWidth: true
            ThemeTextField { id: destination; Layout.fillWidth: true; text: root.dest; placeholderText: "Destination folder"; onEditingFinished: { root.dest = text.trim(); root.save() } }
            ThemeButton { text: "Open"; onClicked: root.openDestination() }
        }
        ListView { Layout.fillWidth: true; Layout.fillHeight: true; clip: true; spacing: 6; model: root.jobs
            delegate: Rectangle {
                required property var modelData
                width: ListView.view.width
                height: modelData.status === "failed" ? 78 : 58
                radius: Theme.radius
                color: Theme.elevated
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    Text { Layout.fillWidth: true; text: modelData.title || modelData.url; elide: Text.ElideMiddle; color: Theme.foreground }
                    RowLayout {
                        Layout.fillWidth: true
                        Text { Layout.fillWidth: true; text: modelData.status + (modelData.percent !== undefined ? " · " + Math.round(modelData.percent) + "%" : ""); color: Theme.subtext }
                        ThemeButton { text: "Cancel"; visible: modelData.status === "running" || modelData.status === "queued"; onClicked: root.cancel(modelData.id) }
                    }
                    Text { Layout.fillWidth: true; visible: modelData.status === "failed"; text: modelData.error || "Download failed"; elide: Text.ElideRight; color: Theme.accent; font.pixelSize: 10 }
                }
            }
        }
    }
}
