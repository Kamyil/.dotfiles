import QtQuick
import QtQuick.Layouts
import "."

RowLayout {
    required property string title
    property string subtitle: ""
    Layout.fillWidth: true
    spacing: 8

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 2
        Text {
            text: title
            color: Theme.foreground
            font.family: Theme.fontFamily
            font.pixelSize: 16
            font.weight: Font.DemiBold
        }
        Text {
            visible: subtitle.length > 0
            text: subtitle
            color: Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: 10
            elide: Text.ElideRight
            Layout.fillWidth: true
        }
    }
}
