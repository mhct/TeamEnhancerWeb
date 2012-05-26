(function() {
  var COORDINATION_TIMEOUT, announceWinningTaxi, at, clientSockets, getClientSockets, getTaxiSockets, i, io, newRideRequest, socket, stop, taxiSockets, _store;

  socket = require('socket.io');

  i = require('util').inspect;

  io = null;

  _store = null;

  COORDINATION_TIMEOUT = 10000;

  taxiSockets = {};

  clientSockets = {};

  at = function(app, store, callback) {
    _store = store;
    if ('undefined' === typeof callback) {
      io = socket.listen(app);
    } else {
      io = socket.listen(app, callback);
    }
    io.set('log level', 1);
    io.configure('production', function() {
      return io.set('transports', ['xhr-polling']);
    });
    console.log('Coordination Service started.');
    return io.sockets.on('connection', function(socket) {
      socket.on('data', function(data) {
        return console.log("received: " + data);
      });
      socket.on('rideRequest', function(rideRequest, response) {
        console.log('rideRequest received');
        return newRideRequest(store, socket, rideRequest);
      });
      socket.on('locationUpdate', function(event, response) {
        console.log("locationUpdate " + (i(event)));
        getTaxiSockets()[event.taxiId] = socket;
        return socket.set('id', event.taxiId, function() {
          return store.updateLocation(event, function() {
            return socket.emit('locationUpdated', '{"acknowledgement":"ok"}');
          });
        });
      });
      socket.on('rideBid', function(bid, response) {
        return store.makeBid(bid, function() {
          return socket.emit('rideBidReceived', '{"acknowledgement":"ok"}');
        });
      });
      return socket.on('rideFinished', function(rideData, response) {
        console.log("rideData: " + (i(rideData)));
        if (getClientSockets()[rideData.rideRequestId] != null) {
          return getClientSockets()[rideData.rideRequestId].emit('rideFinished', {
            ok: 'ok'
          });
        } else {
          return console.log("socket unavailable");
        }
      });
    });
  };

  getClientSockets = function() {
    return clientSockets;
  };

  getTaxiSockets = function() {
    return taxiSockets;
  };

  newRideRequest = function(store, socket, rideRequest) {
    return _store.makeRequest(rideRequest, function(res) {
      rideRequest._id = res._id;
      getClientSockets()[rideRequest._id] = socket;
      console.log("nrr: " + rideRequest._id);
      _store.findTaxiByLocation(rideRequest, function(selectedTaxis) {
        var taxi, _i, _len, _results;
        console.log("RideRequest: " + (i(rideRequest)));
        console.log("SelectedTaxis: " + (i(selectedTaxis)));
        if ((selectedTaxis != null) && selectedTaxis.length > 0) {
          _results = [];
          for (_i = 0, _len = selectedTaxis.length; _i < _len; _i++) {
            taxi = selectedTaxis[_i];
            console.log("taxi: " + taxi);
            if (getTaxiSockets()[taxi.taxiId] != null) {
              _results.push(getTaxiSockets()[taxi.taxiId].emit('rideOffer', rideRequest));
            } else {
              _results.push(void 0);
            }
          }
          return _results;
        }
      });
      return setTimeout(announceWinningTaxi, COORDINATION_TIMEOUT, rideRequest, socket);
    });
  };

  announceWinningTaxi = function(rideRequest, clientSocket) {
    return _store.collectBids(rideRequest, function(bids) {
      var bid, winnerBid, _i, _len;
      winnerBid = {};
      winnerBid.estimatedTimeToPickup = Number.MAX_VALUE;
      for (_i = 0, _len = bids.length; _i < _len; _i++) {
        bid = bids[_i];
        if (bid.estimatedTimeToPickup <= winnerBid.estimatedTimeToPickup) {
          winnerBid = bid;
        }
      }
      if (bids.length === 0) {
        return clientSocket.emit('rideResponse', {
          taxiId: -1,
          estimatedTimeToPickup: -1
        });
      } else {
        if (getTaxiSockets()[winnerBid.taxiId] != null) {
          getTaxiSockets()[winnerBid.taxiId].emit('rideAwarded', rideRequest);
          return clientSocket.emit('rideResponse', {
            taxiId: "" + winnerBid.taxiId,
            estimatedTimeToPickup: "" + winnerBid.estimatedTimeToPickup
          });
        } else {
          return console.log("ERROR, no socket found");
        }
      }
    });
  };

  stop = function(callback) {
    io.server.close();
    console.log('Coordination Service stoped.');
    if (callback != null) return callback();
  };

  exports.at = at;

  exports.stop = stop;

}).call(this);
