#
# 30/04/2012
# @mariohct
#
# Taxi Driver 
#
# Responsible for driving a taxi, following the route defined by the GPS. It can 'say' where his cab currently is.
# Currently it only drives at a constant speed.
#
class Driver
    #
    # Keeps the lengths between consecutive pairs of points in a route
    #
    distancesVector: []
    drivenTime: 0

    constructor: (@name, @speed) ->
        @distance = (a, b) ->
            deltaX = (a[0] - b[0]) * (a[0] - b[0])
            deltaY = (a[1] - b[1]) * (a[1] - b[1])

            Math.sqrt(deltaX + deltaY)

        #
        # Find the location in the Route
        #
        @findsLocation = (totalDistance) ->
            previousPointer = 0
            walkedDistance = 0
            
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

    getName: -> @name
    getSpeed: -> @speed
    getCurrentLocation: (elapsedTime) ->
        @drivenTime += elapsedTime
        @findsLocation(distance(@drivenTime, @speed))

    #
    # Creates a vector of distances between any too pairs of points, and ZEROES the @drivenTime
    # Makes the driver start driving along the route, given by @waypoints
    addRoute: (@waypoints) ->
        @resetDrivenTime()
        for point, i in @waypoints[0...(@waypoints.length-1)]
            @distancesVector[i] = {distance: @distance(@waypoints[i], @waypoints[i+1]), points: [@waypoints[i], @waypoints[i+1]]}



#
# Calculates the distance
#
distance = (time, speed) ->
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
