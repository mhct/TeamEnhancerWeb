(function() {
  var RiderRequest, TaxiLocation, TaxiLocationModel, connection, findTaxiByLocation, getConnection, mongo, registerTaxi, updateLocation;

  mongo = require('mongoose');

  connection = mongo.connect('mongodb://localhost/test');

  RiderRequest = new mongo.Schema({
    riderId: Number,
    pickupLocation: [],
    deliveryLocation: [],
    timeToPickup: Number
  });

  TaxiLocation = new mongo.Schema({
    taxiId: {
      type: Number,
      unique: true
    },
    currentLocation: [],
    headingToLocation: [],
    hasPassenger: Boolean
  });

  RiderRequest.index({
    pickupLocation: '2d'
  });

  TaxiLocation.index({
    currentLocation: '2d'
  });

  TaxiLocationModel = mongo.model('TaxiLocationModel', TaxiLocation);

  getConnection = function() {
    return connection;
  };

  findTaxiByLocation = function(rideRequest, fn) {
    var MAX_DISTANCE;
    MAX_DISTANCE = 0.018;
    return TaxiLocationModel.find({
      currentLocation: {
        $near: [rideRequest.pickupLocation.latitude, rideRequest.pickupLocation.longitude],
        $maxDistance: MAX_DISTANCE
      },
      hasPassenger: false
    }, null, function(err, results) {
      if (err !== null) {
        console.log("ERROR: " + err);
        return fn(err);
      } else {
        console.log("Found " + results.length + " entries");
        return fn(results);
      }
    });
  };

  updateLocation = function(locationUpdate, fn) {
    var condition, options;
    condition = {
      taxiId: locationUpdate.taxiId
    };
    options = {
      multi: false
    };
    return TaxiLocationModel.update(condition, locationUpdate, options, function(err, res) {
      if (err !== null) {
        return console.log("ERROR persisting location update taxiId: " + taxiId + "\n" + err);
      } else {
        return fn();
      }
    });
  };

  registerTaxi = function(taxiRegistration, fn) {
    var taxi;
    taxi = new TaxiLocationModel({
      taxiId: taxiRegistration.taxiId,
      currentLocation: [taxiRegistration.currentLocation.latitude, taxiRegistration.currentLocation.longitude],
      headingToLocation: [taxiRegistration.headingToLocation.latitude, taxiRegistration.headingToLocation.longitude],
      hasPassenger: taxiRegistration.hasPassenger
    });
    return taxi.save(function(err, res) {
      if (err !== null) {
        return fn("" + err);
      } else {
        return fn("OK");
      }
    });
  };

  exports.findTaxiByLocation = findTaxiByLocation;

  exports.updateLocation = updateLocation;

  exports.registerTaxi = registerTaxi;

  exports.connection = getConnection;

}).call(this);
