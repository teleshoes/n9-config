import QtQuick 1.1
import MapsPlugin 1.0


QtObject {
    property variant center
    property variant currentMiniMap

    function addLayer(map) {
        var mapLayer = Qt.createQmlObject("import MapsPlugin 1.0; MapLayer {}", map, null);
        map.addLayer(mapLayer);

        return mapLayer;
    }

    function addIcon(coordinates, map, layer, iconPath, anchorPoint) {
        var mapIcon = Qt.createQmlObject("import MapsPlugin 1.0; MapIcon {}", map, null),
            icon = Qt.createQmlObject("import MapsPlugin 1.0; Icon {}", map, null),
            location = mapIcon.location;

        icon.localUrl = Qt.resolvedUrl(iconPath);
        mapIcon.icon = icon;
        location.geoCoordinates = coordinates;
        mapIcon.location = location;
        anchorPoint && (mapIcon.anchorPoint = anchorPoint);
        layer.addMapObject(mapIcon);

        return mapIcon;
    }

    function removeIcon(layer, icon) {
        layer.removeMapObject(icon);
    }

    function applySettings(map, settings, force2D) {
        //Set scheme and landmarks
        map.scheme != settings.scheme && (map.scheme = settings.mapScheme);
        map.landmarksVisible != settings.landmarksVisible && (map.landmarksVisible = settings.landmarksVisible);

        //Set perspective and apply POIs
        force2D = force2D || settings.sateliteMode;
        var newPerspective = (force2D ? "2D" : settings.perspective);
        setPerspective(map, newPerspective);
        applyPoiSettings(map, settings);
    }

    function applyPoiSettings(map, settings) {
        var poiCategories = settings.getPoiCategories();
        for (var i = 0, len = poiCategories.length; i < len; i++) {
            var category = poiCategories[i];
            if (category.turnOn != map.isPoiCategoryVisible(category.id)) {
                map.showPoiCategory(category.id, category.turnOn);
            }
        }
    }

    function setPerspective(map, perspective) {
        var angle = (perspective == "2D" ? 0 : 62);
        map.perspective != angle && (map.perspective = angle);
    }

    function setCurrentMinimap(minimap) {
        currentMiniMap && currentMiniMap.beforeDestruction.disconnect(onMapDestroyed);
        currentMiniMap = minimap;
        currentMiniMap.beforeDestruction.connect(onMapDestroyed);
    }

    function onMapDestroyed() {
        currentMiniMap.map.saveState("drive.mapState");
    }
}
