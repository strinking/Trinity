import QtQuick 2.10
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import QtQuick.Shapes 1.0

Rectangle {
    color: "transparent"

    ToolButton {
        id: button

        width: 32
        height: 32

        text: "X"

        onClicked: stack.pop()
    }

    Text {
        anchors.top: button.bottom
        anchors.horizontalCenter: button.horizontalCenter

        horizontalAlignment: Text.AlignHCenter

        font.bold: true

        text: "ESC"

        color: "grey"
    }

    Shortcut {
        sequence: "ESC"
        onActivated: stack.pop()
    }
}
