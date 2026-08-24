pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    readonly property string themePath: Quickshell.env("HOME") + "/.local/state/dotfiles-theme/current/theme.json"
    property var palette: ({})

    function color(key, fallback) {
        const value = palette[key]
        return typeof value === "string" && value.length > 0 ? value : fallback
    }

    function reload() {
        themeFile.reload()
    }

    readonly property color background: color("background", "#14141a")
    readonly property color surface: color("surface", "#1f1f28")
    readonly property color elevated: color("elevated", "#2a2a37")
    readonly property color hover: color("selection", "#363646")
    readonly property color border: color("selection", "#363646")
    readonly property color foreground: color("foreground", "#dcd7ba")
    readonly property color muted: color("muted", "#9e9b93")
    readonly property color accent: color("accent", "#809ba7")
    readonly property color good: color("green", "#699469")
    readonly property color warning: color("yellow", "#c4b28a")
    readonly property color danger: color("red", "#c4746e")
    readonly property string fontFamily: "Berkeley Mono SemiBold SemiCondensed"
    readonly property real radius: 0

    property FileView themeFile: FileView {
        path: root.themePath
        watchChanges: true
        printErrors: false
        onLoaded: {
            try {
                root.palette = JSON.parse(text())
            } catch (error) {
                console.warn("Failed to parse theme:", error)
            }
        }
        onFileChanged: reload()
    }

    property IpcHandler themeIpc: IpcHandler {
        target: "theme"
        function reload(): void {
            root.reload()
        }
    }
}
