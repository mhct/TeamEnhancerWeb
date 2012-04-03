#
# NewsStore is responsible for storing news events, storylines, and abstracting from the
# persistence layer
#
# 15/02/2012
# @mariohct
#
redis = require('redis')
client = redis.createClient()
async = require('async')

#TODO check how to guarantee a particular method from module is always called?!
createStore = () ->
    console.log "News Store created"

    client.on('error', (err) ->
        console.log "Error: " + err
    )
#
# TODO add broadcast function as callback and response() to backbone as well.
#
save = (event) ->
    #if client.exists("storyline:#{event.storyLine}") == 0
    client.incr("news:counter", (err, newsId) ->
        console.log "Saving news: #{event}"
        client.hset("news:#{newsId}", "description", event.news.description)
        client.set("news:#{newsId}:date", event.news.date)
        client.hmset("news:#{newsId}", "description", event.news.description, "date", event.news.date, (err, resp) ->
            if err == null
                client.lpush("storyline:#{event.storyLine}", newsId)
            else
                console.log "Error inserting NEWS#{newsId}: #{err}"
        )

        event.news.id = newsId
    ) # atomic operation

#
# Retrieve storylines stored in the redis db. Notice that the format of news:id is fixed as
# a hash with fields description, date
#
retrieveNews = (storyLineId, socket) ->
    client.lrange("storyline:#{storyLineId}", 0, -1, (err, newsIds) ->
        #console.log "#{newsIds}"
        a = []
        createCalls = (key, i) ->
            a[i] = (callback) ->
                client.hmget(key, "description", "date", (err, resp) ->
                    callback(null, respNewsToJSON(resp))
                )
        createCalls("news:#{key}", i) for key, i in newsIds
        async.parallel(a, (err, results)->
          #console.log "initial_news_events: #{results}"
            if results instanceof Array
                console.log "ARRAY: #{results} $$$"
                socket.emit("initial_news_events", results)
            else
                console.log "NAO"
        )
    )

#
# Transforms an array of values into a fixed JSON, assumes
# description = resp[0]
# date = resp[1]
#  ignores any other array elements
respNewsToJSON = (resp) ->
   msg = {description: resp[0], date: resp[1]}
   # msg = "{description: '#{resp[0]}', date: '#{resp[1]}'}"


exports.createStore = createStore
exports.save = save
exports.retrieveNews = retrieveNews
