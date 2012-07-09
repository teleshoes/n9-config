//TODO: move this to settings folder

import QtQuick 1.1
import components 1.0
import models 1.0
import "../components/components.js" as Components
import "../models/ModelFactory.js" as ModelFactory

Page {
    id: page
    title: qsTrId("qtn_drive_navigation_options_hdr")
    scrollableList: list

    property variant stopGuidanceDialog

    // TODO: Uncomment when management makes up their minds
    //property string trafficTxt: modelFactory.getModel("AppSettingsModel").trafficOn ? qsTrId("qtn_drive_trafficoff_item") : qsTrId("qtn_drive_trafficon_item")
    //property string trafficIcon: modelFactory.getModel("AppSettingsModel").trafficOn ? "traffic_off.png" : "traffic_on.png"

    VisualItemModel {
        id: listModel

        MapPerspectiveSwitch {
            id: perspectiveSwitch
            onItemSelected: window.pop()
        }

        ButtonItem {
            id: stopnavigation
            itemId: "stopnavigation"
            title: qsTrId("qtn_drive_stop_btn_short")
            iconUrl: Components.imagePath + "listitems/stop_navigation.png"
            hideArrow: true
        }

        ButtonItem {
            id: saveMyLocation
            itemId: "saveMyLocation"
            title: qsTrId("qtn_drive_savemylocation_item")
            iconUrl: Components.imagePath + "listitems/favorites.png"
            hideArrow: true
        }

        // TODO: Uncomment when management makes up their minds
        /**
        ButtonItem {
            id: toggletraffic
            itemId: "toggletraffic"
            title: trafficTxt
            iconUrl: Components.imagePath + "traffic/list_item/"+trafficIcon
            hideArrow: true
        }
        */

        ButtonItem {
            id: settings
            itemId: "settings"
            title: qsTrId("qtn_drive_settings_item")
            iconUrl: Components.imagePath + "listitems/settings.png"
        }

        ButtonItem {
            id: about
            itemId: "about"
            title: qsTrId("qtn_drive_about_item")
            iconUrl: Components.imagePath + "listitems/about.png"
        }
    }

    List {
        id: list
        listModel: listModel
        anchors.top: titleBottom
        anchors.left: page.left
        anchors.bottom: page.bottom
        anchors.right: page.right

        onItemClicked: {
            var nextPageName;
            switch (itemId) {
                case "settings":
                    nextPageName = "settings/settingsPage.qml";
                    break;
                case "about":
                    nextPageName = "aboutPage.qml";
                    break;
                case "stopnavigation":
                    stopGuidance();
                    break;
                case "toggletraffic":
                    toggleTraffic();
                    break;
                case "saveMyLocation":
                    window.pop();
                    var favoritesModel = ModelFactory.getModel("FavoritesModel");
                    favoritesModel.saveMyLocation();
                    return;
            }

            nextPageName && window.push(nextPageName, {
                invokingPage: "guidancePage"
            });
        }
    }

    onBeforeHide: {
        if (stopGuidanceDialog) {
            stopGuidanceDialog.destroy();
        }
    }

    function stopGuidance() {
        stopGuidanceDialog = window.showDialog("", {
            text: qsTrId("qtn_drive_stop_navigation?_dlg"),
            affirmativeMessage: qsTrId("qtn_drive_yes_btn_short"),
            cancelMessage: qsTrId("qtn_drive_no_btn_short")
        });

        stopGuidanceDialog.userReplied.connect((function(mf) { return function(answer) {
            var popTo;
            if (answer == "ok") {
                var guidanceModel = mf.getModel("GuidanceModel"),
                    appModel = mf.getModel("AppModel"),
                    routingModel = mf.getModel("RoutingModel");

                guidanceModel.stopGuidance();
                routingModel.clearRoute();
                appModel.restartAssistance = true;
                popTo = "landingPage";
            }

            stopGuidanceDialog = null;
            window.pop(popTo, { tag: "guidancePage" });
        }}(modelFactory)));
    }

    function toggleTraffic() {
        var appSettingsModel = modelFactory.getModel("AppSettingsModel");
        var trafficModel = modelFactory.getModel("TrafficModel");
        if (appSettingsModel.trafficOn) {
            appSettingsModel.setTrafficOn(false);
            trafficModel.requestTraffic();

        }
        else if (appSettingsModel.connectionAllowed && appSettingsModel.mapSensorEnabled) {
            if (!device.online) {
                device.openNetworkConnection();
            }

            if (appSettingsModel.mapSensorEnabled) {
                appSettingsModel.setTrafficOn(true);
                trafficModel.requestTraffic();
            }
            else {
                enableMapSensor();
            }
        }
        else {
            goOnlineForTraffic();
        }
        return;
    }

    function goOnlineForTraffic() {
        var dialog = window.showDialog("", {
            text: qsTrId("qtn_drive_go_online_to_get_traffic_dlg"),
            affirmativeMessage: qsTrId("qtn_drive_yes_btn_short"),
            cancelMessage: qsTrId("qtn_drive_no_btn_short")
        });

        dialog.userReplied.connect(function(answer) {
            var appSettingsModel = modelFactory.getModel("AppSettingsModel");
            var trafficModel = modelFactory.getModel("TrafficModel");
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
                        var appSettingsModel = modelFactory.getModel("AppSettingsModel");
                        var trafficModel = modelFactory.getModel("TrafficModel");
                        if (answer == "ok") {
                            appSettingsModel.setMapSensorEnabled(true);
                            appSettingsModel.setTrafficOn(true);
                            trafficModel.requestTraffic();
                        }
                        else {
                            appSettingsModel.setConnectionAllowed(false);
                        }
                    });
                }
                else {
                    appSettingsModel.setTrafficOn(true);
                    trafficModel.requestTraffic();
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
            var appSettingsModel = modelFactory.getModel("AppSettingsModel");
            var trafficModel = modelFactory.getModel("TrafficModel");
            if (answer == "ok") {
                appSettingsModel.setMapSensorEnabled(true);
                appSettingsModel.setTrafficOn(true);
                trafficModel.requestTraffic();
            }
        });
    }
}
