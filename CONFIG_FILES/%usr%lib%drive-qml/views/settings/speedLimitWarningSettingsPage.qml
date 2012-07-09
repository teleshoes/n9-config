import components 1.0
import models 1.0
import QtQuick 1.1
import "../../utils/Units.js" as Units
import "../../components/styles.js" as Styles

Page {
    id: page
    title: qsTrId("qtn_drive_speed_limit_alert_hdr")
    scrollableList: list

    property int limitValue: 0

    onBeforeHide: {
        //save new values
        var guidanceSettingsModel = modelFactory.getModel("GuidanceSettingsModel");
        var convert = 3.6 / (Units.usingImperial() ? Units.KILOMETERS_IN_MILE : 1)
        guidanceSettingsModel.setSpeedWarnerOptions(lowSpeedOffset.value / convert, highSpeedOffset.value / convert)
    }

    onHide: {
        var appSettingsModel = modelFactory.getModel("AppSettingsModel");
        appSettingsModel.unitsSystemChanged.disconnect(unitSystemChanged);
    }

    function unitSystemChanged(system) {
        var guidanceSettingsModel = modelFactory.getModel("GuidanceSettingsModel");
        var appSettingsModel = modelFactory.getModel("AppSettingsModel");
        var usingMetric = system === appSettingsModel.units_metric;
        var convert = 3.6;
        if (usingMetric) {
            lowSpeedOffset.maxValue = Units.SPEED_LIMIT_OFFSET_MAX_METRIC;
            highSpeedOffset.maxValue = Units.SPEED_LIMIT_OFFSET_MAX_METRIC;
            limitValue = Units.SPEED_LIMIT_METRIC;
        } else {
            lowSpeedOffset.maxValue = Units.SPEED_LIMIT_OFFSET_MAX_IMPERIAL;
            highSpeedOffset.maxValue = Units.SPEED_LIMIT_OFFSET_MAX_IMPERIAL;
            convert = convert / Units.KILOMETERS_IN_MILE;
            limitValue = Math.round (Units.SPEED_LIMIT_METRIC / Units.KILOMETERS_IN_MILE);
        }
        var offsets = getOffsetFromModel(guidanceSettingsModel, convert);
        var unit = Units.getCurrentSpeedUnit();
        lowSpeedOffset.setValue(offsets.low);
        highSpeedOffset.setValue(offsets.high);
        lowSpeedOffset.unit = unit;
        highSpeedOffset.unit = unit;
    }

    function getOffsetFromModel(model, ratio) {
        var low = Math.min(Math.round(model.lowSpeedOffset * ratio), lowSpeedOffset.maxValue);
        var high = Math.min(Math.round(model.highSpeedOffset * ratio), highSpeedOffset.maxValue);
        return { low: low, high: high };
    }

    onBeforeShow: {
        var guidanceSettingsModel = modelFactory.getModel("GuidanceSettingsModel");
        var appSettingsModel = modelFactory.getModel("AppSettingsModel");
        var convert = 3.6 / (Units.usingImperial() ? Units.KILOMETERS_IN_MILE : 1)
        limitValue = 80 / (Units.usingImperial() ? Units.KILOMETERS_IN_MILE : 1)
        var offsets = getOffsetFromModel(guidanceSettingsModel, convert);
        lowSpeedOffset.initialValue = offsets.low;
        highSpeedOffset.initialValue = offsets.high;

        appSettingsModel.unitsSystemChanged.connect(unitSystemChanged);

        guidanceSettingsModel.speedWarnerOnChanged.connect(function() {
            contentColumn.state = guidanceSettingsModel.speedWarnerOn === true ? "" : "disabled"
        });

        if (guidanceSettingsModel.speedWarnerOn === false)
            contentColumn.state = "hideWithoutTransition";
    }

    VisualItemModel {
        id: listModel
        Column {
            id: contentColumn
            anchors {
                left: parent.left
                right: parent.right
                leftMargin: Styles.SpeedWarnerSettingsPage.columnAnchors.leftMargin
                rightMargin: Styles.SpeedWarnerSettingsPage.columnAnchors.rightMargin
            }

            SpeedWarnerSwitch {
                anchors.left: parent.left
                anchors.right: parent.right
            }

            SpeedWarnerSettingLabel {
                id: label1
                font.pixelSize: Styles.SpeedWarnerSettingsPage.textFontSize1
                text: qsTrId("qtn_drive_speed_limit_alert_above").replace("§", limitValue + " " + Units.getCurrentSpeedUnit())
            }

            SpeedWarnerSettingLabel {
                id: label2
                color: Styles.SpeedWarnerSettingsPage.textColor2
                font.pixelSize: Styles.SpeedWarnerSettingsPage.textFontSize2
                text: qsTrId("qtn_drive_speed_limit_alert_warn_if")
            }

            SpeedWarnerSettingSlider { id: highSpeedOffset }

            SpeedWarnerSettingLabel {
                id: label3
                font.pixelSize: Styles.SpeedWarnerSettingsPage.textFontSize1
                text: qsTrId("qtn_drive_speed_limit_alert_under").replace("§", limitValue + " " + Units.getCurrentSpeedUnit())
            }

            SpeedWarnerSettingLabel {
                id: label4
                color: label2.color
                font.pixelSize: label2.font.pixelSize
                text: label2.text
            }

            SpeedWarnerSettingSlider { id: lowSpeedOffset }

            transitions: [
                Transition {
                    //from: ""
                    to: "disabled"
                    SequentialAnimation {
                        PropertyAction {
                            targets: [label1, label2, label3, label4, lowSpeedOffset, highSpeedOffset];
                            property: "enabled"; value: false
                        }
                        NumberAnimation {
                            targets: [label1, label2, label3, label4, lowSpeedOffset, highSpeedOffset];
                            property: "opacity"; to: 0; duration: 500
                        }
                        PropertyAction {
                            targets: [label1, label2, label3, label4, lowSpeedOffset, highSpeedOffset];
                            property: "visible"; value: false
                        }
                        ScriptAction { script: list.updateScrollButtons() }
                    }
                },

                Transition {
                    //from: "disabled"
                    to: ""
                    SequentialAnimation {
                        PropertyAction {
                            targets: [label1, label2, label3, label4, lowSpeedOffset, highSpeedOffset];
                            properties: "visible,enabled"; value: true
                        }
                        NumberAnimation {
                            targets: [label1, label2, label3, label4, lowSpeedOffset, highSpeedOffset];
                            property: "opacity"; to: 1; duration: 500
                        }
                        ScriptAction { script: list.updateScrollButtons() }
                    }
                },
                Transition {
                    to: "hideWithoutTransition"
                    PropertyAction {
                        targets: [label1, label2, label3, label4, lowSpeedOffset, highSpeedOffset];
                        properties: "opacity,visible,enabled"; value: false
                    }
                    ScriptAction { script: list.updateScrollButtons() }
                }
            ]
        }
    }

    List {
        id: list
        anchors.top: titleBottom
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        contentHeight: contentColumn.height //adding bottomMargin manully, since braking default bindings for List
        height: parent.height - titleBox.height
        listItemHeight: contentHeight / (contentColumn.children.length)
        listModel: listModel
    }
}
