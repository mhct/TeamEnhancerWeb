#
# 12/04/2012
# @mariohct
#
# Location Store. Stores the location of devices running the middleware
#
#
mongo = require 'mongoose'
#connection = mongo.connect 'mongodb://localhost/test'
connection = null

at = (dbName) ->
    connection = if dbName? then mongo.connect "mongodb://localhost/#{dbName}" else mongo.connect "mongodb://localhost/test"
    this

#
# Type definitions
#
RiderRequest = new mongo.Schema
        riderId:
            type:Number
            unique:true
        pickupLocation:[],
        deliveryLocation:[],
        timeToPickup:Number


TaxiLocation = new mongo.Schema
    taxiId:
        type:Number
        unique:true
    currentLocation:[],
    headingToLocation:[],
    hasPassenger:Boolean


RiderRequest.index(
    {pickupLocation:'2d'}
)

TaxiLocation.index(
    {currentLocation:'2d'}
)


TaxiLocationModel = mongo.model('TaxiLocationModel', TaxiLocation)

#
# Returns a reference to the current database connection
#
getConnection = ->
    connection


#
# Finds a device (in this case a TAXI) according to 
# a device (taxi) current location
#
# TODO: receive a function for this search, since the way the search is
# done should be defined at the application layer
#
#findTaxiByLocation = (riderId, rideRequest, res, callback) ->
findTaxiByLocation = (rideRequest, fn) ->
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
                                fn err
                        else
                                console.log "Found #{results.length} entries"
                                fn results
        )


#
# Saves a device's location on the database
#
updateLocation = (locationUpdate, fn) ->
        condition = {taxiId: locationUpdate.taxiId}
        options = {multi:false}
        TaxiLocationModel.update(condition, locationUpdate, options, (err, res) ->
                if err != null
                        console.log "ERROR persisting location update taxiId: #{taxiId}\n#{err}"
                else
                        fn()
        )

#
# Registering device (taxi)
#
registerTaxi = (taxiRegistration, fn) ->
        taxi = new TaxiLocationModel({
                taxiId: taxiRegistration.taxiId,
                currentLocation: [taxiRegistration.currentLocation.latitude, taxiRegistration.currentLocation.longitude],
                headingToLocation: [taxiRegistration.headingToLocation.latitude, taxiRegistration.headingToLocation.longitude],
                hasPassenger: taxiRegistration.hasPassenger
        })
        taxi.save((err, res) ->
                if err?
                        fn "#{err}"
                else
                        fn "OK"
        )


exports.findTaxiByLocation = findTaxiByLocation
exports.updateLocation = updateLocation
exports.registerTaxi = registerTaxi
exports.connection = getConnection
exports.at = at
exports.TaxiLocationModel = TaxiLocationModel #using this only for tests, check how to improve

