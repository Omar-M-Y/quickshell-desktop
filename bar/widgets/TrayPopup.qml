import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.SystemTray
import Quickshell.Widgets

PopupWindow {
    id: root

    required property Item anchorItem

    signal popupClosed

    property var openMenu: null

    anchor.item: anchorItem
    anchor.rect.x: anchorItem.width - implicitWidth
    anchor.rect.y: anchorItem.height + 8

    implicitWidth: trayRow.implicitWidth + 48
    implicitHeight: 44
    color: "transparent"
    visible: false

    property real popupScale: 0
    property real popupOpacity: 0

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: "#222222"
        border.color: "#444444"
        border.width: 0.5
        clip: true

        scale: root.popupScale
        opacity: root.popupOpacity
        transformOrigin: Item.TopRight

        Behavior on scale {
            NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
        }
        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }

        HoverHandler {
            id: trayHover
            onHoveredChanged: {
                if (!hovered) {
                    closeDelayTimer.start()
                } else {
                    closeDelayTimer.stop()
                }
            }
        }

        Timer {
            id: closeDelayTimer
            interval: 2000
            onTriggered: root.close()
        }

        Row {
            id: trayRow
            anchors.centerIn: parent
            spacing: 8

            Repeater {
                model: SystemTray.items.values
                delegate: Item {
                    required property var modelData
                    width: 24
                    height: 24
                    anchors.verticalCenter: parent?.verticalCenter

                    IconImage {
                        id: trayIcon
                        anchors.fill: parent
                        mipmap: true
                        asynchronous: true
                        source: {
                            let icon = modelData?.icon ?? ""
                            if (!icon) return ""
                            if (icon.includes("?path=")) {
                                const chunks = icon.split("?path=")
                                const name = chunks[0]
                                const path = chunks[1]
                                const fileName = name.substring(name.lastIndexOf("/") + 1)
                                return `file://${path}/${fileName}`
                            }
                            return icon
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mouse => {
                            if (mouse.button === Qt.LeftButton) {
                                if (!modelData.onlyMenu) modelData.activate()
                            } else if (mouse.button === Qt.RightButton) {
                                if (root.openMenu && root.openMenu !== trayMenu) {
                                    root.openMenu.close()
                                }
                                root.openMenu = trayMenu
                                trayMenu.toggle()
                            }
                        }
                    }

                    TrayMenu {
                        id: trayMenu
                        anchorItem: trayIcon
                        menu: modelData.menu
                        onClosed: {
                            if (root.openMenu === trayMenu) {
                                root.openMenu = null
                            }
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
        if (root.openMenu) {
            root.openMenu.close()
            root.openMenu = null
        }
        popupScale = 0
        popupOpacity = 0
        closeTimer.restart()
        root.popupClosed()
    }

    function toggle() {
        visible ? close() : open()
    }

    Timer {
        id: closeTimer
        interval: 300
        onTriggered: root.visible = false
    }
}
