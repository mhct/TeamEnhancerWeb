#
# 30/04/2012
# @mariohct
#
# Taxi Driver 
#
# Responsible for driving the taxis, following the route defined by the GPS. It can 'say' where his cab currently is. 
#

class Driver
    constructor: (@name, @currentLocation, @destination, @speed) ->

    getLocation: ->
        a = @currentLocation
        a

       
exports.Driver = Driver
