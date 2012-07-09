import QtQuick 1.1
import components 1.0
import "../../components/styles.js" as Style


Page {
    id: page
    tag: "favoritesSettings"
    title: qsTrId("qtn_drive_favourites_hdr")
    scrollableList: list

    property variant favoritesModel

    VisualItemModel {
        id: listModel

        FavoritesSyncButton {}

        ButtonItem {
            id: editFavorites
            itemId: "edit"
            title: qsTrId("qtn_drive_edit_favourites_item")
            subtitle: qsTrId("qtn_drive_favourites_rename_delete_subitem")
            iconUrl: Style.Favorites.icon.uri2 + Style.Favorites.icon.listItemEdit
        }

        ButtonItem {
            id: deleteAllFavorites
            itemId: "deleteAll"
            title: qsTrId("qtn_drive_delete_all_favourites_item")
            iconUrl: Style.Favorites.icon.uri2 + Style.Favorites.icon.listItemDelete
            hideArrow: true
        }
    }

    List {
        id: list
        anchors.top: titleBottom
        anchors.left: parent.left
        anchors.right: parent.right
        width: parent.width
        height: parent.height - titleBox.height
        listModel: listModel

        onItemClicked: {
            if (itemId == "edit") {
                editFavoritesClicked();
            } else if (itemId == "deleteAll") {
                deleteAllFavoritesClicked();
            }
        }
    }

    function editFavoritesClicked() {
        window.push("favoritesEditPage.qml");
    }

    function deleteAllFavoritesClicked() {
        var dialog = window.showDialog("", {
            text: qsTrId("qtn_drive_really_delete_all_favs_dlg"),
            affirmativeMessage: qsTrId("qtn_drive_yes_btn_short"),
            cancelMessage: qsTrId("qtn_drive_no_btn_short")
        });

        dialog.userReplied.connect(function(answer) {
            if (answer == "ok") {
                editFavorites.isActive = deleteAllFavorites.isActive = false;
                favoritesModel.removeAll();
            }
        });
    }

    function update() {
        editFavorites.isActive = deleteAllFavorites.isActive = !favoritesModel.isEmpty();
    }

    onBeforeShow: {
        update();
    }

    Component.onCompleted: {
        favoritesModel = modelFactory.getModel("FavoritesModel");
        favoritesModel.favoritesSynchronized.connect(update);
    }

    Component.onDestruction: {
        favoritesModel.favoritesSynchronized.disconnect(update);
    }
}
