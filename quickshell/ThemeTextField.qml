import QtQuick
import QtQuick.Controls
import "."

TextField {
    id: control

    implicitHeight: 34
    leftPadding: 11
    rightPadding: 11
    topPadding: 7
    bottomPadding: 7
    color: Theme.foreground
    placeholderTextColor: Theme.muted
    selectionColor: Theme.accent
    selectedTextColor: Theme.background
    font.family: Theme.fontFamily
    font.pixelSize: 10
    selectByMouse: true

    background: Rectangle {
        radius: 8
        color: control.enabled ? Theme.background : Theme.surface
        border.color: control.activeFocus ? Theme.accent : control.hovered ? Theme.muted : Theme.border
        border.width: control.activeFocus ? 2 : 1

    }
}
