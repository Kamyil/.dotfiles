import QtQuick
import QtQuick.Controls
import "."

Dialog {
    id: control

    modal: true
    padding: 16

    background: Rectangle {
        color: Theme.elevated
        border.color: Theme.border
        border.width: 1
        radius: Theme.radius
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
