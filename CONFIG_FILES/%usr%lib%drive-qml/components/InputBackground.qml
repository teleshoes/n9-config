import QtQuick 1.1
import "styles.js" as Styles


BorderImage {
    horizontalTileMode: BorderImage.Stretch
    verticalTileMode: BorderImage.Stretch
    source: inputBackgroundStyle.backgroundSource[enabled ? "normal" : "disabled"]

    border {
        left: 25;
        top: 25;
        right: 25;
        bottom: 25
    }

    property variant inputBackgroundStyle: Styles.InputBackground
    property variant input                                              //allow public manipulation of input element

    MouseArea {
        anchors.fill:  parent
        onClicked: input && !input.activeFocus && input.forceActiveFocus()
    }
}
