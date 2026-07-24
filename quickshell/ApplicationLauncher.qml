import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import "."

Item {
    id: root
    implicitWidth: 620
    implicitHeight: 520
    signal closeRequested()
    property string query: search.text

    function normalized(value) { return String(value || "").toLowerCase() }
    function score(entry) {
        const needle = normalized(query).trim()
        if (!needle) return 0
        const name = normalized(entry.name)
        const generic = normalized(entry.genericName)
        const keywords = normalized(entry.keywords)
        if (name === needle) return 100
        if (name.startsWith(needle)) return 80
        if (name.includes(needle)) return 60
        if (generic.includes(needle)) return 40
        if (keywords.includes(needle)) return 20
        return -1
    }
    function results() {
        const values = DesktopEntries.applications.values.filter(entry => entry && !entry.noDisplay && score(entry) >= 0)
        values.sort((a, b) => {
            const difference = score(b) - score(a)
            return difference !== 0 ? difference : String(a.name).localeCompare(String(b.name))
        })
        return values.slice(0, 40)
    }
    function launch(entry) {
        if (!entry) return
        entry.execute()
        closeRequested()
    }
    function reset() {
        search.text = ""
        selectedIndex = 0
        search.forceActiveFocus()
    }
    property int selectedIndex: 0
    onQueryChanged: selectedIndex = 0

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: Theme.surface
        border.color: Theme.border
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 10
            TextField {
                id: search
                Layout.fillWidth: true
                placeholderText: "Search applications…"
                color: Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: 14
                selectByMouse: true
                Keys.onEscapePressed: root.closeRequested()
                Keys.onDownPressed: root.selectedIndex = Math.min(resultsRepeater.count - 1, root.selectedIndex + 1)
                Keys.onUpPressed: root.selectedIndex = Math.max(0, root.selectedIndex - 1)
                Keys.onReturnPressed: if (resultsRepeater.itemAt(root.selectedIndex)) root.launch(resultsRepeater.itemAt(root.selectedIndex).entry)
                Keys.onEnterPressed: if (resultsRepeater.itemAt(root.selectedIndex)) root.launch(resultsRepeater.itemAt(root.selectedIndex).entry)
            }
            Text {
                text: "APPLICATIONS"
                color: Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: 9
                font.weight: Font.DemiBold
            }
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                ColumnLayout {
                    width: parent.width
                    spacing: 3
                    Repeater {
                        id: resultsRepeater
                        model: root.results()
                        delegate: ActionRow {
                            required property var modelData
                            required property int index
                            property var entry: modelData
                            title: modelData.name || modelData.id
                            subtitle: modelData.genericName || modelData.comment || "Application"
                            icon: "󰣆"
                            trailing: index === root.selectedIndex ? "Enter" : ""
                            selected: index === root.selectedIndex
                            onClicked: root.launch(modelData)
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.NoButton
                                onPositionChanged: root.selectedIndex = index
                            }
                        }
                    }
                    Text {
                        visible: resultsRepeater.count === 0
                        text: "No matching applications"
                        color: Theme.muted
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: 40
                    }
                }
            }
            Text {
                text: "↑↓ select   Enter launch   Esc close"
                color: Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: 8
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}
