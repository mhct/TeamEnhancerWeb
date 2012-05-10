#
# 12/04/2012
# @mariohct
#
# Events Controller
#
# Responsible for receiveing and dispatching events to clients
#
socket = require 'socket.io'
#coordService = require 'coordination_service'

#
# IO event listener
#
io = null
_store = null

#
# List of available connected taxis/devices
# TODO put this in redis
#
taxiSockets = {}


#
# Dispatches events using socket.io
#
# @app the port the service should listen to events
# @store store with the location of devices
# @callback called when the service is ready to listen to events
#
at = (app, store, callback) ->
    _store = store
    if 'undefined' == typeof callback
        io = socket.listen app
    else
        io = socket.listen app, callback

    io.set 'log level', 1
    console.log 'Coordination Service started.'
    
    io.sockets.on 'connection', (socket) ->
        
        socket.on 'data', (data) ->
            console.log "received: #{data}"

        socket.on 'rideRequest', (rideRequest, response) ->
            newRideRequest(store, socket, rideRequest)

        socket.on 'locationUpdate', (event, response) ->
            getTaxiSockets()[event.taxiId] = socket
            socket.set('id', event.taxiId, ->
                store.updateLocation event, ->
                    socket.emit 'locationUpdated', '{"acknowledgement":"ok"}'
            )

        socket.on 'rideBid', (bid, response) ->
            store.makeBid bid, ->
                socket.emit 'rideBidReceived', '{"acknowledgement":"ok"}'

#
# retrieves the list of sockets pointing to taxis/devices
#
getTaxiSockets = ->
    taxiSockets

#
# Announces new RideRequest to all taxis in the neighboorhood
#
# @store store with locations of devices/taxis
# @socket socket used by the client
# @rideRequest from the client
#
newRideRequest = (store, socket, rideRequest) ->
    COORDINATION_TIMEOUT = 10 # in milliseconds
    _store.makeRequest rideRequest, (res) ->
        rideRequest._id = res._id #add _id to persisted rideRequest
        _store.findTaxiByLocation rideRequest, (selectedTaxis) ->
            #console.log "RE2: #{rideRequest}"
            for taxi in JSON.parse(selectedTaxis)
                if getTaxiSockets()[taxi.taxiId]?
                    getTaxiSockets()[taxi.taxiId].emit 'rideOffer', rideRequest

        setTimeout(announceWinningTaxi, COORDINATION_TIMEOUT, rideRequest, socket)

#
# Finishes the coodination (Contractnet)
#
# The taxi which replies with the LOWEST estimatedTimeToPickup wins
#
# @rideRequest information about the ride request by the client
# @clientSocket socket used by the client who wants the Ride
#
# TODO rideRequestID but now it is only a regular json.. should persist the request before coming here
announceWinningTaxi = (rideRequest, clientSocket) ->
    _store.collectBids rideRequest, (bids) ->
        winnerBid = {}
        winnerBid.estimatedTimeToPickup = Number.MAX_VALUE
        for bid in bids
            if bid.estimatedTimeToPickup <= winnerBid.estimatedTimeToPickup
                winnerBid = bid

        if bids.length == 0
            clientSocket.emit 'rideResponse', {taxiId: 0, estimatedTimeToPickup:-1}
        else
            clientSocket.emit 'rideResponse', {taxiId: "#{winnerBid.taxiId}",estimatedTimeToPickup: "#{winnerBid.estimatedTimeToPikcup}"}
            if getTaxiSockets()[winnerBid.taxiId]?
                getTaxiSockets()[winnerBid.taxiId].emit 'rideAwarded', rideRequest
            else
                console.log "ERROR, no socket found"


#
# Stops the realtime event server
#
# @callback function to be called when the service is shutdown
#
stop = (callback) ->
    io.server.close()
    console.log 'Coordination Service stoped.'
    if callback?
        callback()



exports.at = at
exports.stop = stop
