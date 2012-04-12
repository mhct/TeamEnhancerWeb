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

class MyTestModel
        constructor: (@name, @age) ->

sampleData = []
createSampleData = (sampleSize) ->
        for i in [0...sampleSize]
                #sampleData[i] = new MyTestModel("Mario" + Math.random(), Math.random())
                console.log "sample[#{i}]"
                sampleData[i] = new BeerModel({
                        brand: 'BLA' + sampleSize * Math.random(),
                        location: [50 * Math.random(), 10 * Math.random()],
                        brewery_age: 10,
                        rating: 10
                })

persistSampleData = ->
        for key, value of sampleData
                value.save()

benchmarkMongo = ->
        #
        # Benchmarking creation of plain object arrays
        #
        console.log "creating data start"

        sampleSizes = [10000]

        for i in sampleSizes
                console.time "s#{i}"
                createSampleData(i)
                console.timeEnd "s#{i}"



        #
        # Timming persisting data
        #
        console.log "sample data: #{sampleData[0]}"
        #sampleData[0].save()

        for i in sampleSizes
                console.log "persisting #{i}"
                console.time "p#{i}"
                persistSampleData()
                console.timeEnd "p#{i}"


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

findBeerByLocation = -> BeerModel.find({location: {$near: [50.8619, 4.6874], $maxDistance : 10}}, null, (err, beers) ->
        if err == null
                console.log beer for beer in beers
                if beers.length == 0
                        console.log "Not found"
                else
                        console.log "Found #{beers.length} beers"
        else
                console.log "ERR listing #{err}"
)


#findBeerByLocation()
console.time "find"
BeerModel.find({}, (err, res) ->
        if err == null
                console.log "Found #{res.length} results "
        else
                console.log "ERR: #{err}"
)
console.timeEnd "find"

console.log "end"
