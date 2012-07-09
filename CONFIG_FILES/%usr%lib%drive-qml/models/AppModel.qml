import QtQuick 1.1

Item {
    property bool useDestinationAsHome
    property bool restartAssistance
    property variant lastDestination
    property string homeFlowFlag

    function setHomeFlow(flag) {
        homeFlowFlag = flag ? flag : "";
    }

    Component.onCompleted: {
        useDestinationAsHome = false;
        restartAssistance = false;
        setHomeFlow();
    }
}
