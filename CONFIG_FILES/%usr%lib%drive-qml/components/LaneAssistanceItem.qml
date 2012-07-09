import QtQuick 1.1
import "styles.js" as Style

Item {
    id: laneAssistanceItem

    property variant style: Style.LaneAssistanceBar

    property bool isOnRoute: false
    property int direction: 0
    property bool isDots: true

    height: parent.height
    width: style.item.width
    anchors.verticalCenter: parent.verticalCenter

    Image {
        property string theme: laneAssistanceItem.isOnRoute ? "light" : "dark"
        property string fileName: laneAssistanceItem.isDots ? style.icon.item.dots : laneAssistanceItem.direction

        anchors.centerIn: parent
        opacity: 1
        z: 1
        source: style.icon.uri + theme + "/" + fileName + style.icon.item.ext
    }

    Rectangle {
        anchors.fill: parent
        clip: true
        color: style.background.color
        visible: laneAssistanceItem.isOnRoute && !laneAssistanceItem.isDots
    }
}
