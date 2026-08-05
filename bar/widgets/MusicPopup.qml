import Quickshell
import QtQuick
import QtQuick.Effects
import Quickshell.Services.Mpris
import Quickshell.Widgets

Item {
    id: root
    required property MprisPlayer player
    property real pillRadius: 16
    property real trackLength: 0
    property real basePosition: 0
    property double lastSyncTime: Date.now()
    property int tick: 0
    property bool seekPending: false

    readonly property real livePosition: {
        tick
        if (!root.player || root.player.playbackState !== MprisPlaybackState.Playing || root.seekPending)
            return root.basePosition
        let elapsed = (Date.now() - root.lastSyncTime) / 1000.0
        let rate = root.player.playbackRate || 1.0
        return Math.min(root.basePosition + (elapsed * rate), root.trackLength)
    }

    Timer {
        interval: 500
        running: root.player?.playbackState === MprisPlaybackState.Playing
        repeat: true
        onTriggered: {
            root.tick++
            root.player?.positionChanged()
        }
    }

    function syncFromPlayer() {
        let pos = root.player?.position ?? 0
        let len = root.player?.length ?? 0
        if (pos >= 0) {
            root.basePosition = pos
            root.lastSyncTime = Date.now()
        }
        if (len > 0) root.trackLength = len
    }

    onPlayerChanged: Qt.callLater(syncFromPlayer)

    Connections {
        target: root.player
        function onPositionChanged() {
            root.basePosition = root.player.position
            root.lastSyncTime = Date.now()
            root.seekPending = false
        }
        function onPlaybackStateChanged() {
            root.basePosition = root.player?.position ?? root.basePosition
            root.lastSyncTime = Date.now()
        }
        function onTrackTitleChanged() { Qt.callLater(root.syncFromPlayer) }
        function onLengthChanged() { Qt.callLater(root.syncFromPlayer) }
    }

    function formatTime(secs) {
        if (!secs || secs <= 0) return "0:00"
        let s = Math.floor(secs)
        let mins = Math.floor(s / 60)
        s = s % 60
        return mins + ":" + (s < 10 ? "0" : "") + s
    }

    ClippingRectangle {
        anchors.fill: parent
        radius: root.pillRadius
        color: "transparent"

        Image {
            id: artBg
            anchors.fill: parent
            source: root.player?.trackArtUrl ?? ""
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            visible: false
        }

        MultiEffect {
            anchors.fill: artBg
            source: artBg
            blurEnabled: true
            blurMax: 32
            blur: 0.85
            autoPaddingEnabled: false
        }

        Rectangle {
            anchors.fill: parent
            color: "#000000"
            opacity: 0.45
        }

        Row {
            id: header
            anchors.top: parent.top
            anchors.topMargin: 16
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8

            IconImage {
                implicitSize: 20
                width: 20
                height: 20
                anchors.verticalCenter: parent.verticalCenter
                property string identity: root.player?.identity ?? ""
                property var entry: DesktopEntries.byId(identity) ?? DesktopEntries.byId(identity.toLowerCase())
                property string resolvedIcon: entry?.icon ?? identity.toLowerCase()
                source: resolvedIcon ? "image://icon/" + resolvedIcon : ""
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                color: "#ffffff"
                font.pixelSize: 13
                font.bold: true
                text: root.player?.trackTitle ?? ""
                width: Math.min(implicitWidth, 220)
                elide: Text.ElideRight
            }
        }

        Row {
            id: controlsRow
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 10
            spacing: 16
            height: 44

            Text {
                anchors.verticalCenter: parent.verticalCenter
                font.family: "Material Symbols Rounded"
                font.pixelSize: 24
                color: "#ffffff"
                text: "\ue020"
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        root.seekPending = true
                        root.player?.seek(-5000000)
                    }
                    cursorShape: Qt.PointingHandCursor
                }
            }

            Rectangle {
                id: playBtn
                width: 44
                height: 44
                radius: width / 2
                color: "#ffffff"
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    anchors.centerIn: parent
                    font.family: "Material Symbols Rounded"
                    font.pixelSize: 24
                    color: "#000000"
                    text: root.player?.playbackState === MprisPlaybackState.Playing ? "\ue034" : "\ue037"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.player?.togglePlaying()
                    cursorShape: Qt.PointingHandCursor
                    onPressed: playBtn.opacity = 0.7
                    onReleased: playBtn.opacity = 1.0
                }

                Behavior on opacity {
                    NumberAnimation { duration: 100 }
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                font.family: "Material Symbols Rounded"
                font.pixelSize: 24
                color: "#ffffff"
                text: "\ue01f"
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        root.seekPending = true
                        root.player?.seek(5000000)
                    }
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }

        Item {
            id: progressItem
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 24
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            height: 16

            Text {
                id: currentTime
                anchors.left: parent.left
                anchors.verticalCenter: progressBg.verticalCenter
                color: "#ffffff"
                font.pixelSize: 10
                text: root.formatTime(root.livePosition)
            }

            Text {
                id: totalTime
                anchors.right: parent.right
                anchors.verticalCenter: progressBg.verticalCenter
                color: "#aaaaaa"
                font.pixelSize: 10
                text: root.formatTime(root.trackLength)
            }

            Rectangle {
                id: progressBg
                anchors.left: currentTime.right
                anchors.right: totalTime.left
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                height: 3
                radius: 2
                color: "#444444"

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    radius: 2
                    color: "#ffffff"
                    width: {
                        let len = root.trackLength
                        let pos = root.livePosition
                        if (len <= 0 || pos < 0) return 0
                        return Math.min(1, pos / len) * parent.width
                    }
                }
            }
        }
    }
}
