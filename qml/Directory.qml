import QtQuick 2.10
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import QtQuick.Shapes 1.0

import trinity.matrix 1.0

Rectangle {
    id: roomDirectory

    color: Qt.rgba(0.1, 0.1, 0.1, 1.0)

    Component.onCompleted: matrix.loadDirectory()

    Rectangle {
        width: 700
        height: parent.height

        anchors.horizontalCenter: parent.horizontalCenter

        color: "transparent"

        BackButton {
            id: backButton

            anchors.top: parent.top
            anchors.topMargin: 15

            anchors.right: parent.right
        }

        Text {
            id: directoryLabel

            anchors.top: parent.top
            anchors.topMargin: 15

            text: "Directory"

            font.pointSize: 25
            font.bold: true

            color: "white"
        }

        ListView {
            width: parent.width
            height: parent.height - backButton.height

            anchors.top: directoryLabel.bottom
            anchors.topMargin: 10

            model: matrix.publicRooms

            clip: true

            delegate: Rectangle {
                width: parent.width
                height: 40 + roomTopic.contentHeight

                color: "transparent"

                Image {
                    id: roomAvatar

                    width: 32
                    height: 32

                    source: avatarURL
                }

                Text {
                    id: roomName

                    anchors.top: parent.top
                    anchors.topMargin: 10
                    anchors.left: roomAvatar.right
                    anchors.leftMargin: 15

                    text: alias

                    font.bold: true

                    color: "white"
                }

                Text {
                    id: roomTopic

                    width: parent.width

                    anchors.top: roomName.bottom
                    anchors.topMargin: 5
                    anchors.left: roomAvatar.right
                    anchors.leftMargin: 15

                    text: topic

                    wrapMode: Text.Wrap

                    color: "white"
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        matrix.joinRoom(id)
                        stack.pop()
                    }
                }
            }
        }
    }
}
