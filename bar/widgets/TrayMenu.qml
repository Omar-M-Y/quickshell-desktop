import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets

PopupWindow {
    id: root

    required property var menu
    required property Item anchorItem

    signal closed

    anchor.item: anchorItem
    anchor.rect.x: (anchorItem.width - implicitWidth) / 2
    anchor.rect.y: anchorItem.height + 8

    implicitWidth: 160
    implicitHeight: menuColumn.implicitHeight + 16
    color: "transparent"
    visible: false

    property real popupScale: 0
    property real popupOpacity: 0

    QsMenuOpener {
        id: menuOpener
        menu: root.menu
    }

    Rectangle {
        id: menuRect
        anchors.fill: parent
        radius: 12
        color: "#222222"
        border.color: "#444444"
        border.width: 0.5
        clip: true

        scale: root.popupScale
        opacity: root.popupOpacity
        transformOrigin: Item.Top

        Behavior on scale {
            NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
        }
        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }

        HoverHandler {
            onHoveredChanged: {
                if (!hovered) root.close()
            }
        }

        Column {
            id: menuColumn
            anchors.centerIn: parent
            width: parent.width
            spacing: 2

            Repeater {
                model: menuOpener.children
                delegate: Item {
                    required property var modelData
                    width: 160
                    height: modelData.isSeparator ? 9 : 30

                    Rectangle {
                        visible: modelData.isSeparator
                        width: parent.width - 16
                        height: 1
                        color: "#444444"
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Rectangle {
                        visible: !modelData.isSeparator
                        anchors.fill: parent
                        anchors.leftMargin: 4
                        anchors.rightMargin: 4
                        color: itemHover.containsMouse && modelData.enabled ? "#333333" : "transparent"
                        radius: 6
                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                    }

                    Text {
                        visible: !modelData.isSeparator
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        text: modelData.text ?? ""
                        color: modelData.enabled ? "#ffffff" : "#666666"
                        font.pixelSize: 12
                    }

                    MouseArea {
                        id: itemHover
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: modelData.enabled && !modelData.isSeparator
                        cursorShape: modelData.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: {
                            modelData.triggered()
                            root.close()
                        }
                    }
                }
            }
        }
    }

    function open() {
        popupScale = 0
        popupOpacity = 0
        visible = true
        Qt.callLater(() => {
            popupScale = 1
            popupOpacity = 1
        })
    }

    function close() {
        popupScale = 0
        popupOpacity = 0
        closeTimer.restart()
        root.closed()
    }

    function toggle() {
        visible ? close() : open()
    }

    Timer {
        id: closeTimer
        interval: 250
        onTriggered: root.visible = false
    }
}
