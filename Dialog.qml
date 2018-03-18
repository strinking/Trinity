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

    Component.onCompleted: {
        if(!buttons)
            return;

        var lastX = 0
        for(var i = 0; i < buttons.length; i++) {
            var button = popupButton.createObject(buttonHolder, {text: buttons[i].text, x: lastX })
            lastX = button.width + 10

            button.onClicked.connect(buttons[i].onClicked)
        }
    }

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

    Rectangle {
        id: buttonHolder

        anchors.top: descriptionLabel.bottom
        anchors.topMargin: 10
    }

    Component {
        id: popupButton

        Button {}
    }
}
