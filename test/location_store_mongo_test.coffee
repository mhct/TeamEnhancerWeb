#
# 16/04/2012
# @mariohct
#
# Testing the spatial's device storage 
#

should = require 'should'
store = require('../web/location_store_mongo').at(':bla1111')

    
#
# Taxi Data
#
taxi = {
  "taxiId": 6,
  "currentLocation": {
      "latitude": 11,
      "longitude": 10
  },
  "headingToLocation": {
      "latitude": 20,
      "longitude": 10
  },
  "hasPassenger": false
}

rideRequest = {
    "clientId": 1,
    "pickupLocation": {
      "latitude": 11.000005,
      "longitude": 10.000006
    },
    "deliveryLocation": {
      "latitude": 90,
      "longitude": 100
    },
    "timeToPickup": 1
}

clearDb = (done) ->
    store.TaxiLocationModel.remove ->
        store.RideBid.remove ->
            store.RideRequest.remove ->
                done()
    


describe 'Location Store', ->

    before (done) ->
        clearDb(done)

    it 'should persist devices locations', (done) ->
        store.registerTaxi taxi, (data) ->
            'OK'.should.equal data
            store.registerTaxi taxi, (data) ->
                'OK'.should.not.equal data
                done()
    
    it 'should find nearby devices', (done) ->
        store.findTaxiByLocation rideRequest, (data) ->
            data.should.have.length 1
            done()
     
    it "shouldn't find ANY nearby devices", (done) ->
        rideRequest.pickupLocation.latitude = 10.1

        store.findTaxiByLocation rideRequest, (data) ->
            data.should.have.length 0
            done()

    it "should update location of a device", (done) ->
        store.updateLocation taxi, ->
            store.TaxiLocationModel.find({taxiId: taxi.taxiId}, (err, results) ->
                if err?
                    console.log "din't update taxis: #{err}"
                else
                    results.should.have.length 1
                    results[0].currentLocation[0].should.equal taxi.currentLocation.latitude
                    results[0].currentLocation[1].should.equal taxi.currentLocation.longitude
                done()
                )

    it "should persist and collect a bid", (done) ->
        bid =
            rideRequestId: 1
            taxiId: 1
            estimatedTimeToPickup: 120

        store.makeBid bid, (data) ->
            data.should.equal "ok"

            rideRequestId = 1

            store.collectBids {rideRequestId:rideRequestId}, (data) ->
                should.exist(data)
                data.should.have.length 1
                done()

    it "should persist a RideRequest", (done) ->
        store.makeRequest rideRequest, (data) ->
            should.exist(data._id)
            done()


