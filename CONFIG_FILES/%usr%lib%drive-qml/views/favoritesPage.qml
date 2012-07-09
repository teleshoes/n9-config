import QtQuick 1.1
import MapsPlugin 1.0
import components 1.0
import "../utils/Units.js" as Units
import "../components/styles.js" as Styles
import "../models/ModelFactory.js" as ModelFactory

Page {
    id: page
    title: qsTrId("qtn_drive_favourites_hdr")
    scrollableList: list

    property variant myStyle: Styles.Favorites
    property variant appModel
    property variant mapModel
    property variant favoritesModel
    property variant appSettingsModel
    property variant positioningModel

    ListModel { id: buttonModel }
    Component {
        id: block_hint
        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 40

            Item { // spacer to leave margin to top, height + spacing
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                height: 10
            }
            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                source: myStyle.icon.uri + myStyle.icon.addToFavorites
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 40
                color: "#FFFFFF"
                font.pixelSize: 26
                font.family: myStyle.notification.actionFontFamilty
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                text: qsTrId("qtn_drive_you_can_save_places_not")
            }
        }
    }

    List {
        id: list
        anchors.top: titleBox.bottom
        width: parent.width
        height: parent.height - titleBox.height
        listItemHeight: 130
        contentHeight: listItemHeight * listModel.count + 130
        menuStyle: false

        listModel: buttonModel
        delegate: AddressItem {}
        header: FavoritesSyncButton {} // its height is 130
        footer: Loader {
            anchors.left: parent.left
            anchors.right: parent.right
            sourceComponent: block_hint
            visible: !buttonModel.count
            height: visible ? block_hint.height : 0
        }

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
        if (firstShow) {
            populateFavoritesList();
        }

        list.updateScrollButtons();
    }

    Connections {
        ignoreUnknownSignals: true
        target: favoritesModel
        onFavoritesUpdated: populateFavoritesList()
        onFavoritesSynchronized: populateFavoritesList()
    }

    Component.onCompleted: {
        appModel = ModelFactory.getModel("AppModel");
        favoritesModel = ModelFactory.getModel("FavoritesModel");
        appSettingsModel = ModelFactory.getModel("AppSettingsModel");
        mapModel = ModelFactory.getModel("MapModel");
        positioningModel = ModelFactory.getModel("PositioningModel");
    }

    function populateFavoritesList() {
        var position = positioningModel.getPositionSnapshot() || mapModel.center;
        var favorites = favoritesModel.getObjects();
        var favoritesKeys = favoritesModel.getSortedKeys();

        buttonModel.clear();

        for (var i in favoritesKeys) {
            var key = favoritesKeys[i];
            var favorite = favorites[key];
            var favPosition = favorite.storeObjectProperties.position;

            if (favPosition) {
                var destPosition = positioningModel.createGeoCoordinates(favPosition, page);
                var distance = Units.getReadableDistanceVisual(position.distance(destPosition));
                var distanceText = distance.value + distance.unit;
                var addressLines = favoritesModel.getFormattedAddress(favorite);

                var category = favoritesModel.getTypeFromCategory(favorite.categories);
                var iconPath = "../" + favoritesModel.getIconPath(category, "list");

                buttonModel.append({
                                  "address1": favorite.text,
                                  "address2" : addressLines ? addressLines[0] : "",
                                  "distance": distanceText,
                                  "iconUrlList": iconPath,
                                  "location": favPosition,
                                  "detailAddress2": addressLines ? addressLines[1] : "",
                                  "detailAddress3": addressLines ? addressLines[2] : ""
                                   });
            }
        }

        list.updateScrollButtons();
    }
}
