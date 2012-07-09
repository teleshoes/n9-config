import QtQuick 1.1
import "components.js" as Components

Item {
    id: listBrowser
    property bool isLandscape
    property ListModel _model
    property Component _delegate

    // AAARRRGGGHHHH: why does this have to be exposed to the page
    property alias navigation: navigationBar
    property alias currentItem: listView.currentItem

    signal clicked(int choice)
    clip: false // !important!

    // NAVIGATION BAR
    Rectangle {
        id: navigationBar
        height: Components.ListBrowser.navigationBar.height
        color: eval(Components.ListBrowser.navigationBar.color)

        states: [
            State {
                name: "landscape"
                when: listBrowser.isLandscape
                PropertyChanges {
                    target: navigationBar
                    width: listBrowser.parent.width - listBrowser.width
                }
                AnchorChanges {
                    target: navigationBar
                    anchors.left: listBrowser.right
                    anchors.bottom: listBrowser.bottom
                }
            },
            State {
                name: "portrait"
                when: !listBrowser.isLandscape
                PropertyChanges {
                    target: navigationBar
                    width: listBrowser.width
                }
                AnchorChanges {
                    target: navigationBar
                    anchors.left: listBrowser.left
                    anchors.bottom: listBrowser.top
                }
            }
        ]

        // previous button
        FunctionButton {
            id: previous
            anchors.verticalCenter: navigationBar.verticalCenter
            anchors.left: parent.left
            type: "scrollLeftDark"
            disable: listView.currentIndex <= 0
            onClicked: {
                if ( !previous.disable ) {
                    listView.decrementCurrentIndex();
                    listBrowser.clicked && listBrowser.clicked(listView.currentIndex);
                }
            }
        }

        // next button
        FunctionButton {
            id: next
            anchors.verticalCenter: navigationBar.verticalCenter
            anchors.right: parent.right
            type: "scrollRightDark"
            disable: listView.currentIndex >= listView.count - 1
            onClicked: {
                if ( !next.disable ) {
                    listView.incrementCurrentIndex();
                    listBrowser.clicked && listBrowser.clicked(listView.currentIndex);
                }
            }
        }
    }

    // LIST VIEW
    ListView {
        id: listView
        model: listBrowser._model
        delegate: listBrowser._delegate
        anchors.fill: listBrowser
        clip: listBrowser.isLandscape // !important!
        orientation: ListView.Horizontal
        currentIndex: 0

        flickableDirection: Flickable.HorizontalFlick
        boundsBehavior: Flickable.StopAtBounds
        snapMode: ListView.SnapOneItem

        onMovementEnded: {
            // set the ListView currentIndex accordingly
            // console.log("listView.width: " + listView.width);
            // console.log("listView.contentX: " + listView.contentX);
            var targetIndex = Math.floor(listView.contentX / listView.width);
            // NB: it's possible for contentX to be outside of the list range if the user is very brisk
            if ( targetIndex < 0) {
                targetIndex = 0;
            } else if ( targetIndex > listView.model.count - 1 ) {
                targetIndex = listView.model.count - 1;
            }
            listView.currentIndex = targetIndex;
            listBrowser.clicked && listBrowser.clicked(listView.currentIndex);
        }
    }
}
