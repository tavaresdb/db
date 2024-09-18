// Lista as estatísticas de todas as coleções. É possível obter o totalSize através da soma entre storageSize e totalIndexSize.
// Ref.: https://studio3t.com/whats-new/how-to-get-mongodb-statistics-for-all-collections-studio3t_ama/
var dbs = db.getMongo().getDBNames();

for (adb of dbs) {
    var colls = db.getSiblingDB(adb).getCollectionNames()

    for (coll of colls) {
        var info = db.getSiblingDB(adb).getCollection(coll).stats(1024);
        if (info.ok) {
            printjson({
                ns: info.ns,
                count: info.count,
                size: info.size,
                storageSize: info.storageSize,
                nindexes: info.nindexes,
                totalIndexSize: info.totalIndexSize
            });
        }
    }
}

// Lista todos os índices de um banco de dados, desconsiderando coleções com sufixo especificado.
var dbName = "db";

var collections = db.getSiblingDB(dbName).getCollectionNames();

collections.forEach(function (collectionName) {
    if (collectionName.endsWith("versions")) {
        return;
    }

    var collection = db.getSiblingDB(dbName)[collectionName];
    var stats = collection.stats(1024);

    var indexes = stats.indexSizes;

    for (var indexName in indexes) {
        var indexSizeKB = indexes[indexName];
        var indexSizeMB = indexSizeKB / 1024;

        var output = {
            "Coleção": collectionName,
            "Índice": indexName,
            "Tamanho (MB)": indexSizeMB.toFixed(2)
        };

        printjson(output);
    }
});