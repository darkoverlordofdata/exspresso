#+--------------------------------------------------------------------+
# Cakefile
#+--------------------------------------------------------------------+
# Copyright DarkOverlordOfData (c) 2012 - 2013
#+--------------------------------------------------------------------+
#
#  This file is a part of Exspresso
#
#  Exspresso is free software you can copy, modify, and distribute
#  it under the terms of the MIT License
#
#+--------------------------------------------------------------------+
#
# Cakefile
#

{exec} = require "child_process"



#
# Build the preview - requires valac
#
task "build:preview", "build preview", ->

  console.log 'Building bin/preview...'
  exec "valac --pkg gtk+-2.0 --pkg webkit-1.0 --thread bin/preview.vala --output=bin/preview", (err, output) ->
    console.log output
    if err?
      console.log err.message
    else
      console.log 'Ok.'

