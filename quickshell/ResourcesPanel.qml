import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "."

Item {
    id: root
    implicitWidth: 340
    implicitHeight: 270

    property bool externalMetrics: false
    property int cpu: 0
    property int memory: 0
    property int gpu: -1
    property string memoryUsedGiB: "0.0"
    property string memoryTotalGiB: "0.0"
    property string error: ""

    function refresh() {
        if (!metrics.running)
            metrics.running = true
    }

    function metricColor(value) {
        if (value >= 90)
            return Theme.danger
        if (value >= 70)
            return Theme.warning
        return Theme.accent
    }

    Process {
        id: metrics
        command: [Quickshell.env("HOME") + "/.config/quickshell/resource-status.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const value = JSON.parse(text)
                    root.cpu = value.cpu
                    root.memory = value.memory
                    root.memoryUsedGiB = value.memoryUsedGiB
                    root.memoryTotalGiB = value.memoryTotalGiB
                    root.gpu = value.gpu
                    root.error = ""
                } catch (exception) {
                    root.error = "Resource metrics could not be read."
                }
            }
        }
    }

    Timer {
        interval: 2000
        running: !root.externalMetrics
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    component UsageRow: ColumnLayout {
        required property string label
        required property string detail
        required property int value
        property bool available: true
        Layout.fillWidth: true
        spacing: 6

        RowLayout {
            Layout.fillWidth: true
            Text {
                text: parent.parent.label
                color: Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.weight: Font.DemiBold
            }
            Item { Layout.fillWidth: true }
            Text {
                text: parent.parent.available ? parent.parent.detail : "Unavailable"
                color: Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: 10
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 8
            radius: 4
            color: Theme.elevated

            Rectangle {
                width: parent.parent.available ? parent.width * Math.max(0, Math.min(100, parent.parent.value)) / 100 : 0
                height: parent.height
                radius: parent.radius
                color: root.metricColor(parent.parent.value)
                Behavior on width { NumberAnimation { duration: 180 } }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 16

        Heading {
            title: "System resources"
            subtitle: "Live load sampled every two seconds"
        }

        UsageRow {
            label: "CPU"
            value: root.cpu
            detail: root.cpu + "%"
        }

        UsageRow {
            label: "Memory"
            value: root.memory
            detail: root.memoryUsedGiB + " / " + root.memoryTotalGiB + " GiB  ·  " + root.memory + "%"
        }

        UsageRow {
            label: "GPU"
            value: root.gpu
            available: root.gpu >= 0
            detail: root.gpu + "%"
        }

        Text {
            visible: root.gpu < 0
            Layout.fillWidth: true
            text: "GPU utilization is unavailable because the graphics driver does not expose DRM engine counters."
            color: Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: 9
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

        Item { Layout.fillHeight: true }
    }
}
