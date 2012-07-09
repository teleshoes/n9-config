import QtQuick 1.1
import syncshareplugin.imports 1.0

SyncShare {
    id: syncShare
    objectName: "syncShareObject"
    property variant syncStore: null
    property variant syncService: null
    property bool init: false
    property bool collected: false
    signal initialized

    function initialize() {
        if(!syncShare.syncStore) {
            console.log('no syncStore yet. opening new syncstore');

            syncShare.syncStore = syncShare.openLocalStore();
            syncShare.syncStore.initDone.connect(function() {
                console.log('syncStore initialized');
                syncShare.initialized();
            });
            syncShare.syncStore.init();
        }

        if(!syncShare.syncService) {
            console.log('no syncService yet. opening new syncservice.');

            syncShare.syncService = syncShare.openSyncService();
        }

        syncShare.init = true;
    }
}
