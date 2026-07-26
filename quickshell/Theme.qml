pragma Singleton

import QtQuick

QtObject {
    readonly property color background: "#111318"
    readonly property color surface: "#181820"
    readonly property color elevated: "#1f1f28"
    readonly property color hover: "#2a2a37"
    readonly property color border: "#363646"
    readonly property color foreground: "#cbc8bc"
    readonly property color muted: "#8e8a80"
    readonly property color accent: "#809ba7"
    readonly property color good: "#7e9579"
    readonly property color warning: "#a7956a"
    readonly property color danger: "#c27672"
    readonly property var appIconPalette: [
        "#c4746e",
        "#699469",
        "#c4b28a",
        "#809ba7",
        "#a292a3",
        "#8ea49e"
    ]
    readonly property string fontFamily: "Berkeley Mono SemiBold SemiCondensed"
}
