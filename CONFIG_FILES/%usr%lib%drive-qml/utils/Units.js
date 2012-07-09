.pragma library

//unit system and unit constants
var SYSTEM_IMPERIAL_UK = "imp_uk";
var SYSTEM_IMPERIAL_US = "imp_us";
var SYSTEM_METRIC = "metric";

var UNIT_METERS = qsTrId("qtn_drive_unit_meters");
var UNIT_YARDS = qsTrId("qtn_drive_unit_yards");
var UNIT_FEET = qsTrId("qtn_drive_unit_feet");
var UNIT_KILOMETERS = qsTrId("qtn_drive_unit_kilometers");
var UNIT_MILES = qsTrId("qtn_drive_unit_miles");
var UNIT_MILESPERHOUR = qsTrId("qtn_drive_unit_milesperhour");
var UNIT_KILOMETERSPERHOUR = qsTrId("qtn_drive_unit_kilometersperhour");
var UNIT_SECOND = qsTrId("qtn_drive_unit_second");
var UNIT_MINUTE = qsTrId("qtn_drive_unit_minute");
var UNIT_HOUR = qsTrId("qtn_drive_unit_hour");

//simply useful
var FOOT_IN_METERS = 0.3048;
var MILE_IN_FEET = 5280;
var YARD_IN_METERS = 0.9144;
var MILE_IN_YARDS = 1760;
var KILOMETERS_IN_MILE = 1.6093; // should be MILE_IN_KILOMETERS
var MILE_IN_METERS = 1609.344;

//For speed limit warner
var SPEED_LIMIT_METRIC = 80;
var SPEED_LIMIT_OFFSET_MAX_METRIC = 30;
var SPEED_LIMIT_OFFSET_MAX_IMPERIAL = 18;

//State variables
var currentSystem = SYSTEM_METRIC;


function round(aNumber, aSignificantDigits, aDecimals, aResolution) {
    aResolution && (aNumber = Math.round(aNumber / aResolution) * aResolution);

    if (!aSignificantDigits) {
        return 1 * aNumber.toFixed(aDecimals || 1);
    }
    if (aNumber === 0) {
        return aNumber;
    }
    var exponent = Math.floor(Math.log(Math.abs(aNumber)) / Math.LN10) + 1 - aSignificantDigits;
    if (exponent <= 0) {
        return 1 * aNumber.toFixed(-exponent);
    } else {
        var factor = Math.pow(10, exponent);
        return Math.round(aNumber / factor) * factor;
    }
}

function usingImperial() {
    return currentSystem != SYSTEM_METRIC
}

function getCurrentShortDistanceUnit() {
    return currentSystem == SYSTEM_METRIC ? UNIT_METERS :
           currentSystem == SYSTEM_IMPERIAL_US ? UNIT_FEET : UNIT_YARDS;
}

function getCurrentLongDistanceUnit() {
    return currentSystem == SYSTEM_METRIC ? UNIT_KILOMETERS : UNIT_MILES;
}

function getCurrentSpeedUnit() {
    return currentSystem == SYSTEM_METRIC ? UNIT_KILOMETERSPERHOUR : UNIT_MILESPERHOUR;
}

function roundTo(value, div) {
    return Math.round(value / div) * div;
}

function getReadableDistanceVisual(aDistance) {
    var dist; // to store return values in pair
    var toUnit = function(m, ratio) { return m / ratio; };
    var toBigUnit = function(m, ratio) {
        var big = toUnit(m, ratio);
        return big.toFixed(big < 100 ? 1 : 0);
    }
    var meterToFoot = function(m) { return toUnit(m, FOOT_IN_METERS); };
    var meterToYard = function(m) { return toUnit(m, YARD_IN_METERS); };
    var meterToMile = function(m) { return toBigUnit(m, MILE_IN_METERS); };
    var meterToKilo = function(m) { return toBigUnit(m, 1000); };

    function distInMetric(d) {
        return d >= 995 ? [meterToKilo(d), UNIT_KILOMETERS]
                        : [roundTo(d, (d > 300 ? 10 : 5)), UNIT_METERS];
    };

    function distInUs(d) {
        var dm = meterToMile(d);
        return (dm > 0.1) ? [dm, UNIT_MILES]
                          : [roundTo(meterToFoot(d), 10), UNIT_FEET];
    }

    function distInUk(d) {
        var dy = meterToYard(d);
        return dy > 900 ? [meterToMile(d), UNIT_MILES]
                        : [roundTo(dy, (dy > 300 ? 10 : 5)), UNIT_YARDS];
    }

    switch (currentSystem) {
    case SYSTEM_METRIC:
        dist = distInMetric(aDistance);
        break;
    case SYSTEM_IMPERIAL_US:
        dist = distInUs(aDistance);
        break;
    case SYSTEM_IMPERIAL_UK:
        dist = distInUk(aDistance);
        break;
    default: // should never be here
        dist = [0, ""];
        break;
    }

    return { value: dist[0], unit: dist[1] };
}

var getReadableSpeed = function(aSpeed) {
    var ratio = usingImperial() ? 2.23693629 : 3.6;
    var value = (!aSpeed || aSpeed < 0) ? "-" : Math.round(aSpeed * ratio);
    var unit = usingImperial() ? UNIT_MILESPERHOUR : UNIT_KILOMETERSPERHOUR;
    return { value: value, unit: unit };
};

var getReadableSpeedLimit = function(aSpeed, locale) {
    var readableSpeed = getReadableSpeed(aSpeed);
    if (!isNaN(readableSpeed.value)) {
        readableSpeed.value = roundTo(readableSpeed.value, 5);
    }

    return readableSpeed;
};

var getReadableTime = function(aTime, aOptions) {
    if (!aTime) {
        return {value: 0, unit: UNIT_SECOND};
    } else if (aTime < 60 && aOptions && aOptions.RoundToMinute) {
        return {value: 1, unit: UNIT_MINUTE};
    } else if (aTime < 60) {
        return {value: aTime, unit: UNIT_SECOND};
    } else if (aTime < 3600) {
        return {value: Math.round(aTime / 60), unit: UNIT_MINUTE};
    } else if (aTime < 36000) {
        var min = Math.floor((aTime % 3600) / 60);
        return {value: Math.floor(aTime / 3600) + (min < 10 ? ":0" : ":") + min, unit: UNIT_HOUR};
    }

    return {value: Math.round(aTime / 3600), unit: UNIT_HOUR};
};
