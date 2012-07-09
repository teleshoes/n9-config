import QtQuick 1.1
import com.nokia.meego 1.1
import "components.js" as Components
import "styles.js" as Style

Rectangle {
    id: searchBox
    height: searchBoxStyle.height
    color: searchBoxStyle.backgroundColor

    property alias text: textInput.text
    property alias inputFocus: textInput.focus
    property variant searchBoxStyle: Style.SearchBox

    signal searchTriggered()
    signal inputChanged()
    signal cleared()

    MouseArea {
        anchors.fill: parent
        onClicked: textInput.focus = true;
    }

    TextField {
        id: textInput
        anchors {
            left: parent.left
            leftMargin: 29
            right: parent.right
            rightMargin: 29
            verticalCenter: parent.verticalCenter
        }
        font.pixelSize: searchBoxStyle.inputSize
        font.family: searchBoxStyle.inputFamily
        inputMethodHints: Qt.ImhNoPredictiveText
        placeholderText: qsTrId("qtn_drive_destination_input")
        platformSipAttributes: SipAttributes {
            actionKeyLabel: qsTrId("qtn_comm_search")
            actionKeyHighlighted: !!textInput.text
            actionKeyEnabled: !!textInput.text
        }
        platformStyle: TextFieldStyle {
            textFont.family: textInput.font.family // for placeholderText, against default
            textFont.pixelSize: textInput.font.pixelSize // for placeholderText, against default
            paddingLeft: icon.width + 26
            paddingRight: clear.width + 20
        }

        onAccepted: {
            textInput.focus = false;
            searchTriggered();
        }

        onTextChanged: {
            onInputChanged();
        }

        function onInputChanged() {
            inputChanged();
        }

        function clear() {
            textInput.text = "";
            searchBox.state = "";
        }

        Image {
            id: icon
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            source: searchBoxStyle.iconSource
        }

        AnimatedImage {
            id: spinner
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            source: searchBoxStyle.spinnerSource
            opacity: 0
        }
    }

    Image {
        id: clear
        anchors.right: textInput.right
        anchors.rightMargin: 10
        anchors.verticalCenter: textInput.verticalCenter
        source: searchBoxStyle.clearIconSource
        opacity: 0

        MouseArea {
            anchors.centerIn: parent
            width: 60 // enlarge area for user's fingertip
            height: 60
            onClicked: textInput.clear()
        }
    }

    states: [
        State {
            name: "hasText" //when: textInput.text != ''
            PropertyChanges { target: clear; opacity: 1 }
            PropertyChanges { target: spinner; opacity: 0 }
        },
        State {
            name: "loading"
            PropertyChanges { target: clear; opacity: 0 }
            PropertyChanges { target: spinner; opacity: 1 }
        }
    ]

    transitions: [
        Transition {
            from: ""; to: "hasText"
            NumberAnimation { properties: "opacity" }
        },
        Transition {
            from: "hasText"; to: ""
            NumberAnimation { properties: "opacity" }
        }
    ]

    Connections {
        target: device
        onSoftwareKeyboardKeyPress: textInput.onInputChanged()
    }
}
