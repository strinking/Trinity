import QtQuick 2.6
import QtQuick.Controls 2.3

import trinity.matrix 1.0

Popup {
    id: profilePopup

    width: 500
    height: 256

    x: parent.width / 2 - width / 2
    y: parent.height / 2 - height / 2

    modal: true

    property var member

    Component.onCompleted: matrix.updateMemberCommunities(member)

    Image {
        id: profileAvatar

        width: 64
        height: 64

        source: member.avatarURL ? member.avatarURL : "placeholder.png"
    }

    Text {
        id: profileNameLabel

        anchors.verticalCenter: profileAvatar.verticalCenter
        anchors.left: profileAvatar.right
        anchors.leftMargin: 15

        text: member.displayName

        font.pointSize: 22

        color: "white"
    }

    Text {
        id: profileIdLabel

        anchors.verticalCenter: profileNameLabel.verticalCenter
        anchors.left: profileNameLabel.right
        anchors.leftMargin: 10

        text: member.id

        color: "grey"
    }

    TabBar {
        width: parent.width

        anchors.top: profileAvatar.bottom
        anchors.topMargin: 15

        id: profileTabs

        TabButton {
            text: "Communities"
        }
    }

    SwipeView {
        height: parent.height - profileNameLabel.height - profileTabs.height
        width: parent.width

        anchors.top: profileTabs.bottom

        currentIndex: profileTabs.currentIndex

        Item {
            ListView {
                id: communityList

                anchors.fill: parent

                model: CommunityListModel {
                    communities: member.publicCommunities
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
                            profilePopup.close()
                            stack.push("qrc:/Community.qml", {"community": matrix.resolveCommunityId(display.id)})
                        }
                    }
                }
            }

            Rectangle {
                anchors.fill: communityList

                color: "transparent"

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter

                    text: "This member does not have any public communities."

                    color: "white"

                    visible: !member.publicCommunities || member.publicCommunities.length == 0
                }
            }
        }
    }
}
