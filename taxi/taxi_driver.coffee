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
# ENVIRONMENT_VARS
# HOME_LOCATION = [latitude, longitude]
#
gps = require './routing_engine_adapter'

DISTANCE_CONVERSION_FACTOR = 111 # one radian equals to 111 Km, what also means the Driver speed is given in hours

class Driver
    #
    # Keeps the lengths between consecutive pairs of points in a route
    #
    distancesVector: []
    drivenTime: 0

    constructor: (@name, @speed, homeLocation) ->
        
        if 'undefined' == typeof homeLocation
            @homeLocation = process.env.HOME_LOCATION || [50.874991,4.703215]
        else
            @homeLocation = homeLocation


        @hasPassenger = false

        @distance = (a, b) ->
            deltaX = (a[0] - b[0]) * (a[0] - b[0])
            deltaY = (a[1] - b[1]) * (a[1] - b[1])

            Math.sqrt(deltaX + deltaY) * DISTANCE_CONVERSION_FACTOR

        #
        # Finds the current position (latitude, longitude) in the current Route
        #
        # @return [Float,Float] = [Latitude,Longitude] of current position
        #
        @findsLocation = (totalDistance) ->
            previousPointer = 0
            walkedDistance = 0
          
            if @distancesVector.length == 0
                return @getHomeLocation()

            #
            # Finds the pair of points where a totalDistance is to be found
            #
            for a,i in @distancesVector
                if totalDistance < a.distance
                    #console.log "CALCULAR Distancia entre [#{a.points[0]}, #{a.points[1]}]"
                    #console.log "a partir de: #{walkedDistance}"
                    #console.log "distance: #{valor}"
                    #console.log "currentLengh: #{a.distance}" #TODO renamed a.distance to a.length
                    #console.log "X,Y = #{calculatesCoordinates(valor, walkedDistance, a.distance, a.points[0], a.points[1])}"
                    return calculatesCoordinates((totalDistance-walkedDistance), a.distance, a.points[0], a.points[1])
                previousPointer = i
                walkedDistance += a.distance
            return @distancesVector[@distancesVector.length-1].points[1]

        #
        # Resets the driven time
        #
        @resetDrivenTime = -> @drivenTime = 0

        #
        # Build a map associating Distances to pairs of waypoints, Distance => A, B, where
        # Distance is a float, A, B are cartesian coordinates (waypoints on a cartography map)
        #
        # @param Array of [Float,Float]
        # @return Map[Float, [waypoints]]
        #
        @buildDistancesMap = (waypoints) ->
            distancesMap = []
            for point, i in waypoints[0...(waypoints.length-1)]
                    distancesMap[i] = {distance: @distance(waypoints[i], waypoints[i+1]), points: [waypoints[i], waypoints[i+1]]}
            return distancesMap


    getName: -> @name
    getSpeed: -> @speed
    getCurrentLocation: (elapsedTime) ->
        @drivenTime += elapsedTime
        @findsLocation(drivenDistance(@drivenTime, @speed))

    #
    # Creates a vector of distances between any too pairs of points, and ZEROES the @drivenTime
    # Makes the driver start driving along the route, given by @waypoints
    addRoute: (@waypoints) ->
        @resetDrivenTime()
        @distancesVector = @buildDistancesMap(@waypoints)

    #
    # Makes a bid for driving to a location
    # @param RideOffer
    # @fn callback function called with the Bid value calculated by the driver
    #
    makeBidFor: (rideOffer, fn) ->
        #simple case, I am free and should pick passenger NOW
        if not @hasPassenger
            currentLocation = @getCurrentLocation 0
            console.log "currentLocation: #{currentLocation}"
            gps.getRoute currentLocation[0], currentLocation[1], rideOffer.pickupLocation.latitude, rideOffer.pickupLocation.longitude, (waypoints) =>
                distancesMap = @buildDistancesMap(waypoints)
                totalDistance = 0
                for d in distancesMap
                    totalDistance += d.distance

                timeToPick = totalDistance / @speed
                fn(timeToPick)

    getHomeLocation: ->
        return @homeLocation

#
# Calculates driven distance in terms of time driving and the speed of the driver
#
# @param Float time, time driving
# @param Float speed, speed of the vehicle
drivenDistance = (time, speed) ->
    time * speed

#
# Calculates the coordinates of a point that is along a line connecting @a, to @b, at a distance @displacement from @a
# @currentLength is the length between @a and @b (This is an optimization)
#
# TODO this function could receive only 3 arguments, like @displacement, @a, @b to return the coordinates of the displacement from @a, however 
# it would require the computation of the distance again
#
# @returns the coordinates
#
calculatesCoordinates = (displacement, currentLength, a, b) ->
    #console.log "calculates####\n\tdisplacement: #{displacement}\n\tcurrentLength: #{currentLength}\n\ta:#{a}\n\tb:#{b}"

    lengthPercentage = (displacement) / currentLength
    x = a[0] + (lengthPercentage * Math.abs(b[0] - a[0]))
    y = a[1] + (lengthPercentage * Math.abs(b[1] - a[1]))

    [x,y]

exports.Driver = Driver
