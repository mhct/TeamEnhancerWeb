at = (app) ->
    app.use(require('express').bodyParser())

    app.get '/admin', (req, res) ->
        res.render(__dirname + '/templates/admin.jade', {
                    layout: false})

    storylineID = 0

    # admin
    app.post '/storylines', (req, res) ->
        storyline = req.body
        storyline.id = storylineID++
        if(storyline.title == "server")
            res.send( {title: "server side error"} , 400)
        else res.send storyline
        # throw new Error({title: "server side error"})
        # console.log JSON.stringify req

exports.at = at
