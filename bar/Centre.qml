import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import "./widgets"

Scope {
    Variants {
        model: Quickshell.screens
        delegate: Component {
            PanelWindow {
                id: centreWindow
                required property var modelData
                color: "transparent"
                screen: modelData
                implicitHeight: 200
                exclusiveZone: 0
                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
                WlrLayershell.namespace: "quickshell:centre"
                margins.top: -35

                anchors {
                    top: true
                    left: true
                    right: true
                }

                mask: Region {
                    item: pill
                }

                MusicPill {
                    id: pill
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    parentWindow: centreWindow
                }
            }
        }
    }
}
