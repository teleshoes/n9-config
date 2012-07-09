 function packageDownloadFail() {
    var text = "";
    if (device.online) {
        text = qsTrId("qtn_drive_voice_download_no_server_connection_err");
    } else {
        text = qsTrId("qtn_drive_voice_download_network_lost_err");
    }
    window.showDialog("", {
        text: text,
        cancelVisible: false,
        affirmativeMessage: qsTrId("qtn_drive_ok_btn")
    });
}

function packageDownloaded(voiceid, goback) {

    if (!voiceid) return; //footer clicked

    var guidanceSettingsModel = modelFactory.getModel("GuidanceSettingsModel");
    var appSettingsModel = modelFactory.getModel("AppSettingsModel");

    if (guidanceSettingsModel.canSelectVoiceSkin(voiceid)) {
        guidanceSettingsModel.setVoiceSkinId(voiceid);
        goback === true && window.pop(params.invokingPage)

        return;
    }
    var skin = modelFactory.getModel("VoiceSkinModel").getLocalVoiceSkin(voiceid);

    var language = (skin && skin.language) ? skin.language : ""

    var dialog = window.showDialog("", {
        text: qsTrId("qtn_drive_voice_activation_err").replace("\"[§]", language),
        affirmativeMessage: qsTrId("qtn_drive_yes_btn_short"),
        cancelMessage: qsTrId("qtn_drive_no_btn_short")
    });

    dialog.userReplied
        .connect(function(answer) {
                     if (answer == "ok") {
                         appSettingsModel.setUnitSystem(appSettingsModel.units_impUK);
                         guidanceSettingsModel.setVoiceSkinId(voiceid);
                         goback === true && window.pop(params.invokingPage)
                     }
                 });
}

var connected = false;

function connectVoiceSkinModelListeners() {
    if (connected === false) {
        var voiceSkinModel = modelFactory.getModel("VoiceSkinModel")
        voiceSkinModel.packageDownloadError.connect(packageDownloadFail)
        voiceSkinModel.packageDownloaded.connect(packageDownloaded)
        connected = true
    }
}
