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


    it "should have a name, a from location, destination, and speed", (done) ->
        taxiDriver = new Driver("Joao", 10)

        taxiDriver.getName().should.equal "Joao"
        taxiDriver.getSpeed().should.equal 10
        done()

    it "should calculate distances", (done) ->
        taxiDriver = new Driver("Joao", 1)
        taxiDriver.addRoute([[0,0], [3,4], [30,40]])
        taxiDriver.getCurrentLocation(2.5).should.eql [1.5, 2]
        taxiDriver.getCurrentLocation(2.5).should.eql [3,4]
        done()

    it "should start driving AGAIN, when receives a new route", (done) ->
        taxiDriver = new Driver("ZE", 1)
        taxiDriver.addRoute([[0,0], [3,4], [30,40]])
        taxiDriver.getCurrentLocation(2.5).should.eql [1.5, 2]
        taxiDriver.addRoute([[25,30], [30, 40]])
        taxiDriver.getCurrentLocation(0).should.eql [25,30]
        done()

    it "should stop driving at the last point in his route", (done) ->
        taxiDriver = new Driver("zica", 1)
        taxiDriver.addRoute([[0,0], [30,40]])
        taxiDriver.getCurrentLocation(60).should.eql [30,40]
        done()


