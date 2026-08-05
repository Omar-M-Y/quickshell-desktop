import QtQuick
import Quickshell
import Quickshell.Services.SystemTray

Rectangle {
    id: root
    implicitHeight: 28
    width: 28
    radius: width / 2
    color: "#222222"
    border.color: "#444444"
    border.width: 0.5

    property bool popupOpen: false

    Text {
        anchors.centerIn: parent
        font.family: "Material Symbols Rounded"
        font.pixelSize: 16
        color: "#ffffff"
        text: "\ue5cf"
        rotation: root.popupOpen ? 180 : 0
        Behavior on rotation {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            root.popupOpen = !root.popupOpen
            root.popupOpen ? popup.open() : popup.close()
        }
        cursorShape: Qt.PointingHandCursor
    }

    TrayPopup {
        id: popup
        anchorItem: root
        onPopupClosed: root.popupOpen = false
    }
}
