import QtQuick
import QtQuick.Layouts
import "."

Rectangle {
    id: root

    required property string icon
    property string label: ""
    property bool active: false
    property string accessibleName: label
    signal clicked(var anchor)
    signal wheel(real delta)

    implicitWidth: content.implicitWidth + 16
    implicitHeight: 26
    radius: 7
    color: active ? Theme.elevated : mouse.containsMouse ? Theme.hover : "transparent"

    RowLayout {
        id: content
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: root.icon
            color: root.active ? Theme.accent : Theme.foreground
            font.family: Theme.fontFamily
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
