#
# 18/04/2012
# @mariohct
#
# Testing mongoose and indexes 
#

should = require 'should'
mongoose = require 'mongoose'
mongoose.connect 'mongodb://localhost/test123'

TestSchema = new mongoose.Schema
        someId:
            type:Number
            unique:true
        name:String
        location:[]

TestSchema.index
    location:'2d'



TestModel = mongoose.model('TestModel', TestSchema)


persist = (data, fn) ->
        testModel = new TestModel data
        
        testModel.save((err, res) ->
                if err?
                        fn "#{err}"
                else
                        fn "OK"
        )


describe 'Location Store', ->

    #before (done) ->
    #    clearDb(done)

    #after (done) ->
        

    TestModel.remove(-> console.log "REMOVED?")

    it 'should persist data', (done) ->
        testData = {someId: 3, name: 'Martin'}

        persist testData, (response) ->
            console.log "Reply from first persistence: #{response}"

            persist testData, (response) ->
            
                console.log "Reply from Second call: #{response}"
                'OK'.should.equal response
                done()
    
     #it 'should find nearby devices', (done) ->
     #   store.findTaxiByLocation rideRequest.rideRequest, (data) ->
     #       data.should.have.length 1 #STILL HAVE TO CLEAR THE DB BEFORE THIS TEST
     #       done()
            
