import QtQuick 1.1
import MapsPlugin 1.0
import components 1.0
import "../components/components.js" as Components
import "../utils/Units.js" as Units
import "../models/ModelFactory.js" as ModelFactory

Page {
    id: page
    tag: "recentsPage"
    title: qsTrId("qtn_drive_last_destinations_hdr")
    scrollableList: list

    property variant appModel
    property variant mapModel
    property variant recentsModel
    property variant positioningModel
    property variant appSettingsModel
    property variant favoritesModel

    ListModel { id: listModel }

    List {
        id: list
        anchors.top: titleBottom
        width: parent.width
        height: parent.height - titleBox.height

        listModel: listModel
        delegate: Component { AddressItem{} }
        listItemHeight: 130
        menuStyle: false

        onItemClicked: {
            var address = listModel.get(index);
            if (appModel.homeFlowFlag) {
                var dialog = window.showDialog("DefineHome", {
                    address: address,
                    setting: appModel.homeFlowFlag == "setting", // hide hint line when in setting.
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
                    } else {  // user says NO.
                        if (appModel.homeFlowFlag == "setting") {
                            toSettings();
                        }
                    }
                });
            } else {
                toRoutePreview(address);
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

    onBeforeShow: {
        if (firstShow) populateRecentsList();
    }

    function populateRecentsList() {
        var position = positioningModel.getPositionSnapshot(page) || mapModel.center;
        var recents = recentsModel.getDestinations();
        for (var i = 0, len = recents.length; i < len; ++i) {
            var recent = recents[i];
            var destPosition = positioningModel.createGeoCoordinates(recent.location, page);
            var distance = Units.getReadableDistanceVisual(position.distance(destPosition));
            recent.distance = distance.value + distance.unit;

            var favorites = favoritesModel.getObjects();
            var favoriteKey = favoritesModel.getFavoriteKey(undefined, destPosition);
            var favorite = favorites[favoriteKey];
            if (favoriteKey !== undefined) {
                var category = favoritesModel.getTypeFromCategory(favorite.categories);
                recent.iconUrlList = "../" + favoritesModel.getIconPath(category, "list");
                // Fix favorites name & address
                recent.address1 = favorite.text;
                var addressLines = favoritesModel.getFormattedAddress(favorite);
                recent.address2 = addressLines ? addressLines[0] : "";
                recent.detailAddress2 = addressLines ? addressLines[1] : "";
                recent.detailAddress3 = addressLines ? addressLines[2] : "";
            }

            listModel.append(recent);
        }
    }

    Component.onCompleted: {
        appModel = ModelFactory.getModel("AppModel");
        mapModel = ModelFactory.getModel("MapModel");
        recentsModel = ModelFactory.getModel("RecentsModel");
        positioningModel = ModelFactory.getModel("PositioningModel");
        appSettingsModel = ModelFactory.getModel("AppSettingsModel");
        favoritesModel = modelFactory.getModel("FavoritesModel");
    }
}
