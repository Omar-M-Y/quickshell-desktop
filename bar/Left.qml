import QtQuick
import Quickshell.Hyprland
import "./widgets"

Rectangle {
    id: root
    required property HyprlandMonitor monitor
    implicitHeight: 35
    width: row.width + 20
    // anchors.leftMargin: 10
    color: "#000000"
    border.color: "#cccccc" // Temp Colors going to match with matugen later
    border.width: 0.5
    radius: width / 3 

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 10
        spacing: 10 

        Rectangle {
          implicitHeight: 24
          width: workspaces.width + 12
          radius: workspaces.width / 2 
          color: "#222222" // Replace colours later
          border.color: "#444444"
          border.width: 1 
          anchors.verticalCenter: parent.verticalCenter
        // widgets go here
          Workspaces {
            id: workspaces
            monitor: root.monitor
            anchors.centerIn: parent
          }

        }

        Rectangle {
            implicitHeight: 24
            width: activeWindow.width + 12
            radius: height / 2
            color: "#222222"
            border.color: "#444444"
            border.width: 1
            anchors.verticalCenter: parent.verticalCenter

            ActiveWindow {
                id: activeWindow
                anchors.centerIn: parent
            }
        }
    }
}
