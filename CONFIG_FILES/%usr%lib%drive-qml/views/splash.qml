import QtQuick 1.1

Rectangle {
    id: appContainer
    width: device.width
    height: device.height
    color: "black"

    Rectangle {
        id: splash
        z: 2
        color: "black"
        anchors.centerIn: parent;
        property bool isLandscape: true

        Connections {
            target: device
            onOrientationChanged: {
                splash.isLandscape = device.orientation == "landscape";
            }
        }

        states: [
            State {
                name: "landscape"
                when: splash.isLandscape
                PropertyChanges {
                    target: splash
                    width: device.width
                    height: device.height
                    rotation: 0
                }
            },
            State {
                name: "portrait"
                when: !splash.isLandscape
                PropertyChanges {
                    target: splash
                    width: device.height
                    height: device.width
                    rotation: -90
                }
            }
        ]

        Item {
            width: 128
            height: 208
            anchors.centerIn: parent

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                source: "../resources/icon_drive.png"
            }

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                source: "../resources/loading_icon.png"
            }
        }

        Component.onCompleted: {
            startTimer.running = true;
        }

        Timer {
            id: startTimer
            interval: 50
            repeat: false
            onTriggered: {
                var component = Qt.createComponent("main.qml");

                if (component.status == Component.Error)
                    console.log("Error loading page " + component.url + ", error: " + component.errorString());

                var page = component.createObject(appContainer);
            }
        }
    }
}
