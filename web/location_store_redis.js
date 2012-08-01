(function() {
  var async, client, createStore, redis, respNewsToJSON, retrieveNews, updateTaxiLocation;

  redis = require('redis');

  client = redis.createClient();

  async = require('async');

  createStore = function() {
    console.log("News Store created");
    return client.on('error', function(err) {
      return console.log("Error: " + err);
    });
  };

  updateTaxiLocation = function(taxiId, locationUpdate) {
    console.log("locationUpdate data: " + locationUpdate + "$");
    return client.lpush("taxi:" + taxiId + ":location", locationUpdate, function(err, resp) {
      if (err !== null) {
        return console.log("ERROR updating taxi:" + taxiId + " location");
      } else {
        return console.log("taxi:" + taxiId + " location updated");
      }
    });
  };

  retrieveNews = function(storyLineId, socket) {
    return client.lrange("storyline:" + storyLineId, 0, -1, function(err, newsIds) {
      var a, createCalls, i, key, _len;
      a = [];
      createCalls = function(key, i) {
        return a[i] = function(callback) {
          return client.hmget(key, "description", "date", function(err, resp) {
            return callback(null, respNewsToJSON(resp));
          });
        };
      };
      for (i = 0, _len = newsIds.length; i < _len; i++) {
        key = newsIds[i];
        createCalls("news:" + key, i);
      }
      return async.parallel(a, function(err, results) {
        if (results instanceof Array) {
          console.log("ARRAY: " + results + " $$$");
          return socket.emit("initial_news_events", results);
        } else {
          return console.log("NAO");
        }
      });
    });
  };

  respNewsToJSON = function(resp) {
    var msg;
    return msg = {
      description: resp[0],
      date: resp[1]
    };
  };

  exports.createStore = createStore;

  exports.updateTaxiLocation = updateTaxiLocation;

  exports.retrieveNews = retrieveNews;

}).call(this);
