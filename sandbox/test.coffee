should = require '../../should.js/lib/should'

describe "my little test", (done) ->

    it "should test feql", (done) ->
        console.log ": #{Math.abs(10.1-10.21)}"
        10.1.should.not.feql 10.2, 0.09
        10.1.should.feql 10.21, 0.11
        10.1.should.feql 10.2, 0.1
        10.0011.should.feql 10.0019, 0.001

        done()
