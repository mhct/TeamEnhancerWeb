#
# 19/04/2012
# @mariohct
#
# Coordination Controller NOT USING NOW
#
#
# dispatches the request to the right place??
#
store = require('./location_store_mongo') #location store store

coordinate = (rideRequest, fn) ->
    store.findTaxiByLocation rideRequest 
#
# Coordinates a number os taxis
#
# @taxis = list of taxis in JSON format
# @res = callback, expects a Http.Response object
#
simpleAuctionCoordinate = (taxis, res) ->
    console.log "Should coordinate #{taxis.length}"

    res.send "OK"
        

