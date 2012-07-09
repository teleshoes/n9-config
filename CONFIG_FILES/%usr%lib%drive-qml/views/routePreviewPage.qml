import QtQuick 1.1
import MapsPlugin 1.0
import components 1.0
import models 1.0
import "../utils/Units.js" as Units
import "../components/components.js" as Components
import "../components/styles.js" as Styles
import "../models/ModelFactory.js" as ModelFactory

Page {
    id: page
    tag: "routePreviewPage"

    property variant appModel
    property variant mapModel
    property variant recentsModel
    property variant routingModel
    property variant speedLevelModel
    property variant appSettingsModel
    property variant positioningModel

    property bool calculatingRoute: true
    property bool recalculateRoute: false
    property bool userInteraction: false

    property variant fromCoordinates
    property variant destinationCoords
    property GeoRect boundingBox

    property bool temporarilyOffline: false
    property bool errorOnServerConnection: false
    property int _ERROR_SERVER_CONNECTION: 14     // MOS ErrorCode: NGEO_ERROR_SERVER_CONNECTION, not available in MapsQMLPlugin
    property int _ERROR_OFFLINE_TIMEOUT: -1  // Error for timer running out when calculating route offline temporarily

    // make sure that zoom is not to precise
    property int additionalMargin: 10

    property QtObject routeMargins: QtObject {
        property int left: additionalMargin
        property int top: 0
        property int right: 0
        property int bottom: 0
    }

    property bool hasInteraction: false

    states: [
        State {
            name: "landscape"
            when: page.isLandscape
            PropertyChanges {
                target: minimap.mini
                top: page.top
                right: page.right
                height: page.height
                width: page.width / 2
            }
            AnchorChanges { target: dialogScreen; anchors.top: page.top }
            PropertyChanges {
                target: dialogScreen
                width: page.width - minimap.width
                height: page.height
            }
        },
        State {
            name: "portrait"
            when: !page.isLandscape
            PropertyChanges {
                target: minimap.mini
                top: page.top
                left: page.left
                height: page.height / 2
                width: page.width
            }
            AnchorChanges { target: dialogScreen; anchors.bottom: page.bottom }
            PropertyChanges {
                target: dialogScreen
                width: page.width
                height: page.height - minimap.height
            }
        }
    ]

    MiniMap {
        id: minimap
        positionObjectVisible: true
        longPressEnabled: false
        handleFavoriteClicked: false

        onMapMinimized: {
            dialogScreen.visible = true;
            zoomToRoute();
        }
        onBeforeMaximized: {
            dialogScreen.visible = false;
            hasInteraction = true;
            stopAutoStartPolling();
        }
        onMapMaximized: {
            zoomToRoute();
        }
    }

    // settings button
    MapIcon {
        id: settingsButton
        type: "settings"
        visible: minimap.isReallyMaximized
        anchors.right: minimap.right
        anchors.bottom: minimap.bottom
        anchors.rightMargin: Components.MapControls.margins.right
        anchors.bottomMargin: Components.MapControls.margins.bottom
        onClicked: {
            var currentPage = window.getCurrentPage();
            currentPage.onMenuButtonClicked && currentPage.onMenuButtonClicked()
        }
    }

    Rectangle {
        id: dialogScreen
        color: page.color //Use rectangle with filled color here to cover border of minimap
        anchors.left: page.left
        visible: true

        Column {
            id: calculationScreen
            spacing: 20
            anchors.centerIn: parent
            visible: calculatingRoute

            Text {
                id: calculateText
                anchors.horizontalCenter: calculationScreen.horizontalCenter
                text: qsTrId("qtn_drive_finding_your_route_not")
                color: "#FFFFFF"
                font.pixelSize: 36
                font.family: Styles.defaultFamily
            }

            Spinner {
                id: spinner
                visible: true
                anchors.horizontalCenter: calculationScreen.horizontalCenter
            }
        }

        Item {
            id: previewScreen
            anchors.fill: parent
            visible: !calculatingRoute

            SettingsButton {
                id: routeOptionsButton
                anchors.top: parent.top
                anchors.topMargin: 16
                anchors.right: buttonStart.right
                onClicked: window.push("settings/routeSettingsPage.qml", { invokingPage: "routePreviewPage" });
            }

            InfoBanner {
                id: routePropertiesOnMap
                anchors.left: buttonStart.left
                anchors.verticalCenter: routeOptionsButton.verticalCenter

                function update(v1, u1, v2, u2) {
                    distance = v1;
                    distanceUnit = u1;
                    duration = v2;
                    durationUnit = u2;
                }
            }

            AddressTextBlock {
                id: addressTextBlock
                anchors.top: routePropertiesOnMap.bottom
                anchors.topMargin: page.isLandscape ? 15 : 3
                anchors.left: routePropertiesOnMap.left
                anchors.right: routeOptionsButton.right
                anchors.bottom: buttonStart.top
                landscape: page.isLandscape
                address: params.routeTo ? params.routeTo.address : undefined
                isFavoriteVisible: false
                favoriteKey: undefined
                checkBottomLine: true
            }

            Button {
                id: buttonStart
                anchors.left: parent.left
                anchors.leftMargin: page.isLandscape ? 22 : 40
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 30
                anchors.right: parent.right
                anchors.rightMargin: page.isLandscape ? 22 : 40
                text: qsTrId("qtn_drive_start_navigation_btn")
                onClicked: triggerGuidance()
            }
        }
    }

    Connections {
        target: window
        onIsLandscapeChanged: zoomToRoute();
    }

    Timer {
        id: zoomTimer
        interval: 300   //Arbitrary... always a bit smaller than the standard 300 ms of the transitions
        repeat: false
        running: false
        onTriggered: {
            if (routingModel.currentRoute) {
                routeMargins.bottom = minimap.isMaximized? 0 : routePropertiesOnMap.height;
                routeMargins.bottom += additionalMargin;
                routingModel.zoomToGeoRect(boundingBox, minimap.map, routeMargins);
            }
        }
    }

    Timer {
        id: routeCalculationTimer
        interval: 30000 // 30 seconds
        onTriggered: {
            routingModel.cancelCalculation();
            calculatingRoute = false;

            if (temporarilyOffline) {
                onRouteCalculationError( _ERROR_OFFLINE_TIMEOUT );
            } else if (appSettingsModel.get('allowConnections')) {
                tryRouteCalculationOffline();
            } else {
                onRouteCalculationError( _ERROR_OFFLINE_TIMEOUT );
            }
        }
    }

    Timer {
        id: autoStartPollingTimer
        interval: 3000 // 3 sec
        repeat: false
        running: false
        triggeredOnStart: false
        onTriggered: {
            console.log("AutoStartPolling time triggered");
            startAutoStartPolling();
        }
    }

    onBeforeShow: {
        //set map properties
        minimap.initializeMap();
        minimap.setTransitionMap();

        //Determine "from" location and show start and destination flags
        if (firstShow) {
            var currentPosition = positioningModel.getPositionSnapshot(page);

            destinationCoords = positioningModel.createGeoCoordinates(params.routeTo.address.location, page);
            if (params.routeTo.address['originLocation']) {
                fromCoordinates = positioningModel.createGeoCoordinates(params.routeTo.address.originLocation, page);
            } else {
                fromCoordinates = currentPosition || mapModel.center;
            }
            routingModel.showWaypointIcons(fromCoordinates, destinationCoords, minimap.map);
            routeMargins.top = routeMargins.right = routingModel.waypointIconSize + additionalMargin;
            appSettingsModel.routeOptionsChanged.connect(onRouteOptionsChanged);
        }

        minimap.hide();

        // we don't show the favorites layer in route preview...
        minimap.favoritesLayer.setVisible(false);
    }

    onShow: {
        minimap.map.userInteractionChanged.connect(onUserMapInteraction);
        minimap.userZoomLevelChange.connect(onUserMapInteraction);
        minimap.resetTransitionMap();
        minimap.show();

        if (recalculateRoute && routingModel) {
            routingModel.removeRouteFromMap(minimap.map);
        }

        if (firstShow || recalculateRoute) {
            triggerRouteCalculation();
        } else {
            autoStartPollingTimer.start()
        }
    }

    onBeforeHide: {
        console.log("routePreviewPage: onBeforeHide");

        stopAutoStartPolling();

        if (calculatingRoute) {
            routingModel.cancelCalculation();
            calculatingRoute = false;
        }

        recoverFromTemporaryOffline();
        errorOnServerConnection = false;

        minimap.setTransitionMap();
        minimap.stopMapAnimation();
        minimap.hide();
    }

    onBeforeDestroy: {
        routingModel.routeCalculated.disconnect(onRouteCalculated);
        routingModel.routeCalculationError.disconnect(onRouteCalculationError);
        appSettingsModel.routeOptionsChanged.disconnect(onRouteOptionsChanged);
    }

    function onMenuButtonClicked() {
        window.push("settings/mapPreviewSettingsPage.qml", {
            popOnSchemeChange: true,
            invokingPage: page.tag
        });
    }

    function triggerRouteCalculation() {
        recalculateRoute = false;
        calculatingRoute = true;

        routingModel.routeCalculated.disconnect(onRouteCalculated);
        routingModel.routeCalculated.connect(onRouteCalculated);
        routingModel.routeCalculationError.disconnect(onRouteCalculationError);
        routingModel.routeCalculationError.connect(onRouteCalculationError);
        routingModel.calculateRoute(fromCoordinates, destinationCoords, minimap.map);
        routeCalculationTimer.restart();
    }

    // handle successful route calculations
    function onRouteCalculated(route) {
        routeCalculationTimer.stop();
        calculatingRoute = false;
        recoverFromTemporaryOffline();
        errorOnServerConnection = false;

        var routeLength = Units.getReadableDistanceVisual(route.length),
            routeDuration = Units.getReadableTime(route.duration);

        routePropertiesOnMap.update(routeLength.value,
                                    routeLength.unit,
                                    routeDuration.value,
                                    routeDuration.unit);

        boundingBox = routingModel.extendGeoRect(route.boundingBox, fromCoordinates);
        boundingBox = routingModel.extendGeoRect(boundingBox, destinationCoords);

        routingModel.showRouteOnMap(route, minimap.map);

        zoomToRoute(0);

        if (!hasInteraction) {
            autoStartPollingTimer.start();
        }
    }

    function startAutoStartPolling() {
        console.log("startAutoStartPolling()");

        speedLevelModel.restartPolling();
        speedLevelModel.levelChanged.connect(onSpeedLevelChanged);
    }

    function stopAutoStartPolling() {
        console.log("stopAutoStartPolling()");

        autoStartPollingTimer.stop();

        speedLevelModel.levelChanged.disconnect(onSpeedLevelChanged);
        speedLevelModel.stopPolling();
    }

    // handle route calculation errors
    // The order for error filters are critical!
    function onRouteCalculationError(errorCode) {
        routeCalculationTimer.stop();
        calculatingRoute = false;

        // 12289, some route options are disabled
        // no matter online, offline, or temp_offline, ask user to adjust settings and retry.
        if (( errorCode == Router.ERROR_GRAPH_DISCONNECTED_CHECK_OPTIONS ||
              errorCode == Router.ERROR_ROUTE_USES_DISABLED_ROADS ) &&
            ( parseInt(appSettingsModel.get('routeOptions')) !== 63 ) )
        {
            showDialogRouteDisabled();
            return;
        }

        // Ask user to try online in case
        if (!temporarilyOffline &&
            !appSettingsModel.get('allowConnections'))
        {
            showDialogSearchOnline();
            return;
        }

        // Ensure app online setting is not changed stealthily.
        recoverFromTemporaryOffline();

        // Most errors happening in temp offline mode because of Server Connection issue
        // should be treat as Server Connection issue.
        if (errorOnServerConnection)
        {
            errorOnServerConnection = false;
            showDialogNoConnection();
            return;
        }

        switch (errorCode) {
        case _ERROR_OFFLINE_TIMEOUT: // fall through
        case Router.ERROR_GRAPH_DISCONNECTED: // no route found
            showDialogNoRoute();
            break;
        case _ERROR_SERVER_CONNECTION: // Errors in Temp Offline mode wont come here
            errorOnServerConnection = true;
            tryRouteCalculationOffline();
            break;
        // these 2 cases will be touched only when All options are enabled already
        case Router.ERROR_GRAPH_DISCONNECTED_CHECK_OPTIONS: // fall through
        case Router.ERROR_ROUTE_USES_DISABLED_ROADS: // fall through
        default:
            showDialogNotReachable();
            break;
        }
    }

    function showDialogSearchOnline() {
        var dialog = window.showDialog("", {
            text: qsTrId("qtn_drive_route_cal_offline_try_online_err"),
            affirmativeMessage: qsTrId("qtn_drive_yes_btn_short"),
            cancelMessage: qsTrId("qtn_drive_no_btn_short"),
            columnLayout: true
        });

        dialog.userReplied.connect(function(answer) {
            if (answer == "ok") {
                appSettingsModel.setConnectionAllowed(true);
                triggerRouteCalculation();
            } else {
                window.pop();
            }
        });
    }

    function showDialogNoRoute() {
        var dialog = window.showDialog("", {
            text: qsTrId("qtn_drive_route_cal_no_route_err"),
            affirmativeMessage: qsTrId("qtn_drive_refine_destination_btn"),
            cancelVisible: false
        });

        dialog.userReplied.connect(function() { window.pop(); });
    }

    function showDialogNoConnection() {
        var dialog = window.showDialog("", {
            text: qsTrId("qtn_drive_route_cal_no_server_con_err"),
            affirmativeMessage: qsTrId("qtn_drive_ok_btn"),
            cancelVisible: false
        });

        dialog.userReplied.connect(function() { window.pop(); });
    }

    function showDialogRouteDisabled() {
        var dialog = window.showDialog("", {
            text: qsTrId("qtn_drive_route_cal_route_settings_dis_err"),
            affirmativeMessage: qsTrId("qtn_drive_edit_settings_btn"),
            cancelMessage: qsTrId("qtn_drive_enable_all_btn"),
            columnLayout: true
        });

        dialog.userReplied.connect(function(answer) {
            if (answer == "ok") {
                window.push("settings/routeSettingsPage.qml", {
                                invokingPage: page.tag,
                                forceRouteRecalculation: true // force recalculateRoute to true even without option changes
                            });
            } else {
                appSettingsModel.set('routeOptions');
                appSettingsModel.routeOptionsChanged();
                page.show(false);
            }
        });
    }

    function showDialogNotReachable() {
        var dialog = window.showDialog("", {
            text: qsTrId("qtn_drive_route_cal_not_reachable_err"),
            affirmativeMessage: qsTrId("qtn_drive_refine_destination_btn"),
            cancelVisible: false
        });

        dialog.userReplied.connect(function() { window.pop(); });
    }

    function onSpeedLevelChanged() {
        console.log("Speed level changed! ");
        triggerGuidance();
    }

    function triggerGuidance() {
        routingModel.removeRouteFromMap(minimap.map);

        stopAutoStartPolling();

        //save destination
        var addressToSave = params.routeTo.address;
        recentsModel.addDestination(addressToSave);

        if (params.routeTo.address['originLocation']) {
            window.push("guidancePage.qml", { originLocation: params.routeTo.address.originLocation });
        } else {
            window.push("guidancePage.qml");
        }
    }

    function onNavigateButtonClicked() {
        if (minimap.isMaximized) {
            minimap.minimizeMap();
            return false;
        } else {
            routingModel.clearRoute();
            // will pop automatically...
        }

        if (appModel.homeFlowFlag == "defined") {
            appModel.setHomeFlow();
            window.pop("set_destination");
        }
    }

    function zoomToRoute(interval) {
        zoomTimer.interval = (interval || interval === 0) ? interval : 300;
        zoomTimer.running = true;
    }

    function onUserMapInteraction() {
        minimap.isMaximized && (userInteraction = true);
    }

    function onRouteOptionsChanged() {
        recalculateRoute = true;
        calculatingRoute = true;  // force spinner to appear to avoid flashing back
    }

    function tryRouteCalculationOffline() {
        temporarilyOffline = true;
        appSettingsModel.setConnectionAllowed(false);
        triggerRouteCalculation();
    }

    function recoverFromTemporaryOffline() {
        if (temporarilyOffline) {
            temporarilyOffline = false;
            appSettingsModel.setConnectionAllowed(true);
        }
    }

    Component.onCompleted: {
        appModel = ModelFactory.getModel("AppModel");
        mapModel = ModelFactory.getModel("MapModel");
        recentsModel = ModelFactory.getModel("RecentsModel");
        routingModel = ModelFactory.getModel("RoutingModel");
        speedLevelModel = ModelFactory.getModel("SpeedLevelModel");
        appSettingsModel = ModelFactory.getModel("AppSettingsModel");
        positioningModel = ModelFactory.getModel("PositioningModel");
    }

    Component.onDestruction: {
        recoverFromTemporaryOffline();
    }
}
