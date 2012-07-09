import QtQuick 1.1
import "styles.js" as Style


Rectangle {
    id: dialog

    property variant favoritesStyle: Style.Favorites
    property variant dialogStyle: Style.Dialog
    property variant searchBoxStyle: Style.SearchBox
    property variant pageStyle: Style.Page
    property variant options

    property alias cursorPosition: textInput.cursorPosition
    property alias inputFocus: textInput.focus

    signal userReplied(string answer, string name)

    anchors.fill: parent
    color: dialogStyle.backgroundColor

    MouseArea {
        anchors.fill: parent
        onClicked: {
            // stop clicks going through
        }
    }

    Text {
        id: titleText
        height: pageStyle.titleHeight
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: 16
        verticalAlignment: Text.AlignVCenter
        font.family: pageStyle.titleFamily
        font.pixelSize: pageStyle.titleSize
        color: pageStyle.titleColor
        text: dialog.options.text
    }

    BorderImage {
        id: borderImage
        source: searchBoxStyle.backgroundSource[textInput.focus ? "active" : "normal"]
        anchors.margins: searchBoxStyle.margins
        horizontalTileMode: BorderImage.Repeat
        verticalTileMode: BorderImage.Stretch
        border { left: 29; top: 5; right: 29; bottom: 5 }

        anchors {
            left: parent.left;
            right: parent.right
            top: titleText.bottom
        }
    }

    TextInput {
        id: textInput
        anchors {
            left: borderImage.left;
            right: borderImage.right
            top: borderImage.top
            leftMargin: favoritesStyle.dialog.inputLeftMargin;
            rightMargin: favoritesStyle.dialog.inputRightMargin;
            topMargin: favoritesStyle.dialog.inputTopMargin;
        }
        text: (options && options.locationName)

        height: 50
        //focus: inputFocus
        selectByMouse: true
        inputMethodHints: Qt.ImhNoPredictiveText

        onAccepted: {
            textInput.focus = false
            //searchTriggered()
        }

        function clear() {
            textInput.text = "";
        }

        font.pixelSize: favoritesStyle.dialog.inputSize
        font.family: favoritesStyle.dialog.inputFamily

        Component.onCompleted: {
            textInput.focus = true;
        }
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
        anchors.top: borderImage.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter: dialog.horizontalCenter

        Button {
            id: affirmativeButton
            visible: !!(dialog.options && dialog.options.affirmativeVisible !== false && true)
            text: dialog.options && dialog.options.affirmativeMessage || qsTrId("qtn_drive_yes_btn_short")
            onClicked: {
                device.softwareKeyboardVisible = false;
                handleResponse("ok");
            }
            enabled: !!textInput.text.trim()
        }

        Button {
            id: cancelButton
            visible: !!(dialog.options && dialog.options.cancelVisible !== false && true)
            text: dialog.options && dialog.options.cancelMessage || qsTrId("qtn_drive_cancel_btn_short")
            onClicked: {
                device.softwareKeyboardVisible = false;
                handleResponse("cancel");
            }
            normalBackground: Style.Button.backgroundImageSource.normal
        }
    }

    function handleResponse(btnId) {
        userReplied(btnId, textInput.text.trim());
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
