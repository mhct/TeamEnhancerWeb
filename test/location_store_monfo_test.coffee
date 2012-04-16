#
# 16/04/2012
# @mariohct
#
# Testing the spatial's device storage 
#

should = require 'should'
store = require '../web/location_store_mongo'


#
# Taxi Data
#
taxi = {
  "taxiId": 1,
  "currentLocation": {
      "latitude": 11,
      "loingitude": 10
  },
  "headingToLocation": {
      "latitude": 20,
      "longitude": 10
  },
  "hasPassenger": false
}

describe 'Location Store', ->
    
    it 'should persist devices locations', ->
        store.registerTaxi taxi, (data) ->
            console.log "AAA"

            
