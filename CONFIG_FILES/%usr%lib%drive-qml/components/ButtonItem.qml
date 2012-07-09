import QtQuick 1.1
import "styles.js" as Style


BorderImage {
    id: root
    source: buttonItemStyle.backgroundSource

    width: parent ? parent.width : 100
    height: buttonItemStyle.height
    border.left: 4
    border.top: 4
    border.right: 64
    border.bottom: 4

    property variant buttonItemStyle: Style.ButtonItem
    property variant style: null
    property bool isActive: true
    property alias checkable: ch.enabled
    property alias group: ch.exclusiveGroup
    property alias buttonChecked: ch.checked
    property string itemId
    property int index // this property should never be declared explicitly. TODO: change it to some other name.
    property string targetPage: ""

    property alias title: textLabel.text
    property alias titleFont: textLabel.font
    property alias titleElide: textLabel.elide
    property alias subtitle: line2Container.text
    property alias subtitleFont: line2Container.font
    property alias subtitleElide: line2Container.elide
    property alias subtitleWrapMode: line2Container.wrapMode

    property url iconUrl: buttonItemStyle.iconSource
    property int spriteIndex: 0
    property bool hasIcon: true
    property bool iconVisible: true
    property bool centerIcon: false
    property bool hideArrow: false
    property bool customizedOnClickedBehavior: false // useful for derived button item, e.g. FavoritesSyncButton

    signal clicked(bool checked);

    Rectangle {
        color: "#464646"
        visible: root.state == "pressed"
        anchors.fill: parent
    }

    Column {
        //set left to cb-icon, or arrow left if available, assuming not at the same time
        //if right is not to parent.right, adjust margin
        anchors.right: checkboxIcon.visible ? checkboxIcon.left : arrowImage.visible ? arrowImage.left : parent.right
        anchors.rightMargin: anchors.right === parent.right ? 60 : 20
        anchors.left: hasIcon? icon.right : parent.left;
        anchors.leftMargin: hasIcon ? 12 : 20;
        anchors.verticalCenter: parent.verticalCenter;

        Text {
            id: textLabel
            width: parent.width
            font.family: buttonItemStyle.titleFamily
            font.pixelSize: buttonItemStyle.titleSize
            color: buttonItemStyle.titleColor.active
            elide: Text.ElideRight
        }

        Text {
            id: line2Container
            //width: parent.width
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: Qt.RightToLeft ? 6 : 0
            font.family: buttonItemStyle.subtitleFamily
            font.pixelSize: buttonItemStyle.subtitleSize
            color: buttonItemStyle.subtitleColor.active
            visible: subtitle
            elide: Text.ElideRight
        }
    }

    Item {
        id: icon
        visible: hasIcon && iconVisible
        width: 72
        height: 72
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 16
        clip: true
        opacity: 1

        Image {
            anchors.centerIn: centerIcon ? parent :undefined
            source: iconUrl
            x: -icon.width * spriteIndex
        }
    }

    Image {
        id: arrowImage
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 16
        source: buttonItemStyle.arrowSource
        visible: !hideArrow
    }

    Checkable {
        id: ch
    }

    Image {
        id: checkboxIcon
        property string defaultState: (ch.checked) ? "checked" : "unchecked"
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: buttonItemStyle.arrowRightMargin
        anchors.right: parent.right
        source: style ?  (mouseArea.pressed && buttonChecked ? style.pressed.icon.uri : style.unchecked.icon.uri) : ""
    }

    states: [
        State {
            name: "checked"
            when: buttonChecked && isActive
            PropertyChanges {
                target: checkboxIcon
                source: style ? style.checked.icon.uri : ""
            }

        },
        State {
            name: "unchecked"
            when: !buttonChecked && isActive
            PropertyChanges {
                target: checkboxIcon
                source: style ? style.unchecked.icon.uri : ""
            }
        },
        State {
            name: "disabledUnchecked"
            when: !isActive && !buttonChecked
            PropertyChanges {
                target: checkboxIcon
                source: style ? style.disabledUnchecked.icon.uri : ""
            }
            PropertyChanges {
                target: textLabel
                color: buttonItemStyle.titleColor.disabled
            }
            PropertyChanges {
                target: line2Container
                color: buttonItemStyle.subtitleColor.disabled
            }
            PropertyChanges {
                target: arrowImage
                opacity: 0.5
            }
            PropertyChanges {
                target: icon
                opacity: 0.5
            }

        },
        State {
            name: "disabledChecked"
            when: !isActive && buttonChecked
            PropertyChanges {
                target: checkboxIcon
                source: style ? style.disabledChecked.icon.uri : ""
            }
            PropertyChanges {
                target: textLabel
                color: buttonItemStyle.titleColor.disabled
            }
            PropertyChanges {
                target: line2Container
                color: buttonItemStyle.subtitleColor.disabled
            }
            PropertyChanges {
                target: icon
                opacity: 0.5
            }
        },
        State {
            name: "pressed"
        }
    ]

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        property string oldState

        onClicked: {
            if (isActive && mouseArea.containsMouse) {
                oldState = root.state
                ch.toggle();
                root.clicked(ch.checked);
                // prevent derived button Item to resend click signal to list
                // e.g. FavoritesSyncButton
                if (!customizedOnClickedBehavior) {
                    list.itemClicked(itemId, index, {targetPage: targetPage});
                }
            }
        }

        onPressed: {
            oldState = root.state
            if (isActive && mouseArea.containsMouse) {
                root.state = "pressed";
            }
        }

        onReleased: {
            root.state = oldState
        }

        onCanceled: {
            root.state = oldState;
        }
    }
}
