import QtQuick 1.1
import "styles.js" as Style
import models 1.0


Item {
    height: 130
    anchors.left: parent ? parent.left : undefined
    anchors.right: parent ? parent.right : undefined

    property variant mapSettingsModel
    property variant mapModeSwitchStyle: Style.MapModeSwitch
    signal itemSelected();

    ToggleSwitch {
        height: mapModeSwitchStyle.height
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: mapModeSwitchStyle.leftMargin
        anchors.rightMargin: mapModeSwitchStyle.rightMargin

        isLandscape: page.isLandscape
        onClicked: {
            mapSettingsModel.setSateliteMode(uid == 2);
            itemSelected();
        }
        buttonModel: ListModel {
            id: toggleSwitchModel
            ListElement {
                label: "!Map"
                identifier: 1
                buttonWidth: 0
                preSelected: false
                imageSource: ""
            }
            ListElement {
                label: "!Satellite"
                identifier: 2
                buttonWidth: 0
                preSelected: false
                imageSource: ""
            }
        }
    }

    Component.onCompleted: {
        toggleSwitchModel.get(0).label = qsTrId("qtn_drive_map_tgl");
        toggleSwitchModel.get(1).label = qsTrId("qtn_drive_satellite_tgl");

        mapSettingsModel = modelFactory.getModel("MapSettingsModel");
        mapSettingsModel.settingsChanged.connect(loadSelected);
        loadSelected();
    }

    Component.onDestruction: {
        mapSettingsModel.settingsChanged.disconnect(loadSelected);
    }

    function loadSelected() {
        var selectIndex = mapSettingsModel.sateliteMode ? 1 : 0;
        toggleSwitchModel.get(selectIndex).preSelected = true;
    }
}
