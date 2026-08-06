import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "."

Item {
    id: root
    implicitWidth: 340
    implicitHeight: Math.min(420, 150 + profiles.count * 50)

    property string feedback: ""
    readonly property bool busy: profilesQuery.running || action.running
    signal statusChanged()
    readonly property string helper: Quickshell.env("HOME") + "/.config/quickshell/wireguard-control.sh"

    function refresh() {
        if (!profilesQuery.running && !action.running)
            profilesQuery.running = true
    }

    function parseProfiles(text) {
        profiles.clear()
        for (const line of text.trim().split("\n")) {
            if (!line)
                continue
            const separator = line.lastIndexOf(":")
            if (separator < 0)
                continue
            const name = line.slice(0, separator).trim()
            const state = line.slice(separator + 1).trim()
            profiles.append({
                connectionName: name,
                connected: state === "active"
            })
        }
    }

    function toggle(name, connected) {
        feedback = (connected ? "Disconnecting " : "Connecting ") + name + "…"
        action.command = [
            "systemd-run", "--user", "--wait", "--unit=quickshell-wireguard-control",
            "--collect", "--quiet", "kitty", "--class", "wireguard-auth",
            "--title", "WireGuard authentication", "-e", helper,
            connected ? "down" : "up", name
        ]
        action.running = true
    }

    ListModel { id: profiles }

    Process {
        id: profilesQuery
        command: [root.helper, "list-status"]
        stdout: StdioCollector { onStreamFinished: root.parseProfiles(text) }
        stderr: StdioCollector { onStreamFinished: if (text.trim()) root.feedback = text.trim() }
    }

    Process {
        id: action
        stdout: StdioCollector { onStreamFinished: if (text.trim()) root.feedback = text.trim() }
        stderr: StdioCollector { onStreamFinished: if (text.trim()) root.feedback = text.trim() }
        onExited: {
            root.statusChanged()
            refreshDelay.restart()
        }
    }

    Timer {
        id: refreshDelay
        interval: 700
        onTriggered: root.refresh()
    }

    Component.onCompleted: refresh()

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "󰖂"
                color: Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: 27
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1
                Text {
                    text: "WireGuard VPN"
                    color: Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: 15
                    font.bold: true
                }
                Text {
                    text: profiles.count > 0 ? profiles.count + (profiles.count === 1 ? " PROFILE" : " PROFILES") : "NO PROFILES"
                    color: Theme.muted
                    font.family: Theme.fontFamily
                    font.pixelSize: 9
                    font.bold: true
                    font.letterSpacing: 1.4
                }
            }
            ThemeButton {
                text: root.busy ? "Refreshing…" : "Refresh"
                enabled: !root.busy
                onClicked: root.refresh()
            }
        }

        Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Theme.border }

        Text {
            visible: profiles.count === 0 && !profilesQuery.running
            Layout.fillWidth: true
            text: "No WireGuard profiles or configs found in /etc/wireguard."
            color: Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: 10
            wrapMode: Text.Wrap
        }

        ScrollView {
            visible: profiles.count > 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            ColumnLayout {
                width: parent.width
                spacing: 2

                Repeater {
                    model: profiles
                    delegate: ActionRow {
                        required property string connectionName
                        required property bool connected
                        title: connectionName
                        subtitle: connected ? "Connected via systemd" : "Disconnected"
                        icon: connected ? "󰌾" : "󰌿"
                        trailing: connected ? "Disconnect" : "Connect"
                        selected: connected
                        enabled: !root.busy
                        opacity: enabled ? 1 : 0.55
                        onClicked: root.toggle(connectionName, connected)
                    }
                }
            }
        }

        Text {
            visible: root.feedback.length > 0
            Layout.fillWidth: true
            text: root.feedback
            color: Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: 9
            elide: Text.ElideRight
        }
    }
}
