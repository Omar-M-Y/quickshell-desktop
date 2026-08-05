import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets 


Item {
    id: root
    implicitHeight: 35
    width: row.width

    property var focusedToplevel: ToplevelManager.toplevels.values.find(t => t.activated)

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        IconImage {

            implicitSize: 32
            width: 16
            height: 16
            mipmap: true
            anchors.verticalCenter: parent.verticalCenter

            property string appId: root.focusedToplevel?.appId ?? ""
            property var entry: DesktopEntries.byId(appId)
            property string iconName: entry?.icon ?? appId

            source: iconName ? "image://icon/" + iconName : ""
        }
        ClippingRectangle {
            id: titleClip
            width: Math.min(titleText.implicitWidth, 120)
            height: 35
            color: "transparent"
            Behavior on width {
                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                }
            property bool hovered: false

            Text {
                id: titleText
                anchors.verticalCenter: parent.verticalCenter
                color: "#ffffff"
                font.pixelSize: 12

                property string rawTitle: root.focusedToplevel?.title ?? ""
                property string appName: DesktopEntries.byId(root.focusedToplevel?.appId ?? "")?.name ?? ""
                text: {
                    let t = rawTitle
                    if (appName && t.includes(appName)) {
                        t = t.replace(appName, "").replace(/[\s\-—|]+$/, "").replace(/^[\s\-—|]+/, "").trim()
                    }
                    return t
                }

                x: 0

                Behavior on x {
                    NumberAnimation { duration: 1500; easing.type: Easing.InOutSine }
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: {
                    titleClip.hovered = true
                    titleText.x = Math.min(0, titleClip.width - titleText.width - 4)
                }
                onExited: {
                    titleClip.hovered = false
                    titleText.x = 0
                }
            }
        }
    }
}
