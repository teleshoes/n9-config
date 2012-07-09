import QtQuick 1.1
import "styles.js" as Style


Rectangle {
    id: page
    clip: true
    color: pageStyle.backgroundColor

    property variant params: {}
    property string tag: ""
    property bool isLandscape: window.isLandscape
    property bool fullscreen: false

    property alias titleBox : title

    property alias title: title.text
    property alias titleBottom: title.bottom

    property variant scrollableList
    property variant pageStyle: Style.Page

    Text {
        id: title
        height: pageStyle.titleHeight
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: 16
        verticalAlignment: Text.AlignVCenter
        font.family: pageStyle.titleFamily
        font.pixelSize: pageStyle.titleSize
        color: pageStyle.titleColor
        wrapMode: Text.WrapAnywhere
        elide: Text.ElideRight
    maximumLineCount: 1
    }

    onFullscreenChanged: {
        if (page == window.getCurrentPage()) {
            parent.page1 = page
            parent.state = fullscreen ? "page-fullscreen" : "page"
        }
    }

    //Dummy mouse area that prevents clicking to fall through to "covered" components
    MouseArea {
        anchors.fill: parent
    }

    Item {
        id: stateManager

        states: [
            State {
                name: "landscape"
                when: page.isLandscape
                PropertyChanges {
                    target: page
                    width: page.fullscreen ? parent.width : (parent.width - parent.actionBar.width)
                    height: parent.height;
                }
            },
            State {
                name: "portrait"
                when: !page.isLandscape
                PropertyChanges {
                    target: page
                    width: parent.width;
                    height: page.fullscreen ? parent.height : (parent.height - parent.actionBar.height)
                }
                PropertyChanges {
                    target: title
                    width: page.parent.width - title.anchors.leftMargin
                }
            }
        ]
    }

    signal create()

    signal beforeShow(bool firstShow)
    signal show(bool firstShow)

    signal beforeHide()
    signal hide()

    signal beforeDestroy()

    function onScrollUpButtonClicked() {
        scrollableList && scrollableList.onScrollUpButtonClicked();
    }

    function onScrollDownButtonClicked() {
        scrollableList && scrollableList.onScrollDownButtonClicked();
    }
}
