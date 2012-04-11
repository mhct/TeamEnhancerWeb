mongoose = require('mongoose')
db = mongoose.connect('mongodb://localhost/test')

Schema = mongoose.Schema

Type = new Schema({
        name    :String,
        main_ingredient :String
})

Beer = new Schema({
        brand   :String,
        location     :[],
        #type    :[Type],
        brewery_age     :Number,
        rating  :Number
})

Beer.index({
        location: '2d'
})


BeerModel = mongoose.model('BeerModel', Beer)

sampleData = []
createSampleData = (sampleSize) ->

        populate a for a in sampleSize

        populate = (a) ->
                console.log "Creat"
                sampleData[sampleData.length] = new BeerModel({
                        brand: 'BLA' + sampleSize * Math.random(),
                        location: [50 * Math.random(), 10 * Math.random()],
                        brewery_age: 10,
                        rating: 10
                })
console.log "A"
             
createSampleData(2)

#westmalle = new BeerModel({
#        brand:'Westmalle',
#        location: [50.8790, 4.7015],
#        brewery_age: 86,
#        rating: 10
#})

#westmalle.type.push({
#        name:'Ale',
#        main_ingredient:'Malted Barley'
#})

#westmalle.save((err)->
#        if err
#                console.log err
#        else
#                console.log "UHU saved"
#                findBeerByLocation()
#                #findBeer()
#                #.where('brand', 'Westmalle').run( (err, res) -> console.log "#{err} | #{res}" )
#)

#actually this can return NULL, because this code can execute before the SAVE code ;)

findBeer = -> BeerModel.find({rating: {$gt:5}}, (err, beers) ->
        console.log beer for beer in beers
)

findBeerByLocation = -> BeerModel.find({location: {$near: [50.8619, 4.6874], $maxDistance : 0.009}}, null, {limit:50}, (err, beers) ->
        if err == null
                console.log beer for beer in beers
                if beers.length == 0
                        console.log "Not found"
        else
                console.log "ERR listing #{err}"
)



