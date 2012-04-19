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

