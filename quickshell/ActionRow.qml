import QtQuick
import QtQuick.Layouts
import "."

Rectangle {
    id: row
    required property string title
    property string subtitle: ""
    property string icon: ""
    property string trailing: ""
    property bool selected: false
    signal clicked()

    Layout.fillWidth: true
    implicitHeight: subtitle.length > 0 ? 48 : 40
    radius: 8
    color: selected ? Theme.elevated : mouse.containsMouse ? Theme.hover : "transparent"

    Text {
        id: glyph
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        text: row.icon
        color: row.selected ? Theme.accent : Theme.foreground
        font.family: Theme.fontFamily
        font.pixelSize: 14
    }
    Column {
        anchors.left: glyph.right
        anchors.leftMargin: row.icon.length > 0 ? 10 : 0
        anchors.right: tail.left
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2
        Text {
            width: parent.width
            text: row.title
            color: Theme.foreground
            font.family: Theme.fontFamily
            font.pixelSize: 11
            elide: Text.ElideRight
        }
        Text {
            visible: row.subtitle.length > 0
            width: parent.width
            text: row.subtitle
            color: Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: 9
            elide: Text.ElideRight
        }
    }
    Text {
        id: tail
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        text: row.trailing
        color: row.selected ? Theme.good : Theme.muted
        font.family: Theme.fontFamily
        font.pixelSize: 10
    }
    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: row.clicked()
    }
}
