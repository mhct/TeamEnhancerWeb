(function() {
  var app, coordination, express, myfunc, port, store;

  express = require('express');

  app = express.createServer();

  store = require('./location_store_mongo').at(null);

  coordination = require('./events_controller').at(app, store);

  app.use(express.bodyParser());

  port = process.env.PORT || 3000;

  app.listen(port, function() {
    return console.log("Listening on " + port);
  });

  app.get('/lib/*', function(req, res) {
    return res.sendfile(__dirname + req.url);
  });

  app.get('/css/*', function(req, res) {
    return res.sendfile(__dirname + req.url);
  });

  app.get('/', function(req, res) {
    return res.send('OK');
  });

  app.get('/rider', function(req, res) {
    return res.sendfile(__dirname + '/templates/rider.html');
  });

  app.post('/taxi', function(req, res) {
    console.log("Registering new device");
    return store.registerTaxi(req.body.taxiRegistration, function(data) {
      return res.send(data);
    });
  });

  app.post("/a", function(req, res) {
    console.log("A " + req.body.value);
    return myfunc(req.body.value, function(data) {
      return res.send(data);
    });
  });

  myfunc = function(value, fn) {
    console.log("MERDA value=" + value);
    return setTimeout(fn, 10000, "" + value);
  };

  console.log("Server ready!");

}).call(this);
