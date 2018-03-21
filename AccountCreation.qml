import QtQuick 2.10
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import QtQuick.Shapes 1.0

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

        Rectangle {
            width: 200
            height: 300

            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter

            color: "transparent"

            Text {
                id: accountCreationLabel

                anchors.top: parent.top
                anchors.topMargin: 15

                text: "Create an account"

                font.pointSize: 18

                color: "white"
            }

            Text {
                id: usernameLabel

                anchors.top: accountCreationLabel.bottom
                anchors.topMargin: 10

                text: "Username"

                color: "white"
            }

            TextField {
                id: usernameField

                anchors.top: usernameLabel.bottom
            }

            Text {
                id: passwordLabel

                anchors.top: usernameField.bottom

                text: "Password"

                color: "white"
            }

            TextField {
                id: passwordField

                anchors.top: passwordLabel.bottom

                echoMode: TextInput.Password
            }

            Button {
                id: registerButton

                anchors.top: passwordField.bottom
                anchors.topMargin: 15

                anchors.horizontalCenter: parent.horizontalCenter

                text: "Register"

                onClicked: {
                    setRegisterState(false)
                    matrix.registerAccount(usernameField.text, passwordField.text)
                }
            }
        }
    }

    Connections {
        target: matrix

        onRegisterAttempt: {
            setRegisterState(true)

            if(error) {
                showDialog("Error while registering account", description)
            } else {
                desktop.showTrayIcon(true)
                stack.push("qrc:/Client.qml", {replace: true})
            }
        }

        onRegisterFlow: {
            if(data["type"] === "m.login.recaptcha") {
                Qt.openUrlExternally("https://" + matrix.homeserverURL + "/_matrix/client/r0/auth/m.login.recaptcha/fallback/web?session=" + data["session"])

                showDialog("Needs additional authentication", "Please complete the recaptcha", [
                               {
                                   text: "Done",
                                   onClicked: function(dialog) {
                                       matrix.registerAccount(usernameField.text, passwordField.text, data["session"], data["type"])
                                   }
                               },
                               {
                                   text: "Cancel",
                                   onClicked: function(dialog) {
                                       dialog.close()
                                       setRegisterState(false)
                                   }
                               }
                           ])
            } else if(data["type"] === "m.login.dummy") {
                matrix.registerAccount(usernameField.text, passwordField.text, data["session"], data["type"])
            }
        }
    }

    property var setRegisterState: function(enabled) {
        usernameField.enabled = enabled
        passwordField.enabled = enabled
        registerButton.enabled = enabled
        backButton.enabled = enabled
    }
}
