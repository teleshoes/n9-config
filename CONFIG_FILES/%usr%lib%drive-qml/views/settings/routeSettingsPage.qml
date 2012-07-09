import QtQuick 1.1
import components 1.0
import "../../models/ModelFactory.js" as ModelFactory
import "../../components/components.js" as Components

Page {
    id: routeSettingsPage

    title: qsTrId("qtn_drive_route_settings_hdr")
    tag: "routeSettingsPage"
    scrollableList: buttonList

    property variant routingModel
    property variant appSettingsModel
    property int buttonStatus

    ListModel {
        id: buttonModel
        ListElement {
            _itemId: "motorways"
            _iconUrl: "highways.png"
            _checked: true
        }
        ListElement {
            _itemId: "toll"
            _iconUrl: "toll_roads.png"
            _checked: true
        }
        ListElement {
            _itemId: "ferries"
            _iconUrl: "ferries.png"
            _checked: true
        }
        ListElement {
            _itemId: "tunnels"
            _iconUrl: "tunnel.png"
            _checked: true
        }
        ListElement {
            _itemId: "unpaved"
            _iconUrl: "unpaved_road.png"
            _checked: true
        }
        ListElement {
            _itemId: "motorail"
            _iconUrl: "motorails.png"
            _checked: true
        }

        function indexById(str) {
            for (var i = 0, j = buttonModel.count; i < j; ++i) {
                if (get(i)._itemId == str) break;
            }
            return i < j ? i : -1;
        }

        function status() {
            var s = 0;
            for (var i = 0, j = buttonModel.count; i < j; ++i) {
                s = (s << 1) + get(i)._checked;
            }
            return s;
        }

        function setStatus(s) {
            for (var i = 0, j = buttonModel.count; i < j; ++i) {
                get(i)._checked = !!(s & (1 << (j - i - 1)));
            }
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
            index: buttonModel.indexById(itemId)
            title: appSettingsModel.routeOptionTitles[index]
            iconUrl: "../../resources/routeOptions/" + _iconUrl
            checkable: true
            buttonChecked: !!_checked
            style: Components.CheckBox
            onClicked: buttonModel.get(index)._checked = checked;
        }
    }

    onBeforeShow: {
        buttonModel.setStatus(appSettingsModel.get('routeOptions'));
        buttonStatus = buttonModel.status();
    }

    function onNavigateButtonClicked() {
        var status = buttonModel.status();
        if (buttonStatus !== status) {
            appSettingsModel.set('routeOptions', status);
            appSettingsModel.routeOptionsChanged();

            window.pop(params.invokingPage);
        } else if (params['forceRouteRecalculation']) {
            appSettingsModel.routeOptionsChanged();
            window.pop(params.invokingPage);
        }
    }

    Component.onCompleted: {
        routingModel = ModelFactory.getModel("RoutingModel");
        appSettingsModel = ModelFactory.getModel("AppSettingsModel");
    }
}
