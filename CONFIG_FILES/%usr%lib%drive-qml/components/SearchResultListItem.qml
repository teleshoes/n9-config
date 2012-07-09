import QtQuick 1.1
import "styles.js" as Styles

Item {
    id: resultListItem

    // 'public' properties
        // orientation flag
    property bool isLandscape
        // distance text container
    property Item externalContainer
        // show external contents flag
    property bool showExternal

    width: parent.width
    height: parent.height
    clip: true

    property variant address
    property variant favoriteKey
    property alias isFavorite: textBlock.isFavorite
    property variant searchItem

    function setData(data) {
        resultListItem.address = data;
        resultListItem.favoriteKey = data.favoriteKey
        resultListItem.searchItem = data.properties
        resultListItem.isFavorite = data.isFavorite
    }

    AddressTextBlock {
        id: textBlock
        anchors.left: parent.left
        anchors.topMargin: isLandscape ? 30 : 40
        anchors.leftMargin: isLandscape ? 22 : 40
        anchors.rightMargin: isLandscape ? 22 : 40
        anchors.top: parent.top
        anchors.right: parent.right
        landscape: isLandscape
        address: resultListItem.address
        isFavoriteVisible: !!address
        isFavorite: false
        favoriteKey: resultListItem.favoriteKey
        searchItem: resultListItem.searchItem
    }

    // distance text (appears in Navigation bar = the external container)
    Text {
        id: distanceLabel

        parent: resultListItem.externalContainer
        anchors.centerIn: parent
        visible: resultListItem.showExternal

        font.family: Styles.defaultFamily
        font.pixelSize: Styles.SearchResultListItem.distanceLabel.fontsize
        color: Styles.SearchResultListItem.distanceLabel.color
        text: address ? address.distance : ""
    }
}
