import QtQuick 2.0

Rectangle {
    anchors.fill: parent

    color: Qt.rgba(0.0, 0.0, 0.0, 0.5)

    property string url

    Image {
        id: imagePreview

        width: 500
        fillMode: Image.PreserveAspectFit

        anchors.centerIn: parent

        source: url
    }

    Text {
        id: downloadLink

        anchors.right: imagePreview.right
        anchors.top: imagePreview.bottom
        anchors.topMargin: 5

        text: "Download"

        color: "#048dc2"

        z: 5

        MouseArea {
            anchors.fill: downloadLink

            cursorShape: Qt.PointingHandCursor

            onReleased: Qt.openUrlExternally(url)
        }
    }

    MouseArea {
        anchors.fill: parent

        propagateComposedEvents: true

        onReleased: parent.destroy()
    }
}
