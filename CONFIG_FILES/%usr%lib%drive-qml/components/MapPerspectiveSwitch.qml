import QtQuick 1.1
import "styles.js" as Style


Item {
    id: perspectiveSwitch
    height: 130
    anchors.left: parent ? parent.left : undefined
    anchors.right: parent ? parent.right : undefined
    property variant mapSettingsModel
    signal itemSelected();

    ToggleSwitch {
        id: switcher
        height: Style.MapPerspectiveSwitch.height
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        isLandscape: page.isLandscape
        onClicked: {
            save(uid);
            itemSelected();
        }
        buttonModel: ListModel {
            id: toggleSwitchModel
            ListElement {
                label: "!2D"
                identifier: 1
                buttonWidth: 0
                preSelected: false
                imageSource: ""
            }
            ListElement {
                label: "!3D"
                identifier: 2
                buttonWidth: 0
                preSelected: false
                imageSource: ""
            }
            ListElement {
                label: "!Sat"
                identifier: 3
                buttonWidth: 0
                preSelected: false
                imageSource: ""
            }
        }
    }

    Component.onCompleted: {
        mapSettingsModel = modelFactory.getModel("MapSettingsModel");
        mapSettingsModel.settingsChanged.connect(loadSelected);
        loadSelected();

        switcher.buttonModel.get(0).label = qsTrId("qtn_drive_2d_tgl");
        switcher.buttonModel.get(1).label = qsTrId("qtn_drive_3d_tgl");
        switcher.buttonModel.get(2).label = qsTrId("qtn_drive_sat_tgl");
    }

    function save(uid) {
        var newPerspective = (uid == 2 ? mapSettingsModel.perspective_3d : mapSettingsModel.perspective_2d),
            newSateliteMode = (uid == 3);
        mapSettingsModel.setPerspective(newPerspective) ;
        mapSettingsModel.setSateliteMode(newSateliteMode);
    }

    function loadSelected() {
        var perspective = mapSettingsModel.perspective,
            sateliteMode = mapSettingsModel.sateliteMode;

        toggleSwitchModel.get(0).preSelected = !sateliteMode && (perspective == mapSettingsModel.perspective_2d);
        toggleSwitchModel.get(1).preSelected = !sateliteMode && (perspective == mapSettingsModel.perspective_3d);
        toggleSwitchModel.get(2).preSelected = sateliteMode;
    }
}
