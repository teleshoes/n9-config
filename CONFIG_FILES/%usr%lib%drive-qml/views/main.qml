import QtQuick 1.1
import components 1.0
import models 1.0
import Settings 1.0

Rectangle {
    id: windowBackground
    width: device.width
    height: device.height
    color: "black"
    z: 1


    property variant ssoManager
    property variant appSettingsModel

    Window {
        id: window
        anchors.centerIn: parent
    }

    Application {
        id: application
        onApplicationShow: {
            windowBackground.z = 2
            device.netPingEnabled = true;
            application._visibilityChangedHandler();
        }
    }

    Settings {
        id: settingsManager
    }

    ModelFactory {
        id: modelFactory
        Component.onCompleted: {
            //Load settings manager
            var settingSetup = {
                "organisation" : "Nokia",
                "application" : "Drive",
                "format" : Settings.IniFormat
            };
            settingsManager.setup(settingSetup);

            _updateModels();
            appSettingsModel.applyAppSettings();

            if (device.desktopClient) {
                launch();
            } else {
                ssoManager.key = application.ssoKey;
                ssoManager.secret = application.ssoSecret;

                /**
                  * This block is used to do SSO check
                  * If SSO needs to be removed, replace this by simply
                  * launch();
                  * And remove an useless method below and the key in appSettingsModel
                ***/
                if (appSettingsModel.get('ssoDone')) {
                    launch();
                } else {
                    ssoManager.forceSignIn = true;
                    ssoManager.signInComplete.connect(onSignInCompleted);
                    ssoManager.checkLogin();
                }
                /* ***** */
            }
        }
    }

    function onSignInCompleted(succeed) {
        ssoManager.signInComplete.disconnect(onSignInCompleted);
        if (succeed) {
            appSettingsModel.set('ssoDone', true);
            launch();
        } else {
            Qt.quit();
        }
    }

    function launch() {
        window.uncoverUI();
        application.show();
    }

    function _updateModels() {
        if (!device.desktopClient) {
            ssoManager = modelFactory.getModel("SSOManager");
        }
        appSettingsModel = modelFactory.getModel("AppSettingsModel");
    }
}
