(function() {
  var Beer, BeerModel, Schema, Type, createSampleData, db, findBeer, findBeerByLocation, i, mongoose, sampleData, sampleSize;

  mongoose = require('mongoose');

  db = mongoose.connect('mongodb://localhost/test');

  Schema = mongoose.Schema;

  Type = new Schema({
    name: String,
    main_ingredient: String
  });

  Beer = new Schema({
    brand: String,
    location: [],
    brewery_age: Number,
    rating: Number
  });

  Beer.index({
    location: '2d'
  });

  BeerModel = mongoose.model('BeerModel', Beer);

  sampleData = [];

  createSampleData = function(sampleSize) {
    var i, _results;
    _results = [];
    for (i = 0; 0 <= sampleSize ? i < sampleSize : i > sampleSize; 0 <= sampleSize ? i++ : i--) {
      _results.push(sampleData[i] = new BeerModel({
        brand: 'BLA' + sampleSize * Math.random(),
        location: [50 * Math.random(), 10 * Math.random()],
        brewery_age: 10,
        rating: 10
      }));
    }
    return _results;
  };

  sampleSize = 500000;

  console.log("creating data start");

  console.time('creating-data');

  createSampleData(sampleSize);

  console.timeEnd('creating-data');

  console.time('persisting-data');

  for (i = 0; 0 <= sampleSize ? i < sampleSize : i > sampleSize; 0 <= sampleSize ? i++ : i--) {
    sampleData[i].save();
  }

  console.timeEnd('persisting-data');

  findBeer = function() {
    return BeerModel.find({
      rating: {
        $gt: 5
      }
    }, function(err, beers) {
      var beer, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = beers.length; _i < _len; _i++) {
        beer = beers[_i];
        _results.push(console.log(beer));
      }
      return _results;
    });
  };

  findBeerByLocation = function() {
    return BeerModel.find({
      location: {
        $near: [50.8619, 4.6874],
        $maxDistance: 0.009
      }
    }, null, {
      limit: 50
    }, function(err, beers) {
      var beer, _i, _len;
      if (err === null) {
        for (_i = 0, _len = beers.length; _i < _len; _i++) {
          beer = beers[_i];
          console.log(beer);
        }
        if (beers.length === 0) return console.log("Not found");
      } else {
        return console.log("ERR listing " + err);
      }
    });
  };

}).call(this);
