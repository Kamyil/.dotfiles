import QtQuick
import QtQuick.Layouts
import "."

Rectangle {
    id: root

    required property string icon
    property string iconFontFamily: Theme.fontFamily
    property string label: ""
    property bool tile: false
    readonly property bool hovered: mouse.containsMouse
    property bool active: false
    property string accessibleName: label
    signal clicked(var anchor)
    signal wheel(real delta)

    implicitWidth: tile ? 52 : content.implicitWidth + 16
    implicitHeight: tile ? 38 : 26
    radius: Theme.radius
    color: active ? Theme.elevated : mouse.containsMouse ? Theme.hover : tile ? Theme.elevated : "transparent"

    RowLayout {
        id: content
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: root.icon
            color: root.active ? Theme.accent : Theme.foreground
            font.family: root.iconFontFamily
            font.pixelSize: 14
        }

        Text {
            visible: root.label.length > 0
            text: root.label
            color: Theme.foreground
            font.family: Theme.fontFamily
            font.pixelSize: 11
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked(root)
        onWheel: event => root.wheel(event.angleDelta.y)
    }
}
