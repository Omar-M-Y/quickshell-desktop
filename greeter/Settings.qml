import Quickshell
import Quickshell.Services.Greetd
import QtQuick

QtObject {
    id: root

    readonly property bool isGreetd: Greetd.available
    readonly property bool isLockd:  false  // ext-session-lock-v1 later
    readonly property bool isTest:   !isGreetd && !isLockd
}
