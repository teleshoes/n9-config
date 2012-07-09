import QtQuick 1.1
import MapsPlugin 1.0
import components 1.0
import models 1.0
import "../models/ModelFactory.js" as ModelFactory
import "styles.js" as Style


Item {
    id: pickMarker    
    visible: false
    property bool saveState: false
    property variant map

    property variant geoCoordinates
    property int xPos
    property int yPos

    property int yOffset: 0
    property int fallOffset: 200    // height from which the marker will fall down
    property int shadowMargin: 25   // margin between the shadow and location marker
    property int fingerOffset: 70   // marker offset from picked location
    property int xAnchor: Style.PickMarker.anchor.x
    property int yAnchor: Style.PickMarker.anchor.y

    property bool animatedMarkerVisible: false
    property bool stateTwo: false   // indicate that longtap is in state two, i.e. location is selected and user lifted the finger
    property variant iconLayer      // maplayer for state two icon
    property variant mapIcon        // map object (icon) for state two long tap

    property int animationTime: 150
    property bool snapToAnimationRunning: false
    property bool queueStateTwo: false
    property bool stateTwoOneTransition: false

    property bool cancelLongTap: false
    property bool force2D: false    
    property bool hasInteraction: snapToAnimationRunning || updateTimer.running || perspectiveAnimation.running || state == "state_one" || animationOne.running || animationTwo.running || stateTwoOneTransition || stateTwoOneAnimation.running

    property int tapOffsetX: 0
    property int tapOffsetY: 0

    property int dragMarginTop: Style.PickMarker.height+165
    property int dragMarginBottom: map.height-20
    property int dragMarginLeft: Style.PickMarker.width/2+25
    property int dragMarginRight: map.width-Style.PickMarker.width/2-20

    property int zValue


    signal locationPicked(variant location)

    onGeoCoordinatesChanged: updatePosition()
    onForce2DChanged: {
        if ((map.perspective === 62 && pickMarker.force2D) ||
            (map.perspective === 0 && !pickMarker.force2D)) {
            perspectiveAnimation.startAnimation();
        }
    }

    states: [
        State {
            name: "hidden"
            when: !visible && !saveState
            PropertyChanges {
                target: pickMarker
                animatedMarkerVisible: false
            }
            PropertyChanges {
                target: bigShadow
                opacity: 0
            }
            PropertyChanges {
                target: smallShadow
                opacity: 0
            }
            PropertyChanges {
                target: marker
                opacity: 0
            }
        },
        State {
            name: "state_one"
            when: visible && !stateTwo && !saveState
            PropertyChanges {
                target: pickMarker
                animatedMarkerVisible: true
            }
            PropertyChanges {
                target: bigShadow
                opacity: 1
            }
            PropertyChanges {
                target: smallShadow
                opacity: 1
            }
            PropertyChanges {
                target: marker
                opacity: 1
            }
        },
        State {
            name: "state_two"
            when: visible && stateTwo || saveState
            PropertyChanges {
                target: pickMarker
                animatedMarkerVisible: true
            }
            PropertyChanges {
                target: bigShadow
                width: 0
                height: 0
                resizeX: pickMarker.xAnchor
                resizeY: pickMarker.yAnchor
            }
        }
    ]

    transitions: [
        Transition {
            to: "hidden"
            ScriptAction {
                script: { stateTwo = false; pickMarker.clearMapObjects(); }
            }
        },
        Transition {
            from: "hidden"
            to: "state_one"
            SequentialAnimation {
                id: animationOne
                alwaysRunToEnd: true
                ScriptAction {
                    script: {                        
                        bigShadow.reset();                        
                    }
                }
                ParallelAnimation {
                    PropertyAnimation { target: pickMarker; property: "yOffset"; from: pickMarker.fallOffset; to: pickMarker.shadowMargin; duration: animationTime; }
                    PropertyAnimation { target: marker; property: "opacity";  duration: animationTime; }
                    PropertyAnimation { target: smallShadow; property: "opacity"; duration: animationTime; }
                    PropertyAnimation { target: bigShadow; property: "opacity"; duration: animationTime; }
                }
                ScriptAction {
                    script: {
                        if (pickMarker.queueStateTwo) {
                            queueStateTwo = false;
                            pickMarker.enterStateTwo();                            
                        }
                    }
                }
            }
        },
        Transition {
            from: "state_one"
            to: "state_two"
            SequentialAnimation {
                id: animationTwo
                alwaysRunToEnd: true
                ParallelAnimation {
                    PropertyAnimation { target: pickMarker; property: "yOffset"; to: 0; duration: animationTime }
                    PropertyAnimation { target: bigShadow; properties: "width, height, resizeX, resizeY"; duration: animationTime }
                }
                ScriptAction {                    
                    script: {
                        var mapModel = modelFactory.getModel("MapModel");
                        var layer = mapModel.addLayer(map);
                        layer.zIndex = pickMarker.zValue;

                        pickMarker.animatedMarkerVisible = false;
                        pickMarker.mapIcon = mapModel.addIcon(pickMarker.geoCoordinates, map, layer,
                                                              Style.PickMarker.png.withSmallShadow,
                                                              Qt.point(pickMarker.xAnchor, pickMarker.yAnchor));
                        pickMarker.iconLayer = layer;                        

                        // notify that location has been picked
                        locationPicked(pickMarker.geoCoordinates);
                    }
                }
            }
        },
        Transition {
            from: "state_two"
            to: "state_one"
            SequentialAnimation {
                alwaysRunToEnd: true
                ScriptAction {
                    script: {
                        var onMapMoveDone = function() {
                            map.animationDone.disconnect(onMapMoveDone);
                            var pos = map.geoToScreen(pickMarker.mapIcon.location.geoCoordinates, true);
                            pickMarker.xPos = pos.x;
                            pickMarker.yPos = pos.y;
                            pickMarker.animatedMarkerVisible = true;
                            pickMarker.clearMapObjects();

                            bigShadow.height = bigShadow.width = 0;
                            bigShadow.resizeX = pickMarker.xAnchor;
                            bigShadow.resizeY = pickMarker.yAnchor;
                            stateTwoOneAnimation.start();
                            stateTwoOneTransition = false;
                        }
                        map.animationDone.connect(onMapMoveDone);
                        pickMarker.compensatePageOffset();
                    }
                }
            }
        }
    ]

    ParallelAnimation {
        id: stateTwoOneAnimation
        PropertyAnimation { target: pickMarker; property: "yOffset"; to: pickMarker.shadowMargin; duration: animationTime }
        PropertyAnimation { target: bigShadow; property: "width"; to: Style.PickMarker.width; duration: animationTime }
        PropertyAnimation { target: bigShadow; property: "height"; to: Style.PickMarker.height; duration: animationTime }
        PropertyAnimation { target: bigShadow; property: "resizeX"; to: 0; duration: animationTime }
        PropertyAnimation { target: bigShadow; property: "resizeY"; to: 0; duration: animationTime }
    }


    function cancel() {
        cancelLongTap = true;
        map.center = map.center; // stop map animations
    }

    function enterStateOne() {
        if (visible) {
            if (stateTwo) {
                stateTwoOneTransition = true;
            }
            stateTwo = false;
        }
    }

    function enterStateTwo() {
        if (stateTwoOneTransition) {
            // user lifted finger from screen during transition --> cancel transitions
            map.center = map.center;
            stateTwoOneAnimation.complete();
        }

        if (snapToAnimationRunning) {
            queueStateTwo = true;
        }
        else if (visible) {
            stateTwo = true;
        }
    }

    function snapTo(geoPos) {
        cancelLongTap = false;
        yOffset = 0;
        fallOffset = 200;
        shadowMargin = 25;
        fingerOffset = 70;

        var pp = map.geoToScreen(map.center, true);
        pp.y += fingerOffset;

        var onMapMoveDone = function() {
            map.animationDone.disconnect(onMapMoveDone);

            if (queueStateTwo) {
                // not sure why we have to do this, but on the device (not desktop)
                // the marker is placed at the wrong coordinates if we don't...
                geoCoordinates = map.geoPressPos;
            }

            snapToAnimationRunning = false;
            if (!cancelLongTap) {
                visible = true;
            }
            else {
                cancelLongTap = false;
            }
        }
        map.animationDone.connect(onMapMoveDone);
        snapToAnimationRunning = true;
        map.moveTo(map.screenToGeo(pp, true), Map.ANIMATION_LINEAR, Map.MAP_PRESERVE_ZOOM_LEVEL,
                   Map.PRESERVE_ORIENTATION, Map.PRESERVE_PERSPECTIVE);
        geoCoordinates = geoPos;
     }

    function updatePosition() {
        var pp = map.geoToScreen(geoCoordinates, true);
        xPos = pp.x;
        yPos = pp.y;
    }

    function pixelMove(pixelCoords) {
        var pp = map.geoToScreen(geoCoordinates, true);
        var yOffset = fingerOffset;
        if (pp.y < pixelCoords.y) {
            pp.y += Math.abs(pixelCoords.y-pp.y) - yOffset;
        }
        else {
            pp.y -= Math.abs(pixelCoords.y-pp.y) + yOffset;
        }

        if (pp.x < pixelCoords.x) {
            pp.x += Math.abs(pixelCoords.x-pp.x);
        }
        else {
            pp.x -= Math.abs(pixelCoords.x-pp.x);
        }

        if (needToDrag(pixelCoords)) {
            dragTimer.pixelCoords = pixelCoords;
            if (!dragTimer.running) {
                dragTimer.running = true;
            }
        }
        else {
            geoCoordinates = map.screenToGeo(pp, true);
            dragTimer.running = false;
        }
    }

    function needToDrag(pp) {
        if (pp.x > dragMarginRight ||
            pp.x < dragMarginLeft ||
            pp.y > dragMarginBottom ||
            pp.y < dragMarginTop) {
            return true;
        }
        return false;
    }

    function containsPixel(pos) {
        var pp = map.geoToScreen(geoCoordinates, true);
        var ret =  (pickMarker.visible && (pos.x > pp.x-50 && pos.x < pp.x+50
                                           && pos.y < pp.y+50 && pos.y > pp.y-yAnchor-25));
        if (ret) {
            var xdiff = pp.x-pos.x,
                ydiff = pp.y-pos.y;

            if(xdiff === 0) {
                tapOffsetX = 0;
            }
            else if (xdiff < 0) {
                if(xdiff >= -xAnchor) {
                    tapOffsetX = xdiff - (xAnchor + Math.abs(xdiff)-xAnchor);
                }
                else if (xdiff < -xAnchor) {
                    tapOffsetX = xdiff - (Math.abs(xdiff)-xAnchor) - xAnchor;
                }
            }
            else { // xdiff > 0
                if (xdiff <= xAnchor) {
                    tapOffsetX = xdiff + (xdiff-xAnchor) + xAnchor;
                }
                else if(xdiff > xAnchor) {
                    tapOffsetX = xdiff + (xAnchor + (xdiff-xAnchor));
                }
            }

            tapOffsetY = ydiff;
        }
        else {
            tapOffsetY = tapOffsetX = 0;
        }
        return ret;
    }

    function compensatePageOffset() {
        var center = map.geoToScreen(map.center, true),
            geoPos = map.geoToScreen(geoCoordinates, true),
            pp = map.pixelPressPos;

        center.y += tapOffsetY + fingerOffset;
        center.x -= (geoPos.x-pp.x);
        center.x += tapOffsetX;
        map.moveTo(map.screenToGeo(center, true), Map.ANIMATION_LINEAR, Map.MAP_PRESERVE_ZOOM_LEVEL,
                   Map.PRESERVE_ORIENTATION, Map.PRESERVE_PERSPECTIVE);
    }

    function clearMapObjects() {
        var mapModel = modelFactory.getModel("MapModel");
        if (iconLayer !== undefined) {
            mapModel.removeIcon(iconLayer, mapIcon);
        }
    }

    function reset() {
        pickMarker.saveState = false;
        pickMarker.visible = false;
        if (pickMarker.force2D && ModelFactory.getModel("MapSettingsModel").perspective === "3D") {
            // don't animate perpective change here
            map.perspective = 62;
            pickMarker.force2D = false;
        }
    }

    function makeInvisible(invisible) {
        if (mapIcon) {
            mapIcon.visible = !invisible;
        }

    }

    Timer {
        id: updateTimer
        interval: 5
        repeat: true
        running: pickMarker.visible && pickMarker.animatedMarkerVisible && !dragTimer.running
        onTriggered: pickMarker.updatePosition();
    }

    Timer {
        id: dragTimer
        property int dragDelta: 10
        property variant pixelCoords
        interval: 30
        repeat: true
        onTriggered: {
            var mapCenter = map.geoToScreen(map.center, true);
            var drag = false;
            var pp = dragTimer.pixelCoords;

            if (pp.x > dragMarginRight) {
                mapCenter.x += dragDelta;
                pp.x += dragDelta;
                drag = true;
            }
            else if (pp.x < dragMarginLeft) {
                mapCenter.x -= dragDelta;
                pp.x -= dragDelta;
                drag = true;
            }

            if (pp.y > dragMarginBottom) {
                mapCenter.y += dragDelta;
                pp.y += dragDelta;
                drag = true;
            }
            else if (pp.y < dragMarginTop) {
                mapCenter.y -= dragDelta;
                pp.y -= dragDelta;
                drag = true;
            }

            if (!drag) {
                dragTimer.running = false;
            }
            else {
                var newGeo = map.screenToGeo(mapCenter, true);
                map.moveTo(newGeo, Map.ANIMATION_NONE, Map.MAP_PRESERVE_ZOOM_LEVEL,
                           Map.PRESERVE_ORIENTATION, Map.PRESERVE_PERSPECTIVE);
                newGeo.destroy();

                if (pp.y !== yPos) {
                    yPos = pp.y - fingerOffset;
                }
                if (pp.x !== xPos) {
                    xPos = pp.x
                }
            }
            geoCoordinates = map.screenToGeo(Qt.point(xPos, yPos), true);
        }
    }

    Image {
        id: marker
        source: Style.PickMarker.marker.source
        visible: pickMarker.visible && pickMarker.animatedMarkerVisible && !stateTwoOneTransition
        smooth: true
        x: pickMarker.xPos - pickMarker.xAnchor
        y: pickMarker.yPos - pickMarker.yAnchor - pickMarker.yOffset
    }
    Image {
        id: bigShadow
        property int resizeX: 0 // for compensating x anchor offset while resizing
        property int resizeY: 0 // for compensating y anchor offset while resizing
        source: Style.PickMarker.bigShadow.source
        visible: pickMarker.visible && pickMarker.animatedMarkerVisible && !stateTwoOneTransition
        smooth: true
        x: pickMarker.xPos - pickMarker.xAnchor + resizeX
        y: pickMarker.yPos - pickMarker.yAnchor + resizeY

        function reset() {
            width = Style.PickMarker.width;
            height = Style.PickMarker.height;
            resizeX = resizeY = 0;
        }
    }
    Image {
        id: smallShadow
        source: Style.PickMarker.smallShadow.source
        visible: pickMarker.visible && pickMarker.animatedMarkerVisible&& !stateTwoOneTransition
        smooth: true
        x: pickMarker.xPos - pickMarker.xAnchor
        y: pickMarker.yPos - pickMarker.yAnchor
    }

    Item {
        id: perspectiveAnimation
        property int start: 62
        property int end: 0
        property bool from3d: start !== 0

        NumberAnimation { id: animation; target: map; property: "perspective"; from: perspectiveAnimation.start; to: perspectiveAnimation.end; duration: 500 }

        function startAnimation() {
            var mapSettingsModel = ModelFactory.getModel("MapSettingsModel");
            if (!mapSettingsModel.sateliteMode) {
                start = map.perspective;
                end = start < 62 ? end = 62 : 0
                animation.start();
            }
        }

        function stopAnimation() {
            animation.stop();
            map.perspective = from3d ? 62 : 0;
        }
    }

    Connections {
        target: map
        onMouseUp: {
            // make sure we stop dragging on mouse up.
            if (dragTimer.running) {
                dragTimer.running = false;
            }
        }
        onZoomScaleChanged: {
            var map = pickMarker.map;
            if (pickMarker.stateTwo) {
                if (map.zoomScale >= Style.MiniMap.longTapZoomThreshold.min && pickMarker.mapIcon !== undefined) {
                    pickMarker.mapIcon.visible = false;
                }
                else if (map.zoomScale < Style.MiniMap.longTapZoomThreshold.min && pickMarker.mapIcon !== undefined) {
                    pickMarker.mapIcon.visible = true;
                }
            }
        }
    }

    Component.onCompleted: {
        geoCoordinates = map.geoPressPos || map.center;
    }
}
