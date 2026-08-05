import QtQuick
import "./widgets"

Item {
    id: root
    implicitHeight: 35
    width: row.width + 20

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 10
        spacing: 8

        SystemTray {}
    }
}
