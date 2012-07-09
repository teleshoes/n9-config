import QtQuick 1.1
import "styles.js" as Style

Item {
    id: settingsButton
    property variant style: Style.SettingsButton

    signal clicked
    signal pressed
    signal released

    width: style.width
    height: style.height

    states: [
        State {
            name: "normal"
            when: !mouseArea.pressed
            PropertyChanges {
                target: icon
                source: style.icon.source.normal
            }
        },
        State {
            name: "down"
            when: mouseArea.pressed
            PropertyChanges {
                target: icon
                source: style.icon.source.down
            }
        }
    ]

    Image {
        id: icon
        width: style.icon.width
        height: style.icon.height
        anchors.centerIn: parent
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: parent.clicked();
        onPressed: parent.pressed()
        onReleased: parent.released();
    }
}
