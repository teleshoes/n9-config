import QtQuick 1.1
import MapsPlugin 1.0
import components 1.0
import models 1.0
import "../utils/Units.js" as Units

Page {
    id: page
    scrollableList: list

    property variant trafficModel
    property variant positioningModel
    property variant trafficViewHelper

    property variant distanceText
    property variant lengthText
    property variant speedText
    //property variant delayText

    property string color: "green" // current traffic flow color (green, orange, red)

    VisualItemModel {
        id: listModel

        TrafficEventHeader {
            id: eventHeader
            color: page.color
            leftButtonDisabled: trafficModel.selectedEventIndex === 0
            rightButtonDisabled: trafficModel.selectedEventIndex === trafficModel.trafficEvents.length-1
        }

        ButtonItem {
            id: distance
            itemId: "distance"
            isActive: false
            hasIcon: false
            hideArrow: true
            title: "Distance to"
            subtitle: distanceText.value + ' ' + distanceText.unit
        }

        ButtonItem {
            id: length
            itemId: "length"
            isActive: false
            hasIcon: false
            hideArrow: true
            title: "Length"
            subtitle: lengthText.value + ' ' + lengthText.unit
        }

        ButtonItem {
            id: speed
            itemId: "speed"
            isActive: false
            hasIcon: false
            hideArrow: true
            title: "Average speed"
            subtitle:  speedText.value + ' ' + speedText.unit
        }

        /* This info is not available from plugin
        ButtonItem {
            id: delay
            itemId: "delay"
            isActive: false
            hasIcon: false
            hideArrow: true
            title: "Estimated delay"
            subtitle: delayText
        }
        */

        ButtonItem {
            id: start
            itemId: "start"
            isActive: false
            hasIcon: false
            hideArrow: true
            title: "Starts at"
            subtitle: trafficModel === undefined ? "-" : trafficModel.selectedTrafficEvent.firstAffectedStreet
        }

        /* This info is not available from plugin
        ButtonItem {
            id: end
            itemId: "end"
            isActive: false
            hasIcon: false
            hideArrow: true
            title: "Ends at"
            subtitle: "-"
        }
        */

        ButtonItem {
            id: cause
            itemId: "cause"
            isActive: false
            hasIcon: false
            hideArrow: true
            subtitleWrapMode: Text.WordWrap
            subtitleElide: Text.ElideNone
            title: "Caused by"
            subtitle: trafficModel === undefined ? "Unknown" : trafficModel.selectedTrafficEvent.eventText
        }

        Rectangle {
            id: button
            width: parent ? parent.width : 100
            height: 130
            color: "black"

            Button {
                id: offButton
                anchors.centerIn: parent
                text: "Turn off traffic"
                onClicked: {
                    trafficModel.turnOffTraffic();
                    window.pop();
                }
            }
        }
    }

    List {
        id: list
        listModel: listModel
        anchors.top: titleBottom
        anchors.left: page.left
        anchors.bottom: page.bottom
        anchors.right: page.right
        //onItemClicked:

    }

    function onLeftButtonClicked() {
        trafficModel.loadPreviousTrafficEvent();
        updateTrafficInfo();
    }

    function onRightButtonClicked() {
        trafficModel.loadNextTrafficEvent();
        updateTrafficInfo();
    }

    function updateTrafficInfo() {
        distanceText = trafficViewHelper.getDistanceToTrafficEvent(trafficModel.selectedTrafficEvent);
        lengthText = Units.getReadableDistanceVisual(trafficModel.selectedTrafficEvent.affectedLength);
        speedText = Units.getReadableSpeed(trafficModel.selectedTrafficEvent.speedLimit);
        //delayText = '-'; // not available from plugin
    }

    Connections {
        target: eventHeader
        onLeftButtonClicked: onLeftButtonClicked()
        onRightButtonClicked: onRightButtonClicked()
    }

    Component.onCompleted: {
        positioningModel = modelFactory.getModel("PositioningModel");
        trafficModel = modelFactory.getModel("TrafficModel");
        trafficViewHelper = modelFactory.getModel("TrafficViewHelper");

        updateTrafficInfo();
    }
}
