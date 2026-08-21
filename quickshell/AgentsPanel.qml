import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "."

Item {
    id: root
    implicitWidth: 340
    implicitHeight: Math.max(250, content.implicitHeight)

    property var providers: []
    property int selectedIndex: 0
    property string error: ""
    readonly property var selected: providers.length > 0 ? providers[Math.min(selectedIndex, providers.length - 1)] : null

    function refresh() {
        if (!usageProcess.running)
            usageProcess.running = true
    }

    function resetText(value) {
        if (!value)
            return ""
        const seconds = Math.max(0, Math.floor((new Date(value).getTime() - Date.now()) / 1000))
        const hours = Math.floor(seconds / 3600)
        const minutes = Math.floor((seconds % 3600) / 60)
        return "resets in " + (hours > 0 ? hours + "h " : "") + minutes + "m"
    }

    Process {
        id: usageProcess
        command: [Quickshell.env("HOME") + "/.config/quickshell/agent-usage.py"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const value = JSON.parse(text)
                    root.providers = value.providers || []
                    root.error = ""
                    if (root.selectedIndex >= root.providers.length)
                        root.selectedIndex = 0
                } catch (exception) {
                    root.error = "Agent limits could not be read."
                }
            }
        }
    }

    Timer {
        interval: 15 * 60 * 1000
        running: root.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    component LimitRow: ColumnLayout {
        required property var limit
        Layout.fillWidth: true
        spacing: 7

        RowLayout {
            Layout.fillWidth: true
            Text {
                text: limit.label || "Limit"
                color: Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.weight: Font.DemiBold
            }
            Item { Layout.fillWidth: true }
            Text {
                text: limit.detail || Math.round(Number(limit.percent || 0)) + "% used"
                color: Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: 10
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 8
            radius: Theme.radius
            color: Theme.elevated
            Rectangle {
                width: parent.width * Math.max(0, Math.min(100, Number(limit.percent || 0))) / 100
                height: parent.height
                radius: Theme.radius
                color: Number(limit.percent || 0) >= 90 ? Theme.danger
                    : Number(limit.percent || 0) >= 70 ? Theme.warning : Theme.accent
            }
        }

        Text {
            visible: !!limit.resetsAt || limit.estimated === true
            text: limit.estimated === true ? "Local estimate" : root.resetText(limit.resetsAt)
            color: Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: 9
        }
    }

    ColumnLayout {
        id: content
        anchors.fill: parent
        spacing: 16

        Heading {
            title: root.selected ? root.selected.name : "Agent limits"
            subtitle: root.selected
                ? [root.selected.plan, root.selected.status].filter(value => value && value.length > 0).join(" · ")
                : "Codex and OpenCode Go"
        }

        RowLayout {
            visible: root.providers.length > 1
            Layout.fillWidth: true
            spacing: 8
            Repeater {
                model: root.providers
                delegate: ThemeButton {
                    required property var modelData
                    required property int index
                    text: modelData.name
                    selected: index === root.selectedIndex
                    Layout.fillWidth: true
                    onClicked: root.selectedIndex = index
                }
            }
        }

        ColumnLayout {
            visible: root.selected && root.selected.limits && root.selected.limits.length > 0
            Layout.fillWidth: true
            spacing: 16
            Repeater {
                model: root.selected ? root.selected.limits : []
                delegate: LimitRow { required property var modelData; limit: modelData }
            }
        }

        Text {
            visible: root.selected && (!root.selected.limits || root.selected.limits.length === 0)
            Layout.fillWidth: true
            text: root.selected ? root.selected.status : "No usage data"
            color: Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: 11
            wrapMode: Text.WordWrap
        }

        Text {
            visible: root.error.length > 0
            Layout.fillWidth: true
            text: root.error
            color: Theme.danger
            font.family: Theme.fontFamily
            font.pixelSize: 10
        }

        ThemeButton {
            Layout.alignment: Qt.AlignRight
            text: usageProcess.running ? "Refreshing" : "Refresh"
            enabled: !usageProcess.running
            onClicked: root.refresh()
        }

        Item { Layout.fillHeight: true }
    }
}
