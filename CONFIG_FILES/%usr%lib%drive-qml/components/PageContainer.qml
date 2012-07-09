import QtQuick 1.1
import "../models/ModelFactory.js" as ModelFactory
import "styles.js" as Style

Item {
    id: container

    property Page page1
    property Page page2
    property ActionBar actionBar: actionBar

    property string operation
    property int landscapeTransitionDuration: 230
    property int portraitTransitionDuration: 170
    property int transitionDuration: window.isLandscape ? landscapeTransitionDuration : portraitTransitionDuration

    signal slideLeftFinished
    signal slideRightFinished

    ActionBar {
        id: actionBar
        z: 3
        function updateNavigateButton() {
            var currentPage = window.getCurrentPage();
        }

        function updateButtons(page) {
            scrollUpButton.active = scrollDownButton.active = !!page.scrollableList;
            buttonHome.visible = device.isCarMode;
        }
    }

    Component.onCompleted: {
        device.isCarModeChanged.connect(function() {
            console.log("Car mode changed");
            var page = window.getCurrentPage();
            actionBar.updateButtons(page);
        });
    }

    states: [
        State {
            name: "page"
            PropertyChanges {
                target: page1
                x: actionBar.pageOffset
            }
            PropertyChanges {
                target: actionBar
                visible: true
                x: 0
            }
        },

        State {
            name: "page-fullscreen"
            PropertyChanges {
                target: page1
                x: 0
            }
            PropertyChanges {
                target: actionBar
                visible: false
            }
        },

        State {
            name: "prepareSlideLeft"
            PropertyChanges {
                target: actionBar
                x: {
                    if (!page1.fullscreen) return 0;
                    if (!page2.fullscreen) return container.width;
                    return -container.width;
                }
            }
            PropertyChanges {
                target: page1
                x: page1.fullscreen ? 0 : actionBar.pageOffset
            }
            PropertyChanges {
                target: page2
                x: page1.fullscreen && !page2.fullscreen?  container.width + actionBar.pageOffset : container.width
            }
        },

        State {
            name: "slideLeft"
            PropertyChanges {
                target: actionBar
                x: page2.fullscreen ? -container.width : 0;
                visible: !page2.fullscreen
            }
            PropertyChanges {
                target: page1
                x: {
                    if (page1.fullscreen) return - container.width;
                    if (page2.fullscreen) return actionBar.pageOffset - container.width;
                    return actionBar.pageOffset - page1.width;
                }
            }
            PropertyChanges {
                target: page2
                x: page2.fullscreen ? 0 : actionBar.pageOffset
            }
        },

        State {
            name: "prepareSlideRight"
            PropertyChanges {
                target: actionBar
                x: !page2.fullscreen ? 0 : -container.width;
            }
            PropertyChanges {
                target: page1
                x: {
                    if (!page1.fullscreen && !page2.fullscreen) {
                        return actionBar.pageOffset - page1.width;
                    }
                   return -page1.width;
                }
            }
            PropertyChanges {
                target: page2
                x: page2.fullscreen ? 0 : actionBar.pageOffset
            }
        },

        State {
            name: "slideRight"
            PropertyChanges {
                target: actionBar
                x: {
                    if (page1.fullscreen && page2 && page2.fullscreen) return -container.width;
                    if (page1.fullscreen && !page2) return container.width;
                    if (page1.fullscreen && !page2.fullscreen) return container.width;
                    return 0;
                }
                visible: !page1.fullscreen
            }
            PropertyChanges {
                target: page1
                x: page1.fullscreen ? 0 : actionBar.pageOffset
            }
            PropertyChanges {
                target: page2
                x: (page1.fullscreen && page2 && !page2.fullscreen) ? container.width + actionBar.pageOffset : container.width
            }
        }
    ]

    transitions: [
        Transition {
            from: "prepareSlideLeft"
            to: "slideLeft"
            SequentialAnimation {
                ScriptAction { script: {
                        actionBar.updateButtons(page2);
                        page1.beforeHide();
                        page2.beforeShow(true);
                        page2.scrollableList && page2.scrollableList.updateScrollButtons();
                    }
                }
                PropertyAnimation {
                    properties: "x"
                    easing.type: Easing.InOutQuad
                    duration: transitionDuration
                    alwaysRunToEnd: true
                }
                ScriptAction { script: {
                        leftTimer.running = true;
                        //slideLeftFinished();
                    }
                }
            }
        },
        Transition {
            from: "prepareSlideRight"
            to: "slideRight"
            SequentialAnimation {
                ScriptAction { script: {
                        page2.beforeHide();
                        page1.visible = true;
                        page1.beforeShow(false);
                    }
                }
                PropertyAnimation {
                    properties: "x"
                    easing.type: Easing.InOutQuad
                    duration: transitionDuration
                    alwaysRunToEnd: true
                }
                ScriptAction { script: {
                        rightTimer.running = true;
                        //slideRightFinished()
                    }
                }
            }
        }
    ]

    Timer {
        id: leftTimer
        interval: 10
        repeat: false
        onTriggered: slideLeftFinished()
    }

    Timer {
        id: rightTimer
        interval: 10
        repeat: false
        onTriggered: slideRightFinished()
    }

    onSlideLeftFinished: {
        page1.hide();
        page2.show(true);

        if(operation === "replace") {
            page1.beforeDestroy()
            page1.destroy();
            page1 = null;
        } else {
            page1.visible = false;
        }
        window.busy = false;
    }

    onSlideRightFinished: {
        page2.hide();
        page1.show(false);

        page2.beforeDestroy();
        page2.destroy();
        page2 = null;

        actionBar.updateButtons(page1);
        page1.scrollableList && page1.scrollableList.updateScrollButtons();

        window.busy = false;
    }
}
