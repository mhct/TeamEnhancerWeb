app = require('express').createServer()
#admin = require('./admin_server').at(app) #Administrative server
store = require('./news_store') # database store
#news = require('./news_server').at(app, store) #load the News event system

app.listen 3000


app.get '/lib/*', (req, res) ->
  res.sendfile __dirname + req.url

app.get '/css/*', (req, res) ->
  res.sendfile __dirname + req.url

app.get '/', (req, res) ->
  res.sendfile __dirname + '/index.html'

app.get '/reader/:storyLineID', (req, res) ->
    res.render(__dirname + '/templates/reader.jade', {
                layout: false,
                serverURL: 'http://134.58.46.145:3000',
                storyLineID: req.params.storyLineID})

app.get '/taxireporter/:storyLineID', (req, res) ->
    res.render(__dirname + '/templates/reporter.jade', {
                layout: false,
                serverURL: 'http://134.58.46.145:3000',
                storyLineID: req.params.storyLineID})

console.log "Server ready!"

