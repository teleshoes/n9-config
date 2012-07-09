import QtQuick 1.1
import "../models/ModelFactory.js" as ModelFactory

Item {
    id: addressTextBlock
    property variant address
    property bool isFavoriteVisible
    property variant favoriteKey    
    property variant searchItem
    property variant favoritesModel
    property alias landscape: column.landscape
    property alias isFavorite: favoritesButton.isFavorite
    height: column.height
    property bool checkBottomLine: false // flag for set 3rd line invisible when needed, e.g. routePreviewPage

    signal addFavorite(variant key)
    signal removeFavorite

    Column {
        id: column
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: 20
        // This property means to be read, but not to set in any case
        height: line0.height + (line1.visible ? (spacing + line1.height) : 0) + (line2.visible ? (spacing + line2.height) : 0)
        spacing: 2
        property bool landscape
        property variant lines: address ? [ address.address1,
                                            address.detailAddress2,
                                            address.detailAddress3 ]
                                        : ["", "", ""]

        AddressTextLine { id: line0; text: column.lines[0]; state: "headline"
            anchors.rightMargin: isFavoriteVisible ? favoritesButton.width
                                                   : 0
        }
        AddressTextLine { id: line1; text: column.lines[1]; visible: !!text }
        AddressTextLine { id: line2; text: column.lines[2]; state: "bottomLine"
            visible: addressTextBlock.checkBottomLine ? column.isLineCountFine()
                                                      : true
        }

        function isLineCountFine() {
            var maxLineCount = landscape ? 6 : 4; // total lines available of first 2 line, only applicable for routePreviewPage
            var currentLineCount = line0.lineCount + (line1.visible ? line1.lineCount : 0) + line2.lineCount;
            return currentLineCount <= maxLineCount;
        }
    }

    FavoritesButton {
        id: favoritesButton
        visible: isFavoriteVisible
        isFavorite: false
        anchors.top: parent.top
        anchors.topMargin: -15
        anchors.right: parent.right
    }

    Connections {
        target: favoritesButton
        onAddFavorite: onButtonAddFavorite()
        onRemoveFavorite: onButtonRemoveFavorite()
    }

    Component.onCompleted: {
        favoritesModel = ModelFactory.getModel("FavoritesModel");
    }

    function onButtonAddFavorite() {
        var key = favoritesModel.addFavorite(line0.text,
                                             { latitude: searchItem["geoLatitude"],
                                               longitude: searchItem["geoLongitude"] },
                                             { properties: searchItem });

        addressTextBlock.favoriteKey = key;
        favoritesButton.isFavorite = true;
        addFavorite(key);
    }

    function onButtonRemoveFavorite() {
        favoritesModel.remove(favoriteKey);
        addressTextBlock.favoriteKey = undefined;
        favoritesButton.isFavorite = false;
        removeFavorite();
    }
}
