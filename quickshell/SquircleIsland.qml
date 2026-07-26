import QtQuick
import QtQuick.Shapes
import "."

Item {
    id: root

    property real cornerRadius: 11
    property real cornerTension: 0.72

    Shape {
        anchors.fill: parent
        antialiasing: true

        ShapePath {
            fillColor: Theme.background
            strokeWidth: 0
            startX: 0
            startY: root.height

            PathLine { x: 0; y: root.cornerRadius }
            PathCubic {
                control1X: 0
                control1Y: root.cornerRadius * (1 - root.cornerTension)
                control2X: root.cornerRadius * (1 - root.cornerTension)
                control2Y: 0
                x: root.cornerRadius
                y: 0
            }
            PathLine { x: root.width - root.cornerRadius; y: 0 }
            PathCubic {
                control1X: root.width - root.cornerRadius * (1 - root.cornerTension)
                control1Y: 0
                control2X: root.width
                control2Y: root.cornerRadius * (1 - root.cornerTension)
                x: root.width
                y: root.cornerRadius
            }
            PathLine { x: root.width; y: root.height }
            PathLine { x: 0; y: root.height }
        }

        ShapePath {
            fillColor: "transparent"
            strokeColor: Theme.border
            strokeWidth: 1
            capStyle: ShapePath.FlatCap
            joinStyle: ShapePath.RoundJoin
            startX: 0.5
            startY: root.height

            PathLine { x: 0.5; y: root.cornerRadius }
            PathCubic {
                control1X: 0.5
                control1Y: root.cornerRadius * (1 - root.cornerTension)
                control2X: root.cornerRadius * (1 - root.cornerTension)
                control2Y: 0.5
                x: root.cornerRadius
                y: 0.5
            }
            PathLine { x: root.width - root.cornerRadius; y: 0.5 }
            PathCubic {
                control1X: root.width - root.cornerRadius * (1 - root.cornerTension)
                control1Y: 0.5
                control2X: root.width - 0.5
                control2Y: root.cornerRadius * (1 - root.cornerTension)
                x: root.width - 0.5
                y: root.cornerRadius
            }
            PathLine { x: root.width - 0.5; y: root.height }
        }
    }
}
