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

    makeBid: (bid, fn) ->
        fn()

    makeRequest: (request, fn) ->
        fn {_id:1}

    collectBids: (id, fn) ->
        fn [{taxiId: 1, estimatedTimeToPickup: 310}, {taxiId:2, estimatedTimeToPickup: 30}]

storeMock = new Mock
port = null
socketUrl = null

testLoadsService = false

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
    #"transports": ['xhr-polling']
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
      "longitude": 1
    },
    "headingToLocation": {
      "latitude": 1,
      "longitude": 1
    },
    "hasPassenger": false
}


describe 'Events Controller', ->
    
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
    contractNetComplete = false

    it 'should send a rideResponse when clients sends rideRequest', (done) ->
        client1 = io.connect socketUrl, options

        client1.on 'connect', ->
            client1.emit 'rideRequest', rideRequest
            client1.on 'rideResponse', (data) ->
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


    it "should offer a rideRequest to a taxi, receive Bid, and acknowledge the bid", (done) ->
        client11 = io.connect socketUrl, options # should create another instance of the middleware Socket.io
        taxi99 = io.connect socketUrl, options

        c = 0
        taxi99.emit 'locationUpdate', {taxiId:1} ## CHECK TESTs states.. they are influencing each other.. what CANT happen

        taxi99.on 'locationUpdated', ->
            #console.log "A"
            client11.emit 'rideRequest', rideRequest
            taxi99.on 'rideOffer', (data) ->
                ##notice that this callback keeps in the context of other tests
                #so, it is called twice during the execution of the test suit
                #
                c++
                #console.log "C: #{c}"
                bid =
                        rideRequestId: 1
                        taxiId: 1
                        estimatedTimeToPickup: 100

                taxi99.emit 'rideBid', bid
                    
                taxi99.on 'rideBidReceived', (data) ->
                    console.log "rideBidReceived"
                    JSON.parse(data).acknowledgement.should.equal 'ok'
                    if c == 1 #TODO CRAZY DIRTY hack, why do I need this hack? TODO remember
                        done()

    it "should have the following events rideRequest,receiveBid, ackBid,awardBid", (done) ->
        client1 = io.connect socketUrl, options
        taxi1 = io.connect socketUrl, options


        taxi1.emit 'locationUpdate', {taxiId:2}
        taxi1.on 'locationUpdated', ->
            client1.emit 'rideRequest', rideRequest
            taxi1.on 'rideOffer', (data) ->
                    bid =
                        rideRequestId: 1
                        taxiId: 2
                        estimatedTimeToPickup: 10

                    taxi1.emit 'rideBid', bid
                    async.parallel([
                        (fn) ->
                            taxi1.on 'rideBidReceived', (data) ->
                                JSON.parse(data).acknowledgement.should.equal 'ok'
                                fn()
                        ,
                        (fn) ->
                            taxi1.on 'rideAwarded', (data) ->
                                data.estimatedTimeToPickup.should.equal 10
                                fn()
                        ,
                        (fn) ->
                            client1.on 'rideResponse', (data) ->
                                #console.log "CLIENT RECEIVED"
                                fn()
                    ], ->
                        contractNetComplete = true
                        #console.log "KKK"
                        done()

                       
                    )
                        #TODO
                        #create a FSM with all events I am interested, for every entry in the FSM I can add a function to emit an event.

  
    #it 'should update location', (done) ->
    #    taxi1 = io.connect socketUrl, options
        
    #    taxi1.on 'connect', () ->
    #        taxi1.emit 'locationUpdate', locationUpdate
        
    #    taxi1.on 'locationUpdated', (data) ->
    #        obj = JSON.parse data #TODO only compare string, instead of parsing?!
    #        obj.acknowledgement.should.equal 'ok'
    #        locationUpdatedGuard = true
    #        done()

    checkGuard = (done) ->
        if locationUpdatedGuard and event1ReceivedGuard and taxisReceivedOffer and contractNetComplete
            true.should.be.ok
        else
            should.fail "At least ONE guard wasn't satisfied"
        done()



