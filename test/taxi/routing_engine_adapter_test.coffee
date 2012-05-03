#
# 03/05/2012
# @mariohct
#
# Routing engine adapter test 
#
should = require 'should'
router = require '../../taxi/routing_engine_adapter'

describe "Routing engine", ->
    it "should have routing", (done) ->
        should.exist(router.getRoute)
        done()

    #
    # When using the test/taxiclient/gosmore_output.txt file, this test should work. however it doesn't work with the real engine
    # It can be used to test the little parser for the output of gosmore
    #
    it "should return a route", (done) ->
        console.time("QUERY")
        router.getRoute 50.875095, 4.703121, 50.856026, 4.695568, (list) ->
            console.timeEnd("QUERY")
            list.length.should.equal 66
            list[0].should.eql [50.874991, 4.703215]
            list[list.length-1].should.eql [50.856024, 4.695738]
            done()

