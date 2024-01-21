var collectionName = 'collName';

var map = function () {
  function extractKeys(doc, prefix) {
    for (var key in doc) {
      if (doc.hasOwnProperty(key)) {
        var fullPath = prefix ? prefix + '.' + key : key;
        emit(fullPath, 1);
        if (typeof doc[key] === 'object' && !Array.isArray(doc[key])) {
          extractKeys(doc[key], fullPath);
        }
      }
    }
  }
  extractKeys(this, '');
};

var reduce = function (key, values) {
  return Array.sum(values);
};

var options = {
  out: { inline: 1 },
};

var collection = db.getCollection(collectionName);
var result = collection.mapReduce(map, reduce, options);

var allFields = result.results.map(function (doc) {
  return doc._id;
});

printjson(allFields);