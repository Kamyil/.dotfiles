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
    readonly property bool busy: profilesQuery.running || configsQuery.running || action.running
    signal statusChanged()
    readonly property string helper: Quickshell.env("HOME") + "/.config/quickshell/wireguard-control.sh"
    property var profileNames: ({})

    function refresh() {
        if (!profilesQuery.running && !action.running)
            profilesQuery.running = true
    }

    function parseProfiles(text) {
        profiles.clear()
        profileNames = ({})
        let record = ({})

        function addRecord() {
            if (record.TYPE === "wireguard") {
                profiles.append({
                    connectionName: record.NAME || "WireGuard",
                    imported: true,
                    connectionUuid: record.UUID || "",
                    deviceName: record.DEVICE || "",
                    connected: !!record.DEVICE && record.DEVICE !== "--"
                })
                profileNames[record.NAME] = true
            }
            record = ({})
        }

        for (const line of text.split("\n")) {
            const separator = line.indexOf(":")
            if (separator < 0)
                continue
            const key = line.slice(0, separator).trim()
            const value = line.slice(separator + 1).trim()
            if (key === "NAME" && Object.keys(record).length)
                addRecord()
            record[key] = value
        }
        if (Object.keys(record).length)
            addRecord()
        if (!configsQuery.running)
            configsQuery.running = true
    }

    function addConfigs(text) {
        for (const line of text.trim().split("\n")) {
            const name = line.trim()
            if (name && !profileNames[name]) {
                profiles.append({
                    connectionName: name,
                    connectionUuid: "",
                    deviceName: "",
                    connected: false,
                    imported: false
                })
            }
        }

    }

    function toggle(uuid, connected, name, imported) {
        if (!imported) {
            feedback = "Authenticate in the terminal to import " + name + "…"
            action.command = ["systemd-run", "--user", "--unit=quickshell-wireguard-import", "--collect", "--quiet", "kitty", "--class", "wireguard-auth", "--title", "WireGuard authentication", "-e", helper, "import", name]
        } else {
            feedback = (connected ? "Disconnecting " : "Connecting ") + name + "…"
            action.command = connected
                ? ["nmcli", "connection", "down", "uuid", uuid]
                : ["nmcli", "connection", "up", "uuid", uuid]
        }
        action.running = true
    }

    ListModel { id: profiles }

    Process {
        id: profilesQuery
        command: ["nmcli", "-m", "multiline", "-e", "no", "-f", "NAME,UUID,TYPE,DEVICE", "connection", "show"]
        stdout: StdioCollector { onStreamFinished: root.parseProfiles(text) }
        stderr: StdioCollector { onStreamFinished: if (text.trim()) root.feedback = text.trim() }
    }

    Process {
        id: configsQuery
        command: [root.helper, "list"]
        stdout: StdioCollector { onStreamFinished: root.addConfigs(text) }
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
                        required property string connectionUuid
                        required property string deviceName
                        required property bool connected
                        required property bool imported
                        title: connectionName
                        subtitle: connected ? "Connected on " + deviceName : imported ? "Disconnected" : "Ready to import"
                        icon: connected ? "󰌾" : imported ? "󰌿" : "󰐕"
                        trailing: connected ? "Disconnect" : imported ? "Connect" : "Import & connect"
                        selected: connected
                        enabled: !root.busy
                        opacity: enabled ? 1 : 0.55
                        onClicked: root.toggle(connectionUuid, connected, connectionName, imported)
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
