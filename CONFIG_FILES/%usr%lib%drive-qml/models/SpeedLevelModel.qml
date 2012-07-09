import QtQuick 1.1
import "ModelFactory.js" as ModelFactory


QtObject {
    property variant positioningModel
    property int lastSpeed: 0
    property variant accelerationTable: [15, 35, 60, 85, 115]
    property variant breakingTable: [0, 25, 50, 75, 105]
    property variant currentTable: accelerationTable
    property int accelerationLevel: 0
    property int breakingLevel: 1

    property bool polling: false

    signal levelChanged(variant arguments)

    function startPolling() {
        polling = true;
    }

    function restartPolling() {
        var speed = convertSpeed(positioningModel.speed);
        accelerationLevel = getLevel(speed, accelerationTable);
        breakingLevel = getLevel(speed, breakingTable);
        polling = true;
    }

    function stopPolling() {
        polling = false;
    }

    function onPositionUpdated() {
        if (polling) {
            currentTable = positioningModel.speed > lastSpeed ? accelerationTable : breakingTable;
            updateSpeedLevels(positioningModel.speed);
            lastSpeed = positioningModel.speed;
        }
    }

    function updateSpeedLevels() {
        var newSpeed = convertSpeed(positioningModel.speed),
            action = newSpeed >= lastSpeed ? "acceleration" : "breaking",
            oldAccelerationLevel = accelerationLevel,
            oldBreakingLevel = breakingLevel;

        lastSpeed = newSpeed;

        accelerationLevel = getLevel(newSpeed, accelerationTable);
        breakingLevel = getLevel(newSpeed, breakingTable);

        //emit signal if levels have changed for the current action
        if ((action == "acceleration" && accelerationLevel != oldAccelerationLevel) ||
            (action == "breaking" && breakingLevel != oldBreakingLevel)) {
            levelChanged({
                newLevel: action == "acceleration" ? accelerationLevel : breakingLevel,
                oldLevel: action == "acceleration" ? oldAccelerationLevel : oldBreakingLevel,
                action: action
            });
        }
    }

    function getLevel(speed, table) {
        return ((speed <= table[0]) ? 0 :
                            (speed > table[0] && speed < table[1]) ? 1 :
                            (speed > table[1] && speed < table[2]) ? 2 :
                            (speed > table[2] && speed < table[3]) ? 3 :
                            (speed > table[3] && speed < table[4]) ? 4 : 5);
    }

    function convertSpeed(speedmps) {
        return 3.6 * speedmps;
    }

    Component.onCompleted: {
        positioningModel = ModelFactory.getModel("PositioningModel");
        positioningModel.positionUpdated.connect(onPositionUpdated);
    }
}
