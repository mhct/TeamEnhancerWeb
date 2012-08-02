(function() {
  var Coos, UPDATE_TIME, root;

  UPDATE_TIME = 1;

  Coos = (function() {
    var about;

    about = {
      Version: 0.1,
      Author: "Mario H.C.T.",
      Twitter: "@mariohct",
      Created: 2012
    };

    function Coos(coosServer, updateTime) {
      this.updateTime = updateTime;
      if (!(this.updateTime != null)) this.updateTime = UPDATE_TIME;
      if (!(coosServer != null)) {
        throw "Server Address should be defined";
      } else {
        this.socket = io.connect(coosServer);
      }
    }

    Coos.prototype.requestCollaboration = function(deviceId, latLng, payload, initiatorCallback) {
      return console.log("Not yet implemented");
    };

    Coos.prototype.registerAsParticipant = function(deviceId, locationCallback, participantCallback) {
      return this.socket.on('newTask', function(data) {
        console.log("CoosClient received data");
        return participantCallback(data);
      });
    };

    return Coos;

  })();

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  root.Coos = Coos;

}).call(this);
