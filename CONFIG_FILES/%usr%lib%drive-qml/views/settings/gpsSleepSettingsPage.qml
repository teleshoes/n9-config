import QtQuick 1.1
import components 1.0
import models 1.0
import "../../components/components.js" as Components


Page {
    id: page
    title: qsTrId("qtn_drive_GPS_power_saving_hdr")
    scrollableList: list

    property variant appSettingsModel

    VisualItemModel {
        id: listModel

        ButtonItem  {
            id: gpsSleepCheckbox
            itemId: "gpsSleep"
            title: qsTrId("qtn_drive_GPS_power_saving_item")
            iconUrl: "../../resources/listitems/powersave.png"
            checkable: true
            style: Components.CheckBox
            onClicked: {
                appSettingsModel.setGpsPowersaving(checked);
                loadCurrentValues();
            }
        }

        Text {
            id: notice
            font.family: Components.Common.font.family
            font.pixelSize: 24
            anchors.top: gpsSleepCheckbox.bottom
            anchors.topMargin: 16
            anchors.left: parent.left
            anchors.leftMargin: 16
            width: page.width - (isLandscape ? Components.ActionBar.landscape.width : 0) - 32   //SOME MARGIN
            color: "white"
            wrapMode: Text.WordWrap
            text: qsTrId("qtn_drive_GPS_power_saving_text1") + "\n\n" +
                  qsTrId("qtn_drive_GPS_power_saving_text2") + "\n\n" +
                  qsTrId("qtn_drive_GPS_power_saving_text3")
        }
    }

    List {
        id: list
        anchors.top: titleBottom
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        contentHeight: notice.height + gpsSleepCheckbox.height  //adding bottomMargin manually
        height: parent.height - titleBox.height
        listItemHeight: contentHeight / notice.height           //using the notice height as the "itemHeigh"
        listModel: listModel                                    //since it's the bigger elememt
    }

    onBeforeShow: {
        appSettingsModel = modelFactory.getModel("AppSettingsModel");
        loadCurrentValues();
    }

    function loadCurrentValues() {
        var isPowersaving = appSettingsModel.isGpsPowersaving();
        //gpsSleepCheckbox.subtitle = isPowersaving ? qsTrId("qtn_drive_GPS_power_saving_on_subitem") : qsTrId("qtn_drive_GPS_power_saving_off_subitem");
        gpsSleepCheckbox.buttonChecked = isPowersaving;
    }
}
