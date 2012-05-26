(function() {
  var coordinate, simpleAuctionCoordinate, store;

  store = require('./location_store_mongo');

  coordinate = function(rideRequest, fn) {
    return store.findTaxiByLocation(rideRequest);
  };

  simpleAuctionCoordinate = function(taxis, res) {
    console.log("Should coordinate " + taxis.length);
    return res.send("OK");
  };

}).call(this);
