import QtQuick 1.1
import "components.js" as Components
import models 1.0
import "../utils/Units.js" as Units
import MapsPlugin 1.0
import "styles.js" as Styles
import "../models/ModelFactory.js" as ModelFactory

// A transparent Rectangle is necessary to have gradient property.
// gradient property can not be set to undefined, thus have to set in states.
Rectangle {
    id: speed
    color: "transparent"

    property variant myStyle: Styles.InfoSpeed  // alias
    property bool limitExceeded: false
    property bool isLandscape
    property string value
    property string unit
    property string defaultLimit: "-"

    property variant guidanceModel
    property variant positioningModel
    property variant guidanceSettingsModel

    property int limitCap: 70 // meter/second, about 252 KM/H
    property bool overLimitCap: !!(positioningModel &&
                                   positioningModel.roadElement &&
                                   positioningModel.roadElement.speedLimit > limitCap)
    property bool showWarnerIcon: limitValue() != defaultLimit //&& !onHighway()
    property variant gradientSet: Gradient {
                                      GradientStop { position: 0.0; color: myStyle.gradient.from }
                                      GradientStop { position: 1.0; color: myStyle.gradient.to }
                                  }

/*
/** It is better to keep this code snippet for further reference
/*
    function onHighway() {
        if (!overLimitCap) { return false; }
        var re = positioningModel.roadElement;
        var forbiddenAttributes = RoadElement.ATTR_URBAN |
                                  RoadElement.ATTR_SLIPROAD |
                                  RoadElement.ATTR_TUNNEL |
                                  RoadElement.ATTR_RAIL_FERRY |
                                  RoadElement.ATTR_FERRY;
        var maskedCurrentAttributes = re.attributes & forbiddenAttributes;
        var formOfWayMotorWay = re.formOfWay == RoadElement.FOW_MOTORWAY;
        return (maskedCurrentAttributes === 0 && formOfWayMotorWay);
    }
*/

    function limitValue() {
        if (!positioningModel || !positioningModel.roadElement || overLimitCap) {
            return defaultLimit;
        }
        var sl = positioningModel.roadElement.speedLimit;
        return Units.getReadableSpeedLimit(sl, systemLocale).value;
    }

    states: [
        State {
            name: "landscape_hide"
            when: isLandscape && !showWarnerIcon
            PropertyChanges { target: textArea; state: "landscape_left" }
            PropertyChanges { target: speedWarnerIcon; state: "hide" }
        },
        State {
            name: "landscape_show"
            when: isLandscape && showWarnerIcon && !limitExceeded
            PropertyChanges { target: textArea; state: "landscape_left" }
            PropertyChanges { target: speedWarnerIcon; state: "limit" }
        },
        State {
            name: "landscape_show_overspeed"; extend: "landscape_show"
            when: isLandscape && showWarnerIcon && limitExceeded
            // Setting gradient property to override color settings
            PropertyChanges { target: speed; gradient: gradientSet }
        },
        State {
            name: "portrait_hide"
            when: !isLandscape && !showWarnerIcon
            PropertyChanges { target: textArea; state: "portrait_center" }
            PropertyChanges { target: speedWarnerIcon; state: "hide" }
        },
        State {
            name: "portrait_show"
            when: !isLandscape && showWarnerIcon && !limitExceeded
            PropertyChanges { target: textArea; state: "portrait_left" }
            PropertyChanges { target: speedWarnerIcon; state: "limit" }
        },
        State {
            name: "portrait_show_overspeed"; extend: "portrait_show"
            when: !isLandscape && showWarnerIcon && limitExceeded
            // Setting gradient property to override color settings
            PropertyChanges { target: speed; gradient: gradientSet }
        }
    ]

    // value/unit pair
    Column {
        id: textArea

        Text {
            id: valueItem
            font.family: Components.Common.font.family
            text: speed.value
        }
        Text {
            id: unitItem
            font.family: Components.Common.font.family
            style: Text.Raised
            text: speed.unit
        }

        states: [
            State {
                name: "landscape_left"
                AnchorChanges {
                    target: textArea
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                }
                PropertyChanges {
                    target: textArea
                    anchors.leftMargin: Components.AssistanceItem.landscape.margin.left
                    anchors.rightMargin: Components.AssistanceItem.landscape.margin.right
                }
                AnchorChanges { target: valueItem; anchors.left: parent.left }
                AnchorChanges { target: unitItem;  anchors.left: parent.left }
                PropertyChanges {
                    target: valueItem
                    font.pixelSize: Components.AssistanceItem.landscape.value.font.size
                    color: Components.AssistanceItem.landscape.value.font.color
                }
                PropertyChanges {
                    target: unitItem
                    font.pixelSize: Components.AssistanceItem.landscape.unit.font.size
                    color: Components.AssistanceItem.landscape.unit.font.color
                }
            },
            State {
                name: "portrait_base"
                AnchorChanges { target: valueItem; anchors.horizontalCenter: parent.horizontalCenter }
                AnchorChanges { target: unitItem;  anchors.horizontalCenter: parent.horizontalCenter }
                PropertyChanges {
                    target: valueItem
                    font.pixelSize: Components.AssistanceItem.portrait.value.font.size
                    color: Components.AssistanceItem.portrait.value.font.color
                }
                PropertyChanges {
                    target: unitItem
                    font.pixelSize: Components.AssistanceItem.portrait.unit.font.size
                    color: Components.AssistanceItem.portrait.unit.font.color
                }
            },
            State {
                name: "portrait_center"; extend: "portrait_base"
                PropertyChanges { target: textArea; anchors.centerIn: parent }
            },
            State {
                name: "portrait_left"; extend: "portrait_base"
                AnchorChanges { target: textArea
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.horizontalCenter
                }
                PropertyChanges { target: valueItem; anchors.horizontalCenterOffset: -8 }
                PropertyChanges { target: unitItem; anchors.horizontalCenterOffset: -8 }
            }
        ]
    }

    // warner icon when speed limit value is meaningful.
    Image {
        id: speedWarnerIcon
        source: myStyle.speedWarnerSource
        anchors.left: parent.horizontalCenter
        anchors.leftMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -2
        width: myStyle.speedWarnerWidth
        height: myStyle.speedWarnerHeight
        visible: false

        Text {
            id: speedLimitText
            font.family: myStyle.speedWarnerFamily
            color: myStyle.speedWarnerColor
            font.pixelSize: myStyle.speedWarnerSize
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: +(text.length <= 2)  // 1 for 2 digits, and no_offset for 3 digits
            anchors.verticalCenterOffset: 1
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: speed.limitValue()
        }

        states: [
            State {
                name: "hide"
                PropertyChanges { target: speedWarnerIcon; visible: false }
                PropertyChanges { target: speedLimitText; visible: false }
            },
            State {
                name: "limit"
                PropertyChanges {
                    target: speedWarnerIcon
                    source: myStyle.speedWarnerSource
                    visible: true
                }
                PropertyChanges { target: speedLimitText; visible: true }
            }
        ]
    }

    Component.onCompleted: {
        guidanceModel = ModelFactory.getModel("GuidanceModel");
        positioningModel = ModelFactory.getModel("PositioningModel");
        guidanceSettingsModel = ModelFactory.getModel("GuidanceSettingsModel");
        
        guidanceModel.speedExceeded.connect(onSpeedExceeded);
        guidanceModel.speedExceededEnd.connect(speedExceededEnd);

        guidanceSettingsModel.speedWarnedChanged.connect(function(enabled) {
            console.log("Speed warned setting changed: " + enabled);

            if(enabled) {
                guidanceModel.speedExceeded.connect(onSpeedExceeded);
                guidanceModel.speedExceededEnd.connect(speedExceededEnd);
            }
            else {
                guidanceModel.speedExceeded.disconnect(onSpeedExceeded);
                guidanceModel.speedExceededEnd.disconnect(speedExceededEnd);

                speedExceededEnd();
            }
        });
    }

    function onSpeedExceeded() {
        limitExceeded = guidanceSettingsModel.speedWarnerOn;
    }

    function speedExceededEnd() {
        limitExceeded = false;
    }
}
