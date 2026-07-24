import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import "."

Item {
    id: root
    implicitWidth: 340
    implicitHeight: 480
    property int brightness: 0
    property string feedback: ""

    function refresh() {
        if (!status.running) status.running = true
    }

    function parse(text) {
        monitors.clear()
        const lines = text.trim().split("\n")
        for (const line of lines) {
            const f = line.split("\t")
            if (f[0] === "brightness") brightness = Number(f[1])
            if (f[0] === "monitor" && f.length >= 10) monitors.append({
                name: f[1], description: f[2], widthPx: f[3], heightPx: f[4],
                resolution: f[3] + "×" + f[4], refreshRate: f[5],
                xPos: f[6], yPos: f[7], scale: Number(f[8]), focused: f[9] === "true"
            })
        }
    }

    ListModel { id: monitors }
    Process {
        id: status
        command: [Qt.resolvedUrl("display-status.sh").toString().replace("file://", "")]
        stdout: StdioCollector { onStreamFinished: root.parse(text) }
    }
    Process {
        id: action
        stdout: StdioCollector { onStreamFinished: root.feedback = text.trim() }
        stderr: StdioCollector { onStreamFinished: if (text.trim()) root.feedback = text.trim() }
        onExited: refreshDelay.restart()
    }
    Timer { id: refreshDelay; interval: 350; onTriggered: root.refresh() }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10
        Heading { title: "Displays"; subtitle: monitors.count + (monitors.count === 1 ? " connected display" : " connected displays") }

        Text { text: "BRIGHTNESS"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 9; font.weight: Font.DemiBold }
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 58
            radius: 9
            color: Theme.elevated
            RowLayout {
                anchors.fill: parent; anchors.margins: 10; spacing: 10
                Text { text: "󰃟"; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: 16 }
                Slider {
                    Layout.fillWidth: true; from: 1; to: 100; value: root.brightness
                    onMoved: {
                        root.brightness = Math.round(value)
                        action.command = ["brightnessctl", "set", root.brightness + "%"]
                        action.running = true
                    }
                }
                Text { text: root.brightness + "%"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 9; Layout.preferredWidth: 32; horizontalAlignment: Text.AlignRight }
            }
        }

        Text { text: "MONITORS"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 9; font.weight: Font.DemiBold }
        ScrollView {
            Layout.fillWidth: true; Layout.fillHeight: true; clip: true
            ColumnLayout {
                width: parent.width; spacing: 6
                Repeater {
                    model: monitors
                    delegate: Rectangle {
                        required property string name
                        required property string description
                        required property string resolution
                        required property string refreshRate
                        required property string widthPx
                        required property string heightPx
                        required property string xPos
                        required property string yPos
                        required property real scale
                        required property bool focused
                        Layout.fillWidth: true; implicitHeight: 92; radius: 9
                        color: focused ? Theme.hover : Theme.elevated
                        border.color: focused ? Theme.accent : Theme.border
                        ColumnLayout {
                            anchors.fill: parent; anchors.margins: 10; spacing: 5
                            RowLayout {
                                Layout.fillWidth: true
                                Text { text: "󰍹"; color: Theme.accent; font.family: Theme.fontFamily; font.pixelSize: 15 }
                                ColumnLayout {
                                    Layout.fillWidth: true; spacing: 0
                                    Text { text: description; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: 10; font.weight: Font.DemiBold; elide: Text.ElideRight; Layout.fillWidth: true }
                                    Text { text: name + " · " + resolution + " @ " + refreshRate + " Hz"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 8; elide: Text.ElideRight; Layout.fillWidth: true }
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                Text { text: "Scale"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 9 }
                                Item { Layout.fillWidth: true }
                                Button {
                                    text: "−"; enabled: scale > 0.75
                                    onClicked: { action.command = ["hyprctl", "keyword", "monitor", name + "," + widthPx + "x" + heightPx + "@" + refreshRate + "," + xPos + "x" + yPos + "," + Math.max(0.75, scale - 0.25)]; action.running = true }
                                }
                                Text { text: Math.round(scale * 100) + "%"; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: 9; Layout.preferredWidth: 36; horizontalAlignment: Text.AlignHCenter }
                                Button {
                                    text: "+"; enabled: scale < 3
                                    onClicked: { action.command = ["hyprctl", "keyword", "monitor", name + "," + widthPx + "x" + heightPx + "@" + refreshRate + "," + xPos + "x" + yPos + "," + Math.min(3, scale + 0.25)]; action.running = true }
                                }
                            }
                        }
                    }
                }
            }
        }
        Text { visible: root.feedback.length > 0; text: root.feedback; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 8; elide: Text.ElideRight; Layout.fillWidth: true }
    }
    Component.onCompleted: refresh()
}
