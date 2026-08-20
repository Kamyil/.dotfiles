import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import "."
import "MonitorModel.js" as Model

Item {
    id: root
    implicitWidth: 340
    implicitHeight: 580
    focus: true

    property int brightnessPercent: 0
    property bool brightnessAvailable: false
    property bool textSizeAvailable: false
    property int textSizePreviewIndex: -1
    property int textSizeCurrentPx: 12
    property string focusedMonitor: ""
    property string feedback: ""
    property var displays: []
    property int enabledDisplayCount: 0
    property string focusSection: "scale"
    property int selectedIndex: 0
    property bool cursorActive: false
    property real wheelAccumulator: 0
    readonly property var scalePresets: ["1", "1.25", "1.6", "2", "3", "4"]
    readonly property var textSizeStops: [9, 10, 11, 12, 14, 16, 20]
    readonly property var visibleSections: {
        var sections = []
        if (root.brightnessAvailable) sections.push("brightness")
        if (root.textSizeAvailable) sections.push("textsize")
        sections.push("scale")
        if (root.displays.length > 1) sections.push("monitors")
        return sections
    }
    readonly property var scaleValues: {
        for (var i = 0; i < root.displays.length; i++) {
            if (root.displays[i] && root.displays[i].focused)
                return Model.availableScales(root.scalePresets, root.displays[i].width, root.displays[i].height)
        }
        return root.scalePresets
    }

    function refresh() {
        if (!status.running) status.running = true
    }

    function parse(text) {
        var parsedDisplays = []
        var lines = String(text || "").trim().split("\n")
        for (var i = 0; i < lines.length; i++) {
            var fields = lines[i].split("\t")
            if (fields[0] === "brightness") {
                root.brightnessAvailable = true
                root.brightnessPercent = Model.clampBrightness(fields[1])
            } else if (fields[0] === "text-size-available") {
                root.textSizeAvailable = fields[1] === "true"
            } else if (fields[0] === "text-size") {
                var px = Number(fields[1])
                if (isFinite(px) && px >= 9 && px <= 20) root.textSizeCurrentPx = Math.round(px)
            } else if (fields[0] === "displays-json") {
                var result = Model.parseDisplays(fields.slice(1).join("\t"))
                parsedDisplays = result.displays
                root.enabledDisplayCount = result.enabledDisplayCount
            }
        }
        if (!lines.some(function(line) { return line.indexOf("brightness\t") === 0 })) {
            root.brightnessAvailable = false
            root.brightnessPercent = 0
        }
        root.displays = parsedDisplays
        root.focusedMonitor = ""
        for (var j = 0; j < root.displays.length; j++) {
            if (root.displays[j].focused) { root.focusedMonitor = root.displays[j].name; break }
        }
        clampCursor()
    }

    function sectionSingle(section) { return section === "brightness" || section === "textsize" || section === "scale" }
    function sectionCount(section) {
        if (section === "scale") return root.scaleValues.length
        if (section === "monitors") return root.displays.length
        return 0
    }
    function sectionFirst(section) { return sectionSingle(section) && section !== "scale" ? -1 : 0 }

    function moveCursor(delta) {
        var sections = root.visibleSections
        if (!sections.length) return
        var sectionIndex = sections.indexOf(root.focusSection)
        if (sectionIndex < 0) { root.focusSection = sections[0]; root.selectedIndex = sectionFirst(root.focusSection); return }
        var max = sectionSingle(root.focusSection) ? 0 : sectionCount(root.focusSection) - 1
        if (delta > 0 && !sectionSingle(root.focusSection) && root.selectedIndex < max) { root.selectedIndex++; return }
        if (delta < 0 && !sectionSingle(root.focusSection) && root.selectedIndex > 0) { root.selectedIndex--; return }
        var next = sectionIndex + (delta > 0 ? 1 : -1)
        if (next >= 0 && next < sections.length) {
            root.focusSection = sections[next]
            root.selectedIndex = sectionFirst(root.focusSection)
        }
    }

    function moveHorizontal(delta) {
        if (root.focusSection === "brightness") adjustBrightness(delta * 5)
        else if (root.focusSection === "textsize") adjustTextSize(delta)
        else if (root.focusSection === "scale") root.selectedIndex = Math.max(0, Math.min(root.scaleValues.length - 1, root.selectedIndex + delta))
    }

    function activate() {
        if (root.focusSection === "scale" && root.scaleValues[root.selectedIndex] !== undefined) setScale(root.scaleValues[root.selectedIndex])
        else if (root.focusSection === "monitors" && root.displays[root.selectedIndex]) {
            var display = root.displays[root.selectedIndex]
            if (!display.enabled || root.enabledDisplayCount > 1) toggleDisplay(display.name, display.enabled)
        }
    }

    function clampCursor() {
        var sections = root.visibleSections
        if (!sections.length) return
        if (sections.indexOf(root.focusSection) < 0) { root.focusSection = sections[0]; root.selectedIndex = sectionFirst(root.focusSection); return }
        if (sectionSingle(root.focusSection)) root.selectedIndex = root.focusSection === "scale" ? Math.max(0, Math.min(root.scaleValues.length - 1, root.selectedIndex)) : -1
        else root.selectedIndex = Math.max(0, Math.min(sectionCount(root.focusSection) - 1, root.selectedIndex))
    }

    function adjustBrightness(delta) {
        if (!root.brightnessAvailable) return
        setBrightness(root.brightnessPercent + delta)
    }
    function setBrightness(value) {
        root.brightnessPercent = Model.clampBrightness(value)
        action.command = ["brightnessctl", "set", root.brightnessPercent + "%"]
        if (!action.running) action.running = true
    }
    function adjustTextSize(delta) {
        if (!root.textSizeAvailable) return
        var current = root.textSizePreviewIndex >= 0 ? root.textSizePreviewIndex : 3
        root.textSizePreviewIndex = Math.max(0, Math.min(root.textSizeStops.length - 1, current + delta))
        action.command = ["omarchy-display-text-size", String(root.textSizeStops[root.textSizePreviewIndex])]
        if (!action.running) action.running = true
    }
    function toggleDisplay(name, enabled) {
        if (!name || (enabled && root.enabledDisplayCount <= 1)) return
        action.command = ["hyprctl", "keyword", "monitor", name + (enabled ? ",disable" : ",preferred,auto,auto")]
        if (!action.running) action.running = true
    }
    function setScale(scale) {
        var display = root.displays.find(function(item) { return item.focused })
        if (!display) return
        var clean = Model.cleanScale(scale, display.width, display.height)
        action.command = ["hyprctl", "keyword", "monitor", display.name + "," + display.width + "x" + display.height + "@" + display.refreshRate + "," + display.x + "x" + display.y + "," + clean]
        if (!action.running) action.running = true
    }
    function focusedDisplay() {
        for (var i = 0; i < root.displays.length; i++)
            if (root.displays[i] && root.displays[i].focused) return root.displays[i]
        return null
    }
    function brightnessName(value) { return Model.brightnessName(value) }

    function nearestTextIndex(px) {
        var best = 0
        var distance = Infinity
        for (var i = 0; i < root.textSizeStops.length; i++) {
            var candidateDistance = Math.abs(root.textSizeStops[i] - px)
            if (candidateDistance < distance) { distance = candidateDistance; best = i }
        }
        return best
    }

    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_J || event.key === Qt.Key_Down) {
            root.cursorActive = true; moveCursor(1); event.accepted = true
        } else if (event.key === Qt.Key_K || event.key === Qt.Key_Up) {
            root.cursorActive = true; moveCursor(-1); event.accepted = true
        } else if (event.key === Qt.Key_H || event.key === Qt.Key_Left) {
            root.cursorActive = true; moveHorizontal(-1); event.accepted = true
        } else if (event.key === Qt.Key_L || event.key === Qt.Key_Right) {
            root.cursorActive = true; moveHorizontal(1); event.accepted = true
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
            root.cursorActive = true; activate(); event.accepted = true
        }
    }

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
    Timer {
        id: brightnessDelay
        interval: 150
        onTriggered: root.setBrightness(root.brightnessPercent)
    }
    Timer { interval: 5000; running: true; repeat: true; onTriggered: root.refresh() }

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        Item {
            Layout.fillWidth: true
            implicitHeight: Math.max(titleIcon.implicitHeight, titleColumn.implicitHeight)
            Text { id: titleIcon; text: root.displays.length > 1 ? "󰍺" : "󰍹"; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: 25; anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter }
            Column {
                id: titleColumn
                anchors.left: titleIcon.right; anchors.leftMargin: 12; anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; spacing: 1
                Text { text: "Display"; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: 16; font.bold: true }
                Text { text: root.brightnessAvailable ? root.brightnessName(root.brightnessPercent).toUpperCase() : "FIXED BRIGHTNESS"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 9; font.bold: true; font.letterSpacing: 1.1 }
            }
        }

        ScrollView {
            id: scrollArea
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ColumnLayout {
                id: content
                width: scrollArea.availableWidth
                spacing: 12

                Text { visible: root.brightnessAvailable; text: "BRIGHTNESS"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 9; font.bold: true }
                Rectangle {
                    visible: root.brightnessAvailable
                    Layout.fillWidth: true; implicitHeight: 56; radius: Theme.radius
                    color: root.cursorActive && root.focusSection === "brightness" ? Theme.hover : Theme.elevated
                    border.color: root.cursorActive && root.focusSection === "brightness" ? Theme.accent : Theme.border
                    RowLayout {
                        anchors.fill: parent; anchors.margins: 10; spacing: 10
                        Text { text: "󰃟"; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: 17 }
                        ThemeSlider {
                            id: brightnessSlider
                            Layout.fillWidth: true; from: 1; to: 100; value: root.brightnessPercent
                            onMoved: { root.brightnessPercent = Model.clampBrightness(value); brightnessDelay.restart() }
                            onPressedChanged: if (pressed) { root.cursorActive = true; root.focusSection = "brightness"; root.selectedIndex = -1 }
                        }
                        Text { text: root.brightnessPercent + "%"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 9; Layout.preferredWidth: 34; horizontalAlignment: Text.AlignRight }
                    }
                }

                Text { visible: root.textSizeAvailable; text: "TEXT SIZE"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 9; font.bold: true }
                Rectangle {
                    visible: root.textSizeAvailable
                    Layout.fillWidth: true; implicitHeight: 56; radius: Theme.radius
                    color: root.cursorActive && root.focusSection === "textsize" ? Theme.hover : Theme.elevated
                    border.color: root.cursorActive && root.focusSection === "textsize" ? Theme.accent : Theme.border
                    RowLayout {
                        anchors.fill: parent; anchors.margins: 10; spacing: 10
                        Text { text: "Aa"; color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: 14; font.bold: true }
                        ThemeSlider {
                            id: textSizeSlider
                            Layout.fillWidth: true; from: 0; to: root.textSizeStops.length - 1; stepSize: 1; value: root.textSizePreviewIndex >= 0 ? root.textSizePreviewIndex : root.nearestTextIndex(root.textSizeCurrentPx)
                            onMoved: { root.textSizePreviewIndex = Math.round(value) }
                            onPressedChanged: {
                                if (pressed) {
                                    root.cursorActive = true
                                    root.focusSection = "textsize"
                                    root.selectedIndex = -1
                                } else if (root.textSizePreviewIndex >= 0) {
                                    action.command = ["omarchy-display-text-size", String(root.textSizeStops[root.textSizePreviewIndex])]
                                    if (!action.running) action.running = true
                                }
                            }
                        }
                        Text { text: root.textSizeStops[root.textSizePreviewIndex >= 0 ? root.textSizePreviewIndex : root.nearestTextIndex(root.textSizeCurrentPx)] + "px"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 9; Layout.preferredWidth: 34; horizontalAlignment: Text.AlignRight }
                    }
                }

                Text { text: "SCALE"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 9; font.bold: true }
                RowLayout {
                    Layout.fillWidth: true; spacing: 5
                    Repeater {
                        model: root.scaleValues
                        ThemeButton {
                            required property string modelData
                            required property int index
                            Layout.fillWidth: true
                            text: {
                                var display = root.focusedDisplay()
                                var label = display ? Model.cleanScale(modelData, display.width, display.height) : Model.normalizeScale(modelData)
                                return label + "x"
                            }
                            selected: (root.cursorActive && root.focusSection === "scale" && root.selectedIndex === index)
                                || root.displays.some(function(item) { return item.focused && Model.normalizeScale(item.scale) === Model.normalizeScale(modelData) })
                            onClicked: { root.cursorActive = true; root.focusSection = "scale"; root.selectedIndex = index; root.setScale(modelData) }
                        }
                    }
                }

                Text { visible: root.displays.length > 1; text: "DISPLAYS"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 9; font.bold: true }
                Repeater {
                    model: root.displays
                    delegate: Rectangle {
                        required property var modelData
                        required property int index
                        Layout.fillWidth: true; implicitHeight: 52; radius: Theme.radius
                        readonly property bool canToggle: !modelData.enabled || root.enabledDisplayCount > 1
                        color: root.cursorActive && root.focusSection === "monitors" && root.selectedIndex === index ? Theme.hover : modelData.focused ? Theme.elevated : "transparent"
                        border.color: modelData.focused ? Theme.accent : Theme.border
                        opacity: canToggle ? 1 : 0.45
                        RowLayout {
                            anchors.fill: parent; anchors.margins: 10; spacing: 8
                            Text { text: "󰍹"; color: Theme.accent; font.family: Theme.fontFamily; font.pixelSize: 16 }
                            ColumnLayout {
                                Layout.fillWidth: true; spacing: 0
                                Text { text: modelData.name + (modelData.focused ? " · focused" : ""); color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: 10; font.bold: true; elide: Text.ElideRight; Layout.fillWidth: true }
                                Text { text: modelData.description + " · " + modelData.width + "×" + modelData.height + " @ " + Math.round(modelData.refreshRate) + " Hz"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 8; elide: Text.ElideRight; Layout.fillWidth: true }
                            }
                            Text { text: modelData.enabled ? "󰄬" : ""; color: Theme.good; font.family: Theme.fontFamily; font.pixelSize: 14 }
                        }
                        MouseArea {
                            anchors.fill: parent; hoverEnabled: true; enabled: parent.canToggle
                            onEntered: { root.cursorActive = true; root.focusSection = "monitors"; root.selectedIndex = index }
                            onClicked: root.toggleDisplay(modelData.name, modelData.enabled)
                        }
                    }
                }
                Text { visible: root.feedback.length > 0; text: root.feedback; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: 8; elide: Text.ElideRight; Layout.fillWidth: true }
            }
        }
    }

    Component.onCompleted: { root.refresh(); root.forceActiveFocus() }
}
