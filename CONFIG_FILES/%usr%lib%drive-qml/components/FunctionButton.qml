import QtQuick 1.1
import "styles.js" as Style

Item {
    id: functionButton

    property string type: "empty"
    property bool disable: false
    property variant functionButtonStyle: Style.FunctionButton
    signal clicked

    width: functionButtonStyle.width
    height: functionButtonStyle.height
    clip: true

    states: [
        State {
            name: "normal"
            when: !(functionButton.disable || mouseArea.pressed)
            // button icon
            PropertyChanges {
                target: buttonIcon
                x: functionButtonStyle[functionButton.type].iconX.normal
                y: functionButtonStyle[functionButton.type].iconY.normal
            }
        },
        State {
            name: "down"
            when: !functionButton.disable && mouseArea.pressed
            // button icon
            PropertyChanges {
                target: buttonIcon
                x: functionButtonStyle[functionButton.type].iconX.down ? functionButtonStyle[functionButton.type].iconX.down : x
                y: functionButtonStyle[functionButton.type].iconY.down ? functionButtonStyle[functionButton.type].iconY.down : y
            }
        },
        State {
            name: "disabled"
            when: functionButton.disable
            // button icon
            PropertyChanges {
                target: buttonIcon
                x: functionButtonStyle[functionButton.type].iconX.disabled
                y: functionButtonStyle[functionButton.type].iconY.disabled
            }
        }
    ]

    Image {
        id: buttonIcon
        source: functionButtonStyle.iconSource
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: !parent.disable && parent.clicked && parent.clicked()
    }
}
