import QtQuick 1.1
import MapsPlugin 1.0
import models 1.0
import "../models/ModelFactory.js" as ModelFactory
import "styles.js" as Style
import "FavoritesLayer.js" as JS

Item {
    id: favoritesLayer

    property variant style: Style.Favorites
    property variant mapSettingsModel
    property variant mapModel
    property variant positioningModel
    property variant favoritesModel
    property variant map
    property variant mapView  // back ref to listen to beforeMaximize signal. There seems no other way to acknowledge the minimap's movement.
    property bool favoritesVisible: false
    property variant favoriteLayer
    property bool showFadeoutIcon: true
    property int zValue: 100

    signal favoriteAddedToLayer()
    signal favoriteRemovedFromLayer()

    function setVisible(v) {
        if (favoriteLayer && favoritesVisible) {
            favoriteLayer.visible = v;
        }
    }

    function populateLayer() {
        if (!favoritesVisible) return;

        var favorites = favoritesModel.getObjects();
        for (var key in favorites) {
            var fav = favorites[key];
            addToLayer(fav);
        }
    }

    function deleteLayer() {
        if (favoriteLayer) {
            // remove all mapobjects and remove layer from map
            favoriteLayer.removeAllMapObjects();
            map.removeLayer(favoriteLayer);
            // reset the layer
            favoriteLayer.destroy();
            favoriteLayer = undefined;
        }
        JS.keyObjectMapping = {};
    }

    function addToLayer(fav) {
        if (fav) {
            // only add favorite to map if we have a position
            var pos = fav.storeObjectProperties.position;
            if (pos) {
                var coords = positioningModel.createGeoCoordinates(pos);
                var category = favoritesModel.getTypeFromCategory(fav.categories);
                var icon = "../" + favoritesModel.getIconPath(category, "map");
                var mapIcon = mapModel.addIcon(coords, map, favoriteLayer, icon, Qt.point(36, 60));
                coords.destroy();

                // do mapping of favorite key <-> map object ID
                JS.keyObjectMapping[fav.key] = mapIcon;
                favoriteAddedToLayer();
            }
        }
    }

    function removeFromLayer(fav) {
        if (fav) {
            var icon = JS.keyObjectMapping[fav.key];
            if (icon) {
                var removed = favoriteLayer.removeMapObject(icon);
                if (removed) {
                    delete JS.keyObjectMapping[fav.key];
                    favoriteRemovedFromLayer();
                }
            }
        }
    }

    function onMapSettingsChanged() {
        if (favoritesVisible !== mapSettingsModel.favoritesVisible) {
            favoritesVisible = mapSettingsModel.favoritesVisible;
            if (favoritesVisible) {
                favoriteLayer = mapModel.addLayer(map);
                favoriteLayer.zIndex = zValue;
                populateLayer();
            }
            else {
                deleteLayer();
            }
        }
    }

    function onFavoritesSynchronized() {
        if (favoritesVisible) {
            deleteLayer();
            favoriteLayer = mapModel.addLayer(map);
            favoriteLayer.zIndex = zValue;
            populateLayer();
        }
    }

    function onFavoriteAdded(fav) {
        if (fav) {
            if (favoritesVisible) {
                addToLayer(fav);
            }
            else  if (showFadeoutIcon) {
                // if layer not visible then show favorite and fade out
                var pos = fav.storeObjectProperties.position;
                if (pos) {
                    var category = favoritesModel.getTypeFromCategory(fav.categories);
                    var icon = "../" + favoritesModel.getIconPath(category, "map");
                    fadeoutIcon.fadeout(icon, pos);
                }
            }
        }
    }

    function onFavoriteRemoved(fav) {
        if (favoritesVisible && fav) {
            removeFromLayer(fav);
        }
    }

    Timer {
        id: internal
        interval: 20
        repeat: false
        property variant key
        function hideIcon(key) {
            internal.key = key
            internal.start();
        }
        onTriggered: {
            var icon = JS.keyObjectMapping[internal.key];
            if (icon) icon.visible = false;
        }
    }

    function hideFavoriteIcon(key, delayed) {
        if (key && favoritesVisible) {
            if (delayed) {
                internal.hideIcon(key);
            }
            else {
                var icon = JS.keyObjectMapping[key];
                if (icon) icon.visible = false;
            }
        }
    }

    function showFavoriteIcon(key) {
        if (key) {
            var icon = JS.keyObjectMapping[key];
            if (icon) {
                icon.visible = true;
            }
        }
    }

    function isFavorite(mapObjectId) {
        for (var key in JS.keyObjectMapping) {
            if (JS.keyObjectMapping[key].id == mapObjectId) {
                return true;
            }
        }
        return false;
    }

    function getFavoriteFromMapObjectId(mapObjectId) {
        for (var key in JS.keyObjectMapping) {
            if (JS.keyObjectMapping[key].id == mapObjectId) {
                var favs = favoritesModel.getObjects();
                return favs[key];
            }
        }
        return undefined;
    }

    Image {
        id: fadeoutIcon
        visible: false
        width: 72
        height: 65

        function fadeout(image, pos) {
            var location = positioningModel.createGeoCoordinates(pos);
            if (!location) return;
            animationTimer.stop();

            fadeoutIcon.source = image;
            fadeoutIcon.opacity = 1;
            var pixelCoords = map.geoToScreen(location, true);
            location.destroy();
            fadeoutIcon.x = pixelCoords.x - 36; // subtract anchorpoint
            fadeoutIcon.y = pixelCoords.y - 62; // subtract anchorpoint
            fadeoutIcon.visible = true;
            animationTimer.start();
        }

        function hideNow() {
            if (fadeoutIcon.visible) {
                animationTimer.stop();
                animation.complete();
                fadeoutIcon.visible = false;
            }
        }

        Connections { target: map; onMouseDown: fadeoutIcon.hideNow() }
        Connections { target: mapView; onBeforeMaximized: fadeoutIcon.hideNow() }

        Timer {
            id: animationTimer
            interval: 600
            onTriggered: animation.start();
        }

        SequentialAnimation {
            id: animation
            PropertyAnimation { target: fadeoutIcon; property: "opacity"; to: 0; duration: 400; }
            ScriptAction { script: fadeoutIcon.visible = false; }
        }
    }

    // maybe there is better way to wait until share is available
    Timer {
        id: initalizeTimer
        interval: 1000
        repeat: false
        onTriggered: populateLayer()
    }

    Component.onCompleted: {
        mapSettingsModel = ModelFactory.getModel("MapSettingsModel");
        mapModel = ModelFactory.getModel("MapModel");
        positioningModel = ModelFactory.getModel("PositioningModel");
        favoritesModel = ModelFactory.getModel("FavoritesModel");

        favoritesVisible = mapSettingsModel.favoritesVisible;
        mapSettingsModel.settingsChanged.connect(onMapSettingsChanged);
        favoritesModel.favoriteAdded.connect(onFavoriteAdded);
        favoritesModel.favoriteRemoved.connect(onFavoriteRemoved);
        favoritesModel.favoritesSynchronized.connect(onFavoritesSynchronized);

        if (favoritesVisible) {
            favoriteLayer = mapModel.addLayer(map);
            favoriteLayer.zIndex = zValue;

            if (!favoritesModel.shareReady) {
                var onShareReady = function() {
                    favoritesModel.share.initialized.disconnect(onShareReady);
                    favoritesModel.shareReady = true;
                    initalizeTimer.start();
                }
                favoritesModel.share.initialized.connect(onShareReady);
            }
            else {
                populateLayer();
            }
        }
    }

    Component.onDestruction: {
        mapSettingsModel.settingsChanged.disconnect(onMapSettingsChanged);
        favoritesModel.favoriteAdded.disconnect(onFavoriteAdded);
        favoritesModel.favoriteRemoved.disconnect(onFavoriteRemoved);
        favoritesModel.favoritesSynchronized.disconnect(onFavoritesSynchronized);
        deleteLayer();
    }
}
