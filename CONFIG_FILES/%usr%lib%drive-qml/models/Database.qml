import QtQuick 1.1

QtObject {
    id: database

    property string databaseName
    property string databaseVersion: "1.0"
    property string databaseDesc: ""
    property int estimatedSize: 1000 // in bytes

    function getDatabase() {
        var db = openDatabaseSync(databaseName, databaseVersion, databaseDesc, estimatedSize);
        return db;
    }

    function query(sql, values) {
        var db = database.getDatabase();
        var results = [];

        var rs = db.readTransaction(function(tx) {
            var sqlResults = values ? tx.executeSql(sql, values) : tx.executeSql(sql);
            var rows = sqlResults.rows;
            for (var i = 0, len = rows.length; i < len; i++) {
                results.push(rows.item(i));
            }
        });

        return results;
    }

    function execute(sql, values) {
        var db = database.getDatabase();
        var ret;

        db.transaction(function(tx) {
            ret = values ? tx.executeSql(sql, values) : tx.executeSql(sql);
        });

        return ret;
    }
}
