import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Networking
import Quickshell.Bluetooth
import "."

ShellRoot {
    id: root

    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                id: bar
                required property var modelData
                exclusiveZone: 30
                screen: modelData
                implicitHeight: 30
                color: Theme.background

                property string activePanel: ""
                property Item panelAnchor: null
                property int volume: 0
                property bool audioMuted: false
                readonly property bool bluetoothPowered: {
                    for (const adapter of Bluetooth.adapters.values) {
                        if (adapter.enabled)
                            return true
                    }
                    return false
                }
                property int batteryPercent: 0
                property string batteryState: ""
                property date now: new Date()
                property string nightLightState: "unavailable"
                property string nightLightTemperature: ""
                property int resourceCpu: 0
                property string resourceMemoryUsed: "0.0"
                property string resourceMemoryTotal: "0.0"
                property int resourceMemory: 0
                property int resourceGpu: -1

                function isoWeek(date) {
                    const day = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()))
                    const weekday = day.getUTCDay() || 7
                    day.setUTCDate(day.getUTCDate() + 4 - weekday)
                    const yearStart = new Date(Date.UTC(day.getUTCFullYear(), 0, 1))
                    return Math.ceil((((day - yearStart) / 86400000) + 1) / 7)
                }

                function togglePanel(name, item) {
                    if (activePanel === name) {
                        activePanel = ""
                        panel.visible = false
                        return
                    }
                    panel.visible = false
                    activePanel = name
                    panelAnchor = item
                    panel.anchor.item = item
                    panel.visible = true
                }

                anchors {
                    left: true
                    right: true
                    bottom: true
                }

                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: bar.now = new Date()
                }

                Timer {
                    interval: 4000
                    running: true
                    repeat: true
                    triggeredOnStart: true
                    onTriggered: {
                        audioStatus.running = true
                        batteryStatus.running = true
                        nightLightStatus.running = true
                        if (!resourceStatus.running)
                            resourceStatus.running = true
                    }
                }

                Process {
                    id: audioStatus
                    command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
                    stdout: StdioCollector {
                        onStreamFinished: {
                            const match = text.match(/Volume:\s+([0-9.]+)/)
                            if (match) bar.volume = Math.round(Number(match[1]) * 100)
                            bar.audioMuted = /MUTED/.test(text)
                        }
                    }
                }


                Process {
                    id: batteryStatus
                    command: ["bash", "-lc", "device=$(upower -e | grep battery | head -n1); test -n \"$device\" && upower -i \"$device\""]
                    stdout: StdioCollector {
                        onStreamFinished: {
                            let match = text.match(/percentage:\s+([0-9]+)%/)
                            if (match) bar.batteryPercent = Number(match[1])
                            match = text.match(/state:\s+([^\n]+)/)
                            if (match) bar.batteryState = match[1].trim()
                        }
                    }
                }

                Process {
                    id: resourceStatus
                    command: [Quickshell.env("HOME") + "/.config/quickshell/resource-status.sh"]
                    stdout: StdioCollector {
                        onStreamFinished: {
                            try {
                                const value = JSON.parse(text)
                                bar.resourceCpu = value.cpu
                                bar.resourceMemory = value.memory
                                bar.resourceGpu = value.gpu
                                bar.resourceMemoryUsed = value.memoryUsedGiB
                                bar.resourceMemoryTotal = value.memoryTotalGiB
                            } catch (exception) {
                                // Keep the last valid sample when a transient read fails.
                            }
                        }
                    }
                }

                Process {
                    id: nightLightStatus
                    command: [Quickshell.env("HOME") + "/.config/hypr/hyprsunset-control.sh", "status"]
                    stdout: StdioCollector {
                        onStreamFinished: {
                            try {
                                const status = JSON.parse(text)
                                bar.nightLightState = status.class || "unavailable"
                                const match = status.text.match(/([0-9]+)K/)
                                bar.nightLightTemperature = match ? match[1] : ""
                            } catch (error) {
                                bar.nightLightState = "unavailable"
                                bar.nightLightTemperature = ""
                            }
                        }
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: Theme.background

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 7
                        anchors.rightMargin: 7
                        spacing: 4

                        BarButton {
                            icon: ""
                            active: bar.activePanel === "system"
                            accessibleName: "System controls"
                            onClicked: anchor => bar.togglePanel("system", anchor)
                        }

                        RowLayout {
                            spacing: 2
                            Repeater {
                                model: 10
                                delegate: Rectangle {
                                    required property int index
                                    readonly property int workspaceId: index + 1
                                    readonly property bool focused: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === workspaceId
                                    implicitWidth: 24
                                    implicitHeight: 24
                                    radius: 7
                                    color: focused ? Theme.elevated : workspaceMouse.containsMouse ? Theme.hover : "transparent"
                                    Text {
                                        anchors.centerIn: parent
                                        text: parent.workspaceId
                                        color: parent.focused ? Theme.accent : Theme.muted
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 10
                                        font.weight: parent.focused ? Font.DemiBold : Font.Normal
                                    }
                                    MouseArea {
                                        id: workspaceMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: workspaceAction.running = true
                                    }
                                    Process {
                                        id: workspaceAction
                                        command: ["hyprctl", "dispatch", "hl.dsp.focus({ workspace = " + parent.workspaceId + " })"]
                                    }
                                }
                            }
                        }

                        Item { Layout.fillWidth: true }

                        BarButton {
                            icon: ""
                            label: "W" + bar.isoWeek(bar.now) + " · " + Qt.formatDateTime(bar.now, "ddd HH:mm")
                            active: bar.activePanel === "clock"
                            accessibleName: "Calendar"
                            onClicked: anchor => bar.togglePanel("clock", anchor)
                        }

                        Item { Layout.fillWidth: true }

                        BarButton {
                            icon: Networking.wifiEnabled ? "󰤨" : "󰤮"
                            active: bar.activePanel === "network"
                            accessibleName: "Wi-Fi"
                            onClicked: anchor => bar.togglePanel("network", anchor)
                        }

                        BarButton {
                            icon: bar.bluetoothPowered ? "󰂯" : "󰂲"
                            active: bar.activePanel === "bluetooth"
                            accessibleName: "Bluetooth"
                            onClicked: anchor => bar.togglePanel("bluetooth", anchor)
                        }

                        BarButton {
                            icon: bar.audioMuted ? "" : bar.volume < 35 ? "" : bar.volume < 70 ? "" : ""
                            label: bar.volume + "%"
                            active: bar.activePanel === "audio"
                            accessibleName: "Sound"
                            onClicked: anchor => bar.togglePanel("audio", anchor)
                            onWheel: delta => {
                                volumeAction.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", delta > 0 ? "5%+" : "5%-"]
                                volumeAction.running = true
                            }
                            Process { id: volumeAction; onExited: audioStatus.running = true }
                        }

                        BarButton {
                            icon: bar.nightLightState === "unavailable" ? "󰖨 ?" : "󰖨"
                            active: bar.nightLightState === "enabled"
                            accessibleName: bar.nightLightState === "unavailable"
                                ? "Start night light"
                                : "Night light " + (bar.nightLightState === "enabled" ? "on" : "off")
                                    + (bar.nightLightTemperature ? " at " + bar.nightLightTemperature + "K" : "")
                            onClicked: {
                                nightLightAction.command = bar.nightLightState === "unavailable"
                                    ? ["systemd-run", "--user", "--unit=quickshell-hyprsunset", "--collect", "hyprsunset"]
                                    : [Quickshell.env("HOME") + "/.config/hypr/hyprsunset-control.sh", "toggle"]
                                nightLightAction.running = true
                            }
                            onWheel: delta => {
                                if (bar.nightLightState !== "unavailable") {
                                    nightLightAction.command = [
                                        Quickshell.env("HOME") + "/.config/hypr/hyprsunset-control.sh",
                                        delta > 0 ? "cooler" : "warmer"
                                    ]
                                    nightLightAction.running = true
                                }
                            }
                            Process {
                                id: nightLightAction
                                onExited: nightLightRefreshDelay.restart()
                            }
                            Timer {
                                id: nightLightRefreshDelay
                                interval: 800
                                onTriggered: nightLightStatus.running = true
                            }
                        }

                        BarButton {
                            icon: "󰍛"
                            active: bar.activePanel === "resources"
                            label: "CPU " + bar.resourceCpu + "%  RAM " + bar.resourceMemoryUsed + "/" + bar.resourceMemoryTotal + " GB"
                            accessibleName: "System resources: CPU " + bar.resourceCpu + " percent, memory " + bar.resourceMemoryUsed + " of " + bar.resourceMemoryTotal + " gibibytes"
                            onClicked: anchor => bar.togglePanel("resources", anchor)
                        }
                        BarButton {
                            visible: bar.batteryPercent > 0
                            icon: bar.batteryState === "charging" ? "󰂄" : bar.batteryPercent > 75 ? "󰁹" : bar.batteryPercent > 40 ? "󰁾" : bar.batteryPercent > 15 ? "󰁻" : "󰂃"
                            label: bar.batteryPercent + "%"
                            active: bar.activePanel === "power"
                            accessibleName: "Battery"
                            onClicked: anchor => bar.togglePanel("power", anchor)
                        }
                    }
                }

                PopupWindow {
                    id: panel
                    visible: false
                    implicitWidth: 372
                    implicitHeight: contentLoader.item ? contentLoader.item.implicitHeight + 32 : 100
                    color: "transparent"

                    anchor {
                        item: bar.panelAnchor
                        edges: Edges.Top | Edges.Left
                        gravity: Edges.Top | Edges.Left
                        adjustment: PopupAdjustment.FlipX | PopupAdjustment.SlideX | PopupAdjustment.SlideY
                        margins.top: 7
                    }

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 4
                        radius: 14
                        color: Theme.surface
                        border.color: Theme.border
                        border.width: 1

                        Loader {
                            id: contentLoader
                            anchors.fill: parent
                            anchors.margins: 16
                            sourceComponent: bar.activePanel === "network" ? networkComponent
                                : bar.activePanel === "bluetooth" ? bluetoothComponent
                                : bar.activePanel === "audio" ? audioComponent
                                : bar.activePanel === "power" ? powerComponent
                                : bar.activePanel === "clock" ? clockComponent
                                : bar.activePanel === "system" ? systemComponent
                                : bar.activePanel === "resources" ? resourcesComponent
                                : null
                        }
                    }

                    Shortcut {
                        sequence: "Escape"
                        onActivated: {
                            panel.visible = false
                            bar.activePanel = ""
                        }
                    }
                }

                HyprlandFocusGrab {
                    id: focusGrab
                    windows: [panel]
                    active: panel.visible
                    onCleared: {
                        panel.visible = false
                        bar.activePanel = ""
                    }
                }

                Component { id: networkComponent; NetworkPanel {} }
                Component { id: bluetoothComponent; BluetoothPanel {} }
                Component { id: audioComponent; AudioPanel {} }
                Component { id: powerComponent; PowerPanel {} }
                Component { id: clockComponent; ClockPanel {} }
                Component {
                    id: resourcesComponent
                    ResourcesPanel {
                        externalMetrics: true
                        cpu: bar.resourceCpu
                        memory: bar.resourceMemory
                        gpu: bar.resourceGpu
                        memoryUsedGiB: bar.resourceMemoryUsed
                        memoryTotalGiB: bar.resourceMemoryTotal
                    }
                }
                Component {
                    id: systemComponent
                    SystemPanel {
                        onCloseRequested: {
                            panel.visible = false
                            bar.activePanel = ""
                        }
                    }
                }
            }
        }
    }
}
