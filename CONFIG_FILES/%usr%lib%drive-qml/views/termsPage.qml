import QtQuick 1.1
import components 1.0
import "../components/styles.js" as Styles

Page {
    id: page
    title: qsTrId("qtn_drive_terms_item")

    property variant texts: [
        qsTrId("qtn_drive_terms_text"),
        toRichText(qsTrId("qtn_drive_tc_service_terms_link"), Styles.URL_TERMS),
        toRichText(qsTrId("qtn_drive_tc_privacy_policy_link"), Styles.URL_POLICY),
        toRichText(qsTrId("qtn_drive_your_privacy_in_drive_link"), Styles.URL_YOUR_PRIVACY)
    ]

    function toRichText(text, url) {
        return "<a href='" + url + "'><font color='#57aaef'><b>" + text + "</b></font></a>";
    }

    Flickable {
        anchors.top: page.titleBottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
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
            text: texts.join("<br /><br />")
            onLinkActivated: window.openUrl(link)
        }
    }
}
