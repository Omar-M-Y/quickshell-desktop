// greeter/views/Tester.qml
import QtQuick
import QtQuick.Controls.Basic

Item {
    anchors.fill: parent

    // Background
    Rectangle {
        anchors.fill: parent
        color: "#1e1e2e"

        Rectangle {
            anchors.fill: parent
            color: "#441e1e2e"
        }
    }

    property string stage: "username"
    property string errorText: ""

    // Clock
    Text {
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
            onTriggered: parent.text = Qt.formatTime(new Date(), "HH:mm")
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
                            stage = "password"
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
                        if (text === "test") {
                            stage = "success"
                            errorText = ""
                        } else {
                            errorText = "Authentication failed"
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

            // Success
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "✓ Welcome back, " + usernameField.text
                color: "#a6e3a1"
                font.pixelSize: 14
                visible: stage === "success"
            }
        }
    }
}
