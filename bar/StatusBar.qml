import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import "."

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
                implicitHeight: 200
                exclusiveZone: 0
                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
                WlrLayershell.namespace: "quickshell:statusbar"
margins.top: -35
                anchors {
                    top: true
                    left: true
                    right: true
                }

                mask: Region {
                    item: barHitbox
                }

                Item {
                    id: barHitbox
                    x: 0
                    y: 0
                    width: bar.width
                    height: 35
                }

                Left {
                    x: 0
                    y: 0
                    monitor: bar.monitor
                }

                Right {
                    anchors.right: parent.right
                    y: 0
                }
            }
        }
    }
}
