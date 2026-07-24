import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import "."

Item {
    id: root
    implicitWidth: 340
    implicitHeight: 350

    property int volume: 0
    property bool muted: false
    property string defaultSink: ""
    property string feedback: ""

    function refresh() {
        volumeProc.running = true
        sinksProc.running = true
        defaultProc.running = true
    }

    function setVolume(value) {
        action.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", Math.round(value) + "%"]
        action.running = true
    }

    ListModel { id: sinks }

    Process {
        id: volumeProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: StdioCollector {
            onStreamFinished: {
                const match = text.match(/Volume:\s+([0-9.]+)/)
                if (match)
                    root.volume = Math.round(Number(match[1]) * 100)
                root.muted = /MUTED/.test(text)
            }
        }
    }

    Process {
        id: defaultProc
        command: ["pactl", "get-default-sink"]
        stdout: StdioCollector { onStreamFinished: root.defaultSink = text.trim() }
    }

    Process {
        id: sinksProc
        command: ["pactl", "list", "short", "sinks"]
        stdout: StdioCollector {
            onStreamFinished: {
                sinks.clear()
                for (const line of text.trim().split("\n")) {
                    const fields = line.split("\t")
                    if (fields.length >= 2)
                        sinks.append({ sinkName: fields[1], description: fields[1].replace(/^alsa_output\./, "").replace(/\./g, " ") })
                }
            }
        }
    }

    Process {
        id: action
        stdout: StdioCollector { onStreamFinished: if (text.trim()) root.feedback = text.trim() }
        stderr: StdioCollector { onStreamFinished: if (text.trim()) root.feedback = text.trim() }
        onExited: refreshDelay.restart()
    }

    Timer { id: refreshDelay; interval: 350; onTriggered: root.refresh() }

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        Heading {
            title: "Sound"
            subtitle: root.muted ? "Output muted" : root.volume + "% on the selected output"
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 74
            radius: 10
            color: Theme.elevated

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                Text {
                    text: root.muted ? "" : root.volume < 35 ? "" : root.volume < 70 ? "" : ""
                    color: root.muted ? Theme.muted : Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: 17
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -8
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            action.command = ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]
                            action.running = true
                        }
                    }
                }

                Slider {
                    id: volumeSlider
                    Layout.fillWidth: true
                    from: 0
                    to: 100
                    value: root.volume
                    onMoved: root.setVolume(value)
                }

                Text {
                    text: root.volume + "%"
                    color: Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    Layout.preferredWidth: 36
                    horizontalAlignment: Text.AlignRight
                }
            }
        }

        Text {
            text: "OUTPUT DEVICE"
            color: Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: 9
            font.weight: Font.DemiBold
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 2

            Repeater {
                model: sinks
                delegate: ActionRow {
                    required property string sinkName
                    required property string description
                    title: description
                    subtitle: sinkName
                    icon: "󰓃"
                    trailing: sinkName === root.defaultSink ? "Selected" : ""
                    selected: sinkName === root.defaultSink
                    onClicked: {
                        action.command = ["pactl", "set-default-sink", sinkName]
                        action.running = true
                    }
                }
            }
            Item { Layout.fillHeight: true }
        }

        Text {
            visible: root.feedback.length > 0
            text: root.feedback
            color: Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: 9
            elide: Text.ElideRight
            Layout.fillWidth: true
        }
    }

    Component.onCompleted: refresh()
}
