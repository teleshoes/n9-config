import QtQuick 1.1
import "components.js" as Components

BorderImage {
    id: name
    source: Components.resourcePath + "listbg_plain.png"

    width: parent.width;
    height: listItemHeight
    border.left: 4; border.top: 4
    border.right: 64; border.bottom: 4

    Column {

        anchors.right: parent.right;
        anchors.rightMargin: 60;
        anchors.left: icon.right;
        anchors.leftMargin: 12;
        anchors.verticalCenter: parent.verticalCenter;

        Text {
            id: textLabel;
            wrapMode: Text.WrapAnywhere
            text: label
            font.family: Components.ListItem.line1.font.family
            font.pixelSize: Components.ListItem.line1.font.size
            color: mouseArea.pressed ? "#1080dd" : "#ffffff"
        }

        Text {
            id: line2Container
            visible: !!model.line2;
            text: model.line2 ? model.line2 : ""
            font.family: Components.ListItem.line2.font.family
            font.pixelSize: Components.ListItem.line2.font.size
            color: mouseArea.pressed ? "#1080dd" : "#ffffff"
        }
    }

    Image {
        id: icon
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 16
        source: Components.imagePath + "listItemIcon.png"
    }

    Image {
        id: arrowImage
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 16
        source: Components.imagePath + "ButtonItemArrow.png"
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: list.itemClicked(model.itemId, index);
    }
}
