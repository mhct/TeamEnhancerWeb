#
# 30/04/2012
# @mariohct
#
# Taxi Driver Test 
#
# Tests the taxi driver
#
should = require 'should'
Driver = require('../../taxiclient/taxi_driver').Driver

describe "TaxiDriver behaviour", ->
    it "should exist", (done) ->
        should.exist(Driver)
        done()

    it "should return its location", (done) ->
        taxiDriver = new Driver()
        should.exist taxiDriver
        done()


    it "should have a name, a from location, destination, and speed", (done) ->
        taxiDriver = new Driver("Joao", [10.0, 10.0], [100.0, 100.0], 10)

        10.should.equal taxiDriver.getLocation()[0]
        10.should.equal taxiDriver.getLocation()[1]
        taxiDriver.getLocation()[0] = 9999
        10.should.equal taxiDriver.getLocation()[0]

        done()
        

