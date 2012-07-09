import QtQuick 1.1
import "styles.js" as Style

ButtonItem {
    id: button
    itemId: "favoritesSyncButton"

    property variant appSettingsModel
    property variant favoritesModel
    property string lastSyncText
    property bool canceled: false

    title: qsTrId("qtn_drive_synchronize_item")
    subtitle: qsTrId("qtn_favourites_not_synched_subitem")
    iconUrl: Style.Favorites.icon.uri + Style.Favorites.icon.listItemSync
    hideArrow: true
    isActive: favoritesModel ? !favoritesModel.synchronizing : true
    iconVisible: favoritesModel ? !favoritesModel.synchronizing : true
    customizedOnClickedBehavior: true // do not send onItemClicked signal to list

    onClicked: {
        if (!favoritesModel.synchronizing) {
            if (appSettingsModel.isConnectionAllowed()) {
                synchronize();
            }
            else {
                var onlineDlg = window.showDialog("", {
                    text: qsTrId("qtn_drive_go_online_to_synch_favs_dlg"),
                    affirmativeMessage: qsTrId("qtn_drive_yes_btn_short"),
                    cancelMessage: qsTrId("qtn_drive_no_btn_short")
                });
                onlineDlg.userReplied.connect(function(answer) {
                    if (answer == "ok") {
                        appSettingsModel.setConnectionAllowed(true);
                        synchronize();
                    }
                });
            }
        }
    }

    Component.onCompleted: {
        appSettingsModel = modelFactory.getModel("AppSettingsModel");
        favoritesModel = modelFactory.getModel("FavoritesModel");

        updateLastSyncTitle();

        favoritesModel.favoritesSynchronized.connect(onSyncFinsihed);
        favoritesModel.synchronizationFailed.connect(onSyncFailed);
    }

    Component.onDestruction: {
        favoritesModel.favoritesSynchronized.disconnect(onSyncFinsihed);
        favoritesModel.synchronizationFailed.disconnect(onSyncFailed);
    }

    function onSyncFinsihed() {
        updateLastSyncTitle();
    }

    function onSyncFailed() {
        button.subtitle = lastSyncText;
        if (!canceled) {
            // Show error message only if user did NOT cancel sync, but something actually went wrong
            var dlg = window.showDialog("", {
                text: qsTrId("qtn_drive_go_error_in_synching_favs_err"),
                cancelVisible: false,
                affirmativeMessage: qsTrId("qtn_drive_ok_btn")
            });
        } else {
            canceled = false;
        }
    }

    function synchronize() {
        lastSyncText = button.subtitle;
        favoritesModel.synchronize();        
        updateLastSyncTitle();
    }

    function updateLastSyncTitle() {
        if (favoritesModel.synchronizing) {
            button.subtitle = qsTrId("qtn_drive_synchronizing_item");
        }
        else {
            var lastSyncDate = appSettingsModel.lastSyncDate();
            var syncDate = new Date(Date.parse(lastSyncDate));
            lastSyncText = qsTrId("qtn_favourites_not_synched_subitem");

            if(lastSyncDate !== undefined) {
                var dateNow = new Date();
                var format;

                if(syncDate.getFullYear() == dateNow.getFullYear() &&
                   syncDate.getMonth() == dateNow.getMonth() &&
                   syncDate.getDate() == dateNow.getDate())
                {
                    format = "hh:mm";
                }
                else
                {
                    format = "dd.MM.yyyy, hh:mm";
                }

                lastSyncText = qsTrId("qtn_drive_last_synch_subitem").replace("§", " " + Qt.formatDateTime( syncDate, format));
            }

            button.subtitle = lastSyncText;
        }
    }

    function cancelSynchronization() {
        canceled = true;
        favoritesModel.cancelSynchronization();
        updateLastSyncTitle();
    }

    Item {
        id: rotatingSyncIcon
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: syncImage.width + 32

        property bool rotationEnabled: favoritesModel ? favoritesModel.synchronizing : false

        onRotationEnabledChanged: {
            if (rotator.running) {
                rotator.stop();
            }
            else {
                rotator.start();
            }
        }

        Image {
            id: syncImage
            visible: favoritesModel.synchronizing
            source: Style.Favorites.icon.uri + Style.Favorites.icon.sync.uri
            anchors.centerIn: parent
            smooth: true
        }

        // animation for rotating the sync button
        PropertyAnimation {
            id: rotator
            loops: Animation.Infinite
            target: syncImage
            property: "rotation"
            from: 360
            to: 0
            duration: 1500
        }
    }

    // cancel sync button
    Item {
        id: cancel
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: cancelImage.width + 32

        Image {
            id: cancelImage
            visible: favoritesModel.synchronizing
            source: Style.Favorites.icon.uri + Style.Favorites.icon.cancel.normal
            anchors.centerIn: parent
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            enabled: cancelImage.visible
            onClicked: {
                button.cancelSynchronization();
                cancelImage.source = Style.Favorites.icon.uri +Style.Favorites.icon.cancel.normal;
            }
            onPressed: {
                cancelImage.source = Style.Favorites.icon.uri +Style.Favorites.icon.cancel.down;
            }
        }
    }
}
