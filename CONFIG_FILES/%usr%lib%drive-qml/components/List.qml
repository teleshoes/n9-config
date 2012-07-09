import QtQuick 1.1
//import components 1.0
import "styles.js" as Style

Item {
    id: list
    property int listItemHeight: Style.ListItem.height
    property alias header : listView.header
    property alias footer : listView.footer
    property alias innerList: listView
    property alias listModel : listView.model
    property bool isLandscape: window.isLandscape
    property bool menuStyle: true
    property bool emitUserInteractionSignal: false
    property int contentHeight: (listView.count + (listView.footer ? 1 : 0) + (listView.header ? 1 : 0)) * listItemHeight
    property int lastPageY: contentHeight - height
    property alias delegate: listView.delegate
    property alias contentY: listView.contentY

    signal itemClicked(string itemId, int index, variant itemArgs)
    signal userInteraction()

    onIsLandscapeChanged: updateScrollButtons()
    onHeightChanged: updateScrollButtons()

    // animation properties
    property alias listViewState: listView.state
    property bool scrollBarVisible: true
    signal transitionDone()

    function scrollTo(y) {
        listView.animateContentY = true;
        listView.contentY = y;
        updateScrollButtons(y);
    }

    function onScrollDownButtonClicked() {
        listView.animateContentY = true;

        var newPageY = listView.contentY + height;
        var correction = newPageY % listItemHeight;

        newPageY = newPageY < lastPageY ? newPageY - correction : lastPageY;

        listView.contentY = newPageY;
        updateScrollButtons(newPageY);
    }

    function onScrollUpButtonClicked() {
        listView.animateContentY = true

        var newPageY = listView.contentY - height;
        var correction = listItemHeight - newPageY % listItemHeight;

        newPageY = newPageY > 0 ? newPageY + correction : 0;

        listView.contentY = newPageY;
        updateScrollButtons(newPageY);
    }

    /**
    Updates the two set of scroll buttons setting them enabled or
    disabled according to the position of the scrollable content
    inside the ListView.

    @param y is a optional parameter, that is given mostly because
    during the animation the contentY is not yet at the final state
    so you might want to give the final y-position.

    If y is not defined the position of the scrollable content is
    fetched from the listView.
    */
    function updateScrollButtons(y) {
        if(!list.visible) {
            return;
        }
    
        var contentY = (y !== undefined) ? y : listView.contentY,
            upButton = window.actionBar.scrollUpButton,
            downButton = window.actionBar.scrollDownButton;

        // if list items make less than one page disable the scroll buttons, SLVD-609 fix is outdated.
        if (listView.count === 0 || contentHeight <= height) {
            upButton.disable = scrollBar.scrollUp.disable = downButton.disable = scrollBar.scrollDown.disable = true;
        } else {
            var lastPage = contentHeight - height;
            upButton.disable = scrollBar.scrollUp.disable = (contentY === 0);
            downButton.disable = scrollBar.scrollDown.disable = (contentY === lastPage);
        }
    }

    ListView {
        id: listView
//        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: list.isLandscape ? scrollBar.left : parent.right
//        anchors.bottom: parent.bottom
        height: parent.height
        flickDeceleration: 2500

        property bool animateContentY: false

        model: listModel
        Behavior on contentY {
            enabled: listView.animateContentY
            SequentialAnimation {
                PropertyAnimation{}
                PropertyAction { target: listView; property: "animateContentY"; value: false }
                //for programatic scrolls
                PropertyAnimation { target: scrollBarIndicator; property: "state"; to: "" }
            }
        }
        //for programatic scrolls
        onContentYChanged: {
            scrollBarIndicator.state = "show"
        }

        onMovementEnded: updateScrollButtons()
        onModelChanged: updateScrollButtons()
        //snapMode: ListView.SnapToItem //QML BUG: slow performance and cause bugs
        clip: true

        MouseArea {
            anchors.fill: parent
            enabled: emitUserInteractionSignal

            onPressed: {
               mouse.accepted = false;
               userInteraction();
            }
        }

        states: [
            State {
                name: ""
                PropertyChanges {
                    target: listView
                    y: -parent.height
                }
                StateChangeScript {
                    script: {
                        //transitionDone()
                    }
                }
            },
            State {
                name: "visible"
                PropertyChanges {
                    target: listView
                    y: 0
                }
            }
        ]
        transitions: [
            Transition {
                from: ""
                to: "visible"
                SequentialAnimation {
                    NumberAnimation { target: listView; property: "y"; to: 0; from: -parent.height; duration: 200 }
                    ScriptAction {
                        script: {
                            transitionDone();
                        }
                    }
                }
            }
        ]
    }


    ScrollBar {
        id: scrollBar
        y: list.height - list.parent.height
        height: window.isLandscape ? list.parent.height : undefined
        visible: parent.isLandscape && scrollBarVisible

        MouseArea {
            anchors.fill: parent
            enabled: emitUserInteractionSignal

            onPressed: {
               mouse.accepted = false;
               userInteraction();
            }
        }
    }

    ScrollPositionIndicator {
        id: scrollBarIndicator
        flickable: listView
        anchors.bottom: listView.bottom
        anchors.top: listView.top
        anchors.right: listView.right
        anchors.topMargin: 2
        anchors.bottomMargin: 2
    }
}
