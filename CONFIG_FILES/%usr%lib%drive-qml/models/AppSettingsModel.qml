import QtQuick 1.1
import "../utils/Units.js" as Units
import "ModelFactory.js" as ModelFactory
import MapsPlugin 1.0

QtObject {
    id: appSettingsModel

    property string _baseKey: "GeneralSettings/"
    property variant _setting: ModelFactory.settingsManager // alias
    // a container to save all keys with their default values.
    property variant _keys: {
        allowConnections: true,
        appVersion: "",
        gpsPowersaving: true,
        home: undefined,
        lastSyncDate: undefined,
        mapSensor: false,
        npsDone: false,
        routeOptions: 63,
        serviceAgreedOn: "",
        ssoDone: false,
        traffic: false, //true,  // TODO: change back when management makes up their mind
        trafficUpdateInterval: 5,
        unitSystem: ""
    }
    property variant routeOptionTitles: [
        qsTrId("qtn_drive_route_settings_motorways_item"),
        qsTrId("qtn_drive_route_settings_tollroads_item"),
        qsTrId("qtn_drive_route_settings_ferries_item"),
        qsTrId("qtn_drive_route_settings_tunnels_item"),
        qsTrId("qtn_drive_route_settings_unpavedroads_item"),
        qsTrId("qtn_drive_route_settings_motorailtrains_item")
    ]

    property variant guidanceSettingsModel
    //constants
    property string units_metric: Units.SYSTEM_METRIC
    property string units_impUK: Units.SYSTEM_IMPERIAL_UK
    property string units_impUS: Units.SYSTEM_IMPERIAL_US

    //used in minimap
    property int app_mapZoomIntervalDefault: 100
    property real app_zoomDelta: 7 / 8
    property int app_transitionDuration: 300
    property int app_showTransitionDuration: 300

    // Caution: Do not use these Properties.
    // The usage of these properties should be avoid.
    // The values of these properties do not updated seamlessly.
    property bool connectionAllowed
    property bool gpsPowersaving
    property bool trafficOn
    property bool mapSensorEnabled
    property int trafficUpdateInterval
    property string currentUnitSystem

    // Getters and Setters below are kept here
    // to remain Backward compatibility.
    // However these are not recommended to be used in new-added code anymore.
    // Should be replaced by get() and set() with key string as parameter instead
    // Example1: appSettingsModel.get('traffic')
    //        2: appSettingsModel.set('traffic', true)
    //        3: appSettingsModel.set('traffic')  // set with default value.
    function isConnectionAllowed() { return get('allowConnections'); }
    function isGpsPowersaving() { return get('gpsPowersaving'); }
    function isTrafficOn() { return get('traffic'); }
    function isMapSensorEnabled() { return get('mapSensor'); }
    function getTrafficUpdateInterval() { return get('trafficUpdateInterval'); }

    function setGpsPowersaving(v) { set('gpsPowersaving', v); _updateProps(); }
    function setTrafficOn(v) { set('traffic', v); _updateProps(); }
    function setMapSensorEnabled(v) { set('mapSensor', v); if (!v) { set('traffic', false); } _updateProps(); }
    function setTrafficUpdateInterval(v) { set('trafficUpdateInterval', v); _updateProps(); }

    //signals
    signal unitsSystemChanged(string newUnitsSystem)
    signal routeOptionsChanged()

    function getUnitSystem() {
        var unit = get('unitSystem');
        if (!unit) {
            switch (systemRegion.toUpperCase()) {
            case "GB":
                unit = units_impUK;
                break;
            case "US":
                unit = guidanceSettingsModel.voiceSkinSupportsImpUS(guidanceSettingsModel.voiceSkinId) ? units_impUS
                                                                                                       : units_impUK;
                break;
            default: //Use metric as default if no value has been set.
                unit = units_metric;
                break;
            }

            setUnitSystem(unit);
        }
        return unit;
    }
    function setUnitSystem(newUnitSystem) {
        set('unitSystem', newUnitSystem);
        Units.currentSystem = newUnitSystem;
        _updateProps();
        unitsSystemChanged(newUnitSystem);
    }
    function setConnectionAllowed(allow) {
        set('allowConnections', allow);
        if (!allow) {
            set('traffic', false);
        }
        MapsPlugin.online = allow;
        _updateProps();
    }
    function lastSyncDate() {
        return get('lastSyncDate');
    }

    function setLastSyncDate(date) {
        set('lastSyncDate', date);
    }

    function getHome() {
        return get('home') ? JSON.parse(get('home'))
                           : undefined;
    }
    function setHome(home) {
        if (home) {
            set('home', JSON.stringify(home));
        } else {
            set('home');
        }
    }

    // A method to be used to set a value to a key in QSettings.
    // the pre-defined default value will be given if without 2nd arg.
    // This method is encouraged to be used across the app
    function set(key, value) {
        if (key in _keys) {
            if (typeof value == 'undefined') value = _keys[key];
            _setting.setValue(_baseKey + key, value);
        } else { // useful for debugging.
            console.log("No such a key to set in AppSettingsModel:", key);
        }
    }
    // A method to be used to get value with a key in QSettings.
    // Default values will be returned when QSettings is not ready, or the value stored is undefined.
    // This method is encouraged to be used across the app
    function get(key) {
        if (key in _keys) {
            if (!_setting) return _keys[key]; // prevent QSettings un-initilized.
            var value = _setting.value(_baseKey + key);
            if (typeof value == 'undefined') return _keys[key]; // prevent non-sense value
            if (value == "true" || value == "false") value = eval(value); // useful for Backward compatibility
            return value;
        } else { // useful for debugging.
            console.log("No such a key to get in AppSettingsModel:", key);
        }
    }

    // A shortcut to ensure props working, should be removed when props usage are eliminated.
    function _updateProps() {
        connectionAllowed = get('allowConnections');
        gpsPowersaving = get('gpsPowersaving');

        // TODO: change back when management makes up their minds
        trafficOn = false; //get('traffic');

        mapSensorEnabled = get('mapSensor');
        trafficUpdateInterval = get('trafficUpdateInterval');
        currentUnitSystem = getUnitSystem();
    }

    //TODO: do not apply app settings stuff here. Let each component load its settings when they start up
    //for the units bit is tricky. So, keep this method here until we have a better idea
    function applyAppSettings() {
        _updateProps();
        MapsPlugin.online = get('allowConnections');
        Units.currentSystem = getUnitSystem();

        // TODO: change back when management makes up their minds
        trafficOn = false; //get('allowConnections') && get('mapSensor') && get('traffic') && device.online;
    }

    Component.onCompleted: {
        guidanceSettingsModel = ModelFactory.getModel("GuidanceSettingsModel");
        _updateProps();
    }
}
