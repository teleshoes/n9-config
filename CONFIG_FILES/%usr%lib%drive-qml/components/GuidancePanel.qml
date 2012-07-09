import QtQuick 1.1
import "styles.js" as Style


Item {
    id: guidance

    property bool isLandscape
    property bool isRerouting
    property int maneuverIconIndex
    property string maneuverName
    property string maneuverDistanceValue
    property string maneuverDistanceUnit
    property bool hasGPS: true
    property variant guidancePanelStyle: Style.GuidancePanel

    signal maneuverClicked()

    width: parent.width
    height: guidancePanelStyle.height[isLandscape ? "landscape" : "portrait"]

    states: [
        State {
            name: "landscape"
            when: guidance.isLandscape
            // street
            AnchorChanges {
                target: street
                anchors.verticalCenter: guidanceBase.verticalCenter
                anchors.horizontalCenter: guidanceBase.horizontalCenter
            }
            // distance
            AnchorChanges {
                target: distance
                anchors.horizontalCenter: maneuverBase.horizontalCenter
                anchors.bottom: maneuverBase.bottom
            }
            AnchorChanges {
                target: distanceUnit
                anchors.baseline: distanceValue.baseline
            }
        },
        State {
            name: "portrait"
            when: !guidance.isLandscape
            // street
            AnchorChanges {
                target: street
                anchors.top: guidanceBase.top
                anchors.left: guidanceBase.left
            }
            // distance
            AnchorChanges {
                target: distance
                anchors.left: maneuverBase.right
                anchors.bottom: guidanceBase.bottom
            }
            AnchorChanges {
                target: distanceUnit
                anchors.baseline: distanceValue.baseline
            }
        }
    ]
    // maneuver
    Rectangle {
        id: maneuverBase
        color: guidancePanelStyle.maneuverBaseColor[hasGPS ? "hasGPS" : "noGPS"]
        width: guidancePanelStyle.maneuverBaseWidth[isLandscape ? "landscape" : "portrait"]
        height: parent.height

        Item {
            id: maneuverIconContainer
            anchors.horizontalCenter: parent.horizontalCenter
            clip: true
            width: guidancePanelStyle.maneuverIconContainerWidth
            height: guidancePanelStyle.maneuverIconContainerHeight
            y: guidancePanelStyle.maneuverIconContainerY[isLandscape ? "landscape" : "portrait"]

            Image {
                id: maneuverIcon
                visible: !isRerouting
                source: guidancePanelStyle.maneuverIconFolder + guidance.maneuverIconIndex + ".png"
                opacity: hasGPS ? 1.0 : 0.6
            }
            Image {
                id: spinner
                visible: isRerouting
                anchors.centerIn: parent.center
                width: 72
                height: 72
                property int index: 1
                source: "../resources/spinner/spinner_0"+index+".png"
                opacity: hasGPS ? 1.0 : 0.6
                smooth: true
            }
            PropertyAnimation {
                id: spinnerAnimation
                target: spinner
                running: spinner.visible
                property: "index"
                from: 1
                to: 8
                duration: 1000
                loops: Animation.Infinite
            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: guidance.maneuverClicked();
        }
    }

    // guidance base
    Rectangle {
        id: guidanceBase
        color: guidancePanelStyle.guidanceBaseColor[hasGPS ? "hasGPS" : "noGPS"]
        height: isLandscape ? guidancePanelStyle.guidanceBaseHeighLandscape : guidance.height
        anchors.top: parent.top
        anchors.left: maneuverBase.right
        anchors.right: parent.right

        // street
        Text {
            id: street
            font.family: guidancePanelStyle.streetFamily
            anchors.top: parent.top
            anchors.topMargin: guidancePanelStyle.streetTopMargin[isLandscape ? "landscape" : "portrait"]
            text: guidance.maneuverName || ""
            elide: Text.ElideRight
            horizontalAlignment: isLandscape ? Text.AlignHCenter : Text.AlignLeft
            width: parent.width
            font.pixelSize: guidancePanelStyle.streetSize[isLandscape ? "landscape" : "portrait"]
            color: guidancePanelStyle.streetColor[hasGPS ? "hasGPS" : "noGPS"]
        }
        MouseArea {
            anchors.fill: parent
            onClicked: guidance.maneuverClicked();
        }
    }

    // distance
    Flow {
        id: distance
        visible: !isRerouting
        // distance value
        Text {
            id: distanceValue
            font.family: guidancePanelStyle.distanceValueFamily
            text: guidance.maneuverDistanceValue
            color: guidancePanelStyle.distanceValueColor[hasGPS ? "hasGPS" : "noGPS"]
            font.pixelSize: guidancePanelStyle.distanceValueSize[isLandscape ? "landscape" : "portrait"]
        }
        // distance unit
        Text {
            id: distanceUnit
            font.family: guidancePanelStyle.distanceUnitFamily
            text: guidance.maneuverDistanceUnit
            color: guidancePanelStyle.distanceUnitColor[hasGPS ? "hasGPS" : "noGPS"]
            font.pixelSize: guidancePanelStyle.distanceUnitSize[isLandscape ? "landscape" : "portrait"]
        }
    }
}
