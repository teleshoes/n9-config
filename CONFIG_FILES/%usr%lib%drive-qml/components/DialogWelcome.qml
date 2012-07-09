import QtQuick 1.1
import "styles.js" as Styles


Rectangle {
    id: dialog

    anchors.fill: parent
    color: myStyle.backgroundColor
    property variant myStyle: Styles.Dialog
    property variant texts: [
        qsTrId("qtn_drive_terms_text"),
        toRichText(qsTrId("qtn_drive_more_info_about_privacy_link"), Styles.URL_YOUR_PRIVACY),
        qsTrId("qtn_drive_welcome_screen_continue_text"),
        toRichText(qsTrId("qtn_drive_service_terms_link"),Styles.URL_TERMS),
        toRichText(qsTrId("qtn_drive_privacy_policy_link"), Styles.URL_POLICY)
    ]

    signal userReplied(string answer)
    function toRichText(text, url) {
        return "<a href='" + url + "'><font color='#57aaef'><b>" + text + "</b></font></a>";
    }

    function handleResponse(btnId) {
        userReplied(btnId);
        dialog.destroy();
    }

    Flickable {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: buttonContainer.top
        anchors.margins: 16
        clip: true
        contentWidth: width
        contentHeight: Math.max(height, content.height) // flickable only when necessary

        Text {
            id: content
            width: parent.width
            font.family: Styles.RegularText.family
            font.pixelSize: Styles.RegularText.size
            color: Styles.RegularText.color
            wrapMode: Text.WordWrap
            textFormat: Text.RichText
            text: texts[0] + "<br /><br />" + texts[1] + "<br /><br /><br />" + texts[2].replace('[1]', texts[3]).replace('[2]', texts[4])
            onLinkActivated: window.openUrl(link)
        }
    }

    Row {
        id: buttonContainer
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 20
        spacing: 20

        Button {
            id: cancelButton
            text: qsTrId("qtn_drive_cancel_btn_short")
            onClicked: handleResponse("cancel")
            normalBackground: Styles.Button.backgroundImageSource.normal
            buttonWidth: (parent.width - parent.spacing) / 2
        }

        Button {
            id: affirmativeButton
            text: qsTrId("qtn_drive_continue_btn")
            onClicked: handleResponse("ok")
            normalBackground: Styles.Button.backgroundImageSource.normal
            buttonWidth: (parent.width - parent.spacing) / 2
        }
    }
}
