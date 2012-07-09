import QtQuick 1.1
import "styles.js" as Styles

BorderImage {
    property variant myStyle: Styles.AddressItem
    property alias mouseAreaEnabled: mouseArea.enabled  // useful when presenting this item as a favorate detail

    id: listItem
    source: myStyle.backgroundSource
    width: parent.width;
    height: myStyle.height
    border.left: 0; border.top: 0
    border.right: 0; border.bottom: 4

    //property bool favoriteItem: false

    function polishedAddress() {
        var _address2 = address2 ? address2.trim() : "";
        if (_address2) return _address2;

        var _detailAddress2 = detailAddress2 ? detailAddress2.trim() : "";
        var _detailAddress3 = detailAddress3 ? detailAddress3.trim() : "";
        var _line = [];
        if (_detailAddress2) _line.push(_detailAddress2);
        if (_detailAddress3) _line.push(_detailAddress3);
        return _line.join(', ');
    }

    Rectangle {
        anchors.fill: parent
        color: myStyle.backgroundColorPressed
        visible: mouseArea.pressed
    }

    Item {
        id: imageContainer
        height: parent.height
        width: 112
        Image {
            id: image
            anchors.centerIn: parent
            source: iconUrlList || myStyle.defaultItemSource
            onStatusChanged: {
                if (image.status == Image.Error) {
                    image.source = myStyle.defaultItemSource;
                }
            }
        }
    }

    Text {
        id: header
        anchors.left: imageContainer.right
        anchors.top: listItem.top
        anchors.topMargin: 10
        text: address1 || ""
        color: myStyle.headerColor
        font.pixelSize: myStyle.headerSize
        font.family: myStyle.headerFamily
        width: parent.width - imageContainer.width - 5
        elide: Text.ElideRight
    }
    Text {
        id: address
        anchors.left: imageContainer.right
        anchors.top: header.bottom
        anchors.topMargin: -1
        text: polishedAddress()
        //text: favoriteItem ? (address2 || detailAddress3 || "") : (detailAddress3 || detailAddress2 || "")
        color: myStyle.addressColor
        font.pixelSize: myStyle.addressSize
        font.family: myStyle.addressFamily
        width: parent.width - imageContainer.width - 5
        elide: Text.ElideRight
    }
    Text {
        id: distanceText
        anchors.left: imageContainer.right
        anchors.top: address.bottom
        text: distance || "" //"800m"
        color: myStyle.distanceTextColor
        font.pixelSize: myStyle.distanceTextSize
        font.family: myStyle.distanceTextFamily
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: list.itemClicked(model.itemId, index, {});
    }
}

