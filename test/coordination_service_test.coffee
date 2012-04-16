#
# 16/04/2012
# @mariohct
#
# Coordination service tests 
#
# TODO this is a first test unit test. Actually the deployed service
# should have its own test. Currently I use the 'testLoadsService' flag 
# to alternate between local and deployed services
#
should = require 'should'
io = require 'socket.io-client'
coordService = require '../web/coordination_service'

class Mock
    findTaxiByLocation: (param, fn) ->
        #console.log "Parameters #{param}"
        fn("{'result':'ok'}")
    
    updateLocation: (newLocation, fn) ->
        #console.log 'updateLocation called'
        fn()


storeMock = new Mock
port = null
socketUrl = null

testLoadsService = true

if testLoadsService
    #
    # Test for local testing service
    #
    port = 5000
    socketUrl = "http://0.0.0.0:#{port}"
else
    #
    # Test for cloud service
    #
    port = 3000 #testing the "REAL" server
    socketUrl = "http://0.0.0.0:#{port}"



options =
    transports: ['websockets']
    'force new connection': true

rideRequest = {
  "rideRequest": {
    "clientId": 1,
    "pickupLocation": {
      "latitude": 10,
      "longitude": 12
    },
    "deliveryLocation": {
      "latitude": 90,
      "longitude": 100
    },
    "timeToPickup": 1
  }
}

locationUpdate = {
  "locationUpdate": {
    "taxiId": 1,
    "currentLocation": {
      "latitude": 11,
      "loingitude": 10
    },
    "headingToLocation": {
      "latitude": 20,
      "longitude": 10
    },
    "hasPassenger": false
  }
}


describe 'Coordination Service', ->
    
    if testLoadsService
        before (done) ->
            coordService.at port, storeMock, done

        after (done) ->
            checkGuard()
            coordService.stop done
    
    it 'should inform a user has connected', (done) ->
        client1 = io.connect socketUrl, options

        client1.on 'connect', () ->
            client1.emit 'rideRequest', rideRequest
            done()

        client1.on 'connect_failed', () ->
            should.fail 'Couldn\'t connect'
            done()

        client1.on 'event1', (data) ->
            should.be.ok
            done()
   
    locationUpdatedGuard = false
    it 'should update location', (done) ->
        should.exist 'heee'

        taxi1 = io.connect socketUrl, options

        taxi1.on 'connect', () ->
            taxi1.emit 'locationUpdate', locationUpdate
            

        taxi1.on 'locationUpdated', (data) ->
            obj = JSON.parse data #TODO only compare string, instead of parsing?!
            obj.value.should.equal 'ok'
            locationUpdatedGuard = true
            done()

    checkGuard = () ->
        if not locationUpdatedGuard
            should.fail "Location wasn't updated"



