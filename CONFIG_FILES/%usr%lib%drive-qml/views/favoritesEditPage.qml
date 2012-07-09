import QtQuick 1.1
import components 1.0
import "../utils/Units.js" as Units
import "../components/styles.js" as Styles

Page {
    id: favoritesEditPage
    title: qsTrId("qtn_drive_edit_favourites_hdr")
    scrollableList: list

    property variant style: Styles.Favorites
    property variant mapModel
    property variant favoritesModel
    property variant positioningModel

    ListModel { id: listModel }

    List {
        id: list
        anchors.top: titleBox.bottom
        width: parent.width
        height: parent.height - titleBox.height
        listItemHeight: 130
        menuStyle: false

        delegate: AddressItem {}
        listModel: listModel

        onItemClicked: {
            var favoriteItem = listModel.get(index);

            window.push("favoritesDetailsPage.qml", {
                invokingPage: "favoritesEditPage",
                favoriteKey: favoriteItem.favoriteObject.key,
                address1: favoriteItem.address1,
                address2: favoriteItem.address2,
                iconUrlList: favoriteItem.iconUrlList,
                modificationDate: Qt.formatDateTime(favoriteItem.favoriteObject.modificationDate, "dd.MM.yyyy")
            });
        }
    }

    onBeforeShow: {
        populateFavoritesList();
    }

    Connections {
        ignoreUnknownSignals: true
        target: favoritesModel
        onFavoritesUpdated: populateFavoritesList()
    }

    Component.onCompleted: {
        mapModel = modelFactory.getModel("MapModel");
        favoritesModel = modelFactory.getModel("FavoritesModel");
        positioningModel = modelFactory.getModel("PositioningModel");
    }

    function populateFavoritesList() {
        var position = positioningModel.getPositionSnapshot() || mapModel.center;
        var favorites = favoritesModel.getObjects();
        var favoritesKeys = favoritesModel.getSortedKeys();

        listModel.clear();
        for (var i in favoritesKeys) {
            var key = favoritesKeys[i];
            var favorite = favorites[key];
            var favPosition = favorite.storeObjectProperties.position;
            var category = favoritesModel.getTypeFromCategory(favorite.categories);
            var iconPath = "../" + favoritesModel.getIconPath(category, "list");

            if (favPosition) {
                var destPosition = positioningModel.createGeoCoordinates(favPosition, favoritesEditPage);
                var distance = Units.getReadableDistanceVisual(position.distance(destPosition));
                var distanceText = distance.value + distance.unit;

                var addressLines = favoritesModel.getFormattedAddress(favorite);

                listModel.append({"address1": favorite.text,
                                  "address2" : addressLines ? addressLines[0] : "",
                                  "distance": distanceText,
                                  "iconUrlList": iconPath,
                                  "location": favPosition,
                                  "detailAddress2": addressLines ? addressLines[1] : "",
                                  "detailAddress3": addressLines ? addressLines[2] : "",
                                  "favoriteObject": favorite});

                destPosition.destroy();
            }
        }
    }
}
