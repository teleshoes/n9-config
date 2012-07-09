import QtQuick 1.1
import MapsPlugin 1.0
import "../models/ModelFactory.js" as ModelFactory


Item {
    id: quickZoom
    property variant map
    property bool assistanceMode
    property variant mapSettingsModel: ModelFactory.getModel("MapSettingsModel")

    property variant zoomOutPosition
    property int zoomOutScale
    property bool overviewMode: false
    property bool resetting: false
    property bool activating: transitionTimer.running
    property int overviewScale: 1694

    signal perspectiveChanged()
    signal transitionDone()

    function setOverviewMode(enabled) {
        if (resetting || overviewMode == enabled) return;

        if (transitionTimer.running) {
            transitionTimer.stop();
        }

        transitionTimer.start();
        if (enabled) {
            overviewMode = true;
            if (mapSettingsModel.perspective == "3D" && !mapSettingsModel.sateliteMode) {
                var onPerspectiveChanged = function() {
                    quickZoom.perspectiveChanged.disconnect(onPerspectiveChanged);
                    _zoomOut();
                }
                quickZoom.perspectiveChanged.connect(onPerspectiveChanged);
                perspectiveAnimation.startAnimation();
            }
            else {
                _zoomOut();
            }
        }
        else {
            overviewMode = false;
            _zoomIn();
        }
    }

    function reset() {
        if (!overviewMode) return;
        if (transitionTimer.running) {
            transitionTimer.stop();
        }        
        resetting = true;
        overviewMode = false;
        var p = (mapSettingsModel.perspective == "3D" && !mapSettingsModel.sateliteMode) ? 62 : 0;
        map.perspective = p;
        map.zoomScale = zoomOutScale;
        if (!assistanceMode) {
            // Make sure we map center is reset to 2/3 in guidance mode
            map.transformCenter = Qt.point(map.width / 2, (2/3) * map.height);
        }
        resetting = false;
    }


    function _zoomOut() {
        zoomOutScale = map.zoomScale;

        var positioningModel = ModelFactory.getModel("PositioningModel"),
            mapModel = ModelFactory.getModel("MapModel"),
            zoomLevels = map.zoomLevels,
            currentPos = map.center;

        if (positioningModel.hasGPS) {
            currentPos = positioningModel.getPositionSnapshot();
        }
        if (zoomOutPosition) {
            zoomOutPosition.destroy();
        }
        zoomOutPosition = positioningModel.createGeoCoordinates(currentPos);

        var onZoomOutDone = function() {
            transitionDone();
        }
        map.animationDone.connect(onZoomOutDone);

        map.moveTo(currentPos, Map.ANIMATION_BOW, overviewScale,
                   Map.PRESERVE_ORIENTATION, Map.PRESERVE_PERSPECTIVE);
    }

    function _zoomIn() {
        var onZoomInDone = function() {
            map.animationDone.disconnect(onZoomInDone);
            if (map.perspective === 0 && mapSettingsModel.perspective == "3D" && !mapSettingsModel.sateliteMode) {                

                var onPerspectiveChanged = function() {
                    quickZoom.perspectiveChanged.disconnect(onPerspectiveChanged);
                    transitionDone();
                }
                quickZoom.perspectiveChanged.connect(onPerspectiveChanged);
                perspectiveAnimation.startAnimation();
            }
            else {
                transitionDone();                
            }
        }
        map.animationDone.connect(onZoomInDone);

        var positioningModel = ModelFactory.getModel("PositioningModel");
        map.moveTo(positioningModel.hasGPS ? positioningModel.position.geoCoordinates :
                   zoomOutPosition,
                   Map.ANIMATION_LINEAR,
                   zoomOutScale,
                   Map.PRESERVE_ORIENTATION,
                   Map.PRESERVE_PERSPECTIVE);

        if (!assistanceMode) {
            // Make sure we map center is reset to 2/3 in guidance mode
            map.transformCenter = Qt.point(map.width / 2, (2/3) * map.height);
        }
    }

    Item {
        id: perspectiveAnimation
        property int start: 62
        property int end: 0
        property bool running: animation.running

        SequentialAnimation {
            id: animation
            alwaysRunToEnd: true
            NumberAnimation { target: quickZoom.map; property: "perspective"; from: perspectiveAnimation.start; to: perspectiveAnimation.end; duration: 400 }
            ScriptAction {
                script: quickZoom.perspectiveChanged()
            }
        }

        function startAnimation() {
            start = map.perspective;
            end = start < 62 ? end = 62 : 0
            animation.start();
        }
    }

    Timer {
        id: transitionTimer
        interval: 5000
        repeat: false;
    }
}
