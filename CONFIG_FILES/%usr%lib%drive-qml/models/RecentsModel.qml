import QtQuick 1.1

Database {
    databaseName: "DriveRecentDestinations"
    databaseVersion: "1.0"
    databaseDesc: "Drive's recent destinations"
    estimatedSize: 1000
    property int limit: 100

    function initialize() {
        execute('CREATE TABLE IF NOT EXISTS recents(key VARCHAR(128) PRIMARY KEY, destination TEXT, ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP)');
    }

    function getDestinations() {
        var recents = query("SELECT destination FROM recents ORDER BY ts DESC");

        for(var i=0, len=recents.length; i<len; i++) {
            recents[i] = JSON.parse(recents[i].destination);
        }

        return recents;
    }

    function addDestination(destination) {
        var key = destination.location.latitude + "|" + destination.location.longitude;
        var dest = JSON.stringify(destination)

        execute('INSERT OR REPLACE INTO recents(key, destination) VALUES (?,?)', [key, dest]);

        if (count() > limit) {
            execute("DELETE FROM recents WHERE ts = (SELECT MIN(ts) FROM recents)");
        }
    }

    function count() {
        var res = query("SELECT COUNT(*) AS count FROM recents");
        return res[0].count;
    }

    function isEmpty() {
        return count() == 0;
    }

    function clear() {
        execute("DELETE FROM recents");
    }

    Component.onCompleted: initialize();
}
