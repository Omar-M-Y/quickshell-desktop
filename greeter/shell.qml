import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Greetd
import QtQuick
import "./views"

ShellRoot {
    Settings { id: settings }

    PanelWindow {
        anchors.top: true
        anchors.bottom: true
        anchors.left: true
        anchors.right: true
        color: "transparent"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        Loader {
            anchors.fill: parent
            active: settings.isTest
            sourceComponent: Tester {}
        }

        Loader {
            anchors.fill: parent
            active: settings.isGreetd
            sourceComponent: Greeter {}
        }

        Loader {
            anchors.fill: parent
            active: settings.isLockd
            sourceComponent: Locker {}
        }
    }
}
