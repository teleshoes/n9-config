import QtQuick 1.1
import "styles.js" as Style

Rectangle {
    width: parent.width;
    height: listItemHeight
    color: suggestionListItemStyle.backgroundColor

    property variant suggestionListItemStyle: Style.SuggestionListItem

    BorderImage {
        id: name
        source:  suggestionListItemStyle.backgroundSource
        anchors.fill:parent

        border.left: 4; border.top: 4
        border.right: 4; border.bottom: 4

        Text {
            id: textLabel;
            anchors.right: parent.right
            anchors.rightMargin: suggestionListItemStyle.rightMargin
            anchors.left: parent.left;
            anchors.leftMargin: suggestionListItemStyle.leftMargin;
            anchors.verticalCenter: parent.verticalCenter;
            text: label
            font.family: suggestionListItemStyle.family
            font.pixelSize: suggestionListItemStyle.size
//            width: parent.width - 150;
            color: suggestionListItemStyle.color
            clip: true
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: list.itemClicked(model.itemId, index, {});
        }
    }
}


