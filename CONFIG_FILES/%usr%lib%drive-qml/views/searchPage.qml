import QtQuick 1.1
import MapsPlugin 1.0
import components 1.0
import models 1.0
import "../components/components.js" as Components
import "../models/ModelFactory.js" as ModelFactory

Page {
    id: searchPage
    objectName: "windowContent"  // attempt to correct EditBubble/Magnifier behavior
    scrollableList: searchList

    property variant finder
    property variant mapModel
    property variant positioningModel
    property variant favoritesModel
    property variant searchHistoryDatabase
    property bool suggestionsClicked: false
    property variant appSettingsModel: ModelFactory.getModel("AppSettingsModel");

    property string afterHideState
    property bool useOnline: /*device.online && */ appSettingsModel.connectionAllowed
    property bool temporaryOfflineSearch: false
    property variant _listContents: { history:
                                        { model: searchHistoryModel,
                                          delegate: recentSearchListItem },
                                      results:
                                        { model: searchResultModel,
                                          delegate: addressItem },
                                      suggestions:
                                        { model: suggestionModel,
                                          delegate: suggestionListItem }
                                    }

    ListModel { id: searchHistoryModel }
    ListModel { id: suggestionModel }
    ListModel { id: searchResultModel }
    Component { id: recentSearchListItem; RecentSearchListItem{} }
    Component { id: addressItem; AddressItem{} }
    Component { id: suggestionListItem; SuggestionListItem{} }
    Component { id: emptyDelegate; Item{} }

    function _onHistoryItemClicked(index) {
        var searchItem = searchList.listModel.get(index);
        var searchText = searchItem.plainText || searchItem.label;
        triggerSearch(searchText)
        searchBox.text = searchText;
    }

    function _onResultItemClicked(index) {
        window.push("searchResultsPage.qml", {
            invokingPage: "searchPage",
            selectedIndex: index
        });
    }

    function _onSuggestionItemClicked(index) {
        suggestionsClicked = true;
        var searchText = searchList.listModel.get(index).plainText;
        triggerSearch(searchText);
        searchBox.text = searchText;
    }

    // Used in scripts change to ensure delegate is re-assigned in correct order
    function _setListContent() {
        var key = searchPage.state;
        if (searchList.listModel != _listContents[key].model) {
            searchList.delegate = emptyDelegate;
            searchList.listModel = _listContents[key].model;
            searchList.delegate = _listContents[key].delegate;
        }
    }

    states: [
        State {
            name: "searching"
            PropertyChanges { target: suggestionBackground; visible: false; }
            PropertyChanges { target: searchList; visible: false; }
            PropertyChanges { target: searchPage; fullscreen: true; }
        },
        State { name: "error"; extend: "searching" },
        State {
            name: "history"
            PropertyChanges { target: suggestionBackground; visible: searchBox.state == "hasText" &&
                                                                     searchHistoryModel.count == 0 &&
                                                                     !useOnline; }
            PropertyChanges { target: searchList; onItemClicked: { _onHistoryItemClicked(index); } }
            StateChangeScript { script: _setListContent(); }
        },
        State {
            name: "results"
            PropertyChanges { target: suggestionBackground; visible: false; }
            PropertyChanges {
                target: searchList
                listItemHeight: 130
                menuStyle: false
                onItemClicked: { _onResultItemClicked(index); }
            }
            StateChangeScript { script: _setListContent(); }
        },
        State {
            name: "suggestions"
            PropertyChanges {
                target: searchList
                listItemHeight: 100
                menuStyle: true
                onItemClicked: { _onSuggestionItemClicked(index); }
                onTransitionDone: { suggestionBackground.visible = true; }
            }
            StateChangeScript { script: _setListContent(); }
        }
    ]

    Rectangle {
        id: suggestionBackground
        visible: false
        color: "#EFF0F1"
        anchors.top: searchBox.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        Text {
            id: noSuggestionsText
            color: "black"
            font.family: Components.Common.font.family
            font.pixelSize: 36
            anchors.fill: parent
            anchors.topMargin: 40
            anchors.rightMargin: window.isLandscape ? 140 : 40
            anchors.leftMargin: 40
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            text: qsTrId("qtn_drive_search_hitenter_not")
        }
    }

    List {
        id: searchList
        anchors.top: searchBox.bottom
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        emitUserInteractionSignal: true
        onUserInteraction: { unfocusSearchBox(); }
        listModel: searchHistoryModel
        delegate: recentSearchListItem
        listItemHeight: 100
        menuStyle: false
    }

    SearchBox {
        id: searchBox
        anchors.top: parent.top
        width: window.isLandscape ? searchPage.width - Components.ScrollBar.width : parent.width
        inputFocus: false
        height: 100

        onSearchTriggered: {
            searchBox.text = searchBox.text.trim();
            if (searchBox.text) {
                triggerSearch(searchBox.text)
            } else {
                searchBox.inputFocus = true;
            }
        }

        onInputChanged:{
            if (searchBox.text === "") {
                updateRecents();
                searchPage.state = "history";
                searchList.updateScrollButtons();
                searchBox.inputFocus = true;
                searchBox.state = "";
                suggestionBackground.visible = false;
            } else {
                searchBox.state = "hasText";

                if (!useOnline) {
                    searchPage.state = "history";
                    searchHistoryModel.clear();
                    var searchHistory = searchHistoryDatabase.getRecentSearchs();
                    highlightSuggestions(searchHistory, searchHistoryModel, searchBox.text.trim());
                    searchList.updateScrollButtons();
                    suggestionBackground.visible = !searchHistoryModel.count;
                } else if (searchPage.state != "searching") {
                    suggestionTimer.restart();
                }
            }
        }
    }

    Image {
        id: searchBoxShadow
        source: "../resources/searchBoxShadow.png"
        anchors.top: searchBox.bottom
        width: searchBox.width
        fillMode: Image.TileHorizontally
    }

    Timer {
        id: suggestionTimer
        interval: 200
        onTriggered: {
            if (searchBox.text === "" || searchPage.state == "searching") {
                return;
            }

            searchBox.state = "loading";
            finder.suggestionsDone.connect(searchPage.suggestionHandler);
            finder.getSuggestions(searchBox.text, (positioningModel.position && positioningModel.position.geoCoordinates) || mapModel.center);
        }
    }

    Connections {
        ignoreUnknownSignals: true
        target: favoritesModel
        onFavoriteAdded: onFavoriteAdded(favorite)
        onFavoriteRemoved: onFavoriteRemoved(favorite)
    }

    Component.onCompleted: {
        mapModel = modelFactory.getModel("MapModel");
        finder = modelFactory.getModel("SearchModel");
        favoritesModel = modelFactory.getModel("FavoritesModel");
        searchHistoryDatabase = modelFactory.getModel("SearchHistoryModel");
        positioningModel = modelFactory.getModel("PositioningModel");
        updateRecents();
        searchList.updateScrollButtons();
    }

    function onFavoriteAdded(fav) {
        var count = searchResultModel.count;

        for (var i = 0; i < count; i++) {
            var item = searchResultModel.get(i);
            if (item.favoriteKey === undefined) {
                var key = favoritesModel.getFavoriteKey(item.placeId, item.location);

                if (key !== undefined ) {
                    searchResultModel.setProperty(i, "iconUrlList", item.iconUrlFav);
                    searchResultModel.setProperty(i, "favoriteKey", key);
                    searchResultModel.setProperty(i, "isFavorite", true);
                    break;
                }
            }
        }
    }

    function onFavoriteRemoved(fav) {
        var count = searchResultModel.count;
        for (var i = 0; i < count; i++) {
            var item = searchResultModel.get(i);
            if (item.favoriteKey !== undefined && item.favoriteKey === fav.key) {
                searchResultModel.setProperty(i, "iconUrlList", item.iconUrlNoFav);
                searchResultModel.setProperty(i, "favoriteKey", undefined);
                searchResultModel.setProperty(i, "isFavorite", false);
                break;
            }
        }
    }


    onShow: {
        if (firstShow) {
            if (params.searchTerm) {
                triggerSearch(params.searchTerm);
                searchBox.text = params.searchTerm;
            } else {
                searchBox.inputFocus = true;
            }
             searchPage.state = "history";
        }
    }

    onBeforeHide: {
        unfocusSearchBox();
    }

    onHide: {
        if (searchPage.afterHideState) {
            searchPage.state = searchPage.afterHideState;
            searchPage.afterHideState = "";
        }
    }

    function unfocusSearchBox() {
        searchBox.inputFocus = false;
        device.softwareKeyboardVisible = false;
        window.focus = true;
    }

    function triggerSearch(textInput, forceOnline) {
        var searchOnline = forceOnline || useOnline;

        searchResultModel.clear();
        unfocusSearchBox();
        finder.cancelSuggestions();
        finder.cancelSearch();

        searchPage.state = "searching";
        var searchingStr = searchOnline ? qsTrId("qtn_drive_searching_online_not") : qsTrId("qtn_drive_searching_offline_not");
        var dialog = window.showDialog("", {
            text: [searchingStr, "'" + textInput + "'"].join("\n"),
            cancelMessage: qsTrId("qtn_drive_cancel_btn"),
            cancelVisible: true,
            affirmativeVisible: false,
            showSpinner: true
        });

        dialog.userReplied.connect(function(answer) {
            if (answer == "cancel") {
                finder.cancelSearch();
                searchBox.inputFocus = true;
                searchPage.fullscreen = false;
                searchPage.state = "history";
            }
        });

        var positionSnapshot = positioningModel.getPositionSnapshot();
        finder.searchDone.connect(function() { dialog.destroy(); })
        finder.searchDone.connect(searchDoneHandler);
        finder.search(textInput, positionSnapshot || mapModel.center, searchOnline);
        positionSnapshot && positionSnapshot.destroy();
    }

    function showError(errorText) {
        var dialog = window.showDialog("SearchError", {
            text: errorText,
            searchString: searchBox.text,
            affirmativeMessage: qsTrId("qtn_drive_edit_search_btn"),
            cancelVisible: false
        });
        dialog.userReplied.connect(function(answer) {
            if (answer == "ok") {
                searchBox.inputFocus = true;
                searchPage.state = "history";
            }
        });
    }

    function searchTemporarilyOffline() {
        appSettingsModel.setConnectionAllowed(false);
        temporaryOfflineSearch = true;
        triggerSearch(searchBox.text.trim());
    }

    function promptSearchTemporarilyOffline() {
        var dialog = window.showDialog("SearchError", {
            text: qsTrId("qtn_drive_no_search_server_connection_err"),
            searchString: searchBox.text,
            affirmativeMessage: qsTrId("qtn_drive_search_offline_btn"),
            columnLayout: true
        });

        dialog.userReplied.connect(function(answer) {
            if (answer == "ok") {
                searchTemporarilyOffline();
            } else {
               // triggerSearch(searchBox.text.trim());;
                searchBox.inputFocus = true;
                searchPage.state = "history";

            }
        });
    }

    function showNoOfflineResultsError() {
        var dialog = window.showDialog("SearchError", {
            text: qsTrId("qtn_drive_no_search_results_offline_err"),
            searchString: searchBox.text,
            cancelMessage: qsTrId("qtn_drive_no_btn_short"),
            columnLayout: false
        });

        dialog.userReplied.connect(function(answer) {
            if (answer == "ok") {
                appSettingsModel.setConnectionAllowed(true);
                triggerSearch(searchBox.text.trim(), true)
            } else {
                searchBox.inputFocus = true;
                searchPage.state = "history";
            }
        });
    }

    function searchDoneHandler(errorCode, results) {
        searchBox.state = "hasText";
        if (temporaryOfflineSearch) {
            temporaryOfflineSearch = false;
            appSettingsModel.setConnectionAllowed(true);
        }

        finder.searchDone.disconnect(searchPage.searchDoneHandler);

        //Exit directly if there was an error
        if (errorCode == finder.networkConnectionError || errorCode == finder.timedOutError) {
            promptSearchTemporarilyOffline();
            return;
        } else if (errorCode == finder.userCancelledError) {
            searchPage.state = "history";
            return;
        }

        if (results.length === 0) {
            if (!useOnline) {
                showNoOfflineResultsError();
            } else {
                showError(qsTrId("qtn_drive_no_search_results_online_err"));
            }
            searchPage.state = "error";

        } else {
            for (var i = 0, len = results.length; i < len; i++) {
                searchResultModel.append(results[i]);
            }

            searchHistoryDatabase.insert(searchBox.text);

            if (results.length === 1) {
                window.push("searchResultsPage.qml", {
                    invokingPage: "searchPage",
                    results: finder.currentResults,
                    selectedIndex: 0
                });

                searchPage.afterHideState = "results";
                return;
            }

            searchPage.state = "results";
            searchList.updateScrollButtons();
        }
    }

    function suggestionHandler(errorCode, suggestions) {
        finder.suggestionsDone.disconnect(searchPage.suggestionHandler);
        if (!searchBox.text.trim()) return; // To prevent callback delay of suggestions

        searchBox.state = "hasText";
        if (errorCode != finder.noError) {
            if (errorCode == finder.networkConnectionError && !device.online) {
                //Switch application to offline mode
                appSettingsModel.setConnectionAllowed(false);
            }

            return;
        }

        suggestionModel.clear();
        if (suggestions.length > 0) {
            if (searchPage.state != "suggestions") {
                searchList.listViewState = "";
            }
            highlightSuggestions(suggestions, suggestionModel, searchBox.text.trim());
        }
        if (searchList.listViewState != "visible") {
            searchList.listViewState = "visible";
        }
        noSuggestionsText.visible = (suggestionModel.count == 0);
        searchPage.state = "suggestions";
        searchList.updateScrollButtons();
    }

    function highlightSuggestions(suggestions, model, keyword) {
        var regexp = new RegExp("(" + keyword + ")", "gi");
        var replacement = '<font color="#1080DD"><u>$1</u></font>';
        for (var i = 0, j = suggestions.length; i < j; ++i) {
            var itemText = suggestions[i];
            var label = itemText.replace(regexp, replacement);
            // compare 2 strings to ensure highlight works. (reasonable suggestions)
            if (itemText != label) {
                model.append({label: label, itemId: label, plainText: itemText});
            }
        }
    }

    function updateRecents() {
        searchHistoryModel.clear();
        var searchHistory = searchHistoryDatabase.getRecentSearchs(),
            len = Math.min(searchHistory.length, 100);
        for (var i = 0; i < len; i++) {
            searchHistoryModel.append({ label: searchHistory[i], itemId: "item" + i });
        }
    }
}
