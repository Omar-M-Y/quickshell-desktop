import Quickshell
import QtQuick
import Quickshell.Hyprland

Item {
  id: root
  implicitHeight: 35
  required property HyprlandMonitor monitor
  width: workspaceRow.width

  Row {
    id: workspaceRow
    anchors.verticalCenter: parent.verticalCenter
    spacing: 8 

    Repeater {
      model: Hyprland.workspaces
      delegate: WorkspaceItem {
        required property HyprlandWorkspace modelData
        workspace: modelData
        visible: modelData.monitor === root.monitor
      }
    }
  }
}
