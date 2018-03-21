import QtQuick 2.10
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import QtQuick.Shapes 1.0

Rectangle {
    id: serverSelect

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

        Rectangle {
            width: parent.width
            height: 300

            anchors.verticalCenter: parent.verticalCenter

            color: "transparent"

            Text {
                id: whatIsHeader

                anchors.top: parent.top

                text: "What is a homeserver?"

                font.pointSize: 11
                font.bold: true

                color: "white"
            }

            Text {
                id: whatIsDesc

                width: parent.width

                anchors.top: whatIsHeader.bottom

                text: "Your homeserver is where you login and register your account. Your homeserver also makes up the second part of your user id: username@<homeserver url>."

                wrapMode: Text.WordWrap

                color: "white"
            }

            Text {
                id: canIHeader

                anchors.top: whatIsDesc.bottom
                anchors.topMargin: 10

                text: "Can I only join rooms on my homeserver?"

                font.pointSize: 11
                font.bold: true

                color: "white"
            }

            Text {
                id: canIDesc

                width: parent.width

                anchors.top: canIHeader.bottom

                text: "You are not limited to rooms that exist on your homeserver, you can join any other public server's rooms from any homeserver."

                wrapMode: Text.WordWrap

                color: "white"
            }

            Text {
                id: whatIfHeader

                anchors.top: canIDesc.bottom
                anchors.topMargin: 10

                text: "What if I don't like my homeserver?"

                font.pointSize: 11
                font.bold: true

                color: "white"
            }

            Text {
                id: whatIfDesc

                width: parent.width

                anchors.top: whatIfHeader.bottom

                text: "Simply don't use that server's account anymore. The homeserver may even have an option to delete your account."

                wrapMode: Text.WordWrap

                color: "white"
            }

            Text {
                id: whatHomeHeader

                anchors.top: whatIfDesc.bottom
                anchors.topMargin: 10

                text: "What homeserver should I choose?"

                font.pointSize: 11
                font.bold: true

                color: "white"
            }

            Text {
                id: whatHomeDesc

                width: parent.width

                anchors.top: whatHomeHeader.bottom

                text: "Since you can join any publicly accessible room from any homeserver, its mostly up to personal preference. If you don't like any server that's out there, you can always run your own."

                wrapMode: Text.WordWrap

                color: "white"
            }

            Rectangle {
                anchors.top: whatHomeDesc.bottom
                anchors.topMargin: 25

                height: 30
                width: parent.width

                color: "transparent"

                TextField {
                    id: urlField

                    width: parent.width - changeButton.width

                    placeholderText: "matrix.org"

                    Component.onCompleted: text = matrix.homeserverURL
                }

                Button {
                    id: changeButton

                    anchors.left: urlField.right

                    text: "Change"

                    onClicked: matrix.setHomeserver(urlField.text)
                }
            }
        }
    }

    Connections {
        target: matrix

        onHomeserverChanged: {
            if(valid) {
                stack.pop()
            } else {
                showDialog("Error while connecting to homeserver", description)
            }
        }
    }
}
