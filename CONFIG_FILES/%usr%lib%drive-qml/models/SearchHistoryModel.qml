import QtQuick 1.1

Database {
    databaseName: "DriveSearchHistory"
    databaseVersion: "1.0"
    databaseDesc: "Drive's search history"
    estimatedSize: 1000
    property int limit: 100

    function initialize() {
        execute('CREATE TABLE IF NOT EXISTS history(searchTerm TEXT PRIMARY KEY, lastSearched INT)');
    }

    function getRecentSearchs() {
        var recents = query("SELECT searchTerm FROM history ORDER BY lastSearched DESC");
        for (var i = 0, len = recents.length; i < len; i++) {
            recents[i] = recents[i].searchTerm;
        }

        return recents;
    }

    function insert(searchTerm) {
        execute('INSERT OR REPLACE INTO history(searchTerm, lastSearched) VALUES (?, ?)', [searchTerm, new Date().getTime()]);

        if (count() > limit) {
            execute("DELETE FROM history WHERE lastSearched = (SELECT MIN(lastSearched) FROM history)");
        }
    }

    function count() {
        var res = query("SELECT COUNT(*) AS count FROM history");
        return res[0].count;
    }

    function isEmpty() {
        return count() == 0;
    }

    function clear() {
        execute("DELETE FROM history");
    }

    Component.onCompleted: initialize();
}
