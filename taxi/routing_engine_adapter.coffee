#
# 03/05/2012
# @mariohct
#
# Adapter to the Routing engine Gosmore
#
exec = require('child_process').exec


#
# Calculates the route between two locations
# Float @flat from latitude
# Float @flon from longitude
# Float @tlat to latitude
# Float @tlon to longitute
# Function @fn, callback with @list, @list is an array of coordinates
#          
# @returns nothing
#
getRoute = (flat, flon, tlat, tlon, fn) ->
    queryString = "flat=#{flat}&flon=#{flon}&tlat=#{tlat}&tlon=#{tlon}&fast=0&v=motorcar"
    languageEnv = "en_US"
    environmentVars =
        QUERY_STRING: queryString
        LC_NUMERIC: languageEnv

    routingService = 'cat test/taxi/gosmore_output.txt'
    #routingService = 'echo valor=$QUERY_STRING - $LC_NUMERIC'
    #routingService = '/home/u0061821/gosmore.sh'

    #TODO, get path from the configuration
    child = exec routingService, {env: environmentVars},
        (error, stdout, stderr) ->
            if error?
                throw new Error "gosmore error: #{error}"
                fn([])
            else
                fn(parseOutput(stdout))

parseOutput = (output) ->
    rawRoutingData = output.split("\n")
    route = []
    for routingLine in rawRoutingData[2..rawRoutingData.length-2]
        temp = routingLine.split ","
        route[route.length] = [parseFloat(temp[0]), parseFloat(temp[1])]
exports.getRoute = getRoute
