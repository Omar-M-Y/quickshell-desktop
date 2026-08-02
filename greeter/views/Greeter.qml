// greeter/views/Greeter.qml
import QtQuick
import Quickshell
import Quickshell.Services.Greetd

Item {
    anchors.fill: parent

    property string stage: "username"
    property string errorText: ""

    Connections {
        target: Greetd

        function onAuthMessage(message, error, responseRequired, echoResponse) {
            if (responseRequired) {
                stage = "password"
            }
        }

        function onAuthFailure(message) {
            errorText = "Authentication failed"
            stage = "password"
            passwordField.clear()
        }

        function onReadyToLaunch() {
            stage = "launching"
            launchTimer.start()
        }

        function onError(error) {
            errorText = error
        }
    }

    Timer {
        id: launchTimer
        interval: 350
        onTriggered: Greetd.launch(["uwsm", "start", "hyprland-uwsm.desktop"])
    }

    // Background
    Rectangle {
        anchors.fill: parent
        color: "#1e1e2e"

        Rectangle {
            anchors.fill: parent
            color: "#441e1e2e"
        }
    }

    // Clock
    Text {
        id: clockText
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.25
        text: Qt.formatTime(new Date(), "HH:mm")
        color: "white"
        font.pixelSize: 72
        font.bold: true

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: clockText.text = Qt.formatTime(new Date(), "HH:mm")
        }
    }

    // Date
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.25 + 80
        text: Qt.formatDate(new Date(), "dddd, MMMM d")
        color: "#88ffffff"
        font.pixelSize: 18
    }

    // Center card
    Rectangle {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 60
        width: 380
        height: 160
        radius: 16
        color: "#aa1e1e2e"

        Column {
            anchors.centerIn: parent
            spacing: 12
            width: parent.width - 48

            // Username field
            Rectangle {
                width: parent.width
                height: 40
                radius: 8
                color: "#221e1e2e"
                visible: stage === "username"
                border.color: "#44cba6f7"
                border.width: 1

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    text: "Username"
                    color: "#44ffffff"
                    font.pixelSize: 14
                    visible: usernameField.text === ""
                }

                TextInput {
                    id: usernameField
                    anchors.fill: parent
                    anchors.margins: 12
                    color: "white"
                    font.pixelSize: 14
                    focus: stage === "username"

                    Keys.onReturnPressed: {
                        if (text !== "") {
                            Greetd.createSession(text)
                        }
                    }
                }
            }

            // Password field
            Rectangle {
                width: parent.width
                height: 40
                radius: 8
                color: "#221e1e2e"
                visible: stage === "password"
                border.color: "#44cba6f7"
                border.width: 1

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    text: "Password"
                    color: "#44ffffff"
                    font.pixelSize: 14
                    visible: passwordField.text === ""
                }

                TextInput {
                    id: passwordField
                    anchors.fill: parent
                    anchors.margins: 12
                    color: "white"
                    font.pixelSize: 14
                    echoMode: TextInput.Password
                    focus: stage === "password"

                    Keys.onReturnPressed: {
                        if (text !== "") {
                            Greetd.respond(text)
                            clear()
                        }
                    }
                }
            }

            // Error
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: errorText
                color: "#f38ba8"
                font.pixelSize: 12
                visible: errorText !== ""
            }
        }
    }

    // Launch overlay — fades to black then launches Hyprland
    Rectangle {
        id: launchOverlay
        anchors.fill: parent
        color: "#000000"
        visible: stage === "launching"
        opacity: 0
        z: 999

        Behavior on opacity {
            NumberAnimation { duration: 300 }
        }

        onVisibleChanged: {
            if (visible) opacity = 1
        }
    }
}
