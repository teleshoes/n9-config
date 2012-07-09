import QtQuick 1.1

Item {
    id: favoriteObject
    property variant storeObject
    property variant storeObjectProperties
    property variant place

    property int syncId
    property string key
    property string text
    property string description
    property variant categories
    property variant modificationDate

    property bool isFuzzy: false // Whether the location has *no* Place ID, only coordinates

    function isReady() {
        return true;
    }

    Component.onDestruction: {
        if (place) place.destroy();
    }
}
