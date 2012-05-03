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
    it "should return an empty route if no route is found", (done) ->
        router.getRoute 50.875095, 4.703121, 50.856026, 4.695568, (list) ->
            list.length.should.equal 66
            done()

