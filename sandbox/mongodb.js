(function() {
  var Beer, BeerModel, Schema, Type, db, findBeer, findBeerByLocation, mongoose, westmalle;

  mongoose = require('mongoose');

  db = mongoose.connect('mongodb://localhost/test');

  Schema = mongoose.Schema;

  Type = new Schema({
    name: String,
    main_ingredient: String
  });

  Beer = new Schema({
    brand: String,
    location: {
      type: [],
      index: {
        location: '2d'
      }
    },
    type: [Type],
    brewery_age: Number,
    rating: Number
  });

  BeerModel = mongoose.model('BeerModel', Beer);

  westmalle = new BeerModel({
    brand: 'Westmalle',
    location: [50.8790, 4.7015],
    brewery_age: 86,
    rating: 10
  });

  westmalle.type.push({
    name: 'Ale',
    main_ingredient: 'Malted Barley'
  });

  westmalle.save(function(err) {
    if (err) {
      return console.log(err);
    } else {
      console.log("UHU saved");
      return findBeerByLocation();
    }
  });

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
        $nearSphere: [50.8700, 4.7000],
        $maxDistance: 1
      }
    }, null, {
      limit: 50
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

}).call(this);
