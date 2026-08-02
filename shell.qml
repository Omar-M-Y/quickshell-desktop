// shell.qml — desktop entry point
import Quickshell
import QtQuick

ShellRoot {

    // Startup overlay — covers everything until desktop is ready
    PanelWindow {
        id: startupOverlayWindow
        anchors.top: true
        anchors.bottom: true
        anchors.left: true
        anchors.right: true
        color: "transparent"
        exclusiveZone: -1
        z: 9999

        Rectangle {
            id: startupOverlay
            anchors.fill: parent
            color: "#000000"
            opacity: 1

            Component.onCompleted: fadeTimer.start()

            Timer {
                id: fadeTimer
                interval: 500
                onTriggered: fadeOut.start()
            }

            NumberAnimation {
                id: fadeOut
                target: startupOverlay
                property: "opacity"
                from: 1
                to: 0
                duration: 400
                easing.type: Easing.InOutCubic
                onFinished: startupOverlayWindow.visible = false
            }
        }
    }
}
