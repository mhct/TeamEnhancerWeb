#
# 03/05/2012
# @mariohct
#
# TaxiAgent is the main taxi application, it is responsible for interacting with the driver (Driver) 
# and with the ride auctions
#
io = require 'socket.io-client'

socketUrl = process.env.EVENTS_SERVER || 'http://localhost:3000'
agentName = process.env.AGENT_NAME || 'TESTING_AGENT'

currentInterval = 1000
socket = null

class TaxiAgent
    constructor: (@agentName, @socketUrl) ->
    run: =>
        @socket.on 'connect', ->
            console.log "#{agentName} connected."

        @socket.on 'disconnect', ->
            console.log "#{agentName} disconnected."

        @socket.on 'connect_failed', ->
            console.log "#{agentName} connection failed."

        @socket.on 'rideOffer', (rideOffer) ->
            console.

    connect: =>
        @socket = io.connect @socketUrl
        this.run()

    stop: =>
        @socket.disconnect()


myAgent = new TaxiAgent(agentName, socketUrl)
myAgent.connect()

process.on 'exit', ->
    now = new Date()
    console.log "FINISHED Agent #{agentName} at: #{now}"

