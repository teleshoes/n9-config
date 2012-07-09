import QtQuick 1.1
import "styles.js" as Style

// NB: DON'T be tempted by rotational transformation here - it is very unpredictable!
Item {
    id: actionBar
    property bool isLandscape: window.isLandscape

    // properties to allow access to individual buttons
    property Item navigateButton: navigateButton
    property Item buttonHome: buttonHome
    property Item scrollUpButton: scrollUpButton
    property Item scrollDownButton: scrollDownButton

    // internal properties to calculate button dimensions
    property real _buttonWidth
    property real _buttonHeight

    // helper for paging framework
    property int pageOffset
    property variant actionBarStyle: Style.ActionBar

    function countVisible() {
        var count = 0;
        for (var i = 0; i < actionBar.children.length; i++) {
            var child = actionBar.children[i];
            // MY GOD! THERE MUST BE A BETTER WAY TO DO THIS?!
            // if ( child instanceof ActionBarButton ) {
            if ( child.toString().indexOf("ActionBarButton") >= 0 ) {
                child.visible !== undefined && child.visible && (count++);
            }
        }
        // console.log("visible buttons: " + count);
        return count;
    }

    states: [
        State {
            name: "landscape"
            when: actionBar.isLandscape
            // action bar
            PropertyChanges {
                target: actionBar
                width: actionBarStyle.width
                height: parent.height

                pageOffset: actionBarStyle.width

                _buttonWidth: actionBar.width
                _buttonHeight: actionBar.height / actionBar.countVisible()
            }
            AnchorChanges {
                target: actionBar
                anchors.top: parent.top
            }

            // BUTTONS:
            // NB: Super-complicated UX rules for positioning and visibility of controls.
            // Test any changes thoroughly!
                // 'navigate' button
            AnchorChanges {
                target: navigateButton
                anchors.bottom: actionBar.bottom
                anchors.left: actionBar.left
            }
            PropertyChanges {
                target: navigateButton
                isFirst: !buttonHome.visible
                isLast: true
            }
            AnchorChanges {
                target: buttonHome
                anchors.top: actionBar.top
                anchors.left: actionBar.left
            }
            PropertyChanges {
                target: buttonHome
                isFirst: true
            }
                // scroll up button
            PropertyChanges {
                target: scrollUpButton
                visible: false
            }
                // scroll down button
            PropertyChanges {
                target: scrollDownButton
                visible: false
            }
        },
        State {
            name: "portrait"
            when: !actionBar.isLandscape
            // action bar
            PropertyChanges {
                target: actionBar
                width: parent.width
                height: actionBarStyle.width

                pageOffset: 0

                _buttonWidth: actionBar.width / actionBar.countVisible()
                _buttonHeight: actionBar.height
            }
            AnchorChanges {
                target: actionBar
                anchors.bottom: parent.bottom
            }

            // BUTTONS:
            // NB: Super-complicated UX rules for positioning and visibility of controls.
            // Test any changes thoroughly!
                // 'navigate' button
            AnchorChanges {
                target: navigateButton
                anchors.left: actionBar.left
                anchors.bottom: actionBar.bottom
            }
            PropertyChanges {
                target: navigateButton
                isFirst: true
                isLast: !(buttonHome.visible || scrollUpButton.active)
            }
            AnchorChanges {
                target: buttonHome
                anchors.left: navigateButton.right
                anchors.bottom: actionBar.bottom
            }
            PropertyChanges {
                target: buttonHome
                isLast: buttonHome.visible // buttonHome.visible && !scrollUpButton.active
            }
                // scroll up button
            AnchorChanges {
                target: scrollUpButton
                anchors.left: navigateButton.right
                anchors.bottom: actionBar.bottom
            }
            PropertyChanges {
                target: scrollUpButton
                visible: scrollUpButton.active
            }
            // scroll down button
            AnchorChanges {
                target: scrollDownButton
                anchors.left: scrollUpButton.right
                anchors.bottom: actionBar.bottom
            }
            PropertyChanges {
                target: scrollDownButton
                visible: scrollDownButton.active
                isLast: true
            }
        }
    ]

    // background image
    Image {
        id: background
        anchors.fill: actionBar
        source: actionBarStyle.backgroundImageSource[isLandscape ? "landscape" : "portrait"]
    }

    // navigate button
    ActionBarButton {
        id: navigateButton
        type: "back"
        isLandscape: actionBar.isLandscape
        width: actionBar._buttonWidth
        height: actionBar._buttonHeight
        onClicked: {
            var currentPage = window.getCurrentPage(),
                popPage = true;

            if (currentPage.onNavigateButtonClicked) {
                // pop when onBackButtonClicked returns undefined or true
                popPage = !(currentPage.onNavigateButtonClicked() === false);
            }

            popPage && window.pop();
        }
    }

    // home button for car mode
    ActionBarButton {
        id: buttonHome
        type: "home"
        isLandscape: actionBar.isLandscape
        width: actionBar._buttonWidth
        height: actionBar._buttonHeight
        onClicked: {
            console.log("HOME button clicked!");
            device.showHomeScreen();
        }
    }

    // scroll up button
    ActionBarButton {
        id: scrollUpButton
        type: "scrollUp"
        isLandscape: actionBar.isLandscape
        width: actionBar._buttonWidth
        height: actionBar._buttonHeight
        onClicked: window.getCurrentPage().onScrollUpButtonClicked()
    }

    // scroll down button
    ActionBarButton {
        id: scrollDownButton
        type: "scrollDown"
        isLandscape: actionBar.isLandscape
        width: actionBar._buttonWidth
        height: actionBar._buttonHeight
        onClicked: window.getCurrentPage().onScrollDownButtonClicked()
    }
}
