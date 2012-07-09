import QtQuick 1.1
import "components.js" as Components

Item {
    id: mapControl
    property string type: "zoomIn"
    property bool disable: false
    property int angle: 0
    property bool clickable: true

    signal clicked
    signal pressAndHold
    signal pressed
    signal released

    width: Components.MapControls.width
    height: Components.MapControls.height

    states: [
        State {
            name: "normal"
            when: !mouseArea.pressed
            PropertyChanges {
                target: icon
                x: Components.MapControls.icon[mapControl.type].normal.x
                y: Components.MapControls.icon[mapControl.type].normal.y
            }
            PropertyChanges {
                target: iconRotation
                origin.x: Components.MapControls.icon[mapControl.type].normal.origin.x
                origin.y: Components.MapControls.icon[mapControl.type].normal.origin.y
            }
        },
        State {
            name: "down"
            when: mouseArea.pressed
            PropertyChanges {
                target: icon
                x: Components.MapControls.icon[mapControl.type].down.x
                y: Components.MapControls.icon[mapControl.type].down.y
            }
            PropertyChanges {
                target: iconRotation
                origin.x: Components.MapControls.icon[mapControl.type].down.origin.x
                origin.y: Components.MapControls.icon[mapControl.type].down.origin.y
            }
        }
    ]

    // base shape
    Rectangle {
        id: base
        anchors.fill: parent
        smooth: true

        color: Components.MapControls.base.color
        opacity: Components.MapControls.base.opacity
        border.width: Components.MapControls.base.border.width
        border.color: Components.MapControls.base.border.color

        radius: Components.MapControls.base[mapControl.type].radius
    }

    // background icon
    Item {
        id: backgroundIconContainer
        width: Components.MapControls.icon.width
        height: Components.MapControls.icon.height
        anchors.centerIn: parent
        property int angle: mapControl.angle + Components.MapControls.icon[mapControl.type].presetAngle
        clip: true

        transform: Rotation {
            origin.x: Components.MapControls.icon[mapControl.type].background.origin.x
            origin.y: Components.MapControls.icon[mapControl.type].background.origin.y
            angle: backgroundIconContainer.angle
        }

        Image {
            id: backgroundIcon
            x: Components.MapControls.icon[mapControl.type].background.x
            y: Components.MapControls.icon[mapControl.type].background.y
            source: Components.imagePath + Components.MapControls.icon.uri
        }
    }

    // icon
    Item {
        id: iconContainer
        width: Components.MapControls.icon.width
        height: Components.MapControls.icon.height
        anchors.centerIn: parent
        property int angle: mapControl.angle + Components.MapControls.icon[mapControl.type].presetAngle
        clip: true

        transform: Rotation {
            id: iconRotation
            angle: iconContainer.angle
        }

        Image {
            id: icon
            source: Components.imagePath + Components.MapControls.icon.uri
            smooth: true
        }
    }

    // click area
    MouseArea {
        id: mouseArea
        enabled: parent.clickable
        anchors.fill: parent
        onClicked: !parent.disable && parent.clicked()
        onPressAndHold: !parent.disable && parent.pressAndHold()
        onPressed: !parent.disable && parent.pressed()
        onReleased: !parent.disable && parent.released()
    }
}
