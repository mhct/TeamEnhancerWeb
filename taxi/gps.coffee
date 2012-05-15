#
# 15/05/2012
# @mariohct
#
# GPS 
#
# GPS Device
#
router = require './routing_engine_adapter'

#
# Util functions
#
degreeToRadian = (degree) ->
    degree * Math.PI / 180

#
# Using model from http://derickrethans.nl/spatial-indexes-calculating-distance.html
#
distance = (a, b) ->
    latA = degreeToRadian(a[0])
    latB = degreeToRadian(b[0])
    lonA = degreeToRadian(a[1])
    lonB = degreeToRadian(b[1])

    dLat = latA - latB
    dLon = lonA - lonB
    d = Math.sin(dLat/2) * Math.sin(dLat/2) + Math.cos(latA) * Math.cos(latB) * Math.sin(dLon/2) * Math.sin(dLon/2)
    d = 2 * Math.asin(Math.sqrt(d))
    
    return d * 6371

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
    x = a[0] + (lengthPercentage * (b[0] - a[0]))
    y = a[1] + (lengthPercentage * (b[1] - a[1]))

    [x,y]


class GpsDevice
    #
    # Keeps the lengths between consecutive pairs of points in a route
    #
    distancesVector: []
    drivenTime: 0

    constructor: (@speed, @homeLocation) ->
       
        @resetDrivenTime = -> @drivenTime = 0

        @lengthDistancesMap = (distanceMap) ->
            totalLength = 0.0
            for i in distanceMap
                totalLength += i.distance
            totalLength

        #
        # Build a map associating Distances to pairs of waypoints, Distance => A, B, where
        # Distance is a float, A, B are cartesian coordinates (waypoints on a cartography map)
        #
        # @param Array of [Float,Float]
        # @return Map[Float, [waypoints]]
        #
        @buildDistancesMap = (waypoints) =>
            distancesMap = []
            for point, i in waypoints[0...(waypoints.length-1)]
                    distancesMap[i] =
                        distance: distance(waypoints[i], waypoints[i+1])
                        points: [waypoints[i], waypoints[i+1]]
            return distancesMap

        #
        # Finds the current position (latitude, longitude) in the current Route
        #
        # @return [Float,Float] = [Latitude,Longitude] of current position
        #
        @findsLocation = (totalDistance) =>
            previousPointer = 0
            walkedDistance = 0
          
            if @distancesVector.length == 0
                return @getHomeLocation()

            #
            # Finds the pair of points where a totalDistance is to be found
            #
            for a,i in @distancesVector
                if totalDistance <= walkedDistance
                    #console.log "CALCULAR Distancia entre [#{a.points[0]}, #{a.points[1]}]"
                    #console.log "a partir de: #{walkedDistance}"
                    #console.log "distance: #{valor}"
                    #console.log "currentLengh: #{a.distance}" #TODO renamed a.distance to a.length
                    #console.log "X,Y = #{calculatesCoordinates(valor, walkedDistance, a.distance, a.points[0], a.points[1])}"
                    return calculatesCoordinates((totalDistance-walkedDistance), a.distance, a.points[0], a.points[1])
                previousPointer = i
                walkedDistance += a.distance
            return @distancesVector[@distancesVector.length-1].points[1]


    getSpeed: -> @speed
    getCurrentLocation: (elapsedTime) ->
        @drivenTime += elapsedTime
        @findsLocation(drivenDistance(@drivenTime, @speed))

    #
    # Creates a vector of distances between any too pairs of points, and ZEROES the @drivenTime
    # Makes the driver start driving along the route, given by @waypoints
    # DEPRECATED
    addRoute: (waypoints) ->
        @waypoints = waypoints
        @resetDrivenTime()
        @distancesVector = @buildDistancesMap(waypoints)
        #for distancia in @distancesVector
            #console.log "d: #{distancia.distance}, coordi: #{distancia.points}"

    #legacy... finish removing this
    getRoute: (fromLat, fromLon, toLat, toLon, fn) =>
        router.getRoute fromLat, fromLon, toLat, toLon, (waypoints) =>
            fn(waypoints)

    getCurrentRouteLength: ->
        @lengthDistancesMap(@distancesVector)

    getRouteLength: (fromLat, fromLon, toLat, toLon, fn) =>
        router.getRoute fromLat, fromLon, toLat, toLon, (waypoints) =>
            distancesMap = @buildDistancesMap(waypoints)
            fn(@lengthDistancesMap(distancesMap))

    getDrivenDistance: ->
        drivenDistance(@drivenTime, @speed)

    
    getHomeLocation: ->
        return @homeLocation

    getHeadingTo: ->
        if @distancesVector.length > 0
            @distancesVector[@distancesVector.length-1].points[1]
        else
            @getHomeLocation()

exports.GpsDevice = GpsDevice

