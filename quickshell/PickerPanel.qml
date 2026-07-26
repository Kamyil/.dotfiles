import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "."

Item {
    id: root
    implicitWidth: 620
    implicitHeight: 520
    property string mode: Quickshell.env("PICKER_MODE") || "clipboard"
    property string title: mode === "clipboard" ? "Clipboard history" : mode === "emoji" ? "Emoji" : "Images"
    property int selectedIndex: 0
    property string feedback: ""
    property string pendingValue: ""
    signal closeRequested()
    readonly property string helper: Qt.resolvedUrl("picker-data.py").toString().replace("file://", "")
    function rebuildFiltered() {
        visibleEntries.clear()
        const needle = search.text.toLowerCase().trim()
        for (let index = 0; index < entries.count && visibleEntries.count < 80; index++) {
            const row = entries.get(index)
            if (!needle || row.label.toLowerCase().includes(needle) || row.value.toLowerCase().includes(needle))
                visibleEntries.append({ value: row.value, label: row.label })
        }
        selectedIndex = 0
    }
    function reset() { search.text = ""; feedback = ""; selectedIndex = 0; load.running = true; search.forceActiveFocus() }
    function revealSelected() {
        Qt.callLater(() => {
            if (mode === "emoji") {
                emojiGrid.positionViewAtIndex(selectedIndex, GridView.Contain)
                return
            }
            const row = entriesRepeater.itemAt(selectedIndex)
            const flickable = entriesScroll.contentItem
            if (!row || !flickable) return
            const top = row.y
            const bottom = top + row.height
            if (top < flickable.contentY)
                flickable.contentY = top
            else if (bottom > flickable.contentY + flickable.height)
                flickable.contentY = bottom - flickable.height
        })
    }
    onSelectedIndexChanged: revealSelected()
    function choose(value) {
        if (select.running) return
        pendingValue = value
        feedback = ""
        select.command = ["python3", helper, mode, "select", value]
        select.running = true
    }
    ListModel { id: entries }
    ListModel { id: visibleEntries }
    Process {
        id: load
        command: ["python3", root.helper, root.mode, "list"]
        stdout: StdioCollector { onStreamFinished: {
            entries.clear()
            for (const line of text.split("\n")) { const split = line.indexOf("\t"); if (split > 0) entries.append({ value: line.slice(0, split), label: line.slice(split + 1) }) }
            root.rebuildFiltered()
        } }
        stderr: StdioCollector { onStreamFinished: if (text.trim()) root.feedback = text.trim() }
    }
    Process {
        id: select
        stderr: StdioCollector { onStreamFinished: if (text.trim()) root.feedback = text.trim() }
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                root.closeRequested()
                pasteDelay.restart()
            } else if (!root.feedback) {
                root.feedback = "Could not copy the selected entry"
            }
        }
    }
    Process { id: paste; command: ["wtype", "-M", "ctrl", "-P", "v", "-p", "v", "-m", "ctrl"] }
    Timer { id: pasteDelay; interval: 180; onTriggered: paste.running = true }
    Rectangle {
        anchors.fill: parent; radius: 16; color: Theme.surface; border.color: Theme.border
        ColumnLayout {
            anchors.fill: parent; anchors.margins: 16; spacing: 10
            Heading { title: root.title; subtitle: root.mode === "image" ? "Copy an image to the clipboard" : "Select to copy" }
            ThemeTextField {
                id: search; Layout.fillWidth: true; placeholderText: "Search…"; color: Theme.foreground; font.family: Theme.fontFamily
                onTextChanged: root.rebuildFiltered()
                Keys.onEscapePressed: root.closeRequested()
                Keys.onDownPressed: root.selectedIndex = Math.min(visibleEntries.count - 1, root.selectedIndex + (root.mode === "emoji" ? emojiGrid.columns : 1))
                Keys.onUpPressed: root.selectedIndex = Math.max(0, root.selectedIndex - (root.mode === "emoji" ? emojiGrid.columns : 1))
                Keys.onLeftPressed: if (root.mode === "emoji") root.selectedIndex = Math.max(0, root.selectedIndex - 1)
                Keys.onRightPressed: if (root.mode === "emoji") root.selectedIndex = Math.min(visibleEntries.count - 1, root.selectedIndex + 1)
                Keys.onReturnPressed: if (root.selectedIndex >= 0 && root.selectedIndex < visibleEntries.count) root.choose(visibleEntries.get(root.selectedIndex).value)
            }
            GridView {
                id: emojiGrid
                visible: root.mode === "emoji"
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                readonly property int columns: 10
                cellWidth: width / columns
                cellHeight: cellWidth
                model: visibleEntries
                delegate: Rectangle {
                    required property string value
                    required property string label
                    required property int index
                    width: emojiGrid.cellWidth
                    height: emojiGrid.cellHeight
                    radius: 8
                    color: index === root.selectedIndex ? Theme.elevated : emojiMouse.containsMouse ? Theme.hover : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: value
                        color: Theme.foreground
                        font.family: "Noto Color Emoji"
                        font.pixelSize: 26
                    }
                    MouseArea {
                        id: emojiMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: root.selectedIndex = parent.index
                        onClicked: root.choose(parent.value)
                    }
                    ToolTip.visible: emojiMouse.containsMouse
                    ToolTip.text: label
                    ToolTip.delay: 500
                }
            }
            ScrollView {
                id: entriesScroll
                visible: root.mode !== "emoji"
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                ColumnLayout {
                    width: parent.width
                    spacing: 3
                    Repeater {
                        id: entriesRepeater
                        model: visibleEntries
                        delegate: Rectangle {
                            required property string value
                            required property string label
                            required property int index
                            readonly property bool selected: index === root.selectedIndex
                            Layout.fillWidth: true
                            implicitHeight: root.mode === "image" ? 48 : 40
                            radius: 8
                            color: selected ? Theme.elevated : rowMouse.containsMouse ? Theme.hover : "transparent"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 10
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1
                                    Text { text: label; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: 11; elide: Text.ElideRight; Layout.fillWidth: true }
                                    Text { visible: root.mode === "image"; text: value; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 9; elide: Text.ElideMiddle; Layout.fillWidth: true }
                                }
                                Text { visible: parent.parent.selected; text: "Paste"; color: Theme.accent; font.family: Theme.fontFamily; font.pixelSize: 11 }
                            }
                            MouseArea {
                                id: rowMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: root.selectedIndex = parent.index
                                onClicked: root.choose(parent.value)
                            }
                        }
                    }
                }
            }
            Text { visible: visibleEntries.count === 0; text: "No matching entries"; color: Theme.muted; font.family: Theme.fontFamily; Layout.alignment: Qt.AlignHCenter }
            Text { visible: root.feedback.length > 0; text: root.feedback; color: Theme.danger; font.family: Theme.fontFamily; font.pixelSize: 9; wrapMode: Text.Wrap; Layout.fillWidth: true }
        }
    }
    Component.onCompleted: reset()
}
