import QtQuick 2.10
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import QtQuick.Shapes 1.0

Rectangle {
    id: settings

    color: Qt.rgba(0.1, 0.1, 0.1, 1.0)

    Component.onCompleted: matrix.updateAccountInformation()

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

        TabBar {
            id: bar

            width: parent.width

            anchors.top: backButton.bottom

            TabButton {
                text: "Account"
            }

            TabButton {
                text: "Notifications"
            }

            TabButton {
                text: "Appearance"
            }
        }

        SwipeView {
            id: settingsStack

            anchors.top: bar.bottom

            width: parent.width
            height: parent.height

            currentIndex: bar.currentIndex

            clip: true

            Item {
                id: accountTab

                Label {
                    id: usernameLabel

                    text: "Username"
                }

                TextField {
                    id: usernameField

                    text: matrix.getUsername()

                    enabled: false

                    anchors.top: usernameLabel.bottom
                }

                Label {
                    id: displayNameLabel

                    text: "Display Name"

                    anchors.top: usernameField.bottom
                }

                TextField {
                    id: displayNameField

                    text: matrix.displayName

                    anchors.top: displayNameLabel.bottom
                }

                Label {
                    id: emailLabel

                    text: "Email"

                    anchors.top: displayNameField.bottom
                }

                TextField {
                    id: emailField

                    anchors.top: emailLabel.bottom
                }

                Button {
                    id: saveButton

                    text: "Save"

                    anchors.top: emailField.bottom

                    onClicked: {
                        matrix.setDisplayName(displayNameField.text)
                    }
                }

                Button {
                    id: logoutButton

                    text: "Log out"

                    anchors.top: emailField.bottom
                    anchors.left: saveButton.right

                    onClicked: {
                        matrix.logout();

                        desktop.showTrayIcon(false)

                        stack.pop();
                        stack.push("qrc:/Login.qml")
                    }
                }

                Button {
                    id: deactivateButton

                    text: "Deactivate Account"

                    anchors.top: emailField.bottom
                    anchors.left: logoutButton.right
                }
            }

            Item {
                id: notificationsTab

                CheckBox {
                    text: "Enable Desktop Notifications"
                }
            }

            Item {
                id: appearanceTab
            }
        }
    }
}
