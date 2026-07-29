import QtQuick
import QtQuick.Controls
import "."

Dialog {
    id: control

    modal: true
    padding: 16
    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Theme.motionFast; easing.type: Easing.OutCubic }
        NumberAnimation { property: "scale"; from: 0.97; to: 1; duration: Theme.motionPanel; easing.type: Easing.OutCubic }
    }
    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1; to: 0; duration: Theme.motionFast; easing.type: Easing.InCubic }
        NumberAnimation { property: "scale"; from: 1; to: 0.97; duration: Theme.motionFast; easing.type: Easing.InCubic }
    }

    background: Rectangle {
        color: Theme.elevated
        border.color: Theme.border
        border.width: 1
        radius: 10
    }

    header: Rectangle {
        visible: control.title.length > 0
        implicitHeight: visible ? 42 : 0
        color: "transparent"

        Text {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            anchors.bottomMargin: 8
            text: control.title
            color: Theme.foreground
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.weight: Font.DemiBold
            elide: Text.ElideRight
        }
    }

    footer: DialogButtonBox {
        visible: count > 0
        standardButtons: control.standardButtons
        spacing: 8
        leftPadding: 16
        rightPadding: 16
        topPadding: 8
        bottomPadding: 16
        alignment: Qt.AlignRight
        background: Item {}
        delegate: ThemeButton {}
    }
}
