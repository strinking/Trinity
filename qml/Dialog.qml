import QtQuick 2.6
import QtQuick.Controls 2.3

Popup {
    id: dialog

    width: 256
    height: buttons != null ? 110 : 60

    x: parent.width / 2 - width / 2
    y: parent.height / 2 - height / 2

    modal: true

    property string title: ""
    property string description: ""

    property var buttons: []

    Text {
        id: titleLabel

        text: title

        color: "white"
    }

    Text {
        id: descriptionLabel

        text: description

        anchors.top: titleLabel.bottom

        color: "white"
    }

    Repeater {
        model: buttons

        delegate: Button {
            text: buttons[index].text

            anchors.top: descriptionLabel.bottom
            anchors.topMargin: 10

            x: index * width + 10

            onClicked: buttons[index].onClicked(dialog)
        }
    }
}
