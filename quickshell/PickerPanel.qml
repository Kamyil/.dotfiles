import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import "."

Item {
    id: root
    implicitWidth: 620
    implicitHeight: 520
    property string mode: "clipboard"
    property string title: mode === "clipboard" ? "Clipboard history" : mode === "emoji" ? "Emoji" : "Images"
    property int selectedIndex: 0
    signal closeRequested()
    readonly property string helper: Qt.resolvedUrl("picker-data.py").toString().replace("file://", "")
    readonly property var filtered: {
        const needle = search.text.toLowerCase().trim()
        const values = []
        for (let index = 0; index < entries.count; index++) {
            const row = entries.get(index)
            if (!needle || row.label.toLowerCase().includes(needle) || row.value.toLowerCase().includes(needle)) values.push({ value: row.value, label: row.label })
            if (values.length >= 80) break
        }
        return values
    }
    function reset() { search.text = ""; selectedIndex = 0; load.running = true; search.forceActiveFocus() }
    function choose(value) { select.command = ["python3", helper, mode, "select", value]; select.running = true; closeRequested() }
    ListModel { id: entries }
    Process {
        id: load
        command: ["python3", root.helper, root.mode, "list"]
        stdout: StdioCollector { onStreamFinished: {
            entries.clear()
            for (const line of text.split("\n")) { const split = line.indexOf("\t"); if (split > 0) entries.append({ value: line.slice(0, split), label: line.slice(split + 1) }) }
        } }
    }
    Process { id: select }
    Rectangle {
        anchors.fill: parent; radius: 16; color: Theme.surface; border.color: Theme.border
        ColumnLayout {
            anchors.fill: parent; anchors.margins: 16; spacing: 10
            Heading { title: root.title; subtitle: root.mode === "image" ? "Copy an image to the clipboard" : "Select to copy" }
            TextField {
                id: search; Layout.fillWidth: true; placeholderText: "Search…"; color: Theme.foreground; font.family: Theme.fontFamily
                Keys.onEscapePressed: root.closeRequested()
                Keys.onDownPressed: root.selectedIndex = Math.min(results.count - 1, root.selectedIndex + 1)
                Keys.onUpPressed: root.selectedIndex = Math.max(0, root.selectedIndex - 1)
                Keys.onReturnPressed: if (results.itemAt(root.selectedIndex)) root.choose(results.itemAt(root.selectedIndex).value)
            }
            ScrollView {
                Layout.fillWidth: true; Layout.fillHeight: true; clip: true
                ColumnLayout {
                    width: parent.width; spacing: 3
                    Repeater {
                        id: results; model: root.filtered
                        delegate: ActionRow {
                            required property var modelData
                            required property int index
                            property string value: modelData.value
                            title: root.mode === "emoji" ? modelData.value + "  " + modelData.label : modelData.label
                            subtitle: root.mode === "image" ? modelData.value : ""
                            icon: root.mode === "clipboard" ? "󰅌" : root.mode === "emoji" ? "󰞅" : "󰋩"
                            selected: index === root.selectedIndex; trailing: selected ? "Copy" : ""
                            onClicked: root.choose(modelData.value)
                        }
                    }
                    Text { visible: results.count === 0; text: "No matching entries"; color: Theme.muted; font.family: Theme.fontFamily; Layout.alignment: Qt.AlignHCenter; Layout.topMargin: 30 }
                }
            }
        }
    }
}
