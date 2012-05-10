#
# 30/04/2012
# @mariohct
#
# Taxi Driver Test 
#
# Tests the taxi driver
#
should = require 'should'
Driver = require('../../taxi/taxi_driver').Driver

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
        taxiDriver.getCurrentLocation(0).should.eql [50.874991, 4.703215]
        done()

    it "should calculate distances", (done) ->
        taxiDriver = new Driver("Joao", 111)
        taxiDriver.addRoute([[0,0], [3,4], [30,40]])
        taxiDriver.getCurrentLocation(2.5).should.eql [1.5, 2]
        taxiDriver.getCurrentLocation(2.5).should.eql [3,4]
        done()

    it "should calculate the distance from London to Amsterdam", (done) ->
        taxiDriver = new Driver("Derick", 1, [51.519425, -0.124397])

        #TODO improve should way of handling floats.
        taxiDriver.london().should.equal 356.8707624
        true.should.equalFloat()

        done()

    it "should start driving AGAIN, when receives a new route", (done) ->
        taxiDriver = new Driver("ZE", 111)
        taxiDriver.addRoute([[0,0], [3,4], [30,40]])
        taxiDriver.getCurrentLocation(2.5).should.eql [1.5, 2]
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
        driver1.getHomeLocation().should.eql [50.874991,4.703215]


        taxiDriver = new Driver("mario", 1, [23,23])
        taxiDriver.getHomeLocation().should.eql [23, 23]
        done()

    it "should make bid for rideOffer", (done) ->
        driver = new Driver("paula", 10, [50.874991, 4.703215])
        driver.makeBidFor {pickupLocation:{latitude:50.856024,longitude: 4.695738}}, (bid) ->
            bid.should.equal 0.26
            done()

    it "should head to somewhere", (done) ->
        driver = new Driver("papa", 10, [10,10])
        driver.headingTo()[0].should.equal 10
        driver.headingTo()[1].should.equal 10
        done()




