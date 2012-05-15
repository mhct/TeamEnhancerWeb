#
# 14/05/2012
# @mariohct
#
# Passenger for the taxiapp 
#
# simulates a passenger for the taxiapp
#
io = require 'socket.io-client'

socketUrl = process.env.EVENTS_SERVER || 'http://localhost:3000'
passengerName = process.env.PASSENGER_NAME || 1
homeLocation = process.env.HOME_LOCATION || undefined

class PassengerAgent
    constructor: (@passengerName, @homeLocation, @socketUrl) ->
        #@passenger = new Passenger(@passengerName, @homeLocation)

    run: =>
        @socket.on 'connect', ->
            console.log "#{passengerName} connected."

        @socket.on 'disconnect', ->
            console.log "#{passengerName} disconnected."

        @socket.on 'connect_failed', ->
            console.log "#{passengerName} connection failed."

        @socket.on 'rideResponse', (rideResponse) ->
            console.log "rideResponse received"
            console.log "taxiId: #{rideResponse.taxiId}, time: #{rideResponse.estimatedTimeToPickup}"
    
        @socket.on 'rideFinished', (rideData) ->
            console.log 'rideFinished'

        #admin
        @socket.on 'admin_requestARide', (rideRequest) =>
            @requestARide(rideRequest)

    connect: =>
        @socket = io.connect @socketUrl
        this.run()

    requestARide: (rideRequest) =>
        @socket.emit "rideRequest", rideRequest

    stop: =>
        @socket.disconnect()

    test: =>
        if @socket?
            now = new Date()
            @socket.emit "data", now

myPassenger = new PassengerAgent(passengerName, [50.854509,4.351559], socketUrl)
myPassenger.connect()
ride =
    riderId:1
    pickupLocation:
        latitude: 50.853211
        longitude: 4.365722
    deliveryLocation:
        latitude: 51.017858
        longitude: 4.482365
    timeToPickup: 0

myPassenger.requestARide(ride)

setInterval(console.log, 1000, 'nada')
# testing
# addroute



#setInterval(myAgent.updateLocation, currentInterval, 1)

       

