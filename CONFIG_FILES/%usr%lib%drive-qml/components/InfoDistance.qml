import QtQuick 1.1
import "styles.js" as Style

Item {
    id: distance
    property bool isLandscape
    property string value
    property string unit
    property variant infoDistanceStyle: Style.InfoDistance

    states: [
        State {
            name: "landscape"
            when: distance.isLandscape
            // container
            AnchorChanges {
                target: container
                anchors.left: distance.left
                anchors.verticalCenter: distance.verticalCenter
            }
            PropertyChanges {
                target: container
                anchors.leftMargin: infoDistanceStyle.leftMarginLandscape
                anchors.rightMargin: infoDistanceStyle.rightMarginLandscape
            }
            // value
            AnchorChanges {
                target: valueItem
                anchors.left: container.left
            }
            // unit
            AnchorChanges {
                target: unitItem
                anchors.left: container.left
            }
        },
        State {
            name: "portrait"
            when: !distance.isLandscape
            // container
            PropertyChanges {
                target: container
                anchors.centerIn: distance
            }
            // unit
            AnchorChanges {
                target: unitItem
                anchors.top: valueItem.bottom
                anchors.horizontalCenter: valueItem.horizontalCenter
            }
        }
    ]

    // value/unit pair
    Grid {
        id: container
        columns: 1
        rows: 2
        // value
        Text {
            id: valueItem
            font.family: infoDistanceStyle.valueItemFamily
            text: distance.value
            font.pixelSize: infoDistanceStyle.valueItemSize[isLandscape ? "landscape" : "portrait"]
            color: infoDistanceStyle.valueItemColor
        }
        // unit
        Text {
            id: unitItem
            font.family: infoDistanceStyle.unitItemFamily
            style: Text.Raised
            text: distance.unit
            font.pixelSize: infoDistanceStyle.unitItemSize
            color: infoDistanceStyle.unitItemColor
        }
    }
}
