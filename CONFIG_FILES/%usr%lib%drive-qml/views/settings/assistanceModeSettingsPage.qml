import QtQuick 1.1
import components 1.0
import models 1.0
import "../../components/components.js" as Components
import "../../models/ModelFactory.js" as ModelFactory

Page {
    id: page
    title: qsTrId("qtn_drive_navigation_options_hdr")
    scrollableList: list

    property variant appModel
    property variant trafficModel
    property variant favoritesModel
    property variant appSettingsModel

    property variant titles: {
        destination: qsTrId("qtn_drive_set_destination_item"),
        saveLocation: qsTrId("qtn_drive_savemylocation_item"),
        traffic_on: qsTrId("qtn_drive_trafficon_item"),
        traffic_off: qsTrId("qtn_drive_trafficoff_item"),
        settings: qsTrId("qtn_drive_settings_item"),
        about: qsTrId("qtn_drive_about_item"),
        feedback: qsTrId("qtn_drive_feedback_item")
    }
    property variant icons: {
        destination: "set_destination",
        saveLocation: "favorites",
        traffic_on: "traffic_on",
        traffic_off: "traffic_off",
        settings: "settings",
        about: "about",
        feedback: "feedback"
    }

    ListModel {
        id: buttonModel
        ListElement { _itemId: "destination"; _targetPage: "locationPicker.qml" }
        ListElement { _itemId: "saveLocation"; _hideArrow: true }
//        TODO: Uncomment when management makes up their minds
        ListElement { _itemId: "traffic_on"; _hideArrow: true }
        ListElement { _itemId: "settings"; _targetPage: "settings/settingsPage.qml" }
        ListElement { _itemId: "about"; _targetPage: "aboutPage.qml" }
        ListElement { _itemId: "feedback"; _targetPage: "npsPage.qml" }

        function indexById(str) {
            for(var i = 0, j = count; i < j; ++i) {
                if (get(i)._itemId == str) break;
            }
            return i < j ? i : -1;
        }

        function updateTraffic() {
            if (appSettingsModel.get('traffic'))
                get(2)._itemId = "traffic_off";
        }

        function updateFeedback() {
            var index = indexById('feedback');
            if (index != -1 && appSettingsModel.get('npsDone'))
                remove(index);
        }
    }

    function feedbackOnline() {
        var dialog = window.showDialog("", {
            text: qsTrId("qtn_drive_nps_goonline?_dlg"),
            affirmativeMessage: qsTrId("qtn_drive_yes_btn_short"),
            cancelMessage: qsTrId("qtn_drive_no_btn_short")
        });

        dialog.userReplied.connect(function(answer) {
            if (answer == "ok") {
                // sso will handle the network connnection of device if necessary
                //device.openNetworkConnection();
                appSettingsModel.setConnectionAllowed(true);
                window.push("npsPage.qml", { invokingPage: params.invokingPage });
            }
        });
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
                if (!appSettingsModel.mapSensorEnabled) {
                    var sensorDlg = window.showDialog("", {
                        text: qsTrId("qtn_drive_traffic_map_sensor_disabled1_dlg") + "\n\n" +
                              qsTrId("qtn_drive_traffic_map_sensor_disabled2_dlg"),
                        affirmativeMessage: qsTrId("qtn_drive_yes_btn_short"),
                        cancelMessage: qsTrId("qtn_drive_no_btn_short"),
                        fontSize: 26
                    });
                    sensorDlg.userReplied.connect(function(answer) {
                        if (answer == "ok") {
                            appSettingsModel.setMapSensorEnabled(true);
                            appSettingsModel.setTrafficOn(true);
                            trafficModel.requestTraffic();
                            listModel.updateTraffic();
                        }
                        else {
                            appSettingsModel.setConnectionAllowed(false);
                        }
                        window.pop();
                    });
                }
                else {
                    appSettingsModel.setTrafficOn(true);
                    trafficModel.requestTraffic();
                    listModel.updateTraffic();
                    window.pop();
                }
            }
        });
    }

    function enableMapSensor() {
        var dialog = window.showDialog("", {
            text: qsTrId("qtn_drive_traffic_map_sensor_disabled1_dlg") + "\n\n" +
                  qsTrId("qtn_drive_traffic_map_sensor_disabled2_dlg"),
            affirmativeMessage: qsTrId("qtn_drive_yes_btn_short"),
            cancelMessage: qsTrId("qtn_drive_no_btn_short"),
            fontSize: 26
        });

        dialog.userReplied.connect(function(answer) {
            if (answer == "ok") {
                appSettingsModel.setMapSensorEnabled(true);
                appSettingsModel.setTrafficOn(true);
                trafficModel.requestTraffic();
                listModel.updateTraffic();
            }
            window.pop();
        });
    }

    List {
        id: list
        anchors.top: titleBottom
        anchors.left: page.left
        anchors.bottom: page.bottom
        anchors.right: page.right

        listModel: buttonModel
        header: MapPerspectiveSwitch {
            onItemSelected: window.pop()
        }
        delegate: ButtonItem {
            itemId: _itemId
            title: titles[_itemId]
            iconUrl: "../../resources/listitems/{*}.png".replace('{*}', icons[_itemId])
            hideArrow: !!_hideArrow
            targetPage: _targetPage || ""
        }
        onItemClicked: {
            if (itemId == "destination") {
                appModel.setHomeFlow();
            } else if (itemId == "feedback") {
                if (!appSettingsModel.get('allowConnections') || !device.online) {
                    feedbackOnline();
                    return; // prevent directly forward to npsPage, since itemArgs is not editable
                }
            } else if (itemId == "saveLocation") {
                favoritesModel.saveMyLocation();
                window.pop();
            } else if (itemId == "traffic_on" || itemId == "traffic_off") {
                if (appSettingsModel.trafficOn) {
                    appSettingsModel.setTrafficOn(false);
                    listModel.updateTraffic();
                    trafficModel.requestTraffic();
                    window.pop();
                } else if (appSettingsModel.connectionAllowed) {
                    if (!device.online) {
                        device.openNetworkConnection();
                    }

                    if (appSettingsModel.mapSensorEnabled) {
                        appSettingsModel.setTrafficOn(true);
                        listModel.updateTraffic();
                        trafficModel.requestTraffic();
                        window.pop();
                    }
                    else {
                        enableMapSensor();
                    }
                } else {
                    goOnlineForTraffic();
                }
            }

            if (itemArgs.targetPage) {
                window.push(itemArgs.targetPage, { invokingPage: params.invokingPage });
            }
        }
    }

    onBeforeShow: {
        buttonModel.updateFeedback();
    }

    Component.onCompleted: {
        appModel = ModelFactory.getModel("AppModel");
        trafficModel = ModelFactory.getModel("TrafficModel");
        favoritesModel = ModelFactory.getModel("FavoritesModel");
        appSettingsModel = ModelFactory.getModel("AppSettingsModel");
    }
}
