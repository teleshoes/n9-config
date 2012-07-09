import QtQuick 1.1
import MapsPlugin 1.0
import components 1.0
import models 1.0
import "../../components/components.js" as Components
import "../../components/styles.js" as Style


Page {
    id: page
    title: qsTrId("qtn_drive_traffic_settings_hdr")
    scrollableList: list

    property variant appSettingsModel
    property variant trafficModel

    VisualItemModel {
        id: listModel

        ButtonItem {
            id: trafficService
            itemId: "trafficService"
            title: qsTrId("qtn_drive_traffic_service_item")
            subtitle: appSettingsModel.mapSensorEnabled ? qsTrId("qtn_drive_traffic_using_location_subitem") : qsTrId("qtn_drive_traffic_disabled_subitem")
            checkable: true
            style: Components.CheckBox
            hasIcon: false
            buttonChecked: appSettingsModel.mapSensorEnabled
            onClicked: {
                if (appSettingsModel.mapSensorEnabled) {
                    appSettingsModel.setMapSensorEnabled(false);
                    if (appSettingsModel.trafficOn) {
                        appSettingsModel.setTrafficOn(false);
                        trafficModel.requestTraffic();
                    }
                }
                else {
                    appSettingsModel.setMapSensorEnabled(true);
                }
            }
        }

        ButtonItem {
            id: trafficState
            itemId: "trafficState"
            title: appSettingsModel.trafficOn ? qsTrId("qtn_drive_trafficoff_item") : qsTrId("qtn_drive_trafficon_item")
            iconUrl: "../../resources/traffic/list_item/" + (appSettingsModel.trafficOn ? "traffic_off.png" : "traffic_on.png")
            checkable: false
            visible: appSettingsModel.mapSensorEnabled
            onClicked: onTrafficButtonClicked()
            hideArrow: true
        }

        ButtonItem {
            id: updateInterval
            itemId: "updateInterval"
            title: qsTrId("qtn_drive_traffic_update_interval_item")
            subtitle: appSettingsModel.trafficUpdateInterval + " " + qsTrId("qtn_drive_unit_minute")
            iconUrl: "../../resources/traffic/list_item/list_item_update_interval.png"
            checkable: false
            visible: appSettingsModel.mapSensorEnabled
            onClicked: window.push("settings/trafficIntervalSettingsPage.qml")
        }

        Item {
            id: textItem
            anchors.top: trafficService.bottom
            width: trafficService.width
            anchors.topMargin: 20
            Text {
                id: infoText
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                width: parent.width-40
                font.family: Style.RegularText.family
                font.pixelSize: Style.RegularText.size
                color: Style.RegularText.color
                wrapMode: Text.WordWrap
                text: qsTrId("qtn_drive_traffic_map_sensor_disabled1_dlg")
                visible: !appSettingsModel.mapSensorEnabled
            }

            Text {
                id: moreInfoText
                anchors.top: infoText.bottom
                anchors.left: parent.left
                anchors.topMargin: 20
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                width: parent.width-40
                font.family: Style.RegularText.family
                font.pixelSize: Style.RegularText.size
                color: Style.RegularText.color
                wrapMode: Text.WordWrap
                text: qsTrId("qtn_drive_traffic_more_info")
                visible: !appSettingsModel.mapSensorEnabled
            }

            Text {
                id: link
                anchors.top: moreInfoText.bottom
                anchors.left: parent.left
                anchors.topMargin: 20
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                width: parent.width-40
                font.family: Style.RegularText.family
                font.pixelSize: Style.RegularText.size
                wrapMode: Text.WordWrap
                color: "#57aaef"
                text: qsTrId("qtn_drive_terms_link")
                visible: !appSettingsModel.mapSensorEnabled

                MouseArea {
                    anchors.fill: parent
                    onClicked: !appSettingsModel.mapSensorEnabled && window.openUrl("http://www.nokia.com/privacy/m-201103/maps-privacy");
                }
            }
        }
    }

    List {
        id: list
        anchors.top: titleBottom
        anchors.left: page.left
        anchors.right: page.right
        anchors.bottom: page.bottom
        listModel: listModel
    }

    function onTrafficButtonClicked() {
        if (appSettingsModel.trafficOn) {
            appSettingsModel.setTrafficOn(false);
        }
        else if (appSettingsModel.connectionAllowed) {
            if (!device.online) {
                device.openNetworkConnection();
            }
            appSettingsModel.setTrafficOn(true);
            trafficModel.requestTraffic();
        }
        else {
            goOnlineForTraffic();
        }
    }

    function goOnlineForTraffic() {
        var dialog = window.showDialog("", {
            text: qsTrId("qtn_drive_go_online_to_get_traffic_dlg"),
            affirmativeMessage: qsTrId("qtn_drive_yes_btn_short"),
            cancelMessage: qsTrId("qtn_drive_no_btn_short")
        });

        dialog.userReplied.connect(function(answer) {
            if (answer == "ok") {
                if (!device.online) {
                    device.openNetworkConnection();
                }
                appSettingsModel.setConnectionAllowed(true);
                appSettingsModel.setTrafficOn(true);
                trafficModel.requestTraffic();
            }
        });
    }


    Component.onCompleted: {
        appSettingsModel = modelFactory.getModel("AppSettingsModel");
        trafficModel = modelFactory.getModel("TrafficModel");
    }
}
