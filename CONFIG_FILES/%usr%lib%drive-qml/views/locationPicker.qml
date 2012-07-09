import QtQuick 1.1
import com.nokia.meego 1.1  // pre-load meego lib to decrease loading time of searchPage.
import components 1.0
import "../models/ModelFactory.js" as ModelFactory

Page {
    id: page

    title: qsTrId("qtn_drive_set_destination_hdr")
    scrollableList: buttonList
    property string tag: "set_destination"

    property variant appModel
    property variant searchModel
    property variant recentsModel
    property variant appSettingsModel
    property variant positioningModel
    // have to define qsTrIds here instead of in ListElements, a bug waiting for fix in QtQuick 2.0!
    property variant titles: {
        myPosition: qsTrId("qtn_drive_my_position_item"),
        search: qsTrId("qtn_drive_search_item"),
        home: qsTrId("qtn_drive_home_item"),
        favorites: qsTrId("qtn_drive_favourites_item"),
        recents: qsTrId("qtn_drive_last_destinations_item"),
        fromMap: qsTrId("qtn_drive_from_map_item")
    }
    property variant icons: {
        myPosition: "my_position",
        search: "search",
        home: "home",
        favorites: "favorites",
        recents: "recent",
        fromMap: "map_view"
    }
    property variant currentPosition // used to save polishAddress from searchModel
    onCurrentPositionChanged: buttonModel.setActive("myPosition", !!currentPosition)

    function getMyPosition() {
        searchModel.searchDone.connect(updatePosition);
        searchModel.positionToName(positioningModel.getPositionSnapshot());
    }

    function updatePosition(errorCode, results) {
        searchModel.searchDone.disconnect(updatePosition);
        if (results && results[0]) {
            var address = {
                address1: results[0].address1,
                address2: "",
                detailAddress2: results[0].detailAddress2 || "",
                detailAddress3: results[0].detailAddress3 || "",
                location: results[0].location,
                iconUrlList: results[0].iconUrlList,
                iconUrlMap: results[0].iconUrlMap
            };
            currentPosition = address;
        } else {
            currentPosition = undefined;
        }
    }

    ListModel {
        id: buttonModel
        ListElement {
            _itemId: "search"
            _targetPage: "searchPage.qml"
        }
        ListElement {
            _itemId: "home"
            _targetPage: "locationPicker.qml"
        }
        ListElement {
            _itemId: "favorites"
            _targetPage: "favoritesPage.qml"
        }
        ListElement {
            _itemId: "recents"
            _targetPage: "recentsPage.qml"
            _isActive: false
        }
        ListElement {
            _itemId: "fromMap"
            _targetPage: "pickFromMapPage.qml"
        }

        function indexById(str) {
            for(var i = 0, j = buttonModel.count; i < j; ++i) {
                if (buttonModel.get(i)._itemId == str) break;
            }
            return i < j ? i : -1;
        }

        function hide(str) {
            var index = indexById(str);
            if (index != -1) remove(index);
        }

        function showMyPosition() {
            if (get(0)._itemId != "myPosition") {
                insert(0, {
                           _itemId: "myPosition",
                           _targetPage: ""
                       });
            }
        }

        function setActive(str, value) {
            var index = indexById(str);
            if (index != -1) get(index)._isActive = value;
        }
    }

    List {
        id: buttonList
        anchors.top: titleBottom
        width: parent.width
        height: parent.height - titleBox.height

        listModel: buttonModel
        delegate: ButtonItem {
            itemId: _itemId
            title: titles[_itemId]
            iconUrl: "../resources/listitems/{*}.png".replace('{*}', icons[_itemId])
            targetPage: _targetPage
            isActive: _isActive !== false
        }

        onItemClicked: {
            if (itemId == "home") {
                if (appSettingsModel.getHome()) {
                    toRoutePreview(appSettingsModel.getHome());
                } else {
                    appModel.setHomeFlow("defining");
                    toPage(itemArgs.targetPage);
                }
            } else if (itemId == "myPosition") {
                var address = currentPosition;
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
                toPage(itemArgs.targetPage);
            }
        }
    }

    function toPage(page) {
        window.push(page, {invokingPage: tag});
    }

    function toSettings() {
        appModel.setHomeFlow();
        window.pop("settingsPage");
    }

    function toRoutePreview(address) {
        window.push("routePreviewPage.qml", { tag: page.tag, routeTo:  { address: address } } );
    }

    onBeforeShow: {
        buttonModel.setActive("recents", !recentsModel.isEmpty());

        if (appModel.homeFlowFlag) {
            title = qsTrId("qtn_drive_set_home_location_hdr");
            tag = "set_home_location";
            buttonModel.hide("home");

            if (appModel.homeFlowFlag == "setting") {
                buttonModel.showMyPosition();
                getMyPosition();
            }
        }
    }

    function onNavigateButtonClicked() {
        appModel.setHomeFlow();
    }

    Component.onCompleted: {
        appModel = ModelFactory.getModel("AppModel");
        searchModel = ModelFactory.getModel("SearchModel");
        recentsModel = ModelFactory.getModel("RecentsModel");
        appSettingsModel = ModelFactory.getModel("AppSettingsModel");
        positioningModel = ModelFactory.getModel("PositioningModel");
    }
}
