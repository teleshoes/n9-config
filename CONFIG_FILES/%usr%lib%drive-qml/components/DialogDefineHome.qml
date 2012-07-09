import QtQuick 1.1
import "styles.js" as Styles


Rectangle {
    id: dialog

    anchors.fill: parent
    color: myStyle.backgroundColor
    property variant myStyle: Styles.Dialog
    property variant options

    signal userReplied(string answer)

    function handleResponse(btnId) {
        userReplied(btnId);
        dialog.destroy();
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            // stop clicks going through
        }
    }

    Text {
        id: title
        anchors.top: parent.top
        anchors.topMargin: 40
        anchors.left: parent.left
        anchors.leftMargin: 40
        anchors.right: parent.right

        color: myStyle.color
        font.pixelSize: 42
        font.family: myStyle.fontFamily
        wrapMode: Text.WordWrap
        text: qsTrId("qtn_drive_your_home_location?_dlg")
    }

    Image {
        id: addressIcon
        anchors.top: addressTextBlock.top
        anchors.right: addressTextBlock.left
        anchors.rightMargin: 10
        source: addressTextBlock.address ? addressTextBlock.address.iconUrlList : ""
    }

    AddressTextBlock {
        id: addressTextBlock
        // efforts to put address into center. CenterIn turns texts messy.
        anchors.top: title.bottom
        anchors.topMargin: (hint.y - title.y - title.height - height) / 2
        anchors.left: title.left
        anchors.leftMargin: 70
        anchors.right: parent.right
        landscape: window.isLandscape
        address: options.address
    }

    Text {
        id: hint
        anchors.left: title.left
        anchors.bottom: buttonContainer.top
        anchors.bottomMargin: window.isLandscape ? 10 : 30
        anchors.right: parent.right

        color: myStyle.color
        font.pixelSize: 26
        font.family: myStyle.fontFamily
        wrapMode: Text.WordWrap
        text: qsTrId("qtn_drive_home_can_be_changed_dlg")
        visible: !dialog.options.setting
    }

    Row {
        id: buttonContainer
        spacing: 20
        anchors.bottom: dialog.bottom
        anchors.bottomMargin: 40
        anchors.horizontalCenter: dialog.horizontalCenter

        Button {
            text: qsTrId("qtn_drive_yes_btn_short")
            onClicked: handleResponse("ok")
            buttonWidth: dialog.width * 0.4
        }

        Button {
            text: qsTrId("qtn_drive_no_btn_short")
            onClicked: handleResponse("cancel")
            normalBackground: Styles.Button.backgroundImageSource.normal
            buttonWidth: dialog.width * 0.4
        }
    }
}
