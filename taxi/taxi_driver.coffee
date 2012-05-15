#
# 30/04/2012
# @mariohct
#
# Taxi Driver 
#
# Responsible for driving a taxi, following the route defined by the GPS. It can 'say' where his cab currently is.
# Currently it only drives at a constant speed.
# FIXME change the distanceVector data structure, acumulate the total distance as key, instead of the segment length. 
#
#
gps = require './gps'

class Driver
    drivenTime: 0

    constructor: (@name, speed, homeLocation) ->
        if 'undefined' == typeof speed
            @speed = 10
        else
            @speed = speed

        if 'undefined' == typeof homeLocation
            @homeLocation = [50.874991,4.703215]
        else
            @homeLocation = homeLocation


        @hasPassenger = false

        @gps = new gps.GpsDevice(@speed, @homeLocation)

        #
        # Resets the driven time
        #
        @resetDrivenTime = -> @drivenTime = 0
       
    getName: -> @name
    getSpeed: -> @speed
    getCurrentLocation: (elapsedTime) ->
        @gps.getCurrentLocation(elapsedTime)

    #
    # Creates a vector of distances between any too pairs of points, and ZEROES the @drivenTime
    # Makes the driver start driving along the route, given by @waypoints
    #
    addRoute: (waypoints) ->
        @gps.addRoute(waypoints)
        @resetDrivenTime()

    getDistanceCurrentRide: ->
        @gps.getCurrentRouteLength()

    getDrivenDistance: ->
        @gps.getDrivenDistance()

    distanceLondonAmsterdam: ->
        #@distance([51.519425, -0.12439], [52.375599,4.895039])
        9999999
    #
    # Makes a bid for driving to a location
    # @param RideOffer
    # @fn callback function called with the Bid value calculated by the driver
    #
    makeBidFor: (rideOffer, fn) ->
        #simple case, I am free and should pick passenger NOW
        if not @hasPassenger
            currentLocation = @gps.getCurrentLocation 0
            #console.log "currentLocation: #{currentLocation}"
            @gps.getRouteLength currentLocation[0], currentLocation[1], rideOffer.pickupLocation.latitude, rideOffer.pickupLocation.longitude, (length) =>
                timeToPick = length / @speed
                fn(timeToPick)

    #legacy
    addRide: (rideRequest, fn) ->
        currentLocation = @gps.getCurrentLocation 0
        #console.log "A: currentLocation: #{currentLocation[0]}, #{currentLocation[1]}"
        @gps.getRoute currentLocation[0], currentLocation[1], rideRequest.pickupLocation.latitude, rideRequest.pickupLocation.longitude, (waypoints) =>
            #console.log "B"
            if waypoints.length > 0
                #console.log "waypoints.length #{waypoints.length}"
                #console.log "waypoints #{waypoints}"
                #for i in [1..30]
                #    console.log "#{waypoints[i*10]}"

                @hasPassenger = true
                @setRideRequestId(rideRequest._id)
                @gps.addRoute waypoints
                if fn? then fn('ok')
            else
                console.log "NO ROUTE TO DESTINATION"
                if fn? then fn('nok')

    finishRide: ->
        @gps.addRoute([])
        @hasPassenger = false
        @rideRequestId = 0

    hasFinishedRide: ->
        currentLocation = @gps.getCurrentLocation 0
        heading = @gps.getHeadingTo()
        if currentLocation[0] == heading[0] && currentLocation[1] == heading[1] && @getRideRequestId() > 0
            return true
        else
            return false

    getRideRequestId: ->
        @rideRequestId

    setRideRequestId: (id) ->
        @rideRequestId = id

    getHomeLocation: ->
        return @gps.getHomeLocation()

    headingTo: ->
        @gps.getHeadingTo()

    hasPassenger111: ->
        if @hasPassenger
            true
        else
            false

exports.Driver = Driver
