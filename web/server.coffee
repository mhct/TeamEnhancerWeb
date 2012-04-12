express = require('express')
app = express.createServer()
#admin = require('./admin_server').at(app) #Administrative server
store = require('./location_store_mongo') #location store store
#news = require('./news_server').at(app, store) #load the News event system

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

#App specific part
app.get '/rider', (req, res) ->
    res.sendfile __dirname + '/templates/rider.html'


# MW part
app.post '/rider/:riderId', (req, res) ->
        console.log "RiderId: #{req.params.riderId}"
        store.findTaxiByLocation "#{req.params.riderId}", req.body.rideRequest, res


app.post '/taxi/:taxiId', (req, res) ->
        console.log "Taxi #{req.params.taxiId} updating location"
        store.updateTaxiLocation(req.params.taxiId, req.body.locationUpdate, res)

console.log "Server ready!"

