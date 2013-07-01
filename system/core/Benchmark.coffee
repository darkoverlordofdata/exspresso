#+--------------------------------------------------------------------+
#  Benchmark.coffee
#+--------------------------------------------------------------------+
#  Copyright DarkOverlordOfData (c) 2012 - 2013
#+--------------------------------------------------------------------+
#
#  This file is a part of Exspresso
#
#  Exspresso is free software you can copy, modify, and distribute
#  it under the terms of the MIT License
#
#+--------------------------------------------------------------------+

#
# Exspresso Benchmark Class
#
# This class enables you to mark points and calculate the time difference
# between them.
#
#
module.exports = class system.core.Benchmark

  #
  # @property [Object] Hash list of time markers
  #
  marker: null

  #
  # Initialize the marker array
  #
  constructor: ->

    defineProperties @,
      marker : {enumerable: true, writeable: false, value: {}}


  #
  # Set a benchmark
  #
  # Mark the time at name
  #
  # @param  [String]  name  name of the marker
  # @return [Void]
  #
  mark : ($name) ->
    @marker[$name] = new Date()


  #
  # Elapsed Time
  #
  # Returns the time elapsed between two markers
  #
  # @param  [String]  point1   a particular marked point
  # @param  [String]  point2   a particular marked point
  # @return [Mixed]
  #
  elapsedTime : ($point1, $point2) ->

    return 0 if not @marker[$point1]?

    @marker[$point2] = new Date() if not @marker[$point2]?
    @marker[$point2] - @marker[$point1]
  
