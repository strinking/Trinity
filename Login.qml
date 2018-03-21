import QtQuick 2.10
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import QtQuick.Shapes 1.0

Rectangle {
    id: login

    Component {
        id: customButton

        Rectangle {
            property string text
            property var onClicked

            height: 30

            color: "transparent"

            radius: 3

            border.width: 1
            border.color: enabled ? "white" : "gray"

            Text {
                anchors.centerIn: parent

                text: parent.text

                color: parent.enabled ? "white" : "gray"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: parent.onClicked()
            }
        }
    }

    Image {
        id: background

        anchors.centerIn: parent
        anchors.fill: parent

        fillMode: Image.PreserveAspectCrop

        source: "background.jpg"
    }

    ShaderEffectSource {
         id: effectSource

         sourceItem: background
         anchors.centerIn: background
         width: loginContainer.width
         height: loginContainer.height

         sourceRect: Qt.rect(loginContainer.x, loginContainer.y, loginContainer.width, loginContainer.height)
     }

     FastBlur {
         id: blur
         anchors.fill: effectSource

         source: effectSource
         radius: 64
     }

    Rectangle {
        id: loginContainer

        width: 600
        height: 300

        anchors.centerIn: parent

        color: Qt.rgba(0.1, 0.1, 0.1, 0.4)

        Rectangle {
            id: loginForm

            width: parent.width / 2
            height: parent.height

            color: "transparent"

            Rectangle {
                width: parent.width - 50
                height: parent.height - 50

                anchors.centerIn: parent

                color: "transparent"

                Label {
                    id: loginLabel

                    text: "Login to " + matrix.homeserverURL

                    font.pointSize: 18
                    font.bold: true

                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.topMargin: 15
                }

                Label {
                    id: usernameLabel

                    text: "Username"

                    anchors.top: loginLabel.bottom
                    anchors.topMargin: 20
                }

                TextField {
                    id: usernameField

                    width: parent.width

                    anchors.top: usernameLabel.bottom

                    background: Rectangle {
                       color: Qt.rgba(0.1, 0.1, 0.1, 0.3)
                       border.color: parent.enabled ? "white" : "gray"
                       border.width: 1
                       radius: 3
                   }
                }

                Label {
                    id: passwordLabel

                    anchors.top: usernameField.bottom
                    anchors.topMargin: 5

                    text: "Password"
                }

                TextField {
                    id: passwordField

                    width: parent.width

                    anchors.top: passwordLabel.bottom

                    echoMode: TextInput.Password

                    background: Rectangle {
                       color: Qt.rgba(0.1, 0.1, 0.1, 0.3)
                       border.color: parent.enabled ? "white" : "gray"
                       border.width: 1
                       radius: 3
                   }
                }

                Text {
                    id: resetPasswordLink

                    anchors.top: passwordField.bottom

                    text: "Forgot your password?"
                    color: "grey"

                    font.underline: true

                    font.pointSize: 9
                }

                Rectangle {
                    id: loginButtons

                    width: 90 + 120 + 5
                    height: 25

                    anchors.top: passwordField.bottom
                    anchors.topMargin: 35

                    anchors.horizontalCenter: parent.horizontalCenter

                    color: "transparent"

                    Loader {
                        id: loginButton

                        width: 90

                        sourceComponent: customButton

                        onLoaded: {
                            item.text = "Login"
                            item.onClicked = function() {
                                setLoginState(false)
                                matrix.login(usernameField.text, passwordField.text)
                            }
                        }
                    }

                    Loader {
                        id: changeServerButton

                        width: 120

                        sourceComponent: customButton
                        anchors.left: loginButton.right
                        anchors.leftMargin: 5

                        onLoaded: {
                            item.text = "Change Server"
                            item.onClicked = function() {
                                stack.push("qrc:/ServerSelection.qml")
                            }
                        }
                    }
                }

                Text {
                    id: createAccountLink

                    anchors.top: loginButtons.bottom
                    anchors.topMargin: 20
                    anchors.horizontalCenter: parent.horizontalCenter

                    text: "Create an account"

                    font.underline: true

                    color: "white"

                    MouseArea {
                        anchors.fill: parent

                        onClicked: stack.push("qrc:/AccountCreation.qml")
                    }
                }
            }
        }

        Shape {
            id: seperator

            anchors.left: loginForm.right
            anchors.verticalCenter: parent.verticalCenter

            width: 10
            height: parent.height - 50

            ShapePath {
                strokeColor: "white"
                strokeWidth: 1

                PathLine {
                    y: seperator.height
                }
            }
        }

        Rectangle {
            id: infoForm

            anchors.top: parent.top
            anchors.topMargin: 15
            anchors.rightMargin: 15

            width: parent.width / 2
            height: parent.height

            anchors.left: seperator.right

            color: "transparent"

            Image {
                id: matrixInfoLogo

                anchors.horizontalCenter: parent.horizontalCenter

                anchors.top: parent.top
                anchors.topMargin: 55

                width: 120

                sourceSize.width: width
                sourceSize.height: height

                source: "matrix-logo.png"

                fillMode: Image.PreserveAspectFit

                smooth: true
            }

            DropShadow {
                id: matrixInfoLogoShadow
                anchors.fill: matrixInfoLogo

                verticalOffset: 6

                radius: 18
                color: "#aa000000"
                smooth: true
                cached: true
                samples: 20

                source: matrixInfoLogo
            }

            Text {
                id: matrixInfoDesc

                text: "Matrix is a free and open network for secure, decentralized communication."

                width: parent.width - 35

                anchors.top: matrixInfoLogo.bottom
                anchors.topMargin: 15

                color: "white"

                wrapMode: Text.WordWrap

                anchors.horizontalCenter: parent.horizontalCenter

                horizontalAlignment: Text.AlignHCenter
            }

            Loader {
                sourceComponent: customButton

                id: matrixInfoLearnMore

                width: 110

                anchors.top: matrixInfoDesc.bottom
                anchors.topMargin: 25

                anchors.horizontalCenter: parent.horizontalCenter

                onLoaded: {
                    item.text = "Learn More"
                    item.onClicked = function() {
                        Qt.openUrlExternally("https://matrix.org/")
                    }
                }
            }
        }
    }

    Text {
        text: "Version 1.0.0"

        color: "white"

        anchors.right: parent.right
        anchors.bottom: parent.bottom

        horizontalAlignment: Text.AlignRight
    }

    Connections {
        target: matrix

        onLoginAttempt: {
            setLoginState(true)

            if(error) {
                passwordField.clear()

                showDialog("Error while logging in", description)
            } else {
                desktop.showTrayIcon(true)
                stack.push("qrc:/Client.qml", {replace: true})
            }
        }
    }

    property var setLoginState: function(enabled) {
        usernameField.enabled = enabled
        passwordField.enabled = enabled
        loginButton.enabled = enabled
        resetPasswordLink.enabled = enabled
        changeServerButton.enabled = enabled
        createAccountLink.enabled = enabled
    }
}
