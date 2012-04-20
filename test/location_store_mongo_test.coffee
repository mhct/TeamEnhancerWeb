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
 "rideRequest": {
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
}

clearDb = (done) ->
    store.TaxiLocationModel.remove(done)


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
        store.findTaxiByLocation rideRequest.rideRequest, (data) ->
            data.should.have.length 1
            done()
     
    it "shouldn't find ANY nearby devices", (done) ->
        rideRequest.rideRequest.pickupLocation.latitude = 10.1

        store.findTaxiByLocation rideRequest.rideRequest, (data) ->
            data.should.have.length 0
            done()
      
