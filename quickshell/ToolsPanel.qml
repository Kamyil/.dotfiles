import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "."

Item {
    id: root
    implicitWidth: 620
    implicitHeight: 520
    signal closeRequested()
    signal showRequested()
    signal hideRequested()
    property int selectedIndex: 0
    property string activeTool: ""
    property string result: ""
    property string copyText: ""
    property var details: []
    property string error: ""
    readonly property string helper: Qt.resolvedUrl("tool-runner.py").toString().replace("file://", "")
    readonly property var tools: [
        { id: "calculate", name: "Calculator", description: "Evaluate a mathematical expression", icon: "󰪚", keywords: "calc math expression arithmetic" },
        { id: "convert", name: "Unit converter", description: "Convert distance, mass, temperature and data", icon: "󰔏", keywords: "unit distance length mass temperature storage parsing" },
        { id: "color", name: "Color picker", description: "Pick, inspect and convert colors", icon: "󰏘", keywords: "colour hex rgb hsl screen hyprpicker" },
        { id: "currency", name: "Currency converter", description: "Convert currencies using cached live rates", icon: "󰥔", keywords: "money exchange rate usd eur gbp" }
    ]
    readonly property var active: tools.find(tool => tool.id === activeTool)
    readonly property string query: search.text.trim().toLowerCase()
    readonly property var filteredTools: {
        const values = tools.filter(tool => score(tool) >= 0)
        values.sort((a, b) => score(b) - score(a) || a.name.localeCompare(b.name))
        return values
    }

    function fuzzy(text, needle) {
        let position = 0
        for (let index = 0; index < text.length && position < needle.length; index++)
            if (text[index] === needle[position]) position++
        return position === needle.length
    }
    function score(tool) {
        if (!query) return 0
        const name = tool.name.toLowerCase()
        const haystack = name + " " + tool.keywords + " " + tool.description.toLowerCase()
        if (name === query) return 100
        if (name.startsWith(query)) return 80
        if (haystack.includes(query)) return 60
        return fuzzy(haystack, query) ? 20 : -1
    }
    function reset() {
        activeTool = ""
        search.text = ""
        toolInput.text = ""
        selectedIndex = 0
        clearResult()
        search.forceActiveFocus()
    }
    function clearResult() { result = ""; copyText = ""; details = []; error = "" }
    function openTool(tool) {
        if (!tool) return
        activeTool = tool.id
        toolInput.text = ""
        clearResult()
        Qt.callLater(() => toolInput.forceActiveFocus())
    }
    function goBack() {
        if (!activeTool) { closeRequested(); return }
        activeTool = ""
        clearResult()
        Qt.callLater(() => search.forceActiveFocus())
    }
    function runTool() {
        if (!activeTool || !toolInput.text.trim() || runner.running) return
        error = ""
        runner.command = ["python3", helper, activeTool, toolInput.text.trim()]
        runner.running = true
    }
    function copyResult() {
        if (!copyText || copy.running) return
        copy.command = ["python3", helper, "copy", copyText]
        copy.running = true
    }
    function placeholder() {
        if (activeTool === "calculate") return "sqrt(144) + 5 * 3"
        if (activeTool === "convert") return "12.5 km to miles"
        if (activeTool === "color") return "#7AA2F7 or rgb(122, 162, 247)"
        return "150 USD to EUR"
    }

    Timer { id: debounce; interval: 140; onTriggered: root.runTool() }
    Process {
        id: runner
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const payload = JSON.parse(text.trim())
                    if (payload.ok) {
                        root.result = payload.primary || ""
                        root.copyText = payload.copyText || root.result
                        root.details = payload.details || []
                        root.error = ""
                    } else root.error = payload.error || "Tool failed"
                } catch (_) { root.error = "Tool returned an invalid response" }
            }
        }
        stderr: StdioCollector { onStreamFinished: if (text.trim() && !root.error) root.error = text.trim() }
    }
    Process { id: copy }
    Process {
        id: picker
        command: ["hyprpicker", "-a", "-f", "hex"]
        stdout: StdioCollector {
            onStreamFinished: {
                const value = text.trim()
                if (value) {
                    root.toolInput.text = value
                    root.runTool()
                }
            }
        }
        onExited: root.showRequested()
    }

    Rectangle {
        anchors.fill: parent
        radius: 7
        color: Theme.surface
        border.color: Theme.border
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            Heading {
                title: root.active ? root.active.name : "Tools"
                subtitle: root.active ? root.active.description : "Search and run a quick tool"
            }
            ThemeTextField {
                id: search
                visible: !root.activeTool
                Layout.fillWidth: true
                placeholderText: "Search tools…"
                color: Theme.foreground
                font.family: Theme.fontFamily
                onTextChanged: root.selectedIndex = 0
                Keys.onEscapePressed: root.closeRequested()
                Keys.onDownPressed: root.selectedIndex = Math.min(root.filteredTools.length - 1, root.selectedIndex + 1)
                Keys.onUpPressed: root.selectedIndex = Math.max(0, root.selectedIndex - 1)
                Keys.onReturnPressed: root.openTool(root.filteredTools[root.selectedIndex])
                Keys.onEnterPressed: root.openTool(root.filteredTools[root.selectedIndex])
            }
            ScrollView {
                visible: !root.activeTool
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                ColumnLayout {
                    width: parent.width
                    spacing: 3
                    Repeater {
                        model: root.filteredTools
                        delegate: ActionRow {
                            required property var modelData
                            required property int index
                            title: modelData.icon + "  " + modelData.name
                            subtitle: modelData.description
                            trailing: index === root.selectedIndex ? "Enter" : ""
                            selected: index === root.selectedIndex
                            onClicked: root.openTool(modelData)
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.NoButton
                                onPositionChanged: root.selectedIndex = index
                            }
                        }
                    }
                    Text {
                        visible: root.filteredTools.length === 0
                        text: "No matching tools"
                        color: Theme.muted
                        font.family: Theme.fontFamily
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: 40
                    }
                }
            }
            ColumnLayout {
                visible: !!root.activeTool
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 12
                ThemeTextField {
                    id: toolInput
                    Layout.fillWidth: true
                    placeholderText: root.placeholder()
                    color: Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                    onTextChanged: { root.clearResult(); debounce.restart() }
                    Keys.onEscapePressed: root.goBack()
                    Keys.onReturnPressed: root.runTool()
                    Keys.onEnterPressed: root.runTool()
                }
                RowLayout {
                    visible: root.activeTool === "color"
                    Layout.fillWidth: true
                    Button {
                        text: "Pick from screen"
                        onClicked: {
                            root.hideRequested()
                            picker.running = true
                        }
                    }
                }
                Rectangle {
                    visible: root.result.length > 0
                    Layout.fillWidth: true
                    implicitHeight: resultColumn.implicitHeight + 32
                    radius: 8
                    color: Theme.elevated
                    ColumnLayout {
                        id: resultColumn
                        anchors.fill: parent
                        anchors.margins: 16
                        Text { text: root.result; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: 24; Layout.fillWidth: true; wrapMode: Text.Wrap }
                        Repeater {
                            model: root.details
                            Text { required property var modelData; text: modelData; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 10 }
                        }
                        Button { text: "Copy result"; onClicked: root.copyResult() }
                    }
                }
                Text { visible: root.error.length > 0; text: root.error; color: Theme.danger; font.family: Theme.fontFamily; wrapMode: Text.Wrap; Layout.fillWidth: true }
                Item { Layout.fillHeight: true }
            }
            Text {
                text: root.activeTool ? "Enter run   Esc back   Copy result to clipboard" : "↑↓ select   Enter open   Esc close"
                color: Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: 8
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}
