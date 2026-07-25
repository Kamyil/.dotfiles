import QtQuick
import QtQuick.Controls
import "."

Slider {
    id: control

    implicitWidth: 150
    implicitHeight: 28
    leftPadding: 0
    rightPadding: 0
    topPadding: 7
    bottomPadding: 7

    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: 150
        implicitHeight: 4
        width: control.availableWidth
        height: implicitHeight
        radius: 2
        color: Theme.border

        Rectangle {
            width: control.visualPosition * parent.width
            height: parent.height
            radius: parent.radius
            color: Theme.accent
        }
    }

    handle: Rectangle {
        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: 14
        implicitHeight: 14
        radius: 7
        color: control.pressed ? Theme.accent : Theme.foreground
        border.color: Theme.background
        border.width: 2
    }
}
