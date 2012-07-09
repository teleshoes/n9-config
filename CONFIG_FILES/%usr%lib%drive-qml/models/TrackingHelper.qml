import QtQuick 1.1
import MapsPlugin 1.0
import "ModelFactory.js" as ModelFactory


QtObject {
    id: trackingHelper

    //"Constants" (MODES)
    property string mode_not_tracking: "not_tracking"
    property string mode_track_up: "track_up"
    property string mode_north_up: "north_up"

    //Models & state variables
    property variant positioningModel
    property variant guidanceModel
    property variant currentMap: null
    property string trackingMode: mode_not_tracking
    property bool snapping: false
    property bool paused: false

    //Actions
    property bool action_trackMap: (trackingMode == mode_track_up || trackingMode == mode_north_up) &&
                                    !snapping && currentMap != null && positioningModel.hasValidPosition && !paused
    property bool action_orientateMap: trackingMode == mode_track_up
    property bool action_wait_and_snap: false

    //Utilitary and setup methods
    function trackOnMap(map) {
        map != currentMap && (currentMap = map);
    }

    function cleanupMap() {
        currentMap = null;
    }

    Component.onCompleted: {
        guidanceModel = ModelFactory.getModel("GuidanceModel");
        positioningModel = ModelFactory.getModel("PositioningModel");
        positioningModel.positionUpdated.connect(trackingHelper.onPositionChanged);
        positioningModel.positionLost.connect(trackingHelper.onPositionLost);
    }

    //Main method used from the outside
    function setTrackingMode(newMode) {
        var oldMode = trackingMode;

        trackingMode = newMode;
        setupModeProperties();

        //Snap nicely to the position for tracking modes if currently not tracking or paused tracking
        if ((newMode == mode_track_up || newMode == mode_north_up) && (oldMode == mode_not_tracking || paused)) {
            snapToPosition();
        }
        paused = false;
    }

    function pauseTracking() {
        paused = true;
    }

    //Listeners
    function onPositionChanged() {
        if (!action_wait_and_snap) {
            //Move the map if the track map action is enabled
            action_trackMap && currentMap.moveTo(positioningModel.position.geoCoordinates,
                   Map.ANIMATION_NONE,
                   Map.PRESERVE_SCALE,
                   action_orientateMap ? positioningModel.direction : 0,
                   Map.PRESERVE_PERSPECTIVE);
        } else {
            //But if waiting to snap then...
            snapToPosition();
        }
    }

    function onPositionLost() {
        trackingMode != mode_not_tracking && (action_wait_and_snap = true);
    }

    //Will nicely move to the current position
    function snapToPosition() {
        snapping = true;

        if (positioningModel.position) {
            action_wait_and_snap = false;

            //Callback for animation done
            var onMapAnimationDone = function () {
                currentMap.animationDone.disconnect(onMapAnimationDone);

                //Do the mode setup here
                snapping = false;
                setupModeProperties();
            }

            currentMap.animationDone.connect(onMapAnimationDone);
            currentMap.moveTo(positioningModel.position.geoCoordinates,
                         Map.ANIMATION_BOW,
                         Map.PRESERVE_SCALE,
                         action_orientateMap ? positioningModel.direction : 0,
                         Map.PRESERVE_PERSPECTIVE);
        } else {
            action_wait_and_snap = true;
        }
    }

    function setupModeProperties() {
        var yCenterTransform = (trackingMode == mode_track_up ? 2/3 : 1/2);
        guidanceModel.mapUpdateMode = Guidance.MAP_UPDATE_NONE;
        currentMap.transformCenter = Qt.point(currentMap.width / 2, yCenterTransform * currentMap.height);
    }
}
