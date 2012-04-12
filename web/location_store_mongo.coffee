#
# 12/04/2012
# @mariohct
#
# Location Store. Stores the location of devices running the middleware
#
#
mongo = require 'mongoose'
connection = mongo.connect 'mongodb://localhost/test'

#
# Type definitions
#
RiderRequest = new mongo.Schema({
        riderId                 :Number,
        pickupLocation          :[],
        deliveryLocation        :[],
        timeToPickup            :Number
})

TaxiLocation = new mongo.Schema({
        taxiId                  :Number,
        currentLocation         :[],
        headingToLocation       :[],
        hasPassenger            :Boolean
})

RiderRequest.index({
        pickupLocation:'2d'
        #deliveryLocation:'2d'
})

TaxiLocation.index({
        currentLocation:'2d'
        #headingToLocation:'2d'
})


TaxiLocationModel = mongo.model('TaxiLocationModel', TaxiLocation)

#
# Finds a device (in this case a TAXI) according to 
# a device (taxi) current location
#
# TODO: receive a function for this search, since the way the search is
# done should be defined at the application layer
#
findTaxiByLocation = (riderId, rideRequest, callback) ->

        MAX_DISTANCE = 0.018 #degree => +- 2 kilometers
        TaxiLocationModel.find({currentLocation: {$near: [rideRequest.pickupLocation.latitude, rideRequest.pickupLocation.longitude], $maxDistance: MAX_DISTANCE}}, null, (err, results) ->
                if err != null
                        console.log "ERROR: #{err}"
                        callback err
                else
                        console.log "Found #{results.length} entries"
                        callback.send results
        )


#
# Saves a device's location on the database
#
updateLocation = (taxiId, locationUpdate, callback) ->
        taxiLocation = new TaxiLocationModel({
                taxiId: taxiId,
                currentLocation: [locationUpdate.currentLocation.latitude, locationUpdate.currentLocation.longitude],
                headingToLocation: [locationUpdate.headingToLocation.latitude, locationUpdate.headingToLocation.longitude],
                hasPassenger: locationUpdate.hasPassenger
        })

        taxiLocation.save((err, res) ->
                if err != null
                        console.log "ERROR persisting location update taxiId: #{taxiId}\n#{err}"
                else
                        callback.send "OK"
        )



exports.findTaxiByLocation = findTaxiByLocation
exports.updateTaxiLocation = updateLocation




