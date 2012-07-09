import QtQuick 1.1
import "../utils/Units.js" as Units
import "ModelFactory.js" as ModelFactory
import MapsPlugin 1.0


QtObject {
    id: guidanceSettingsModel
    //keys
    property string baseKey: "GuidanceSettings/"
    property string voiceSkinIdKey: "voiceSkin"
    property string lowSpeedOffsetKey: "lowSpeedOffset"
    property string highSpeedOffsetKey: "highSpeedOffset"
    property string speedWarnerAudioKey: "speedWarnerAudio"
    property string speedWarnerKey: "speedWarner"

    property string voice_skin_none: "0"

    //used everywhere
    property int voiceSkinId: (ModelFactory && ModelFactory.settingsManager) ?
            getVoiceSkinId() : Number(voice_skin_none);

    property real lowSpeedOffset: 0
    property real highSpeedOffset: 0
    property bool speedWarnerAudioOn: false
    property bool speedWarnerOn: false

    //signals
    signal voiceSkinIdChanged(int newSkinId)
    signal speedWarnedChanged(bool enabled)

    function getVoiceSkinId() {
        var currentSkin = ModelFactory.settingsManager.value(baseKey + voiceSkinIdKey);
        if (!isNaN(currentSkin)) {
            voiceSkinId = Number(currentSkin);
            return Number(currentSkin);
        }

        //no skin id available, set to system locale if available,
        //only on 1st run
        var currentLang = device.language;

        console.log("-----------------> DEVICE LANGUAGE IS " + device.language);
        if (!currentLang) return voice_skin_none;

        var reg = new RegExp(currentLang, "i"),
            catalog = Qt.createQmlObject("import MapsPlugin 1.0; VoiceCatalog {}", guidanceSettingsModel, null),
            localList = catalog.localVoiceSkins,
            skin = null, voiceid = voice_skin_none;

        for (var i = 0, il = localList.length; i < il; i++) {
            skin = localList[i];
            if (reg.test(skin.marcCode) && skin.outputType == VoiceSkin.OUTPUT_TYPE_AUDIO) {
                voiceid = skin.id;
                console.log("Setting voiceskin to default: " + skin.language);
                break;
            }
        }

        catalog.destroy();
        setVoiceSkinId(voiceid);
        return voiceid;
    }

    function setVoiceSkinId(newSkinId) {
        if (!canSelectVoiceSkin(newSkinId)) {
            return console.log("NO CAN DO CHARLIE!")
        }

        ModelFactory.settingsManager.setValue(baseKey + voiceSkinIdKey, newSkinId);
        voiceSkinId = Number(newSkinId);
        voiceSkinIdChanged(newSkinId);
    }

    function voiceSkinSupportsImpUS(voiceid) {
        return ModelFactory.getModel("VoiceSkinModel").voiceSkinSupportsImpUS(Number(voiceid));
    }

    function canSelectVoiceSkin(voiceid) {
        return Units.currentSystem !== Units.SYSTEM_IMPERIAL_US || voiceSkinSupportsImpUS(voiceid)
    }

    /*
      param lowSpeedOffset, Number or string representation of, speed offset for speeds under 80 km/h in m/s
      param lowSpeedOffset, Number or string representation of, speed offset for speeds over 80 km/h in m/s
      */
    function setSpeedWarnerOptions(pLowSpeedOffset, pHighSpeedOffset) {
        if (!isNaN(pLowSpeedOffset)) {
            //keeping 3 decimals to give UI illusion of all values possible
            //in reality some values will be lost due to conversions
            lowSpeedOffset = Math.round(Number(pLowSpeedOffset) * 1000) / 1000;
            ModelFactory.settingsManager.setValue(baseKey + lowSpeedOffsetKey, "" + lowSpeedOffset);
        }
        if (!isNaN(pHighSpeedOffset)) {
            highSpeedOffset = Math.round(Number(pHighSpeedOffset) * 1000) / 1000;
            ModelFactory.settingsManager.setValue(baseKey + highSpeedOffsetKey, "" + highSpeedOffset);
        }
    }

    function setSpeedWarnerAudio(pOn) {
        speedWarnerAudioOn = (pOn === true)
        ModelFactory.settingsManager.setValue(baseKey + speedWarnerAudioKey, "" + speedWarnerAudioOn)
    }

    function setSpeedWarner(pOn) {
        speedWarnerOn = (pOn === true)
        ModelFactory.settingsManager.setValue(baseKey + speedWarnerKey, "" + speedWarnerOn)

        speedWarnedChanged(speedWarnerOn);
    }

    //private
    function getSpeedWarnerLowSpeedOffsetFromFile() {
        var lLowSpeedOffset = ModelFactory.settingsManager.value(baseKey + lowSpeedOffsetKey);
        return isNaN(lLowSpeedOffset) ? 0 : Number(lLowSpeedOffset);
    }

    //private
    function getSpeedWarnerHighSpeedOffsetFromFile() {
        var lHighSpeedOffset = ModelFactory.settingsManager.value(baseKey + highSpeedOffsetKey);
        return isNaN(lHighSpeedOffset) ? 0 : Number(lHighSpeedOffset);
    }

    //private
    function getSpeedWarnerAudioFromFile() {//default to true
        return ModelFactory.settingsManager.value(baseKey + speedWarnerAudioKey) !== "false";
    }

    //private
    function getSpeedWarnerFromFile() { //default to true
        return ModelFactory.settingsManager.value(baseKey + speedWarnerKey) !== "false";
    }

    Component.onCompleted: {
        setSpeedWarner(getSpeedWarnerFromFile());
        setSpeedWarnerAudio(getSpeedWarnerAudioFromFile());
        setSpeedWarnerOptions(getSpeedWarnerLowSpeedOffsetFromFile(), getSpeedWarnerHighSpeedOffsetFromFile());
    }
}
