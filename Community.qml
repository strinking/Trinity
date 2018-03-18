import QtQuick 2.10
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import QtQuick.Shapes 1.0

Rectangle {
    id: communityDescription

    color: Qt.rgba(0.1, 0.1, 0.1, 1.0)

    property var community

    Rectangle {
        width: 700
        height: parent.height

        anchors.horizontalCenter: parent.horizontalCenter

        color: "transparent"

        Button {
            id: backButton

            text: "Back"
            onClicked: stack.pop()
        }

        Image {
            id: communityAvatar

            anchors.top: backButton.bottom
            anchors.topMargin: 15

            width: 64
            height: 64

            source: community.avatar
        }

        Text {
            id: communityNameLabel

            anchors.left: communityAvatar.right
            anchors.leftMargin: 10
            anchors.verticalCenter: communityAvatar.verticalCenter

            text: community.name

            color: "white"

            font.pointSize: 25
        }

        Text {
            id: communityShortDescriptionLabel

            anchors.top: communityAvatar.bottom
            anchors.topMargin: 15

            text: community.shortDescription

            color: "gray"
        }

        Text {
            id: communityLongDescriptionLabel

            width: parent.width

            anchors.top: communityShortDescriptionLabel.bottom
            anchors.topMargin: 15

            text: community.longDescription

            wrapMode: Text.WrapAnywhere

            color: "white"
        }
    }
}
