import QtQuick 1.1
import "styles.js" as Style

Item {
    id: laneAssistanceBar

    property variant style: Style.LaneAssistanceBar

    height: style.height

    property variant items: [lane0, lane1, lane2, lane3, lane4, lane5, lane6, lane7]
    property variant separators: [separtor0, separtor1, separtor2, separtor3, separtor4, separtor5, separtor6]

    Rectangle {
        z: -1
        height: parent.height
        width: parent.width
        anchors.centerIn: parent
        opacity: style.opacity
    }
    
    Row {
        height: parent.height
        anchors.centerIn: parent

        LaneAssistanceItem {
            id: lane0
            visible: false
        }

        LaneAssistanceSeparator {
            id: separtor0
            visible: false
        }

        LaneAssistanceItem {
            id: lane1
            visible: false
        }

        LaneAssistanceSeparator {
            id: separtor1
            visible: false
        }

        LaneAssistanceItem {
            id: lane2
            visible: false
        }

        LaneAssistanceSeparator {
            id: separtor2
            visible: false
        }

        LaneAssistanceItem {
            id: lane3
            visible: false
        }

        LaneAssistanceSeparator {
            id: separtor3
            visible: false
        }

        LaneAssistanceItem {
            id: lane4
            visible: false
        }

        LaneAssistanceSeparator {
            id: separtor4
            visible: false
        }

        LaneAssistanceItem {
            id: lane5
            visible: false
        }

        LaneAssistanceSeparator {
            id: separtor5
            visible: false
        }

        LaneAssistanceItem {
            id: lane6
            visible: false
        }

        LaneAssistanceSeparator {
            id: separtor6
            visible: false
        }

        LaneAssistanceItem {
            id: lane7
            visible: false
        }
    }

    function resetAll() {
        var items = laneAssistanceBar.items;

        for(var i=0; i < items.length; ++i)
        {
            var lane = items[i];
            lane.visible = false;
            lane.direction = 0;
            lane.isOnRoute = false;
        }

        var separators = laneAssistanceBar.separators;

        for(var i=0; i < separators.length; ++i)
        {
            var separator = separators[i];
            separator.visible = false;
        }
    }

    function showLaneInfo(laneInfos)
    {
        laneAssistanceBar.resetAll();

        var lanesCount = laneInfos.length;

        if(lanesCount > style.maxLanesSupported) {
            extractRelevantLanes(laneInfos);
        }
        else {
            for (var i = 0; i < lanesCount; ++i) {
                var laneInfo = laneInfos[i];
                laneAssistanceBar.setupLane(i, laneInfo.Direction,  laneInfo.onRoute);
            }
        }
    }

    // This method decides which lanes to hide if its count more than supported.
    function extractRelevantLanes(laneInfos)
    {
        var lanesCount = laneInfos.length;

        // We need to know what lanes are on route to decide from which side to hide extra lanes.
        var minLaneORoute = -1;
        var maxLaneOnRoute = -1;

        for (var i = 0; i < lanesCount; ++i) {
            var laneInfo = laneInfos[i];

            if(laneInfo.onRoute) {
                if(minLaneORoute == -1) {
                    minLaneORoute = i;
                }

                maxLaneOnRoute = i;
            }
        }

        // Idicates to hide lanes from the left side
        var isHideLeft = false;

        // Idicates to hide lanes from the right side
        var isHideRight = false;

        // In case we hide lanes from the left we need to shift the array with lanes and display the rest of the array
        var laneShift = 0;

        // If route lanes are closer to right side - hide from the left, otherwise - from the right
        if(lanesCount - minLaneORoute -1 < minLaneORoute) {
            isHideLeft = true;
            laneShift = lanesCount - minLaneORoute - 1;
        } else {
            isHideRight = true;
        }

        // Display lanes
        for (var i = 0; i < style.maxLanesSupported; ++i) {
            var laneInfo = laneInfos[i + laneShift];
            // Dots are shown for the relevant lanes from the left or the right side.
            var isDots = (isHideLeft && i == 0) || (isHideRight && i == style.maxLanesSupported - 1);
            laneAssistanceBar.setupLane(i, laneInfo.Direction,  laneInfo.onRoute, isDots);
        }
    }

    function setupLane(laneId, direction, onRoute, isDots) {
        if(laneId > 0 && !isDots)
        {
            var firstLane = laneAssistanceBar.items[0];
            if(!firstLane.isDots || laneId !=1 ) {
                var separators = laneAssistanceBar.separators;
                separators[laneId -1].visible = true;
            }
        }

        var items = laneAssistanceBar.items;
        var lane = items[laneId];
        lane.direction = direction;
        lane.isOnRoute = onRoute;
        lane.isDots = isDots;
        lane.visible = true;
    }
}
