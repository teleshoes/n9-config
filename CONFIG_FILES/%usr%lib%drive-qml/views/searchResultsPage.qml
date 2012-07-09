import QtQuick 1.1
import MapsPlugin 1.0
import components 1.0
import models 1.0
import "../utils/SearchResults.js" as SearchResults
import "../components/components.js" as Components
import "../models/ModelFactory.js" as ModelFactory

Page {
    id: page
    tag: "searchResultsPage"

    property variant appModel
    property variant mapModel
    property variant searchModel
    property variant positioningModel
    property variant appSettingsModel
    property bool pickingLocation: false
    property variant favoritesModel
    property variant mapSettingsModel
    property variant searchIconLayer

    onPickingLocationChanged: {
        // show the fading out favorite icon if user is picking location
        minimap.favoritesLayer.showFadeoutIcon = pickingLocation;
    }

    states: [
        State {
            name: "landscape"
            when: page.isLandscape
            // list browser
            PropertyChanges {
                target: listBrowser
                width: page.width * 0.5
                height: page.height
            }
            AnchorChanges {
                target: listBrowser
                anchors.top: page.top
                anchors.left: page.left
            }

            // map
            PropertyChanges {
                target: minimap.mini
                width: page.width * 0.5
                height: page.height
                top: page.top
                right: page.right
            }
        },
        State {
            name: "portrait"
            when: !page.isLandscape
            // list browser
            PropertyChanges {
                target: listBrowser
                width: page.width
                height: page.height * 0.5
            }
            AnchorChanges {
                target: listBrowser
                anchors.bottom: page.bottom
                anchors.left: page.left
            }

            // map
            PropertyChanges {
                target: minimap.mini
                width: page.width
                height: page.height * 0.5
                top: page.top
                left: page.left
            }
        }
    ]

    MiniMap {
        id: minimap
        positionObjectVisible: true
        handleFavoriteClicked: false

        onLongTapped: {
            page.pickingLocation = true;
        }
        onLocationMarkerClicked: {
            page.pickingLocation = true;
        }
        onBeforeMaximized: {
            listBrowser.visible = false;
        }
        onMapMinimized: {
            listBrowser.visible = !pickLocationDialogVisible;
        }
    }

    // settings button
    MapIcon {
        id: settingsButton
        type: "settings"
        visible: !minimap.pickingLocation && !minimap.pickLocationDialogVisible && minimap.isReallyMaximized
        anchors.right: minimap.right
        anchors.bottom: minimap.bottom
        anchors.rightMargin: Components.MapControls.margins.right
        anchors.bottomMargin: Components.MapControls.margins.bottom
        onClicked: {
            var currentPage = window.getCurrentPage();
            currentPage.onMenuButtonClicked && currentPage.onMenuButtonClicked()
        }
    }

    ListModel { id: resultsModel }

    ListBrowser {
        id: listBrowser
        isLandscape: page.isLandscape
        listItemName: "SearchResultListItem"

        dataModel: resultsModel
        onClick: {
            minimap.map.moveTo(resultsModel.get(choice).geoCoordinates,
                               Map.ANIMATION_BOW,
                               resultsModel.get(choice).zoomScale,
                               Map.PRESERVE_ORIENTATION,
                               Map.PRESERVE_PERSPECTIVE);
        }

        onCurrentIndexChanged: {
            var selection = resultsModel.get(currentIndex);
            uncoverCurrentIcon();
            polishAddressToButton(selection);
        }

        Button {
            id: driveButton
            anchors.bottom: listBrowser.bottom
            anchors.bottomMargin: 30
            anchors.left: parent.left
            anchors.leftMargin: page.isLandscape ? 22 : 40
            anchors.right: parent.right
            anchors.rightMargin: page.isLandscape ? 22 : 40
            property variant address
            text: appModel.homeFlowFlag ? qsTrId("qtn_drive_set_as_home_btn")
                                        : qsTrId("qtn_drive_drive_to_btn")

            onClicked: {
                // only fetch address when currentIndex did not update ever.
                // This happens when no change on address selection.
                // Notice that the time delay wont work in this situation.
                if (!address) {
                    var selection = listBrowser.dataModel.get(listBrowser.currentIndex);
                    polishAddressToButton(selection);
                }

                if (appModel.homeFlowFlag) {
                    var dialog = window.showDialog("DefineHome", {
                        address: address,
                        setting: appModel.homeFlowFlag == "setting", // hide hint line when in setting.
                        columnLayout: false
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
                        } else if (appModel.homeFlowFlag == "setting") { // user says NO.
                            toSettings();
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

    function polishAddressToButton(address) {
        var newAddress = {
            address1: address.address1,
            address2: "",
            detailAddress2: address.detailAddress2 || "",
            detailAddress3: address.detailAddress3 || "",
            location: address.location,
            iconUrlList: address.iconUrlList,
            iconUrlMap: address.iconUrlMap
        };
        driveButton.address = newAddress; // ensure address wont be undefined whenever.

        // a place for unit test
        // newAddress.address1 = '';

        if (!newAddress.address1) {
            _retreiveAddress(newAddress.location, newAddress);
        }
    }

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

            driveButton.address = address;
        }

        searchModel.reverseGeocodingDone.connect(_onReverseGeoCodingDone);
        searchModel.reverseGeocode(location, searchOnline);
    }

    function onMenuButtonClicked() {
        window.push("settings/mapPreviewSettingsPage.qml", {
            popOnSchemeChange: true,
            invokingPage: page.tag
        });
    }

    function onNavigateButtonClicked() {
        if (page.pickingLocation) {
            if (minimap.pickLocationDialogVisible || !minimap.pickMarker.visible) {
                if (!minimap.pickMarker.visible) {
                    page.pickingLocation = false;
                    minimap.minimizeMap();
                    var item = listBrowser.dataModel.get(listBrowser.currentIndex);
                    minimap.map.moveTo(item.geoCoordinates, Map.ANIMATION_BOW, item.zoomScale,
                                       Map.PRESERVE_ORIENTATION, Map.PRESERVE_PERSPECTIVE);
                    return false;
                }
                else {
                    page.pickingLocation = false;
                    minimap.pickMarker.visible = false;
                    minimap.minimizeMap();
                }
            }
            else {
                minimap.moveTo(minimap.pickMarker.geoCoordinates, Map.ANIMATION_LINEAR);
                minimap.minimizeMap();
                minimap.showPickDialog();
                return false;
            }
        }
        else if (minimap.isMaximized) {
            minimap.minimizeMap();
            var currentListItem = listBrowser.dataModel.get(listBrowser.currentIndex);
            minimap.map.moveTo(currentListItem.geoCoordinates, Map.ANIMATION_BOW, currentListItem.zoomScale,
                               Map.PRESERVE_ORIENTATION, Map.PRESERVE_PERSPECTIVE);
            return false;
        }
    }

    Component.onCompleted: {
        appModel = ModelFactory.getModel("AppModel");
        mapModel = ModelFactory.getModel("MapModel");
        searchModel = ModelFactory.getModel("SearchModel");
        favoritesModel = ModelFactory.getModel("FavoritesModel");
        positioningModel = ModelFactory.getModel("PositioningModel");
        appSettingsModel = ModelFactory.getModel("AppSettingsModel");
        mapSettingsModel = ModelFactory.getModel("MapSettingsModel");

        minimap.favoritesLayer.showFadeoutIcon = false;
    }

    Connections {
        ignoreUnknownSignals: true
        target: favoritesModel
        onFavoriteAdded: onFavoriteAdded(favorite)
        onFavoriteRemoved: onFavoriteRemoved(favorite)
    }

    onBeforeShow: {
        //Setup map & page menu button
        minimap.initializeMap();
        minimap.setTransitionMap();
        minimap.hide();
    }

    onShow: {
        minimap.resetTransitionMap();


        if (firstShow) {
            var searchResults = SearchResults.results;
            //Show result text and the selected result icon
            //listBrowser.dataModel = params.results;

            listBrowser.arrowsVisible = searchResults.length > 1;

            searchResults[params.selectedIndex].geoCoordinates =
                    positioningModel.createGeoCoordinates(searchResults[params.selectedIndex].location, page);
            minimap.map.moveTo(searchResults[params.selectedIndex].geoCoordinates,
                               Map.ANIMATION_NONE,
                               searchResults[params.selectedIndex].zoomScale,
                               Map.PRESERVE_ORIENTATION,
                               Map.PRESERVE_PERSPECTIVE);

            //Add icons
            var layer = mapModel.addLayer(minimap.map);
            var result, icon;
            searchIconLayer = layer;
            searchIconLayer.zIndex = minimap.favoritesLayer.zValue+1;
            for (var i = 0, il = searchResults.length; i < il; ++i) {
                result = searchResults[i];

                result.geoCoordinates = positioningModel.createGeoCoordinates(result.location, page);
                resultsModel.append(result);
                icon = mapModel.addIcon(result.geoCoordinates, minimap.map, layer, result.iconUrlMap, Qt.point(36, 60));
                resultsModel.setProperty(i, "iconId", icon.id);
                searchResults[i].iconId = icon.id;
                SearchResults.mapIcons["" + icon.id] = i;

                // hide search the corresponding favorite icon from FavoritesLayer
                if (result.isFavorite && mapSettingsModel.favoritesVisible) {
                    minimap.favoritesLayer.hideFavoriteIcon(result.favoriteKey, false);
                }
            }
            listBrowser.setCurrentIndex(params.selectedIndex);
            uncoverCurrentIcon();
        }
        minimap.show();
    }

    Connections {
        target: minimap.map
        onMapObjectsSelected: {
            // objects are not clickable in minimap
            if (!minimap.isReallyMaximized) return;

            var index = SearchResults.mapIcons[mapObject.id];
            if (index > 0 || index === 0) {
                if (page.pickingLocation) {
                    page.pickingLocation = false;
                }

                listBrowser.setCurrentIndex(index);
                uncoverCurrentIcon();
                var selectedListItem = listBrowser.dataModel.get(index);
                minimap.map.moveTo(selectedListItem.geoCoordinates,
                                   Map.ANIMATION_BOW, selectedListItem.zoomScale,
                                   Map.PRESERVE_ORIENTATION,
                                   Map.PRESERVE_PERSPECTIVE);
                minimap.minimizeMap();
            }
            else if (mapObject.type === MapObject.MAPICON && minimap.favoritesLayer.isFavorite(mapObject.id)) {
                // A favorite was clicked which is not part of search results
                var fav = minimap.favoritesLayer.getFavoriteFromMapObjectId(mapObject.id);
                if (fav) {
                    minimap.showFavorite(fav);
                }
            }
        }
    }

    onBeforeHide: {
        minimap.setTransitionMap();
        minimap.stopMapAnimation();
        minimap.hide();
    }

    function uncoverCurrentIcon() {
        if (!listBrowser.visible) return;

        var mapObjects = searchIconLayer.mapObjects;
        var len = mapObjects.length;
        if (len < 2) return;

        var id = listBrowser.dataModel.get(listBrowser.currentIndex).iconId;
        for (var i = 0; i < len; ++i) {
            // a js trick to convert boolean to integer
            mapObjects[i].zIndex = +(mapObjects[i].id == id);
        }
    }

    function onFavoriteAdded(fav) {
        // If list browser is not visible,
        // favorite was added from pick from map. Make sure we don't handle it here.
        if (!listBrowser.visible) return;

        var index = listBrowser.currentIndex,
            item = listBrowser.dataModel.get(index),
            mapObjects = searchIconLayer.mapObjects;

        // remove search icon
        for (var i = 0, il = mapObjects.length; i < il; ++i) {
            if (mapObjects[i].id === item.iconId) {
                searchIconLayer.removeMapObject(mapObjects[i]);
                delete SearchResults[item.iconId];
                break;
            }
        }

        // add new search icon with favorite star
        var cat = favoritesModel.getTypeFromCategory(fav.categories),
            iconPath = "../" + favoritesModel.getIconPath(cat, "map");
        var icon = mapModel.addIcon(item.geoCoordinates, minimap.map, searchIconLayer, iconPath, Qt.point(36, 60));
        resultsModel.setProperty(index, "iconUrlMap", iconPath);
        resultsModel.setProperty(index, "iconId", icon.id);
        resultsModel.setProperty(index, "isFavorite", true);
        resultsModel.setProperty(index, "favoriteKey", fav.key);

        var searchResults = SearchResults.results;
        searchResults[index].iconUrlMap = iconPath;
        searchResults[index].iconId = icon.id;
        searchResults[index].isFavorite = true;
        searchResults[index].favoriteKey = fav.key;
        SearchResults.mapIcons["" + icon.id] = index;
        if (mapSettingsModel.favoritesVisible) {
            minimap.favoritesLayer.hideFavoriteIcon(fav.key, true);
        }
    }

    function onFavoriteRemoved(fav) {
        // If list browser is not visible,
        // favorite was removed from pick from map. Make sure we don't handle it here.
        if (!listBrowser.visible) return;

        var index = listBrowser.currentIndex,
            item = listBrowser.dataModel.get(index),
            mapObjects = searchIconLayer.mapObjects;

        // remove favorite search icon
        for (var i=0; i<mapObjects.length; i++) {
            if (mapObjects[i].id === item.iconId) {
                searchIconLayer.removeMapObject(mapObjects[i]);
                delete SearchResults[item.iconId];
                break;
            }
        }

        // add new search icon with favorite star
        var cat = favoritesModel.getTypeFromCategory(fav.categories),
            iconPath = "../" + favoritesModel.getIconPath(cat, "map");
        iconPath = iconPath.replace("_fav.png", ".png");
        var icon = mapModel.addIcon(item.geoCoordinates, minimap.map, searchIconLayer, iconPath, Qt.point(36, 60));
        resultsModel.setProperty(index, "iconUrlMap", iconPath);
        resultsModel.setProperty(index, "iconId", icon.id);
        resultsModel.setProperty(index, "isFavorite", false);
        resultsModel.setProperty(index, "favoriteKey", undefined);

        var searchResults = SearchResults.results;
        searchResults[index].iconUrlMap = iconPath;
        searchResults[index].iconId = icon.id;
        searchResults[index].isFavorite = false;
        searchResults[index].favoriteKey = undefined;
        SearchResults.mapIcons["" + icon.id] = index;
    }

    Component.onDestruction: {
        searchModel.reverseGeocodingDone.disconnect();

        if (searchIconLayer) {
            searchIconLayer.removeAllMapObjects();
            minimap.map.removeLayer(searchIconLayer);
        }
    }
}

