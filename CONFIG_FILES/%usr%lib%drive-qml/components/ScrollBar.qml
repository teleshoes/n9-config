import QtQuick 1.1
import "styles.js" as Style

Item {
    id: scrollBar

    // properties to allow access to individual buttons
    property Item scrollUp: scrollUp
    property Item scrollDown: scrollDown

    width: Style.ScrollBar.width
    anchors.right: parent.right

    // SCROLL UP
    ScrollBarButton {
        id: scrollUp
        type: "scrollUp"
        anchors.top: parent.top
        onClicked: {
            var currentPage = window.getCurrentPage();
            currentPage.onScrollUpButtonClicked && currentPage.onScrollUpButtonClicked()
        }
    }

    // SCROLL DOWN
    ScrollBarButton {
        id: scrollDown
        type: "scrollDown"
        anchors.bottom: parent.bottom
        onClicked: {
            var currentPage = window.getCurrentPage();
            currentPage.onScrollDownButtonClicked && currentPage.onScrollDownButtonClicked()
        }
    }
}
