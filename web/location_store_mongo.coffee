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
RideRequestSchema = new mongo.Schema
        riderId:
            type:Number
            unique:true
        pickupLocation:[]
        deliveryLocation:[]
        timeToPickup:Number

#getLocation = (location) ->
#    obj = {}
#    obj['latitude'] = 10
#    obj['longitude'] = 1000
#    return obj

#
# RideBid
#
RideBidSchema = new mongo.Schema
    rideRequestId:
        type: Number
        index: true
    taxiId: Number
    estimatedTimeToPickup: Number


TaxiLocation = new mongo.Schema
    taxiId:
        type:Number
        unique:true
    currentLocation:
        type:[]
        #get:getLocation
    headingToLocation:[],
    hasPassenger:Boolean


RideRequestSchema.index(
    {pickupLocation:'2d'}
)

TaxiLocation.index(
    {currentLocation:'2d'}
)


TaxiLocationModel = mongo.model('TaxiLocationModel', TaxiLocation)
RideBid = mongo.model('RideBid', RideBidSchema)
RideRequest = mongo.model('RideRequest', RideRequestSchema)

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
                                #console.log "ERROR: #{err}"
                                fn err
                        else
                                #console.log "Found #{results.length} entries"
                                fn results
        )


#
# Saves a device's location on the database
#
updateLocation = (locationUpdate, fn) ->
        condition = {taxiId: locationUpdate.taxiId}
        update =
            taxiId: locationUpdate.taxiId
            currentLocation: [locationUpdate.currentLocation.latitude, locationUpdate.currentLocation.longitude]
            headingToLocation: [locationUpdate.headingToLocation.latitude, locationUpdate.headingToLocation.longitude]
            hasPassenger: locationUpdate.hasPassenger

        options = {multi:false}
        TaxiLocationModel.update(condition, update, options, (err, res) ->
                if err?
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

#
# MakeBid
#  
# Registers a bid by a taxi
#
makeBid = (bid, fn) ->
    rideBid = new RideBid(
        rideRequestId: bid.rideRequestId
        taxiId: bid.taxiId
        estimatedTimeToPickup: bid.estimatedTimeToPickup
    )

    rideBid.save( (err, res) ->
        if err?
            console.log "EER"
            fn "#{err}"
        else
            console.log "OK"
            fn "ok"
    )

#
# Collect Bids for a given request
#
# @rideRequestId ID of the ride request (or Id of the auction request)
#
collectBids = (rideRequest, fn) ->
    RideBid.find {rideRequestId: rideRequest.rideRequestId}, (err, bidsFound) ->
        if err?
            fn err
        else
            fn bidsFound

#
# Make request
#
# Client makes a request (this should be in the application part, in a real app)
#
makeRequest = (rideRequest, fn) ->
    request = new RideRequest(
        riderId: rideRequest.riderId
        pickupLocation:[rideRequest.pickupLocation.latitude, rideRequest.pickupLocation.longitude]
        deliveryLocation:[rideRequest.deliveryLocation.latitude, rideRequest.deliveryLocation.longitude]
        timeToPickup:rideRequest.timeToPickup
    )

    request.save (err, res) ->
        if err?
            console.log "ERR #{err}"
            fn err
        else
            console.log "_ID: #{res._id}"
            fn {_id:res._id}


exports.makeRequest = makeRequest
exports.findTaxiByLocation = findTaxiByLocation
exports.updateLocation = updateLocation
exports.registerTaxi = registerTaxi
exports.connection = getConnection
exports.at = at
exports.TaxiLocationModel = TaxiLocationModel #using this only for tests, check how to improve
exports.RideBid = RideBid #dirty hack for testing... check way to improve
exports.RideRequest = RideRequest
exports.makeBid = makeBid
exports.collectBids = collectBids
