#
# Build script for storynode
# version: 0.1
#
# @mariohct
#
{exec} = require 'child_process'

task 'buildClient', 'Build/depoly the client libraries', ->
    exec 'coffee --compile --output web/lib/ src-client/', (err, stdout, stderr) ->
        throw err if err
        console.log stdout + stderr

task 'up', 'Prepare system to go up', ->
    exec '~/opt/redis/src/redis-server', (err, stdout, stderr) ->
	    throw err if err
	    console.log stdout + stderr
    exec 'coffee web/server.coffee', (err, stdout, stderr) ->
	    throw err if err
	    console.log stdout + stderr

