import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import "."
import "AudioModel.js" as Model

FocusScope {
    id: root
    implicitWidth: 340
    implicitHeight: Math.min(560, panelColumn.implicitHeight)
    focus: true
    activeFocusOnTab: true

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property var nodes: Pipewire.nodes ? Pipewire.nodes.values : []

    readonly property var candidateSinks: {
        var result = []
        for (var i = 0; i < nodes.length; i++) {
            var node = nodes[i]
            if (node && node.isSink && !node.isStream) result.push(node)
        }
        return result
    }
    readonly property var candidateSources: {
        var result = []
        for (var i = 0; i < nodes.length; i++) {
            var node = nodes[i]
            if (node && !node.isSink && !node.isStream && Model.isAudioSource(node)
                    && String(node.name || "") !== "quickshell") result.push(node)
        }
        return result
    }
    readonly property var candidateStreams: {
        var result = []
        for (var i = 0; i < nodes.length; i++) {
            var node = nodes[i]
            if (!Model.isPlaybackStream(node)) continue
            if (String(node.name || "").indexOf("omarchy_speaker_tuning") === 0) continue
            result.push(node)
        }
        return result
    }

    property var displaySinks: []
    property var displaySources: []
    property var displayStreams: []
    property string focusSection: "output"
    property int selectedIndex: -1
    property bool cursorActive: false

    readonly property bool hasOutput: !!(sink && sink.audio)
    readonly property bool hasInput: !!(source && source.audio)
    readonly property real outputVolume: hasOutput ? sink.audio.volume : 0
    readonly property bool outputMuted: hasOutput ? sink.audio.muted : false
    readonly property real inputVolume: hasInput ? source.audio.volume : 0
    readonly property bool inputMuted: hasInput ? source.audio.muted : false
    readonly property bool anyAudible: (hasOutput && !outputMuted) || (hasInput && !inputMuted)
    readonly property bool headerHasCursor: cursorActive && focusSection === "header"

    function listSnapshot(list) { return Model.listSnapshot(list) }
    function nodeLabel(node) { return Model.nodeLabel(node) }
    function sinkGlyph(node) { return Model.sinkGlyph(node) }
    function sourceGlyph(node) { return Model.sourceGlyph(node) }
    function streamLabel(node) { return Model.friendlyStreamLabel(Model.rawStreamLabel(node)) }
    function outputVolumeName(volume, muted) { return Model.outputVolumeName(volume, muted) }

    function setVolume(node, value) {
        if (node && node.audio) node.audio.volume = Math.max(0, Math.min(1.5, value))
    }
    function toggleMute(node) {
        if (node && node.audio) node.audio.muted = !node.audio.muted
    }
    function setOutputVolume(value) { setVolume(sink, Math.max(0, Math.min(1, value))); return outputVolume }
    function setInputVolume(value) { setVolume(source, Math.max(0, Math.min(1, value))) }
    function toggleOutputMute() { toggleMute(sink) }
    function toggleInputMute() { toggleMute(source) }
    function toggleAllMuted() {
        var mute = anyAudible
        if (hasOutput) sink.audio.muted = mute
        if (hasInput) source.audio.muted = mute
    }
    function setDefaultSink(node) {
        if (node) Pipewire.preferredDefaultAudioSink = node
    }
    function setDefaultSource(node) {
        if (node) Pipewire.preferredDefaultAudioSource = node
    }

    function sectionCount(section) {
        if (section === "output") return displaySinks.length
        if (section === "input") return displaySources.length
        if (section === "streams") return displayStreams.length
        return 0
    }
    function sectionVisible(section) {
        if (section === "output") return true
        if (section === "input") return hasInput || displaySources.length > 0
        return section === "streams" && displayStreams.length > 0
    }
    function sectionHasSlider(section) {
        return section === "output" || (section === "input" && hasInput)
    }
    readonly property var visibleSections: {
        var result = []
        if (sectionVisible("output")) result.push("output")
        if (sectionVisible("input")) result.push("input")
        if (sectionVisible("streams")) result.push("streams")
        return result
    }

    function clampCursor() {
        if (focusSection === "header") return
        var sections = visibleSections
        if (!sections.length) return
        if (sections.indexOf(focusSection) < 0) {
            focusSection = sections[0]
            selectedIndex = sectionHasSlider(focusSection) ? -1 : 0
            return
        }
        var floor = sectionHasSlider(focusSection) ? -1 : 0
        selectedIndex = Math.max(floor, Math.min(sectionCount(focusSection) - 1, selectedIndex))
    }
    function moveCursor(delta) {
        var sections = visibleSections
        if (!sections.length) return
        if (focusSection === "header") {
            if (delta > 0) {
                focusSection = sections[0]
                selectedIndex = sectionHasSlider(focusSection) ? -1 : 0
            }
            return
        }
        var sectionIndex = sections.indexOf(focusSection)
        if (sectionIndex < 0) { clampCursor(); return }
        var floor = sectionHasSlider(focusSection) ? -1 : 0
        var max = sectionCount(focusSection) - 1
        if (delta > 0 && selectedIndex < max) { selectedIndex++; return }
        if (delta < 0 && selectedIndex > floor) { selectedIndex--; return }
        if (delta > 0 && sectionIndex < sections.length - 1) {
            focusSection = sections[sectionIndex + 1]
            selectedIndex = sectionHasSlider(focusSection) ? -1 : 0
        } else if (delta < 0 && sectionIndex > 0) {
            focusSection = sections[sectionIndex - 1]
            var previousMax = sectionCount(focusSection) - 1
            selectedIndex = previousMax >= 0 ? previousMax : (sectionHasSlider(focusSection) ? -1 : 0)
        } else if (delta < 0) {
            focusSection = "header"
            selectedIndex = -1
        }
    }
    function adjustVolume(delta) {
        if (focusSection === "output" && selectedIndex === -1) { setOutputVolume(outputVolume + delta); return }
        if (focusSection === "input" && selectedIndex === -1) { setInputVolume(inputVolume + delta); return }
        if (focusSection === "streams" && selectedIndex >= 0 && selectedIndex < displayStreams.length)
            setVolume(displayStreams[selectedIndex], displayStreams[selectedIndex].audio.volume + delta)
    }
    function activateCursor() {
        if (focusSection === "header") { toggleAllMuted(); return }
        if (focusSection === "output") {
            if (selectedIndex < 0) toggleOutputMute()
            else setDefaultSink(displaySinks[selectedIndex])
        } else if (focusSection === "input") {
            if (selectedIndex < 0) toggleInputMute()
            else setDefaultSource(displaySources[selectedIndex])
        } else if (selectedIndex >= 0) toggleMute(displayStreams[selectedIndex])
    }
    function handleKey(event) {
        if (event.key === Qt.Key_Down || event.key === Qt.Key_J) {
            if (!cursorActive) cursorActive = true
            else moveCursor(1)
            event.accepted = true
        } else if (event.key === Qt.Key_Up || event.key === Qt.Key_K) {
            if (!cursorActive) cursorActive = true
            else moveCursor(-1)
            event.accepted = true
        } else if (event.key === Qt.Key_Left || event.key === Qt.Key_H) {
            if (cursorActive) adjustVolume(-0.05)
            event.accepted = true
        } else if (event.key === Qt.Key_Right || event.key === Qt.Key_L) {
            if (cursorActive) adjustVolume(0.05)
            event.accepted = true
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
            if (cursorActive) activateCursor()
            event.accepted = true
        } else if (event.key === Qt.Key_M) {
            if (!cursorActive) return
            if (focusSection === "streams" && selectedIndex >= 0) toggleMute(displayStreams[selectedIndex])
            else if (focusSection === "input") toggleInputMute()
            else if (focusSection === "header") toggleAllMuted()
            else toggleOutputMute()
            event.accepted = true
        }
    }

    function refreshDisplayModels() {
        if (!root.visible) return
        displaySinks = listSnapshot(candidateSinks)
        displaySources = listSnapshot(candidateSources)
        displayStreams = listSnapshot(candidateStreams).filter(function(node) { return !!(node && node.audio) })
        clampCursor()
    }

    onVisibleChanged: {
        if (visible) {
            cursorActive = false
            focusSection = "output"
            selectedIndex = -1
            refreshTimer.restart()
            forceActiveFocus()
        } else {
            displaySinks = []
            displaySources = []
            displayStreams = []
        }
    }
    onCandidateSinksChanged: if (visible) refreshTimer.restart()
    onCandidateSourcesChanged: if (visible) refreshTimer.restart()
    onCandidateStreamsChanged: if (visible) refreshTimer.restart()

    PwObjectTracker { objects: root.candidateSinks }
    PwObjectTracker { objects: root.candidateSources }
    PwObjectTracker { objects: root.candidateStreams }

    Timer {
        id: refreshTimer
        interval: 75
        repeat: false
        onTriggered: root.refreshDisplayModels()
    }

    Keys.onPressed: function(event) { root.handleKey(event) }

    ScrollView {
        id: scrollArea
        anchors.fill: parent
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ColumnLayout {
            id: panelColumn
            width: scrollArea.availableWidth
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                Text {
                    text: root.hasOutput && !root.outputMuted ? "" : ""
                    color: Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: 26
                    opacity: root.outputMuted ? 0.5 : 1
                }
                Heading {
                    title: "Audio"
                    subtitle: root.outputVolumeName(root.outputVolume, root.outputMuted).toUpperCase()
                }
                ThemeButton {
                    text: root.anyAudible ? "Mute" : "Unmute"
                    selected: root.headerHasCursor
                    onClicked: root.toggleAllMuted()
                    onHoveredChanged: if (hovered) {
                        root.cursorActive = true
                        root.focusSection = "header"
                        root.selectedIndex = -1
                    }
                }
            }

            SectionTitle { text: "OUTPUT" }
            VolumeRow {
                node: root.sink
                cursorSection: "output"
                cursorIndex: -1
                icon: root.hasOutput && root.outputMuted ? "" : ""
                maximum: 100
            }
            Repeater {
                model: root.displaySinks
                DeviceRow {
                    required property var modelData
                    required property int index
                    node: modelData
                    section: "output"
                    rowIndex: index
                    icon: root.sinkGlyph(modelData)
                    onActivated: root.setDefaultSink(node)
                }
            }

            Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Theme.border }
            ColumnLayout {
                Layout.fillWidth: true
                visible: root.sectionVisible("input")
                SectionTitle { text: "INPUT" }
                VolumeRow {
                    visible: root.hasInput
                    node: root.source
                    cursorSection: "input"
                    cursorIndex: -1
                    icon: root.inputMuted ? "󰍭" : "󰍬"
                    maximum: 100
                }
                Repeater {
                    model: root.displaySources
                    DeviceRow {
                        required property var modelData
                        required property int index
                        node: modelData
                        section: "input"
                        rowIndex: index
                        icon: root.sourceGlyph(modelData)
                        onActivated: root.setDefaultSource(node)
                    }
                }
            }

            Rectangle { visible: root.sectionVisible("streams"); Layout.fillWidth: true; implicitHeight: 1; color: Theme.border }
            ColumnLayout {
                Layout.fillWidth: true
                visible: root.sectionVisible("streams")
                SectionTitle { text: "APPLICATIONS" }
                Repeater {
                    model: root.displayStreams
                    VolumeRow {
                        required property var modelData
                        required property int index
                        node: modelData
                        cursorSection: "streams"
                        cursorIndex: index
                        icon: node && node.audio && node.audio.muted ? "󰝟" : "󰕾"
                        maximum: 150
                        compact: true
                    }
                }
            }
            Item { Layout.fillHeight: true; Layout.minimumHeight: 2 }
        }
    }

    component SectionTitle: Text {
        color: Theme.muted
        font.family: Theme.fontFamily
        font.pixelSize: 9
        font.weight: Font.DemiBold
        Layout.fillWidth: true
    }

    component VolumeRow: Rectangle {
        id: volumeRow
        required property var node
        property string icon: "󰕾"
        property string cursorSection: ""
        property int cursorIndex: -2
        property bool compact: false
        property real maximum: 100
        readonly property bool keyboardSelected: root.cursorActive
            && root.focusSection === cursorSection && root.selectedIndex === cursorIndex
        Layout.fillWidth: true
        implicitHeight: compact ? 52 : 62
        radius: Theme.radius
        color: keyboardSelected ? Theme.hover : Theme.elevated

        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 9
            Text {
                text: volumeRow.node && volumeRow.node.audio && volumeRow.node.audio.muted ? "" : volumeRow.icon
                color: volumeRow.node && volumeRow.node.audio && volumeRow.node.audio.muted ? Theme.muted : Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: 15
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.toggleMute(volumeRow.node)
                }
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text {
                    text: root.streamLabel(volumeRow.node)
                    color: Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                ThemeSlider {
                    Layout.fillWidth: true
                    from: 0
                    to: volumeRow.maximum
                    value: volumeRow.node && volumeRow.node.audio ? volumeRow.node.audio.volume * 100 : 0
                    onMoved: root.setVolume(volumeRow.node, value / 100)
                }
            }
            Text {
                text: Math.round(volumeRow.node && volumeRow.node.audio ? volumeRow.node.audio.volume * 100 : 0) + "%"
                color: Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: 9
                Layout.preferredWidth: 34
                horizontalAlignment: Text.AlignRight
            }
        }
        HoverHandler {
            onHoveredChanged: if (hovered) {
                root.cursorActive = true
                root.focusSection = volumeRow.cursorSection
                root.selectedIndex = volumeRow.cursorIndex
            }
        }
    }

    component DeviceRow: Rectangle {
        id: deviceRow
        required property var node
        required property string section
        required property int rowIndex
        property string icon: "󰓃"
        readonly property bool active: (section === "output" ? root.sink : root.source)
            && (section === "output" ? root.sink.id : root.source.id) === node.id
        readonly property bool keyboardSelected: root.cursorActive
            && root.focusSection === section && root.selectedIndex === rowIndex
        signal activated()
        Layout.fillWidth: true
        implicitHeight: 42
        radius: Theme.radius
        color: keyboardSelected ? Theme.hover : active ? Theme.elevated : "transparent"
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 9
            Text {
                text: deviceRow.icon
                color: deviceRow.active ? Theme.accent : Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: 14
                Layout.preferredWidth: 18
                horizontalAlignment: Text.AlignHCenter
            }
            Text {
                text: root.nodeLabel(deviceRow.node)
                color: Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: 10
                font.weight: deviceRow.active ? Font.DemiBold : Font.Normal
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
            Text {
                text: deviceRow.active ? "Selected" : ""
                color: Theme.good
                font.family: Theme.fontFamily
                font.pixelSize: 9
            }
        }
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onContainsMouseChanged: if (containsMouse) {
                root.cursorActive = true
                root.focusSection = deviceRow.section
                root.selectedIndex = deviceRow.rowIndex
            }
            onClicked: deviceRow.activated()
        }
    }
}
