import QtQuick 1.1
import "styles.js" as Style

Item {
    id: scrollButton
    property string type: "scrollUp"
    property bool disable: false
    signal clicked
    property variant scrollBarButtonStyle: Style.ScrollBarButton

    width: parent.width
    height: parent.height/2

    states: [
        State {
            name: "normal"
            when: !(scrollButton.disable || mouseArea.pressed)
            // foreground
            PropertyChanges {
                target: foreground
                color: scrollBarButtonStyle.foregroundColor.normal
            }
        },
        State {
            name: "down"
            when: !scrollButton.disable && mouseArea.pressed
            // foreground
            PropertyChanges {
                target: foreground
                color: scrollBarButtonStyle.foregroundColor.down
            }
        },
        State {
            name: "disabled"
            when: scrollButton.disable
            // action button
            PropertyChanges {
                target: foreground
                color: scrollBarButtonStyle.foregroundColor.disabled
            }
        }
    ]

    Image {
        id: background
        source: scrollBarButtonStyle.backgroundSource
    }

    Rectangle {
        id: foreground
        anchors.fill: parent
    }

    FunctionButton {
        id: functionButton
        type: scrollButton.type
        disable: scrollButton.disable
        // propagate the state down to the child button
        state: scrollButton.state
        anchors.centerIn: parent
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: !parent.disable && parent.clicked && parent.clicked()
    }
}
