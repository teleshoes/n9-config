import QtQuick 1.1
import "styles.js" as Style

Rectangle {
    id: assistance
    color: Style.Dashboard.backgroundColor
    clip: true

    property bool isLandscape
    property string speedValue
    property string speedUnit
    property string distanceValue
    property string distanceUnit

    signal menuButtonClicked()

    /*
       NB: Notice that the order of the AssistanceItems changes depending on orientation (hence anchors
       instead of grid)
    */

    /* NB: Unfortunately, we can not easily resize AssistenceItems which contain dithered images so we need
       to work within a maximum height (landscape) or width (portrait), that being the physical dimension
       of the background image. If we want larger AssistanceItems, just create a new larger background image.
       The AssistanceItem height will also vary depending on the context in which the Dashboard is used, e.g.
       Assistance and Guidance.  So we'll use ratios for now rather than fixing the pixel heights and then
       sniffing the context.
    */

    states: [
        State {
            name: "landscape"
            when: assistance.isLandscape
            // assistance components
                // speed
            AnchorChanges {
                target: speed
                anchors.top: assistance.top
                anchors.left: assistance.left
            }
            PropertyChanges {
                target: speed
                width: assistance.width
                height: assistance.height * Style.InfoSpeed.heightRatioLandscape
            }
                // distance
            AnchorChanges {
                target: distance
                anchors.top: speed.bottom
                anchors.left: assistance.left
            }
            PropertyChanges {
                target: distance
                width: assistance.width
                height: assistance.height * Style.InfoDistance.heightRatioLandscape
            }
                // menu
            AnchorChanges {
                target: menu
                anchors.top: distance.bottom
                anchors.left: assistance.left
            }
            PropertyChanges {
                target: menu
                width: assistance.width
                // what ever vertical space is left over...
                height: assistance.height - speed.height - distance.height
            }
        },
        State {
            name: "portrait"
            when: !assistance.isLandscape
            // assistance components
                // distance
            AnchorChanges {
                target: distance
                anchors.top: assistance.top
                anchors.left: assistance.left
            }
            PropertyChanges {
                target: distance
                width: assistance.width * Style.InfoDistance.widthRatioPortrait
                height: assistance.height
            }
                // speed
            AnchorChanges {
                target: speed
                anchors.top: assistance.top
                anchors.left: distance.right
            }
            PropertyChanges {
                target: speed
                width: assistance.width * Style.InfoSpeed.widthRatio.portrait
                height: assistance.height
            }
                // menu
            AnchorChanges {
                target: menu
                anchors.top: assistance.top
                anchors.left: speed.right

            }
            PropertyChanges {
                target: menu
                // what ever horizontal space is left over...
                width: assistance.width - speed.width - distance.width
                height: assistance.height
            }
        }
    ]

    // assistance items
        // speed
    AssistanceItem {
        id: speed
        isLandscape: assistance.isLandscape

        InfoSpeed {
            id: speedInfo
            anchors.fill: speed
            isLandscape: assistance.isLandscape

            value: assistance.speedValue
            unit: assistance.speedUnit
        }
    }

        // distance
    AssistanceItem {
        id: distance
        isLandscape: assistance.isLandscape

        InfoDistance {
            id: distanceInfo
            anchors.fill: distance
            isLandscape: assistance.isLandscape
            value: assistance.distanceValue
            unit: assistance.distanceUnit
        }
    }

        // menu
    AssistanceItem {
        id: menu
        isLandscape: assistance.isLandscape
        isLast: true

        // Utilise WHOLE AssistanceItem as menu button
        onPressed: menuButton.state = "down"
        onReleased: menuButton.state = "normal"
        onClicked: assistance.menuButtonClicked()
        Rectangle {
            color: Style.Button.backgroundColorPressed
            visible: menuButton.state == "down"
            anchors.fill: parent
        }
        FunctionButton {

            id: menuButton
            anchors.centerIn: menu
            type: "menu"
            // !!! IMPORTANT !!!
            // click is 'consumed' before reaching AssistanceItem
            onClicked: assistance.menuButtonClicked()
        }
    }
}
