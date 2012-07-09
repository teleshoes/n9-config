import QtQuick 1.1
import models 1.0
import "../models/ModelFactory.js" as ModelFactory
import DriveApp 1.0
import MapsPlugin 1.0
import com.nokia.meego 1.1


DriveApp {
    id: application

    property variant appModel
    property variant searchModel
    property variant routingModel
    property variant guidanceModel
    property variant voiceSkinModel
    property variant appSettingsModel
    property variant positioningModel

    property bool stopNavigationDialogVisible: false

    //powersaving properties
    property bool pluginWasOnline: false
    property bool powersaveModeOn: false
    property Timer powersaveTimer: Timer {
        interval: 120000
        onTriggered: enterPowersaveMode()
    }


    property bool windowVisible: platformWindow.visible
    property bool windowActive: platformWindow.active
    onWindowVisibleChanged: application._visibilityChangedHandler();
    onWindowActiveChanged: application._visibilityChangedHandler();

    signal applicationShow()

    function setupGpsSleeper() {
        console.log("Setting up gps sleeper");

        //Handle app minimize changes
        device.minimizedChanged.connect(function() {
            if (appSettingsModel.gpsPowersaving && !guidanceModel.isNavigationMode) {
                console.log("Gps sleeper, minimized: " + device.minimized);
                device.minimized ? powersaveTimer.restart() : resetPowersaveTimer();
            }
        });

        if(device.minimized && appSettingsModel.gpsPowersaving)
        {
            console.log("Gps sleeper, application is minimized at startup");
            powersaveTimer.restart();
        }
    }

    function setupRoamingMode() {
        //Initial roaming check
        checkRoamingStatus();

        //subscribe and react to further changes on roaming
        device.roamingChanged.connect(checkRoamingStatus);
    }

    function setupVoiceCatalog() {
        console.log("Setting up voice catalog");
        voiceSkinModel.downloadCatalog();
    }

    function setupFavorites() {
        console.log("Setting up favorites");

        var model = ModelFactory.getModel("FavoritesModel");
        model.initializeService();
        //model.initialize();
    }

    function checkRoamingStatus() {
        if (appSettingsModel.isConnectionAllowed() && device.roaming) {
            var dialog = window.showDialog("", {
                text: qsTrId("qtn_drive_roaming_dlg"),
                affirmativeMessage: qsTrId("qtn_drive_ok_btn_short"),
                cancelVisible: false,
                iconSource:"../resources/alertIcon.png"
            });
        }
    }

    function setup() {
        device.allowBacklightDimming = true;
        setupVoiceCatalog();
        setupGpsSleeper();
        setupRoamingMode();
        setupFavorites();
    }

    function show() {
        _updateModels();
        if (appSettingsModel.get('serviceAgreedOn') && mambaVersion !== appSettingsModel.get('appVersion')) {
            appSettingsModel.set('serviceAgreedOn');
            appSettingsModel.set('npsDone');  // allow user feedback
        }
        appSettingsModel.set('appVersion', mambaVersion);

        if (appSettingsModel.get('serviceAgreedOn') || device.desktopClient) {
            showAssistance();
        } else {
            applicationShow();
            var dialog = window.showDialog("Welcome", {});
            dialog.userReplied.connect(function(answer) {
                if (answer == "ok") {
                    appSettingsModel.set('serviceAgreedOn', new Date().toUTCString());
                    showAssistance();
                } else {
                    Qt.quit();
                }
            });
        }
    }

    function showAssistance() {
        if (device.geoUrl) {
            var geoData = parseGeoUrl(device.geoUrl);
            if (geoData) {  // after checker No.2 we ensure that either SearchTerm, or DestLocation is valid.
                application.setup(); // This is necessary only when pushHidden assistancePage
                window.pushHidden("assistancePage.qml");
                geoUrlAction(geoData);
                return;
            } else {
                console.log("--> Invalid geoUrl to Drive. Launch app as default.");
                // fall through to the general case.
            }
        }

        window.push("assistancePage.qml");
        applicationShow();
    }

    function geoUrlAction(geoData) {
        if (geoData.searchTerm) {
            window.push("searchPage.qml", { searchTerm: geoData.searchTerm }, true);
            applicationShow();
        } else {
            // TODO: check if is in favorites model
            var isFavorite = false;

            // navi request from Maps, we do not believe anything from it except geoLoc.
            var newAddress = {
                address1: "",
                address2: "",
                detailAddress2: "",
                detailAddress3: "",
                location: geoData.location,
                iconUrlList: searchModel.getIconSourceFromId(geoData.destinationCategoryId, "list", isFavorite),
                iconUrlMap: searchModel.getIconSourceFromId(geoData.destinationCategoryId, "map", isFavorite),
                originLocation: geoData.originLocation
            };
            _retreiveAddress(newAddress.location, newAddress);
        }
    }

    // a copy function from searchResultPage, might should be moved to searchModel?
    function _retreiveAddress(location, address) {
        var searchOnline = appSettingsModel.isConnectionAllowed() && device.online;

        function _onReverseGeoCodingDone(errorCode, result) {
            searchModel.reverseGeocodingDone.disconnect(_onReverseGeoCodingDone);
            if (result) {
                address.address1 = result.address1;
                address.detailAddress2 = result.detailAddress2;
                address.detailAddress3 = result.detailAddress3;
            } else {
                address.address1 = qsTrId("qtn_drive_destination_input");
                address.detailAddress2 = "";
                address.detailAddress3 = "";
            }

            toRoutePreview(address);
        }

        searchModel.reverseGeocodingDone.connect(_onReverseGeoCodingDone);
        searchModel.reverseGeocode(location, searchOnline);
    }

    function toRoutePreview(address) {
        window.push("routePreviewPage.qml", { routeTo:  { address: address } }, true );
        applicationShow();
    }

    function parseGeoUrl(url) {
        var geoUrlPattern = /^geo:[-+]?\d+(\.\d+)?,[-+]?\d+(\.\d+)?\?/i;  // looking for something like "geo:1.1,2.2?*"
        if (!geoUrlPattern.test(url)) return undefined; // checker no.1.
        var parts = url.split("?", 2);
        var geos = parts[0].substr(4).split(",", 2);
        var destLatitude = geos[0];
        var destLongitude = geos[1];
        var location = undefined;
        // ensure either of both exists, and does not equal to "0"
        if (destLatitude && parseFloat(destLatitude) && destLongitude && parseFloat(destLongitude)) {
            location = { latitude: destLatitude, longitude: destLongitude };
        }

        var searchTerm = matchParam(parts[1], "searchTerm");

        if (!searchTerm) { // navi request from Maps, we do not believe anything from it except geoLoc.
            if (!location) return undefined; // checker no.2.
            var categoryId = matchParam(parts[1], "destination-categoryId");
            var originLatitude = matchParam(parts[1], "originLatitude");
            var originLongitude = matchParam(parts[1], "originLongitude");
            var originLocation = undefined;
            if (originLatitude && originLongitude)
                originLocation = { latitude: originLatitude, longitude: originLongitude };
        }

        return {
            searchTerm: searchTerm,
            location: location,
            destinationCategoryId: categoryId,
            originLocation: originLocation
        }
    }

    function matchParam(queryString, paramName) {
        var paramRegExp = new RegExp("(?:^|&)" + paramName + "=(.*?)(?:&|$)", "g"),
            paramMatch = paramRegExp.exec(queryString);
        return paramMatch ? paramMatch[1] : null;
    }

    function stopGuidance() {
        // the user is already prompts
        if (stopNavigationDialogVisible)
            return;
        stopNavigationDialogVisible = true;
        var dialog = window.showDialog("", {
            text: qsTrId("qtn_drive_stop_navigation?_dlg"),
            affirmativeMessage: qsTrId("qtn_drive_yes_btn_short"),
            cancelMessage: qsTrId("qtn_drive_no_btn_short")
        });

        dialog.userReplied.connect(function(answer) {
            stopNavigationDialogVisible = false;
            if (answer == "ok") {
                guidanceModel.stopGuidance();
                routingModel.clearRoute();
                appModel.restartAssistance = true;

                geoUrlChanged();
            }
        });
    }

    function geoUrlChanged() {
        //Propmt user if guidance is running, otherwise execute action on geourl
        if (guidanceModel.isNavigationMode) {
            stopGuidance();
        } else {
            var geoData = application.parseGeoUrl(device.geoUrl);
            window.deleteToFirstPage();
            if (geoData) {
                application.geoUrlAction(geoData);
            } else {
                console.log("--> Invalid geoUrl to Drive. Nowhere to go.");
                // keep on AssistancePage while doing nothing
            }
        }
    }

    function resetPowersaveTimer() {
        powersaveTimer.stop();

        if (powersaveModeOn) {
            exitPowersaveMode();
        }
    }

    function enterPowersaveMode() {
        //set plugin offline
        if (MapsPlugin.online) {
            pluginWasOnline = true;
            MapsPlugin.online = false;
        } else {
            pluginWasOnline = false;
        }

        if (positioningModel && positioningModel.enabled) {
            positioningModel.enabled = false;
        }

        guidanceModel.pause();

        // Notify other components
        powersaveModeOn = true;
    }

    function exitPowersaveMode() {
        pluginWasOnline && !MapsPlugin.online && (MapsPlugin.online = true);

        if (positioningModel && !positioningModel.enabled)  {
            positioningModel.enabled = true;
            positioningModel.mapMatcherMode = PositionProvider.MAPMATCH_CAR;
        }

        guidanceModel.resume();
        powersaveModeOn = false;
    }

    // Some models will not be ready in Component.onCompleted{}
    // thus this function is necessary to be invoked again at right moment
    function _updateModels() {
        appModel = ModelFactory.getModel("AppModel");
        searchModel = ModelFactory.getModel("SearchModel");
        routingModel = ModelFactory.getModel("RoutingModel");
        guidanceModel = ModelFactory.getModel("GuidanceModel");
        voiceSkinModel = ModelFactory.getModel("VoiceSkinModel");
        appSettingsModel = ModelFactory.getModel("AppSettingsModel");
        positioningModel = ModelFactory.getModel("PositioningModel");
    }

    function _visibilityChangedHandler() {
        /*
         *     visible == true and active == true    - Application is visible and can be interacted with.
         *     visible == true and active == false   - Application is (at least partly) visible but cannot be interacted with. Some dialog on top or application is visible in the task switcher.
         *     visible == false and active == true   - This combination is not allowed.
         *     visible == false and active == false  - Application is not visible and cannot be interacted with.
         */
         if (application.windowVisible && application.windowActive) {
             device.setDisplayUpdatesEnabled(true);
         }
         else if (application.windowVisible && !application.windowActive) {
             device.setDisplayUpdatesEnabled(true);
         }
         else if (!application.windowVisible && !application.windowActive) {
             device.setDisplayUpdatesEnabled(false);
         }
    }

    Component.onCompleted: {
        _updateModels();
        device.geoUrlChanged.connect(geoUrlChanged);
    }
}
