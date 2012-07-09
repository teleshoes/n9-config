// -*- mode: js; js-indent-level: 4; -*-

// Please don't remove -- akahl20110518
.pragma library

var objects = {};
var maxResults = 200;

function getKey(id) {
    if (objects.hasOwnProperty(id)) {
        return id;
    }
    return null;
}

function getFromStore(id) {
    var key = getKey(id);
    if (key) {
        return objects[key];
    }
    return null;
}
