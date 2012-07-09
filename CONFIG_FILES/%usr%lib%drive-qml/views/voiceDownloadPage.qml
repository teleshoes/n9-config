import QtQuick 1.1
import components 1.0
import "../components/components.js" as Components


Page {
    id: root
    title: qsTrId("qtn_drive_download_new_voice_hdr")
    scrollableList: list

    property variant voiceSkinModel: null;
    property variant appSettingsModel: modelFactory.getModel('AppSettingsModel')
    property variant style: Components.VoiceDownloadPage

    List {
        id: list
        anchors.top: titleBox.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        scrollBarVisible: !loadingDialog.visible

        property bool isDownloading: voiceSkinModel.isActive

        delegate: BorderImage {
            id: remoteDelegate
            source: "../resources/listbg_plain.png"
            border.left: 4
            border.top: 4
            border.right: 64
            border.bottom: 4
            height: style.delegate_height
            width: parent.width
            state: tstate

            Rectangle {
                id: currentDownloadIndicator
                anchors.fill: parent
                color: style.activedItemBGColor
                visible: false
            }

            Rectangle {
                anchors.fill: parent
                color: {
                    return remoteDelegate.state === voiceSkinModel.downloading ?
                             style.cancelActiveColor : Components.ButtonItem.bgColorPressed;
                }
                visible: mouseArea.pressed
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                enabled: false
                onClicked: {
                    if (remoteDelegate.state === voiceSkinModel.downloading) {
                        voiceSkinModel.cancelVoiceDownload(index);
                    } else if (device.online && appSettingsModel.isConnectionAllowed()) {
                        voiceSkinModel.downloadVoice(index);
                    } else {
                        connectAndDownloadVoice(index);
                    }
                }
            }

            Item {
                anchors.fill: parent
                anchors.leftMargin: style.delegate_leftMargin
                anchors.rightMargin: style.delegate_rightMargin

                Text {
                    text: language
                    font.pixelSize: Components.ButtonItem.line1.font.size
                    color: Components.ButtonItem.line1.font.colorActive
                    font.family: Components.ButtonItem.line2.font.family
                    font.capitalization: Font.Capitalize
                    anchors.left: parent.left
                    anchors.right: updateIndicator.visible ? updateIndicator.left : logoPlaceholder.left
                    anchors.bottom: parent.verticalCenter
                    elide: Text.ElideRight
                }

                Text {
                    text: genderString
                    font.pixelSize: Components.ButtonItem.line2.font.size
                    color: root.style.line2color
                    font.family: Components.ButtonItem.line2.font.family
                    font.capitalization: Font.Capitalize
                    anchors.left: parent.left
                    anchors.top: parent.verticalCenter
                }

                Image {
                    id: logoPlaceholder
                    source: style[list.isDownloading ? "downloadIconInactive_uri" : "downloadIcon_uri"]
                    width: style.downloadIcon_width
                    height: style.downloadIcon_width
                    anchors.right: parent.right
                    anchors.rightMargin: style.downloadIcon_rightMargin
                    anchors.bottom: parent.verticalCenter
                }

                Text {
                    id: progressIndicator
                    visible: false
                    text: loadProgress + "%"
                    font.pixelSize: Components.ButtonItem.line2.font.size
                    color: Components.ButtonItem.line2.font.colorActivePressed
                    font.family: Components.ButtonItem.line2.font.family
                    anchors.right: parent.right
                    anchors.top: parent.verticalCenter
                    anchors.topMargin: 5
                }

                Image {
                    visible: hasUpdate && (remoteDelegate.state !== voiceSkinModel.downloading)
                    id: updateIndicator
                    source: style[list.isDownloading ? "hasUpdateIconInactive_uri" : "hasUpdateIcon_uri"]
                    width: style.hasUpdateIcon_width
                    height: style.hasUpdateIcon_height
                    anchors.right: logoPlaceholder.left
                    anchors.rightMargin: style.hasUpdateIcon_rightMargin
                    anchors.bottom: parent.verticalCenter
                }

                Item {
                    id: progressBar
                    height: style.progressBar_height
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: style.progressBar_bottomMargin
                    anchors.right: parent.right
                    visible: false

                    BorderImage {
                        anchors.right: parent.right
                        anchors.left: parent.left
                        height: parent.height
                        horizontalTileMode: BorderImage.Repeat
                        verticalTileMode: BorderImage.Repeat
                        source: style.progressbarBackground_uri

                        border {
                            left: 10
                            top: 5
                            right: 10
                            bottom: 5
                        }
                    }

                    BorderImage {
                        anchors.left: parent.left
                        width: Math.max(loadProgress, 1) / 100 * parent.width
                        height: parent.height
                        source: style.progressbarIndicator_uri
                        horizontalTileMode: BorderImage.Repeat
                        verticalTileMode: BorderImage.Repeat

                        border {
                            left: 5
                            top: 5
                            right: 5
                            bottom: 5
                        }

                        Behavior on width { SmoothedAnimation {
                            velocity: 1200
                        }}
                    }
                }

                Text {
                    id: installingIndicator
                    visible: false
                    text: qsTrId("qtn_drive_installing_voice_not")
                    font.pixelSize: Components.ButtonItem.line2.font.size
                    color: Components.ButtonItem.line2.font.colorActivePressed
                    font.family: Components.ButtonItem.line2.font.family
                    anchors.rightMargin: style.installingText_rightMargin || 5
                    anchors.right: parent.right
                    anchors.top: parent.verticalCenter
                    anchors.topMargin: 5
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: style.selectedIndicator_width
                color: Components.ButtonItem.line2.font.colorActivePressed
                visible: false
                id: selectedIndicator
            }

            SequentialAnimation {
                id: cancelSequence
                running: false

                //Wait 200ms after cancelling the download is triggered
                PauseAnimation {
                    duration: 200
                }

                NumberAnimation {
                    target: progressBar
                    property: "opacity"
                    to: 0
                    duration: 1000
                }

                //Reset models
                ScriptAction {
                    script: {
                        var item = list.listModel.get(index);
                        item.tstate = voiceSkinModel.idle;
                        item.loadProgress = 0;
                        progressBar.opacity = 1;
                    }
                }
            }

            Timer {
                id: cancelTimer
                interval: 1
                onTriggered: voiceSkinModel.cancelVoiceDownload(index);
                running: false;
            }

            states: [
                State {
                    name: voiceSkinModel.cancelled
                    PropertyChanges {
                        target: cancelSequence
                        running: true
                    }
                    StateChangeScript {
                        script: cancelSequence.restart()
                    }
                    PropertyChanges {
                        target: progressBar
                        visible: true
                    }
                    PropertyChanges {
                        target: mouseArea
                        enabled: !list.isDownloading
                    }
                },

                State {
                    name: voiceSkinModel.idle
                    PropertyChanges {
                        target: mouseArea
                        enabled: !list.isDownloading
                    }
                },
                State {
                    name: voiceSkinModel.downloading
                    PropertyChanges {
                        target: mouseArea
                        enabled: true
                    }
                    PropertyChanges {
                        target: progressIndicator
                        visible: true
                    }
                    PropertyChanges {
                        target: selectedIndicator
                        visible: true
                    }
                    PropertyChanges {
                        target: currentDownloadIndicator
                        visible: true
                    }
                    PropertyChanges {
                        target: progressBar
                        visible: true
                        //animation not finished case
                        opacity: 1
                    }
                    PropertyChanges {
                        target: logoPlaceholder
                        //cancel source
                        source: mouseArea.pressed ? style.cancelIconPressed_uri : style.cancelIcon_uri
                    }
                },
                State {
                    name: voiceSkinModel.installing
                    PropertyChanges {
                        target: selectedIndicator
                        visible: true
                    }
                    PropertyChanges {
                        target: currentDownloadIndicator
                        visible: true
                    }
                    PropertyChanges {
                        target: installingIndicator
                        visible: true
                    }
                    PropertyChanges {
                        target: logoPlaceholder
                        visible: false
                    }
                },
                State {
                    name: voiceSkinModel.downloaderror
                    StateChangeScript {
                        //this is st*, but states are not allowed to set states, so letting timer cancel instead
                        script: cancelTimer.restart()
                    }
                }
            ]
        }

        Dialog {
            id: loadingDialog
            visible: voiceSkinModel.isDownloadingCatalog
            options: QtObject {
                property bool affirmativeVisible: false
                property bool cancelVisible: false
                property bool showSpinner: true
            }
        }

        function connectAndDownloadVoice(index) {
            promptGoOnline(qsTrId("qtn_drive_download_voice_go_online_dlg"), function() {
                voiceSkinModel.downloadVoice(index);
            }, window.pop);
        }

        function promptCatalogConnection(fatal) {
            var message = qsTrId("qtn_drive_download_voice_go_online_dlg");

            promptGoOnline(message, null, function() {
                (fatal === true) && goBack();
            });
        }

        function promptGoOnline(message, yesCallback, noCallback) {
            var dialog = window.showDialog("", {text: message});
            dialog.userReplied.connect(function(reply) {
                if (reply === "ok") {
                    if (!appSettingsModel.isConnectionAllowed()) {
                         appSettingsModel.setConnectionAllowed(true);
                    }

                    if (!device.online && !device.desktopClient) {
                        var onOnlineChanged = function() {
                            device.onlineChanged.disconnect(onOnlineChanged);
                            yesCallback && yesCallback();
                        };

                        device.onlineChanged.connect(onOnlineChanged);
                        device.openNetworkConnection();

                    } else {
                        yesCallback && yesCallback();
                    }
                } else {
                    noCallback && noCallback();
                }
            });
        }

        function onCatalogDownloadErrorChanged() {
            if (voiceSkinModel.catalogDownloadError == voiceSkinModel.noerror) {
                return;
            }

            var text = "", pop = false;
            switch (voiceSkinModel.catalogDownloadError) {
                case voiceSkinModel.timeouterror:                                           //took more than 30 secs
                case voiceSkinModel.networkerror:                                           //plugin (network) problem
                case voiceSkinModel.empty:
                    text = qsTrId("qtn_drive_voice_download_nocatalogue_err");
                    pop = true;
                    break;
                case voiceSkinModel.offlinandempty: return promptCatalogConnection(true);
                case voiceSkinModel.offlineerror: return promptCatalogConnection();
                default: return;                                                            //an error occured
            }

            var dialog = window.showDialog("", {
                text: text,
                cancelVisible: false,
                affirmativeMessage: qsTrId("qtn_drive_ok_btn")
            });

            if (pop) {
                dialog.userReplied.connect(function() {
                    window.pop();
                });
            }
        }

        function goBack() {
            if (window.getCurrentPage() === root) {
                window.pop();
            }
        }

        Connections {
            ignoreUnknownSignals: true
            target: voiceSkinModel
            onPackageDownloaded: goBack()
            onCatalogDownloadErrorChanged: onCatalogDownloadErrorChanged()
        }

        Component.onCompleted: {
            voiceSkinModel = modelFactory.getModel("VoiceSkinModel");
            list.listModel = voiceSkinModel.localVoiceCatalog;

            if (voiceSkinModel.isCatalogEmpty) {
                if (device.online && appSettingsModel.isConnectionAllowed()) {
                    voiceSkinModel.downloadCatalog();
                }
                else {
                    var message = qsTrId("qtn_drive_download_voice_go_online_dlg");
                    promptGoOnline(message, function() {voiceSkinModel.downloadCatalog();}, window.pop);

                }
            }
        }
    }
}


