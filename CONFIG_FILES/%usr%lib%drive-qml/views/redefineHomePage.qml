import QtQuick 1.1
import components 1.0
import "../components/styles.js" as Styles
import "../models/ModelFactory.js" as ModelFactory

Page {
    id: page

    property variant myStyle: Styles.Dialog
    property variant appModel
    property variant appSettingsModel

    Image {
        id: icon
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 40
        anchors.topMargin: 40
        source: "../resources/listitems/home.png"
    }

    Text {
        id: title
        anchors.top: icon.top
        anchors.left: icon.right
        anchors.leftMargin: 10
        anchors.right: parent.right

        color: myStyle.color
        font.pixelSize: 42
        font.family: myStyle.fontFamily
        wrapMode: Text.WordWrap
        text: qsTrId("qtn_drive_home_location_dlg")
    }

    AddressTextBlock {
        id: addressTextBlock
        // efforts to put address into center. CenterIn turns texts messy.
        anchors.top: title.bottom
        anchors.topMargin: (button.y - title.y - title.height - height) / 2
        anchors.left: icon.horizontalCenter
        anchors.right: parent.right
        landscape: window.isLandscape
    }

    Button {
        id: button
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 40
        anchors.horizontalCenter: parent.horizontalCenter
        buttonWidth: parent.width * 0.8
        text: qsTrId("qtn_drive_redefine_btn")
        onClicked: window.replace("locationPicker.qml", {
            invokingPage: params.invokingPage
        });
    }

    function onNavigateButtonClicked() {
        appModel.setHomeFlow();
    }

    Component.onCompleted: {
        appModel = ModelFactory.getModel("AppModel");
        appSettingsModel = ModelFactory.getModel("AppSettingsModel");
        addressTextBlock.address = appSettingsModel.getHome();
    }
}
