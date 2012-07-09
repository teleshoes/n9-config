import QtQuick 1.1
import MapsPlugin 1.0
import "ModelFactory.js" as ModelFactory
import "models.js" as Models
import "../components/components.js" as Components

Item {
    id: routingModel

    property variant currentRoute
    property variant mapModel
    property variant mapSettingsModel
    property variant appSettingsModel
    property int waypointIconSize: 64
    property variant currentMapRoute
    property variant currentRouteOptions
    property variant currentIconLayer
    property variant currentStartIcon
    property variant currentDestinationIcon

    signal routeCalculated(variant route)
    signal routeCalculationError(variant errorCode)

    Router {
        id: router
        onRoutingDone: {
            console.log("ROUTINGMODEL -> onRoutingDone: error code = " + errorCode);
            clearRoute();

            if (calculatedRoute && errorCode == Router.ERROR_NONE) {
                currentRoute = calculatedRoute.clone(routingModel);
                routeCalculated(currentRoute);
            } else {
                routeCalculationError(errorCode);
            }
        }
    }

    RoutePlan { id: routePlan }

    RouteOptions {
        id: routeOptions
        routeMode: RouteOptions.MODE_CAR
        routeType: RouteOptions.TYPE_FASTEST
    }

    Component.onCompleted: {
        mapModel = ModelFactory.getModel("MapModel");
        appSettingsModel = ModelFactory.getModel("AppSettingsModel");
        mapSettingsModel = ModelFactory.getModel("MapSettingsModel");

        updateRouteOptions();

        currentRouteOptions = routeOptions;
        appSettingsModel.routeOptionsChanged.connect(updateRouteOptions);
    }

    function calculateRoute(from, to, map) {
        console.log("Calculating route from [" + from.latitude + ", " + from.longitude + "] to [" + to.latitude + ", " + to.longitude + "]");

        //Go online if necessary
        if (!device.online && appSettingsModel.isConnectionAllowed())
            device.openNetworkConnection();

        //cleanup, add stopovers and settings
        clearRoute();
        routePlan.removeAllStopovers();
        routePlan.addStopover(from);
        routePlan.addStopover(to);
        routePlan.setAllRouteOptions(currentRouteOptions);

        //Calculate route
        router.calculate(routePlan);
    }

    function reCalculateRoute(map) {
        cancelCalculation();
        // update route options and recalculate the route
        routePlan.setAllRouteOptions(currentRouteOptions);
        router.calculate(routePlan);
    }

    function cancelCalculation() {
        router.cancel();
    }

    function clearRoute() {
        if (currentRoute) {
            currentRoute.destroy();
            currentRoute = undefined;
        }
    }

    function removeRouteFromMap(map) {
        if (currentMapRoute) {
            map.removeRoute(currentMapRoute);
            currentMapRoute.destroy();
            currentMapRoute = undefined;
        }
    }

    function showWaypointIcons(from, to, map) {
        //Create bounding box and zoom
        var bbox = [ from, to ];
        map.showPoints(bbox, null, Map.ANIMATION_NONE, Map.PRESERVE_ORIENTATION, Map.PRESERVE_PERSPECTIVE);

        //Create and show the icons
        currentIconLayer = mapModel.addLayer(map),
        currentStartIcon = mapModel.addIcon(from, map, currentIconLayer, Models.RoutingModel.icons.start, Qt.point(15, 59)),
        currentDestinationIcon = mapModel.addIcon(to, map, currentIconLayer, Models.RoutingModel.icons.destination, Qt.point(15, 59));
    }

    function showRouteOnMap(route, map) {
        //show on map
        var mapRoute = Qt.createQmlObject("import MapsPlugin 1.0; MapRoute {}", map, null);

        mapRoute.route = route;
        mapRoute.color = mapSettingsModel.nightMode ? Components.Route.nightColor : Components.Route.dayColor;
        map.addRoute(mapRoute);

        if (currentMapRoute) currentMapRoute.destroy();
        currentMapRoute = mapRoute;

        return mapRoute;
    }

    function removeCurrentRouteFromMap(map) {
        if (currentMapRoute) {
            map.removeRoute(currentMapRoute);
        }

        if (currentIconLayer) {
            mapModel.removeIcon(currentIconLayer, currentStartIcon);
            mapModel.removeIcon(currentIconLayer, currentDestinationIcon);
        }
    }

    function zoomToRoute(route, map, margins) {
        zoomToGeoRect(route.boundingBox, map, margins);
    }

    function zoomToGeoRect(geoRect, map, margins) {
        var viewport = null;
        if (margins) {
            viewport = Qt.rect(margins.left,
                               margins.top,
                               map.width - margins.left - margins.right,
                               map.height - margins.top - margins.bottom);
        }

        map.moveToRect(geoRect, viewport, Map.ANIMATION_BOW);
    }

    function extendGeoRect(geoRect, geoPoint) {
        var longitude = geoPoint.longitude,
            latitude = geoPoint.latitude;

        if (longitude < geoRect.left) {
            geoRect.left = longitude;
        } else if (longitude > geoRect.right) {
            geoRect.right = longitude;
        }

        if (latitude > geoRect.top) {
            geoRect.top = latitude;
        } else if (latitude < geoRect.bottom) {
            geoRect.bottom = latitude;
        }

        return geoRect;
    }

    function updateRouteOptions() {
        var options = appSettingsModel.get('routeOptions');
        routeOptions.allowHighways = !!(options & (1 << 5));
        routeOptions.allowTollRoads = !!(options & (1 << 4));
        routeOptions.allowFerries = !!(options & (1 << 3));
        routeOptions.allowTunnels = !!(options & (1 << 2));
        routeOptions.allowDirtRoads = !!(options & (1 << 1));
        routeOptions.allowRailFerries = !!(options & 1);
    }
}
