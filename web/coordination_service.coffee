#
# 12/04/2012
# @mariohct
#
# Location Store. Stores the location of devices running the middleware
#
#


#
# Coordinates a number os taxis
#
# @taxis = list of taxis in JSON format
# @res = callback, expects a Http.Response object
simpleAuctionCoordinate = (taxis, res) ->
        console.log "Should coordinate #{taxis.length}"

        res.send "OK"

exports.coordinate = simpleAuctionCoordinate
