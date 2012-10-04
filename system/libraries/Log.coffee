#+--------------------------------------------------------------------+
#| Log.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Expresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the MIT License
#|
#+--------------------------------------------------------------------+
#
# Exspresso Config Class
#
# This class contains functions that enable config files to be managed
#
#
{FCPATH}        = require(process.cwd() + '/index')     # '/var/www/Exspresso/'
{APPPATH}       = require(FCPATH + 'index')            # '/var/www/Exspresso/application/'
{BASEPATH}      = require(FCPATH + 'index')            # '/var/www/Exspresso/system/'
{WEBROOT}       = require(FCPATH + 'index')            # '/var/www/Exspresso/public/'
{EXT}           = require(FCPATH + 'index')            # '.coffee'
{ENVIRONMENT}   = require(FCPATH + 'index')            # 'development'
{is_dir}        = require(FCPATH + 'pal')           # Tells whether the filename is a directory.
{get_config}    = require(BASEPATH + 'core/Common')     # Loads the main config.coffee file.
{Exspresso}     = require(BASEPATH + 'core/Common')     # Core framework library

class CI_Log

  _log_path:    ''
  _threshold:   1
  _date_fmt:    'Y-m-d H:i:s'
  _enabled:     true
  _levels:
    ERROR:        1
    DEBUG:        2
    INFO:         3
    ALL:          4

  constructor: ->

    config = get_config()

    @_log_path = if config.log_path is '' then APPPATH + 'logs/' else config.log_path

    if not is_dir(@_log_path) # or not is_really_writable(@_log_path)
      @_enabled = false

    if not isNaN(config.log_threshold)
      @_threshold = config.log_threshold

    if config.log_date_format isnt ''
      @_date_ftm = config.log_date_format

  ##
  # Write Log File
  #
  # Generally this function will be called using the global log_message() function
  #
  # @param	string	the error level
  # @param	string	the error message
  # @param	bool	whether the error is a native PHP error
  # @return	bool
  ##
  write_log: (level = 'error', msg, js_error = false) ->

    if @_enabled is false then return false

    level = level.toUpperCase()
    if not @_levels[level]? then return false
    if @_levels[level] > @_threshold then return false


    d = new Date()
    filepath = @_log_path + 'log-' + d.toISOString().substr(0,10) + '.log'

    message = level + (if level is 'INFO' then ' ' else '') + ' ' + d.toTimeString() + ' -->' + msg + "\n"

    fs = require('fs')
    fs.appendFileSync filepath, message

# END Log Class
Exspresso.CI_Log = CI_Log
module.exports = CI_Log

# End of file Log.coffee
# Location: ./system/libraries/Log.coffee