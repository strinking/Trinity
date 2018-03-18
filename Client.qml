import QtQuick 2.10
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0

import trinity.matrix 1.0

Rectangle {
    id: client
    color: Qt.rgba(0.05, 0.05, 0.05, 1.0)

    property var shouldScroll: false

    ListView {
       id: channels
       width: 150
       height: parent.height
       anchors.right: rightArea.left
       anchors.left: client.left

       model: matrix.roomListModel

       clip: true

       section.property: "joinState"
       section.criteria: ViewSection.FullString
       section.delegate: Rectangle {
           width: parent.width
           height: 25

           color: "transparent"

           Text {
               text: section

               color: "red"
           }
       }

       delegate: Rectangle {
            width: 150
            height: 25

            property bool selected: channels.currentIndex === index

            color: selected ? "white" : "transparent"

            radius: 5

            Image {
                id: roomAvatar

                anchors.top: parent.top
                anchors.topMargin: 5
                anchors.left: parent.left
                anchors.leftMargin: 5

                width: 18
                height: 18

                sourceSize.width: 18
                sourceSize.height: 18

                source: avatarURL ? avatarURL : "placeholder.png"

                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Item {
                        width: roomAvatar.width
                        height: roomAvatar.height
                        Rectangle {
                            anchors.centerIn: parent
                            width: roomAvatar.width
                            height: roomAvatar.height
                            radius: Math.min(width, height)
                        }
                    }
                }
            }

            Text {
                text: alias

                anchors.verticalCenter: parent.verticalCenter

                anchors.left: roomAvatar.right
                anchors.leftMargin: 5

                color: selected ? "black" : "white"
            }

            MouseArea {
                anchors.fill: parent

                acceptedButtons: Qt.LeftButton | Qt.RightButton

                onReleased: {
                    if(mouse.button == Qt.LeftButton) {
                        if(!selected) {
                            matrix.changeCurrentRoom(index)
                            channels.currentIndex = index
                        }
                    } else
                        contextMenu.popup()
                }
            }

            Menu {
                id: contextMenu

                MenuItem {
                    text: "Settings"

                    onClicked: stack.push("qrc:/RoomSettings.qml", {"room": matrix.getRoom(index)})
                }
            }
       }
    }

    Button {
        id: communitiesButton

        width: channels.width

        anchors.bottom: channels.bottom

        text: "Communities"

        onClicked: stack.push("qrc:/Communities.qml")
    }

    Button {
        id: directoryButton

        width: channels.width

        anchors.bottom: communitiesButton.top

        text: "Directory"

        onClicked: stack.push("qrc:/Directory.qml")
    }

    Rectangle {
        id: rightArea
        height: parent.height
        width: parent.width - channels.width
        anchors.left: channels.right

        color: "green"

        Rectangle {
            id: roomHeader
            height: 45
            width: parent.width

            anchors.bottom: messagesArea.top

            color: Qt.rgba(0.3, 0.3, 0.3, 1.0)

            Image {
                id: channelAvatar

                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 15

                width: 33
                height: 33

                sourceSize.width: 33
                sourceSize.height: 33

                fillMode: Image.PreserveAspectFit

                source: matrix.currentRoom.avatar

                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Item {
                        width: 33
                        height: 33
                        Rectangle {
                            anchors.centerIn: parent
                            width: 33
                            height: 33
                            radius: Math.min(width, height)
                        }
                    }
                }
            }

            Text {
                id: channelTitle

                font.pointSize: 15

                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 15
                anchors.left: channelAvatar.right

                text: matrix.currentRoom.name

                color: "white"
            }

            Text {
                id: channelTopic

                width: showMemberListButton.x - x

                font.pointSize: 12

                anchors.verticalCenter: parent.verticalCenter

                anchors.left: channelTitle.right
                anchors.leftMargin: 5

                text: {
                    if(matrix.currentRoom.topic.length == 0)
                        return "This room has no topic set."
                    else
                        return matrix.currentRoom.topic
                }

                color: "gray"

                elide: Text.ElideRight

                MouseArea {
                    anchors.fill: parent

                    onReleased: showDialog(matrix.currentRoom.name, matrix.currentRoom.topic)
                }
            }

            ToolButton {
                id: showMemberListButton

                anchors.verticalCenter: parent.verticalCenter

                anchors.right: settingsButton.left
                anchors.rightMargin: 10

                icon.name: "face-plain"

                onClicked: {
                    if(memberList.width == 0)
                        memberList.width = 200
                    else
                        memberList.width = 0
                }

                ToolTip.visible: hovered
                ToolTip.text: "Member List"
            }

            ToolButton {
                id: settingsButton

                anchors.verticalCenter: parent.verticalCenter

                anchors.right: parent.right
                anchors.rightMargin: 10

                icon.name: "preferences-system"

                onClicked: stack.push("qrc:/Settings.qml")

                ToolTip.visible: hovered
                ToolTip.text: "Settings"
            }
        }

        Rectangle {
            id: messagesArea

            width: parent.width - memberList.width
            height: parent.height - roomHeader.height

            anchors.top: roomHeader.bottom

            Rectangle {
                height: parent.height - messageInput.height
                width: parent.width

                clip: true

                color: Qt.rgba(0.1, 0.1, 0.1, 1.0)

                ListView {
                    id: messages
                    model: matrix.eventModel

                    anchors.fill: parent

                    delegate: Rectangle {                        
                        width: parent.width
                        height: (condense ? 5 : 25) + message.contentHeight

                        color: "transparent"

                        Image {
                            id: avatar

                            anchors.top: parent.top
                            anchors.topMargin: 5
                            anchors.left: parent.left
                            anchors.leftMargin: 5

                            sourceSize.width: 33
                            sourceSize.height: 33

                            source: avatarURL ? avatarURL : "placeholder.png"

                            visible: !condense

                            layer.enabled: true
                            layer.effect: OpacityMask {
                                maskSource: Item {
                                    width: avatar.width
                                    height: avatar.height
                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: avatar.width
                                        height: avatar.height
                                        radius: Math.min(width, height)
                                    }
                                }
                            }
                        }

                        Text {
                            id: senderText

                            text: condense ? "" : sender

                            color: "white"

                            anchors.left: avatar.right
                            anchors.leftMargin: 10
                        }

                        Text {
                            text: condense ? "" : timestamp

                            color: "gray"

                            anchors.left: senderText.right
                            anchors.leftMargin: 10
                        }

                        Text {
                            id: message

                            y: condense ? 0 : 20
                            text: msg

                            width: parent.width

                            wrapMode: Text.Wrap

                            color: sent ? "white" : "gray"

                            anchors.left: condense ? parent.left : avatar.right
                            anchors.leftMargin: condense ? 45 : 10
                        }

                        MouseArea {
                            anchors.fill: parent

                            acceptedButtons: Qt.RightButton

                            onClicked: contextMenu.popup()
                        }

                        Menu {
                            id: contextMenu

                            MenuItem {
                                text: "Remove"

                                onClicked: matrix.removeMessage(eventId)
                            }

                            MenuItem {
                                text: "Permalink"

                                onClicked: Qt.openUrlExternally("https://matrix.to/#/" + matrix.currentRoom.id + "/" + eventId)
                            }
                        }
                    }

                    ScrollBar.vertical: ScrollBar {}

                    boundsBehavior: Flickable.StopAtBounds
                    flickableDirection: Flickable.VerticalFlick
                    verticalLayoutDirection: ListView.BottomToTop

                    onMovingVerticallyChanged: {

                        var curVelocity = verticalVelocity // Snapshot the current speed
                        if( curVelocity < 0 )
                        {
                            if(matrix.currentRoom)
                                   matrix.readMessageHistory(matrix.currentRoom)
                        }
                    }
                }

                Rectangle {
                    id: overlay

                    anchors.fill: parent

                    visible: matrix.currentRoom.guestDenied

                    color: "transparent"

                    Text {
                        id: invitedByLabel

                        anchors.centerIn: parent

                        color: "white"

                        text: "You have been invited to this room by " + matrix.currentRoom.invitedBy
                    }

                    Button {
                        text: "Accept"

                        anchors.top: invitedByLabel.bottom

                        onReleased: {
                            matrix.joinRoom(matrix.currentRoom.id)
                        }
                    }
                }
            }

            Rectangle {
                anchors.top: messages.parent.bottom

                width: parent.width
                height: 50

                TextArea {
                    id: messageInput
                    width: parent.width
                    height: 50

                    Keys.onReturnPressed: {
                        if(event.modifiers & Qt.ShiftModifier) {
                            event.accepted = false
                        } else {
                            matrix.sendMessage(matrix.currentRoom, text)
                            clear()
                        }
                    }
                }
            }
        }

        Rectangle {
            id: memberList

            anchors.top: roomHeader.bottom
            anchors.left: messagesArea.right

            color: Qt.rgba(0.15, 0.15, 0.15, 1.0)

            width: 200
            height: parent.height - roomHeader.height

            ListView {
                model: matrix.memberModel

                anchors.fill: parent

                delegate: Rectangle {
                    width: parent.width
                    height: 50

                    color: "transparent"

                    Image {
                        id: memberAvatar

                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 10

                        sourceSize.width: 33
                        sourceSize.height: 33

                        source: avatarURL ? avatarURL : "placeholder.png"

                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: Item {
                                width: memberAvatar.width
                                height: memberAvatar.height
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: memberAvatar.width
                                    height: memberAvatar.height
                                    radius: Math.min(width, height)
                                }
                            }
                        }
                    }

                    Text {
                        anchors.left: memberAvatar.right
                        anchors.leftMargin: 10

                        anchors.verticalCenter: parent.verticalCenter

                        color: "white"

                        text: displayName
                    }

                    MouseArea {
                        anchors.fill: parent

                        acceptedButtons: Qt.RightButton

                        onClicked: memberContextMenu.popup()
                    }

                    Menu {
                        id: memberContextMenu

                        MenuItem {
                            text: "Profile"

                            onReleased: {
                                var popup = Qt.createComponent("qrc:/Profile.qml")
                                var popupContainer = popup.createObject(client, {"parent": client, "member": matrix.resolveMemberId(id)})

                                popupContainer.open()
                            }
                        }
                    }
                }

                ScrollBar.vertical: ScrollBar {}

                boundsBehavior: Flickable.StopAtBounds
                flickableDirection: Flickable.VerticalFlick
            }
        }

        Button {
            id: inviteButton

            width: memberList.width

            anchors.bottom: memberList.bottom
            anchors.right: memberList.right

            text: "Invite to room"

            onClicked: {
                var popup = Qt.createComponent("qrc:/InviteDialog.qml")
                var popupContainer = popup.createObject(window, {"parent": window})

                popupContainer.open()
            }
        }
    }

    Timer {
        id: syncTimer
        interval: 1500
        running: true
        onTriggered: {
            if(messages.contentY == messages.contentHeight - messages.height)
                shouldScroll = true
            else
                shouldScroll = false

            matrix.sync()
        }
    }

    Timer {
        id: memberTimer
        interval: 60000
        running: true
        onTriggered: matrix.updateMembers(matrix.currentRoom)
    }

    Connections {
        target: matrix
        onSyncFinished: {
            syncTimer.start()

            if(shouldScroll)
                messages.positionViewAtEnd()
        }

        onInitialSyncFinished: {
            matrix.changeCurrentRoom(0)
        }

        onCurrentRoomChanged: {
            matrix.readMessageHistory(matrix.currentRoom)
            matrix.updateMembers(matrix.currentRoom)
        }

        onMessage: {
            console.log(content)
            if(content.includes(matrix.displayName)) {
                desktop.showMessage(matrix.resolveMemberId(sender).displayName, content)
            }
        }
    }
}
