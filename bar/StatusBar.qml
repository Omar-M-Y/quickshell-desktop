import QtQuick
import Quickshell
import Quickshell.Hyprland
import "widgets"


Scope {
  Variants {
    model: Quickshell.screens

    delegate: Component {
      PanelWindow {
        id: bar

        required property var modelData
        property HyprlandMonitor monitor: Hyprland.monitorFor(modelData)

        color: "transparent"
        screen: modelData

        mask 
      }
    }
  }
}
