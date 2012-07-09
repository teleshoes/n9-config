import QtQuick 1.1
import "styles.js" as Style

Rectangle {
    id: listBrowser
    color: parent.color //Use rectangle with filled color here to cover border of minimap

    // 'public' properties
        // reference to the list data model
    property ListModel dataModel
        // current [visible/selected] item index
    property int currentIndex: 0
        // name of the qml component which should display the data
    property string listItemName
        // the onClick handler called when the user navigates to an item (passed the item's index in the list)
    signal click(int choice)
        // orientation flag
    property bool isLandscape
        // visibility of the arrow buttons
    property bool arrowsVisible: true
    property variant listBrowserStyle: Style.ListBrowser

    // 'private' properties
        // reference to swap item A
    property Item _itemA
        // reference to swap item B
    property Item _itemB
        // reference to current item (default is A - the first, visible item)
    property Item _current: _itemA
        // reference to next item (default is B - the next item to scroll into visible area)
    property Item _subsequent: _itemB
        // internal disable flag (prevents multiple clicks)
    property bool _disable: false

    Component.onCompleted: {
        // create the specified list component
        var component = Qt.createComponent(listBrowser.listItemName + ".qml");

        // instantiate item A
        _itemA = component.createObject(listItemContainer);

        _itemA.externalContainer = navigationBar;

        // instantiate item B
        _itemB = component.createObject(listItemContainer);

        // It can't be seen but there are many layout dependencies
        _itemB.externalContainer = navigationBar;

        // set the initial list browser state
        listBrowser.state = "showNextStart";

        if (listBrowser.dataModel.count > 0) {
            _itemA.setData(listBrowser.dataModel.get(0));
            _itemB.setData(listBrowser.dataModel.get(listBrowser.dataModel.count > 1 ? 1 : 0));
        }

    }

    function reset() {
        listBrowser.setCurrentIndex(0);
    }

    function setCurrentIndex(targetIndex) {
        if (targetIndex < listBrowser.dataModel.count) {
            listBrowser.currentIndex = targetIndex;
            var data = listBrowser.dataModel.get(targetIndex);
            listBrowser._subsequent.setData(data);

            listBrowser.state = "showNextStart";
            listBrowser.state = "showNextFinish";

        } else {
            // error
            console.log("ERROR: ListBrowser.setCurrentIndex targetIndex too big");
        }
    }

    function onScroll(target) {
        if ( !listBrowser._disable ) {
            // disable clicks during animations
            listBrowser._disable = true;

            if ( target === next ) {
                // increment current index
                listBrowser.currentIndex++;

                // set the data to the item to which view will be animated to the new current index
                listBrowser._subsequent.setData(listBrowser.dataModel.get(listBrowser.currentIndex));

                // trigger transition between states
                listBrowser.state = "showNextStart";
                listBrowser.state = "showNextFinish";
            } else {
                // decrement current index
                listBrowser.currentIndex--;

                // set the data to the item to which view will be animated to the new current index
                listBrowser._subsequent.setData(listBrowser.dataModel.get(listBrowser.currentIndex));

                // trigger transition between states
                listBrowser.state = "showPreviousStart";
                listBrowser.state = "showPreviousFinish";
            }

            // if the ListBrowser has a click signal, call it, passing the new current maneuver index
            listBrowser.click && listBrowser.click(listBrowser.currentIndex);
        }
    }

    states: [
        State {
            name: "showNextStart"
            PropertyChanges {
                target: listBrowser._current
                x: 0
                showExternal: true
            }
            PropertyChanges {
                target: listBrowser._subsequent
                x: listBrowser._current.width
                showExternal: false
            }
        },
        State {
            name: "showNextFinish"
            PropertyChanges {
                target: listBrowser._current
                x: -listBrowser._current.width
                showExternal: false
            }
            PropertyChanges {
                target: listBrowser._subsequent
                x: 0
                showExternal: true
            }
        },
        State {
            name: "showPreviousStart"
            PropertyChanges {
                target: listBrowser._current
                x: 0
                showExternal: true
            }
            PropertyChanges {
                target: listBrowser._subsequent
                x: -listBrowser._current.width
                showExternal: false
            }
        },
        State {
            name: "showPreviousFinish"
            PropertyChanges {
                target: listBrowser._current
                x: listBrowser._current.width
                showExternal: false
            }
            PropertyChanges {
                target: listBrowser._subsequent
                x: 0
                showExternal: true
            }
        }
    ]

    transitions: [
        Transition {
            from: "showNextStart"
            to: "showNextFinish"
            SequentialAnimation {
                NumberAnimation {
                    properties: "x"
                    easing.type: Easing.InOutQuad
                    duration: 200
                    alwaysRunToEnd: true
                }
                ScriptAction {
                    script: {
                        // swap current and subsequent item references
                        // e.g. |A|-B transition A-|B|
                        var temp = listBrowser._current;
                        listBrowser._current = listBrowser._subsequent;
                        listBrowser._subsequent = temp;

                        // re-enable clicks
                        listBrowser._disable = false;
                    }
                }
            }
        },
        Transition {
            from: "showPreviousStart"
            to: "showPreviousFinish"
            SequentialAnimation {
                NumberAnimation {
                    properties: "x"
                    easing.type: Easing.InOutQuad
                    duration: 200
                    alwaysRunToEnd: true
                }
                ScriptAction {
                    script: {
                        // swap current and subsequent item references
                        // e.g. |B|-A transition B-|A|
                        var temp = listBrowser._current;
                        listBrowser._current = listBrowser._subsequent;
                        listBrowser._subsequent = temp;

                        // re-enable clicks
                        listBrowser._disable = false;
                    }
                }
            }
        }
    ]

    Rectangle {
        id: navigationBar
        height: listBrowserStyle.navigationBarHeight
        color: listBrowserStyle.navigationBarColor

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

        MouseArea {
            anchors.fill: parent
            onClicked: {
                // Do nothing. Block clicks/taps going through to the map
            }
        }
        // previous button
        FunctionButton {
            id: previous
            visible: arrowsVisible

            anchors.verticalCenter: navigationBar.verticalCenter
            anchors.left: parent.left

            type: "scrollLeftDark"
            disable: listBrowser.currentIndex === 0
            onClicked: !previous.disable && onScroll(previous);
        }
        MouseArea {
            id: previousHitArea
            width: 120
            height: previous.height
            anchors.left: previous.left
            onClicked: !previous.disable && onScroll(previous);
            onPressed: {
                if (!previous.disable) {
                    previous.state = "down"
                }
            }
            onReleased: {
                if (!previous.disable) {
                    previous.state = "normal"
                }
            }

        }
        // next button
        FunctionButton {
            id: next
            visible: arrowsVisible
            anchors.right: parent.right

            anchors.verticalCenter: navigationBar.verticalCenter

            type: "scrollRightDark"
            disable: listBrowser.currentIndex === listBrowser.dataModel.count - 1
            onClicked: !next.disable && onScroll(next);
        }
        MouseArea {
            id: nextHitArea
            width: 120
            height: next.height
            anchors.right: next.right
            onClicked: !next.disable && onScroll(next);
            onPressed: {
                if (!next.disable) {
                    next.state = "down"
                }
            }
            onReleased: {
                if (!next.disable) {
                    next.state = "normal"
                }
            }

        }


    }

    Item {
        id: listItemContainer
        anchors.fill: parent
        clip: listBrowser.isLandscape // only clip in landscape

        /*
         * On orientation changes, we need to pass the current state to the list items.
         * These have been dynamically created and hence have no binding on this property.
         * We will not do this until both exist.
         */
        states: [
            State {
                name: "startUp"
                when: !(_itemA || _itemB)
            },
            State {
                name: "landscape"
                when: _itemA && _itemB && listBrowser.isLandscape
                PropertyChanges {
                    target: _itemA
                    isLandscape: true
                }
                PropertyChanges {
                    target: _itemB
                    isLandscape: true
                }
            },
            State {
                name: "portrait"
                when: _itemA && _itemB && !listBrowser.isLandscape
                PropertyChanges {
                    target: _itemA
                    isLandscape: false
                }
                PropertyChanges {
                    target: _itemB
                    isLandscape: false
                }
            }
        ]
    }
}
