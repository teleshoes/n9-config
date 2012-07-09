import QtQuick 1.1
import "styles.js" as Style


Item {
    id: button

    property string type: "plain"
    property real buttonWidth // target width (used if greater than minimum required)
    property real buttonHeight // target height (used if greater than minimum required)
    property string buttonIcon // a custom icon (not recommended)
    property alias text: buttonText.text
    property variant buttonStyle: Style.Button
    property url normalBackground: buttonStyle.backgroundImageSource.hover
    property alias color: buttonText.color
    property alias font: buttonText.font
    signal clicked

    // ensure the dimensions of the button are at least big enough to fit its contents
    width: buttonWidth //&& buttonWidth > contents._width ? buttonWidth : contents._width
    height: buttonHeight && buttonHeight > contents._height ? buttonHeight : contents._height

    states: [
        State {
            name: "disabled"
            when: !enabled
            PropertyChanges {
                target: background
                source: buttonStyle.backgroundImageSource.disabled
            }
        },
        State {
            name: "down"
            // when: mouseArea.containsMouse && mouseArea.pressed
            PropertyChanges {
                target: background
                source: buttonStyle.backgroundImageSource.down
            }
        }
    ]

    // background
    BorderImage {
        id: background
        source: normalBackground
        anchors.fill: button
        border {
            left: buttonStyle.backgroundImageWidth
            top: buttonStyle.backgroundImageHeight
            right: buttonStyle.backgroundImageWidth
            bottom: buttonStyle.backgroundImageHeight
        }
        horizontalTileMode: BorderImage.Stretch
        verticalTileMode: BorderImage.Stretch
    }

    // contents
    Row {
        id: contents

        //property real _width: contents.width + buttonStyle.horzontalPadding * 2
        property real _height: contents.height + buttonStyle.verticalPadding * 2

        width: parent.width - buttonStyle.horzontalPadding * 2 //contents.childrenRect.width
        height: buttonStyle.height // contents.childrenRect.height
        spacing: buttonStyle.spacing
        anchors.centerIn: parent

        // icon
        Item {
            id: iconContainer
            width: buttonStyle.iconWidth
            height: width
            anchors.verticalCenter: parent.verticalCenter
            clip: true
            visible: button.type != "plain"

            Image {
                id: icon
                x: button.type ? buttonStyle[button.type].iconX : buttonStyle.iconX
                y: button.type ? buttonStyle[button.type].iconY : buttonStyle.iconY
                source: !button.buttonIcon ? buttonStyle.iconSource : "../resources/" + button.buttonIcon
            }
        }

        // text
        Text {
            id: buttonText

            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: iconContainer.visible ? Text.AlignLeft : Text.AlignHCenter
            width: parent.width - (iconContainer.visible ? buttonStyle.iconWidth : 0)

            style: Text.Raised
            color: buttonStyle.color
            font.family: buttonStyle.family
            font.weight: buttonStyle.weight
            font.pixelSize: buttonStyle.size
            font.capitalization: eval(buttonStyle.capitalization)
            elide: Text.ElideRight
        }
    }

    Timer {
        id: releaseTimer
        interval: 100
        repeat: false
        onTriggered: button.state = ""
    }

    // mouse area
    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        onClicked: button.clicked && button.clicked()
        onPressed: {
            button.state = "down"
        }
        onReleased: {
            releaseTimer.running = true
        }
        onExited: {
            button.state = ""
        }
    }
}
