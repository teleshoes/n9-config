import QtQuick 1.1
import MapsPlugin 1.0
import "ModelFactory.js" as ModelFactory
import "mapSettings.js" as ModelHelper


QtObject {
    signal settingsChanged()

    //keys
    property string baseKey: "MapSettings/"
    property string mapSchemeKey: "MapScheme"
    property string landmarksVisibleKey: "LandmarksVisible"
    property string favoritesVisibleKey: "FavoritesVisible"
    property string perspectiveKey: "Perspective"
    property string poiCategoriesKey: "POIs"
    property string dayNightModeKey: "DayNightMode"

    //constants
    property string perspective_2d: "2D"
    property string perspective_3d: "3D"
    property string scheme_normal: "carnav.day.grey"
    property string scheme_night: "carnav.night.grey"
    property string scheme_satelite_day: "hybrid.day"
    property string scheme_satelite_night: "hybrid.night"

    //settings
    property string mapScheme: "carnav.day.grey"
    property bool landmarksVisible: true
    property bool favoritesVisible: true
    property string perspective: "3D"
    property bool nightMode: getSchemeProperties(mapScheme).nightMode
    property bool sateliteMode: getSchemeProperties(mapScheme).sateliteMode
    property string dayNightMode: ""

    Component.onCompleted: {
        loadMapSettings();
        //MapsPlugin.dayNightSwitch.connect(onDayNightSwitch);
    }

    //The settings party starts here
    function loadMapSettings() {
        mapScheme = ModelFactory.settingsManager.value(baseKey + mapSchemeKey) || mapScheme;
        landmarksVisible = ModelFactory.settingsManager.value(baseKey + landmarksVisibleKey) || landmarksVisible;
        favoritesVisible = ModelFactory.settingsManager.value(baseKey + favoritesVisibleKey) || favoritesVisible;
        perspective = ModelFactory.settingsManager.value(baseKey + perspectiveKey) || perspective;
        ModelHelper.deserialize(ModelFactory.settingsManager.value(baseKey + poiCategoriesKey));
        dayNightMode = ModelFactory.settingsManager.value(baseKey + dayNightModeKey) || "day";
    }

    function setMapScheme(newSchemeProperties) {
        var newScheme = getSchemeString(newSchemeProperties);
        mapScheme = newScheme;
        ModelFactory.settingsManager.setValue(baseKey + mapSchemeKey, newScheme);
        settingsChanged();
    }

    function setLandmarksVisible(newValue) {
        landmarksVisible = newValue;
        ModelFactory.settingsManager.setValue(baseKey + landmarksVisibleKey, newValue);
        settingsChanged();
    }

    function setFavoritesVisible(newValue) {
        favoritesVisible = newValue;
        ModelFactory.settingsManager.setValue(baseKey + favoritesVisibleKey, newValue);
        settingsChanged();
    }

    function setPerspective(newValue) {
        perspective = newValue;
        ModelFactory.settingsManager.setValue(baseKey + perspectiveKey, newValue);
        settingsChanged();
    }

    function setNightMode(value) {
        var schemeProperties = getSchemeProperties(mapScheme);
        schemeProperties.nightMode = value;
        setMapScheme(schemeProperties);
    }

    function setDayNightMode(newvalue) {
        ModelFactory.settingsManager.setValue(baseKey + dayNightModeKey, newvalue);
        dayNightMode = newvalue;
        //do plugin connecting here
        //possible values for newvalue string:"day", string:"night", string:"auto"
        /*
        if (newvalue === "auto") {
            setNightMode(isNight());
        }
        else*/ {
            setNightMode(newvalue === "night");
        }
    }

    function setSateliteMode(value) {
        var schemeProperties = getSchemeProperties(mapScheme);
        schemeProperties.sateliteMode = value;
        setMapScheme(schemeProperties);
    }

    function getSchemeProperties(schemeString) {
        return {
            sateliteMode: schemeString.indexOf("hybrid") != -1,
            nightMode: schemeString.indexOf("night") != -1
        };
    }

    function getSchemeString(schemeProperties) {
        return (schemeProperties.sateliteMode ? "hybrid" : "carnav") + "."
                + (schemeProperties.nightMode ? "night" : "day") +
                (schemeProperties.sateliteMode ? "" : ".grey");
    }

    function changePoiVisibility(itemId) {
        ModelHelper.changePoiVisibility(itemId);
        ModelFactory.settingsManager.setValue(baseKey + poiCategoriesKey, ModelHelper.serialize());
        settingsChanged();
    }

    function getPoiCategories() {
        return ModelHelper.getSortedPoiCategories();
    }

    function serializePois() {
        return ModelHelper.serialize();
    }

    /** TODO: Fix when plugin support automatic day/night
    function isNight() {
        var positioningModel = ModelFactory.getModel("PositioningModel"),
            pos = positioningModel.getReferencePosition();

        var today = new Date();
        var janFirst = new Date(today.getFullYear(), 0, 1);
        var dayOfTheYear = Math.ceil((today - janFirst) / 86400000);
        var lat_rad = pos.latitude * (Math.PI/180);
        var declination = (23.4*Math.PI)/180 * Math.sin(2*Math.PI * (284+dayOfTheYear)/365);
        var omega = Math.acos(-Math.tan(declination) * Math.tan(lat_rad));
        var sunset = 12 - (1/15) * omega * (180/Math.PI) - pos.longitude/15 + today.getTimezoneOffset()/60;
        var sunrise = 24  - sunset; //(1/15) * omega * (180/Math.PI) - pos.longitude/15 + today.getTimezoneOffset()/60;

        console.log("Sunset:" + sunset);
        console.log("Sunrise:" + sunrise);

        var t = today.getHours() + today.getMinutes()/60;
        console.log("NOW: "+t);
        if (t >= sunrise && t < sunset) {
            return false;
        }
        return true;
    }

    function onDayNightSwitch() {
        console.log("onDayNightSwitch");
        if (dayNightMode === "auto") {
            console.log("Change map mode to: "+!nightMode);
            setNightMode(isNight());
        }
    }
    */
}
