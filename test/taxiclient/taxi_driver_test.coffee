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

        10.should.equal taxiDriver.getFromLocation()[0]
        10.should.equal taxiDriver.getFromLocation()[1]
        crazyValue = 999 # TODO just to remember, take care with array objects
        taxiDriver.getFromLocation()[0] = crazyValue
        taxiDriver.getFromLocation()[0].should.equal crazyValue

        taxiDriver.getName().should.equal "Joao"
        taxiDriver.getSpeed().should.equal 10
        done()

    it "should calculate distances", (done) ->
        taxiDriver = new Driver("Joao", [10.0, 10.0], [100.0, 100.0], 10)
        taxiDriver.getCurrentLocation(10).should.equal 25
        taxiDriver.addRoute([[0,0], [3,4], [30,40]])
        valor = 24
        previousPointer = 0
        for a,i in taxiDriver.distanceVector
            if valor < a.distance
                console.log "CALCULAR Distancia entre [#{a.points[0]}, #{a.points[1]}]"
                break
            previousPointer = i

        bla = {"10": 1000}
        console.log "#{dist}, #{i}" for dist,i of bla

        console.log "tamanho: #{bla[0]}"
        done()

