#
# News Event system
# 10/02/2012
# @mariohct
#
socket = require('socket.io')

at = (app, store) ->
    io = socket.listen app

    # All state should be clearly separated from the operations... trying to follow a functional way of doing stuff
    numberOfUsers = 0

    io.sockets.on('connection', (socket) ->
        numberOfUsers = increaseCounter numberOfUsers

        console.log "Number of Users: #{numberOfUsers}"

        socket.on('disconnect', ->
            numberOfUsers = decreaseCounter numberOfUsers
            console.log "Number of Users: #{numberOfUsers}"
        )

        socket.on('news_event_created', (event, response) ->
            #just a simple test to test errors
            if event.news.description == "undefined"
               response {error: "ERROR: failed to create story due to illegal name"}
            else
                store.save(event)
                response event.news
                socket.broadcast.to(event.storyLine).emit("news_event", event.news)
        )

        socket.on('listening_to_storyline', (event) ->
            console.log "listening to STORYline: " + event.storyLine
            socket.join(event.storyLine)
            store.retrieveNews(event.storyLine, socket)
        )

    )


increaseCounter = (currentCount) -> currentCount + 1
decreaseCounter = (currentCount) -> currentCount - 1

exports.at = at
