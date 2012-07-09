import QtQuick 1.1
import "styles.js" as Style
import models 1.0


Item {
    id: speedWarnerSwitch
    height: Style.SpeedWarnerSwitch.height
    signal itemSelected();

    ToggleSwitch {
        id: switcher
        height: Style.ToggleButton.height[page.isLandscape ? "landscape" : "portrait"]
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
                label: "!ON"
                identifier: 1
                buttonWidth: 0
                preSelected: false
                imageSource: "" //"../resources/visual_acoustic_alert.png"
            }
            /*
            ListElement {
                label: ""
                identifier: 2
                buttonWidth: 0
                preSelected: false
                imageSource: "../resources/no_acoustic_alert.png"
            } */
            ListElement {
                label: "!OFF"
                identifier: 3
                buttonWidth: 0
                preSelected: false
                imageSource: ""
            }
        }
    }

    Component.onCompleted: {
        var guidanceSettingsModel = modelFactory.getModel("GuidanceSettingsModel");
        guidanceSettingsModel.speedWarnerAudioOnChanged.connect(loadSelected);
        guidanceSettingsModel.speedWarnerOnChanged.connect(loadSelected);

        switcher.buttonModel.get(0).label = qsTrId("qtn_drive_on_tgl");
        switcher.buttonModel.get(1).label = qsTrId("qtn_drive_off_tgl");
        loadSelected();

    //    switcher.buttonModel.get(0).label = qsTrId("ON");
    //    switcher.buttonModel.get(1).label = qsTrId("MUTE");
    //    switcher.buttonModel.get(2).label = qsTrId("OFF");
    }

    function save(uid) {
        var guidanceSettingsModel = modelFactory.getModel("GuidanceSettingsModel");
        switch (uid) {
        case 1:
            guidanceSettingsModel.setSpeedWarnerAudio(true);
            guidanceSettingsModel.setSpeedWarner(true);
            break;
        case 2:
            guidanceSettingsModel.setSpeedWarnerAudio(false);
            guidanceSettingsModel.setSpeedWarner(true);
            break;
        case 3:
            guidanceSettingsModel.setSpeedWarnerAudio(false);
            guidanceSettingsModel.setSpeedWarner(false);

            break;
        }
    }

    function loadSelected() {
        var guidanceSettingsModel = modelFactory.getModel("GuidanceSettingsModel");
        var warner = guidanceSettingsModel.speedWarnerOn
        //var audio = guidanceSettingsModel.speedWarnerAudioOn

        //toggleSwitchModel.get(0).preSelected = (warner === true) && (audio === true);
        //toggleSwitchModel.get(1).preSelected = (warner === true) && (audio === false);
        //toggleSwitchModel.get(2).preSelected = (warner === false);

        toggleSwitchModel.get(0).preSelected = (warner === true);
        toggleSwitchModel.get(1).preSelected = (warner === false);
    }
}
