import QtQuick 1.1
import "components.js" as Components

Item {
    id: actionButton
    property string type: "empty"
    property bool disable: false
    signal clicked

    Connections {
        target: button
        onClicked: actionButton.clicked && actionButton.clicked();
    }

    width: Components.ActionButtonWithBase.width
    height: Components.ActionButtonWithBase.height
    anchors.margins: Components.ActionBar.button.margins

    // base
    Rectangle {
        id: base
        anchors.fill: actionButton

        color: Components.ActionButtonWithBase.base.color
        opacity: Components.ActionButtonWithBase.base.opacity
        border.width: Components.ActionButtonWithBase.base.border.width
        border.color: Components.ActionButtonWithBase.base.border.color

        radius: Components.ActionButtonWithBase.radius
        smooth: true
    }

    // button
    FunctionButton {
        id: button
        type: actionButton.type
        disable: actionButton.disable
        anchors.centerIn: actionButton
    }
}
