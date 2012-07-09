import QtQuick 1.1
import com.nokia.meego 1.1
import components 1.0
import "../models/ModelFactory.js" as ModelFactory
import "../components/styles.js" as Styles

Page {
    id: page
    objectName: "windowContent" // attempt to correct EditBubble/Magnifier behavior
    title: qsTrId("qtn_drive_nps_feedback_hdr")
    scrollableList: visualList

    property variant ssoManager
    property variant appSettingsModel
    property bool ssoChecked // initialized in onCompleted, to set should Email/Ovi Email visible
    property bool ssoValid // initialized in onCompleted, to set which of Email/Ovi Email should be visible

    states: [
        State {
            name: "showAll"
            when: visualModel.sliderTouched
        }
    ]

    transitions: [
        Transition {
            to: "showAll"
            SequentialAnimation {
                NumberAnimation {
                    targets: [loader_comment, loader_email, cancontactCheckbox, sendButton, privacy]
                    property: "opacity"; to: 1; duration: 800
                }
                // better than to use a StateChangeScript because of the execution order
                ScriptAction { script: visualList.updateScrollButtons() }
            }
        }
    ]

    Component {
        id: component_score
        Column {
            id: block_score
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 20

            signal setValue(int value)

            Text {
                anchors.left: parent.left
                anchors.right: parent.right
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WordWrap
                font.family: Styles.NOKIA_STANDARD_REGULAR
                font.pixelSize: 30
                color: "white"
                text: qsTrId("qtn_drive_nps_howlikely")
            }

            Item {
                height: 150
                anchors.left: parent.left
                anchors.right: parent.right

                Slider {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    minValue: 1
                    maxValue: 10
                    initialValue: 7
                    anchors.verticalCenter: parent.verticalCenter

                    onValueChanged: block_score.setValue(value)
                }
                Text {
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    width: page.width * 0.4
                    horizontalAlignment: Text.AlignLeft
                    wrapMode: Text.WordWrap
                    font.family: Styles.NOKIA_STANDARD_REGULAR
                    font.pixelSize: 24
                    color: "white"
                    text: qsTrId("qtn_drive_nps_notlikely")
                }
                Text {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    width: page.width * 0.4
                    horizontalAlignment: Text.AlignRight
                    wrapMode: Text.WordWrap
                    font.family: Styles.NOKIA_STANDARD_REGULAR
                    font.pixelSize: 24
                    color: "white"
                    text: qsTrId("qtn_drive_nps_likely")
                }
            }

            // spacer for margin at component's bottom
            // the height is its height + column's spacing
            Item {
                anchors.left: parent.left
                anchors.right: parent.right
                height: 10
            }
        }
    }

    Component {
        id: component_comment
        Column {
            id: block_comment
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 20

            signal setValue(string value)
            signal setFocus(bool focus)

            Text {
                anchors.left: parent.left
                anchors.right: parent.right
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WordWrap
                font.family: Styles.NOKIA_STANDARD_REGULAR
                font.pixelSize: 24
                color: "white"
                text: qsTrId("qtn_drive_nps_tellus")
            }

            TextArea {
                anchors.left: parent.left
                anchors.right: parent.right
                font.family: Styles.NOKIA_STANDARD_REGULAR
                font.pointSize: 24
                wrapMode: TextEdit.Wrap
                inputMethodHints: Qt.ImhNoPredictiveText
                height: Math.max(88, implicitHeight)

                onTextChanged: block_comment.setValue(text.trim())
                onActiveFocusChanged: block_comment.setFocus(activeFocus)
            }
        }
    }

    Component {
        id: component_email
        Column {
            id: block_email
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 20

            signal setValue(string value)
            signal setFocus(bool focus)

            Text {
                anchors.left: parent.left
                anchors.right: parent.right
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WordWrap
                font.family: Styles.NOKIA_STANDARD_REGULAR
                font.pixelSize: 24
                color: "white"
                text: qsTrId("qtn_drive_nps_contact_email")
            }

            ExtendedTextInput {
                anchors.left: parent.left
                anchors.right: parent.right

                onTextChanged: block_email.setValue(text.trim())
                onMyActiveFocusChanged: block_email.setFocus(myActiveFocus)
            }
        }
    }

    Timer {
        id: thankyou
        interval: 2000
        triggeredOnStart: true
        property variant dialog

        onTriggered: {
            if (dialog) {
                dialog.destroy();
                dialog = undefined;
                if (page == window.getCurrentPage()) window.pop();
            } else {
                dialog = window.showDialog("", {
                    text: qsTrId("qtn_drive_nps_thankyou"),
                    affirmativeVisible: false,
                    cancelVisible: false
                });
            }
        }
    }

    VisualItemModel {
        id: visualModel

        property bool sliderTouched: false
        property variant feedback: {
            score: 0,
            comment: "",
            email: ""
        }

        // QML does not allow directly modification on a variant/dict property
        // where we need this function to help
        function updateFeedback(key, value) {
            var _fb = feedback;
            if (key in _fb && (typeof value == typeof _fb[key])) {
                _fb[key] = value;
            } else {
                console.log("---> Warning: npsPage.updateFeedback(): wrong parameters!");
            }
            feedback = _fb;
        }

        Column {
            id: visualColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 20

            Loader {
                id: loader_score
                anchors.left: parent.left
                anchors.right: parent.right
                sourceComponent: component_score
            }
            Loader {
                id: loader_comment
                anchors.left: parent.left
                anchors.right: parent.right
                sourceComponent: component_comment
            }
            Loader {
                id: loader_email
                anchors.left: parent.left
                anchors.right: parent.right
                sourceComponent: component_email
                visible: ssoChecked && !ssoValid
            }

            Connections {
                target: loader_score.item
                onSetValue: {
                    visualModel.updateFeedback("score", value);
                    visualModel.sliderTouched = true;
                }
            }
            Connections {
                target: loader_comment.item
                onSetValue: visualModel.updateFeedback("comment", value)
                onSetFocus: {
                    vkbSpacer.height = (focus && !isLandscape) ? 85 : 10;
                    if (focus && isLandscape) {
                        visualList.scrollTo(290); // a little bit less than loader_comment.Y
                    } else {
                        visualList.scrollTo(visualList.listItemHeight - visualList.height); // scroll to bottom
                    }
                }
            }
            Connections {
                target: loader_email.item
                onSetValue: visualModel.updateFeedback("email", value)
                onSetFocus: {
                    vkbSpacer.height = focus ? (isLandscape ? 45 : 95) : 10;
                    visualList.scrollTo(visualList.listItemHeight - visualList.height);  // scroll to bottom
                }
            }

            Checkbox  {
                id: cancontactCheckbox
                anchors.left: parent.left
                anchors.right: parent.right
                labelStyle: Styles.LightText
                text: qsTrId("qtn_drive_nps_nokiaaccount")
                visible: ssoChecked && ssoValid
            }

            Text {
                id: privacy
                anchors.left: parent.left
                anchors.right: parent.right
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WordWrap
                font.family: Styles.NOKIA_STANDARD_LIGHT
                font.pixelSize: 24
                color: "white"
                text: qsTrId("qtn_drive_nps_privacy_policy")
            }

            Button {
                id: sendButton
                anchors.horizontalCenter: parent.horizontalCenter
                buttonWidth: 400
                buttonHeight: 88
                color: "white"
                text: qsTrId("qtn_drive_nps_send")

                onClicked: {
                    appSettingsModel.set('npsDone', true);
                    thankyou.start();
                    npsHelper.sendNPS(
                                true, // may move to appSettingsModel as a key when necessary
                                visualModel.feedback.score,
                                visualModel.feedback.comment,
                                ssoValid ? ssoManager.oviAccount : "",
                                ssoValid ? (cancontactCheckbox.selected ? ssoManager.emailAddress : "")
                                         : visualModel.feedback.email,
                                mambaVersion
                                );
                }
            }

            // spacer for margin at component's bottom, in common situation
            // and changed to VKB supportor when activeFocus is true in either input area.
            // the height is its height + column's spacing
            Item {
                id: vkbSpacer
                anchors.left: parent.left
                anchors.right: parent.right
                height: 10 // default height. will be changed according to activeFocus changes.
            }
        }
    }

    List {
        id: visualList
        anchors.top: titleBottom
        width: parent.width
        height: parent.height - titleBox.height
        listItemHeight: visualColumn.height
        listModel: visualModel
    }

    function resetOpacity() {
        // component ids are not enumerable, annoying
        loader_comment.opacity = 0;
        loader_email.opacity = 0;
        cancontactCheckbox.opacity = 0;
        sendButton.opacity = 0;
        privacy.opacity = 0;
        visualList.updateScrollButtons();
    }

    function onSignInCompleted(succeed) {
        ssoManager.signInComplete.disconnect(onSignInCompleted);
        if (succeed) {
            appSettingsModel.set('ssoDone', true); // in most cases, this is not useful, but a double-check.
            ssoValid = !!ssoManager.emailAddress || !!ssoManager.oviAccount;
        }
        ssoChecked = true;
    }

    Component.onCompleted: {
        appSettingsModel = ModelFactory.getModel("AppSettingsModel");
        resetOpacity();
        ssoChecked = false;
        ssoValid = false; // meaningful only when ssoChecked is true.

        if (!device.desktopClient) { // lazy sso signIn
            ssoManager = ModelFactory.getModel("SSOManager");
            ssoValid = !!ssoManager.emailAddress || !!ssoManager.oviAccount;
            // Only ask for sso login again, when sso is not available
            if (ssoValid) {
                ssoChecked = true;
            } else {
                ssoManager.forceSignIn = false; // Do not interrupt UX
                ssoManager.signInComplete.connect(onSignInCompleted);
                ssoManager.checkLogin();
            }
        }
    }

    Component.onDestruction: {
        ssoManager.signInComplete.disconnect(onSignInCompleted);
    }
}
