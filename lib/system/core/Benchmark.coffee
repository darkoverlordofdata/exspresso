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
# This file was ported from CodeIgniter to coffee-script using php2coffee
#
#
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @package    Exspresso
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013 Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license    MIT License
# @link       http://darkoverlordofdata.com
# @since      Version 1.0
#

#
# Exspresso Benchmark Class
#
# This class enables you to mark points and calculate the time difference
# between them.  Memory consumption can also be displayed.
#
#
class system.core.Benchmark

  constructor: ->

    defineProperties @,
      marker : {enumerable: true, writeable: false, value: {}}

  #
  # Set a benchmark marker
  #
  # Multiple calls to this function can be made so that several
  # execution points can be timed
  #
  # @access  public
  # @param  string  $name  name of the marker
  # @return  void
  #
  mark : ($name) ->
    @marker[$name] = new Date()


  #
  # Calculates the time difference between two marked points.
  #
  # If the first parameter is empty this function instead returns the
  # {elapsed_time} pseudo-variable. This permits the full system
  # execution time to be shown in a template. The output class will
  # swap the real value for this variable.
  #
  # @access  public
  # @param  string  a particular marked point
  # @param  string  a particular marked point
  # @param  integer  the number of decimal places
  # @return  mixed
  #
  elapsedTime : ($point1 = '', $point2 = '', $decimals = 4) ->
    if $point1 is ''
      return '{elapsed_time}'


    if not @marker[$point1]?
      return ''


    if not @marker[$point2]?
      @marker[$point2] = new Date() # microtime()

    @marker[$point2] - @marker[$point1]
  
  #
  # Memory Usage
  #
  # This function returns the {memory_usage} pseudo-variable.
  # This permits it to be put it anywhere in a template
  # without the memory being calculated until the end.
  # The output class will swap the real value for this variable.
  #
  # @access  public
  # @return  string
  #
  memoryUsage :  ->
    '{memory_usage}'
    
  
#  END ExspressoBenchmark class
module.exports = system.core.Benchmark
#  End of file Benchmark.php 
#  Location: ./system/core/Benchmark.php 