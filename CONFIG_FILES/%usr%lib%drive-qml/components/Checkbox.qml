import QtQuick 1.1
import "styles.js" as Style


Item {
    id: checkbox
    height: checkboxStyle.height
    property bool selected: false
    property alias text: label.text
    property alias labelStyle: label.textStyle
    property variant checkboxStyle: Style.Checkbox

    MouseArea {
        id: clickArea
        anchors.fill: parent
        onClicked: checkbox.selected = !checkbox.selected
    }

    Image {
        id: icon
        anchors {
            top: parent.top
            bottom: parent.bottom
        }
        height: parent.height
        width: checkboxStyle.iconWidth
        fillMode: Image.PreserveAspectFit
        source: checkboxStyle.source.unchecked
        states: [
            State {
                name: "pressed"
                when: checkbox.selected && clickArea.pressed
                PropertyChanges {
                    target: icon
                    source: checkboxStyle.source.pressed
                }
            },
            State {
                name: "checked"
                when: checkbox.selected && !clickArea.pressed
                PropertyChanges {
                    target: icon
                    source: checkboxStyle.source.checked
                }
            },
            State {
                name: "disabledUnchecked"
                when: !enabled && !checkbox.selected
                PropertyChanges {
                    target: icon
                    source: checkboxStyle.source.disabledUnchecked
                }
            },
            State { //this is a very special case, that should not happen
                name: "disabledChecked"
                when: !checkbox.enabled && checkbox.selected
                PropertyChanges {
                    target: icon
                    source: checkboxStyle.source.disabledChecked
                }
            }
        ]
    }

    StyledText {
        id: label
        textStyle: Style.RegularText
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: icon.right
            leftMargin: checkboxStyle.spacing
            right: parent.right
        }
        verticalAlignment: Text.AlignVCenter
    }
}

