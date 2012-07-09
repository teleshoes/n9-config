import QtQuick 1.1
import noasso 1.0

NoaInterface {
    id: noaInterface
    property bool ssoChecked: false
    property bool isUiShown: false
    property bool forceSignIn: true
    property string emailAddress: ""
    property string oviAccount: ""
    property int productionServer: 2
    property int stagingServer: 3
    property string appId: "OviDriveMeego"
    property string key: ""
    property string secret: ""
    property string token
    property string noaAccountId

    signal signInComplete(bool success)

    function checkLogin() {
        noaInterface.initialize(key, secret, productionServer, appId, {});
    }

    // Signal is triggered on completion of noaInterface.initialise() API
    onInitializeResponse: {
        console.log("Initialisation successful signing in... STATUS: " + status);
        if (status === 0 || status === 1000) {
            noaInterface.signIn();
        }
    }

    // Signal handler for signal: signInResponse
    onSignInResponse: {
        console.log("sign-in operation completed... STATUS: " + status);
        ssoChecked = true;

        if(status === 0)  {// Sign in successful
            emailAddress = signInResponseData["EmailAddress"]
            oviAccount = signInResponseData["UserId"]
            token = signInResponseData["Token"]
            noaAccountId = signInResponseData["NoaAccountId"]
            device.minimizedChanged.disconnect(onMaximize);
            signInComplete(true);
        } else {
            if (forceSignIn === false) {
                signInComplete(false);
                return;
            }
            if (isUiShown) {
                device.minimizedChanged.disconnect(onMaximize);
                signInComplete(false);
                return;
            }
            isUiShown = true;
            device.minimizedChanged.connect(onMaximize);
            noaInterface.launchUi(0);
        }
    }

    function onMaximize() {
        if (!device.minimized) {
            noaInterface.launchUi(0);
        }
    }
}
