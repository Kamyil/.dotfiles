import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Networking
import Quickshell.Bluetooth
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray
import Quickshell.Services.Mpris
import Quickshell.Services.Notifications
import Quickshell.Services.UPower
import "."

ShellRoot {
    id: root
    property int updateCount: -1
    property string weatherTemperature: ""
    property string weatherCondition: ""
    property string nightLightState: "unavailable"
    property string nightLightTemperature: ""
    property bool nightLightStartupAttempted: false
    property string pickerMode: "clipboard"
    property string keyboardDevice: ""
    property string keyboardLayout: ""


    function ensureNightLight(): void {
        if (nightLightStartupAttempted)
            return
        nightLightStartupAttempted = true
        nightLightEnsure.running = true
    }
    readonly property var activeMediaPlayer: {
        const players = Mpris.players.values.filter(player => {
            const name = String(player.dbusName || "").toLowerCase()
            return !name.includes("playerctld")
        })
        for (const player of players) {
            if (player.isPlaying)
                return player
        }
        return players.length > 0 ? players[0] : null
    }
    readonly property var notifications: notificationServer.trackedNotifications.values

    PersistentProperties {
        id: notificationPreferences
        reloadableId: "quickshell-notification-preferences"
        property bool doNotDisturb: false
    }

    ListModel { id: toastModel }

    NotificationServer {
        id: notificationServer
        actionsSupported: true
        actionIconsSupported: true
        imageSupported: true
        persistenceSupported: true
        keepOnReload: true
        onNotification: notification => {
            notification.tracked = true
            if (!notificationPreferences.doNotDisturb) {
                toastModel.insert(0, {
                    notificationId: notification.id,
                    appName: notification.appName || "Notification",
                    summary: notification.summary || "Notification",
                    body: notification.body || "",
                    imageSource: notification.image || notification.appIcon || ""
                })
                while (toastModel.count > 3)
                    toastModel.remove(toastModel.count - 1)
            }
        }
    }

    function clearNotifications() {
        const current = notificationServer.trackedNotifications.values.slice()
        for (const notification of current)
            notification.tracked = false
        toastModel.clear()
    }

    function removeToast(notificationId) {
        for (let index = toastModel.count - 1; index >= 0; index--) {
            if (toastModel.get(index).notificationId === notificationId)
                toastModel.remove(index)
        }
    }

    function setDoNotDisturb(value) {
        notificationPreferences.doNotDisturb = value
        if (value)
            toastModel.clear()
    }



    Timer {
        interval: 21600000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: if (!globalUpdateStatus.running) globalUpdateStatus.running = true
    }

    Timer {
        interval: 900000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: if (!globalWeatherStatus.running) globalWeatherStatus.running = true
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: if (!keyboardStatus.running) keyboardStatus.running = true
    }

    Timer {
        interval: 4000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: if (!globalNightLightStatus.running) globalNightLightStatus.running = true
    }

    Process {
        id: globalUpdateStatus
        command: [Quickshell.env("HOME") + "/.config/quickshell/nix-update-status.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                const fields = text.trim().split("\t")
                root.updateCount = fields[0] === "updates" ? Number(fields[1]) : -1
            }
        }
    }

    Process {
        id: globalWeatherStatus
        command: [Quickshell.env("HOME") + "/.config/quickshell/weather-status.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                const first = text.trim().split("\n")[0].split("\t")
                if (first[0] === "current") {
                    root.weatherTemperature = first[2]
                    root.weatherCondition = first[4]
                }
            }
        }
    }

    Process {
        id: keyboardStatus
        command: [Quickshell.env("HOME") + "/.config/quickshell/keyboard-layout.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                const fields = text.trim().split("\t")
                root.keyboardDevice = fields.length > 1 ? fields[0] : ""
                root.keyboardLayout = fields.length > 1 ? fields[1] : ""
            }
        }
    }
    Process {
        id: keyboardSwitch
        onExited: keyboardStatus.running = true
    }

    Process {
        id: globalNightLightStatus
        command: [Quickshell.env("HOME") + "/.config/hypr/hyprsunset-control.sh", "status"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const status = JSON.parse(text)
                    root.nightLightState = status.class || "unavailable"
                    const match = status.text.match(/([0-9]+)K/)
                    root.nightLightTemperature = match ? match[1] : ""
                    if (root.nightLightState === "unavailable")
                        root.ensureNightLight()
                } catch (error) {
                    root.nightLightState = "unavailable"
                    root.nightLightTemperature = ""
                }
            }
        }
    }

    Process {
        id: nightLightEnsure
        command: ["systemd-run", "--user", "--unit=quickshell-hyprsunset", "--collect", "hyprsunset"]
        onExited: nightLightEnsureRefresh.restart()
    }
    Timer {
        id: nightLightEnsureRefresh
        interval: 800
        onTriggered: globalNightLightStatus.running = true
    }


    IpcHandler {
        target: "launcher"
        function toggle(): void {
            launcherWindow.visible = !launcherWindow.visible
        }
        function show(): void {
            launcherWindow.visible = true
        }
        function hide(): void {
            launcherWindow.visible = false
        }
    }
    function lockSession(): void {
        if (!lockProcess.running)
            lockProcess.running = true
    }

    Process {
        id: lockProcess
        command: ["hyprlock"]
    }

    Process { id: dpmsProcess }

    IdleMonitor {
        timeout: 300
        onIsIdleChanged: if (isIdle) root.lockSession()
    }

    IdleMonitor {
        timeout: 600
        onIsIdleChanged: {
            dpmsProcess.command = ["hyprctl", "dispatch", "dpms", isIdle ? "off" : "on"]
            dpmsProcess.running = true
        }
    }

    IpcHandler {
        target: "session"
        function lock(): void { root.lockSession() }
    }

    function showPicker(mode: string): void {
        const alreadyVisible = pickerWindow.visible
        pickerMode = mode
        pickerWindow.visible = true
        if (alreadyVisible)
            pickerContent.reset()
    }

    IpcHandler {
        target: "picker"
        function clipboard(): void { root.showPicker("clipboard") }
        function emoji(): void { root.showPicker("emoji") }
        function image(): void { root.showPicker("image") }
        function hide(): void { pickerWindow.visible = false }
    }


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
                readonly property var battery: UPower.displayDevice
                readonly property int batteryPercent: battery && battery.ready ? Math.round(battery.percentage * 100) : 0
                readonly property bool batteryCharging: battery && (battery.state === UPowerDeviceState.Charging || battery.state === UPowerDeviceState.PendingCharge)
                property date now: new Date()
                readonly property string nightLightState: root.nightLightState
                readonly property string nightLightTemperature: root.nightLightTemperature
                property int resourceCpu: 0
                property string resourceMemoryUsed: "0.0"
                property string resourceMemoryTotal: "0.0"
                property int resourceMemory: 0
                property int resourceGpu: -1
                readonly property var microphone: Pipewire.defaultAudioSource
                readonly property string activeWindowTitle: Hyprland.activeToplevel ? Hyprland.activeToplevel.title : ""
                readonly property int updateCount: root.updateCount
                readonly property string weatherTemperature: root.weatherTemperature
                readonly property string weatherCondition: root.weatherCondition



                PwObjectTracker { objects: bar.microphone ? [bar.microphone] : [] }

                function isoWeek(date) {
                    const day = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()))
                    const weekday = day.getUTCDay() || 7
                    day.setUTCDate(day.getUTCDate() + 4 - weekday)
                    const yearStart = new Date(Date.UTC(day.getUTCFullYear(), 0, 1))
                    return Math.ceil((((day - yearStart) / 86400000) + 1) / 7)
                }

                function workspaceById(id) {
                    for (const workspace of Hyprland.workspaces.values) {
                        if (workspace.id === id)
                            return workspace
                    }
                    return null
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
                        BarButton {
                            icon: "󰍉"
                            active: launcherWindow.visible
                            accessibleName: "Application launcher"
                            onClicked: launcherWindow.visible = !launcherWindow.visible
                        }

                        BarButton {
                            visible: bar.updateCount > 0
                            icon: "󰏔"
                            label: bar.updateCount
                            active: true
                            accessibleName: bar.updateCount + " Nix flake updates available"
                        }


                        RowLayout {
                            spacing: 2
                            Repeater {
                                model: 10
                                delegate: Rectangle {
                                    required property int index
                                    readonly property int workspaceId: index + 1
                                    readonly property bool focused: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === workspaceId
                                    readonly property var workspace: bar.workspaceById(workspaceId)
                                    readonly property bool occupied: !!workspace
                                    implicitWidth: 24
                                    implicitHeight: 24
                                    radius: 7
                                    color: focused ? Theme.elevated : occupied || workspaceMouse.containsMouse ? Theme.hover : "transparent"
                                    Text {
                                        anchors.centerIn: parent
                                        text: parent.workspaceId
                                        color: parent.focused ? Theme.accent : Theme.muted
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 10
                                        font.weight: parent.focused ? Font.DemiBold : Font.Normal
                                    }
                                    Rectangle {
                                        visible: parent.occupied && !parent.focused
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        anchors.bottom: parent.bottom
                                        anchors.bottomMargin: 2
                                        width: 3
                                        height: 3
                                        radius: 2
                                        color: Theme.accent
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
                                        command: ["hyprctl", "dispatch", "workspace", String(parent.workspaceId)]
                                    }
                                }
                            }
                        }

                        BarButton {
                            visible: bar.activeWindowTitle.length > 0
                            icon: "󰣆"
                            label: bar.activeWindowTitle
                            accessibleName: "Active window: " + bar.activeWindowTitle
                            Layout.maximumWidth: 280
                        }
                        RowLayout {
                            visible: !!root.activeMediaPlayer
                            spacing: 0
                            BarButton {
                                icon: "󰒮"
                                accessibleName: "Previous track"
                                onClicked: if (root.activeMediaPlayer) root.activeMediaPlayer.previous()
                            }
                            BarButton {
                                icon: root.activeMediaPlayer && root.activeMediaPlayer.isPlaying ? "󰏤" : "󰐊"
                                label: {
                                    if (!root.activeMediaPlayer) return ""
                                    const artist = root.activeMediaPlayer.trackArtist || ""
                                    const title = root.activeMediaPlayer.trackTitle || root.activeMediaPlayer.identity || ""
                                    return artist.length > 0 ? artist + " — " + title : title
                                }
                                Layout.maximumWidth: 280
                                active: root.activeMediaPlayer && root.activeMediaPlayer.isPlaying
                                accessibleName: root.activeMediaPlayer && root.activeMediaPlayer.isPlaying ? "Pause media" : "Play media"
                                onClicked: if (root.activeMediaPlayer) root.activeMediaPlayer.togglePlaying()
                            }
                            BarButton {
                                icon: "󰒭"
                                accessibleName: "Next track"
                                onClicked: if (root.activeMediaPlayer) root.activeMediaPlayer.next()
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
                        BarButton {
                            icon: "󰖙"
                            label: bar.weatherTemperature.length > 0 ? bar.weatherTemperature + "°" : ""
                            active: bar.activePanel === "weather"
                            accessibleName: bar.weatherCondition.length > 0
                                ? "Weather: " + bar.weatherTemperature + " degrees, " + bar.weatherCondition
                                : "Weather"
                            onClicked: anchor => bar.togglePanel("weather", anchor)
                        }


                        Item { Layout.fillWidth: true }

                        BarButton {
                            visible: root.keyboardLayout.length > 0
                            icon: "󰌌"
                            label: root.keyboardLayout.replace("English (US)", "EN").replace("Polish", "PL")
                            accessibleName: "Keyboard layout: " + root.keyboardLayout
                            onClicked: {
                                keyboardSwitch.command = ["hyprctl", "switchxkblayout", root.keyboardDevice, "next"]
                                keyboardSwitch.running = true
                            }
                        }

                        Repeater {
                            model: SystemTray.items
                            delegate: Rectangle {
                                id: trayItem
                                required property var modelData
                                implicitWidth: 25
                                implicitHeight: 25
                                radius: 7
                                color: trayMouse.containsMouse ? Theme.hover : "transparent"
                                Image {
                                    anchors.centerIn: parent
                                    width: 16
                                    height: 16
                                    source: trayItem.modelData.icon
                                    sourceSize.width: 32
                                    sourceSize.height: 32
                                }
                                MouseArea {
                                    id: trayMouse
                                    anchors.fill: parent
                                    acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: mouse => {
                                        if (mouse.button === Qt.MiddleButton)
                                            trayItem.modelData.secondaryActivate()
                                        else if (mouse.button === Qt.RightButton || trayItem.modelData.onlyMenu)
                                            trayItem.modelData.display(bar, trayItem.x + mouse.x, trayItem.y)
                                        else
                                            trayItem.modelData.activate()
                                    }
                                    onWheel: wheel => trayItem.modelData.scroll(wheel.angleDelta.y, false)
                                }
                                ToolTip {
                                    visible: trayMouse.containsMouse
                                    text: trayItem.modelData.tooltipTitle || trayItem.modelData.title
                                }
                            }
                        }
                        BarButton {
                            icon: notificationPreferences.doNotDisturb ? "󰂛" : root.notifications.length > 0 ? "󰂚" : "󰂜"
                            label: root.notifications.length > 0 ? root.notifications.length : ""
                            active: bar.activePanel === "notifications" || root.notifications.length > 0
                            accessibleName: notificationPreferences.doNotDisturb
                                ? "Notifications: do not disturb"
                                : root.notifications.length + " notifications"
                            onClicked: anchor => bar.togglePanel("notifications", anchor)
                        }


                        BarButton {
                            icon: Networking.wifiEnabled ? "󰤨" : "󰤮"
                            active: bar.activePanel === "network"
                            accessibleName: "Wi-Fi"
                            onClicked: anchor => bar.togglePanel("network", anchor)
                        }

                        BarButton {
                            visible: !!bar.microphone
                            icon: bar.microphone && bar.microphone.audio && bar.microphone.audio.muted ? "󰍭" : "󰍬"
                            active: bar.microphone && bar.microphone.audio && !bar.microphone.audio.muted
                            accessibleName: bar.microphone && bar.microphone.audio && bar.microphone.audio.muted ? "Unmute microphone" : "Mute microphone"
                            onClicked: {
                                if (bar.microphone && bar.microphone.audio)
                                    bar.microphone.audio.muted = !bar.microphone.audio.muted
                            }
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
                            icon: "󰍹"
                            active: bar.activePanel === "display"
                            accessibleName: "Display controls"
                            onClicked: anchor => bar.togglePanel("display", anchor)
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
                                onTriggered: globalNightLightStatus.running = true
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
                            icon: bar.batteryCharging ? "󰂄" : bar.batteryPercent > 75 ? "󰁹" : bar.batteryPercent > 40 ? "󰁾" : bar.batteryPercent > 15 ? "󰁻" : "󰂃"
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
                                : bar.activePanel === "display" ? displayComponent
                                : bar.activePanel === "weather" ? weatherComponent
                                : bar.activePanel === "notifications" ? notificationsComponent
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
                Component { id: displayComponent; MonitorPanel {} }
                Component { id: weatherComponent; WeatherPanel {} }
                Component {
                    id: notificationsComponent
                    NotificationCenter {
                        notifications: root.notifications
                        doNotDisturb: notificationPreferences.doNotDisturb
                        onDoNotDisturbChangedByUser: value => root.setDoNotDisturb(value)
                        onClearRequested: root.clearNotifications()
                    }
                }
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
                        onLockRequested: {
                            panel.visible = false
                            bar.activePanel = ""
                            root.lockSession()
                        }
                    }
                }
            }
        }
    }
    PanelWindow {
        id: launcherWindow
        visible: false
        screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
        anchors { top: true; bottom: true; left: true; right: true }
        exclusiveZone: 0
        color: Qt.rgba(0, 0, 0, 0.45)
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        MouseArea {
            anchors.fill: parent
            onClicked: launcherWindow.visible = false
        }
        ApplicationLauncher {
            id: launcherContent
            anchors.centerIn: parent
            width: 620
            height: Math.min(520, launcherWindow.height - 80)
            onCloseRequested: launcherWindow.visible = false
        }
        onVisibleChanged: if (visible) launcherContent.reset()
    }

    HyprlandFocusGrab {
        windows: [launcherWindow]
        active: launcherWindow.visible
        onCleared: launcherWindow.visible = false
    }

    PanelWindow {
        id: pickerWindow
        visible: false
        screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
        anchors { top: true; bottom: true; left: true; right: true }
        exclusiveZone: 0
        color: Qt.rgba(0, 0, 0, 0.45)
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        MouseArea { anchors.fill: parent; onClicked: pickerWindow.visible = false }
        PickerPanel {
            id: pickerContent
            anchors.centerIn: parent
            width: 620
            height: Math.min(520, pickerWindow.height - 80)
            mode: root.pickerMode
            onCloseRequested: pickerWindow.visible = false
        }
        onVisibleChanged: if (visible) pickerContent.reset()
    }
    HyprlandFocusGrab {
        windows: [pickerWindow]
        active: pickerWindow.visible
        onCleared: pickerWindow.visible = false
    }

    PanelWindow {
        id: notificationToasts
        visible: toastModel.count > 0 && !notificationPreferences.doNotDisturb
        screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
        anchors { top: true; right: true }
        margins { top: 42; right: 12 }
        exclusiveZone: 0
        implicitWidth: 370
        implicitHeight: toastColumn.implicitHeight + 16
        color: "transparent"

        ColumnLayout {
            id: toastColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            spacing: 8
            Repeater {
                model: toastModel
                delegate: Rectangle {
                    id: toastCard
                    required property int notificationId
                    required property string appName
                    required property string summary
                    required property string body
                    required property string imageSource
                    Layout.fillWidth: true
                    implicitHeight: toastContent.implicitHeight + 24
                    radius: 12
                    color: Theme.surface
                    border.color: Theme.border
                    border.width: 1

                    RowLayout {
                        id: toastContent
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 12
                        spacing: 10
                        Image {
                            visible: source.toString().length > 0
                            source: toastCard.imageSource
                            Layout.preferredWidth: visible ? 36 : 0
                            Layout.preferredHeight: visible ? 36 : 0
                            fillMode: Image.PreserveAspectFit
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Text { text: toastCard.appName; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 8; elide: Text.ElideRight; Layout.fillWidth: true }
                            Text { text: toastCard.summary; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: 11; font.weight: Font.DemiBold; wrapMode: Text.Wrap; Layout.fillWidth: true }
                            Text { visible: text.length > 0; text: toastCard.body; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 9; wrapMode: Text.Wrap; textFormat: Text.PlainText; Layout.fillWidth: true }
                        }
                        Button { text: "×"; onClicked: root.removeToast(toastCard.notificationId) }
                    }
                    Timer {
                        interval: 8000
                        running: true
                        onTriggered: root.removeToast(toastCard.notificationId)
                    }
                }
            }
        }
    }
}
