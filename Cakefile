#
# Build script for storynode
# version: 0.1
#
# @mariohct
#
{exec} = require 'child_process'
fs = require 'fs'

task 'buildClient', 'Build/depoly the client libraries', ->
    exec 'coffee --compile --output web/lib/ src-client/', (err, stdout, stderr) ->
        throw err if err?
        console.log stdout + stderr

task 'up', 'Prepare system to go up', ->
    exec '~/opt/redis/src/redis-server', (err, stdout, stderr) ->
	    throw err if err?
	    console.log stdout + stderr
    exec 'coffee web/server.coffee', (err, stdout, stderr) ->
	    throw err if err?
	    console.log stdout + stderr

task 'testall', 'Runs all tests under test/', ->
    console.log "Starting tests suite"

    testDirs = ['test', 'test/taxi']

    for dir in testDirs
        #DIRTY HACK around the JS closure
        ((dir) ->
            fs.readdir dir, (err, files) ->
                runTests(dir, err, files)
        )(dir)

runTests = (path, err, files) ->
    throw err if err?

    for file in files when file.indexOf(".coffee") == (file.length - ".coffee".length)
        exec "mocha --ui bdd --reporter spec #{path}/#{file}  --compilers coffee:coffee-script", (err, stdout, stderr) ->
            console.log stdout + stderr
