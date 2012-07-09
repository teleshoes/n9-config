import QtQuick 1.1
import "ModelFactory.js" as ModelFactory
import "models.js" as Models
import "FavoritesModel.js" as JS
import "FavoritesHelper.js" as Helper

Item {
    id: favoritesModel

    property variant appSettingsModel
    property variant mapModel
    property variant positioningModel
    property bool synchronizing: false
    property double syncProgress: 0.0
    property bool shareReady: false
    property int uriCount: 0

    property variant share: SyncShareService {}

    property Component objectFactory

    property string syncShareKey: "maps-qml"

    //signals
    signal myLocationSaved(string title, string action)
    signal favoritesUpdated()
    signal favoritesSynchronized()
    signal synchronizationFailed();
    signal favoriteAdded(variant favorite)
    signal favoriteRemoved(variant favorite)

    function initializeService() {
        var init = function () {
            initialize();
        };
        share.initialized.connect(init);
        share.initialize();
    }

    function initialize() {
        var cb = function () {
            favoritesModel.favoritesUpdated();
            favoritesModel.favoritesSynchronized();
        };

        Helper.initialize(cb);
    }

    function synchronize() {
        synchronizing = true;
        syncProgress = 0.0;

        var onSyncDone = function(success) {
            synchronizing = false;
            if (success) {
                appSettingsModel.setLastSyncDate(new Date().toUTCString());
                favoritesSynchronized();
            }
            else {
                synchronizationFailed();
            }
        }
        var onProgress = function(progress, status) {
            syncProgress = progress;
        }
        var networkOpened = function() {
            device.networkConnectionOpened.disconnect(networkOpened);
            device.networkConnectionError.disconnect(networkError);
            Helper.synchronizeFavorites(onSyncDone, onProgress);
        }
        var networkError = function() {
            // user cancelled the network connection
            device.networkConnectionOpened.disconnect(networkOpened);
            device.networkConnectionError.disconnect(networkError);
            synchronizing = false;
            synchronizationFailed();
        }

        if (!device.online) {
            device.networkConnectionOpened.connect(networkOpened);
            device.networkConnectionError.connect(networkError);
            device.openNetworkConnection();
        }
        else {
            Helper.synchronizeFavorites(onSyncDone, onProgress);
        }
    }

    function cancelSynchronization() {
        Helper.cancelSynchronization();

        // There is risk of crashing syncshare plugin if multiple cancel request are made,
        // so don't do this here, instead wait for syncshare plugin to finish the cancel task
        // and call onSyncDone callback in synchronize() function above, where synchronizing will be set to false
        //synchronizing = false;
    }

    function getObjects()
    {
        return JS.objects;
    }

    function getSortedKeys() {
        return Helper.getSortedKeys();
    }

    function remove(favoriteKey) {
        Helper.remove(favoriteKey);
    }

    function removeAll() {
        Helper.removeAll();
    }

    function isEmpty() {
        return !Object.keys(getObjects()).length; // 0 is true, >0 is false
    }

    function rename(name, favoriteKey) {
        Helper.rename(name, favoriteKey);
    }

    function formatAddress(properties) {
        return Helper.formatAddress(properties);
    }

    function getPlaceSubtitle(object) {
        return Helper.getPlaceSubtitle(object);
    }

    function getFormattedAddress(object) {
        return Helper.getFormattedAddress(object);
    }

    function getFavoriteKey(placeId, location) {
        return Helper.getFavoriteKey(placeId, location);
    }

    function saveMyLocation() {
        var searchPosition = positioningModel.getPositionSnapshot() || mapModel.center;
        console.log("saving position: lat " + searchPosition.latitude + ", long: " + searchPosition.longitude);

        var finder = ModelFactory.getModel("SearchModel");
        var searchOnline = appSettingsModel.isConnectionAllowed() && device.online;
        var onReverseGeoCodingDone = function (errorCode, result) {
            finder.reverseGeocodingDone.disconnect(onReverseGeoCodingDone);

            var searchResult = result;

            var address = result ? result.address1 : "";
            var address2 = result ? result.detailAddress2 : "";
            var address3 = result ? result.detailAddress3 : "";

            console.log("address1.text: " + address);
            console.log("address2.text: " + address2);
            console.log("address3.text: " + address3);

            Helper.addFavorite(address, searchPosition, searchResult);

            var msg = qsTrId("qtn_drive_saved_to_favourites_dlg").replace("§ ", "");
            favoritesModel.myLocationSaved(address + ", " + address3, msg);
        }

        finder.reverseGeocodingDone.connect(onReverseGeoCodingDone);
        finder.reverseGeocode(searchPosition, searchOnline);
    }

    function addFavorite(address, searchPosition, searchResult) {
        return Helper.addFavorite(address, searchPosition, searchResult);
    }

    function getTypeFromCategory(aCategory) {
        return Helper.getTypeFromCategory(aCategory);
    }

    function getCategoryTypeByName(aName) {
        return Helper.getCategoryTypeByName(aName);
    }

    function getCategoryTypeById(categoryNumber) {
        return Helper.getCategoryTypeById(categoryNumber);
    }


    function getIconFromMosCategoryMapping(category){
        return Helper.getIconFromMosCategoryMapping(category);
    }


    function getIconPath(category, mode) {
        return Helper.getIconPath(category, mode);
    }


    Component.onCompleted: {
        mapModel = ModelFactory.getModel("MapModel");
        appSettingsModel = ModelFactory.getModel("AppSettingsModel");
        positioningModel = ModelFactory.getModel("PositioningModel");
    }
}
