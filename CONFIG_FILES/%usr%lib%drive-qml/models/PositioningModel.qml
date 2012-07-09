import QtQuick 1.1
import MapsPlugin 1.0
import "ModelFactory.js" as ModelFactory


PositionProvider {
    id: positionProvider
    mapMatcherMode: PositionProvider.MAPMATCH_CAR
    enabled: true
    mapSensorEnabled: !!appSettingsModel && appSettingsModel.isMapSensorEnabled()

    property variant mapModel
    property variant appSettingsModel
    property string currentStreetName: position && roadElement ? (roadElement.roadName || roadElement.routeName) : ""
    property int direction: position && position.direction != Position.UNKNOWN_VALUE ? position.direction : 0
    property real speed: -1
    property real lastSpeed: -1
    property bool hasGPS: hasValidPosition && (positionMethod == PositionProvider.METHOD_GPS)

    onPositionChanged: updateSpeed()
    onPositionLost: updateSpeed()

    function updateSpeed() {
        var tmpSpeed = -1;
        if (position && position.speed != Position.UNKNOWN_VALUE) {
            tmpSpeed = position.speed;
            lastSpeed = tmpSpeed;
        } else {
            tmpSpeed = lastSpeed;
            lastSpeed = -1;
        }

        speed = tmpSpeed;
    }

    function getPositionSnapshot(parent) {
        var positionSnapshot;

        if (isValidPosition(location)) {
            positionSnapshot = Qt.createQmlObject("import MapsPlugin 1.0; GeoCoordinates {}", parent || positionProvider, null);
            positionSnapshot.longitude = position.geoCoordinates.longitude;
            positionSnapshot.latitude = position.geoCoordinates.latitude;
        }

        return positionSnapshot;
    }

    function getReferencePosition(parent) {
        var referencePosition,
            geoCoordinates;

        if (isValidPosition(location) || mapModel.center) {
            referencePosition = Qt.createQmlObject("import MapsPlugin 1.0; GeoCoordinates {}", parent || positionProvider, null);
            geoCoordinates = isValidPosition(location) ? location.geoCoordinates : mapModel.center;
            referencePosition.longitude = geoCoordinates.longitude;
            referencePosition.latitude = geoCoordinates.latitude;
        }

        return referencePosition;
    }

    function createGeoCoordinates(location, parent) {        
        var geoCoordinates = Qt.createQmlObject("import MapsPlugin 1.0; GeoCoordinates {}", parent || positionProvider, null);
        geoCoordinates.latitude = location.latitude;
        geoCoordinates.longitude = location.longitude;

        return geoCoordinates;
    }

    function isValidPosition(geoPosition) {
        return geoPosition && geoPosition.geoCoordinates && geoPosition.geoCoordinates.latitude && geoPosition.geoCoordinates.longitude;
    }

    Component.onCompleted: {
        mapModel = ModelFactory.getModel("MapModel");
        appSettingsModel = ModelFactory.getModel("AppSettingsModel");
    }
}
