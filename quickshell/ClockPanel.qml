import QtQuick
import QtQuick.Layouts
import "."

Item {
    id: root
    implicitWidth: 340
    implicitHeight: 350

    property date now: new Date()
    property date shownMonth: new Date(now.getFullYear(), now.getMonth(), 1)
    readonly property var monthNames: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    readonly property var dayNames: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

    function cellDate(index) {
        const firstWeekday = (shownMonth.getDay() + 6) % 7
        return new Date(shownMonth.getFullYear(), shownMonth.getMonth(), index - firstWeekday + 1)
    }

    function moveMonth(offset) {
        shownMonth = new Date(shownMonth.getFullYear(), shownMonth.getMonth() + offset, 1)
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        Text {
            text: Qt.formatTime(root.now, "HH:mm")
            color: Theme.foreground
            font.family: Theme.fontFamily
            font.pixelSize: 30
            font.weight: Font.DemiBold
            Layout.alignment: Qt.AlignHCenter
        }
        Text {
            text: Qt.formatDate(root.now, "dddd, d MMMM yyyy")
            color: Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: 11
            Layout.alignment: Qt.AlignHCenter
        }

        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "‹"
                color: Theme.foreground
                font.pixelSize: 22
                MouseArea { anchors.fill: parent; anchors.margins: -8; cursorShape: Qt.PointingHandCursor; onClicked: root.moveMonth(-1) }
            }
            Text {
                Layout.fillWidth: true
                text: root.monthNames[root.shownMonth.getMonth()] + " " + root.shownMonth.getFullYear()
                color: Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignHCenter
            }
            Text {
                text: "›"
                color: Theme.foreground
                font.pixelSize: 22
                MouseArea { anchors.fill: parent; anchors.margins: -8; cursorShape: Qt.PointingHandCursor; onClicked: root.moveMonth(1) }
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 7
            columnSpacing: 4
            rowSpacing: 4

            Repeater {
                model: root.dayNames
                delegate: Text {
                    required property string modelData
                    text: modelData
                    color: Theme.muted
                    font.family: Theme.fontFamily
                    font.pixelSize: 9
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }
            }

            Repeater {
                model: 42
                delegate: Rectangle {
                    required property int index
                    readonly property date day: root.cellDate(index)
                    readonly property bool currentMonth: day.getMonth() === root.shownMonth.getMonth()
                    readonly property bool today: day.toDateString() === root.now.toDateString()
                    Layout.fillWidth: true
                    implicitHeight: 28
                    radius: 7
                    color: today ? Theme.accent : "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: parent.day.getDate()
                        color: parent.today ? Theme.background : parent.currentMonth ? Theme.foreground : Theme.muted
                        opacity: parent.currentMonth ? 1 : 0.45
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
