import QtQuick 1.1
import components 1.0
import "../components/styles.js" as Style
import models 1.0

Item {
    id: root
    anchors.left: parent.left
    anchors.right: parent.right

    property variant headerStyle: Style.TrafficEventHeader
    height: headerStyle.height

    property bool leftButtonDisabled: false
    property bool rightButtonDisabled: false
    property string color

    signal leftButtonClicked()
    signal rightButtonClicked()

    states: [
        State {
            name: "normal"
            when: !mouseAreaLeft.pressed && !root.leftButtonDisabled && !mouseAreaRight.pressed && !root.rightButtonDisabled
            PropertyChanges {
                target: leftButton
                iconX: headerStyle.arrow.left.normal.x
                iconY: headerStyle.arrow.left.normal.y
            }
            PropertyChanges {
                target: rightButton                
                iconX: headerStyle.arrow.right.normal.x
                iconY: headerStyle.arrow.right.normal.y
            }
        },
        State {
            name: "leftpressed"
            when: mouseAreaLeft.pressed && !root.leftButtonDisabled
            PropertyChanges {
                target: leftButton
                iconX: headerStyle.arrow.left.down.x
                iconY: headerStyle.arrow.left.down.y

            }
        },
        State {
            name: "rightpressed"
            when: mouseAreaRight.pressed && !root.rightButtonDisabled
            PropertyChanges {
                target: rightButton
                iconX: headerStyle.arrow.right.down.x
                iconY: headerStyle.arrow.right.down.y

            }
        }
    ]

    Rectangle {
        id: traffic
        anchors.left: leftButton.right
        anchors.right: rightButton.left
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        anchors.margins: headerStyle.margins
        color: root.color
        radius: headerStyle.radius

        Item {
            width: headerStyle.trafficIcon.width
            height: headerStyle.trafficIcon.height
            anchors.centerIn: parent
            clip: true
            opacity: 1

            Image {
                source: headerStyle.trafficIcon.source
                anchors.centerIn: parent
            }
        }
    }

    Rectangle {
        id: leftButton
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        width: headerStyle.arrow.width
        anchors.margins: headerStyle.margins
        color: headerStyle.arrow.bgcolor
        radius: headerStyle.radius
        property int iconX: root.leftButtonDisabled ? headerStyle.arrow.left.disabled.x : headerStyle.arrow.left.normal.x
        property int iconY: root.leftButtonDisabled ? headerStyle.arrow.left.disabled.y : headerStyle.arrow.left.normal.y
        Item {
            anchors.centerIn: parent
            width: parent.width
            height: headerStyle.arrow.height
            clip: true
            opacity: 1

            Image {
                source: headerStyle.arrow.source
                x: leftButton.iconX
                y: leftButton.iconY
            }
        }

        MouseArea {
            id: mouseAreaLeft
            anchors.fill: parent
            property string oldState

            onClicked: {
                if (mouseAreaLeft.containsMouse) {
                    oldState = root.state
                    leftButtonClicked();
                }
            }

            onPressed: {
                oldState = root.state;
                if (mouseAreaLeft.containsMouse) {
                    root.state = "leftpressed";
                }
            }

            onReleased: {
                root.state = oldState;
            }

            onCanceled: {
                root.state = oldState;
            }
        }
    }

    Rectangle {
        id: rightButton
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height:  parent.height
        width: headerStyle.arrow.width
        anchors.margins: headerStyle.margins
        color: headerStyle.arrow.bgcolor
        radius: headerStyle.radius
        property int iconX: root.rightButtonDisabled ? headerStyle.arrow.right.disabled.x : headerStyle.arrow.right.normal.x
        property int iconY: root.rightButtonDisabled ? headerStyle.arrow.right.disabled.y : headerStyle.arrow.right.normal.y

        Item {
            anchors.centerIn: parent
            width: parent.width
            height: headerStyle.arrow.height
            clip: true
            opacity: 1

            Image {
                source: headerStyle.arrow.source
                x: rightButton.iconX
                y: rightButton.iconY
            }
        }

        MouseArea {
            id: mouseAreaRight
            anchors.fill: parent
            property string oldState

            onClicked: {
                if (mouseAreaRight.containsMouse) {
                    oldState = root.state
                    rightButtonClicked();
                }
            }

            onPressed: {
                oldState = root.state
                if (mouseAreaRight.containsMouse) {
                    root.state = "rightpressed";
                }
            }

            onReleased: {
                root.state = oldState;
            }

            onCanceled: {
                root.state = oldState;
            }
        }
    }
}
