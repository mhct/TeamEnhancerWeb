#
# 03/05/2012
# @mariohct
#
# TaxiAgent is the taxiapp simulator, it simulates the driver user of the taxiapp. it is responsible for interacting with the driver (Driver) 
# and with the ride auctions ?
#
# FIXME there is a bug in the socket.io-client. nothing happens, if the server is not running
#
# Environment VARS
# HOME_LOCATION = [Float, Float], home location of taxi driver, to start simulation
# EVENTS_SERVER = URL, events server url
# AGENT_NAME = String, string to identify the current agent
#
io = require 'socket.io-client'
i = require('util').inspect

TaxiDriver = require('./taxi_driver').Driver

socketUrl = process.env.EVENTS_SERVER || 'http://localhost:3000'
agentName = (Number) process.env.AGENT_NAME || undefined
driverSpeed = (Number) process.env.DRIVER_SPEED || undefined
elapsedTime = (Number) process.env.ELAPSED_TIME || undefined
tickInterval = (Number) process.env.TICK_INTERVAL || undefined
homeLocation = []
homeLocation[0] = (Number) process.env.HOME_LOCATION_LATITUDE || undefined
homeLocation[1] = (Number) process.env.HOME_LOCATION_LONGITUDE || undefined

socket = null
isConnected = false

class TaxiAgent
    constructor: (@agentName, @socketUrl) ->
        console.log "Loading TaxiAgent: #{@agentName}, at #{@socketUrl}, home: #{homeLocation}"
        @driver = new TaxiDriver(@agentName, driverSpeed, homeLocation)

    run: =>
        @socket.on 'connect', =>
            console.log "#{agentName} connected."

        @socket.on 'disconnect', =>
            console.log "#{agentName} disconnected."

        @socket.on 'connect_failed', =>
            console.log "#{agentName} connection failed."

        @socket.on 'rideOffer', (rideOffer) =>
            console.log "received rideOffer"
            @driver.makeBidFor rideOffer, (bid) =>
                rideBid =
                    rideRequestId: rideOffer.rideRequestId
                    taxiId: @driver.getName()
                    estimatedTimeToPickup: bid

                @socket.emit "rideBid", rideBid

        @socket.on 'rideAwarded', (rideRequest) =>
            console.log "rideAwarded #{i(rideRequest)}"
            @driver.addRide rideRequest
       

    connect: =>
        @socket = io.connect @socketUrl
        this.run()

    updateLocation: (elapsedTime) =>
        currentLocation = @driver.getCurrentLocation(elapsedTime)
        headingTo = @driver.headingTo()

        locationUpdateEvent =
            taxiId:@driver.getName()
            currentLocation:
                    latitude: currentLocation[0]
                    longitude: currentLocation[1]
            headingToLocation:
                latitude: headingTo[0]
                longitude: headingTo[1]
            hasPassenger: @driver.hasPassenger111()
        console.log i(locationUpdateEvent)

        @socket.emit "locationUpdate", locationUpdateEvent

        #check if it is the end of the ride
        if @driver.hasFinishedRide()
            @driver.finishRide()
            @socket.emit "rideFinished", {taxiId: @driver.getName(), rideRequestId: @driver.getRideRequestId()}

    stop: =>
        @socket.disconnect()

    test: =>
        if @socket?
            now = new Date()
            @socket.emit "data", now

myAgent = new TaxiAgent(agentName, socketUrl)
myAgent.connect()

# testing
# addroute
#myAgent.driver.addRoute([[50,4],[20,20],[30,30],[40,40],[30,30],[170, 170]])


setInterval(myAgent.updateLocation, tickInterval, elapsedTime)

process.on 'exit', ->
    now = new Date()
    console.log "FINISHED Agent #{agentName} at: #{now}"

doNothing = ->
       #locationUpdateEvent =
       #     taxiId: 1
       #     currentLocation:
       #             latitude: currentLocation[0]
       #             longitude: currentLocation[1]
       #     headingToLocation:
       #         latitude: currentLocation[0]
       #         longitude: currentLocation[1]
       #         #latitude: headingTo[0]
       #         #longitude: headingTo[1]
       #     hasPassenger: @driver.hasPassenger111()
  
