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

        Button {
            id: backButton

            text: "Back"

            onClicked: stack.pop()
        }

        Text {
            id: usernameLabel

            anchors.top: backButton.bottom

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

            text: "Register"

            onClicked: {
                setRegisterState(false)
                matrix.registerAccount(usernameField.text, passwordField.text)
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
                                   onClicked: function() {
                                       matrix.registerAccount(usernameField.text, passwordField.text, data["session"], data["type"])
                                   }
                               },
                               {
                                   text: "Cancel",
                                   onClicked: function() {
                                       close()
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
