express = require('express')
app = express.createServer()
#admin = require('./admin_server').at(app) #Administrative server
#store = require('./news_store') # database store
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

#app.get '/reader/:storyLineID', (req, res) ->
#    res.render(__dirname + '/templates/reader.jade', {
#                layout: false,
#                serverURL: 'http://134.58.46.145:3000',
#                storyLineID: req.params.storyLineID})

#app.get '/taxireporter/:storyLineID', (req, res) ->
#    res.render(__dirname + '/templates/reporter.jade', {
#                layout: false,
#                serverURL: 'http://134.58.46.145:3000',
#                storyLineID: req.params.storyLineID})

app.get '/rider', (req, res) ->
    res.sendfile __dirname + '/templates/rider.html'

app.post '/rider/:riderId', (req, res) ->
	console.log "RiderId: #{req.params.riderId} lat: #{req.body.latitude}, lon: #{req.body.longitude}"
	res.send 'OK'
	

console.log "Server ready!"

