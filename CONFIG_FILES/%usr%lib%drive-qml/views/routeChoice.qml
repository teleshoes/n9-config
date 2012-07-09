import QtQuick 1.1
import MapsPlugin 1.0
import components 1.0
import "../components/components.js" as Components

Page {
    id: page

    MiniMap {
        id: minimap
        width: parent.width
        height: parent.height / 2
    }

    Text {
        id: title
        anchors.top: parent.top // minimap.bottom
        anchors.left: parent.left
        anchors.margins: 10
        text: "Select alternative route"
        font.family: Components.Common.font.family
        font.pixelSize: 16
        color: "white"
    }

    ToggleSwitch {
        id: toggleSwitch
        anchors.top: title.bottom
        anchors.left: page.left
        anchors.right: page.right
        anchors.margins: 20

        isLandscape: page.isLandscape

        buttonModel: ListModel {
            ListElement {
                type: "type1"
                label: "route 1"
                preSelected: true
            }
            ListElement {
                type: "type2"
                label: "route 2"
                preSelected: false
            }
            ListElement {
                type: "type3"
                label: "route 3"
                preSelected: false
            }
        }

        onClick: console.log("you clicked button type: " + choice);
    }
}
