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
        anchors.bottom: textElement.top
        anchors.bottomMargin: 30
        visible: source !== ""
        source: options && options.iconSource ? options.iconSource : ""
    }

    Text {
        id: textElement
        color: dialogStyle.color
        text: dialog.options.text || ""
        anchors.horizontalCenter: dialog.horizontalCenter
        anchors.verticalCenter: spinner.visible ? undefined : dialog.verticalCenter
        anchors.verticalCenterOffset: spinner.visible ? 0
                                                      : - (buttonContainer.height +
                                                           buttonContainer.anchors.bottomMargin) / 2

        anchors.bottom: spinner.visible ? spinner.top : undefined
        anchors.bottomMargin: spinner.visible ? dialogStyle.textButtomMargin : 0

        width: parent.width - dialogStyle.textSideMargin
        font.pixelSize: options && options.fontSize ? options.fontSize : dialogStyle.size
        font.family: dialogStyle.fontFamily
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
    }

    Spinner {
        id: spinner
        anchors.centerIn: parent
        anchors.verticalCenterOffset: window.isLandscape ? 0
                                                         : - (buttonContainer.height + buttonContainer.anchors.bottomMargin) / 2
        visible: options && options.showSpinner === true ? true : false
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
