#
# 12/04/2012
# @mariohct
#
# Coordination Service 
#
#
socket = require 'socket.io'
io = null

#
# Dispatches events to the controller and to the clients
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
    
    clients = {}
    io.sockets.on 'connection', (socket) ->
        
        socket.on 'rideRequest', (event, response) ->
            store.findTaxiByLocation event.rideRequest, (selectedTaxis) ->
                for taxi in JSON.parse(selectedTaxis)
                    if clients[taxi.taxiId]?
                        clients[taxi.taxiId].emit 'rideOffer', 'MARIO'
                socket.emit 'event1', "#{taxi.taxiId}" #TODO add event in the future

            #store.findTaxiByLocation event.rideRequest, (selectedTaxis) ->
            #    for taxi in selectedTaxis
            #        clients[taxi.taxiId].emit 'rideOffer',event.rideRequest
            #    socket.emit 'event1'
            #socket.emit 'event1'

        socket.on 'locationUpdate', (event, response) ->
            clients[event.locationUpdate.taxiId] = socket
            socket.set('id', event.locationUpdate.taxiId, ->
                store.updateLocation event.locationUpdate, ->
                    socket.emit 'locationUpdated', '{"value":"ok"}'
            )




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

#
# Coordinates a number os taxis
#
# @taxis = list of taxis in JSON format
# @res = callback, expects a Http.Response object
#
simpleAuctionCoordinate = (taxis, res) ->
    console.log "Should coordinate #{taxis.length}"

    res.send "OK"
        


exports.coordinate = simpleAuctionCoordinate
exports.at = at
exports.stop = stop
