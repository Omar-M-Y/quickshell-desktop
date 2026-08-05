import Quickshell
import QtQuick

import Quickshell.Hyprland
import "."

Item {
  id: root
  required property HyprlandWorkspace workspace

  property bool isActive: Hyprland.focusedWorkspace && workspace.id === Hyprland.focusedWorkspace.id

  width: dot.width
  height: 35

  Rectangle {
    id: dot
    anchors.verticalCenter: parent.verticalCenter

    width: isActive ? 10 : 6
    height: width
    radius: width / 2

    color: isActive ? "#ffffff" : "#aaaaaa"

    Behavior on width {
      NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
    }

    Behavior on color {
      ColorAnimation { duration: 150 }
    }

    MouseArea {
      anchors.fill: parent
      onClicked: Hyprland.dispatch("workspace " + workspace.id)
      hoverEnabled: true
      onEntered: dot.opacity = 0.7
      onExited: dot.opacity = 1.0
    }
  }
}
