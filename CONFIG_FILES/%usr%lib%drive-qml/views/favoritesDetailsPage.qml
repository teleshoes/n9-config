import QtQuick 1.1
import components 1.0
import "../components/styles.js" as Style

Page {
    id: favoriteDetailsPage
    title: qsTrId("qtn_drive_edit_favourites_hdr")
    scrollableList: list

    property variant favoritesModel

    VisualItemModel {
        id: listModel

        AddressItem {
            id: addressItem
            mouseAreaEnabled: false
            property string address1: params.address1 || ""
            property string address2: params.address2 || ""
            property string detailAddress2: ""
            property string detailAddress3: params.detailAddress3 || ""
            property string distance: qsTrId("qtn_drive_added_fav_subitem").replace("§", params.modificationDate)
            property string iconUrlList: params.iconUrlList || ""
        }

        ButtonItem {
            itemId: "rename"
            title: qsTrId("qtn_drive_rename_favourite_item")
            iconUrl: Style.Favorites.icon.uri + Style.Favorites.icon.listItemEdit
        }

        ButtonItem {
            itemId: "delete"
            title: qsTrId("qtn_drive_delete_favourite_item")
            iconUrl: Style.Favorites.icon.uri + Style.Favorites.icon.listItemDelete
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
            if (itemId == "rename") {
                renameFavoriteClicked();
            } else if (itemId == "delete") {
                deleteFavoriteClicked();
            }
        }
    }

    function renameFavoriteClicked() {
        var dialog = window.showDialog("RenameFavorite", {
                                       text: qsTrId("qtn_drive_rename_favourite_hdr"),
                                       affirmativeMessage: qsTrId("qtn_drive_save_btn"),
                                       cancelMessage: qsTrId("qtn_drive_cancel_btn"),
                                       locationName: addressItem.address1,
                                       cursorPosition: addressItem.address1.length,
                                       inputFocus: true
        });

        dialog.userReplied.connect(function(answer, name) {
            if (answer == "ok") {
                favoritesModel.rename(name, params.favoriteKey);
                addressItem.address1 = name;
            }
        });
    }

    function deleteFavoriteClicked() {
        var dialog = window.showDialog("", {
            text: qsTrId("qtn_drive_really_delete_fav_dlg"),
            affirmativeMessage: qsTrId("qtn_drive_yes_btn_short"),
            cancelMessage: qsTrId("qtn_drive_no_btn_short")
        });

        dialog.userReplied.connect(function(answer) {
            if (answer == "ok") {
                favoritesModel.remove(params.favoriteKey);
                if (favoritesModel.isEmpty()) {
                    window.pop("favoritesSettings"); // user wont see empty favorites list
                } else {
                    window.pop();
                }
            }
        });
    }

    Component.onCompleted: {
        favoritesModel = modelFactory.getModel("FavoritesModel");
    }
}
