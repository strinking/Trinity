import QtQuick 2.10
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import QtQuick.Dialogs 1.2

import trinity.matrix 1.0

Rectangle {
    id: client
    color: Qt.rgba(0.05, 0.05, 0.05, 1.0)

    property bool shouldScroll: false

    ListView {
       id: channels
       width: 180
       height: parent.height
       anchors.right: rightArea.left
       anchors.left: client.left

       model: matrix.roomListModel

       section.property: "section"
       section.criteria: ViewSection.FullString
       section.delegate: Rectangle {
           width: parent.width
           height: 25

           color: "transparent"

           Text {
               anchors.verticalCenter: parent.verticalCenter

               anchors.left: parent.left
               anchors.leftMargin: 5

               text: section

               color: Qt.rgba(0.8, 0.8, 0.8, 1.0)

               textFormat: Text.PlainText
           }
       }

       delegate: Rectangle {
            width: parent.width
            height: 25

            property bool selected: channels.currentIndex === matrix.roomListModel.getOriginalIndex(index)

            color: selected ? "white" : "transparent"

            radius: 5

            Image {
                id: roomAvatar

                cache: true

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

                color: selected ? "black" : (highlightCount > 0 ? "red" : (notificationCount > 0 ? "blue" : "white"))

                textFormat: Text.PlainText
            }

            MouseArea {
                anchors.fill: parent

                cursorShape: Qt.PointingHandCursor

                acceptedButtons: Qt.LeftButton | Qt.RightButton

                onReleased: {
                    if(mouse.button == Qt.LeftButton) {
                        if(!selected) {
                            var originalIndex = matrix.roomListModel.getOriginalIndex(index)
                            matrix.changeCurrentRoom(originalIndex)
                            channels.currentIndex = originalIndex
                        }
                    } else
                        contextMenu.popup()
                }
            }

            Menu {
                id: contextMenu

                MenuItem {
                    text: "Mark As Read"

                    onReleased: matrix.readUpTo(matrix.getRoom(matrix.roomListModel.getOriginalIndex(index)), 0)
                }

                MenuSeparator {}

                GroupBox {
                    title: "Notification Settings"

                    Column {
                        spacing: 10

                        RadioButton {
                            text: "All messages"

                            ToolTip.text: "Recieve a notification for all messages in this room."
                            ToolTip.visible: hovered

                            onReleased: matrix.getRoom(matrix.roomListModel.getOriginalIndex(index)).notificationLevel = 2

                            checked: matrix.getRoom(matrix.roomListModel.getOriginalIndex(index)).notificationLevel === 2
                        }

                        RadioButton {
                            text: "Only Mentions"

                            ToolTip.text: "Recieve a notification for mentions in this room."
                            ToolTip.visible: hovered

                            onReleased: matrix.getRoom(matrix.roomListModel.getOriginalIndex(index)).notificationLevel = 1

                            checked: matrix.getRoom(matrix.roomListModel.getOriginalIndex(index)).notificationLevel === 1
                        }

                        RadioButton {
                            text: "Mute"

                            ToolTip.text: "Don't get notifications or unread indicators for this room."
                            ToolTip.visible: hovered

                            onReleased: matrix.getRoom(matrix.roomListModel.getOriginalIndex(index)).notificationLevel = 0

                            checked: matrix.getRoom(matrix.roomListModel.getOriginalIndex(index)).notificationLevel === 3
                        }
                    }
                }

                MenuSeparator {}

                MenuItem {
                    text: "Room Settings"

                    onReleased: stack.push("qrc:/RoomSettings.qml", {"room": matrix.getRoom(matrix.roomListModel.getOriginalIndex(index))})
                }

                MenuSeparator {}

                MenuItem {
                    text: "Leave Room"

                    onReleased: {
                        showDialog("Leave Confirmation", "Are you sure you want to leave " + alias + "?", [
                                       {
                                           text: "Yes",
                                           onClicked: function(dialog) {
                                                matrix.leaveRoom(id)
                                                dialog.close()
                                           }
                                       },
                                       {
                                           text: "No",
                                           onClicked: function(dialog) {
                                               dialog.close()
                                           }
                                       }
                                   ])
                    }
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

                cache: true

                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 15

                width: 33
                height: 33

                sourceSize.width: 33
                sourceSize.height: 33

                fillMode: Image.PreserveAspectFit

                source: matrix.currentRoom.avatar ? matrix.currentRoom.avatar : "placeholder.png"

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

                textFormat: Text.PlainText
            }

            Text {
                id: channelTopic

                width: showMemberListButton.x - x

                font.pointSize: 12

                anchors.verticalCenter: parent.verticalCenter

                anchors.left: channelTitle.right
                anchors.leftMargin: 5

                text: {
                    if(matrix.currentRoom.direct)
                        return "";

                    if(matrix.currentRoom.topic.length == 0)
                        return "This room has no topic set."
                    else
                        return matrix.currentRoom.topic
                }

                color: "gray"

                elide: Text.ElideRight

                MouseArea {
                    anchors.fill: parent

                    cursorShape: Qt.PointingHandCursor

                    onReleased: showDialog(matrix.currentRoom.name, matrix.currentRoom.topic)
                }

                textFormat: Text.PlainText
            }

            ToolButton {
                id: showMemberListButton

                width: 25
                height: 25

                anchors.verticalCenter: parent.verticalCenter

                anchors.right: settingsButton.left
                anchors.rightMargin: 10

                onClicked: {
                    if(memberList.width == 0)
                        memberList.width = 200
                    else
                        memberList.width = 0
                }

                ToolTip.visible: hovered
                ToolTip.text: "Member List"

                background: Rectangle { color: "transparent" }
                contentItem: Rectangle { color: "transparent" }

                visible: !matrix.currentRoom.direct

                Image {
                    id: memberListButtonImage

                    anchors.fill: parent

                    sourceSize.width: parent.width
                    sourceSize.height: parent.height

                    source: "icons/memberlist.png"
                }

                ColorOverlay {
                    anchors.fill: parent
                    source: memberListButtonImage

                    color: parent.hovered ? "white" : (memberList.width == 200 ? "white" : Qt.rgba(0.8, 0.8, 0.8, 1.0))
                }
            }

            ToolButton {
                id: settingsButton

                width: 25
                height: 25

                anchors.verticalCenter: parent.verticalCenter

                anchors.right: parent.right
                anchors.rightMargin: 15

                onClicked: stack.push("qrc:/Settings.qml")

                ToolTip.visible: hovered
                ToolTip.text: "Settings"

                background: Rectangle { color: "transparent" }
                contentItem: Rectangle { color: "transparent" }

                Image {
                    id: settingsButtonImage

                    anchors.fill: parent

                    sourceSize.width: parent.width
                    sourceSize.height: parent.height

                    source: "icons/settings.png"
                }

                ColorOverlay {
                    anchors.fill: parent
                    source: settingsButtonImage

                    color: parent.hovered ? "white" : Qt.rgba(0.8, 0.8, 0.8, 1.0)
                }
            }
        }

        Rectangle {
            id: messagesArea

            width: parent.width - memberList.width
            height: parent.height - roomHeader.height

            anchors.top: roomHeader.bottom

            Rectangle {
                height: parent.height - messageInputParent.height
                width: parent.width

                clip: true

                color: Qt.rgba(0.1, 0.1, 0.1, 1.0)

                ListView {
                    id: messages
                    model: matrix.eventModel

                    anchors.fill: parent

                    cacheBuffer: 200

                    delegate: Rectangle {                        
                        width: parent.width
                        height: (condense ? 5 : 25) + messageArea.height

                        color: "transparent"

                        property string attachment: display.attachment
                        property var sender: matrix.resolveMemberId(display.sender)
                        property var eventId: display.eventId
                        property var msg: display.msg

                        Image {
                            id: avatar

                            width: 33
                            height: 33

                            cache: true

                            anchors.top: parent.top
                            anchors.topMargin: 5
                            anchors.left: parent.left
                            anchors.leftMargin: 5

                            sourceSize.width: 33
                            sourceSize.height: 33

                            source: sender.avatarURL ? sender.avatarURL : "placeholder.png"

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

                            text: condense ? "" : sender.displayName

                            color: "white"

                            anchors.left: avatar.right
                            anchors.leftMargin: 10

                            textFormat: Text.PlainText
                        }

                        Text {
                            text: condense ? "" : timestamp

                            color: "gray"

                            anchors.left: senderText.right
                            anchors.leftMargin: 10

                            textFormat: Text.PlainText
                        }

                        Rectangle {
                            id: messageArea

                            y: condense ? 0 : 20

                            height: {
                                if(display.msgType === "text")
                                    return message.contentHeight
                                else if(display.msgType === "image")
                                    return messageThumbnail.height
                                else
                                    return preview.height
                            }

                            width: parent.width

                            anchors.left: condense ? parent.left : avatar.right
                            anchors.leftMargin: condense ? 48 : 10

                            color: "transparent"

                            TextEdit {
                                id: message

                                text: display.msg

                                width: parent.width

                                wrapMode: Text.Wrap
                                textFormat: Text.RichText

                                readOnly: true
                                selectByMouse: true

                                color: display.sent ? "white" : "gray"

                                visible: display.msgType === "text"
                            }

                            Image {
                                id: messageThumbnail

                                visible: display.msgType === "image"

                                source: display.thumbnail

                                fillMode: Image.PreserveAspectFit
                                width: Math.min(sourceSize.width, 400)
                            }

                            MouseArea {
                                enabled: display.msgType === "image"

                                cursorShape: Qt.PointingHandCursor

                                anchors.fill: messageThumbnail

                                onReleased: showImage(display.attachment)
                            }

                            Rectangle {
                                id: preview

                                width: 350
                                height: 45

                                visible: display.msgType === "file"

                                radius: 5

                                color: Qt.rgba(0.05, 0.05, 0.05, 1.0)

                                Text {
                                    id: previewFilename

                                    x: 15
                                    y: 7

                                    text: display.msg

                                    color: "#048dc2"
                                }

                                Text {
                                    id: previewFilesize

                                    x: 15
                                    y: 22

                                    font.pointSize: 9

                                    text: display.attachmentSize / 1000.0 + " KB"

                                    color: "gray"
                                }

                                ToolButton {
                                    id: previewFileDownload

                                    width: 25
                                    height: 25

                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.right: parent.right
                                    anchors.rightMargin: 10

                                    Image {
                                        id: downloadButtonImage

                                        anchors.fill: parent

                                        sourceSize.width: parent.width
                                        sourceSize.height: parent.height

                                        source: "icons/download.png"
                                    }

                                    ColorOverlay {
                                        anchors.fill: parent
                                        source: downloadButtonImage

                                        color: parent.hovered ? "white" : Qt.rgba(0.8, 0.8, 0.8, 1.0)
                                    }

                                    onClicked: {
                                        console.log(attachment)
                                        Qt.openUrlExternally(attachment)
                                    }
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: messageArea

                            acceptedButtons: Qt.RightButton

                            propagateComposedEvents: true

                            onClicked: contextMenu.popup()
                        }

                        Menu {
                            id: contextMenu

                            MenuItem {
                                text: "Remove"

                                onReleased: matrix.removeMessage(eventId)
                            }

                            MenuItem {
                                text: "Permalink"

                                onReleased: Qt.openUrlExternally("https://matrix.to/#/" + matrix.currentRoom.id + "/" + eventId)
                            }

                            MenuItem {
                                text: "Quote"

                                onReleased: messageInput.append("> " + msg + "\n\n")
                            }
                        }
                    }

                    ScrollBar.vertical: ScrollBar {}

                    boundsBehavior: Flickable.StopAtBounds
                    flickableDirection: Flickable.VerticalFlick
                    verticalLayoutDirection: ListView.BottomToTop

                    onMovingVerticallyChanged: {
                        if(verticalVelocity < 0)
                           matrix.readMessageHistory(matrix.currentRoom)
                    }

                    // we scrolled
                    onContentYChanged: {
                        var index = indexAt(0, contentY + height - 5)
                        matrix.readUpTo(matrix.currentRoom, index)
                    }

                    // a new message was added
                    onContentHeightChanged: {
                        var index = indexAt(0, contentY + height - 5)
                        matrix.readUpTo(matrix.currentRoom, index)
                    }
                }

                Rectangle {
                    id: overlay

                    anchors.fill: parent

                    visible: matrix.currentRoom.guestDenied

                    Text {
                        id: invitedByLabel

                        anchors.centerIn: parent

                        color: "white"

                        text: "You have been invited to this room by " + matrix.currentRoom.invitedBy

                        textFormat: Text.PlainText
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
                id: messageInputParent

                anchors.top: messages.parent.bottom

                width: parent.width
                height: 55

                color: Qt.rgba(0.1, 0.1, 0.1, 1.0)

                ToolButton {
                    id: attachButton

                    icon.name: "mail-attachment"

                    width: 30
                    height: 30

                    anchors.top: parent.top
                    anchors.topMargin: 5

                    anchors.left: parent.left
                    anchors.leftMargin: 5

                    ToolTip.text: "Attach File"
                    ToolTip.visible: hovered

                    onReleased: openAttachmentFileDialog.open()
                }

                TextArea {
                    id: messageInput

                    width: parent.width - attachButton.width - 10
                    height: 30

                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 20

                    anchors.left: attachButton.right
                    anchors.leftMargin: 5

                    anchors.right: parent.right
                    anchors.rightMargin: 5

                    placeholderText: "Message " + matrix.currentRoom.name

                    Keys.onReturnPressed: {
                        if(event.modifiers & Qt.ShiftModifier) {
                            event.accepted = false
                        } else {
                            event.accepted = true
                            matrix.sendMessage(matrix.currentRoom, text)
                            clear()
                        }
                    }

                    onTextChanged: {
                        height = Math.max(30, contentHeight + 13)
                        parent.height = Math.max(55, contentHeight + 20)
                    }
                }

                ToolButton {
                    id: markdownButton

                    icon.name: "text-x-generic"

                    width: 20
                    height: 20

                    anchors.top: messageInput.top
                    anchors.topMargin: 5

                    anchors.right: emojiButton.left
                    anchors.rightMargin: 5

                    ToolTip.text: "Markdown is " + (matrix.markdownEnabled ? "enabled" : "disabled")
                    ToolTip.visible: hovered

                    onReleased: matrix.markdownEnabled = !matrix.markdownEnabled
                }

                ToolButton {
                    id: emojiButton

                    icon.name: "face-smile"

                    width: 20
                    height: 20

                    anchors.top: messageInput.top
                    anchors.topMargin: 5

                    anchors.right: messageInput.right
                    anchors.rightMargin: 5

                    ToolTip.text: "Add emoji"
                    ToolTip.visible: hovered
                }

                Text {
                    id: typingLabel

                    anchors.bottom: messageInputParent.bottom

                    color: "white"

                    text: matrix.typingText

                    textFormat: Text.PlainText
                }
            }
        }

        Rectangle {
            id: memberList

            anchors.top: roomHeader.bottom
            anchors.left: messagesArea.right

            color: Qt.rgba(0.15, 0.15, 0.15, 1.0)

            width: matrix.currentRoom.direct ? 0 : 200
            height: parent.height - roomHeader.height

            ListView {
                model: matrix.memberModel

                anchors.fill: parent

                delegate: Rectangle {
                    width: parent.width
                    height: 50

                    color: "transparent"

                    property string memberId: id

                    Image {
                        id: memberAvatar

                        cache: true

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

                        textFormat: Text.PlainText
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

                        MenuItem {
                            text: "Mention"

                            onReleased: messageInput.append(displayName + ": ")
                        }

                        MenuItem {
                            text: "Start Direct Chat"

                            onReleased: matrix.startDirectChat(id)
                        }

                        MenuSeparator {}

                        Menu {
                            title: "Invite to room"

                            Repeater {
                                model: matrix.roomListModel

                                MenuItem {
                                    text: alias

                                    onReleased: {
                                        matrix.inviteToRoom(matrix.resolveRoomId(id), memberId)
                                    }
                                }
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
            shouldScroll = messages.contentY == messages.contentHeight - messages.height

            matrix.sync()
        }
    }

    Timer {
        id: memberTimer
        interval: 60000
        running: true
        onTriggered: matrix.updateMembers(matrix.currentRoom)
    }

    Timer {
        id: typingTimer
        interval: 15000 //15 seconds
        running: true
        onTriggered: {
            if(messageInput.text.length !== 0)
                matrix.setTyping(matrix.currentRoom)
        }
    }

    Connections {
        target: matrix
        onSyncFinished: {
            syncTimer.start()

            if(shouldScroll)
                messages.positionViewAtEnd()
        }

        onInitialSyncFinished: matrix.changeCurrentRoom(0)

        onCurrentRoomChanged: {
            if(messages.contentY < messages.originY + 5)
                matrix.readMessageHistory(matrix.currentRoom)
        }

        onMessage: {
            var notificationLevel = room.notificationLevel
            var shouldDisplay = false

            if(notificationLevel === 2) {
                shouldDisplay = true
            } else if(notificationLevel === 1) {
                if(content.includes(matrix.displayName))
                    shouldDisplay = true
            }

            if(shouldDisplay)
                desktop.showMessage(matrix.resolveMemberId(sender).displayName + " (" + room.name + ")", content)
        }
    }

    FileDialog {
        id: openAttachmentFileDialog
        folder: shortcuts.home

        selectExisting: true
        selectFolder: false
        selectMultiple: false

        onAccepted: {
            matrix.uploadAttachment(matrix.currentRoom, fileUrl)
            close()
        }

        onRejected: close()
    }
}
