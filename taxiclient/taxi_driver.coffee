#
# 30/04/2012
# @mariohct
#
# Taxi Driver 
#
# Responsible for driving the taxis, following the route defined by the GPS. It can 'say' where his cab currently is. 
#
_ = require 'underscore'

class Driver
    distanceVector: []

    constructor: (@name, @fromLocation, @destination, @speed) ->
        @calculateDistanceMetric = (a, b) ->
            deltaX = (a[0] - b[0]) * (a[0] - b[0])
            deltaY = (a[1] - b[1]) * (a[1] - b[1])

            deltaX + deltaY

    getFromLocation: -> @fromLocation
    getDestination: -> @destination
    getName: -> @name
    getSpeed: -> @speed
    getCurrentLocation: (elapsedTime) ->
        @calculateDistanceMetric([0,0], [3,4])
    addRoute: (@waypoints) ->
        for point, i in @waypoints[0...(@waypoints.length-1)]
            console.log "point: #{point}"
            @distanceVector[i] = {distance: @calculateDistanceMetric(@waypoints[i], @waypoints[i+1]), points: [@waypoints[i], @waypoints[i+1]]}

exports.Driver = Driver
