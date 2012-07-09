import QtQuick 1.1
import MapsPlugin 1.0
import "VoiceSkinModel.js" as VoiceSkinData
import "ModelFactory.js" as ModelFactory

Item {
    //required to discconect from online changed
    id: voiceskinmodel
    //package state enums
    property string idle: "idle"
    property string downloading: "downloading"
    property string installing: "installing"
    property string downloaderror: "downloaderror"
    property string cancelled: "cancelled"

    //catalog download errors
    property int noerror: 0
    property int empty: 1
    property int networkerror: 2
    property int offlineerror: 3
    property int offlinandempty: 4
    property int timeouterror: 5

    //private
    property int activeIndex: -1
    property int downloadedPackageId: -1
    property bool cancelledFlag: false
    property bool hasDownloadedCatalog: false
    property bool catalogDownloadTimeout: false
    property bool isResumeStateDone: false
    property bool online: ModelFactory.getModel("AppSettingsModel").connectionAllowed && device.online

    //public
    signal catalogDownloaded()
    signal packageDownloaded(string voiceid)
    signal packageDownloadError(int voiceid)
    signal translationsLoaded()
    property bool isActive: activeIndex !== -1
    property bool isDownloadingCatalog: false
    property int catalogDownloadError: noerror
    property bool isCatalogEmpty: voiceCatalog.catalogList.length === 0

    property ListModel localVoiceCatalog: ListModel {  }
    property ListModel localVoiceSkins: ListModel {  }


    //public methods
    function downloadCatalog() {
        if (!online) return;

        catalogDownloadError = noerror
        isDownloadingCatalog = true;
        voiceCatalog.downloadCatalog();
    }

    function downloadVoice(index, forceOnline) {
        //VoiceCatalog is running a download
        if (isActive) {
            console.log("only one download at a time is allowed");
            return;
        }

        var item = localVoiceCatalog.get(index);
        if (item) {
            activeIndex = index;
            item.tstate = downloading;
            //cancelledFlag may be turned on progmatically, so resetting
            cancelledFlag = false;

            //Go online and download voice skin
            if (forceOnline) {
                MapsPlugin.online = forceOnline;
            }

            var downloadInitSuccess = voiceCatalog.downloadVoice(item.voiceid);
            if (!downloadInitSuccess) {
                console.log("download init failed (" + item.voiceid + ")");
                item.tstate = downloaderror;
                activeIndex = -1;
            }
        } else {
            throw "downloadVoice: UI sync promblems?";
        }
    }

    function cancelVoiceDownload(index) {
        var item = localVoiceCatalog.get(index);

        cancelledFlag = true;
        voiceCatalog.cancelVoiceDownload();

        if (item) {
            item.tstate = cancelled;
            activeIndex = -1;
        } else {
            throw "cancelVoiceDownload failed: UI sync promblems?";
        }
    }

    function getLocalVoiceSkin(skinId) {
        //skin "none" has 0 as id
        if (Number(skinId) === 0) {
            return {
                language: qsTrId("qtn_drive_voice_none")
            };
        }

        //local localized voice skin db saved based on voiceCatalog, may require network connection
        var voiceSkin = VoiceSkinData.localizedLocalSkins[skinId];
        if (voiceSkin === undefined) {
            voiceSkin = voiceCatalog.getLocalVoiceSkin(skinId);         //return string directly from the skin
        }

        return voiceSkin;
    }

    function isFemale(voiceSkin) {
        return !voiceSkin.gender ? null : voiceSkin.gender === "f";
    }

    function voiceSkinSupportsImpUS(voiceid) {
        //none
        if (voiceid === 0) {
            return true;
        }

        var voiceSkin = voiceCatalog.getLocalVoiceSkin(voiceid);
        if (!voiceSkin) {
            throw new Error(voiceid + " does not match to any local voiceskin");
        }

        return voiceSkin.unitFeatures & VoiceSkin.UNIT_IMPERIAL_US;
    }

    //private
    function getRawLocalList() {
        var localVoiceSkins = voiceCatalog.localVoiceSkins,
            localVoiceSkin = null,
            remoteVoicePakage = null,
            voiceid = 0,
            language = "",
            female = false,
            genderString = "",
            rawLocalList = [];

        //Iterate local voice skin and create enriched skins info objects
        for (var i = 0, il = localVoiceSkins.length; i < il; i++) {
            localVoiceSkin = localVoiceSkins[i];
            voiceid = localVoiceSkin.id;

            //ignore TTS, own voice and beeps and vibrations, these may have been preinstalled
            // if (localVoiceSkin.outputType === VoiceSkin.OUTPUT_TYPE_TTS) continue;
            if (voiceid === 1004) continue;
            if (voiceid === 1003) continue;

            female = isFemale(localVoiceSkin);

            //see if the localized list contains a matching id
            if ((remoteVoicePakage = VoiceSkinData.localizedLocalSkins[voiceid])) {
                language = remoteVoicePakage.language
                genderString = remoteVoicePakage.genderString
            } else {
                language = localVoiceSkin.language;
                genderString = (female === true ? ("female") : (female === false ? "male" : ""))
            }

            rawLocalList.push({
                language: language,
                voiceid: voiceid,
                isFemale: female,
                genderString: genderString,
            });
        }

        return rawLocalList;
    }

    function sortLocalList(skinA, skinB) {
        var langA = skinA.language,
            langB = skinB.language,
            compareResult = 0;

        if (langA === langB) {
            compareResult = 0;
        } else {
            var minLength = Math.min(langA.length, langB.length),
                charA = '', charB = '';

            for (var i = 0; i < minLength; i++) {
                charA = langA[i], charB = langB[i];

                if (charA != charB) {
                    compareResult = (charA > charB ? -1 : 1);
                    break;
                }
            }
        }

        return compareResult;
    }

    function onLocalVoiceSkinsChanged() {
        //new voice downloaded, emit signal
        if (downloadedPackageId !== -1) {
            packageDownloaded(downloadedPackageId)
            downloadedPackageId = -1;
        }

        //reset local list
        localVoiceSkins.clear();
        localVoiceSkins.append({
            language: qsTrId("qtn_drive_voice_none"),
            voiceid: 0,
            isFemale: null,
            genderString: ""
        });

        //create and sort raw list and populate local model with it
        var rawLocalList = getRawLocalList();
        rawLocalList.sort(sortLocalList);
        while (rawLocalList.length > 0) {
            localVoiceSkins.append(rawLocalList.pop());
        }
    }

    function setCatalogEmptyError() {
        if (catalogDownloadTimeout) {
            catalogDownloadError = timeouterror;
            catalogDownloadTimeout = false;
        } else if(online) {
            catalogDownloadError = empty;
        } else {
            catalogDownloadError = offlinandempty;
        }
    }

    function populateLocalVoiceCatalog() {
        localVoiceCatalog.clear();
        var list = voiceCatalog.catalogList,
            item = null,
            voiceid = 0,
            name = "",
            listElement = null;

        //iterate plugin catalog and create model
        for (var i = 0, il = list.length; i < il; i++) {
            item = list[i], voiceid = item.id;

            //ignore TTS, own voice and beeps and vibrations
            // if (item.tts === true) continue;
            if (voiceid === 1004) continue;
            if (voiceid === 1003) continue;

            //create object while extracting name, which is originally of format localized  "[language] - [gender]"
            name = item.name;
            listElement = {
                voiceid: voiceid,
                language: name.replace(/\-[^\-]*$/, ""),
                tstate: idle,
                hasUpdate: false,
                genderString: name.replace(/[\S\s]*\-\s*([^\-]*)$/, "$1"),
                isFemale: isFemale(item.gender),
                downloadSize: item.downloadSize,
                loadProgress: 0
            };

            if (!item.isLocal) {
                localVoiceCatalog.append(listElement);
                if (VoiceSkinData.localizedLocalSkins[voiceid]) delete VoiceSkinData.localizedLocalSkins[voiceid];
            } else { // is already locally available
                VoiceSkinData.localizedLocalSkins[voiceid] = {
                    language: listElement.language,
                    genderString: listElement.genderString,
                    gender: item.gender
                }
                //has an update available
                if (voiceCatalog.getLocalVoiceSkin(voiceid).version != item.version) {
                    listElement.hasUpdate = true;
                    localVoiceCatalog.append(listElement);
                }
            }
        }

        translationsLoaded();
    }
    //private onVoiceCatalogChanged helpers//////////////////////

    //private
    function onVoiceCatalogChanged() {
        //locally loaded catalog
        isDownloadingCatalog && (isDownloadingCatalog = false);
        //var list = [{id:1,name: "foo - bar", downloadSize: 200000},{id:2,name: "foo - bar2", downloadSize: 220000}],

        if (voiceCatalog.catalogList.length  === 0) {
            setCatalogEmptyError();
            console.log("No items in catalog, network down? error: " + catalogDownloadError);
            return;
        }

        populateLocalVoiceCatalog();

        //re populate local list in case, to re-localize it
        onLocalVoiceSkinsChanged();
    }

    //private
    Timer {
        id: catalogDownloadTimer
        onTriggeredOnStartChanged: catalogDownloadTimeout = false
        onTriggered: {
            catalogDownloadTimeout = true;
            voiceCatalog.cancelVoiceDownload();
        }
        interval: 30000
    }

    //private
    Timer {
        //connection lost while downloading
        id: voiceDownloadTimer
        onTriggered: {
            if (isActive) {
                //let on download done handle the error
                voiceCatalog.cancelVoiceDownload();
            }
        }
        interval: 20000
    }

    //private
    onIsDownloadingCatalogChanged: {
        if (isDownloadingCatalog) {
            catalogDownloadTimer.restart()
        } else {
            catalogDownloadTimer.stop()
        }
    }

    //private onDownloadDone helpers//////////////////////
    function userCancelled() {
        activeIndex = -1;
        cancelledFlag = false;
    }

    function packageDownloadFailed() {
        console.log(["Package download failed: id(", activeIndex, ")"].join(""));
        packageDownloadError(activeIndex);
        localVoiceCatalog.get(activeIndex).tstate = downloaderror;
        activeIndex = -1;
    }

    function catalogDownloadFailed() {
        console.log("VoiceCatalog download failed");
        //try to offer local list
        if (catalogDownloadTimeout) {
            return onVoiceCatalogChanged();
        }

        catalogDownloadError = networkerror;
        /* catalog download failed code here */
    }
    //private onDownloadDone helpers//////////////////////

    //private singleton
    VoiceCatalog {
        id: voiceCatalog;

        onDownloadDone: {
            isDownloadingCatalog && (isDownloadingCatalog = false)
            if (isResumeStateDone) {//cancelling the download to resume calls here
                isResumeStateDone = false;
                return;
            }
            if (!success) {
                /* Error handling code here */
                if (cancelledFlag === true) {
                    userCancelled();
                } else if (isActive) {
                    packageDownloadFailed();
                } else {
                    catalogDownloadFailed();
                }
                return;
            }

            //package downloaded
            if (isActive) {
                downloadedPackageId = localVoiceCatalog.get(activeIndex).voiceid;
                activeIndex = -1;
                //local list changed emitted, which updates LocalVoiceCatalog for translations and locallist
                //saving id of the downloaded package and emit packageDownloaded after translation
                //is completed
                return;
            }

            //catalog downloaded
            if (!hasDownloadedCatalog) {
                hasDownloadedCatalog = true;
                onlineChanged.disconnect(voiceskinmodel.downloadCatalog);
            }

            //TODO: should we disconnect catalog loads if it is empty
            if (voiceCatalog.catalogList.length === 0) {
                catalogDownloadError = empty;
            } else {
                catalogDownloadError = noerror;
            }

            //catalog downloaded
            catalogDownloaded();
            return;
        }

        onDownloadProgress: {
            var item = localVoiceCatalog.get(activeIndex);
            //to fake resume
            item.loadProgress = Math.max(item.loadProgress, progress);
            if (progress == 100) {
                item.tstate = installing;
            }
        }
    }

    //private
    //download in mid, due to network lost, called in device.online change handler
    function resumeDownload(index) {
        isResumeStateDone = true;
        voiceCatalog.cancelVoiceDownload();
        var item = localVoiceCatalog.get(index)
        if (!voiceCatalog.downloadVoice(item.voiceid)) {
            console.log("download init failed on resuming (" + item.voiceid + ")");
            item.tstate = downloaderror;
            activeIndex = -1;
        }
    }

    Component.onCompleted: {
        voiceCatalog.localVoiceSkinsChanged.connect(onVoiceCatalogChanged);
        voiceCatalog.catalogListChanged.connect(onVoiceCatalogChanged);
        onLocalVoiceSkinsChanged();

        if (! online) {
            //take from cache
            catalogDownloadError = offlineerror;
            onVoiceCatalogChanged();
        }

        voiceskinmodel.onlineChanged.connect(voiceskinmodel.downloadCatalog);

        voiceskinmodel.onlineChanged.connect(function() {
            //assume catalog error was due to lost connection
            if (online && catalogDownloadError !== empty) {
                 catalogDownloadError = noerror;
            }

            if (online) {
                if (voiceDownloadTimer.running) {
                    voiceDownloadTimer.stop();
                }
                if (isActive) {
                    //resume here, atm no resume API available and the download wont pick up
                    resumeDownload(activeIndex);
                }
            } else {
                if (isActive) {
                    voiceDownloadTimer.restart();
                }
            }
        });
        
        MapsPlugin.mapVersionChanged.connect(function() {
             console.log("MapVersionChanged: " + MapsPlugin.mapVersion);
             downloadCatalog();
        });
    }
}
