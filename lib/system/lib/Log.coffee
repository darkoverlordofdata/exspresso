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
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license    MIT License
# @link       http://darkoverlordofdata.com
# @since      Version 1.0
#

class system.lib.Log

  fs              = require('fs')                         # Standard POSIX file i/o
  util            = require('util')

  _log_path       : ''
  _threshold      : 1
  _date_fmt       : 'Y-m-d H:i:s'
  _enabled        : true
  _levels:
    ERROR         : 1
    DEBUG         : 2
    INFO          : 3
    ALL           : 4

  constructor: ->

    $config = get_config()

    @_log_path = $config.log_path or APPPATH + 'logs/'

    if not is_dir(@_log_path) # or not is_really_writable(@_log_path)
      @_enabled = false

    if not isNaN($config.log_threshold)
      @_threshold = $config.log_threshold

    if $config.log_date_format isnt ''
      @_date_ftm = $config.log_date_format

  ##
  # Write Log File
  #
  # Generally this function will be called using the global log_message() function
  #
  # @param	string	the error level
  # @param	string	the error message
  # @param	bool	whether the error is a native error
  # @return	bool
  ##
  writeLog: ($level = 'error', $msg) ->


    $level = $level.toUpperCase()
    if not @_levels[$level]? then return false
    if @_levels[$level] > @_threshold then return false

    $d = new Date()
    $message = $level + (if $level is 'INFO' then ' ' else '') + ' ' + $d.toISOString() + ' -->' + $msg + "\n"
    console.log $message

    if @_enabled
      $filepath = @_log_path + 'log-' + $d.toISOString().substr(0,10) + '.log'
      fs.appendFileSync $filepath, $message


# END Log Class
module.exports = system.lib.Log

# End of file Log.coffee
# Location: .system/lib/Log.coffee