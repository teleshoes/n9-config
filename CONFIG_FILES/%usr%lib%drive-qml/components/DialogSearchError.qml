import QtQuick 1.1
import "styles.js" as Style


Rectangle {
    id: dialog

    property variant dialogStyle: Style.Dialog
    property variant options

    signal userReplied(string answer)

    anchors.fill: parent
    color: dialogStyle.backgroundColor

    MouseArea {
        anchors.fill: parent
        onClicked: {
            // stop clicks going through
        }
    }

    Image {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: searchText.top
        anchors.bottomMargin: 20
        visible: true
        source: "../resources/alertIcon.png"
    }

    Text {
        id: searchText
        width: parent.width - dialogStyle.textSideMargin
        anchors.bottom: textElement.top
        anchors.bottomMargin: 15
        anchors.horizontalCenter: dialog.horizontalCenter
        text: dialog.options.searchString
        color: "#1080DD"
        font.pixelSize: dialogStyle.size
        font.family: dialogStyle.fontFamily
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
    }

    Text {
        id: textElement
        color: dialogStyle.color
        text: dialog.options.text
        anchors.horizontalCenter: dialog.horizontalCenter
        anchors.verticalCenter: dialog.verticalCenter
        anchors.verticalCenterOffset: window.isLandscape ? 0 : - (buttonContainer.height + buttonContainer.anchors.bottomMargin) / 2

        width: parent.width - dialogStyle.textSideMargin
        font.pixelSize: dialogStyle.size
        font.family: dialogStyle.fontFamily
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
    }

    states:  [
        State {
            name: "row"
            when: window.isLandscape || (dialog.options && !dialog.options.columnLayout)
            PropertyChanges { target: buttonContainer; columns: 2; rows: 1 }
            PropertyChanges { target: affirmativeButton; buttonWidth: getButtonWidth() }
            PropertyChanges { target: cancelButton; buttonWidth: getButtonWidth() }
        },
        State {
            name: "column"
            when: !window.isLandscape && dialog.options && dialog.options.columnLayout
            PropertyChanges { target: buttonContainer; columns: 1; rows: 2 }
            PropertyChanges { target: affirmativeButton; buttonWidth: getButtonWidth() }
            PropertyChanges { target: cancelButton; buttonWidth: getButtonWidth() }
        }
    ]

    Grid {
        id: buttonContainer
        spacing: 20
        anchors.bottom: dialog.bottom
        anchors.bottomMargin: window.isLandscape ? 22 : 40
        anchors.horizontalCenter: dialog.horizontalCenter

        Button {
            id: affirmativeButton
            visible: !!(dialog.options && dialog.options.affirmativeVisible !== false && true)
            text: dialog.options && dialog.options.affirmativeMessage || qsTrId("qtn_drive_yes_btn_short")
            onClicked: handleResponse("ok")
        }

        Button {
            id: cancelButton
            visible: !!(dialog.options && dialog.options.cancelVisible !== false && true)
            text: dialog.options && dialog.options.cancelMessage || qsTrId("qtn_drive_cancel_btn_short")
            onClicked: handleResponse("cancel")
            normalBackground: Style.Button.backgroundImageSource.normal
        }
    }

    function handleResponse(btnId) {
        userReplied(btnId);
        dialog.destroy();
    }

    function getButtonWidth() {
        var factor;
        if (window.isLandscape) {
            factor = 0.4;
        } else if (dialog.options && dialog.options.columnLayout) {
            factor = 0.8;
        } else {
            factor = affirmativeButton.visible && cancelButton.visible ? 0.4 : 0.8;
        }

        return dialog.width * factor;
    }
}
