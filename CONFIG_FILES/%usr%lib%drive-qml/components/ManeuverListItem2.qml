import QtQuick 1.1
import "components.js" as Components

Item {
    id: maneuverListItem
    property bool isLandscape
    property Item externalContainer
    property bool showIcon

    property int _iconIndex
    property string _title
    property string _info1
    property string _info2

    states: [
        State {
            name: "landscape"
            when: maneuverListItem.isLandscape
            // icon
                // container
            // => START: RE-PARENTED VERSION - required for removal of portrait state below
            ParentChange {
                target: maneuverIconContainer
                parent: maneuverListItem
            }
            // <= FINISH: RE-PARENTED VERSION

            // => COMMON
            AnchorChanges {
                target: maneuverIconContainer
                anchors.top: maneuver.top
                anchors.horizontalCenter: maneuver.horizontalCenter
            }
            PropertyChanges {
                target: maneuverIconContainer
                anchors.topMargin: Components.ManeuverListItem.icon.landscape.margins.top
                width: Components.ManeuverListItem.icon.landscape.width
                height: Components.ManeuverListItem.icon.landscape.height
            }
                // image
            PropertyChanges {
                target: maneuverIcon
                source: Components.imagePath + Components.ManeuverListItem.icon.landscape.uri
                x: -maneuverIconContainer.width * ((maneuverListItem._iconIndex - 1) % Components.ManeuverListItem.icon.landscape.source.columns)
                y: -maneuverIconContainer.height * Math.floor((maneuverListItem._iconIndex - 1) / Components.ManeuverListItem.icon.landscape.source.columns)
                sourceSize.width: Components.ManeuverListItem.icon.landscape.source.size.width
                sourceSize.height: Components.ManeuverListItem.icon.landscape.source.size.height
            }
            // details
            AnchorChanges {
                target: details
                anchors.bottom: maneuver.bottom
                anchors.right: maneuver.right
                anchors.left: maneuver.left
            }
            PropertyChanges {
                target: details
                anchors.rightMargin: Components.ManeuverListItem.details.landscape.margin.right
                anchors.bottomMargin: Components.ManeuverListItem.details.landscape.margin.bottom
                anchors.leftMargin: Components.ManeuverListItem.details.landscape.margin.left
            }
                // text
                    // title
            PropertyChanges {
                target: title
                font.pixelSize: Components.ManeuverListItem.details.landscape.h1.size
            }
                    // info1
            PropertyChanges {
                target: info1
                font.pixelSize: Components.ManeuverListItem.details.landscape.h3.size
            }
                    // info2
            PropertyChanges {
                target: info2
                font.pixelSize: Components.ManeuverListItem.details.landscape.h3.size
            }
        },
        State {
            name: "portrait"
            when: !maneuverListItem.isLandscape
            // icon
                // container
            // => RE-PARENTED VERSION
            ParentChange {
                target: maneuverIconContainer
                parent: maneuverListItem.externalContainer
            }
            PropertyChanges {
                target: maneuverIconContainer
                anchors.centerIn: parent
                width: Components.ManeuverListItem.icon.portrait.width
                height: Components.ManeuverListItem.icon.portrait.height
                visible: maneuverListItem.showIcon
            }
            // => START: INLINE VERSION
            /*
            AnchorChanges {
                target: maneuverIconContainer
                anchors.bottom: maneuverListItem.top
                anchors.horizontalCenter: maneuverListItem.horizontalCenter
            }
            PropertyChanges {
                target: maneuverIconContainer
                anchors.bottomMargin: Components.ManeuverListItem.icon.portrait.margins.bottom
                width: Components.ManeuverListItem.icon.portrait.width
                height: Components.ManeuverListItem.icon.portrait.height
            }
            */
            // <= FINISH: INLINE VERSION
                // image
            PropertyChanges {
                target: maneuverIcon
                source: Components.imagePath + Components.ManeuverListItem.icon.portrait.uri
                x: -maneuverIconContainer.width * ((maneuverListItem._iconIndex - 1) % Components.ManeuverListItem.icon.portrait.source.columns)
                y: -maneuverIconContainer.height * Math.floor((maneuverListItem._iconIndex - 1) / Components.ManeuverListItem.icon.portrait.source.columns)
                sourceSize.width: Components.ManeuverListItem.icon.portrait.source.size.width
                sourceSize.height: Components.ManeuverListItem.icon.portrait.source.size.height
            }

            // details
            AnchorChanges {
                target: details
                anchors.top: maneuver.top
                anchors.right: maneuver.right
                anchors.left: maneuver.left
            }
            PropertyChanges {
                target: details
                anchors.topMargin: Components.ManeuverListItem.details.portrait.margin.top
                anchors.rightMargin: Components.ManeuverListItem.details.portrait.margin.right
                anchors.leftMargin: Components.ManeuverListItem.details.portrait.margin.left
            }
                // text
                    // title
            PropertyChanges {
                target: title
                font.pixelSize: Components.ManeuverListItem.details.portrait.h1.size
            }
                    // info1
            PropertyChanges {
                target: info1
                font.pixelSize: Components.ManeuverListItem.details.portrait.h3.size
            }
                    // info2
            PropertyChanges {
                target: info2
                font.pixelSize: Components.ManeuverListItem.details.portrait.h3.size
            }
        }
    ]

    // MANEUVER
    Rectangle {
        id: maneuver

        anchors.top: parent.top
        anchors.topMargin: Components.ManeuverListItem.margins.top
        anchors.right: parent.right
        anchors.rightMargin: Components.ManeuverListItem.margins.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Components.ManeuverListItem.margins.bottom
        anchors.left: parent.left
        anchors.leftMargin: Components.ManeuverListItem.margins.left

        color: Components.ManeuverListItem.color
        radius: Components.ManeuverListItem.radius
        border.width: Components.ManeuverListItem.border.width
        border.color: Components.ManeuverListItem.border.color

        // DETAILS
        Column {
            id: details
            spacing: Components.ManeuverListItem.details.spacing

            Text {
                id: title
                font.family: Components.Common.font.family
                font.weight: eval(Components.ManeuverListItem.details.h1.weight)
                font.capitalization: eval(Components.ManeuverListItem.details.h1.capitalization)
                color: Components.ManeuverListItem.details.h1.color
                text: maneuverListItem._title
            }

            Text {
                id: info1
                font.family: Components.Common.font.family
                font.weight: eval(Components.ManeuverListItem.details.h3.weight)
                font.capitalization: eval(Components.ManeuverListItem.details.h3.capitalization)
                color: Components.ManeuverListItem.details.h3.color
                text: maneuverListItem._info1
            }

            Text {
                id: info2
                font.family: Components.Common.font.family
                font.weight: eval(Components.ManeuverListItem.details.h3.weight)
                font.capitalization: eval(Components.ManeuverListItem.details.h3.capitalization)
                color: Components.ManeuverListItem.details.h3.color
                text: maneuverListItem._info2
            }
        }
    }

    // ICON
    Item {
        id: maneuverIconContainer
        clip: true

        Image {
            id: maneuverIcon
        }
    }
}
