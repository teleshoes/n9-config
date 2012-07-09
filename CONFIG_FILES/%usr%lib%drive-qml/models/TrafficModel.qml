import QtQuick 1.1
import MapsPlugin 1.0
import "ModelFactory.js" as ModelFactory
import "models.js" as Models
import "../components/components.js" as Components


Traffic {
    id: traffic
    property variant appSettingsModel: ModelFactory.getModel("AppSettingsModel")

    property bool trafficOn: appSettingsModel.trafficOn
    property bool isLoadingTraffic: trafficOn && (traffic.status == Traffic.TRAFFIC_REQUESTING)
    property bool ready: false
    property int trafficRadius: 50 // km

    property int pollingInterval: (traffic.status == Traffic.TRAFFIC_ERROR) ? 5000 : appSettingsModel.trafficUpdateInterval*60*1000
    property bool mapPanning: (map !== undefined) ? map.hasUserInteraction : false
    property variant lastRequestCenter
    property variant map

    property Timer requestTimer: Timer {
        id: trafficRequestTimer
        repeat: true
        running: traffic.trafficOn
        interval: traffic.pollingInterval
        onTriggered: traffic.requestTraffic();
    }

    property Timer updateTimer: Timer {
        id: trafficUpdateTimer
        repeat: false
        interval: 3000 // 3 seconds
        onTriggered: traffic.requestTraffic()
    }

    signal trafficReady()
    signal trafficError()

    onStatusChanged: onTrafficStatusChanged();
    onEventsChanged: onTrafficEventsChanged();

    onMapPanningChanged: {
        var pan = traffic.mapPanning;
        if (trafficUpdateTimer.running) {
            trafficUpdateTimer.stop();
        }
        if (!pan && lastRequestCenter) {
            var distance = computeDistance(lastRequestCenter, map.center);
            if (distance > 40000) {
                trafficUpdateTimer.start();
            }
        }
    }

    function resetTraffic() {
        traffic.clear();
        traffic.stopPolling();
    }


    function requestTraffic() {
        if (map) {
            saveTrafficRequestCenter();
            traffic.requestTrafficAt(map.center, trafficRadius);
            trafficRequestTimer.restart();
        }
    }

    function isTrafficAvailable() {
        //return (countryCode == "c" || traffic.getAvailability(countryCode));
        return true; // return true for now. Doesn't seem to work using plugin...
    }

    function onTrafficStatusChanged() {
        console.log("TRAFFIC STATUS CHANGED: "+traffic.status);
        if (trafficOn) {
            if (!traffic.ready) {
                traffic.ready = true;
                trafficReady();
            }
            if (traffic.status == Traffic.TRAFFIC_ERROR) {
                trafficError();
            }
        }
    }

    function onTrafficEventsChanged() {
    }

    function saveTrafficRequestCenter() {
        var positioningModel = ModelFactory.getModel("PositioningModel");
        if(lastRequestCenter) {
            lastRequestCenter.destroy();
        }
        if (map) {
            lastRequestCenter = positioningModel.createGeoCoordinates(map.center);
        }
    }

    function computeDistance(from, to) {
        if (!from || !to) return 0;
        var PI_OVER_180 = Math.PI / 180,
            thetaA = from.latitude * PI_OVER_180,
            phiA = from.longitude * PI_OVER_180,
            cosThetaA = Math.cos(thetaA),
            ax = cosThetaA * Math.sin(phiA),
            ay = cosThetaA * Math.cos(phiA),
            az = Math.sin(thetaA),
            thetaB = to.latitude * PI_OVER_180,
            phiB = to.longitude * PI_OVER_180,
            cosThetaB = Math.cos(thetaB),
            bx = cosThetaB * Math.sin(phiB),
            by = cosThetaB * Math.cos(phiB),
            bz = Math.sin(thetaB);
        return 6371e3 * Math.acos(ax*bx + ay*by + az*bz);
    }
}
