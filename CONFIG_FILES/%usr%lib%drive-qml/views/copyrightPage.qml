import QtQuick 1.1
import components 1.0
import "../components/components.js" as Components

Page {
    id: page
    title: qsTrId("qtn_drive_copyright_item")

    Flickable {
        id: view
        anchors.top: page.titleBottom
        anchors.left: page.left
        anchors.right: page.right
        anchors.bottom: page.bottom
        anchors.margins: 16
        clip: true
        flickableDirection: Flickable.VerticalFlick

        contentWidth: content.width;
        contentHeight: logos.height + notice.height + link.height + 30

        Item {
            id: content
            width: page.width - 32

            Item {
                id: logos
                width: content.width
                height: 80

                Image {
                    id: navteqLogo
                    height: 80
                    width: 163
                    anchors.top: parent.top
                    anchors.left: parent.left
                    source: Components.About.navteq.uri;
                }

                Image {
                    id: nav2Logo
                    width: 112
                    height: 80
                    anchors.top: parent.top
                    anchors.left: navteqLogo.right
                    anchors.leftMargin: 15
                    source: Components.About.nav2.uri;
                }
            }

            Text {
                id: notice
                anchors.top: logos.bottom
                anchors.topMargin: 15
                anchors.left: content.left
                font.family: Components.Common.font.family
                font.pixelSize: 24
                width: content.width
                color: "white"
                wrapMode: Text.WordWrap
                text: "2009 NAVTEQ. All Rights Reserved<br/>" +
                      "www.navteq.com<br/>" +
                      "<br/>" +
                      "2009 NavInfo Co Ltd. All Rights Reserved<br/>" +
                      "www.nav2.com.cn<br/>" +
                      "<br/>" +
                      "2002 Planetary Visions Ltd.<br/>" +
                      "planetaryvisions.com<br/>" +
                      "<br/>" +
                      "2009 DigitalGlobe, Inc.<br/>" +
                      "Crown Copyright 100048088<br/>" +
                      "<br/>" +
                      "Aprobado por el Instituto Geografico Militar.<br/>" +
                      "Numero de expediente GG081531/Sept 5 2008<br/>" +
                      "<br/>" +
                      "SRTM V4, 2008, CIAT<br/>" +
                      "http://srtm.csi.cgiar.com<br/>" +
                      "Royal Jordanian Geographic Centre<br/>" +
                      "Iran Maps provided by THTC<br/>" +
                      "<br/>" +
                      qsTrId("qtn_drive_copyright_open_source_text");
            }

            Text {
                id: link
                anchors.top: notice.bottom
                anchors.topMargin: 15
                anchors.left: content.left
                width: content.width
                font.family: Components.Common.font.family
                font.pixelSize: 24
                wrapMode: Text.WordWrap
                color: "#57aaef"
                text: qsTrId("qtn_drive_copyright_open_source_link");

                MouseArea {
                    anchors.fill: parent
                    onClicked: window.openUrl(resourcePath + "copyrights/oss.txt")
                }
            }
        }
    }

    ScrollPositionIndicator {
        id: scrollBar
        flickable: view
        anchors.bottom: page.bottom
        anchors.top: page.titleBottom
        anchors.right: page.right
        anchors.topMargin: 16
        anchors.bottomMargin: 16
    }

}
