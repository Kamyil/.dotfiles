import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import "."

Rectangle {
    id: row
    required property string title
    property string subtitle: ""
    property string icon: ""
    property string iconSource: ""
    property string trailing: ""
    property bool selected: false
    signal clicked()

    Layout.fillWidth: true
    implicitHeight: subtitle.length > 0 ? 48 : 40
    radius: 8
    color: selected ? Theme.elevated : mouse.containsMouse ? Theme.hover : "transparent"

    Item {
        id: iconSlot
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        width: row.iconSource.length > 0 || row.icon.length > 0 ? 18 : 0
        height: 18

        IconImage {
            anchors.fill: parent
            source: row.iconSource
            visible: row.iconSource.length > 0
        }
        Text {
            anchors.centerIn: parent
            text: row.icon
            visible: row.iconSource.length === 0
            color: row.selected ? Theme.accent : Theme.foreground
            font.family: Theme.fontFamily
            font.pixelSize: 14
        }
    }
    Column {
        anchors.left: iconSlot.right
        anchors.leftMargin: iconSlot.width > 0 ? 10 : 0
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
