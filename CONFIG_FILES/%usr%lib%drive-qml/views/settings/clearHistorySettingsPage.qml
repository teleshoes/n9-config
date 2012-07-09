import QtQuick 1.1
import components 1.0
import "../../models/ModelFactory.js" as ModelFactory

Page {
    id: page
    title: qsTrId("qtn_drive_clear_history_hdr")
    scrollableList: buttonList

    property variant recentsModel
    property variant appSettingsModel
    property variant searchHistoryModel

    property variant titles: {
        history: qsTrId("qtn_drive_search_history_clear_item"),
        recents: qsTrId("qtn_drive_last_destinations_history_clear_item"),
        home: qsTrId("!!Delete home")
    }
    property variant hints: {
        history: qsTrId("qtn_drive_really_delete?_dlg"),
        recents: qsTrId("qtn_drive_really_delete_destinations?_dlg"),
        home: qsTrId("!!really delete home address?")
    }

    function clean(id) {
        switch (id) {
        case "history": searchHistoryModel.clear(); break;
        case "recents": recentsModel.clear(); break;
        case "home": appSettingsModel.setHome(); break;
        default: break; // should never be here
        }
    }

    ListModel {
        id: buttonModel
        ListElement { _itemId: "history"; _isActive: false }
        ListElement { _itemId: "recents"; _isActive: false }
        //ListElement { _itemId: "home"; _isActive: false }

        function indexById(str) {
            for(var i = 0, j = buttonModel.count; i < j; ++i) {
                if (get(i)._itemId == str) break;
            }
            return i < j ? i : -1;
        }

        function updateActive() {
            get(indexById("history"))._isActive = !searchHistoryModel.isEmpty();
            get(indexById("recents"))._isActive = !recentsModel.isEmpty();
            //get(indexById("home"))._isActive = !!appSettingsModel.getHome();
        }

        function useless() {
            for(var i = 0, j = buttonModel.count; i < j; ++i) {
                if (get(i)._isActive) return false;
            }
            return true;
        }
    }

    List {
        id: buttonList
        anchors.top: titleBox.bottom
        width: parent.width
        height: parent.height - titleBox.height

        listModel: buttonModel
        delegate: ButtonItem {
            itemId: _itemId
            title: titles[_itemId]
            subtitle: _isActive ? "" : qsTrId("qtn_drive_empty_subitem")
            iconUrl: "../../resources/listitems/clear.png"
            hideArrow: true
            isActive: _isActive
        }

        onItemClicked: {
            var id = itemId; // alias itemId for cross invoking
            var dialog = window.showDialog("", {
                text: hints[id],
                cancelMessage: qsTrId("qtn_drive_no_btn_short")
            });
            dialog.userReplied.connect(function(answer) {
                if (answer == "ok") {
                    page.clean(id);
                    buttonModel.updateActive();
                    if (buttonModel.useless()) window.pop();
                } else {
                    window.pop();
                }
            });
        }
    }

    Component.onCompleted: {
        recentsModel = ModelFactory.getModel("RecentsModel");
        appSettingsModel = ModelFactory.getModel("AppSettingsModel");
        searchHistoryModel = ModelFactory.getModel("SearchHistoryModel");

        buttonModel.updateActive();
    }
}
