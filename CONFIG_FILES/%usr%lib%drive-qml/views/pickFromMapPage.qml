import Qt 4.7
import MapsPlugin 1.0
import components 1.0
import models 1.0
import "../components/components.js" as Components
import "../components/styles.js" as Style

Page {
    id: page
    tag: "pickFromMapPage"

    property variant positioningModel: modelFactory.getModel("PositioningModel")
    property variant finder: modelFactory.getModel("SearchModel")
    property variant trackingHelper: modelFactory.getModel("TrackingHelper");
    property bool longTapInProgress: false
    property bool mapInteractionMode: false

    MiniMap {
        id: minimap
        controlMargins.top: searchBox.visible ? searchBox.height : 0
        positionObjectVisible: true        

        onLongTapped: {
            page.longTapInProgress = true;
        }
        onLocationMarkerClicked: {
            page.longTapInProgress = true;
        }
    }

    MapIcon {
        id: settingsButton
        type: "settings"
        anchors.right: minimap.right
        anchors.bottom: minimap.bottom
        visible: !minimap.pickingLocation && !minimap.pickLocationDialogVisible && minimap.isReallyMaximized
        anchors.rightMargin: Components.MapControls.margins.right
        anchors.bottomMargin: Components.MapControls.margins.bottom
        onClicked: {
            window.push("settings/mapPreviewSettingsPage.qml", {
                popOnSchemeChange: true,
                invokingPage: page.tag
            });
        }
    }

    SearchBox {
        id: searchBox
        anchors.top: parent.top
        width: page.width
        inputFocus: false
        height: 100
        visible: !minimap.pickingLocation && !minimap.pickLocationDialogVisible && !longTapInProgress
        state: "hasText"
        MouseArea {
            anchors.fill: parent
            onClicked: {
                window.push("searchPage.qml", {
                    invokingPage: page.tag
                },
                true);
            }
        }
        function updateSearchText(results) {
            if (results && results[0]) { 
                var text = "";
                if (results[0].detailAddress2 == results[0].address2) {
                    text = results[0].address1;
                    if (results[0].address2) {
                        text += ", " + results[0].address2;
                    }
                } else {
                    text = results[0].detailAddress3;
                }
                searchBox.text = text;
            }
        }
    }

    onBeforeShow: {
        minimap.initializeMap();
        minimap.setTransitionMap();
        minimap.hide();

        if (!minimap.pickLocationDialogVisible && !minimap.pickMarker.visible) {
            minimap.maximizeMap();
            minimap.map.center = positioningModel.getReferencePosition();
        }
        else {
            minimap.map.center = minimap.pickMarker.geoCoordinates;
        }

        window.actionBar.width = page.isLandscape ? Style.ActionBar.width : page.width;
        window.actionBar.height = page.isLandscape ? page.height : Style.ActionBar.width;
        window.actionBar.pageOffset = page.isLandscape ? Style.ActionBar.width : 0;
        window.actionBar.visible = true;
    }

    onShow: {
        minimap.map.userInteractionChanged.connect(onUserMapInteraction);
        minimap.resetTransitionMap();
        minimap.show();
        startSearch(minimap.map.center);
    }

    onBeforeHide: {
        minimap.map.userInteractionChanged.disconnect(onUserMapInteraction);
        minimap.setTransitionMap();
        minimap.stopMapAnimation();
        minimap.hide();
    }

    function onUserMapInteraction() {
        if (!mapInteractionMode) {
            mapInteractionMode = true;
        }
    }

    function startSearch(geoPos) {
        finder.searchDone.connect(searchAfterPress);
        finder.positionToName(geoPos);
    }

    function searchAfterPress(errorCode, results) {
        searchBox.updateSearchText(results);
        finder.searchDone.disconnect(searchAfterPress);
    }

    function onNavigateButtonClicked() {
        var onMapMoveDone = function() {
            minimap.map.animationDone.disconnect(onMapMoveDone);
            startSearch(minimap.map.center);
        }

        if (minimap.pickLocationDialogVisible || (longTapInProgress && !minimap.pickMarker.visible)) {
            minimap.maximizeMap();
            mapInteractionMode = longTapInProgress = false;

            minimap.map.animationDone.connect(onMapMoveDone);
            minimap.moveTo(positioningModel.getReferencePosition(), Map.ANIMATION_BOW);
            return false;
        }
        else if (longTapInProgress) {
            minimap.moveTo(minimap.pickMarker.geoCoordinates, Map.ANIMATION_LINEAR);
            minimap.minimizeMap();
            minimap.showPickDialog();
            return false;
        }
        else if (mapInteractionMode) {
            mapInteractionMode = false;

            minimap.map.animationDone.connect(onMapMoveDone);
            minimap.moveTo(positioningModel.getReferencePosition(), Map.ANIMATION_BOW);
            return false;
        }
        else {
            minimap.pickMarker.visible = mapInteractionMode = longTapInProgress = false;
        }
    }

    Connections {
        target: minimap.map
        onMouseDown: {
            startSearch(geoPos);
        }
    }

 }
