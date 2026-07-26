import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "."

Item {
    id: root
    implicitWidth: 340
    implicitHeight: 390

    property var wallpapers: []
    property string currentWallpaper: ""
    property bool loading: true
    readonly property string controller: Quickshell.env("HOME") + "/.config/quickshell/wallpaper-control.sh"

    function refresh() {
        if (!listProcess.running)
            listProcess.running = true
    }

    function run(action) {
        if (wallpaperAction.running)
            return
        wallpaperAction.command = [controller, action]
        wallpaperAction.running = true
    }

    function select(file) {
        if (wallpaperAction.running || file === currentWallpaper)
            return
        wallpaperAction.command = [controller, "set", file]
        wallpaperAction.running = true
    }

    function displayName(name) {
        return name.length > 0 ? name.charAt(0).toUpperCase() + name.slice(1) : name
    }

    Component.onCompleted: refresh()

    Process {
        id: listProcess
        command: [root.controller, "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const result = JSON.parse(text)
                    root.wallpapers = result.wallpapers || []
                    root.currentWallpaper = result.current || ""
                } catch (error) {
                    root.wallpapers = []
                    root.currentWallpaper = ""
                }
                root.loading = false
            }
        }
    }

    Process {
        id: wallpaperAction
        onExited: refreshDelay.restart()
    }

    Timer {
        id: refreshDelay
        interval: 250
        onTriggered: root.refresh()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        Heading {
            title: "Wallpapers"
            subtitle: root.loading
                ? "Loading collection…"
                : root.wallpapers.length + " scenes · click to apply"
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            ThemeButton {
                Layout.fillWidth: true
                text: "󰒮  Previous"
                enabled: !wallpaperAction.running && root.wallpapers.length > 1
                onClicked: root.run("previous")
            }
            ThemeButton {
                Layout.fillWidth: true
                text: "󰒟  Random"
                enabled: !wallpaperAction.running && root.wallpapers.length > 1
                onClicked: root.run("random")
            }
            ThemeButton {
                Layout.fillWidth: true
                text: "Next  󰒭"
                enabled: !wallpaperAction.running && root.wallpapers.length > 1
                onClicked: root.run("next")
            }
        }

        GridView {
            id: wallpaperGrid
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: root.wallpapers
            cellWidth: 170
            cellHeight: 122
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar {}

            delegate: Item {
                id: card
                required property var modelData
                width: wallpaperGrid.cellWidth
                height: wallpaperGrid.cellHeight
                readonly property bool selected: card.modelData.file === root.currentWallpaper

                Rectangle {
                    anchors.fill: parent
                    anchors.rightMargin: 6
                    anchors.bottomMargin: 6
                    radius: 7
                    color: Theme.elevated
                    border.color: card.selected ? Theme.accent : cardMouse.containsMouse ? Theme.muted : Theme.border
                    border.width: card.selected ? 2 : 1
                    clip: true

                    Image {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        height: 82
                        source: card.modelData.source
                        sourceSize.width: 320
                        sourceSize.height: 180
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: true
                    }

                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: 31
                        color: card.selected ? Theme.hover : Theme.surface

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 8
                            anchors.right: selectedMark.left
                            anchors.rightMargin: 4
                            anchors.verticalCenter: parent.verticalCenter
                            text: root.displayName(card.modelData.name)
                            color: card.selected ? Theme.foreground : Theme.muted
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            font.weight: card.selected ? Font.DemiBold : Font.Normal
                            elide: Text.ElideRight
                        }

                        Text {
                            id: selectedMark
                            anchors.right: parent.right
                            anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            text: card.selected ? "󰄬" : ""
                            color: Theme.accent
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                        }
                    }

                    MouseArea {
                        id: cardMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.select(card.modelData.file)
                    }
                }
            }
        }
    }
}
