import QtQuick 1.1
import components 1.0
import "../../components/components.js" as Components
import "../../utils/ApplicationEventListeners.js" as EventListeners
import models 1.0


Page {
    id: root
    title: qsTrId("qtn_drive_navigation_voice_hdr")
    scrollableList: list
    property variant voiceChanged: false

    property variant guidanceSettingsModel
    property variant style: Components.NavigtionVoiceSettings


    CheckableGroup {
        id: group
    }

    List {
        id: list
        delegate: ButtonItem {
            itemId: voiceid
            title: language
            titleFont.capitalization: Font.Capitalize
            subtitle: genderString
            subtitleFont.capitalization: Font.Capitalize
            group: group
            style: Components.RadioButton
            iconUrl: getSkinIconUrl(isFemale)
            buttonChecked: guidanceSettingsModel && guidanceSettingsModel.voiceSkinId === voiceid
        }
        footer: ButtonItem {
            title: qsTrId("qtn_drive_download_new_voice_btn")
            iconUrl: "../../resources/listitems/download.png"
            onClicked: {
                var voiceSkinModel = modelFactory.getModel("VoiceSkinModel");
                window.push(Qt.createComponent("../voiceDownloadPage.qml"), {
                    invokingPage: root.tag
                });
            }
        }

        anchors.top: titleBottom
        width: parent.width
        height: parent.height - titleBox.height
        onItemClicked: setVoiceSkinId(itemId, true)

        function getSkinIconUrl(isFemale) {
            var gender;

            if (isFemale === true) {
                gender = "female";
            } else if (isFemale == false) {
                gender = "male";
            } else {
                gender = "none";
            }

            return [
                "../../resources/listitems/voice_",
                gender,
                ".png"
            ].join("");
        }
    }

    function onNavigateButtonClicked() {
        if (voiceChanged) {
            window.pop(params.invokingPage);
        }
    }

    function setVoiceSkinId(itemId) {

        if (!itemId) return; //footer clicked
        return EventListeners.packageDownloaded(itemId, true)
    }

    function setVoiceChanged() {
        voiceChanged = true;
    }

    Component.onCompleted: {
        var voiceSkinModel = modelFactory.getModel("VoiceSkinModel");
        guidanceSettingsModel = modelFactory.getModel("GuidanceSettingsModel");

        guidanceSettingsModel.voiceSkinIdChanged.connect(setVoiceChanged);
        list.listModel = voiceSkinModel.localVoiceSkins;
    }

    Component.onDestruction: {
        guidanceSettingsModel.voiceSkinIdChanged.disconnect(setVoiceChanged);
    }
}
