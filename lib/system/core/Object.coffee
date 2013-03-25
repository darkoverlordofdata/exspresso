#+--------------------------------------------------------------------+
#| Object.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the MIT License
#|
#+--------------------------------------------------------------------+
#
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @see        http://darkoverlordofdata.com
# @since      Version 1.0
#
#

#
# Define - read only attribute
#
# @param  def [Object]  property definition
# @return [Void]
#
Function::define = ($def) ->
  $name = keys($def)[0]
  defineProperty @::, $name, {writeable: false, enumerable: ($name[0] isnt '_'), value: $def[$name]}


#  ------------------------------------------------------------------------
#
#	Class Object
#
class system.core.Object

  #
  # Define a read-only property
  #
  # @param  [Object]  def hash list of property definitions
  # @return	[Void]
  #
  define: ($def) ->

    for $key, $val of $def
      defineProperty @, $key, {writeable: false, enumerable: ($key[0] isnt '_'), value: $val}
    return

  #
  # Async job queue for the controller
  #
  # @param  [Function]  fn  Function to push onto the queue
  # @return	[Void]
  #
  queue: ($fn) ->

    #@define _queue: [] if not @_queue?
    @_queue = [] unless @_queue?

    if $fn then @_queue.push($fn) else @_queue

  #
  # Run the functions in the queue
  #
  # @param  [Function]  next  async callback
  # @return [Void]
  #
  run: ($next) ->

    #@define _queue: [] if not @_queue?
    @_queue = [] unless @_queue?

    $queue = @_queue
    $index = 0

    $done = ($err) =>
      @_queue = []
      $next($err)

    $iterate = ->

      $done(null) if $queue.length is 0
      #
      # call the function at index
      #
      $function = $queue[$index]

      $function ($err) ->
        return $next($err) if $err
        $index += 1
        if $index is $queue.length then $done(null)
        else $iterate()

    $iterate()


# END CLASS Object
module.exports = system.core.Object
# End of file Object.coffee
# Location: .system/core/Object.coffee