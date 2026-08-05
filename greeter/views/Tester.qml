// greeter/views/Tester.qml
import QtQuick
import QtQuick.Effects
import Quickshell.Io

Item {
    anchors.fill: parent

    readonly property color onSurface: "#ffffff"

    property string stage: "username"
    property string errorText: ""
    property string confirmedUsername: ""

    property color colorPrimary: "#cba6f7"
    property color colorSurface: "#1e1e2e"
    property color colorOutline: "#585b70"
    property color colorError: "#f38ba8"

    FileView {
        id: colorsFile
        path: "/tmp/current-colors.json"
        watchChanges: true

        onLoaded: {
            const data = JSON.parse(text())
            colorPrimary = data.primary
            colorSurface = data.surface
            colorOutline = data.outline
            colorError = data.error
        }

        onFileChanged: reload()
    }

    // ---- Blurred wallpaper background ----
    Image {
        id: wallpaper
        anchors.fill: parent
        source: "file:///tmp/current-wallpaper"
        fillMode: Image.PreserveAspectCrop
        visible: false
        asynchronous: true
    }

    MultiEffect {
        anchors.fill: parent
        source: wallpaper
        blurEnabled: true
        blur: 1.0
        blurMax: 64
        autoPaddingEnabled: false
    }

    Rectangle {
        anchors.fill: parent
        color: "#33000000"
    }

    // ---- Profile picture ----
    Image {
        id: profilePic
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.26
        width: 96
        height: 96
        source: "file:///tmp/current-wallpaper"
        fillMode: Image.PreserveAspectCrop
        asynchronous: true

        layer.enabled: true
        layer.effect: MultiEffect {
            maskEnabled: true
            maskSource: mask
        }

        Item {
            id: mask
            width: profilePic.width
            height: profilePic.height
            layer.enabled: true
            visible: false

            Rectangle {
                anchors.fill: parent
                radius: width / 2
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: "transparent"
            border.color: colorPrimary
            border.width: 2
            opacity: 0.6
        }
    }

    // ---- Username label — appears here once confirmed ----
    Text {
        id: usernameChip
        anchors.horizontalCenter: parent.horizontalCenter
        text: confirmedUsername
        color: onSurface
        font.pixelSize: 18
        font.bold: true
        opacity: 0

        y: stage === "username" ? inputCard.y : profilePic.y + profilePic.height + 14

        Behavior on y {
            NumberAnimation { duration: 350; easing.type: Easing.InOutCubic }
        }
        Behavior on opacity {
            NumberAnimation { duration: 250 }
        }
    }

    // ---- Input card ----
    Rectangle {
        id: inputCard
        anchors.top: profilePic.bottom
        anchors.topMargin: 56
        anchors.horizontalCenter: parent.horizontalCenter
        width: 140
        height: 44
        radius: 12
        color: "#ffffff"
        border.color: colorPrimary
        border.width: 1

        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }

        Text {
            id: fieldLabel
            anchors.centerIn: parent
            text: stage === "username" ? "Username" : "Password"
            color: "#88000000"
            font.pixelSize: 13
            visible: activeField.text === ""
        }

        // Invisible real input — handles typing/cursor/focus/keys
        TextInput {
            id: activeField
            anchors.fill: parent
            anchors.margins: 14
            color: "transparent"
            selectionColor: "transparent"
            selectedTextColor: "transparent"
            font.pixelSize: 14
            horizontalAlignment: TextInput.AlignHCenter
            echoMode: stage === "password" ? TextInput.Password : TextInput.Normal
            focus: true
            clip: true
            cursorVisible: false
            activeFocusOnTab: false
            cursorDelegate: Item {}

            Component.onCompleted: forceActiveFocus()

            // Sync the persistent ListModel to match text changes —
            // append one entry on growth, remove entries on shrink/clear.
            onTextChanged: {
                while (charModel.count < text.length) {
                    charModel.append({ "ch": text[charModel.count] })
                }
                while (charModel.count > text.length) {
                    charModel.remove(charModel.count - 1)
                }
                // Keep characters in sync in case of mid-string edits (paste, arrow+delete etc.)
                for (let i = 0; i < text.length; i++) {
                    if (charModel.get(i).ch !== text[i]) {
                        charModel.set(i, { "ch": text[i] })
                    }
                }
            }

            Keys.onReturnPressed: {
                if (stage === "username") {
                    if (text !== "") {
                        confirmedUsername = text
                        switchAnim.start()
                    }
                } else if (stage === "password") {
                    if (text !== "") {
                        if (text === "test") {
                            stage = "success"
                            Qt.quit()
                            errorText = ""
                        } else {
                            errorText = "Authentication failed"
                            activeField.clear()
                        }
                    }
                }
            }
        }

        // Persistent model — survives across keystrokes, only grows/shrinks incrementally
        ListModel {
            id: charModel
        }

        // Visible rendered content — characters (username) or dots (password)
        Row {
            id: charRow
            anchors.centerIn: parent
            spacing: stage === "password" ? 6 : 0

            Repeater {
                model: charModel

                Item {
                    id: delegateRoot
                    width: stage === "password" ? 8 : charText.implicitWidth
                    height: stage === "password" ? 8 : charText.implicitHeight

                    // Password dot
                    Rectangle {
                        id: dot
                        anchors.centerIn: parent
                        visible: stage === "password"
                        width: 8
                        height: 8
                        radius: 4
                        color: "#000000"
                        scale: 0.5

                        ParallelAnimation {
                            id: dotAnim
                            NumberAnimation {
                                target: dot
                                property: "scale"
                                to: 1
                                duration: 400
                                easing.type: Easing.BezierSpline
                                easing.bezierCurve: [0.68, -0.55, 0.27, 1.55, 1, 1]
                            }
                        }
                        Component.onCompleted: dotAnim.start()
                    }

                    // Username character
                    Text {
                        id: charText
                        visible: stage === "username"
                        text: model.ch
                        color: "#000000"
                        font.pixelSize: 14
                        scale: 0.5

                        ParallelAnimation {
                            id: charAnim
                            NumberAnimation {
                                target: charText
                                property: "scale"
                                to: 1
                                duration: 400   // was 160
                                easing.type: Easing.BezierSpline
                                easing.bezierCurve: [0.68, -0.55, 0.27, 1.55, 1, 1]
                            }
                        }
                        Component.onCompleted: charAnim.start()
                    }
                }
            }
        }

        // Smooth-fading cursor (real animated fade, not a hard blink)
        Rectangle {
            id: caret
            width: 2
            height: 16
            color: "#000000"
            anchors.verticalCenter: parent.verticalCenter
            x: parent.width / 2 + charRow.width / 2 + 4
            visible: activeField.activeFocus

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                running: caret.visible
                NumberAnimation { to: 0; duration: 530 }
                NumberAnimation { to: 1; duration: 530 }
            }
        }
    }

    SequentialAnimation {
        id: switchAnim
        NumberAnimation { target: inputCard; property: "opacity"; to: 0; duration: 150 }
        ScriptAction {
            script: {
                stage = "password"
                usernameChip.opacity = 1
                activeField.clear()
                activeField.forceActiveFocus()
            }
        }
        NumberAnimation { target: inputCard; property: "opacity"; to: 1; duration: 150 }
    }

    // ---- Error text ----
    Text {
        anchors.top: inputCard.bottom
        anchors.topMargin: 12
        anchors.horizontalCenter: parent.horizontalCenter
        text: errorText
        color: colorError
        font.pixelSize: 12
        visible: errorText !== ""
    }

    // ---- Success text ----
    Text {
        anchors.top: inputCard.bottom
        anchors.topMargin: 12
        anchors.horizontalCenter: parent.horizontalCenter
        text: "✓ Welcome back"
        color: onSurface
        font.pixelSize: 12
        visible: stage === "success"
    }
}
