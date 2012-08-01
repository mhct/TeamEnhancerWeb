#
# 30/04/2012
# @mariohct
#
# Taxi Driver Test 
#
# Tests the taxi driver
#
should = require '../../../should.js/lib/should'
Driver = require('../../taxi/taxi_driver').Driver

#
# Maximum allowed floating point error
#
delta = 0.00001

describe "TaxiDriver", ->
    it "should exist", (done) ->
        should.exist(Driver)
        done()

    it "should return its location", (done) ->
        taxiDriver = new Driver()
        should.exist taxiDriver
        done()


    it "should have a name, a home location, destination, and speed", (done) ->
        taxiDriver = new Driver("Joao", 10)

        taxiDriver.getName().should.equal "Joao"
        taxiDriver.getSpeed().should.equal 10
        taxiDriver.getCurrentLocation(0).should.feql [50.874991, 4.703215], delta
        done()

    it "should calculate distances", (done) ->
        taxiDriver = new Driver("Joao", 111)
        taxiDriver.addRoute([[0,0], [3,4], [30,40]])
        taxiDriver.getCurrentLocation(2.5).should.feql [1.5, 2], 0.1
        taxiDriver.getCurrentLocation(2.5).should.feql [3,4], 0.1
        taxiDriver.getCurrentLocation(39).should.feql [30,40], 0.1
        done()

    it "should calculate locations", (done) ->
        taxiDriver = new Driver('ji', 10)
        taxiDriver.addRoute([[0,0], [4,-4]])
        console.log "Distance: #{taxiDriver.getDistanceCurrentRide()}"
        console.log "IT SHOULD: #{taxiDriver.getCurrentLocation(31)}"
        #taxiDriver.getCurrentLocation(101010).should.feql [4, -4], 0.1
        done()

    it "should show locations on a given path (Leuven->Brussels)", (done) ->
        taxiDriver = new Driver("lfllf", 10)
        taxiDriver.addRoute([[50.856035,4.6923], [50.863149,4.680346], [50.869969,4.650811],[50.853211,4.365722]])
        console.log "Distance Current: #{taxiDriver.getDistanceCurrentRide()}"
        for i in [1..21]
            console.log "#{taxiDriver.getCurrentLocation(0.1)}"
        taxiDriver.getCurrentLocation(0).should.feql [50.853211, 4.365722], 0.001
        done()

    it "should calculate the distance from London to Amsterdam", (done) ->
        taxiDriver = new Driver("Derick", 1, [51.519425, -0.124397])

        #
        # checks the distance calculation from London to Amsterdam
        #
        taxiDriver.distanceLondonAmsterdam().should.feql 356.8707624, delta

        done()

    it "should start driving AGAIN, when receives a new route", (done) ->
        taxiDriver = new Driver("ZE", 111)
        taxiDriver.addRoute([[0,0], [3,4], [30,40]])
        taxiDriver.getCurrentLocation(2.5).should.feql [1.5, 2], 0.1
        taxiDriver.addRoute([[25,30], [30, 40]])
        taxiDriver.getCurrentLocation(0).should.eql [25,30]
        done()

    it "should stop driving at the last point in his route", (done) ->
        taxiDriver = new Driver("zica", 111)
        taxiDriver.addRoute([[0,0], [30,40]])
        taxiDriver.getCurrentLocation(60).should.eql [30,40]
        done()


    it "should have a home location", (done) ->
        driver1 = new Driver("jose", 1)
        driver1.getHomeLocation().should.feql [50.874991,4.703215], delta


        taxiDriver = new Driver("mario", 1, [23,23])
        taxiDriver.getHomeLocation().should.eql [23, 23]
        done()

    it "should make bid for rideOffer", (done) ->
        driver = new Driver("paula", 10, [50.874991, 4.703215])
        driver.makeBidFor {pickupLocation:{latitude:50.856024,longitude: 4.695738}}, (bid) ->
            bid.should.feql 0.26, 0.1
            done()

    it "should head to home, if there is no route", (done) ->
        driver = new Driver("papa", 10, [19,10])
        driver.headingTo()[0].should.equal 19
        driver.headingTo()[1].should.equal 10
        done()

    it "should head to last waypoint in route, if there is a route" , (done) ->
        driver = new Driver('papa', 10, [10,11])
        driver.addRoute([[100,100], [80,83]])

        driver.headingTo()[0].should.equal 80
        driver.headingTo()[1].should.equal 83
        done()


    it "should show location while driving, from London to Amsterdam on a straigh line", (done) ->
        driver = new Driver('papa', 50, [51.519425, -0.12439])
        driver.addRoute([[51.519425, -0.12439], [52.375599,4.895039]])

        #for i in [1..6]
        #console.log "KKK: #{driver.getCurrentLocation(1)}"
        #console.log "KKK: #{driver.getCurrentLocation(1)}"
        #console.log "KKK: #{driver.getCurrentLocation(1)}"
        #console.log "KKK: #{driver.getCurrentLocation(1)}"
        #console.log "KKK: #{driver.getCurrentLocation(1)}"
        #console.log "KKK: #{driver.getCurrentLocation(1)}"
        #console.log "KKK: #{driver.getCurrentLocation(1)}"
        #console.log "KKK: #{driver.getCurrentLocation(1)}"
        #driver.getCurrentLocation(1).should.feql [52.375599, 4.895039], 0.1
        done()

    it "should calculate bid for the same location", (done) ->
        driver = new Driver("lala", undefined, undefined)
        driver.makeBidFor({pickupLocation:{latitude:50.874991,longitude:4.70321}}, console.log)
        done()

    it "should calculate a big route", (done) ->
        driver = new Driver('lsls', 10, [50.856024, 4.6923])
        driver.makeBidFor {pickupLocation:{latitude:50.853209, longitude:4.365635}}, (bid) ->
            console.log "time to pick: #{bid}"

        driver.addRide {pickupLocation:{latitude:50.853211, longitude:4.365722},_id:999}, ->
            driver.getDistanceCurrentRide().should.feql 25.58, 0.01
            for i in [1..26]
                driver.getCurrentLocation(0.1)
                #console.log "DISTANCE: #{driver.getDistanceCurrentRide()}"
                #console.log "DrivenDistance: #{driver.getDrivenDistance()}"
                #console.log "location: #{driver.getCurrentLocation(0)}"
            driver.getCurrentLocation(0).should.feql [50.853211, 4.364722], 0.001
            done()
