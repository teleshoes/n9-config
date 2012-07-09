import QtQuick 1.1
import "styles.js" as Styles


Item {
    id: assistanceItem
    property bool isLandscape
    property string value
    property string unit
    property bool isLast: false
    property variant assistanceItemStyle: Styles.AssistanceItem

    signal pressed
    signal released
    signal clicked

    clip: true

    states: [
        State {
            name: "landscape"
            when: assistanceItem.isLandscape
            // background
            AnchorChanges {
                target: background
                anchors.right: assistanceItem.right
                anchors.bottom: assistanceItem.bottom
            }
            // border
            AnchorChanges {
                target: border
                anchors.right: assistanceItem.right
                anchors.bottom: assistanceItem.bottom
            }
        },
        State {
            name: "portrait"
            when: !assistanceItem.isLandscape
            // background
            AnchorChanges {
                target: background
                anchors.top: assistanceItem.top
                anchors.left: assistanceItem.left
            }
            // border
            AnchorChanges {
                target: border
                anchors.top: assistanceItem.top
                anchors.right: assistanceItem.right
            }
        }
    ]

    // background
    Image {
        id: background
        width: isLandscape ? parent.width : assistanceItemStyle.backgroundWidthPortait
        height: assistanceItemStyle.backgroundHeight[isLandscape ? "landscape" : "portrait"]
        source: assistanceItemStyle.backgroundSource[isLandscape ? "landscape" : "portrait"]
    }

    // border
    Rectangle {
        id: border        
        visible: !assistanceItem.isLast
        color: assistanceItemStyle.borderColor
        width: isLandscape ? parent.width : assistanceItemStyle.borderWidth
        height: isLandscape ? assistanceItemStyle.borderWidth : parent.height
    }

    // !!! IMPORTANT !!!
    // Click Area (may not be needed but PREVENTS click-thru's)
    MouseArea {
        id: mouseArea
        anchors.fill: assistanceItem
        onPressed: assistanceItem.pressed && assistanceItem.pressed()
        onReleased: assistanceItem.released && assistanceItem.released()
        onClicked: assistanceItem.clicked && assistanceItem.clicked()
    }
}
