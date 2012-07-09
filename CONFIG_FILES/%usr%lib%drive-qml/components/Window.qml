import QtQuick 1.1

import "WindowManager.js" as WindowManager
import "components.js" as Components


Item {
    id: window
    property bool isLandscape: true
    property ActionBar actionBar: pageContainer.actionBar
    property bool busy: false

    Connections {
        target: device
        onOrientationChanged: {
            window.isLandscape = device.orientation == "landscape";
        }
    }

    states: [
        State {
            name: "landscape"
            when: window.isLandscape
            PropertyChanges {
                target: window
                width: device.width
                height: device.height
                rotation: 0
            }
        },
        State {
            name: "portrait"
            when: !window.isLandscape
            PropertyChanges {
                target: window
                width: device.height
                height: device.width
                rotation: -90
            }
        }
    ]

    PageContainer {
        id: pageContainer
        anchors.fill: parent
    }

    function pushHidden(page, params) {
        WindowManager.pushHidden(page, params);
    }

    function push(page, params, noAnimation) {
        WindowManager.push(page, params, noAnimation);
        pageContainer.actionBar.updateNavigateButton();
    }

    function pop(tagName, params) {
        WindowManager.pop(tagName, params);
        pageContainer.actionBar.updateNavigateButton();
    }

    function replace(page, params) {
        WindowManager.replace(page, params);
        pageContainer.actionBar.updateNavigateButton();
    }

    function deleteToFirstPage() {
        WindowManager.deleteToFirstPage();
        pageContainer.actionBar.updateNavigateButton();
    }

    /**
      Delete pages in stack from exlusive interval (fromTag, toTag)
      @param fromTag delete from with page (not included)
      @param toTag delete to with page (not included), if null current page will be used
    */
    function deletePages(fromTag, toTag) {
        WindowManager.deletePages(fromTag, toTag);
    }

    function showDialog(type, options) {
        return WindowManager.showDialog(type, options);
    }

    function openUrl(link) {
        WindowManager.openUrl(link);
    }

    function getCurrentPage() {
        return WindowManager.currentPage;
    }

    function getPageStackSize() {
        return WindowManager.pages.length;
    }

    function coverUI() {
        cover.visible = true;
    }

    function uncoverUI() {
        cover.visible = false;
    }

    focus: true
    Keys.onPressed: {
        if (event.modifiers & Qt.ControlModifier) {
            switch (event.key) {
                case Qt.Key_M:
                    device.profiling = !device.profiling;
                    break;
                case Qt.Key_R:
                    window.isLandscape = !window.isLandscape;
                    break;
                case Qt.Key_I:
                    if (!sysinfo.visible) {
                        firmwareVersion.text = "Firwmare: " + device.firmwareVersion;
                        qtVersion.text = "Qt: " + device.qtVersion;
                        mobilityVersion.text = "Qt mobility: " + device.mobilityVersion;
                        sysinfo.visible = true;
                    } else {
                        sysinfo.visible = false;
                    }
                    break;
            }
        }
    }

    Rectangle {
        id: cover
        visible: false
        color: "#000"
        anchors.fill:parent
        MouseArea {
            anchors.fill: parent
            onClicked: { }
        }
    }

    Rectangle {
        width: 160
        height: 100
        radius: 20
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.right: parent.right
        anchors.rightMargin: 20
        color: "#aaa"
        opacity: 0.8
        visible: device.profiling
        z: 999

        Column {
            anchors.centerIn: parent
            Text {
                opacity: 1.0
                font.pixelSize: 24
                font.bold:  true
                text:  "Memory"
            }
            Text {
                opacity: 1.0
                font.pixelSize: 24
                text:  "R: " + Math.round(100 * device.residentMemory / 1024) / 100
            }
            Text {
                opacity: 1.0
                font.pixelSize: 24
                text:  "V: " + Math.round(100 * device.virtualMemory / 1024) / 100
            }
        }
    }

    Rectangle {
        id: sysinfo
        width: 620
        height: 160
        radius: 20
        anchors.centerIn: parent
        color: "#aaa"
        opacity: 0.8
        visible: false
        z: 999

        Column {
            anchors.centerIn: parent
            Text {
                opacity: 1.0
                font.pixelSize: 24
                font.bold:  true
                text:  "System information"
            }
            Text {
                id: firmwareVersion
                opacity: 1.0
                font.pixelSize: 24
            }
            Text {
                id: qtVersion
                opacity: 1.0
                font.pixelSize: 24
            }
            Text {
                id: mobilityVersion
                opacity: 1.0
                font.pixelSize: 24
            }
        }
    }

    Component.onCompleted: {
        window.isLandscape = device.orientation == "landscape";
    }
}

