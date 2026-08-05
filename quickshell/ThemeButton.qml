import QtQuick
import QtQuick.Controls
import "."

Button {
    id: control

    property bool selected: false

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: 30
    leftPadding: 12
    rightPadding: 12
    topPadding: 6
    bottomPadding: 6
    opacity: enabled ? 1 : 0.45

    contentItem: Text {
        text: control.text
        color: control.selected ? Theme.background : Theme.foreground
        font.family: Theme.fontFamily
        font.pixelSize: 10
        font.weight: control.selected ? Font.DemiBold : Font.Medium
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        radius: 7
        color: control.selected ? Theme.accent
            : control.down ? Theme.hover
            : control.hovered ? Theme.elevated
            : "transparent"
        border.color: control.selected ? Theme.accent : control.hovered ? Theme.muted : Theme.border
        border.width: 1

    }
}
