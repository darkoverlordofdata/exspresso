#+--------------------------------------------------------------------+
#| Log.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012 - 2013
#+--------------------------------------------------------------------+
#|
#| This file is a part of Expresso
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
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @see        http://darkoverlordofdata.com
# @since      Version 1.0
#

class system.core.Log

  fs              = require('fs')   # Standard POSIX file i/o

  is_dir = ($path) -> fs.existsSync($path) and fs.statSync($path).isDirectory()


  _enabled        : true            # Use logging?
  _log_path       : ''              # Path to the log file
  _threshold      : 1               # Current threshhold level
  _levels:                          # Threshold Levels:
    ERROR         : 1               #   log only errors
    DEBUG         : 2               #   log errors and debug entries
    INFO          : 3               #   log everything

  #
  # Load configuration
  #
  constructor: ->

    $config = get_config()

    @_log_path = $config.log_path or APPPATH + 'logs/'

    if not is_dir(@_log_path) or not is_really_writable(@_log_path)
      @_enabled = false

    @_threshold = parseInt($config.log_threshold, 10)

  #
  # Write Log File
  #
  # Generally this function will be called using the global log_message() function
  #
  # @param  [String]  level the error level
  # @param  [String]  msg the error message
  # @return	[Boolean] always returns true
  #
  write: ($level = 'error', $msg) ->


    $level = $level.toUpperCase()
    if not @_levels[$level]? then return false
    if @_levels[$level] >= @_threshold then return false

    $d = new Date
    $message = $level + (if $level is 'INFO' then ' ' else '') + ' ' + $d.toISOString() + ' -->' + $msg
    console.log $message

    if @_enabled
      try

        $filepath = @_log_path + 'log-' + $d.toISOString().substr(0,10) + '.log'
        fs.appendFileSync $filepath, $message+"\n"

      catch $err
        @_enabled = false

    return true


# END Log Class
module.exports = system.core.Log

# End of file Log.coffee
# Location: .system/core/Log.coffee