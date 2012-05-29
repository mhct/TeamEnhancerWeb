#
# 12/04/2012
# @mariohct
#
# Events Controller
#
# Responsible for receiveing and dispatching events to clients
#
socket = require 'socket.io'
i = require('util').inspect


#coordService = require 'coordination_service'

#
# IO event listener
#
io = null
_store = null

COORDINATION_TIMEOUT = 10000 # in milliseconds

#
# List of available connected taxis/devices
# TODO put this in redis
#
taxiSockets = {}
clientSockets = {}

connectionOptions =
    "transports": ['xhr-polling']
    'try multiple transports': false
    'log level': 10

    #"polling duration": 10

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
        io = socket.listen app, connectionOptions
        console.log "without callback"
    else
        io = socket.listen app, callback
        console.log "with callback"

    #io.set 'log level', 1
    #io.configure(->
    #    io.set("transports", ["xhr-polling"])
    #    io.set("polling duration", 10)
    #)
    #io.set("transports", ["xhr-polling"])
    #io.set("polling duration", 10)

    console.log 'Coordination Service started.'
   
    io.sockets.on 'connection', (socket) ->
        
        socket.on 'echo', (data) ->
            console.log "echo: #{data}"
            socket.emit "echoReply", {"data": data}

        socket.on 'rideRequest', (rideRequest, response) ->
            console.log 'rideRequest received'
            newRideRequest(store, socket, rideRequest)

        socket.on 'locationUpdate', (event, response) ->
            console.log "locationUpdate #{i(event)}"
            getTaxiSockets()[event.taxiId] = socket
            socket.set('id', event.taxiId, ->
                store.updateLocation event, ->
                    socket.emit 'locationUpdated', '{"acknowledgement":"ok"}'
            )

        socket.on 'rideBid', (bid, response) ->
            store.makeBid bid, ->
                socket.emit 'rideBidReceived', '{"acknowledgement":"ok"}'

        socket.on 'rideFinished', (rideData, response) ->
            console.log "rideData: #{i(rideData)}"
            if getClientSockets()[rideData.rideRequestId]?
                getClientSockets()[rideData.rideRequestId].emit 'rideFinished', {ok: 'ok'}
            else
                console.log "socket unavailable"

getClientSockets = ->
    clientSockets
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
    _store.makeRequest rideRequest, (res) ->
        rideRequest._id = res._id #add _id to persisted rideRequest
        getClientSockets()[rideRequest._id] = socket
        console.log "nrr: #{rideRequest._id}"
        _store.findTaxiByLocation rideRequest, (selectedTaxis) ->
            console.log "RideRequest: #{i(rideRequest)}"
            console.log "SelectedTaxis: #{i(selectedTaxis)}"
            if selectedTaxis? and selectedTaxis.length > 0
                for taxi in selectedTaxis
                    console.log "taxi: #{taxi}"
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
            clientSocket.emit 'rideResponse', {taxiId: -1, estimatedTimeToPickup:-1}
        else
            if getTaxiSockets()[winnerBid.taxiId]?
                getTaxiSockets()[winnerBid.taxiId].emit 'rideAwarded', rideRequest
                clientSocket.emit 'rideResponse', {taxiId: "#{winnerBid.taxiId}",estimatedTimeToPickup: "#{winnerBid.estimatedTimeToPickup}"}
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
