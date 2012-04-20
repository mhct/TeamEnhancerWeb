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
    if 'undefined' == typeof callback
        io = socket.listen app
    else
        io = socket.listen app, callback

    io.set 'log level', 1
    console.log 'Coordination Service started.'
    
    io.sockets.on 'connection', (socket) ->
        
        socket.on 'rideRequest', (event, response) ->
            newRideRequest(store, socket, event.rideRequest)

        socket.on 'locationUpdate', (event, response) ->
            getTaxiSockets()[event.taxiId] = socket
            socket.set('id', event.taxiId, ->
                store.updateLocation event, ->
                    socket.emit 'locationUpdated', '{"acknowledgement":"ok"}'
            )

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

    store.findTaxiByLocation rideRequest, (selectedTaxis) ->
        for taxi in JSON.parse(selectedTaxis)
            if getTaxiSockets()[taxi.taxiId]?
                getTaxiSockets()[taxi.taxiId].emit 'rideOffer', 'MARIO'

    setTimeout(announceWinningTaxi, COORDINATION_TIMEOUT, socket)

#
# Finishes the coodination (Contractnet)
#
announceWinningTaxi = (clientSocket) ->
    clientSocket.emit 'RideResponse', "taxi" #TODO add event in the future

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
