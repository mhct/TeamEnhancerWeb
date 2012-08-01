(function() {
  var RideBid, RideBidSchema, RideRequest, RideRequestSchema, TaxiLocation, TaxiLocationModel, at, collectBids, connection, findTaxiByLocation, getConnection, i, makeBid, makeRequest, mongo, registerTaxi, updateLocation;

  mongo = require('mongoose');

  i = require('util').inspect;

  connection = null;

  at = function(dbName) {
    connection = dbName != null ? mongo.connect("mongodb://localhost/" + dbName) : mongo.connect("mongodb://mw2012:bla132@staff.mongohq.com:10000/app3671227 ");
    return this;
  };

  RideRequestSchema = new mongo.Schema({
    riderId: {
      type: Number,
      unique: true
    },
    pickupLocation: [],
    deliveryLocation: [],
    timeToPickup: Number
  });

  RideBidSchema = new mongo.Schema({
    rideRequestId: {
      type: Number,
      index: true
    },
    taxiId: Number,
    estimatedTimeToPickup: Number
  });

  TaxiLocation = new mongo.Schema({
    taxiId: {
      type: Number,
      unique: true
    },
    currentLocation: {
      type: []
    },
    headingToLocation: [],
    hasPassenger: Boolean
  });

  RideRequestSchema.index({
    pickupLocation: '2d'
  });

  TaxiLocation.index({
    currentLocation: '2d'
  });

  TaxiLocationModel = mongo.model('TaxiLocationModel', TaxiLocation);

  RideBid = mongo.model('RideBid', RideBidSchema);

  RideRequest = mongo.model('RideRequest', RideRequestSchema);

  getConnection = function() {
    return connection;
  };

  findTaxiByLocation = function(rideRequest, fn) {
    var MAX_DISTANCE;
    MAX_DISTANCE = 10;
    return TaxiLocationModel.find({
      currentLocation: {
        $near: [rideRequest.pickupLocation.latitude, rideRequest.pickupLocation.longitude],
        $maxDistance: MAX_DISTANCE
      },
      hasPassenger: false
    }, null, function(err, results) {
      if (err !== null) {
        return fn(err);
      } else {
        return fn(results);
      }
    });
  };

  updateLocation = function(locationUpdate, fn) {
    var condition, options, update;
    condition = {
      taxiId: locationUpdate.taxiId
    };
    update = {
      taxiId: locationUpdate.taxiId,
      currentLocation: [locationUpdate.currentLocation.latitude, locationUpdate.currentLocation.longitude],
      headingToLocation: [locationUpdate.headingToLocation.latitude, locationUpdate.headingToLocation.longitude],
      hasPassenger: locationUpdate.hasPassenger
    };
    options = {
      multi: false
    };
    return TaxiLocationModel.update(condition, update, options, function(err, res) {
      if (err != null) {
        console.log("ERROR persisting location update taxiId: " + taxiId + "\n" + err);
        return fn();
      } else {
        console.log("LocationUpdated: taxiId: " + update.currentLocation);
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
      if (err != null) {
        return fn("" + err);
      } else {
        return fn("OK");
      }
    });
  };

  makeBid = function(bid, fn) {
    var rideBid;
    rideBid = new RideBid({
      rideRequestId: bid.rideRequestId,
      taxiId: bid.taxiId,
      estimatedTimeToPickup: bid.estimatedTimeToPickup
    });
    return rideBid.save(function(err, res) {
      if (err != null) {
        console.log("EER");
        return fn("" + err);
      } else {
        console.log("OK");
        return fn("ok");
      }
    });
  };

  collectBids = function(rideRequest, fn) {
    return RideBid.find({
      rideRequestId: rideRequest.rideRequestId
    }, function(err, bidsFound) {
      if (err != null) {
        return fn(err);
      } else {
        return fn(bidsFound);
      }
    });
  };

  makeRequest = function(rideRequest, fn) {
    var request;
    request = new RideRequest({
      riderId: rideRequest.riderId,
      pickupLocation: [rideRequest.pickupLocation.latitude, rideRequest.pickupLocation.longitude],
      deliveryLocation: [rideRequest.deliveryLocation.latitude, rideRequest.deliveryLocation.longitude],
      timeToPickup: rideRequest.timeToPickup
    });
    return request.save(function(err, res) {
      if (err != null) {
        console.log("ERR " + err);
        return fn(err);
      } else {
        console.log("_ID: " + res._id);
        return fn({
          _id: res._id
        });
      }
    });
  };

  exports.makeRequest = makeRequest;

  exports.findTaxiByLocation = findTaxiByLocation;

  exports.updateLocation = updateLocation;

  exports.registerTaxi = registerTaxi;

  exports.connection = getConnection;

  exports.at = at;

  exports.TaxiLocationModel = TaxiLocationModel;

  exports.RideBid = RideBid;

  exports.RideRequest = RideRequest;

  exports.makeBid = makeBid;

  exports.collectBids = collectBids;

}).call(this);
