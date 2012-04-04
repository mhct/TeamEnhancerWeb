(function() {
  var app, express;

  express = require('express');

  app = express.createServer();

  app.listen(3000);

  app.use(express.bodyParser());

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
