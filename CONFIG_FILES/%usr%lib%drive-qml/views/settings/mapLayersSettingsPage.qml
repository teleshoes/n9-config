import QtQuick 1.1
import components 1.0
import "../../models/ModelFactory.js" as ModelFactory
import "../../components/components.js" as Components

Page {
    id: page

    title: qsTrId("qtn_drive_map_layers_hdr")
    tag: "mapLayersSettingsPage"
    scrollableList: list

    property variant mapSettingsModel

    VisualItemModel {
        id: listModel

        ButtonItem  {
            id: landmarks
            itemId: "landmarks"
            title: qsTrId("qtn_drive_landmarks_item")
            iconUrl: "../../resources/listitems/landmarks.png"
            checkable: true
            style: Components.CheckBox
            onClicked: mapSettingsModel.setLandmarksVisible(checked)
        }

        ButtonItem  {
            id: favorites
            itemId: "favorites"
            title: qsTrId("qtn_drive_favourites_item")
            iconUrl: "../../resources/listitems/favorites.png"
            checkable: true
            style: Components.CheckBox
            onClicked: mapSettingsModel.setFavoritesVisible(checked)
        }

        ButtonItem {
            id: places
            itemId: "places"
            title: qsTrId("qtn_drive_places_item")
            iconUrl:  "../../resources/listitems/places.png"
        }
    }

    List {
        id: list
        listModel: listModel
        anchors.top: titleBottom
        width: parent.width
        height: parent.height - titleBox.height

        onItemClicked: {
            var targetPage,
                invokingPage = page.tag;

            switch (itemId) {
                case "places":
                    targetPage = "settings/placesSettingsPage.qml";
                    break;
            }

            targetPage && window.push(targetPage, {
                invokingPage: invokingPage
            });
        }
    }

    function getSelectedPlaces(allPoiCategories) {
        var ret = [], poi = null;
        for (var i = 0, il = allPoiCategories.length; i < il; i ++) {
            (poi = allPoiCategories[i]) && (poi.turnOn === true) && ret.push(poi.categoryTitle);
        }

        return ret.join(", ");
    }

    onBeforeShow: {
        landmarks.buttonChecked = mapSettingsModel.landmarksVisible;
        places.subtitle = getSelectedPlaces(mapSettingsModel.getPoiCategories());
        favorites.buttonChecked = mapSettingsModel.favoritesVisible;
    }

    Component.onCompleted: {
        mapSettingsModel = modelFactory.getModel("MapSettingsModel");
    }
}
