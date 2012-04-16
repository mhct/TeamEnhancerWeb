storeMock = () ->
    console.log "A"

storeMock::findTaxiByLocation = (param, fn) ->
        console.log "Parameters #{param}"
        fn("{'result':'ok'}")



