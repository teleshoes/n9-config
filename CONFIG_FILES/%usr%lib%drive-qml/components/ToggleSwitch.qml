import QtQuick 1.1
import "styles.js" as Style

Item {
    id: toggleSwitch
    property bool isLandscape
    // the model used to populate the toggle switch with toggle buttons
    property ListModel buttonModel
    // the SINGLE handler for a click on ANY button within the switch
    signal clicked(int uid)

    function _clickHandler(target) {
        // unset all BUT the target button
        for (var i = 0, len = buttons.children.length; i < len; i++) {
            var button = buttons.children[i];
            !(button.isSelected === undefined || button === target) && (button.isSelected = false);
        }
        // call the ToggleSwitch click signal
        toggleSwitch.clicked && toggleSwitch.clicked(target.uid);
    }

    Component {
        id: buttonDelegate

        // example: ListElement
        // --------------------
        // preSelected: mapped to -> ToggleButton.isSelected
        // label: mapped to -> ToggleButton.text
        // buttonWidth: mapped to -> ToggleButton.targetWidth if defined and non-zero, else the width
        //      of each button is calculated from the width of the ToggleSwitch. If that has no width,
        //      each button will be as wide as is necessary to display the text.
        // identifier (optional): mapped to extra property 'uid' for the purposes of identifying the target button
        //      clicked and hence responding appropriately within the ToggleSwitch signal handler 'clicked'.

        // the delegate
        ToggleButton {
            // set the id of this ToggleButton instance
            id: toggleButton

            // set landscape/portrait mode
            isLandscape: toggleSwitch.isLandscape

            // configured by each ListElement in the ListModel
            targetWidth: buttonWidth || toggleSwitch.width/buttonModel.count
            isSelected: preSelected
            iconSource: imageSource
            text: label
            property int uid: identifier

            // dependent on order of ListElement within ListModel
            isFirst: index === 0
            isLast: index === buttonModel.count - 1

            // call the toggle switch click handler, passing a reference to THIS clicked button
            onClicked: _clickHandler(toggleButton)
        }
    }

    Row {
        id: buttons
        anchors.fill: parent
        spacing: Style.ToggleSwitch.spacing
        Repeater {
            model: buttonModel
            delegate: buttonDelegate
        }
    }
}
