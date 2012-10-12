# Cakefile

{exec} = require "child_process"

REPORTER = "nyan"

task "test", "run tests", ->
  exec "NODE_ENV=test
      ./node_modules/.bin/mocha
      --compilers coffee:coffee-script
      --reporter #{REPORTER}
      --require coffee-script
      --require test/test_helper.coffee
    ", (err, output) ->
    console.log output
    console.log err.message if err?

