import QtQuick 1.1
import "styles.js" as Styles

Item {
    id: infoBanner
    height: value.height
    property variant myStyle: Styles.InfoBanner

    property alias distance: value.text
    property alias distanceUnit: unit.text
    property alias duration: value2.text
    property alias durationUnit: unit2.text

    Row {
        anchors.fill: parent

        Text {
            id: value
            color: myStyle.value.color
            font.pixelSize: myStyle.value.font.pixelSize
            font.family: myStyle.value.font.family
            anchors.bottom: parent.bottom
        }
        Text {
            id: unit
            color: value.color
            font.pixelSize: myStyle.unit.font.pixelSize
            font.family: myStyle.unit.font.family
            anchors.baseline: value.baseline
        }
        Text {
            id: spliter
            color: value.color
            font.pixelSize: value.font.pixelSize - 8 // shorten
            font.family: unit.font.family
            anchors.verticalCenter: parent.verticalCenter
            text: " | "
        }
        Text {
            id: value2
            color: value.color
            font.pixelSize: value.font.pixelSize
            font.family: value.font.family
            anchors.baseline: value.baseline
        }
        Text {
            id: unit2
            color: unit.color
            font.pixelSize: unit.font.pixelSize
            font.family: unit.font.family
            anchors.baseline: value.baseline
        }
    }
}
