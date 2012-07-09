import QtQuick 1.1
import MapsPlugin 1.0
import components 1.0
import models 1.0
import "../models/ModelFactory.js" as ModelFactory
import "components.js" as Components
import "styles.js" as Style


Item {
    id: mapView
    property variant appModel
    property variant mapModel
    property variant finder
    property variant routingModel
    property variant trafficModel
    property variant favoritesModel
    property variant appSettingsModel
    property variant mapSettingsModel
    property variant positioningModel

    property bool isMaximized: mapView.state == "fullscreen"
    // the prop isMaximized is not proper to tell if animation is running or not
    // But we can not correct it directly in such a late stage.
    // So one more prop here to tell the truth.
    property bool isReallyMaximized: false
    property bool doubleTapZoomInProgress: false
    property bool hasUserInteraction: map.hasUserInteraction || zoomInTimer.running || zoomOutTimer.running || doubleTapZoomInProgress || pickMarker.hasInteraction || pickingLocation || longTapInProgress
    property variant trackingHelper
    property variant guidance
    property int zoomIntervalDefault:appSettingsModel.app_mapZoomIntervalDefault
    property alias map: map
    property bool positionObjectVisible: false
    property real zoomDelta: appSettingsModel.app_zoomDelta
    property int transitionDuration:  appSettingsModel.app_transitionDuration
    property variant miniMapStyle: Style.MiniMap

    property bool useNavigationMapSetup: false //the navigation map setup applies only to maximized maps

    property int showTransitionDuration: appSettingsModel.app_showTransitionDuration
    property string dayCoverColor: miniMapStyle.coverColor.day
    property string nightCoverColor: miniMapStyle.coverColor.night
    property string sateliteCoverColor: miniMapStyle.coverColor.satelite

    property bool controlsBackgroundVisible: false

    property variant flagIconLayer
    property alias favoritesLayer: favorites

    property bool longTapInProgress: longTapTimer.running
    property bool pickingLocation: false
    property bool pickLocationDialogVisible: dialogScreen.visible
    property variant pickMarker: pickMarker
    property bool longPressEnabled: true
    property bool overviewMode: false

    // if set to false, then THIS minimap ignores the favorite click.
    property bool handleFavoriteClicked: false

    property Geometry mini: Geometry {
        top: page.top
        right: page.right
        height: !page.isLandscape ? page.height / 2 : page.height
        width: page.isLandscape ? page.width / 2 : page.width
    }
    property Geometry maxi: Geometry {
        top: page.top
        right: page.right
        bottom: page.bottom
        left: page.left
        height: page.height
        width: page.width
    }
    property Geometry controlMargins: Geometry {
        top: locationName.visible ? locationName.height : 0
        right: 0
        bottom: 0
        left: 0
    }

    signal beforeMinimized()
    signal mapMinimized()
    signal beforeMaximized()
    signal mapMaximized()
    signal userZoomLevelChange()
    signal beforeDestruction()
    signal longTapped(variant tapPos)
    signal click(variant pos)
    signal locationMarkerClicked(variant location)
    signal mouseDown()


    state: "minimized"

    function minimizeMap() {
        mapView.state = "minimized";
    }

    function maximizeMap() {
        mapView.state = "fullscreen";
    }

    function startupInitialization() {
        mapModel.applySettings(map, mapSettingsModel);
        mapView.isReallyMaximized = mapView.state == "fullscreen";
    }

    function initializeMap(destination) {
        //Add a destination flag if a location for it is specified
        if (destination) {
            flagIconLayer && flagIconLayer.removeAllMapObjects();
            var mapLayer = mapModel.addLayer(map);
            mapModel.addIcon(destination, map, mapLayer, miniMapStyle.destinationIconSource, Qt.point(15, 59));
            flagIconLayer = mapLayer;
            if (favorites.favoritesVisible) {
                flagIconLayer.zIndex = favorites.zValue + 1;
            }
        }

        var modelLocator = ModelFactory;
        var minimapInstance = mapView;
        mapSettingsModel.settingsChanged.connect((function(minimapInstance, modelLocator) {
            mapView.loadMapSetup(modelLocator);
        })(minimapInstance, modelLocator));

        mapView.isReallyMaximized = mapView.state == "fullscreen";
        loadMapSetup(modelLocator);
    }

    function setTransitionMap() {
        map.detailLevel = Map.LEAST_DETAILS;
    }

    function stopMapAnimation() {
        map.center = map.center;    //looks dumb, but it works
    }

    function resetTransitionMap() {
        map.detailLevel = Map.FULL_DETAILS;
    }

    function onMapStateChanged() {
        var modelLocator = ModelFactory;
        useNavigationMapSetup && mapView.loadMapSetup(modelLocator);    //Only guidance maps could need perspective adjustments on state changes
    }

    function loadMapSetup(modelLocator) {
        var force2D = !useNavigationMapSetup || !isMaximized || pickMarker.force2D || overviewMode;

        mapModel.applySettings(map, mapSettingsModel, force2D);
        mapModel.applyPoiSettings(map, mapSettingsModel);

        //adapt cover
        if (mapSettingsModel.sateliteMode) {
            cover.color = sateliteCoverColor;
        } else if (mapSettingsModel.nightMode) {
            cover.color = nightCoverColor;
        } else {
            cover.color = dayCoverColor;
        }

        var route = routingModel.currentMapRoute;
        if (route) {
            route.color = miniMapStyle.routeColor[mapSettingsModel.nightMode ? "night" : "day"];
        }

        //attach/deattach destruction callback
        mapModel.setCurrentMinimap(mapView);
    }

    function zoomIn() {
        var m = map, newZoom = m.zoomScale * zoomDelta;
        newZoom > m.minZoomScale && (m.zoomScale = newZoom);
    }

    function zoomOut() {
        var m = map, newZoom = m.zoomScale / zoomDelta;
        newZoom < m.maxZoomScale && (m.zoomScale = newZoom);
    }

    function hide() {
        map.visible = false;
        cover.visible = true;
        cover.state = "shown";
        // if pick location marker is visible,
        // save the state so it doesn't disappear when returning to map
        if (pickMarker.visible) {
            pickMarker.saveState = true;
        }
    }

    function show() {
        mapScreenshot.visible = false;
        map.visible = true;
        cover.state = "hidden";
        if (pickMarker.saveState) {
            pickMarker.saveState = false;
        }
    }

    function coverWithScreenshot() {
        map.visible = false;
        mapScreenshot.source = map.getMapImage();
        mapScreenshot.visible = true;
    }

    function showTraffic() {
        map.trafficInfoVisible = true;
    }

    function hideTraffic() {
        map.trafficInfoVisible = false;
    }

    function moveTo(newGeo, animation) {
        map.moveTo(newGeo,
            animation,
            Map.PRESERVE_SCALE,
            Map.PRESERVE_ORIENTATION,
            Map.PRESERVE_PERSPECTIVE);
    }

    function fixSearchResultForFavoriteItem(result, coordinates) {
        result.properties["geoLatitude"] = coordinates.latitude;
        result.properties["geoLongitude"] = coordinates.longitude;
        result.favoriteKey = favoritesModel.getFavoriteKey(undefined, coordinates);
        result.isFavorite = result.favoriteKey !== undefined;

        if (result.isFavorite) {
            // fix address if we have a favorite
            var favs = favoritesModel.getObjects();
            var fav = favs[result.favoriteKey];
            var favAddress = favoritesModel.getFormattedAddress(fav);
            if (favAddress) {
                result.address1 = fav.text;
                result.address2 = favAddress[0];
                result.detailAddress2 = favAddress[1];
                result.detailAddress3 = favAddress[2];
            }
        }

        return result;
    }

    function showPickedLocation(location) {
        var onSearchDone = function(errorCode, results) {
            finder.searchDone.disconnect(onSearchDone);

            // Must update the geo-coordinates & favorite key here,
            // otherwise positions won't match if user marks the place a favorite or moves marker over an existing favorite
            dialogScreen.currentLocation = fixSearchResultForFavoriteItem(results[0], pickMarker.geoCoordinates);

            if (results[0].favoriteKey !== undefined) {
                dialogScreen.isFavorite = true;
                dialogScreen.favoriteKey = results[0].favoriteKey;
                pickMarker.makeInvisible(true);
            }
            else {
                dialogScreen.isFavorite = false;
                dialogScreen.favoriteKey = results[0].undefined;
            }
        }

        finder.searchDone.connect(onSearchDone);
        finder.positionToName(location);
        moveTo(location, Map.ANIMATION_LINEAR);

        dialogScreen.currentPosition = pickMarker.geoCoordinates;
        dialogScreen.visible = true;
        mapView.pickingLocation = false;
        minimizeMap();
    }

    function showFavorite(favorite) {
        var pos = positioningModel.createGeoCoordinates(favorite.storeObjectProperties.position, minimap);
        var favAddress = favoritesModel.getFormattedAddress(favorite);
        if (favAddress) {
            // fix structure to match search results
            var item = {
                geoLatitude: pos.latitude,
                geoLongitude: pos.longitude
            };

            dialogScreen.currentLocation = { address1: favorite.text,
                                             address2: favAddress[0],
                                             detailAddress2: favAddress[1],
                                             detailAddress3: favAddress[2],
                                             location: {
                                                 latitude: item["geoLatitude"],
                                                 longitude: item["geoLongitude"]
                                             },
                                             isFavorite: true,
                                             favoriteKey: favorite.key,
                                             properties: item };
        }
        moveTo(pos, Map.ANIMATION_LINEAR);

        dialogScreen.currentPosition = pos;
        dialogScreen.isFavorite = true;
        dialogScreen.favoriteKey = favorite.key;

        dialogScreen.visible = true;
        minimizeMap();
    }

    function hideLocationPicker() {
        mapView.pickingLocation = false;
        pickMarker.visible = false;
    }

    function showPickDialog() {
        dialogScreen.visible = true;
    }

    function hidePickDialog() {
        dialogScreen.visible = false;
    }

    states: [
        State {
            name: "fullscreen"
            AnchorChanges {
                target: mapView
                anchors.top: maxi.top
                anchors.right: maxi.right
                anchors.bottom: maxi.bottom
                anchors.left: maxi.left
            }
            PropertyChanges {
                target: mapView
                height: maxi.height
                width: maxi.width
                x: maxi.x || 0
                y: maxi.y || 0
            }
        },
        State {
            name: "minimized"
            AnchorChanges {
                target: mapView
                anchors.top: mini.top
                anchors.right: mini.right
                anchors.bottom: mini.bottom
                anchors.left: mini.left
            }
            PropertyChanges {
                target: mapView
                height: mini.height
                width: mini.width
                x: mini.x || 0
                y: mini.y || 0
            }
        }
    ]

    transitions: [
        Transition {
            from: "minimized"
            to: "fullscreen"
            SequentialAnimation {
                alwaysRunToEnd: true
                ScriptAction {
                    script: {
                        dialogScreen.visible = false;
                        setTransitionMap();
                        beforeMaximized();
                    }
                }
                ParallelAnimation {
                    AnchorAnimation {
                        duration: transitionDuration
                    }
                    PropertyAnimation {
                        duration: transitionDuration
                        properties: "height,width"
                    }
                }
                ScriptAction {
                    script: {
                        resetTransitionMap();
                        mapMaximized();
                        mapView.isReallyMaximized = true;
                        onMapStateChanged();
                    }
                }
            }
        },
        Transition {
            from: "fullscreen"
            to: "minimized"
            SequentialAnimation {
                alwaysRunToEnd: true
                ScriptAction {
                    script: {
                        mapView.isReallyMaximized = false;
                        setTransitionMap();
                        beforeMinimized();
                    }
                }
                ParallelAnimation {
                    AnchorAnimation {
                        duration: transitionDuration
                    }
                    PropertyAnimation {
                        duration: transitionDuration
                        properties: "height,width"
                    }
                }
                ScriptAction {
                    script: {
                        resetTransitionMap();
                        mapMinimized();
                        onMapStateChanged();
                        mapView.pickingLocation = false;
                    }
                }
            }
        }
    ]

    Timer {
        id: searchTimer
        repeat: true
        interval: 1000

        function start() {
            finder.searchDone.connect(locationName.setLocation);
            finder.positionToName(pickMarker.geoCoordinates);
            running = true;
        }

        function stop() {
            finder.searchDone.disconnect(locationName.setLocation);
            finder.cancelSearch();
            running = false;
        }

        onTriggered: {
            finder.positionToName(pickMarker.geoCoordinates);
        }
    }

    Timer {
        id: longTapAnimationTimer
        repeat: false
        interval: 100

        onTriggered: {
            // user started long tap on existing marker
            if (pickMarker.containsPixel(map.pixelPressPos)) {
                longTapTimer.stop();
                mapView.pickingLocation = true;
                map.automaticPanning = false;
                pickMarker.enterStateOne();
                longTapped(map.geoPressPos);
            }
            else {
                longPressRectangle.startAnimationAt(map.pixelPressPos);
            }
        }
    }


    Timer {
        id: longTapTimer
        repeat: false
        interval: 800
        onTriggered: {
            pickMarker.snapTo(map.geoPressPos);
            mapView.pickingLocation = true;
            minimap.map.automaticPanning = false;
            searchTimer.start();
            longTapped(map.geoPressPos);
        }
    }

    // What is this used for?
//    Rectangle {
//        anchors.top: map.top
//        anchors.bottom: map.bottom
//        width: 100
//        color: "red"
//    }

    Map {
        id: map
        property variant pixelPressPos;
        property variant geoPressPos;
        anchors.fill: parent
        deviceOrientationMode: window.isLandscape ? Map.LANDSCAPE : Map.PORTRAIT
        positionObject.visible: positionObjectVisible

        onMapObjectsSelected: {
            // objects are not clickable in minimap
            if (!mapView.isReallyMaximized) return;

            // Check if user clicked on the location marker
            var markerIcon = pickMarker.mapIcon;
            if (markerIcon !== undefined && mapObject.id === markerIcon.id) {
                mapView.moveTo(pickMarker.geoCoordinates, Map.MAP_ANIMATION_LINEAR);
                locationMarkerClicked(pickMarker.geoCoordinates);
                mapView.minimizeMap();
                dialogScreen.visible = true;
            }

            else if (mapView.handleFavoriteClicked && favoritesLayer.favoritesVisible && favoritesLayer.isFavorite(mapObject.id)) {
                var fav = favoritesLayer.getFavoriteFromMapObjectId(mapObject.id);
                if (fav !== undefined) {
                    if (pickMarker.visible) {
                        hideLocationPicker();
                    }
                    showFavorite(fav);
                }

            }
        }
    }

    Rectangle {
        id: longPressRectangle
        width: 200
        height: 200
        radius: 80
        color: "#1080DD"
        smooth: true
        visible: false
        opacity: 0.6
        property int animateTime: 700

        Behavior on visible {
            PropertyAnimation { target: longPressRectangle; property: "scale"; from: 0.5; to: 1; duration: longPressRectangle.animateTime; }
        }
        Timer {
            id: longPressRectangleTimer

            running: false
            interval: longPressRectangle.animateTime
            onTriggered: {
                longPressRectangle.visible = false;
            }
        }

        function startAnimationAt(pixelPos) {
            if (pickMarker.visible) {
                pickMarker.visible = false;
            }
            x = pixelPos.x - width / 2;
            y = pixelPos.y - height / 2;
            longPressRectangleTimer.running = true;
            visible = true;
        }

        function stopAnimation() {
            longPressRectangleTimer.running = false;
            visible = false;
        }
    }

    FavoritesLayer {
        id: favorites
        map: mapView.map
        mapView: mapView
    }

    Image {
        id: mapScreenshot
        anchors.fill: parent
        visible: false;
    }

    Rectangle {
        id: cover
        anchors.fill: parent
        color: dayCoverColor
        state: "hidden"

        states: [
            State {
                name: "shown"
                PropertyChanges {
                    target: cover
                    opacity: 1.0
                }
            },
            State {
                name: "hidden"
                PropertyChanges {
                    target: cover
                    opacity: 0.0
                }
            }
        ]

        transitions: [
            Transition {
                from: "shown"
                to: "hidden"
                SequentialAnimation {
                    alwaysRunToEnd: true
                    ScriptAction {
                        script: {
                            setTransitionMap();
                        }
                    }
                    PropertyAnimation {
                        target: cover
                        duration: showTransitionDuration
                        //easing.type: Easing.OutQuad
                        properties: "opacity"
                    }
                    ScriptAction {
                        script: {
                            cover.visible = false
                            resetTransitionMap();
                        }
                    }
                }
            }
        ]
    }

    // zoom out
    MapIcon {
        id: zoomOutButton
        type: "zoomOut"
        visible: mapView.isReallyMaximized && !mapView.pickingLocation
        anchors.top: mapView.top
        anchors.topMargin: Components.MapControls.margins.top + controlMargins.top
        anchors.left: mapView.left
        anchors.leftMargin: Components.MapControls.margins.left + controlMargins.left

        onPressed: {
            zoomOut();
            zoomOutTimer.running = true;
        }

        onReleased: {
            zoomOutTimer.running = false;
            userZoomLevelChange();
        }
    }

    // zoom in
    MapIcon {
        id: zoomInButton
        type: "zoomIn"
        visible: mapView.isReallyMaximized && !mapView.pickingLocation
        anchors.top: mapView.top
        anchors.topMargin: Components.MapControls.margins.top + controlMargins.top
        anchors.right: mapView.right
        anchors.rightMargin: Components.MapControls.margins.right + controlMargins.right

        onPressed: {
            zoomIn()
            zoomInTimer.running = true;
        }

        onReleased: {
            zoomInTimer.running = false;
            userZoomLevelChange();
        }
    }

    // compass
    Compass {
        id: compass
        z: 1
        visible: mapView.isReallyMaximized && !mapView.pickingLocation
        angle: -map.orientation
        anchors.bottom: mapView.bottom
        anchors.bottomMargin: Components.MapControls.margins.bottom + controlMargins.bottom
        anchors.left: mapView.left
        anchors.leftMargin: Components.MapControls.margins.left + controlMargins.left
    }

    // a border cover to hide the red 1-pixel line at bottom of minimap
    Rectangle {
        color: "black"
        anchors.left: mapView.left
        anchors.right: mapView.right
        anchors.bottom: mapView.bottom
        height: 1
        visible: !page.isLandscape && !mapView.isReallyMaximized
    }

    Rectangle {
        id: locationDetails
        anchors.right: minimap.right
        anchors.top: minimap.top
        anchors.left: minimap.left
        color: "white"
        opacity: 0.9

        border.width: 1
        border.color: "#c4c4c4"
        height: 100
        visible: mapView.isMaximized && mapView.pickingLocation && !dialogScreen.visible

        Image {
            id: locationIcon
            source: Style.PickMarker.marker.source
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 16
            height: 42
            smooth: true
            fillMode: Image.PreserveAspectFit
        }

        Text {
            id: locationName
            verticalAlignment: Text.AlignVCenter
            anchors.left: locationIcon.right
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            elide: Text.ElideRight
            width: parent.width - locationIcon.width - 32 - 16

            color: "#282828"
            font.family: "Nokia Pure Regular"
            font.pixelSize: 36
            text: ""

            function setLocation(errorCode, results) {
                var result = false;
                if (results && results[0]) {
                    text = results[0].address1 || results[0].address2;
                    result = true;
                    locationDetails.height = Style.PickLocationPageBar.height.max;
                }
                return result;
            }
        }
    }

    Item {
        id: internal
        Timer {
            id: zoomInTimer
            interval: mapView.zoomIntervalDefault
            repeat: true
            onTriggered: zoomIn()
        }

        Timer {
            id: zoomOutTimer
            interval: mapView.zoomIntervalDefault
            repeat: true
            onTriggered: zoomOut()
        }
    }


    PickMarker {
        id: pickMarker
        map: minimap.map
        zValue: favoritesLayer.zValue + 2; // make sure marker is on top of favorites
        onLocationPicked: {
            if (!pickMarker.cancelLongTap) {
                mapView.showPickedLocation(location);
            }
            else {
                pickMarker.cancelLongTap = false;
            }
        }
    }

    Item {
        id: dialogScreen
        anchors.top: page.isLandscape ? parent.top : parent.bottom
        anchors.bottom: page.isLandscape ? parent.bottom : undefined
        anchors.right: page.isLandscape ? parent.left : parent.right
        width: page.isLandscape ? page.width / 2 : page.width
        height: page.isLandscape ? undefined : page.height / 2
        visible: false

        property alias isFavorite: addressBlock.isFavorite
        property alias favoriteKey: addressBlock.favoriteKey
        property variant currentLocation
        property variant currentPosition

        AddressTextBlock {
            id: addressBlock
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.leftMargin: page.isLandscape ? 22 : 40
            anchors.rightMargin: page.isLandscape ? 22 : 40
            anchors.topMargin: page.isLandscape ? 30 : 40
            address: dialogScreen.currentLocation
            landscape: page.isLandscape
            searchItem: dialogScreen.currentLocation ? dialogScreen.currentLocation.properties : undefined
            favoriteKey: undefined
            isFavorite: false
            isFavoriteVisible: true

            onAddFavorite: {
                favoriteKey = key;
                pickMarker.makeInvisible(true);
            }

            onRemoveFavorite: {
                favoriteKey = undefined;
                pickMarker.makeInvisible(false);
            }
        }

        Button {
            anchors.left: parent.left
            anchors.leftMargin: page.isLandscape ? 22 : 40
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 25
            anchors.right: parent.right
            anchors.rightMargin: page.isLandscape ? 22 : 40
            text: appModel.homeFlowFlag ? qsTrId("qtn_drive_set_as_home_btn")
                                        : qsTrId("qtn_drive_drive_to_btn")
            onClicked: {
                var address = dialogScreen.currentLocation;
                if (appModel.homeFlowFlag) {
                    var dialog = window.showDialog("DefineHome", {
                        address: address,
                        setting: appModel.homeFlowFlag == "setting", // hide hint line when in setting.
                    });

                    dialog.userReplied.connect(function(answer) {
                        if (answer == "ok") {
                            appSettingsModel.setHome(address);
                            if (appModel.homeFlowFlag == "setting") {
                                toSettings();
                            } else { // defining
                                appModel.setHomeFlow("defined");
                                toRoutePreview(address);
                            }
                        } else {  // user says NO.
                            if (appModel.homeFlowFlag == "setting") {
                                toSettings();
                            }
                        }
                    });
                } else {
                    toRoutePreview(address);
                }
            }
        }
    }

    function toSettings() {
        appModel.setHomeFlow();
        window.pop("settingsPage");
    }

    function toRoutePreview(address) {
        window.push("routePreviewPage.qml", { tag: page.tag, routeTo:  { address: address } } );
    }

    function doubleTabAnimationEnded() {
        doubleTapZoomInProgress = false;
        map.animationDone.disconnect(doubleTabAnimationEnded);
    }

    Connections {
        target: map
        onMouseDown: {
            if (mapView.isMaximized && mapView.longPressEnabled && (map.zoomScale < miniMapStyle.longTapZoomThreshold.min)) {

                if (pickMarker.snapToAnimationRunning) {
                    //pickMarker.cancel();
                    return;
                }

                if (geoPos) {
                    map.pixelPressPos = pixelPos;
                    map.geoPressPos = positioningModel.createGeoCoordinates(geoPos, map);
                    longTapAnimationTimer.start();
                    longTapTimer.start();
                    if (!mapView.isMaximized) mapView.maximizeMap();
                }
            }
            else if (!mapView.isMaximized){
                mapView.maximizeMap();
            }

            mouseDown();
        }
        onPointerMoved: {
            if (longTapTimer.running || longTapAnimationTimer.running) {
                if (Math.abs(map.pixelPressPos.x - pixelPos.x) > miniMapStyle.longTapArea.width ||
                    Math.abs(map.pixelPressPos.y - pixelPos.y) > miniMapStyle.longTapArea.height) {
                    longPressRectangle.stopAnimation();
                    longTapTimer.running = false;
                    longTapAnimationTimer.running = false;
                }
            }
            else if (!map.automaticPanning) {
                mapView.pickingLocation = true;
                pickMarker.pixelMove(pixelPos);
                if (!searchTimer.running) {
                    searchTimer.start();
                }
            }
        }
        onMouseUp: {
            longPressRectangle.stopAnimation();
            longTapTimer.running = false;
            longTapAnimationTimer.running = false;
            searchTimer.stop();

            if (!map.automaticPanning) {
                map.automaticPanning = true;
                if (mapView.pickingLocation) {
                    pickMarker.enterStateTwo();
                }
            }
        }
        onMouseDoubleClick: {
            var noXoom = 0;
            var DOUBLETABINTERVAL = 250;
            //a double finger tap is happening
            if ((new Date().getTime()) - noXoom < DOUBLETABINTERVAL) return;

            var m = map,
                newZoom = m.zoomScale * zoomDelta / 2,
                newScale = newZoom > m.minZoomScale ? newZoom : m.minZoomScale;

            doubleTapZoomInProgress = true;
            map.animationDone.disconnect(doubleTabAnimationEnded);
            map.animationDone.connect(doubleTabAnimationEnded);

            m.moveTo(geoPos, Map.ANIMATION_LINEAR, newScale,
                               Map.PRESERVE_ORIENTATION, Map.PRESERVE_PERSPECTIVE);
        }
        onTwoFingersMouseUp: {
            var noXoom = 0;
            var doubleTabTimeOut = 0;
            var DOUBLETABINTERVAL = 250;
            //look for two consequetive events
            var now = (new Date()).getTime();

            if (now - doubleTabTimeOut > DOUBLETABINTERVAL) {
                return (doubleTabTimeOut = now);
            }

            doubleTabTimeOut = 0;
            noXoom = now;

            var m = map,
                newZoom = m.zoomScale / zoomDelta * 2,
                newScale = newZoom < m.maxZoomScale ? newZoom : m.maxZoomScale;

            doubleTapZoomInProgress = true;
            map.animationDone.disconnect(doubleTabAnimationEnded);
            map.animationDone.connect(doubleTabAnimationEnded);

            m.moveTo(m.center, Map.ANIMATION_LINEAR, newScale,
                               Map.PRESERVE_ORIENTATION, Map.PRESERVE_PERSPECTIVE);
        }
    }

    Component.onCompleted: {
        appModel = ModelFactory.getModel("AppModel");
        mapModel = ModelFactory.getModel("MapModel");
        finder = ModelFactory.getModel("SearchModel");
        routingModel = ModelFactory.getModel("RoutingModel");
        trafficModel = ModelFactory.getModel("TrafficModel");
        favoritesModel = ModelFactory.getModel("FavoritesModel");
        appSettingsModel = ModelFactory.getModel("AppSettingsModel");
        mapSettingsModel = ModelFactory.getModel("MapSettingsModel");
        positioningModel = ModelFactory.getModel("PositioningModel");
    }

    Component.onDestruction: {
        beforeDestruction();
    }
}
