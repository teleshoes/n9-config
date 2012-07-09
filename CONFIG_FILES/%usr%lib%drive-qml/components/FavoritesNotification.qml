import QtQuick 1.1
import "styles.js" as Styles


Rectangle {
    id: notification

    property variant style: Styles.Favorites.notification

    property string locationText
    property string actionText

    anchors.fill: parent
    color: style.backgroundColor
    opacity: style.opacity
    visible: false

    MouseArea {
        anchors.fill: parent
        onClicked: {
            // stop clicks going through
        }
    }

    Column {
        anchors.centerIn: parent
        width: parent.width - style.textSideMargin

        Text {
            id: textElementLocation
            color: notification.style.locationColor
            text: notification.locationText
            width: parent.width
            font.pixelSize: notification.style.textSize
            font.family: notification.style.locationFontFamilty
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            id: textElementAction
            color: notification.style.actionColor
            text: notification.actionText
            width: parent.width
            font.pixelSize: notification.style.textSize
            font.family: notification.style.actionFontFamilty
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }
    }

    property Timer visibilityTimer: Timer {
        repeat: false
        interval: style.duration
        onTriggered: hide();
    }

    function show() {
        notification.visible = true;
        notification.visibilityTimer.start();
    }

    function hide() {
        notification.visible = false;
    }
}
