import QtQuick 1.1
import "styles.js" as Style

Item {
    id: mapControl
    property variant style: Style.MapControl
    property string type: "zoomIn"

    signal clicked
    signal pressAndHold
    signal pressed
    signal released

    width: style.width
    height: style.height

    states: [
        State {
            name: "normal"
            when: !mouseArea.pressed
            PropertyChanges {
                target: background
                source: style.button.bg_normal
            }
        },
        State {
            name: "down"
            when: mouseArea.pressed
            PropertyChanges {
                target: background
                source: style.button.bg_pressed
            }
        }
    ]


    Image {
        id: background
        anchors.centerIn: parent
        width: style.width
        height: style.height
    }

    Image {
        id: icon
        anchors.centerIn: parent
        source: style.button[type].source
    }

    // click area
    MouseArea {
        id: mouseArea
        width: style.width + 12
        height: style.height + 12
        anchors.centerIn: parent
        onClicked: !parent.disable && parent.clicked()
        onPressAndHold: !parent.disable && parent.pressAndHold()
        onPressed: !parent.disable && parent.pressed()
        onReleased: !parent.disable && parent.released()
        onExited: !parent.disable && parent.released()
    }
}
