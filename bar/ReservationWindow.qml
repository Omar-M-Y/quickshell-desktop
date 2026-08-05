import QtQuick
import Quickshell
import Quickshell.Wayland

Scope {
    Variants {
        model: Quickshell.screens
        delegate: Component {
            PanelWindow {
                required property var modelData
                screen: modelData
                color: "transparent"
                implicitHeight: 35
                exclusiveZone: 35
                exclusionMode: ExclusionMode.Normal
                WlrLayershell.layer: WlrLayer.Top
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
                WlrLayershell.namespace: "quickshell:reservation:top"

                anchors {
                    top: true
                    left: true
                    right: true
                }
            }
        }
    }
}
