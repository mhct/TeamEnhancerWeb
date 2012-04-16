#
# 12/04/2012
# @mariohct
#
# CoordMWServer
# Initializes all the needed modules of the server part of the middleware
#
express = require('express')
app = express.createServer()
store = require('./location_store_mongo') #location store store
coordination = require('./coordination_service').at(app, store) # coordinatino service


app.use express.bodyParser()

port = process.env.PORT || 3000;

app.listen port, () ->
  console.log "Listening on #{port}"


#
# Routes
#
app.get '/lib/*', (req, res) ->
  res.sendfile __dirname + req.url

app.get '/css/*', (req, res) ->
  res.sendfile __dirname + req.url

app.get '/', (req, res) ->
	#  res.sendfile __dirname + '/index.html'
    res.send 'OK'

#
#App specific part
#
app.get '/rider', (req, res) ->
    res.sendfile __dirname + '/templates/rider.html'

#
# MW part
#

#
# Requests a taxi nearby the rider location
#
#app.post '/riders/:riderId', (req, res) ->
#        console.log "RiderId: #{req.params.riderId}"
#        store.findTaxiByLocation "#{req.params.riderId}", req.body.rideRequest, res, coordination.coordinate

#
# Updates a Taxi's location
#
#app.post '/taxis/:taxiId', (req, res) ->
#        console.log "Taxi #{req.params.taxiId} updating location"
#        store.updateTaxiLocation(req.params.taxiId, req.body.locationUpdate, res)
        
#
# Registers a new Device (Taxi)
#
app.post '/taxi', (req, res) ->
        console.log "Registering new device"
        store.registerTaxi(req.body.taxiRegistration, res)


console.log "Server ready!"

