import QtQuick 1.1

import MapsPlugin 1.0
import components 1.0
import models 1.0

import "../utils/Units.js" as Units
import "../components/components.js" as Components
import "../models/ModelFactory.js" as ModelFactory

Page {
    id: page
    tag: "guidancePage"
    fullscreen: true

    //models
    property variant appModel
    property variant appSettingsModel
    property variant mapModel
    property variant guidanceModel
    property variant routingModel
    property variant positioningModel
    property variant speedLevelModel
    property variant trafficModel
    property variant favoritesModel

    //State properties
    property bool mapInteraction: false
    property bool initNoGps: false
    property variant currentSpeed: ((appSettingsModel && appSettingsModel.currentUnitSystem) !== undefined) &&
                                   (positioningModel != undefined ? Units.getReadableSpeed(positioningModel.speed) : 0)
    property variant nextManeuverDistance: ((appSettingsModel && appSettingsModel.currentUnitSystem) !== undefined) &&
                                           getNextManeuverDistance()
    property variant destinationDistance: ((appSettingsModel && appSettingsModel.currentUnitSystem) !== undefined) &&
                                          getDestinationDistance()

    property bool laneInfoAvailable: false
    property bool recalculateRoute: false
    property bool longTapInProgress: false

    states: [
        State {
            name: "landscape"
            when: page.isLandscape && !mapInteraction
            // dashboard
            PropertyChanges {
                target: dashboard
                width: Components.Assistance.landscape.width
            }
            AnchorChanges {
                target: dashboard
                anchors.top: guidance.bottom
                anchors.left: page.left
                anchors.bottom: page.bottom
            }
            // map
            PropertyChanges {
                target: minimap.maxi
                right: page.right
                bottom: page.bottom
                left: dashboard.right
                height: page.height - Components.Guidance.landscape.base.height
                top: undefined
            }
            // location
            AnchorChanges {
                target: location
                anchors.top: undefined
                anchors.right: minimap.right
                anchors.bottom: minimap.bottom
                anchors.left: minimap.left
            }
        },
        State {
            name: "portrait"
            when: !page.isLandscape && !mapInteraction
            // dashboard
            PropertyChanges {
                target: dashboard
                height: Components.Assistance.portrait.height
            }
            AnchorChanges {
                target: dashboard
                anchors.top: undefined
                anchors.right: page.right
                anchors.bottom: page.bottom
                anchors.left: page.left
            }
            // map
            PropertyChanges {
                target: minimap.maxi
                //top: guidance.bottom
                top: undefined
                right: page.right
                bottom: dashboard.top
                left: page.left
                height: page.height - Components.Guidance.portrait.height - dashboard.height
            }
            // location
            AnchorChanges {
                target: location
                anchors.top: undefined
                anchors.right: minimap.right
                anchors.bottom: minimap.bottom
                anchors.left: minimap.left
            }
        },
        State {
            name: "mapInteraction"
            when: mapInteraction
            PropertyChanges {
                target: minimap.maxi
                left: page.left
                bottom: page.bottom
                top: undefined
                height: page.height
                width: page.width
                right: page.right
            }
            PropertyChanges {
                target: dashboard
                visible: false
            }
            PropertyChanges {
                target: page
                fullscreen: false
            }
            PropertyChanges {
                target: location
                visible: false
            }
            PropertyChanges {
                target: guidance
                visible: false
            }
        }
    ]

    MiniMap {
        id: minimap
        state: "fullscreen"

        property double locationHeight: location.visible ? location.height : 0
        property double laneAssistanceBarHeight: laneAssistanceBar.visible ? laneAssistanceBar.height : 0
        controlMargins.bottom: window.isLandscape ? locationHeight : locationHeight + laneAssistanceBarHeight
        controlsBackgroundVisible: laneAssistanceBar.visible &&  window.isLandscape
        positionObjectVisible: true
        useNavigationMapSetup: true
        longPressEnabled: page.mapInteraction && !quickZoomHelper.overviewMode
        overviewMode: quickZoomHelper.overviewMode
        handleFavoriteClicked: page.mapInteraction

        onUserZoomLevelChange: {
            if (quickZoomHelper.overviewMode) return;   //TODO: fix this
            if (guidanceModel.mapUpdateMode == Guidance.MAP_UPDATE_ROADVIEW) {
                guidanceModel.mapUpdateMode = Guidance.MAP_UPDATE_POSITION;
                speedLevelModel.startPolling();
                speedLevelModel.levelChanged.connect(onSpeedLevelChanged);
            }
        }

        onBeforeMinimized: {
            if (quickZoomHelper.overviewMode && guidanceModel.mapUpdateMode == Guidance.MAP_UPDATE_POSITION) {
                 guidanceModel.mapUpdateMode = Guidance.MAP_UPDATE_NONE;
            }
        }

        onLongTapped: {
            page.longTapInProgress = true;

            // switch to 2D mode in case we're in 3D and long-tapping
            if (modelFactory.getModel("MapSettingsModel").perspective === "3D") {
                minimap.pickMarker.force2D = true;
            }
        }
    }

    LaneAssistanceBar {
        id: laneAssistanceBar
        anchors.horizontalCenter: minimap.horizontalCenter
        anchors.bottom: minimap.bottom
        visible: !page.mapInteraction && page.laneInfoAvailable
        property int widthLm: minimap.width - 2*Components.MapControls.width - Components.MapControls.margins.left - Components.MapControls.margins.right
        width: window.isLandscape ? widthLm : minimap.width
    }

    GuidancePanel {
        id: guidance
        anchors.top: page.top
        anchors.left: page.left
        isLandscape: page.isLandscape
        isRerouting: !!guidanceModel.rerouting
        visible: guidanceModel !== undefined && !guidanceModel.paused
        hasGPS: positioningModel !== undefined && positioningModel.hasGPS
        maneuverName: {
            var maneuverName = "";
            var routeName = guidanceModel &&
                            guidanceModel.nextManeuver &&
                            guidanceModel.nextManeuver.nextRouteName ? (guidanceModel.nextManeuver.nextRouteName + " / ")
                                                                     : ""

            if (initNoGps || !guidanceModel) {
                maneuverName = (routingModel !== undefined && routingModel.currentRoute !== undefined ) ? routingModel.currentRoute.maneuvers[1].nextStreetName : "";
            } else if (!guidanceModel.rerouting && !guidanceModel.followRoad) {
                maneuverName = guidanceModel.nextManeuver ?
                        (guidanceModel.nextManeuver.nextStreetName || guidanceModel.nextManeuver.nextRouteName) :
                        (routingModel && routingModel.currentRoute ? routingModel.currentRoute.maneuvers[1].nextStreetName : "") ;
            } else if (guidanceModel.rerouting) {
                maneuverName = qsTrId("qtn_drive_finding_new_route_not");
            } else {
                maneuverName = guidanceModel.nextManeuver.nextStreetName || guidanceModel.nextManeuver.nextRouteName;
            }

            return routeName + (guidanceModel ? guidanceModel.getAbbreviation(maneuverName)
                                              : "");
        }
        maneuverDistanceValue: nextManeuverDistance ? nextManeuverDistance.value : " - "
        maneuverDistanceUnit: nextManeuverDistance ? nextManeuverDistance.unit : Units.getCurrentShortDistanceUnit()
        maneuverIconIndex: {
            if (initNoGps || !guidanceModel) {
                return (routingModel !== undefined && routingModel.currentRoute !== undefined) ? routingModel.currentRoute.maneuvers[1].icon : 0;
            } else if (!guidanceModel.rerouting && !guidanceModel.followRoad) {
                return guidanceModel.nextManeuver ? guidanceModel.nextManeuver.icon :
                        (routingModel && routingModel.currentRoute ? routingModel.currentRoute.maneuvers[1].icon : 0);
            } else if (guidanceModel.rerouting) {
                return guidanceModel.reroutingIconIndex;
            } else {
                return guidanceModel.undefinedIconIndex;
            }
        }

        onManeuverClicked: {
            guidanceModel.repeat();
        }
    }

    Location {
        id: location
        isLandscape: page.isLandscape
        visible: guidanceModel !== undefined && !guidanceModel.paused && !laneAssistanceBar.visible
        name: (positioningModel && positioningModel.currentStreetName) ? positioningModel.currentStreetName : ""
        hasGPS: (positioningModel && positioningModel.hasGPS) ? positioningModel.hasGPS : false
        // TODO: Uncomment when management makes up their minds
        loadingTraffic: trafficModel === undefined ? false : trafficModel.isLoadingTraffic
    }

    Dashboard {
        id: dashboard
        isLandscape: page.isLandscape
        visible: guidanceModel !== undefined && !guidanceModel.paused
        speedUnit: typeof currentSpeed === "object" ? currentSpeed.unit : ""
        speedValue: typeof currentSpeed === "object" ? currentSpeed.value : "0"
        distanceUnit: destinationDistance ? destinationDistance.unit : Units.getCurrentShortDistanceUnit()
        distanceValue: destinationDistance ? destinationDistance.value : "-"
        onMenuButtonClicked: window.push("guidanceMenuPage.qml")
    }

    // favorites notification
    FavoritesNotification {
        id: favoritesNotification
        z: 2
    }

    // settings button
    MapIcon {
        id: settingsButton
        type: "settings"
        anchors.right: minimap.right
        anchors.bottom: minimap.bottom
        visible: page.mapInteraction && !minimap.pickingLocation && !minimap.pickLocationDialogVisible && minimap.isReallyMaximized
        anchors.rightMargin: Components.MapControls.margins.right + minimap.controlMargins.right
        anchors.bottomMargin: Components.MapControls.margins.bottom + minimap.controlMargins.bottom
        onClicked: {
            var currentPage = window.getCurrentPage();
            currentPage.onMenuButtonClicked && currentPage.onMenuButtonClicked()
        }
    }


    // overview button
    MapIcon {
        id: quickZoomButton
        type: "quickZoom"
        z: 1
        anchors.right: minimap.right
        anchors.bottom: minimap.bottom
        visible: !page.mapInteraction && minimap.isReallyMaximized
        anchors.rightMargin: Components.MapControls.margins.right + minimap.controlMargins.right
        anchors.bottomMargin: Components.MapControls.margins.bottom + minimap.controlMargins.bottom
        onClicked: {
            guidanceModel.mapUpdateMode = Guidance.MAP_UPDATE_NONE;
            page.mapInteraction = true;

            var done = function() {
                quickZoomHelper.transitionDone.disconnect(done);
                guidanceModel.mapUpdateMode = Guidance.MAP_UPDATE_POSITION;
                speedLevelModel.levelChanged.connect(onSpeedLevelChanged);
                speedLevelModel.startPolling();
            }
            quickZoomHelper.transitionDone.connect(done);
            quickZoomHelper.setOverviewMode(true);
        }
    }

    QuickZoom {
        id: quickZoomHelper
        map: minimap.map
        assistanceMode: false
    }


    onBeforeShow: {
        //move map to last known position, or reference map center (first time) if map has not been panned
        if (page.state != "mapInteraction") {
            var referencePosition = firstShow ? positioningModel.getReferencePosition() : positioningModel.getPositionSnapshot();
            if (!positioningModel.hasGPS && params['originLocation']) {
                minimap.map.center = positioningModel.createGeoCoordinates(params.originLocation, page);
            } else if (referencePosition) {
                minimap.map.center = referencePosition;
            }
        }

        var destination = routingModel && routingModel.currentRoute ? routingModel.currentRoute.routePlan.getStopoverAt(1) : undefined;
        appModel.lastDestination = destination;
        minimap.initializeMap(firstShow ? destination : null);
        minimap.setTransitionMap();
        minimap.hide();

        if (firstShow) {
            appSettingsModel.routeOptionsChanged.connect(onRouteOptionsChanged);
        }

        // hide favorite icon if it is set as destination
        if (destination) {
            var key = favoritesModel.getFavoriteKey(undefined, destination);
            minimap.favoritesLayer.hideFavoriteIcon(key, false);
        }
    }

    onShow: {
        if(recalculateRoute) {
            guidanceModel.stopGuidance();
            routingModel.removeRouteFromMap(minimap.map);
            guidanceModel.rerouteBegin(); // change lable text
            guidanceModel.startAssistance();
            routingModel.routeCalculated.disconnect(onRouteCalculated);
            routingModel.routeCalculationError.disconnect(onRouteCalculationError);

            routingModel.routeCalculated.connect(onRouteCalculated);
            routingModel.routeCalculationError.connect(onRouteCalculationError);

            routingModel.reCalculateRoute(minimap.map);
            recalculateRoute = false;
        }

        if (firstShow) {
            //Stop assistance if it was running. A likely case
            guidanceModel.stopAssistance();

            //Show Route on map and start guidance
            routingModel.showRouteOnMap(routingModel.currentRoute, minimap.map);
            setMapCenterYPosition(2/3);
            startRoadView();
            guidanceModel.startGuidance(routingModel.currentRoute);

            //Use first maneuver
            if (!positioningModel.hasGPS) {
                initNoGps = true;
                var resetInitialStatus = function() {
                    initNoGps = false;
                    positioningModel.hasGPSChanged.disconnect(resetInitialStatus);
                }

                positioningModel.hasGPSChanged.connect(resetInitialStatus);
            }

            //setup map interaction
            minimap.map.userInteractionChanged.connect(onMapInteraction);
            minimap.doubleTapZoomInProgressChanged.connect(onMapInteraction);
            guidanceModel.destinationReached.connect(onDestinationReached);
            minimap.mouseDown.connect(onMapInteractionPrivate);

            guidanceModel.showLaneInfo.connect(onShowLaneInfo);
            guidanceModel.hideLaneInfo.connect(onHideLaneInfo);

            //Delete all pages to the landing page
            window.deletePages("landingPage");
        }

        // TODO: Uncomment when management makes up their minds
        setupTraffic(firstShow);

        minimap.initializeMap();                                        //gotta do it again because showOnMap will override our map settings
        page.state != "mapInteraction" && (guidanceModel.mapUpdateMode = Guidance.MAP_UPDATE_ROADVIEW);
        minimap.resetTransitionMap();

        minimap.show();
    }

    onBeforeHide: {
        // TODO: Uncomment when management makes up their minds
        trafficModel.trafficError.disconnect(onTrafficReady);
        trafficModel.trafficError.disconnect(onTrafficError);
        guidanceModel.mapUpdateMode = Guidance.MAP_UPDATE_NONE;     //For the sake of transitions, stop the map movement
        minimap.setTransitionMap();
        minimap.stopMapAnimation();
        minimap.hide();
    }

    onBeforeDestroy: {
        routingModel.routeCalculated.disconnect(onRouteCalculated);
        routingModel.routeCalculationError.disconnect(onRouteCalculationError);
        appSettingsModel.routeOptionsChanged.disconnect(onRouteOptionsChanged);
        minimap.mouseDown.disconnect(onMapInteractionPrivate);
    }

    function setupTraffic(firstShow) {
        trafficModel.trafficReady.connect(onTrafficReady);
        trafficModel.trafficError.connect(onTrafficError);
        trafficModel.map = minimap.map;

        if (appSettingsModel.trafficOn) {
            if (firstShow) {
                trafficModel.requestTraffic();
            }
            minimap.showTraffic();
        }
        else {
            minimap.hideTraffic();
        }
    }

    function onMapInteraction() {
        if (!minimap.map.hasUserInteraction && !minimap.doubleTapZoomInProgress) {
            return;
        }

        onMapInteractionPrivate();
    }

    function onMapInteractionPrivate() {
        if (quickZoomHelper.overviewMode) {
            guidanceModel.mapUpdateMode = Guidance.MAP_UPDATE_NONE;
        }

        if (!page.mapInteraction) {      //The user is in guidance mode and starts panning the map
            page.mapInteraction = true;
            setMapCenterYPosition(1/2);
            stopRoadView();
            speedLevelModel.startPolling();
            speedLevelModel.levelChanged.connect(onSpeedLevelChanged);
        }
    }

    function onSpeedLevelChanged() {
        if (quickZoomHelper.activating) {
            return;
        }

        //snap to position using road view if a speed change comes while panning or zooming
        if (page.state == "mapInteraction" && !minimap.hasUserInteraction ||
                guidanceModel.mapUpdateMode == Guidance.MAP_UPDATE_POSITION) {
            if (quickZoomHelper.overviewMode) {
                quickZoomHelper.reset();
            }

            mapInteraction = false;
            setMapCenterYPosition(2/3);
            startRoadView();
            speedLevelModel.stopPolling();
            speedLevelModel.levelChanged.disconnect(onSpeedLevelChanged);

            if (page.longTapInProgress) {
                page.longTapInProgress = false;
                minimap.pickMarker.reset();
                minimap.hideLocationPicker();
                minimap.maximizeMap();
            }
        }
    }

    function onDestinationReached() {
        appModel.restartAssistance = true;
        guidanceModel.clear();
        routingModel.clearRoute();
        window.pop("landingPage");
    }

    function stopPickLocation() {
        page.mapInteraction = false;
        page.longTapInProgress = false;
        minimap.pickMarker.cancel();
        minimap.hideLocationPicker();

        if (minimap.pickMarker.force2D) {
            minimap.pickMarker.force2D = false;
        }

        startRoadView();
        setMapCenterYPosition(2/3);
        minimap.maximizeMap();
    }

    function onNavigateButtonClicked() {
        // handle long tap case
        if (page.longTapInProgress) {
            if (minimap.pickLocationDialogVisible || !minimap.pickMarker.visible) {
                stopPickLocation();
            }
            else if (minimap.isMaximized) {
                minimap.moveTo(minimap.pickMarker.geoCoordinates, Map.ANIMATION_LINEAR);
                minimap.minimizeMap();
                minimap.showPickDialog();
            }
            else {
                stopPickLocation();
            }
        }
        else if (page.mapInteraction) {
            guidanceModel.mapUpdateMode = Guidance.MAP_UPDATE_NONE;
            if (minimap.pickingLocation) {
                stopPickLocation();
            }
            else {
                if (quickZoomHelper.overviewMode) {
                    var done = function() {
                        quickZoomHelper.transitionDone.disconnect(done);
                        guidanceModel.mapUpdateMode = Guidance.MAP_UPDATE_ROADVIEW;
                        mapInteraction = false;
                        minimap.maximizeMap();
                    }
                    quickZoomHelper.transitionDone.connect(done);
                    setMapCenterYPosition(2/3);

                    if (!minimap.isMaximized) {
                        var onMaximized = function() {
                            quickZoomHelper.setOverviewMode(false);
                        }
                        minimap.mapMaximized.connect(onMaximized)
                        minimap.maximizeMap();
                    }
                    else {
                        quickZoomHelper.setOverviewMode(false);
                    }
                }
                else {                    
                    var lastPosition = positioningModel.location.geoCoordinates;
                    if (!positioningModel.hasGPS && (lastPosition.latitude !== 0 || lastPosition.longitude !== 0)) {
                        minimap.map.moveTo(lastPosition,
                                           Map.ANIMATION_BOW,
                                           Map.PRESERVE_SCALE,
                                           Map.PRESERVE_ORIENTATION,
                                           Map.PRESERVE_PERSPECTIVE);
                    }                                       
                    setMapCenterYPosition(2/3);
                    mapInteraction = false;
                    minimap.maximizeMap();
                    startRoadView();

                }
            }
        }

        return false;
    }

    function onShowLaneInfo() {
        var laneInfos = guidanceModel.laneInfos;
        laneAssistanceBar.showLaneInfo(laneInfos);

        laneInfoAvailable = true;
    }

    function onHideLaneInfo() {
        laneInfoAvailable = false;
    }

    function startRoadView() {
        guidanceModel.showOnMap(minimap.map);
        minimap.initializeMap();
        guidanceModel.mapUpdateMode = Guidance.MAP_UPDATE_ROADVIEW;
    }

    function stopRoadView() {
        guidanceModel.mapUpdateMode = Guidance.MAP_UPDATE_NONE;
        guidanceModel.removeFromMap(minimap.map);
        minimap.initializeMap();
    }

    function onMenuButtonClicked() {
        window.push( "settings/mapPreviewSettingsPage.qml", {
            navigationViewMode: !(page.longTapInProgress || quickZoomHelper.overviewMode),
            popOnSchemeChange: true,
            invokingPage: page.tag
        });
    }

    function setMapCenterYPosition(factor) {
        minimap.map.transformCenter = Qt.point(minimap.map.width / 2, factor * minimap.map.height);
    }

    function getNextManeuverDistance() {
        var distance = 0;
        if (initNoGps || !guidanceModel) {
            distance = (routingModel !== undefined  && routingModel.currentRoute !== undefined) ?
                    routingModel.currentRoute.maneuvers[1].distanceFromPreviousManeuver : 0;
        } else {
            distance = guidanceModel.nextManeuverDistance;
        }

        return Units.getReadableDistanceVisual(distance);
    }

    function getDestinationDistance() {
        var distance = guidanceModel ? guidanceModel.destinationDistance : 0
        return Units.getReadableDistanceVisual(distance);
    }

    function onTrafficError() {
    }


    function onForceTrafficUpdate() {
        trafficModel.requestTraffic();
    }

    function onTrafficReady() {
        minimap.showTraffic();
    }

    function onRouteOptionsChanged() {
        console.log("Route Options changed!");
        recalculateRoute = true;
    }

    // handle successful route calculations
    function onRouteCalculated(route) {
        routingModel.routeCalculated.disconnect(onRouteCalculated);
        routingModel.routeCalculationError.disconnect(onRouteCalculationError);
        routingModel.showRouteOnMap(route, minimap.map);
        guidanceModel.stopAssistance();
        guidanceModel.startGuidance(route);
        guidanceModel.rerouteEnd(); // change lable text
    }

    // handle successful route calculations
    function onRouteCalculationError(errorCode) {
        routingModel.routeCalculated.disconnect(onRouteCalculated);
        routingModel.routeCalculationError.disconnect(onRouteCalculationError);
        guidanceModel.stopAssistance();
        guidanceModel.rerouteEnd(); // change lable text

        var dialog = window.showDialog("", {
            text: qsTrId("qtn_drive_route_cal_route_settings_dis_err"),
            affirmativeMessage: qsTrId("qtn_drive_edit_settings_btn"),
            cancelMessage: qsTrId("qtn_drive_enable_all_btn"),
            columnLayout: true
        });

        dialog.userReplied.connect(function(answer) {
            if (answer == "ok") {
                window.push("settings/routeSettingsPage.qml",
                            { invokingPage: page.tag });
            } else {
                appSettingsModel.set('routeOptions');
                appSettingsModel.routeOptionsChanged();
                //page.beforeHide();
                page.show(false);
            }
        });
    }

    Component.onCompleted:  {
        appModel = ModelFactory.getModel("AppModel");
        appSettingsModel = ModelFactory.getModel("AppSettingsModel");
        guidanceModel = ModelFactory.getModel("GuidanceModel");
        routingModel = ModelFactory.getModel("RoutingModel");
        positioningModel = ModelFactory.getModel("PositioningModel");
        mapModel = ModelFactory.getModel("MapModel");
        speedLevelModel = ModelFactory.getModel("SpeedLevelModel");
        trafficModel = ModelFactory.getModel("TrafficModel");

        minimap.guidance = guidanceModel;

        favoritesModel = modelFactory.getModel("FavoritesModel");

        favoritesModel.myLocationSaved.connect(function(title, action) {
            favoritesNotification.locationText = title;
            favoritesNotification.actionText = action;
            favoritesNotification.show();
        });
    }
}
