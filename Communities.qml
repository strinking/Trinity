import QtQuick 2.10
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import QtQuick.Shapes 1.0

import trinity.matrix 1.0

Rectangle {
    id: accountCreation

    color: Qt.rgba(0.1, 0.1, 0.1, 1.0)

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
            id: communitiesLabel

            anchors.top: parent.top
            anchors.topMargin: 15

            text: "Communities"

            font.pointSize: 25
            font.bold: true

            color: "white"
        }

        Text {
            id: joinedCommunitiesLabel

            anchors.top: communitiesLabel.bottom
            anchors.topMargin: 10

            text: "Joined Communities"

            color: "white"
        }

        ListView {
            id: joinedCommunitiesList

            width: parent.width

            anchors.top: joinedCommunitiesLabel.bottom

            model: CommunityListModel {
                communities: matrix.joinedCommunities
            }

            delegate: Rectangle {
                width: parent.width
                height: 60

                color: "transparent"

                Image {
                    id: communityAvatar

                    width: 32
                    height: 32

                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10

                    source: display.avatar
                }

                Text {
                    anchors.left: communityAvatar.right
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter

                    text: display.name

                    color: "white"
                }

                MouseArea {
                    anchors.fill: parent

                    onReleased: {
                        stack.push("qrc:/Community.qml", {"community": matrix.resolveCommunityId(display.id)})
                    }
                }
            }
        }
    }
}
