import QtQuick 1.1
import components 1.0
import "../../components/components.js" as Components
import "../../utils/Units.js" as UnitsUtilities
import models 1.0
import MapsPlugin 1.0
import "../../models/ModelFactory.js" as ModelFactory


Page {
    id: page
    title: qsTrId("qtn_drive_settings_hdr")
    tag: "settingsPage"
    scrollableList: list

    property variant appModel
    property variant recentsModel
    property variant voiceSkinModel
    property variant appSettingsModel
    property variant mapSettingsModel
    property variant searchHistoryModel
    property variant guidanceSettingsModel

    VisualItemModel {
        id: listModel

        ButtonItem {
            id: mapMode
            itemId: "map_mode"
            title: qsTrId("qtn_drive_day_night_item")
            subtitle: mapSettingsModel ? qsTrId("qtn_drive_" + mapSettingsModel.dayNightMode + "_subitem") : ""
            iconUrl: mapSettingsModel ? ("../../resources/listitems/" + (mapSettingsModel.dayNightMode + "mode.png")) : ""
        }

        ButtonItem  {
            id: maplayers
            itemId: "maplayers"
            title: qsTrId("qtn_drive_map_layers_hdr")
            subtitle: [qsTrId("qtn_drive_landmarks_item"),
                       qsTrId("qtn_drive_favourites_item"),
                       qsTrId("qtn_drive_places_item")].join(', ')
            iconUrl:  "../../resources/listitems/map_layer.png"
        }

        ButtonItem {
            id: speedwarners
            itemId: "speedwarners"
            title: qsTrId("qtn_drive_speed_limit_alert_item")
            iconUrl:  "../../resources/listitems/speed_alerts.png"
        }

        ButtonItem {
            id: routesettings
            itemId: "routesettings"
            title: qsTrId("qtn_drive_route_settings_item")
            iconUrl:  "../../resources/routeOptions/highways.png"
        }

        ButtonItem {
            id: navigationVoice
            itemId: "navigation_voice"
            title: qsTrId("qtn_drive_navigation_voice_item")
        }

        ButtonItem {
            id: units
            itemId: "units"
            title: qsTrId("qtn_drive_units_item")
            subtitle: ""
        }

        
        ButtonItem {
            id: traffic
            itemId: "traffic"
            title: qsTrId("qtn_drive_traffic_settings_item")
            subtitle: trafficSettingsSubtitle();
            iconUrl: "../../resources/traffic/list_item/traffic_on.png"
        }
        

        ButtonItem {
            id: home
            itemId: "home"
            title: qsTrId("qtn_drive_home_location_item")
            iconUrl:  "../../resources/listitems/home.png"
        }

        ButtonItem {
            id: favorites
            itemId: "favorites"
            title: qsTrId("qtn_drive_favourites_item")
            subtitle: qsTrId("qtn_drive_favourites_synch_rename_delete_subitem")
            iconUrl:  "../../resources/listitems/favorites.png"
        }

        ButtonItem  {
            id: connection
            itemId: "connection"
            title: qsTrId("qtn_drive_connection_item")
            subtitle: (appSettingsModel && appSettingsModel.connectionAllowed) ? qsTrId("qtn_drive_online_subitem") : qsTrId("qtn_drive_offline_subitem");
            iconUrl: "../../resources/listitems/" +
                            (appSettingsModel && appSettingsModel.connectionAllowed ? "conn_online.png" : "conn_offline.png")
            checkable: true
            style: Components.CheckBox
            onClicked: appSettingsModel.setConnectionAllowed(checked);
        }

        ButtonItem  {
            id: gpsPowersave
            itemId: "gpsPowersave"
            title: qsTrId("qtn_drive_GPS_power_saving_item")
            iconUrl: "../../resources/listitems/powersave.png"
        }

        ButtonItem {
            id: clearhistory
            itemId: "clearhistory"
            title: qsTrId("qtn_drive_clear_history_hdr")
            subtitle: qsTrId("qtn_drive_clear_history_search_lastdestinations_subitem")
            iconUrl: "../../resources/listitems/clear.png"
        }
    }

    List {
        id: list
        listModel: listModel
        anchors.top: titleBottom
        width: parent.width
        height: parent.height - titleBox.height

        onItemClicked: {
            var targetPage,
                invokingPage = page.tag;

            switch (itemId) {
                case "map_mode":
                    targetPage = "settings/mapModeSettingsPage.qml";
                    invokingPage = params.invokingPage;
                    break;
                case "maplayers":
                    targetPage = "settings/mapLayersSettingsPage.qml";
                    invokingPage = params.invokingPage;
                    break;
                case "speedwarners":
                    targetPage = "settings/speedLimitWarningSettingsPage.qml";
                    break;
                case "routesettings":
                    targetPage = "settings/routeSettingsPage.qml";
                    // next page should rerurn back to SettingsPage.
                    break;
                case "navigation_voice":
                    targetPage = "settings/navigationVoiceSettingsPage.qml";
                    invokingPage = params.invokingPage;
                    break;
                case "units":
                    targetPage = "settings/unitsSettingsPage.qml";
                    invokingPage = params.invokingPage;
                    break;
                case "traffic":
                    targetPage = "settings/trafficSettingsPage.qml";
                    invokingPage = params.invokingPage;
                    break;
                case "favorites":
                    targetPage = "settings/favoritesSettingsPage.qml";
                    invokingPage = params.invokingPage;
                    break;
                case "home":
                    appModel.setHomeFlow("setting");
                    targetPage = appSettingsModel.getHome() ? "redefineHomePage.qml"
                                                            : "locationPicker.qml";
                    invokingPage = params.invokingPage;
                    break;
                case "gpsPowersave":
                    targetPage = "settings/gpsSleepSettingsPage.qml";
                    invokingPage = params.invokingPage;
                    break;
                case "clearhistory":
                    targetPage = "settings/clearHistorySettingsPage.qml";
                    invokingPage = params.invokingPage;
                    break;
                default:
                    break;
            }

            targetPage && window.push(targetPage, {
                invokingPage: invokingPage
            });
        }
    }

    onBeforeShow: {
        loadCurrentVoiceSkin();
        loadCurrentUnits();

        gpsPowersave.subtitle = appSettingsModel.get('gpsPowersaving') ? qsTrId("qtn_drive_GPS_power_saving_on_subitem")
                                                                       : qsTrId("qtn_drive_GPS_power_saving_off_subitem");

        updateSpeedWarnerSubtitle();
        connection.buttonChecked = appSettingsModel.connectionAllowed;
        updateHomeSubtitle();
        updateRouteOptionButton();
        updateClearHistoryButton();
    }

    function onNavigateButtonClicked() {
        window.pop(params.invokingPage);
    }

    function loadCurrentVoiceSkin() {
        var voiceSkin = voiceSkinModel.getLocalVoiceSkin(Number(guidanceSettingsModel.getVoiceSkinId()));
        if (voiceSkin) {
            var isFemale = voiceSkinModel.isFemale(voiceSkin);
            navigationVoice.subtitle = voiceSkin.language === "Own Voice" ? "" : voiceSkin.language;
            navigationVoice.iconUrl = ["../../resources/listitems/voice_",
                                       (isFemale === true ? "female" :
                                        isFemale === false ? "male" : "none"), ".png"].join("");
        } else {
            guidanceSettingsModel.setVoiceSkinId(guidanceSettingsModel.voice_skin_none);
            navigationVoice.iconUrl = "../../resources/listitems/voice_none.png";
            navigationVoice.subtitle = qsTrId("qtn_drive_voice_none");
        }
    }

    function loadCurrentUnits() {
        switch (appSettingsModel.getUnitSystem()) {
            case appSettingsModel.units_metric:
                units.iconUrl = "../../resources/listitems/units_metric.png";
                units.subtitle = qsTrId("qtn_drive_units_metric_subitem");
                break;
            case appSettingsModel.units_impUK:
                units.iconUrl = "../../resources/listitems/units_UK.png";
                units.subtitle = qsTrId("qtn_drive_units_imperial_uk_subitem");
                break;
            case appSettingsModel.units_impUS:
                units.iconUrl = "../../resources/listitems/units_US.png";
                units.subtitle = qsTrId("qtn_drive_units_imperial_us_subitem");
                break;
            default:
                units.iconUrl = "";
                units.subtitle = "";
                break;
        }
    }

    function trafficSettingsSubtitle() {
        var mapSensor = appSettingsModel && appSettingsModel.mapSensorEnabled;
        var trafficOn = appSettingsModel && appSettingsModel.trafficOn;
        var subtitle = qsTrId("qtn_drive_traffic_disabled_subitem");

        if(mapSensor && trafficOn) {
            subtitle = qsTrId("qtn_drive_traffic_on_subitem");
        }
        else if(mapSensor && !trafficOn) {
            subtitle = qsTrId("qtn_drive_traffic_off_subitem");
        }

        return subtitle;
    }

    function updateSpeedWarnerSubtitle() {
        if (guidanceSettingsModel.speedWarnerOn !== true) {
            speedwarners.subtitle = qsTrId("qtn_drive_speed_limit_alert_off_subitem");
            return;
        }

        var low = UnitsUtilities.getReadableSpeed(guidanceSettingsModel.lowSpeedOffset);
        var high = UnitsUtilities.getReadableSpeed(guidanceSettingsModel.highSpeedOffset);
        var speedLimitOffsetMax = appSettingsModel.getUnitSystem() == appSettingsModel.units_metric ? UnitsUtilities.SPEED_LIMIT_OFFSET_MAX_METRIC
                                                                                                    : UnitsUtilities.SPEED_LIMIT_OFFSET_MAX_IMPERIAL;
        var low_value = isNaN(low.value) ? 0 : Math.min(low.value, speedLimitOffsetMax);
        var high_value = isNaN(high.value) ? 0 : Math.min(high.value, speedLimitOffsetMax);

        speedwarners.subtitle = [
            //guidanceSettingsModel.speedWarnerAudioOn ? qsTrId("qtn_drive_speed_limit_alert_on_subitem") : "!!Only visuals",
            qsTrId("qtn_drive_speed_limit_alert_on_subitem"),
            high_value + " " + high.unit,
            low_value + " " + low.unit
        ].join(", ");
    }

    function updateHomeSubtitle() {
        var homeLoc = appSettingsModel && appSettingsModel.getHome();
        var line = qsTrId("qtn_drive_set_home_location_subitem");

        function pushValid(list, str) {
            if (str) list.push(str);
        }

        if(homeLoc) {
            var address = [];
            pushValid(address, homeLoc.address1);
            pushValid(address, homeLoc.detailAddress2);
            pushValid(address, homeLoc.detailAddress3);
            line = address.join(', ');
        }
        home.subtitle = line;
    }

    function updateRouteOptionButton() {
        var options = appSettingsModel.get('routeOptions');
        var titles = appSettingsModel.routeOptionTitles;
        var subtitles = [];
        for (var i = 0, j = titles.length; i < j; ++i) {
            if (options & (1 << (5 - i))) subtitles.push(titles[i]);
        }
        routesettings.subtitle = subtitles.join(', ');
    }

    function updateClearHistoryButton() {
        clearhistory.isActive = !(searchHistoryModel.isEmpty() && recentsModel.isEmpty());
    }

    Component.onCompleted: {
        appModel = ModelFactory.getModel("AppModel");
        recentsModel = ModelFactory.getModel("RecentsModel");
        voiceSkinModel = ModelFactory.getModel("VoiceSkinModel");
        appSettingsModel = ModelFactory.getModel("AppSettingsModel");
        mapSettingsModel = ModelFactory.getModel("MapSettingsModel");
        searchHistoryModel = ModelFactory.getModel("SearchHistoryModel");
        guidanceSettingsModel = ModelFactory.getModel("GuidanceSettingsModel");


        guidanceSettingsModel.voiceSkinIdChanged.connect(loadCurrentVoiceSkin);
        voiceSkinModel.translationsLoaded.connect(loadCurrentVoiceSkin);
    }

    Component.onDestruction: {
        guidanceSettingsModel.voiceSkinIdChanged.disconnect(loadCurrentVoiceSkin);
        voiceSkinModel.translationsLoaded.disconnect(loadCurrentVoiceSkin);
    }
}
