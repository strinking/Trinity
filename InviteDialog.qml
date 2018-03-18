import QtQuick 2.6
import QtQuick.Controls 2.3

Popup {
    id: dialog

    width: 300
    height: 110

    x: parent.width / 2 - width / 2
    y: parent.height / 2 - height / 2

    modal: true

    Text {
        id: descriptionLabel

        text: "Who do you want to invite to this room?"

        color: "white"
    }

    TextField {
        id: idField

        placeholderText: "Matrix id"

        anchors.top: descriptionLabel.bottom
        anchors.topMargin: 10
    }

    Button {
        anchors.top: idField.bottom

        text: "Invite"

        onClicked: {
            matrix.invite(matrix.currentRoom, idField.text)
            close()
        }
    }
}
