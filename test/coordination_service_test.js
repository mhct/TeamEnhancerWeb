(function() {
  var coordService, io, options, port, rideRequest, socketUrl, testLoadsService;

  require('should');

  io = require('socket.io-client');

  coordService = null;

  storeMock = function() {};

  storeMock.prototype.findTaxiByLocation = function(param, fn) {
    console.log("Parameters " + param);
    return fn("{'result':'ok'}");
  };

  port = null;

  socketUrl = null;

  testLoadsService = true;

  if (testLoadsService) {
    port = 5000;
    socketUrl = "http://0.0.0.0:" + port;
  } else {
    port = 3000;
    socketUrl = "http://0.0.0.0:" + port;
  }

  options = {
    transports: ['websockets'],
    'force new connection': true
  };

  rideRequest = {
    "rideRequest": {
      "clientId": 1,
      "pickupLocation": {
        "latitude": 10,
        "longitude": 12
      },
      "deliveryLocation": {
        "latitude": 90,
        "longitude": 100
      },
      "timeToPickup": 1
    }
  };

  describe('Coordination Service', function() {
    if (testLoadsService) {
      before(function(done) {
        return coordService.at(port, storeMock, done);
      });
      after(function(done) {
        return coordService.stop(done);
      });
    }
    return it('should inform a user has connected', function(done) {
      var client1;
      client1 = io.connect(socketUrl);
      client1.on('connect', function() {
        return client1.emit('rideRequest', rideRequest);
      });
      client1.on('connect_failed', function() {
        should.fail('Couldn\'t connect');
        return done();
      });
      return client1.on('event1', function(data) {
        should.be.ok;
        return done();
      });
    });
  });

}).call(this);
