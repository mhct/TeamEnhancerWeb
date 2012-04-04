(function() {
  var app, express, port;

  express = require('express');

  app = express.createServer();

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

  app.post('/rider/:riderId', function(req, res) {
    console.log("RiderId: " + req.params.riderId + " lat: " + req.body.latitude + ", lon: " + req.body.longitude);
    return res.send('OK');
  });

  console.log("Server ready!");

}).call(this);
