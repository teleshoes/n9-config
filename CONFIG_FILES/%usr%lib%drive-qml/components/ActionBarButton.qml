import QtQuick 1.1
import "styles.js" as Style

Rectangle {
    id: actionBarButton
    property alias type: functionButton.type
    property bool disable: false

    property bool isLandscape
    property bool active: false
    property bool isFirst: false
    property bool isLast: false
    property variant actionBarButtonStyle: Style.ActionBarButton
    signal clicked

    states: [
        State {
            name: "normal"
            when: !(actionBarButton.disable || mouseArea.pressed)
            // action button
            PropertyChanges {
                target: actionBarButton
                color: actionBarButtonStyle.color.normal
            }
        },
        State {
            name: "down"
            when: !actionBarButton.disable && mouseArea.pressed
            // action button
            PropertyChanges {
                target: actionBarButton
                color: actionBarButtonStyle.color.down
            }
        },
        State {
            name: "disabled"
            when: actionBarButton.disable
            // action button
            PropertyChanges {
                target: actionBarButton
                color: actionBarButtonStyle.color.disabled
            }
        }
    ]

    Item {
        id: borders

        clip: true
        anchors.fill: actionBarButton

        states: [
            State {
                name: "landscape"
                when: actionBarButton.isLandscape
                // shadow
                AnchorChanges {
                    target: borderShadow
                    anchors.left: parent.left
                    anchors.top: parent.top
                }
                PropertyChanges {
                    target: borderShadow
                    source: actionBarButtonStyle.borderShadowSource.landscape
                    fillMode: Image.TileHorizontally
                }
                // highlight
                AnchorChanges {
                    target: borderHighlight
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                }
                PropertyChanges {
                    target: borderHighlight
                    source: actionBarButtonStyle.borderHeighlightSource.landscape
                    fillMode: Image.TileHorizontally
                }
            },
            State {
                name: "portrait"
                when: !actionBarButton.isLandscape
                // shadow
                AnchorChanges {
                    target: borderShadow
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                }
                PropertyChanges {
                    target: borderShadow
                    source: actionBarButtonStyle.borderShadowSource.portrait
                    fillMode: Image.TileVertically
                }
                // highlight
                AnchorChanges {
                    target: borderHighlight
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                }
                PropertyChanges {
                    target: borderHighlight
                    source: actionBarButtonStyle.borderHeighlightSource.portrait
                    fillMode: Image.TileVertically
                }
            }
        ]

        Image {
            id: borderShadow
            visible: !actionBarButton.isFirst
        }

        Image {
            id: borderHighlight
            visible: !actionBarButton.isLast
        }
    }

    FunctionButton {
        id: functionButton
        disable: actionBarButton.disable
        // propagate the state down to the child button
        state: actionBarButton.state
        anchors.horizontalCenter: actionBarButton.horizontalCenter
        anchors.verticalCenter: actionBarButton.verticalCenter
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: !parent.disable && parent.clicked && parent.clicked()
    }
}
