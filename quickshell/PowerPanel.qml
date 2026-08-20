import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Services.UPower
import "."
import "PowerModel.js" as Model

Item {
    id: root

    implicitWidth: 340
    implicitHeight: 438

    readonly property var battery: UPower.displayDevice
    readonly property bool batteryPresent: !!root.battery && root.battery.isPresent
    readonly property bool onBattery: !!UPower.onBattery
    readonly property real batteryFraction: Model.batteryFraction(root.battery)
    readonly property int percentage: Math.round(root.batteryFraction * 100)
    readonly property bool discharging: root.batteryPresent && root.onBattery
    readonly property bool fullyCharged: root.batteryPresent
        && root.battery.state === UPowerDeviceState.FullyCharged
        && !root.chargeThresholdActive
    readonly property bool chargeThresholdActive: Model.chargeThresholdActive(
        root.battery,
        root.onBattery,
        root.upowerStates()
    )
    readonly property bool batteryFlowIdle: root.fullyCharged || root.chargeThresholdActive
    readonly property bool charging: root.batteryPresent && !root.onBattery && !root.batteryFlowIdle
    readonly property string stateName: Model.modeLabel(root.battery, root.onBattery, root.upowerStates())
    readonly property real remainingSeconds: root.discharging
        ? Number(root.battery.timeToEmpty || 0)
        : Number(root.battery ? root.battery.timeToFull : 0)
    readonly property string durationText: Model.duration(root.remainingSeconds)
    readonly property string rateText: Model.watts(root.battery ? root.battery.changeRate : 0)
    readonly property string capacityText: Model.energy(root.battery
        ? (root.battery.energyCapacity || root.battery.energyFull)
        : 0)
    readonly property string healthText: root.battery && root.battery.healthSupported
        ? Math.round(Number(root.battery.healthPercentage || 0) * 100) + "%"
        : "—"
    readonly property string cyclesText: root.battery && root.battery.chargeCycles !== undefined
        && Number(root.battery.chargeCycles) >= 0
        ? String(root.battery.chargeCycles)
        : "—"
    readonly property string timeLabel: root.chargeThresholdActive
        ? "Charge limit"
        : root.discharging ? "Time left" : "Time to full"
    readonly property string timeText: root.chargeThresholdActive
        ? (root.battery && root.battery.chargeStopThreshold !== undefined
            && Number(root.battery.chargeStopThreshold) > 0
            ? Math.round(Number(root.battery.chargeStopThreshold)) + "%"
            : "Holding")
        : (root.batteryFlowIdle ? "—" : (root.durationText || "—"))

    property var profiles: ["power-saver", "balanced", "performance"]
    property string activeProfile: ""
    property int profileIndex: 0

    function upowerStates() {
        return {
            Charging: UPowerDeviceState.Charging,
            Discharging: UPowerDeviceState.Discharging,
            FullyCharged: UPowerDeviceState.FullyCharged,
            PendingCharge: UPowerDeviceState.PendingCharge
        }
    }

    function refresh() {
        if (!profileListProc.running) profileListProc.running = true
        if (!profileGetProc.running) profileGetProc.running = true
    }

    function updateProfiles(raw) {
        var parsed = Model.parseProfiles(raw, root.profileIndex)
        if (parsed.profiles.length === 0) return
        root.profiles = parsed.profiles
        root.profileIndex = parsed.profileIndex
        if (parsed.activeProfile.length > 0) root.activeProfile = parsed.activeProfile
    }

    function updateActiveProfile(raw) {
        var value = String(raw || "").trim()
        if (value.length > 0) root.activeProfile = value
    }

    function setProfile(profile) {
        if (!profile || actionProc.running) return
        actionProc.command = ["powerprofilesctl", "set", profile]
        actionProc.running = true
    }

    Process {
        id: profileListProc
        command: ["powerprofilesctl", "list"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: root.updateProfiles(text)
        }
    }

    Process {
        id: profileGetProc
        command: ["powerprofilesctl", "get"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: root.updateActiveProfile(text)
        }
    }

    Process {
        id: actionProc
        onExited: refreshDelay.restart()
    }

    Timer {
        id: refreshDelay
        interval: 450
        onTriggered: root.refresh()
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        Heading {
            title: "Battery"
            subtitle: root.stateName
                + (root.durationText.length > 0 ? " · " + root.durationText : "")
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 88
            radius: Theme.radius
            color: Theme.elevated

            RowLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 12

                Text {
                    text: Model.batteryIcon(root.battery, root.onBattery, root.upowerStates())
                    color: root.percentage <= 15 && root.batteryPresent
                        ? Theme.danger
                        : root.charging ? Theme.good : Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: 28
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: root.batteryPresent ? root.stateName : "Unavailable"
                        color: Theme.foreground
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                    }

                    Text {
                        text: root.rateText.length > 0
                            ? root.rateText + (root.healthText !== "—"
                                ? " · " + root.healthText + " health" : "")
                            : "Power information unavailable"
                        color: Theme.muted
                        font.family: Theme.fontFamily
                        font.pixelSize: 9
                    }
                }

                Text {
                    text: root.batteryPresent ? root.percentage + "%" : "—"
                    color: Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: 22
                    font.weight: Font.DemiBold
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 8
            radius: height / 2
            color: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.12)

            Rectangle {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: Math.max(parent.height, parent.width * root.batteryFraction)
                height: parent.height
                radius: height / 2
                color: root.percentage <= 15 && root.batteryPresent
                    ? Theme.danger
                    : root.charging ? Theme.good : Theme.accent
                Behavior on width { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }
            }
        }

        Text {
            Layout.fillWidth: true
            text: "BATTERY STATS"
            color: Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: 9
            font.weight: Font.DemiBold
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 20

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                InfoPair { label: "Capacity"; value: root.capacityText || "—" }
                InfoPair { label: "Health"; value: root.healthText }
                InfoPair { label: "Cycles"; value: root.cyclesText }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                InfoPair { label: root.timeLabel; value: root.timeText }
                InfoPair { label: "Power rate"; value: root.rateText || "—" }
                InfoPair { label: "State"; value: root.stateName }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1
            color: Theme.border
        }

        Text {
            Layout.fillWidth: true
            text: "POWER PROFILE"
            color: Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: 9
            font.weight: Font.DemiBold
        }

        Repeater {
            model: root.profiles

            delegate: ActionRow {
                required property var modelData
                title: String(modelData).charAt(0).toUpperCase() + String(modelData).slice(1)
                subtitle: root.onBattery ? "Battery profile" : "AC profile"
                icon: Model.profileIcon(String(modelData))
                trailing: String(modelData) === root.activeProfile ? "Selected" : ""
                selected: String(modelData) === root.activeProfile
                onClicked: root.setProfile(String(modelData))
            }
        }

        Item { Layout.fillHeight: true }
    }

    component InfoPair: RowLayout {
        required property string label
        required property string value
        Layout.fillWidth: true
        spacing: 6

        Text {
            text: parent.label
            color: Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: 9
            elide: Text.ElideRight
        }

        Item { Layout.fillWidth: true }

        Text {
            text: parent.value
            color: Theme.foreground
            font.family: Theme.fontFamily
            font.pixelSize: 9
            horizontalAlignment: Text.AlignRight
            elide: Text.ElideLeft
        }
    }

    Component.onCompleted: root.refresh()
}
