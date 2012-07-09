import QtQuick 1.1
import com.nokia.meego 1.1
import "styles.js" as Styles

TextField {
    id: input
    property RegExpValidator emailValidator: RegExpValidator {
        regExp: /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/
    }
    validator: emailValidator // Seems useless when errorHighlight keeps false

    inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhEmailCharactersOnly | Qt.ImhNoPredictiveText
    errorHighlight: false
    font.family: Styles.NOKIA_STANDARD_REGULAR
    font.pixelSize: 24
    placeholderText: qsTrId("qtn_drive_nps_emailaddress")
    text: ""

    platformStyle: TextFieldStyle {
        paddingLeft: 25
        paddingRight: 25
        textColor: "#191919"
        textFont.family: input.font.family // for placeholderText
        textFont.pixelSize: input.font.pixelSize // for placeholderText
    }
    platformSipAttributes: SipAttributes {
        actionKeyLabel: qsTrId("qtn_comm_command_done")
        actionKeyHighlighted: !!input.text
        actionKeyEnabled: !!input.text
    }

    property bool myActiveFocus: activeFocus

    onCursorPositionChanged: { // to fix drawback from activeFocus
        if (!myActiveFocus && activeFocus) {
            platformOpenSoftwareInputPanel();
            myActiveFocus = activeFocus;
        }
    }
    onActiveFocusChanged: {
        myActiveFocus = activeFocus;
    }
    Keys.onReturnPressed: {
        myActiveFocus = false;
        platformCloseSoftwareInputPanel();
    }
}
