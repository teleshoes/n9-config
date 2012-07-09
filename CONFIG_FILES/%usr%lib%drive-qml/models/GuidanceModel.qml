import QtQuick 1.1
import MapsPlugin 1.0
import "ModelFactory.js" as ModelFactory
import "Abbreviations.js" as Abbreviations

Guidance {
    id: guidance



    property variant routingModel
    property variant appSettingsModel
    property variant positioningModel
    property variant guidanceSettingsModel

    //Guidance properties and signals
    property bool hasGPS: positioningModel.hasGPS
    property bool rerouting: false
    property int guidanceMapPerspective: 62

    property int followRoadTriggerDistance: (positioningModel &&
                                             positioningModel.roadElement &&
                                             positioningModel.roadElement.formOfWay === RoadElement.FOW_MOTORWAY) ? 10000 : 3000
    property bool followRoad: guidance.nextManeuverDistance > followRoadTriggerDistance

    property int undefinedIconIndex: 0
    property int reroutingIconIndex: -1
    property int noGpsIconIndex: -2

    //Assistance properties and signals
    property bool assistanceModeOn: false

    property bool isNavigationMode: !!(guidance.guidanceMode) && (guidance.guidanceMode === Guidance.MODE_NAVIGATION)

    mapUpdateMode: Guidance.MAP_UPDATE_NONE
    onRerouteBegin: rerouting = true
    onRerouteEnd: rerouting = false
    onRouteUpdated: {
        routingModel.clearRoute();
        routingModel.currentRoute = route;
    }
    onGpsLost: hasGPS = false
    onGpsRestored: hasGPS = true
    voiceSkinId: 0
    audioOutputEvent: Guidance.AUDIO_MANEUVER | Guidance.AUDIO_GPS

    function startAssistance() {
        assistanceModeOn = true;
        guidance.startTracking();
    }

    function stopAssistance() {
        assistanceModeOn = false;
        guidance.stop();
    }

    function startGuidance(route) {
        guidance.navigateRoute(route);
    }

    function stopGuidance() {
        guidance.clear();
        guidance.stop();
    }

    //private, use guidanceSettingsModel.setSpeedWarnerOptions to control this
    function mSetSpeedWarnerOptions(pLowSpeedOffset, pHighSpeedOffset) {
        //80 km/h ~= 22.2 m/s
        //rounding here so UI can think of all values possible
        console.log("Setting warner offsets " + pLowSpeedOffset + ", " + pHighSpeedOffset)
        guidance.setSpeedWarnerOptions(Math.round(pLowSpeedOffset), Math.round(pHighSpeedOffset), 22);
    }

    //private, use guidanceSettingsModel.setSpeedWarnerAudio to control this
    function mSetSpeedWarnerAudio(speedWarnerAudioOn) {
        console.log("Setting speed warner audio " + (speedWarnerAudioOn ? "ON" : "OFF"));
        guidance.audioOutputEvent = (speedWarnerAudioOn === true) ?
                    guidance.audioOutputEvent | Guidance.AUDIO_SPEED_LIMIT :
                    guidance.audioOutputEvent & ~Guidance.AUDIO_SPEED_LIMIT;
    }

    function connectWarnings() {
        guidanceSettingsModel.lowSpeedOffsetChanged.connect(function () {
            mSetSpeedWarnerOptions(guidanceSettingsModel.lowSpeedOffset, guidanceSettingsModel.highSpeedOffset);
        });

        guidanceSettingsModel.highSpeedOffsetChanged.connect(function () {
            mSetSpeedWarnerOptions(guidanceSettingsModel.lowSpeedOffset, guidanceSettingsModel.highSpeedOffset);
        });

        guidanceSettingsModel.speedWarnerAudioOnChanged.connect(function () {
            mSetSpeedWarnerAudio(guidanceSettingsModel.speedWarnerAudioOn)
        });

        mSetSpeedWarnerOptions(guidanceSettingsModel.lowSpeedOffset, guidanceSettingsModel.highSpeedOffset);
        mSetSpeedWarnerAudio(guidanceSettingsModel.speedWarnerAudioOn);
    }

    function getAbbreviation(junctionsType) {
        var abbreviations = Abbreviations.JunctionType;
        var abbreviatedName = junctionsType;
        var regex = null;

        for (var i = 0, il = abbreviations.length; i < il; i++) {
            regex = new RegExp(abbreviations[i][0], "i");
            if (regex.test(abbreviatedName)) {
                abbreviatedName = abbreviatedName.replace(regex, abbreviations[i][1]);
                break;
            }
        }

        return abbreviatedName;
    }

    function applyUnitSystem(newUnitSystem) {
        guidance.distanceUnit = (newUnitSystem == appSettingsModel.units_metric ? Guidance.METRIC :
                                 newUnitSystem == appSettingsModel.units_impUK  ? Guidance.IMPERIAL :
                                                                                  Guidance.IMPERIAL_US);
    }

    Component.onCompleted: {
        routingModel = ModelFactory.getModel("RoutingModel");
        appSettingsModel = ModelFactory.getModel("AppSettingsModel");
        positioningModel = ModelFactory.getModel("PositioningModel");
        guidanceSettingsModel = ModelFactory.getModel("GuidanceSettingsModel");

        //apply voice skin id
        guidance.voiceSkinId = guidanceSettingsModel.getVoiceSkinId();
        guidanceSettingsModel.voiceSkinIdChanged.connect(function(newVoiceSkinId) {
            guidance.voiceSkinId = newVoiceSkinId;
        });

        connectWarnings();

        //apply unit settings
        applyUnitSystem(appSettingsModel.getUnitSystem());
        appSettingsModel.unitsSystemChanged.connect(applyUnitSystem);
    }
}
