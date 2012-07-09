import QtQuick 1.1
import MapsPlugin 1.0
import components 1.0
import "../../components/components.js" as Components

Page {
    id: root
    title: qsTrId("qtn_drive_traffic_update_interval_hdr")
    scrollableList: list

    property variant appSettingsModel

    CheckableGroup {
        id: group
    }

    VisualItemModel {
        id: listModel

        ButtonItem {
            id: five
            itemId: "five"
            title: "5 "+ qsTrId("qtn_drive_unit_minute")
            style: Components.RadioButton
            group: group
            hasIcon: false
        }

        ButtonItem {
            id: ten
            itemId: "ten"
            title: "10 "+ qsTrId("qtn_drive_unit_minute")
            style: Components.RadioButton
            group: group
            hasIcon: false
        }

        ButtonItem {
            id: fifteen
            itemId: "fifteen"
            title: "15 "+ qsTrId("qtn_drive_unit_minute")
            style: Components.RadioButton
            group: group
            hasIcon: false
        }

        ButtonItem {
            id: twenty
            itemId: "twenty"
            title: "20 "+ qsTrId("qtn_drive_unit_minute")
            style: Components.RadioButton
            group: group
            hasIcon: false
        }
    }

    List {
        id: list
        listModel: listModel
        anchors.top: titleBottom
        width: parent.width
        height: parent.height - titleBox.height
        onItemClicked: {
            appSettingsModel.setTrafficUpdateInterval(itemId == "five" ? 5 : (itemId == "ten" ? 10 : (itemId == "fifteen" ? 15 : 20)));
            window.pop();
        }
    }

    onBeforeShow: {
        appSettingsModel = modelFactory.getModel("AppSettingsModel");
        var itemToSelect = null;
        switch (appSettingsModel.trafficUpdateInterval) {
            case 5:
                itemToSelect = five;
                break;
            case 10:
                itemToSelect = ten;
                break;
            case 15:
                itemToSelect = fifteen;
                break;
            case 20:
                itemToSelect = twenty;
                break;
            default:
                throw new Error("Invalid TrafficUpdateInterval");
        }
        itemToSelect.buttonChecked = true;
    }
}
