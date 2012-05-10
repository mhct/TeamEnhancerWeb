#
# 03/05/2012
# @mariohct
#
# TaxiAgent is the main taxi application, it is responsible for interacting with the driver (Driver) 
# and with the ride auctions
#
# FIXME there is a bug in the socket.io-client. nothing happens, if the server is not running
#
# Environment VARS
# HOME_LOCATION = [Float, Float], home location of taxi driver, to start simulation
# EVENTS_SERVER = URL, events server url
# AGENT_NAME = String, string to identify the current agent
#
io = require 'socket.io-client'
TaxiDriver = require('./taxi_driver').Driver

socketUrl = process.env.EVENTS_SERVER || 'http://localhost:3000'
agentName = process.env.AGENT_NAME || 'TESTING_AGENT'
driverSpeed = process.env.DRIVER_SPEED || undefined
homeLocation = process.env.HOME_LOCATION || undefined

currentInterval = 1000
socket = null
isConnected = false

class TaxiAgent
    constructor: (@agentName, @socketUrl) ->
        @driver = new TaxiDriver(@agentName, driverSpeed, homeLocation)

    run: =>
        @socket.on 'connect', ->
            console.log "#{agentName} connected."

        @socket.on 'disconnect', ->
            console.log "#{agentName} disconnected."

        @socket.on 'connect_failed', ->
            console.log "#{agentName} connection failed."

        @socket.on 'rideOffer', (rideOffer) ->
            console.log "ride offer received"

    connect: =>
        @socket = io.connect @socketUrl
        this.run()

    updateLocation: (elapsedTime) =>
        currentLocation = @driver.getCurrentLocation(elapsedTime)
        headingTo = @driver.headingTo()

        locationUpdateEvent =
            locationUpdate:
                taxiId: @agentName
                currentLocation:
                    latitude: currentLocation[0]
                    longitude: currentLocation[1]
            headingToLocation:
                latitude: headingTo[0]
                longitude: headingTo[1]
            hasPassenger: @driver.hasPassenger()

        @socket.emit "locationUpdate", JSON.stringfy(locationUpdateEvent)

    stop: =>
        @socket.disconnect()

    test: =>
        if @socket?
            now = new Date()
            @socket.emit "data", now

myAgent = new TaxiAgent(agentName, socketUrl)
myAgent.connect()

setInterval(myAgent.test, 1000)

process.on 'exit', ->
    now = new Date()
    console.log "FINISHED Agent #{agentName} at: #{now}"

