import QtQuick 1.1
import "styles.js" as Style

BorderImage {
    id: name
    source: recentSearchListItemStyle.backgroundSource[menuStyle ? "normal" : "plain"]

    width: parent.width;
    height: listItemHeight
    border.left: 4; border.top: 4
    border.right: 64; border.bottom: 4

    property variant recentSearchListItemStyle: Style.RecentSearchListItem

    Rectangle {
        anchors.fill: parent
        color: recentSearchListItemStyle.backgroundColorPressed
        visible: mouseArea.pressed
    }

    Text {
        id: textLabel;
        elide: Text.ElideRight
        width: parent.width - recentSearchListItemStyle.marginSides
        anchors.left: parent.left;
        anchors.leftMargin: recentSearchListItemStyle.leftMargin;
        anchors.top: (model.line2) ? parent.top : undefined
        anchors.topMargin: (model.line2) ? recentSearchListItemStyle.topMargin : 0
        anchors.verticalCenter: parent.verticalCenter;
        text: label
        font.family: recentSearchListItemStyle.family
        font.pixelSize: recentSearchListItemStyle.size
        color: recentSearchListItemStyle.color
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: list.itemClicked(model.itemId, index, {});
    }
}
