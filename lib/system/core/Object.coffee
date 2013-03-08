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
# @package    Exspresso
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @license    MIT License
# @link       http://darkoverlordofdata.com
# @since      Version 1.0
#
#

#  ------------------------------------------------------------------------
#
#	Class Object
#
class system.core.Object

  #
  # Define a read-only property
  #
  # @access	public
  # @param	array
  # @return	array
  #
  define: ($def) ->

    for $key, $val of $def
      defineProperty @, $key, {writeable: false, enumerable: ($key[0] isnt '_'), value: $val}
    return

  #
  # Async job queue for the controller
  #
  # @access	public
  # @param	function
  # @return	array
  #
  queue: ($fn) ->

    @define _queue: [] if not @_queue?

    if $fn then @_queue.push($fn) else @_queue

  #
  # Run the functions in the queue
  #
  # @access	public
  # @param  array
  # @param	function
  # @return	void
  #
  run: ($next) ->

    @define _queue: [] if not @_queue?

    $queue = @_queue
    $inputdex = 0
    $iterate = ->

      $next (null) if $queue.length is 0
      #
      # call the function at index
      #
      $function = $queue[$inputdex]
      $function ($err) ->
        return $next($err) if $err
        $inputdex += 1
        if $inputdex is $queue.length then $next null
        else $iterate()

    $iterate()


# END CLASS Object
module.exports = system.core.Object
# End of file Object.coffee
# Location: .system/core/Object.coffee