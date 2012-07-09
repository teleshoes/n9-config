import QtQuick 1.1
import "styles.js" as Style

Item {
    id: laneAssistanceSeparator

    property variant style: Style.LaneAssistanceBar

    height: parent.height
    width: style.separator.width
    anchors.verticalCenter: parent.verticalCenter

    Image {
        opacity: 1
        anchors.fill: parent
        source: style.icon.uri + style.icon.separator.uri
    }
}
