import QtQuick
import QtQuick.Layouts
import "."

Rectangle {
    id: row
    required property string title
    property string subtitle: ""
    property bool checked: false
    signal toggled(bool checked)

    Layout.fillWidth: true
    implicitHeight: subtitle.length > 0 ? 52 : 42
    radius: 9
    color: mouse.containsMouse ? Theme.hover : Theme.elevated

    Column {
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - toggle.width - 38
        spacing: 2
        Text {
            width: parent.width
            text: row.title
            color: Theme.foreground
            font.family: Theme.fontFamily
            font.pixelSize: 12
            elide: Text.ElideRight
        }
        Text {
            visible: row.subtitle.length > 0
            width: parent.width
            text: row.subtitle
            color: Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: 10
            elide: Text.ElideRight
        }
    }

    Rectangle {
        id: toggle
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        width: 36
        height: 20
        radius: 10
        color: row.checked ? Theme.accent : Theme.border
        Rectangle {
            width: 16
            height: 16
            radius: 8
            y: 2
            x: row.checked ? 18 : 2
            color: Theme.foreground
            Behavior on x { NumberAnimation { duration: 130; easing.type: Easing.OutCubic } }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: row.toggled(!row.checked)
    }
}
