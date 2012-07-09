import QtQuick 1.1
import "styles.js" as Style

Item {
    id: toggleButton
    property bool isLandscape

    // optional: the optimum desired width of the button
    property real targetWidth
    // flag: first button (rounded graphic on the left)
    property bool isFirst: false
    // flag: last button (rounded graphic on the right)
    // NB: isFirst && isLast === true => rounded graphic on both sides
    property bool isLast: false
    // whether the initial state of this button should be 'selected'
    property bool isSelected: false
    // whether the button is initially disabled
    property bool isDisabled: false
    // the button text
    property alias text: buttonText.text
    //
    property alias iconSource: icon.source

    property variant toggleButtonStyle: Style.ToggleButton

    // click handler
    signal clicked

    width: {
        // Calculate the total horizontal margin specified for this component.
        // This is the required MINIMUM gap either side of the text within it.
        var marginWidth = toggleButton.isLandscape ?
                toggleButtonStyle.leftMargin.landscape + toggleButtonStyle.rightMargin.landscape :
                    toggleButtonStyle.leftMargin.portrait + toggleButtonStyle.rightMargin.portrait;

        // Specify the component width as the MINIMUM required width to display
        // the text without clipping, or the target width, which ever is greater.
        return (buttonText.paintedWidth + marginWidth > toggleButton.targetWidth ? buttonText.paintedWidth + marginWidth : toggleButton.targetWidth);
    }
    height: toggleButtonStyle.height[toggleButton.isLandscape ? "landscape" : "portrait"]

    // button states (normal, hover, selected(down), disabled)
    states: [
        State {
            name: "normal"
            when: !(toggleButton.isDisabled || toggleButton.isSelected) && !mouseArea.containsMouse
            PropertyChanges {
                target: borderImage
                source: toggleButtonStyle.backgroundSource.normal
            }
        },
        State {
            name: "hover"
            when: !(toggleButton.isDisabled || toggleButton.isSelected) && mouseArea.containsMouse && !mouseArea.pressed
            PropertyChanges {
                target: borderImage
                source: toggleButtonStyle.backgroundSource.hover
            }
        },
        State {
            name: "selected"
            when: !toggleButton.isDisabled && (toggleButton.isSelected || mouseArea.containsMouse && mouseArea.pressed)
            PropertyChanges {
                target: borderImage
                source: toggleButtonStyle.backgroundSource.down
            }
        },
        State {
            name: "disabled"
            when: toggleButton.isDisabled
            PropertyChanges {
                target: borderImage
                source: toggleButtonStyle.backgroundSource.disabled
            }
        }
    ]

    Item {
        id: borderImageContainer
        anchors.fill: parent
        clip: true

        // button types (only, first, middle, last)
        states: [
            State {
                name: "only"
                when: toggleButton.isFirst && toggleButton.isLast
                PropertyChanges {
                    target: borderImage
                    width: borderImageContainer.width
                }
                AnchorChanges {
                    target: borderImage
                    anchors.left: borderImageContainer.left
                }
            },
            State {
                name: "first"
                when: toggleButton.isFirst && !toggleButton.isLast
                PropertyChanges {
                    target: borderImage
                    width: borderImageContainer.width + toggleButtonStyle.backgroundWidth
                }
                AnchorChanges {
                    target: borderImage
                    anchors.left: borderImageContainer.left
                }
            },
            State {
                name: "last"
                when: toggleButton.isLast && !toggleButton.isFirst
                PropertyChanges {
                    target: borderImage
                    width: borderImageContainer.width + toggleButtonStyle.backgroundWidth
                }
                AnchorChanges {
                    target: borderImage
                    anchors.right: borderImageContainer.right
                }
            },
            State {
                name: "middle"
                when: !(toggleButton.isLast || toggleButton.isFirst)
                PropertyChanges {
                    target: borderImage
                    width: borderImageContainer.width + 2 * toggleButtonStyle.backgroundWidth
                }
                AnchorChanges {
                    target: borderImage
                    anchors.horizontalCenter: borderImageContainer.horizontalCenter
                }
            }
        ]

        BorderImage {
            id: borderImage
            height: parent.height
            border {
                left: toggleButtonStyle.leftBorder
                right: toggleButtonStyle.rightBorder
                top: toggleButtonStyle.topBorder
                bottom: toggleButtonStyle.bottomBorder
            }
            horizontalTileMode: BorderImage.Repeat
            verticalTileMode: BorderImage.Stretch
        }
    }

    Image {
        visible: source !== ""
        id: icon
        source: ""
        anchors.centerIn: parent
    }

    Text {
        visible: text !== ""
        id: buttonText
        anchors.centerIn: parent
        color: toggleButtonStyle.color
        font.family: toggleButtonStyle.family
        font.weight: toggleButtonStyle.weight
        font.pixelSize: toggleButtonStyle.size
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            if ( !toggleButton.isSelected ) {
                toggleButton.isSelected = true;
                toggleButton.clicked && toggleButton.clicked();
            }
        }
    }
}
