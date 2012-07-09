import QtQuick 1.1
import components 1.0
import "../components/components.js" as Components

Page {
    id: page
    scrollableList: list

    Item {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 70
        anchors.margins: 20;

        Text {
            id: title
            anchors.top: parent.top
            anchors.left: parent.left
            height: header.height
            text: "Drive v" + mambaVersion + " <br/>libmos-qml v" + MapsPlugin.pluginVersion
            font.family: Components.Common.font.family
            font.pixelSize: 30
            color: "white"
            verticalAlignment: Text.AlignVCenter
        }
    }

    VisualItemModel {
        id: listModel

        ButtonItem {
            id: support
            itemId: "support"
            title: qsTrId("qtn_drive_support_item")
            hasIcon: false
            //hideArrow: true
        }

        ButtonItem {
            id: terms
            itemId: "terms"
            title: qsTrId("qtn_drive_terms_item")
            hasIcon: false
        }

        ButtonItem {
            id: copyright
            itemId: "copyright"
            title: qsTrId("qtn_drive_copyright_item")
            hasIcon: false
        }

        ButtonItem {
            id: madeby
            itemId: "credits"
            title: qsTrId("qtn_drive_credits_item")
            hasIcon: false
        }
    }

    List {
        id: list
        listModel: listModel
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        menuStyle: false

        onItemClicked: {
            var targetPage;

            switch (itemId) {
                case "copyright":
                    targetPage = "copyrightPage.qml";
                    break;
                case "terms":
                    targetPage = "termsPage.qml";
                    break;
                case "credits":
                    targetPage = "creditsPage.qml";
                    break;
                case "support":
                    window.openUrl("http://nokia.mobi/apps/drive/meego/support");
                    break;
                default:
                    break;
            }

            targetPage && window.push(targetPage, {
                invokingPage: page.tag
            });
       }
    }
}
