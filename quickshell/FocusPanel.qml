import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "."

Item {
    id: root
    implicitWidth: 340
    implicitHeight: 390
    property bool active: false
    property int remainingSeconds: 0
    property string activeLabel: ""
    property int selectedMinutes: 50
    signal startRequested(int seconds, string label)
    signal stopRequested()

    function durationText(seconds) {
        const minutes = Math.floor(seconds / 60)
        const remainder = seconds % 60
        return minutes + ":" + String(remainder).padStart(2, "0")
    }
    function setDuration(minutes) {
        selectedMinutes = minutes
        customMinutes.text = String(minutes)
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 12
        Heading {
            title: root.active ? "Focus mode" : "Start focus"
            subtitle: root.active ? "Distracting sites are blocked in Helium" : "Protect uninterrupted engineering time"
        }

        ColumnLayout {
            visible: !root.active
            Layout.fillWidth: true
            spacing: 8
            Text { text: "DURATION"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 9; font.weight: Font.DemiBold }
            RowLayout {
                Layout.fillWidth: true
                spacing: 6
                Repeater {
                    model: [25, 50, 90]
                    ThemeButton {
                        required property int modelData
                        Layout.fillWidth: true
                        text: modelData + "m"
                        selected: root.selectedMinutes === modelData
                        onClicked: root.setDuration(modelData)
                    }
                }
                ThemeTextField {
                    id: customMinutes
                    Layout.preferredWidth: 64
                    text: "50"
                    placeholderText: "min"
                    horizontalAlignment: TextInput.AlignHCenter
                    inputMethodHints: Qt.ImhDigitsOnly
                    validator: IntValidator { bottom: 1; top: 720 }
                    onTextChanged: {
                        const minutes = Number(text)
                        if (acceptableInput && minutes >= 1)
                            root.selectedMinutes = minutes
                    }
                }
                Text { text: "min"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 9 }
            }
            Text { text: "CURRENT TASK"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 9; font.weight: Font.DemiBold; Layout.topMargin: 8 }
            ThemeTextField {
                id: taskLabel
                Layout.fillWidth: true
                placeholderText: "Issue, task, or outcome"
                color: Theme.foreground
                font.family: Theme.fontFamily
            }
            SwitchRow {
                title: "Block distractions"
                subtitle: "X, YouTube, Reddit, Allegro and OLX in Helium"
                checked: true
                enabled: false
            }
            SwitchRow {
                title: "Do not disturb"
                subtitle: "Restore the previous notification state afterwards"
                checked: true
                enabled: false
            }
            ThemeButton {
                Layout.fillWidth: true
                text: "Start " + root.selectedMinutes + " minute focus"
                onClicked: root.startRequested(root.selectedMinutes * 60, taskLabel.text.trim())
            }
        }

        ColumnLayout {
            visible: root.active
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 16
            Text {
                text: root.durationText(root.remainingSeconds)
                color: Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: 40
                font.weight: Font.DemiBold
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 28
            }
            Text {
                text: root.activeLabel || "Protected focus time"
                color: Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: 11
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }
            Item { Layout.fillHeight: true }
            Text {
                text: "Stopping early immediately unblocks distracting sites."
                color: Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: 9
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }
            ThemeButton { Layout.fillWidth: true; text: "End focus early"; onClicked: root.stopRequested() }
        }
    }
}
