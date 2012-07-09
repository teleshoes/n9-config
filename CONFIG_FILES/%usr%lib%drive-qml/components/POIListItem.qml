import QtQuick 1.1
import "components.js" as Components

Item {
    id: resultListItem

    // 'public' properties
        // reference to the list data model
    property ListModel dataModel
        // index within the list from which this item should get its data
    property int targetIndex
        // orientation flag
    property bool isLandscape
        // distance text container
    property Item externalContainer
        // show external contents flag
    property bool showExternal

    width: parent.width
    height: parent.height

        // data properties
    property int iconIndex: dataModel.get(targetIndex).iconIndex
    property string title: dataModel.get(targetIndex).title
    property string address1: dataModel.get(targetIndex).address1
    property string address2: dataModel.get(targetIndex).address2
    property string distance: dataModel.get(targetIndex).distance

    states: [
        State {
            name: "landscape"
            when: resultListItem.isLandscape
            // icon
                // container
            AnchorChanges {
                target: iconContainer
                anchors.top: resultListItem.top
                anchors.left: resultListItem.left
            }
            PropertyChanges {
                target: iconContainer
                anchors.topMargin: Components.ResultListItem.icon.landscape.margins.top
                anchors.leftMargin: Components.ResultListItem.icon.landscape.margins.left
                width: Components.ResultListItem.icon.landscape.width
                height: Components.ResultListItem.icon.landscape.height
            }
                // image
            PropertyChanges {
                target: icon
                source: Components.imagePath + Components.ResultListItem.icon.landscape.uri
                x: -iconContainer.width * ((resultListItem.iconIndex - 1) % Components.ResultListItem.icon.landscape.source.columns)
                y: -iconContainer.height * Math.floor((resultListItem.iconIndex - 1) / Components.ResultListItem.icon.landscape.source.columns)
                sourceSize.width: Components.ResultListItem.icon.landscape.source.size.width
                sourceSize.height: Components.ResultListItem.icon.landscape.source.size.height
            }
            // details
            AnchorChanges {
                target: details
                anchors.top: resultListItem.top
                anchors.right: resultListItem.right
                anchors.left: iconContainer.right
            }
            PropertyChanges {
                target: details
                anchors.topMargin: Components.ResultListItem.details.landscape.margin.top
                anchors.rightMargin: Components.ResultListItem.details.landscape.margin.right
                anchors.leftMargin: Components.ResultListItem.details.landscape.margin.left
            }
                // text
                    // title
            PropertyChanges {
                target: title
                font.pixelSize: Components.ResultListItem.details.landscape.h1.size
            }
                    // address1
            PropertyChanges {
                target: address1
                font.pixelSize: Components.ResultListItem.details.landscape.h3.size
            }
                    // address2
            PropertyChanges {
                target: address2
                font.pixelSize: Components.ResultListItem.details.landscape.h3.size
            }
        },
        State {
            name: "portrait"
            when: !resultListItem.isLandscape
            // icon
                // container
            AnchorChanges {
                target: iconContainer
                anchors.top: resultListItem.top
                anchors.left: resultListItem.left
            }
            PropertyChanges {
                target: iconContainer
                anchors.topMargin: Components.ResultListItem.icon.portrait.margins.top
                anchors.leftMargin: Components.ResultListItem.icon.portrait.margins.left
                width: Components.ResultListItem.icon.portrait.width
                height: Components.ResultListItem.icon.portrait.height
            }
                // image
            PropertyChanges {
                target: icon
                source: Components.imagePath + Components.ResultListItem.icon.portrait.uri
                x: -iconContainer.width * ((resultListItem.iconIndex - 1) % Components.ResultListItem.icon.portrait.source.columns)
                y: -iconContainer.height * Math.floor((resultListItem.iconIndex - 1) / Components.ResultListItem.icon.portrait.source.columns)
                sourceSize.width: Components.ResultListItem.icon.portrait.source.size.width
                sourceSize.height: Components.ResultListItem.icon.portrait.source.size.height
            }
            // details
            AnchorChanges {
                target: details
                anchors.top: resultListItem.top
                anchors.right: resultListItem.right
                anchors.left: iconContainer.right
            }
            PropertyChanges {
                target: details
                anchors.topMargin: Components.ResultListItem.details.portrait.margin.top
                anchors.rightMargin: Components.ResultListItem.details.portrait.margin.right
                anchors.leftMargin: Components.ResultListItem.details.portrait.margin.left
            }
                // text
                    // title
            PropertyChanges {
                target: title
                font.pixelSize: Components.ResultListItem.details.portrait.h1.size
            }
                    // address1
            PropertyChanges {
                target: address1
                font.pixelSize: Components.ResultListItem.details.portrait.h3.size
            }
                    // address2
            PropertyChanges {
                target: address2
                font.pixelSize: Components.ResultListItem.details.portrait.h3.size
            }
        }
    ]

    // details
    Column {
        id: details
        spacing: Components.ResultListItem.details.spacing

        Text {
            id: title
            font.family: Components.Common.font.family
            font.weight: eval(Components.ResultListItem.details.h1.weight)
            font.capitalization: eval(Components.ResultListItem.details.h1.capitalization)
            color: Components.ResultListItem.details.h1.color
            text: resultListItem.title
        }

        Text {
            id: address1
            font.family: Components.Common.font.family
            font.weight: eval(Components.ResultListItem.details.h3.weight)
            font.capitalization: eval(Components.ResultListItem.details.h3.capitalization)
            color: Components.ResultListItem.details.h3.color
            text: resultListItem.address1
        }

        Text {
            id: address2
            font.family: Components.Common.font.family
            font.weight: eval(Components.ResultListItem.details.h3.weight)
            font.capitalization: eval(Components.ResultListItem.details.h3.capitalization)
            color: Components.ResultListItem.details.h3.color
            text: resultListItem.address2
        }
    }

    // distance text (appears in Navigation bar = the external container)
    Text {
        id: distanceLabel

        parent: resultListItem.externalContainer
        anchors.centerIn: parent
        visible: resultListItem.showExternal

        font.family: Components.Common.font.family
        font.weight: eval(Components.ResultListItem.distance.weight)
        font.pixelSize: Components.ResultListItem.distance.size
        font.capitalization: eval(Components.ResultListItem.distance.capitalization)
        color: Components.ResultListItem.distance.color
        text: resultListItem.distance
    }

    // icon
    Item {
        id: iconContainer
        clip: true

        Image {
            id: icon
        }
    }
}
