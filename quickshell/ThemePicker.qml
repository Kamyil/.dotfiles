import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Item {
    id: root

    property bool opened: false
    property var themes: []
    property int selectedIndex: 0
    property bool applying: false
    property string lastError: ""
    readonly property string helper: Quickshell.env("HOME") + "/.dotfiles/scripts/theme-picker-data"
    readonly property string switcher: Quickshell.env("HOME") + "/.dotfiles/scripts/theme"

    function open(): void {
        opened = true
        loader.running = true
    }

    function close(): void {
        opened = false
    }

    function toggle(): void {
        opened ? close() : open()
    }

    function selectAdjacent(step): void {
        if (themes.length === 0)
            return
        selectedIndex = (selectedIndex + step + themes.length) % themes.length
    }

    function relativeIndex(index): int {
        let relative = index - selectedIndex
        const half = Math.floor(themes.length / 2)
        if (relative > half)
            relative -= themes.length
        else if (relative < -half)
            relative += themes.length
        return relative
    }

    function applySelected(): void {
        if (applying || themes.length === 0)
            return
        applying = true
        applyProcess.command = [switcher, themes[selectedIndex].name]
        applyProcess.running = true
    }

    Process {
        id: loader
        command: [root.helper]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const payload = JSON.parse(text)
                    root.themes = payload.themes || []
                    root.selectedIndex = 0
                    for (let index = 0; index < root.themes.length; index++) {
                        if (root.themes[index].selected) {
                            root.selectedIndex = index
                            break
                        }
                    }
                    Qt.callLater(function() { carousel.forceActiveFocus() })
                } catch (error) {
                    root.lastError = String(error)
                    console.warn("Failed to load theme picker:", error)
                    root.close()
                }
            }
        }
    }

    Process {
        id: applyProcess
        onExited: {
            if (root.applying) {
                root.applying = false
                root.close()
            }
        }
    }

    IpcHandler {
        target: "themes"
        function openPicker(): string { root.open(); return root.opened ? "open" : "closed" }
        function closePicker(): void { root.close() }
        function togglePicker(): void { root.toggle() }
        function state(): string { return root.opened ? "open" : (root.lastError || "closed") }
    }

    PanelWindow {
        id: overlay
        visible: root.opened
        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "dotfiles-theme-picker"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: root.opened ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

        Rectangle {
            anchors.fill: parent
            color: "#d9000000"
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.close()
        }

        Item {
            id: carousel
            anchors.centerIn: parent
            width: Math.min(overlay.width - 80, 1180)
            height: Math.min(overlay.height - 100, 620)
            focus: true

            Keys.onEscapePressed: root.close()
            Keys.onLeftPressed: root.selectAdjacent(-1)
            Keys.onRightPressed: root.selectAdjacent(1)
            Keys.onReturnPressed: root.applySelected()
            Keys.onEnterPressed: root.applySelected()

            MouseArea { anchors.fill: parent; onClicked: {} }

            Repeater {
                model: root.themes.length

                delegate: Item {
                    id: card
                    required property int index
                    readonly property var entry: root.themes[index]
                    readonly property int relative: root.relativeIndex(index)
                    readonly property bool selected: relative === 0
                    readonly property bool nearby: Math.abs(relative) <= 6
                    readonly property real centerWidth: Math.min(760, carousel.width * 0.64)
                    readonly property real centerHeight: Math.min(470, carousel.height - 90)
                    readonly property real sliceWidth: 112
                    readonly property real sliceHeight: centerHeight * 0.91
                    readonly property real step: 78
                    readonly property real centerX: (carousel.width - centerWidth) / 2

                    visible: nearby
                    opacity: nearby ? 1 : 0
                    x: selected ? centerX : (relative < 0
                        ? centerX + relative * step
                        : centerX + centerWidth + 8 + (relative - 1) * step)
                    y: selected ? 0 : (centerHeight - sliceHeight) / 2
                    width: selected ? centerWidth : sliceWidth
                    height: selected ? centerHeight : sliceHeight
                    z: selected ? 100 : 50 - Math.abs(relative)

                    Behavior on x { NumberAnimation { duration: 190; easing.type: Easing.OutCubic } }
                    Behavior on y { NumberAnimation { duration: 190; easing.type: Easing.OutCubic } }
                    Behavior on width { NumberAnimation { duration: 190; easing.type: Easing.OutCubic } }
                    Behavior on height { NumberAnimation { duration: 190; easing.type: Easing.OutCubic } }

                    readonly property real skew: selected ? 0 : 28

                    Item {
                        id: mask
                        anchors.fill: parent
                        visible: false
                        layer.enabled: true

                        Shape {
                            anchors.fill: parent
                            antialiasing: true
                            preferredRendererType: Shape.CurveRenderer
                            ShapePath {
                                fillColor: "white"
                                strokeColor: "transparent"
                                startX: card.skew; startY: 0
                                PathLine { x: card.width; y: 0 }
                                PathLine { x: card.width - card.skew; y: card.height }
                                PathLine { x: 0; y: card.height }
                                PathLine { x: card.skew; y: 0 }
                            }
                        }
                    }

                    Item {
                        anchors.fill: parent
                        layer.enabled: true
                        layer.smooth: true
                        layer.effect: MultiEffect {
                            maskEnabled: true
                            maskSource: mask
                            maskThresholdMin: 0.3
                            maskSpreadAtMin: 0.3
                        }

                        Image {
                            anchors.fill: parent
                            source: card.nearby ? card.entry.preview : ""
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: true
                            smooth: true
                        }

                        Rectangle {
                            anchors.fill: parent
                            color: card.selected ? "transparent" : "#6b000000"
                        }
                    }

                    Shape {
                        anchors.fill: parent
                        antialiasing: true
                        preferredRendererType: Shape.CurveRenderer
                        ShapePath {
                            fillColor: "transparent"
                            strokeColor: card.selected ? Theme.accent : Theme.muted
                            strokeWidth: card.selected ? 3 : 1
                            startX: card.skew; startY: 0
                            PathLine { x: card.width; y: 0 }
                            PathLine { x: card.width - card.skew; y: card.height }
                            PathLine { x: 0; y: card.height }
                            PathLine { x: card.skew; y: 0 }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: card.selected ? root.applySelected() : root.selectedIndex = index
                    }
                }
            }

            Text {
                anchors.top: parent.top
                anchors.topMargin: Math.min(470, parent.height - 90) + 18
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.themes.length > 0 ? root.themes[root.selectedIndex].label : ""
                color: Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: 24
                font.weight: Font.DemiBold
            }

            Text {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.applying ? "Applying…" : "←  →  Select    Enter  Apply    Esc  Close"
                color: Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: 13
            }
        }
    }
}
