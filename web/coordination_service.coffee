#
# 12/04/2012
# @mariohct
#
# Coordination Service 
#
#
socket = require 'socket.io'

io = null
#        store.findTaxiByLocation "#{req.params.riderId}", req.body.rideRequest, res, coordination.coordinate


at = (app, store, callback) ->
    if 'undefined' == typeof callback
        io = socket.listen app
    else
        io = socket.listen app, callback

    io.set 'log level', 1
    console.log 'Coordination Service started.'
    
    io.sockets.on 'connection', (socket) ->
        
        socket.on 'rideRequest', (event, response) ->
            #console.log "#{event.rideRequest.pickupLocation.latitude}"
            #store.findTaxiByLocation event.rideRequest, doStuff(res, io.sockets)
            
         
        socket.on 'locationUpdate', (event, response) ->
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
