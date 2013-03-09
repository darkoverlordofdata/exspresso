#+--------------------------------------------------------------------+
#| Cakefile
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of not-php
#|
#| Not-php is free software; you can copy, modify, and distribute
#| it under the terms of the GNU General Public License Version 3
#|
#+--------------------------------------------------------------------+
#
# Cakefile
#

{exec} = require "child_process"


#  --------------------------------------------------------------------

#
# Run all tests
#
#
task "test", "run tests", ->
  REPORTER = "nyan"
  exec "NODE_ENV=test
      ./node_modules/.bin/mocha
      --compilers coffee:coffee-script
      --reporter #{REPORTER}
      --require coffee-script
      --require test/test_helper.coffee
    ", (err, output) ->
    console.log output
    console.log err.message if err?


#  --------------------------------------------------------------------

#
# Build the documentation
#
#
task "doc", "build documentation", ->
  exec "codo --quiet --output-dir ./lib/assets/doc ./lib/application - ./lib/modules - ./lib/system", (err, output) ->
    console.log output
    console.log err.message if err?

