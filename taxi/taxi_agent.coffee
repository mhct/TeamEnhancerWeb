#
# 03/05/2012
# @mariohct
#
# TaxiAgent is the main taxi application, it is responsible for interacting with the driver (Driver) 
# and with the ride auctions
#
socket = require 'socket.io-client'

socketUrl = process.env.SOCKET_URL

console.log socketUrl

client = socket.connect socketUrl
client.on 'connect', ->
    console.log "connected"




