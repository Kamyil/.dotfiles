import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import "."

Item {
    id: root
    implicitWidth: 340
    implicitHeight: 540

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property var nodes: Pipewire.nodes ? Pipewire.nodes.values : []
    readonly property var sinks: nodes.filter(node => node && node.isSink && !node.isStream)
    readonly property var sources: nodes.filter(node => node && !node.isSink && !node.isStream && node.audio)
    readonly property var streams: nodes.filter(node => node && node.isStream && node.isSink && node.audio)

    function label(node) {
        if (!node) return "Unknown"
        return node.nickname || node.description || node.name || "Unknown"
    }

    function setVolume(node, value) {
        if (node && node.audio) node.audio.volume = Math.max(0, Math.min(1.5, value / 100))
    }

    function toggleMute(node) {
        if (node && node.audio) node.audio.muted = !node.audio.muted
    }

    PwObjectTracker { objects: root.sinks }
    PwObjectTracker { objects: root.sources }
    PwObjectTracker { objects: root.streams }

    component SectionTitle: Text {
        color: Theme.muted
        font.family: Theme.fontFamily
        font.pixelSize: 9
        font.weight: Font.DemiBold
    }

    component VolumeRow: Rectangle {
        id: row
        required property var node
        property string icon: ""
        property bool compact: false
        signal selected()

        Layout.fillWidth: true
        implicitHeight: compact ? 52 : 62
        radius: 9
        color: Theme.elevated

        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 9

            Text {
                text: row.node && row.node.audio && row.node.audio.muted ? "" : row.icon
                color: row.node && row.node.audio && row.node.audio.muted ? Theme.muted : Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: 15
                MouseArea { anchors.fill: parent; anchors.margins: -6; cursorShape: Qt.PointingHandCursor; onClicked: root.toggleMute(row.node) }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text {
                    text: root.label(row.node)
                    color: Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                Slider {
                    Layout.fillWidth: true
                    from: 0
                    to: 150
                    value: row.node && row.node.audio ? row.node.audio.volume * 100 : 0
                    onMoved: root.setVolume(row.node, value)
                }
            }

            Text {
                text: Math.round(row.node && row.node.audio ? row.node.audio.volume * 100 : 0) + "%"
                color: Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: 9
                Layout.preferredWidth: 34
                horizontalAlignment: Text.AlignRight
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        Heading {
            title: "Sound"
            subtitle: root.sink && root.sink.audio && root.sink.audio.muted
                ? "Output muted"
                : Math.round(root.sink && root.sink.audio ? root.sink.audio.volume * 100 : 0) + "% output"
        }

        SectionTitle { text: "OUTPUT" }
        VolumeRow { node: root.sink; icon: "" }

        ScrollView {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(outputDevices.implicitHeight, 108)
            clip: true
            ColumnLayout {
                id: outputDevices
                width: parent.width
                spacing: 2
                Repeater {
                    model: root.sinks
                    delegate: ActionRow {
                        required property var modelData
                        title: root.label(modelData)
                        subtitle: modelData.name || "PipeWire output"
                        icon: "󰓃"
                        trailing: modelData === root.sink ? "Selected" : ""
                        selected: modelData === root.sink
                        onClicked: Pipewire.preferredDefaultAudioSink = modelData
                    }
                }
            }
        }

        Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Theme.border }
        SectionTitle { text: "INPUT" }
        VolumeRow { visible: !!root.source; node: root.source; icon: "󰍬"; compact: true }
        ScrollView {
            visible: root.sources.length > 1
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(inputDevices.implicitHeight, 96)
            clip: true
            ColumnLayout {
                id: inputDevices
                width: parent.width
                spacing: 2
                Repeater {
                    model: root.sources
                    delegate: ActionRow {
                        required property var modelData
                        Layout.fillWidth: true
                        title: root.label(modelData)
                        icon: "󰍬"
                        selected: modelData === root.source
                        onClicked: Pipewire.preferredDefaultAudioSource = modelData
                    }
                }
            }
        }

        Rectangle { visible: root.streams.length > 0; Layout.fillWidth: true; implicitHeight: 1; color: Theme.border }
        SectionTitle { visible: root.streams.length > 0; text: "APPLICATIONS" }
        ScrollView {
            visible: root.streams.length > 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ColumnLayout {
                width: parent.width
                spacing: 4
                Repeater {
                    model: root.streams
                    delegate: VolumeRow {
                        required property var modelData
                        node: modelData
                        icon: "󰎆"
                        compact: true
                    }
                }
            }
        }
        Item { visible: root.streams.length === 0; Layout.fillHeight: true }
    }
}
