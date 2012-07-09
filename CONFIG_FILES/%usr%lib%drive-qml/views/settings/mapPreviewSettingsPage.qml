import QtQuick 1.1
import components 1.0
import "../../components/components.js" as Components
import models 1.0


Page {
    id: page
    title: qsTrId("qtn_drive_map_options_hdr")
    scrollableList: buttonList

    property variant mapSettingsModel
    property variant titles: {
        map_mode: qsTrId("qtn_drive_day_night_item"),
        landmarks: qsTrId("qtn_drive_landmarks_item"),
        favorites: qsTrId("qtn_drive_favourites_item"),
        places: qsTrId("qtn_drive_places_item")
    }
    property variant subtitles: {
        map_mode: mapSettingsModel ? qsTrId("qtn_drive_" + mapSettingsModel.dayNightMode + "_subitem") : "",
        places: getPlaces()
    }
    property variant icons: {
        map_mode: mapSettingsModel ? mapSettingsModel.dayNightMode + "mode" : "",
        landmarks: "landmarks",
        favorites: "favorites",
        places: "places"
    }

    Component {
        id: mapModeSwitch
        MapModeSwitch {
            onItemSelected: page.params.popOnSchemeChange && window.pop()
        }
    }

    Component {
        id: perspectiveSwitch
        MapPerspectiveSwitch {
            onItemSelected: page.params.popOnSchemeChange && window.pop()
        }
    }

    ListModel {
        id: buttonModel
        ListElement { _itemId: "map_mode"; _targetPage: "settings/mapModeSettingsPage.qml" }
        ListElement { _itemId: "landmarks"; _checkable: true; _checked: false }
        ListElement { _itemId: "favorites"; _checkable: true; _checked: false }
        ListElement { _itemId: "places"; _targetPage: "settings/placesSettingsPage.qml" }

        function indexById(str) {
            for(var i = 0, j = buttonModel.count; i < j; ++i) {
                if (buttonModel.get(i)._itemId == str) break;
            }
            return i < j ? i : -1;
        }

        function getChecked(str) {
            var index = indexById(str);
            return (index != -1) ? get(index)._checked : undefined;
        }

        function updateChecked(str, value) {
            var index = indexById(str);
            if (index != -1) get(index)._checked = value;
        }
    }

    List {
        id: buttonList
        anchors.top: titleBottom
        width: parent.width
        height: parent.height - titleBox.height
        header: page.params.navigationViewMode ? perspectiveSwitch : mapModeSwitch
        listModel: buttonModel
        delegate: ButtonItem {
            itemId: _itemId
            title: titles[_itemId]
            subtitle: _itemId in subtitles ? subtitles[_itemId] : ""
            iconUrl: icons[_itemId] ? "../../resources/listitems/{*}.png".replace('{*}', icons[_itemId]) : ""
            checkable: !!_checkable
            buttonChecked: !!_checked
            targetPage: _targetPage || ""
            style: checkable ? Components.CheckBox : null
            onClicked: { if (checkable) buttonModel.updateChecked(_itemId, checked); }
        }

        onItemClicked: {
            if (itemId == "landmarks") {
                mapSettingsModel.setLandmarksVisible(buttonModel.getChecked("landmarks"));
            } else if (itemId == "favorites") {
                mapSettingsModel.setFavoritesVisible(buttonModel.getChecked("favorites"));
            }

            if (!itemArgs.targetPage) {
                window.pop(params.invokingPage);
            } else {
                window.push(itemArgs.targetPage, { invokingPage: params.invokingPage });
            }
        }
    }

    function getPlaces() {
        var pois = mapSettingsModel.getPoiCategories();
        var ret = [];
        for (var poi, i = 0, il = pois.length; i < il; ++i) {
            poi = pois[i];
            if (poi && poi.turnOn === true) ret.push(poi.categoryTitle);
        }
        return ret.join(", ");
    }

    onBeforeShow: {
        buttonModel.updateChecked("landmarks", mapSettingsModel.landmarksVisible);
        buttonModel.updateChecked("favorites", mapSettingsModel.favoritesVisible);
    }

    Component.onCompleted: {
        mapSettingsModel = modelFactory.getModel("MapSettingsModel");
    }
}
