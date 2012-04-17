#
# 16/04/2012
# @mariohct
#
# Testing the spatial's device storage 
#

should = require 'should'
store = require '../web/location_store_mongo'
Db = require('mongodb').Db
Connection = require('mongodb').Connection
Server = require('mongodb').Server

#host = process.env['MONGO_NODE_DRIVER_HOST'] != null ? process.env['MONGO_NODE_DRIVER_HOST'] : 'localhost'
#port = process.env['MONGO_NODE_DRIVER_PORT'] != null ? process.env['MONGO_NODE_DRIVER_PORT'] : Connection.DEFAULT_PORT
host = if process.env['MONG_NODE_DRIVER_HOST']? then process.env['MONGO_NODE_DRIVER_HOST'] else 'localhost'
port = if process.env['MONG_NODE_DRIVER_PORT']? then process.env['MONGO_NODE_DRIVER_PORT'] else Connection.DEFAULT_PORT
#host = 'localhost'

clearDb = ->
    console.log "host: #{host}, port=#{port}"
    db = new Db('test', new Server(host, port, {}), {native_parser:true})

    db.open (err, db) ->
        console.log "A"
        db.dropDatabase (err, result) ->
            db.collection 'taxilocationmodels', (err, collection) ->
                console.log "UHU"
                # Erase all records from the collection, if any
                #collection.remove {}, (err, result) ->
                #    collection.count (err, count) ->
                #        console.log "There are #{count} records in the taxilocationmodels collection"

    


#
# Taxi Data
#
taxi = {
  "taxiId": 4,
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
      "latitude": 11,
      "longitude": 10
    },
    "deliveryLocation": {
      "latitude": 90,
      "longitude": 100
    },
    "timeToPickup": 1
  }
}

describe 'Location Store', ->

    before (done) ->
        clearDb()

    #after (done) ->
        
    
    it 'should persist devices locations', (done) ->
        store.registerTaxi taxi, (data) ->
            'OK'.should.equal data
            done()
    it 'should find near devices', (done) ->
        store.findTaxiByLocation rideRequest.rideRequest, (data) ->
            data.should.have.length 1 #STILL HAVE TO CLEAR THE DB BEFORE THIS TEST
            done()
            
