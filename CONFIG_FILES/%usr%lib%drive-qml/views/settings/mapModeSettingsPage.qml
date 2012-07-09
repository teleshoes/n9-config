import QtQuick 1.1
import MapsPlugin 1.0
import components 1.0
import "../../components/components.js" as Components

Page {
    id: root
    title: qsTrId("qtn_drive_day_night_hdr")
    scrollableList: list

    property variant mapSettingsModel

    CheckableGroup {
        id: group
    }

    VisualItemModel {
        id: listModel

        ButtonItem {
            id: dayMode
            itemId: "day"
            title: qsTrId("qtn_drive_day2_item")
            iconUrl:  "../../resources/listitems/daymode.png"
            style: Components.RadioButton
            group: group
        }

        ButtonItem {
            id: nightMode
            itemId: "night"
            title: qsTrId("qtn_drive_night2_item")
            iconUrl:  "../../resources/listitems/nightmode.png";
            style: Components.RadioButton
            group: group
        }

        /** TODO: enable when plugin is fixed
        ButtonItem {
            id: autoMode
            itemId: "auto"
            title: qsTrId("qtn_drive_auto2_item")
            iconUrl:  "../../resources/listitems/automode.png";
            style: Components.RadioButton
            group: group
        }
        */
    }

    List {
        id: list
        listModel: listModel
        anchors.top: titleBottom
        width: parent.width
        height: parent.height - titleBox.height
        onItemClicked: {
            mapSettingsModel.setDayNightMode(itemId);
            window.pop(params.invokingPage);
        }
    }

    onBeforeShow: {
        mapSettingsModel = modelFactory.getModel("MapSettingsModel");
        var itemToSelect = null;
        switch (mapSettingsModel.dayNightMode) {
            case "day":
                itemToSelect = dayMode; break;
            case "night":
                itemToSelect = nightMode; break;
            case "auto":
                itemToSelect = autoMode; break;
            default:
                throw new Error("Invalid DayNightMode option");
        }
        itemToSelect.buttonChecked = true;
    }
}
