import QtQuick 2.10
import QtQuick.Window 2.10
import QtQuick.Controls 2.3

import trinity.matrix 1.0

ApplicationWindow {
    id: window
    visible: true
    width: 640
    height: 480
    title: "Trinity"

    property var showDialog: function(title, description, buttons) {
        var popup = Qt.createComponent("qrc:/Dialog.qml")
        var popupContainer = popup.createObject(window, {"parent": window, "title": title, "description": description, "buttons": buttons})

        popupContainer.open()
    }

    Component.onCompleted: {
        if(matrix.settingsValid()) {
            desktop.showTrayIcon(false)
            stack.push("qrc:/Client.qml")
        } else {
            desktop.showTrayIcon(true)
            stack.push("qrc:/Login.qml")
        }
    }

    StackView {
        id: stack
        anchors.fill: parent
    }
}
