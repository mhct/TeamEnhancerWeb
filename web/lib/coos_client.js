(function() {
  var Coos, UPDATE_TIME, root,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

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
      this.registerAsParticipant = __bind(this.registerAsParticipant, this);
      this.requestCollaboration = __bind(this.requestCollaboration, this);
      if (!(this.updateTime != null)) this.updateTime = UPDATE_TIME;
      if (!(coosServer != null)) {
        throw "Server Address should be defined";
      } else {
        this.socket = io.connect(coosServer);
      }
    }

    Coos.prototype.requestCollaboration = function(deviceId, latLng, payload, initiatorCallback) {
      this.initiatorCallback = initiatorCallback;
      console.log("requestCollaboration");
      this.socket.emit('CollaborationRequest', payload);
      return this.socket.on('CollaborationResponse', initiatorCallback);
    };

    Coos.prototype.registerAsParticipant = function(deviceId, locationCallback, participantCallback) {
      var _this = this;
      this.participantCallback = participantCallback;
      console.log("registerAsParticipant");
      return this.socket.on('CollaborationRequest', function(collaborationRequestDTO) {
        console.log("CoosClient received a CollaborationRequest");
        return _this.participantCallback(collaborationRequestDTO, function(payload, bid) {
          var collaborationBid;
          collaborationBid = {
            deviceId: _this.deviceId,
            collaborationRequestId: collaborationRequestDTO.collaborationRequestId,
            payload: payload,
            bid: bid
          };
          return _this.socket.emit('CollaborationResponse', collaborationBid);
        });
      });
    };

    return Coos;

  })();

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  root.Coos = Coos;

}).call(this);
