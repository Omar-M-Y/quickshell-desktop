import Quickshell
import QtQuick
import QtQuick.Effects
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import Quickshell.Widgets

Rectangle {
    id: root
    height: expanded ? 200 : 35
    width: expanded ? 300 : (showingPlayer ? collapsedRow.width + 24 : nothingText.width + 24)
    radius: expanded ? 16 : height / 2
    color: "#000000"
    border.color: "#cccccc"
    border.width: 0.5
    clip: true

    required property var parentWindow

    property bool expanded: false
    property MprisPlayer activePlayer: Mpris.players.values.find(p =>
        p.playbackState === MprisPlaybackState.Playing
    ) ?? null
    property MprisPlayer lastPlayer: null
    property bool isPlaying: activePlayer !== null
    property bool showingPlayer: lastPlayer !== null

    onActivePlayerChanged: {
        if (activePlayer !== null) {
            lastPlayer = activePlayer
            fadeTimer.stop()
        } else {
            fadeTimer.start()
        }
    }

    onShowingPlayerChanged: {
        if (!showingPlayer) {
            root.expanded = false
        }
    }

    HoverHandler {
        id: hoverHandler
        onHoveredChanged: {
            if (hovered && root.showingPlayer) {
                root.expanded = true
            } else {
                root.expanded = false
            }
        }
    }

    Behavior on width {
        NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
    }
    Behavior on height {
        NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
    }
    Behavior on radius {
        NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
    }

    Timer {
        id: fadeTimer
        interval: 15000
        onTriggered: root.lastPlayer = null
    }

    // Collapsed content
    Row {
        id: collapsedRow
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 12
        spacing: 6
        opacity: root.showingPlayer && !root.expanded ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 250 } }

        IconImage {
            implicitSize: 16
            width: 16
            height: 16
            anchors.verticalCenter: parent.verticalCenter
            property string identity: root.lastPlayer?.identity ?? ""
            property var entry: DesktopEntries.byId(identity) ?? DesktopEntries.byId(identity.toLowerCase())
            property string resolvedIcon: entry?.icon ?? identity.toLowerCase()
            source: resolvedIcon ? "image://icon/" + resolvedIcon : ""
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            color: "#ffffff"
            font.pixelSize: 12
            text: root.lastPlayer?.trackTitle ?? ""
        }
    }

    // Nothing playing
    Text {
        id: nothingText
        anchors.centerIn: parent
        color: "#aaaaaa"
        font.pixelSize: 12
        text: "Nothing Playing"
        opacity: root.showingPlayer || root.expanded ? 0.0 : 1.0
        Behavior on opacity { NumberAnimation { duration: 250 } }
    }

    // Expanded content
    MusicPopup {
        anchors.fill: parent
        opacity: root.expanded ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 250 } }
        player: root.lastPlayer
        pillRadius: root.radius
    }
}
