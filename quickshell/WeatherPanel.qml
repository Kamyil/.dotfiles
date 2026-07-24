import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "."

Item {
    id: root
    implicitWidth: 340
    implicitHeight: 440
    property string location: "Locating…"
    property string temperature: "—"
    property string feelsLike: "—"
    property string condition: ""
    property string humidity: "—"
    property string wind: "—"
    property string error: ""

    function iconFor(text) {
        const value = String(text).toLowerCase()
        if (value.includes("thunder")) return "󰖓"
        if (value.includes("snow") || value.includes("sleet")) return "󰖘"
        if (value.includes("rain") || value.includes("drizzle")) return "󰖗"
        if (value.includes("fog") || value.includes("mist")) return "󰖑"
        if (value.includes("cloud") || value.includes("overcast")) return "󰖐"
        return "󰖙"
    }

    function parse(text) {
        forecast.clear()
        error = ""
        for (const line of text.trim().split("\n")) {
            const f = line.split("\t")
            if (f[0] === "error") error = f[1]
            if (f[0] === "current") {
                location = f[1]; temperature = f[2]; feelsLike = f[3]
                condition = f[4]; humidity = f[5]; wind = f[6] + " km/h " + f[7]
            }
            if (f[0] === "day") forecast.append({ dateValue: f[1], low: f[2], high: f[3], summary: f[4], rain: f[5] })
        }
    }

    ListModel { id: forecast }
    Process {
        id: weather
        command: [Qt.resolvedUrl("weather-status.sh").toString().replace("file://", "")]
        stdout: StdioCollector { onStreamFinished: root.parse(text) }
        stderr: StdioCollector { onStreamFinished: if (text.trim()) root.error = text.trim() }
        onExited: (exitCode, exitStatus) => { if (exitCode !== 0 && !root.error) root.error = "Weather service unavailable" }
    }
    Timer { interval: 900000; running: true; repeat: true; onTriggered: if (!weather.running) weather.running = true }

    ColumnLayout {
        anchors.fill: parent
        spacing: 12
        Heading { title: "Weather"; subtitle: root.location }
        Rectangle {
            Layout.fillWidth: true; implicitHeight: 116; radius: 10; color: Theme.elevated
            RowLayout {
                anchors.fill: parent; anchors.margins: 16; spacing: 14
                Text { text: root.iconFor(root.condition); color: Theme.accent; font.family: Theme.fontFamily; font.pixelSize: 44 }
                ColumnLayout {
                    Layout.fillWidth: true; spacing: 2
                    Text { text: root.temperature + "°"; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: 36; font.weight: Font.DemiBold }
                    Text { text: root.condition; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: 11; elide: Text.ElideRight; Layout.fillWidth: true }
                    Text { text: "Feels like " + root.feelsLike + "° · Humidity " + root.humidity + "%"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 9 }
                    Text { text: "Wind " + root.wind; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 9 }
                }
            }
        }
        Text { text: "FORECAST"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 9; font.weight: Font.DemiBold }
        ColumnLayout {
            Layout.fillWidth: true; spacing: 5
            Repeater {
                model: forecast
                delegate: Rectangle {
                    required property string dateValue
                    required property string low
                    required property string high
                    required property string summary
                    required property string rain
                    Layout.fillWidth: true; implicitHeight: 52; radius: 8; color: Theme.elevated
                    RowLayout {
                        anchors.fill: parent; anchors.margins: 10; spacing: 10
                        Text { text: Qt.formatDate(new Date(dateValue + "T12:00:00"), "ddd"); color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: 10; font.weight: Font.DemiBold; Layout.preferredWidth: 32 }
                        Text { text: root.iconFor(summary); color: Theme.accent; font.family: Theme.fontFamily; font.pixelSize: 18 }
                        Text { text: summary; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 9; elide: Text.ElideRight; Layout.fillWidth: true }
                        Text { visible: Number(rain) > 0; text: rain + "% 󰖗"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 8 }
                        Text { text: low + "°  " + high + "°"; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: 10 }
                    }
                }
            }
        }
        Text { visible: root.error.length > 0; text: root.error; wrapMode: Text.Wrap; color: Theme.warning; font.family: Theme.fontFamily; font.pixelSize: 9; Layout.fillWidth: true }
        Item { Layout.fillHeight: true }
    }
    Component.onCompleted: weather.running = true
}
