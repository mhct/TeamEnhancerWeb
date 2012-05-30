#
# 12/04/2012
# @mariohct
#
# CoordMWServer
# Initializes all the needed modules of the server part of the middleware
#
# CooS MW needs the following ENV VARS
# DB_USER
# DB_PASS
# DB_URI
# DB_DB_NAME
#
#
# Env vars
#
dbDetails = ->
    details =
        user: process.env.DB_USER || null
        password: process.env.DB_PASS || null
        uri: process.env.DB_URI || null
        dbName: process.env.DB_DB_NAME || null

    details

express = require('express')
app = express.createServer()
store = require('./location_store_mongo').at(dbDetails()) #location store store
#store = require('./location_store_mongo').at(null) #location store store
coordination = require('./events_controller').at(app, store) # coordinatino service


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

app.get '/test', (req, res) ->
    res.sendfile __dirname + "/test/xhr-browser.html"
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
        store.registerTaxi(req.body.taxiRegistration, (data) -> res.send data)


app.post "/a", (req, res) ->
    console.log "A #{req.body.value}"
    #res.send "PORRA"
    myfunc(req.body.value, (data) -> res.send(data) )


myfunc = (value, fn) ->
    console.log "MERDA value=#{value}"
    setTimeout(fn, 10000, "#{value}")
    #fn(value)


console.log "Server ready!"

