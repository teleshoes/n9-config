import QtQuick 1.1
import "styles.js" as Style
import "../utils/Units.js" as Units


Item {
    id: location
    height: locationStyle.height

    property bool isLandscape
    property string name
    property bool hasGPS: false
    property bool hadGPS: false
    property bool loadingTraffic: false
    property int _timeElapsed: 0
    property variant locationStyle: Style.Location
    property alias gpsLostTimer: timer    
    property bool alternateGPSText: false

    onHasGPSChanged: {
        if (hasGPS) {
            hadGPS = true;
            timer.stop();
        } else if (hadGPS) {
            _timeElapsed = 0;
            timer.start();
        }
    }

    Timer {
        id: timer
        repeat: true
        interval: 1000
        onTriggered: _timeElapsed++;
    }

    // Timer for alternating between "loading traffic" and "looking for GPS" text in location bar
    Timer {
        id:gpsTrafficTimer
        repeat: true
        interval: 2000
        onTriggered: alternateGPSText = !alternateGPSText
        running: !hasGPS && loadingTraffic
    }

    // background
    Rectangle {
        id: background
        opacity: locationStyle.backgroundOpacity[hasGPS ? "hasGPS" : "noGPS"]
        color: locationStyle.backgroundColor[hasGPS ? "hasGPS" : "noGPS"]

        // QML limitation: we can't add a border to one side of an Item.
        // NB: Borders fall EVENLY inside and outside of an Item, so a 2px
        // border is required to provide a 1px VISIBLE border.

        // set the border
        border.width: locationStyle.borderWidth
        border.color: locationStyle.borderColor

        // make the background oversized and offset the position to push the background
        // outside of the parent
        width: location.width + locationStyle.borderWidth
        height: location.height + locationStyle.borderWidth
        x: -locationStyle.borderWidth / 2
    }

    AnimatedImage {
        id: name
        source: locationStyle.noGPSIconSource
        width: locationStyle.noGPSIconWidth
        height: locationStyle.noGPSIconHeight
        anchors.left: location.left
        anchors.leftMargin: y
        anchors.verticalCenter: background.verticalCenter
        visible: !hasGPS
    }

    Text {
        id: locationName
        anchors {
            left: hasGPS ? parent.left : name.right
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: locationStyle.color[hasGPS ? "hasGPS" : "noGPS"]
        font.family: locationStyle.family
        font.pixelSize: locationStyle.size
        elide: Text.ElideRight

        text: {
            var currentText;
            if(loadingTraffic && !alternateGPSText) {
                currentText = qsTrId("qtn_drive_loading_traffic_not");
            } else if (hasGPS) {
                currentText = (location.name || "");
            } else if (!hadGPS) {
                currentText = qsTrId("qtn_drive_looking_gps_not");
            } else {
                currentText = qsTrId("qtn_drive_gps_lost_not").replace("$1", _getElapsedTime());
            }

            return currentText;
        }
    }

    function _getElapsedTime() {
        var readableTime = Units.getReadableTime(_timeElapsed);
        return readableTime.value + readableTime.unit;
    }
}
