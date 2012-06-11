#
# 03/05/2012
# @mariohct
#
# CooS Client API 
#
# Environment VARS
# EVENTS_SERVER = URL, events server url
#
io = require 'socket.io-client'
i = require('util').inspect


#
# Configuration variables
#
#socketUrl = process.env.EVENTS_SERVER || 'http://localhost:3000'

socket = null
isConnected = false

class CoosEventsDispatcher
    constructor: (@deviceId, @socketUrl) ->
        console.log "Loading CoosEventsDispatcher, deviceID; #{@deviceId}"

        updateLocation = () =>
            currentLocation = @locationCallback.getCurrentLocation()
            if not (currentLocation? && currentLocation.length == 2)
                return

            locationUpdateEvent =
                        deviceId:@deviceId
                        currentLocation:
                                latitude: currentLocation[0]
                                longitude: currentLocation[1]
                        payload: @locationCallback.getPayload() #TODO check payload size
            console.log i(locationUpdateEvent)

            @socket.emit "locationUpdate", locationUpdateEvent


    run: =>
        @socket.on 'connect', =>
            console.log "Device: #{@deviceID} connected."

        @socket.on 'disconnect', =>
            console.log "#{@deviceID} disconnected."

        @socket.on 'connect_failed', =>
            console.log "#{@deviceID} connection failed."

        @socket.on 'error', =>
            console.log "Can not connect to CoosEventsServer #{socketUrl}"

        ## deprecated
        @socket.on 'rideAwarded', (rideRequest) =>
            console.log "rideAwarded #{i(rideRequest)}"
            @driver.addRide rideRequest
       

    connect: =>
        #io.set('transports', ['xhr-polling'])
        @socket = io.connect @socketUrl
        this.run()

    registerAsParticipant: (locationCallback, participationCallback) =>
        @locationCallback = locationCallback
        @participationCallback = participationCallback

    stop: =>
        @socket.disconnect()

    test: =>
        if @socket?
            now = new Date()
            @socket.emit "data", now

initialize = (deviceID, socketUrl, tickInterval = 1000) ->
    coosClient = new CoosEventsDispatcher(deviceID, socketUrl)
    coosClient.connect()
    setInterval(coosClient.updateLocation, tickInterval)

    

process.on 'exit', ->
    now = new Date()
    console.log "CoosClient unloaded"


exports.initialize = initialize # Synchronous call


