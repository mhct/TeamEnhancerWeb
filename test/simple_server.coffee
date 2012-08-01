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
express = require('express')
app = express.createServer()

app.use express.bodyParser()

port = process.env.PORT || 3000;

app.listen port, () ->
  console.log "Listening on #{port}"


#
# Routes
#
app.post '/', (req, res) ->
	#  res.sendfile __dirname + '/index.html'
    console.log "RECEBEU"
    console.log req
    res.send 'OK'

console.log "Server ready"

