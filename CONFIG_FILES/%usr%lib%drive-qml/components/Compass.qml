import QtQuick 1.1
import "styles.js" as Style

Item {
    id: settingsButton
    property variant style: Style.MapControl
    property int angle: 0

    width: style.width
    height: style.height

    Image {
        id: bg
        anchors.centerIn: parent
        source: style.compass.background
        smooth: true
    }

    Image {
        id: needle
        source: style.compass.needle
        anchors.centerIn: parent
        smooth: true
        rotation: parent.angle
    }
}
