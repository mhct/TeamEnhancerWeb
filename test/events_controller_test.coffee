#
# 16/04/2012
# @mariohct
#
# Events Controller Test 
#
# Tests the events controller
#
# Currently I use the 'testLoadsService' flag 
# to alternate between local and deployed services
#
should = require 'should'
io = require 'socket.io-client'
eventsController = require '../web/events_controller'
async = require 'async'

class Mock
    findTaxiByLocation: (param, fn) ->
        #console.log "Parameters #{param}"
        fn('[{"taxiId":1}, {"taxiId":2}]')
    
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

locationUpdate = {
    "taxiId": 1,
    "currentLocation": {
      "latitude": 1,
      "loingitude": 1
    },
    "headingToLocation": {
      "latitude": 1,
      "longitude": 1
    },
    "hasPassenger": false
}


describe 'Coordination Service', ->
    
    if testLoadsService
        before (done) ->
            eventsController.at port, storeMock, done

        after (done) ->
            eventsController.stop()
            checkGuard(done)
            #done()
    
    #
    # Event occurrence guards
    # TODO create Finite State Machine FSM for testing the event order, etc.
    #
    event1ReceivedGuard = false
    locationUpdatedGuard = false
    taxisReceivedOffer = false

    it 'should inform a user has connected', (done) ->
        client1 = io.connect socketUrl, options

        client1.on 'connect', ->
            client1.emit 'rideRequest', rideRequest
            client1.on 'RideResponse', (data) ->
                event1ReceivedGuard = true
                done()
        
        client1.on 'connect_failed', () ->
            should.fail 'Couldn\'t connect'
            done()


    it 'should offer rideOffer to 2 taxis (see the Mock above)', (done) ->
        client1 = io.connect socketUrl, options
        taxi1 = io.connect socketUrl, options
        taxi2 = io.connect socketUrl, options

        async.parallel([
            (fn) ->
                taxi1.emit('locationUpdate', {taxiId:1})
                fn()
            ,
            (fn) ->
                taxi2.emit('locationUpdate', {taxiId:2})
                fn()
        ], ->
            async.parallel([
                (fn) -> taxi1.on('locationUpdated', -> fn() )
                ,
                (fn) -> taxi2.on('locationUpdated', -> fn() )
            ], ->
                client1.emit 'rideRequest', rideRequest
                async.parallel([
                    (fn) -> taxi1.on('rideOffer', -> fn() )
                    ,
                    (fn) -> taxi2.on('rideOffer', -> fn() )
                ], ->
                    taxisReceivedOffer = true
                    done()
                )
            )
        )


            #client1.on 'event1', (data) ->
        #    event1ReceivedGuard = true
        #    done()
   
    it 'should update location', (done) ->
        taxi1 = io.connect socketUrl, options
        
        taxi1.on 'connect', () ->
            taxi1.emit 'locationUpdate', locationUpdate
        
        taxi1.on 'locationUpdated', (data) ->
            obj = JSON.parse data #TODO only compare string, instead of parsing?!
            obj.acknowledgement.should.equal 'ok'
            locationUpdatedGuard = true
            done()

    checkGuard = (done) ->
        if locationUpdatedGuard and event1ReceivedGuard and taxisReceivedOffer
            true.should.be.ok
        else
            should.fail "At least ONE guard wasn't satisfied"
        done()



