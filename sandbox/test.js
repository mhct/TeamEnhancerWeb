(function() {
  var A;

  A = (function() {

    function A() {}

    A.prototype.test = function() {
      return console.log("AAA");
    };

    return A;

  })();

}).call(this);
