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
        taxiId                  :{type: Number, unique:true}
        currentLocation         :[],
        headingToLocation       :[],
        hasPassenger            :Boolean
})

RiderRequest.index({
        pickupLocation:'2d'
        #deliveryLocation:'2d'
})

TaxiLocation.index({
        currentLocation:'2d',
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
findTaxiByLocation = (riderId, rideRequest, res, callback) ->

        MAX_DISTANCE = 0.018 #degree => +- 2 kilometers
        TaxiLocationModel.find(
                {
                        currentLocation: {$near: [rideRequest.pickupLocation.latitude, rideRequest.pickupLocation.longitude], $maxDistance: MAX_DISTANCE},
                        hasPassenger: false
                },
                null,
                (err, results) ->
                        if err != null
                                console.log "ERROR: #{err}"
                                res.send err
                        else
                                console.log "Found #{results.length} entries"
                                callback results, res
        )


#
# Saves a device's location on the database
#
updateLocation = (taxiId, locationUpdate, callback) ->
        condition = {taxiId: taxiId}
        options = {multi:false}
        TaxiLocationModel.update(condition, locationUpdate, options, (err, res) ->
                if err != null
                        console.log "ERROR persisting location update taxiId: #{taxiId}\n#{err}"
                else
                        callback.send "#{res} OK"
        )

#
# Registering device (taxi)
#
registerTaxi = (taxiRegistration, callback) ->
        taxi = new TaxiLocationModel({
                taxiId: taxiRegistration.taxiId,
                currentLocation: [taxiRegistration.currentLocation.latitude, taxiRegistration.currentLocation.longitude],
                headingToLocation: [taxiRegistration.headingToLocation.latitude, taxiRegistration.headingToLocation.longitude],
                hasPassenger: taxiRegistration.hasPassenger
        })

        taxi.save((err, res) ->
                if err != null
                        console.log "ERROR persisting location update taxiId: #{err}"
                        callback.send "NOK"
                else
                        callback.send "#{res} OK"
        )


exports.findTaxiByLocation = findTaxiByLocation
exports.updateTaxiLocation = updateLocation
exports.registerTaxi = registerTaxi




