import QtQuick 1.1
import MapsPlugin 1.0
import components 1.0
import models 1.0
import "../utils/Units.js" as Units
import "../utils/ApplicationEventListeners.js" as EventListeners
import "../components/components.js" as Components
import "../models/ModelFactory.js" as ModelFactory


Page {
    id: page
    tag: "landingPage"
    fullscreen: !page.mapInteractionMode

    property variant appModel
    property variant appSettingsModel
    property variant guidanceModel
    property variant trafficModel
    property variant positioningModel
    property variant mapModel
    property variant favoritesModel
    property variant trackingHelper
    property variant speedLevelModel
    property variant currentSpeed: Units.getReadableSpeed(positioningModel ? positioningModel.speed : -1)

    property variant elapsedDistance: positioningModel &&
                                      positioningModel.position &&
                                      Units.getReadableDistanceVisual(guidanceModel ? guidanceModel.elapsedDistance : null)

    property variant elapsedDistanceUnit: _getDistanceUnit()
                       
    //modes are assistanceMode, assistanceMode-mapInteraction
    property bool mapInteractionMode: false
    property bool longTapInProgress: false

    //true if the GPS Lost timer was running before the powersave mode was on
    property bool gpsLostTimerWasRunning: false


    onBeforeShow: {
        setModels();
        var resetMarker = appModel.restartAssistance;

        // pre-load guidance during splash screen
        if (firstShow) {
            EventListeners.connectVoiceSkinModelListeners();

            //Pre compile next page objects
            Qt.createQmlObject("import components 1.0;import QtQuick 1.1; Item{ visible:false; ButtonItem {} List {} \
                MapPerspectiveSwitch {}}", page, null).destroy();

            startAssistanceMode();
        } else {
            minimap.hide();
            //setModels(); // successive calls, just get references
            //Precenter map if in tracking modes
            if (appModel.restartAssistance || !page.mapInteractionMode) {
                var positionSnapshot = positioningModel.getPositionSnapshot(page);
                if (positionSnapshot) {
                    minimap.map.center = positionSnapshot;
                    positionSnapshot.destroy();
                }
            }

            if (resetMarker) {
                minimap.maximizeMap();
                // reset the location picker (hides it and resets forced 2D/3D mode and savesState variable)
                minimap.pickMarker.reset();
                page.longTapInProgress = false;
                page.mapInteractionMode = false;
            }

        }
    }

    onShow: {
        if (!firstShow) {
            //traffic should be requested if assistance mode is restarted
            var restartTraffic = appModel.restartAssistance;
            if (appModel.restartAssistance) {                
                startAssistanceMode();
                if (device.minimized && appSettingsModel.gpsPowersaving) {
                    application.startPowersaveTimer();
                }
            }
            setupTracking();

            minimap.initializeMap(appModel.lastDestination);
            minimap.resetTransitionMap();
            minimap.show();

            // TODO: Uncomment when management makes up their minds
            //setupTraffic(false, restartTraffic);
        } else {
            mapModel.center = minimap.map.center;
            minimap.startupInitialization();
            // app startup, defer initialization
            defferConfigTimer.running = true;
            /** TODO: enable when this is fixed in plugin
            var mapSettingsModel = ModelFactory.getModel("MapSettingsModel");
            if (mapSettingsModel.dayNightMode === "auto") {
                mapSettingsModel.setNightMode(mapSettingsModel.isNight());
            }
            */
        }
    }

    Timer {
        id: defferConfigTimer
        interval: 50
        repeat: false
        onTriggered: {
            setModels();                // first call, actually creates models
            minimap.initializeMap();
            setupTracking();

            // TODO: Uncomment when management makes up their minds
            // Setup traffic after application startup
            //setupTraffic(true, false);
            application.setup();
        }
    }

    onBeforeHide: {
        // TODO: Uncomment when management makes up their minds
        //trafficModel.trafficError.disconnect(onTrafficError);
        //trafficModel.trafficError.disconnect(onTrafficReady);
        trackingHelper.pauseTracking();
        minimap.setTransitionMap();
        minimap.stopMapAnimation();
        minimap.hide();
    }

    onHide: {
        resetModels();
    }

    function setModels() {
        //Map properties
        appModel = ModelFactory.getModel("AppModel");
        appSettingsModel = ModelFactory.getModel("AppSettingsModel")
        mapModel = ModelFactory.getModel("MapModel");
        guidanceModel = ModelFactory.getModel("GuidanceModel");
        positioningModel = ModelFactory.getModel("PositioningModel");
        trafficModel = ModelFactory.getModel("TrafficModel");
        trackingHelper = ModelFactory.getModel("TrackingHelper");
        speedLevelModel = ModelFactory.getModel("SpeedLevelModel");
        favoritesModel = modelFactory.getModel("FavoritesModel");

        minimap.map.userInteractionChanged.connect(onUserMapInteraction);
        minimap.doubleTapZoomInProgressChanged.connect(onUserMapInteraction);
        minimap.mouseDown.connect(onUserMapInteractionPrivate);

        favoritesModel.myLocationSaved.connect(function(title, action) {
            favoritesNotification.locationText = title;
            favoritesNotification.actionText = action;
            favoritesNotification.show();
        });
    }

    function resetModels() {
        trackingHelper.cleanupMap();
        minimap.map.userInteractionChanged.disconnect(onUserMapInteraction);
        minimap.doubleTapZoomInProgressChanged.disconnect(onUserMapInteraction);
        minimap.mouseDown.disconnect(onUserMapInteractionPrivate);

        speedLevelModel.stopPolling();
        speedLevelModel.levelChanged.disconnect(onSpeedLevelChanged);

        appModel.restartAssistance = false;

        mapModel.center = minimap.map.center;
        mapModel = positioningModel = guidanceModel = appModel = trafficModel = modelFactory.standByModel;    //Don't really like this
    }

    function setupTracking() {
        var trackingMode = page.mapInteractionMode ? trackingHelper.mode_not_tracking : trackingHelper.mode_track_up;
        trackingHelper.trackOnMap(minimap.map);
        trackingHelper.setTrackingMode(trackingMode);
    }

    function setupTraffic(firstShow, restartTraffic) {
        trafficModel.trafficError.connect(onTrafficError);
        trafficModel.trafficReady.connect(onTrafficReady);
        trafficModel.map = minimap.map;

        if (appSettingsModel.trafficOn) {
            if (firstShow || restartTraffic) {
                trafficModel.requestTraffic();
            }
            minimap.showTraffic();
        }
        else {
            minimap.hideTraffic();
        }
    }

    function startAssistanceMode() {
        // reset overview mode if enabled
        if (quickZoomHelper.overviewMode) {
            quickZoomHelper.reset();
        }

        //Stop listeners and start assistance counters
        speedLevelModel.stopPolling();
        guidanceModel.startAssistance();
        speedLevelModel.levelChanged.disconnect(onSpeedLevelChanged);
        appModel.restartAssistance = false;

        //setup page properties
        page.mapInteractionMode = false;
    }

    function onSpeedLevelChanged(properties) {
        if (quickZoomHelper.activating) {
            return;
        }

        var stopSpeedPolling = true;
        if (page.mapInteractionMode) {                                                     //if in assistance + panning/zooming the map and speed triggers
            if (!minimap.hasUserInteraction) {                                              //and precisely the user is not panning or zooming
                if (quickZoomHelper.overviewMode) {
                    quickZoomHelper.reset();
                }

                page.mapInteractionMode = false;                                            //then snap back to user's position
                page.trackingHelper.setTrackingMode(page.trackingHelper.mode_track_up);
                if (page.longTapInProgress) {
                    page.longTapInProgress = false;
                    minimap.pickMarker.reset();
                    minimap.hideLocationPicker();
                    minimap.maximizeMap();
                }
            } else {                                                                        //otherwise, wait for next speed change
                stopSpeedPolling = false;
            }
        }

        //cleanup
        if (stopSpeedPolling) {
            speedLevelModel.levelChanged.disconnect(onSpeedLevelChanged);
            speedLevelModel.stopPolling();
        }
    }

    function onUserMapInteraction() {
        if (!minimap.map.hasUserInteraction && !minimap.doubleTapZoomInProgress) {
            return;
        }

        onUserMapInteractionPrivate();
    }

    function onUserMapInteractionPrivate() {

        //stop tracking
        if (trackingHelper.trackingMode != trackingHelper.mode_not_tracking) {
            trackingHelper.setTrackingMode(trackingHelper.mode_not_tracking);
            window.actionBar.navigateButton.type = "back";
        }

        //set the new state
        if (!page.mapInteractionMode) {
            page.mapInteractionMode = true;
            speedLevelModel.levelChanged.connect(onSpeedLevelChanged);
            speedLevelModel.startPolling();
        }
    }

    function stopPickLocation() {
        page.mapInteractionMode = false;
        page.longTapInProgress = false;
        minimap.pickMarker.cancel();
        minimap.hideLocationPicker(); // must hide location picker

        if (minimap.pickMarker.force2D) {
            minimap.pickMarker.force2D = false;
        }

        // start tracking & disconnect speed level changes
        trackingHelper.setTrackingMode(trackingHelper.mode_track_up);
        minimap.maximizeMap();
    }

    function onNavigateButtonClicked() {
         trackingHelper.trackingMode = trackingHelper.mode_not_tracking;

        // handle long tap case
        if (page.longTapInProgress) {
            if (minimap.pickLocationDialogVisible || !minimap.pickMarker.visible) {
                stopPickLocation();
            }
            else if (minimap.isMaximized) {
                minimap.minimizeMap();
                minimap.showPickDialog();
                minimap.moveTo(minimap.pickMarker.geoCoordinates, Map.ANIMATION_LINEAR);
            }
            else {
                stopPickLocation();
            }
        }
        else if (page.mapInteractionMode) {
            if (minimap.pickingLocation) {
                // user just started a lonng press but changed his mind and tapped back...
                stopPickLocation();
            }
            else {
                if (quickZoomHelper.overviewMode) {
                    var done = function() {
                        quickZoomHelper.transitionDone.disconnect(done);
                        trackingHelper.setTrackingMode(trackingHelper.mode_track_up);
                        page.mapInteractionMode = false;
                        minimap.maximizeMap();
                    }

                    quickZoomHelper.transitionDone.connect(done);

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
                    trackingHelper.setTrackingMode(trackingHelper.mode_track_up);
                    page.mapInteractionMode = false;
                    minimap.maximizeMap();
                }
            }
        }
        return false;
    }

    function onMenuButtonClicked() {        
        window.push( "settings/mapPreviewSettingsPage.qml", {
            navigationViewMode: !(page.longTapInProgress || quickZoomHelper.overviewMode),
            popOnSchemeChange: true,
            invokingPage: page.tag
        });
    }    

    function onTrafficError() {
    }

    function onTrafficReady() {
        minimap.showTraffic();
    }

    states: [
        State {
            name: "landscape"
            when: page.isLandscape

            // DASHBOARD
            AnchorChanges {
                target: dashboard
                anchors.top: page.top
                anchors.right: undefined
                anchors.bottom: page.bottom
                anchors.left: page.left
            }
            PropertyChanges { target: dashboard; width: Components.Assistance.landscape.width; }
        },
        State {
            name: "portrait"
            when: !page.isLandscape

            // DASHBOARD AND LOCATION
            AnchorChanges {
                target: dashboard
                anchors.top: undefined
                anchors.right: page.right
                anchors.bottom: page.bottom
                anchors.left: page.left
            }
            PropertyChanges {
                target: dashboard
                height: Components.Assistance.portrait.height
            }
        }
    ]

    // map
    MiniMap {
        id: minimap
        positionObjectVisible: true
        controlMargins.bottom: location.visible ? location.height : 0
        guidance: guidanceModel
        useNavigationMapSetup: true
        state: "fullscreen"
        longPressEnabled: page.mapInteractionMode && !quickZoomHelper.overviewMode
        overviewMode: quickZoomHelper.overviewMode
        handleFavoriteClicked: page.mapInteractionMode
        maxi.bottom: page.isLandscape ? page.bottom : (page.fullscreen ? dashboard.top : page.bottom)
        maxi.top: undefined
        maxi.left: undefined
        maxi.right: page.right
        maxi.height: page.isLandscape ? page.height : page.height - (page.fullscreen ? Components.Assistance.portrait.height : 0)
        maxi.width: page.isLandscape ? page.width - (page.fullscreen ? Components.Assistance.landscape.width : 0) : page.width

        onBeforeMinimized: {
            if (quickZoomHelper.overviewMode && page.trackingHelper.trackingMode == page.trackingHelper.mode_track_up) {
                page.trackingHelper.trackingMode = page.trackingHelper.mode_not_tracking;
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

    // location
    Location {
        id: location
        anchors.right: minimap.right
        anchors.bottom: minimap.bottom
        anchors.left: minimap.left
        isLandscape: page.isLandscape
        visible: page.fullscreen
        name: (positioningModel && positioningModel.currentStreetName) ? positioningModel.currentStreetName : ""
        hasGPS: (positioningModel && positioningModel.hasGPS) ? positioningModel.hasGPS : false
        // TODO: Uncomment when management makes up their minds
        loadingTraffic: false //(trafficModel && trafficModel.isLoadingTraffic) ? trafficModel.isLoadingTraffic : false
    }

    // dashboard
    Dashboard {
        id: dashboard
        isLandscape: page.isLandscape
        visible: page.fullscreen
        speedUnit: _isUnitSystemReady() ? currentSpeed.unit : ""
        speedValue: currentSpeed.value
        distanceUnit: elapsedDistanceUnit
        distanceValue: elapsedDistance ? elapsedDistance.value : "-"
        onMenuButtonClicked: window.push("settings/assistanceModeSettingsPage.qml", { invokingPage: tag })
    }

    function _isUnitSystemReady() {
        return appSettingsModel && // ensure the object is not undefined, which evals to false.
               appSettingsModel.currentUnitSystem;
    }

    function _getDistanceUnit() {
        return _isUnitSystemReady() ? (elapsedDistance ? elapsedDistance.unit
                                                       : Units.getCurrentShortDistanceUnit())
                                    : "";
    }

    // settings button
    MapIcon {
        id: settingsButton
        type: "settings"
        anchors.right: minimap.right
        anchors.bottom: minimap.bottom
        visible: page.mapInteractionMode && !minimap.pickingLocation && !minimap.pickLocationDialogVisible && minimap.isReallyMaximized
        anchors.rightMargin: Components.MapControls.margins.right + minimap.controlMargins.right
        anchors.bottomMargin: Components.MapControls.margins.bottom + minimap.controlMargins.bottom
        onClicked: {
            var currentPage = window.getCurrentPage();
            currentPage.onMenuButtonClicked && currentPage.onMenuButtonClicked()
        }
    }

    // favorites notification
    FavoritesNotification {
        id: favoritesNotification
        z: 2
    }

    // overview button
    MapIcon {
        id: quickZoomButton
        type: "quickZoom"
        z: 1
        anchors.right: minimap.right
        anchors.bottom: minimap.bottom
        visible: !page.mapInteractionMode && minimap.isReallyMaximized
        anchors.rightMargin: Components.MapControls.margins.right + minimap.controlMargins.right
        anchors.bottomMargin: Components.MapControls.margins.bottom + minimap.controlMargins.bottom
        onClicked: {
            trackingHelper.trackingMode = trackingHelper.mode_not_tracking;
            page.mapInteractionMode = true;

            var done = function() {
                quickZoomHelper.transitionDone.disconnect(done);
                trackingHelper.trackingMode = trackingHelper.mode_track_up;
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
        assistanceMode: true
    }

    Connections {
        target: MapsPlugin
        ignoreUnknownSignals: true

        onDiskcacheUnmounted: {
            console.log("Diskcache unmounted: exiting now");
            Qt.quit();
        }

        onDiskcacheWillUnmount: {
             console.log("Fs will unmount");
             if(guidanceModel.running) {
                console.log("Stopping guidance");
                guidanceModel.stopAssistance();
                guidanceModel.stopGuidance();
                guidanceModel.voiceSkinId = 0;
            }
        }
    }

    //Load initial map states before doing any show
    Component.onCompleted: {
        setModels();

        minimap.map.restoreState("drive.mapState");
        if (device.geoUrl) {
            mapModel.center = minimap.map.center;
        }

        //Turn off location.timer when in powersave mode
        application.powersaveModeOnChanged.connect(function() {
            if (application.powersaveModeOn) {
                if (location.gpsLostTimer.running) {
                    gpsLostTimerWasRunning = true;
                    location.gpsLostTimer.stop();
                } else {
                    gpsLostTimerWasRunning = false;
                }
            } else {
                gpsLostTimerWasRunning && !location.gpsLostTimer.running && location.gpsLostTimer.start();
            }
        });
    }
}
