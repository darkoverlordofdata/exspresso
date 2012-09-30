#+--------------------------------------------------------------------+
#| Common.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Expresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the GNU General Public License Version 3
#|
#+--------------------------------------------------------------------+
#
#	Common - Main application
#
{APPPATH, BASEPATH, ENVIRONMENT, EXT, FCPATH, WEBROOT} = require(process.cwd() + '/index')
{array_merge, file_exists, is_dir, ltrim, realpath, rtrim, trim, ucfirst} = require(FCPATH + '/helper')
{Exspresso, config_item, get_config, get_instance, is_loaded, load_class, log_message} = require(BASEPATH + 'core/Common')

#
# core/config cache
#
# @var array
#
_config       = []
#
# core/config item cache
#
# @var object
#
_config_item  = {}
#
# class instance cache
#
# @var object
#
_classes      = {}
#
# class names hash
#
# @var object
#
_is_loaded    = {}
#
# CI_Log instance
#
# @var object
#
_log          = null
#
# CI_Exception instance
#
# @var object
#
_error        = null
#
# framework class defenition registry
#
# @var object
#
exports.Exspresso = Exspresso    = {}

exports.get_instance = get_instance = () ->
  return Exspresso.CI_Controller.get_instance()

#  ------------------------------------------------------------------------

#
# Tests for file writability
#
# is_writable() returns TRUE on Windows servers when you really can't write to
# the file, based on the read-only attribute.  is_writable() is also unreliable
# on Unix servers if safe_mode is on.
#
# @access	private
# @return	void
#
exports.is_really_writable = ($file) ->
  #  If we're on a Unix server with safe_mode off we call is_writable
  ###
  if DIRECTORY_SEPARATOR is '/' and ini_get("safe_mode") is FALSE
    return is_writable($file)


  #  For windows servers and safe_mode "on" installations we'll actually
  #  write a file then read it.  Bah...
  if is_dir($file)
    $file = rtrim($file, '/') + '/' + md5(mt_rand(1, 100) + mt_rand(1, 100))

    if ($fp = fopen($file, FOPEN_WRITE_CREATE)) is FALSE
      return FALSE


    fclose($fp)
    chmod($file, DIR_WRITE_MODE)
    unlink($file)
    return TRUE

  else if not is_file($file) or ($fp = fopen($file, FOPEN_WRITE_CREATE)) is FALSE
    return FALSE


  fclose($fp)
  return TRUE
  ###

#  ------------------------------------------------------------------------

#
# Class registry
#
# This function acts as a singleton.  If the requested class does not
# exist it is instantiated and set to a static variable.  If it has
# previously been instantiated the variable is returned.
#
# @access	public
# @param	string	the class name being requested
# @param	string	the directory where the class should be found
# @param	string	the class name prefix
# @return	object
#
exports.load_class = load_class = ($class, $directory = 'libraries', $prefix = 'CI_') ->

  #  Does the class exist?  If so, we're done...
  if _classes[$class]?
    return _classes[$class]

  $name = false

  #  Look for the class first in the native system/libraries folder
  #  then in the local application/libraries folder
  for $path in [BASEPATH, APPPATH]
    if file_exists($path + $directory + '/' + $class + EXT)
      $name = $prefix + $class

      if not Exspresso[$name]?
        Exspresso[$name] = require($path + $directory + '/' + $class + EXT)

      break

  #  Is the request a class extension?  If so we load it too
  if file_exists(APPPATH + $directory + '/' + config_item('subclass_prefix') + $class + EXT)
    $name = config_item('subclass_prefix') + $class

    if not Exspresso[$name]?
      Exspresso[$name] = require(APPPATH + $directory + '/' + config_item('subclass_prefix') + $class + EXT)

  #  Did we find the class?
  if not Exspresso[$name]?
    console.log 'Unable to locate the specified class: ' + $class + EXT
    process.exit 1


  #  Keep track of what we just loaded
  is_loaded($class)

  _classes[$class] = new Exspresso[$name]()
  return _classes[$class]


#  --------------------------------------------------------------------
#
# Keeps track of which libraries have been loaded.  This function is
# called by the load_class() function above
#
# @access	public
# @return	array
#
exports.is_loaded = is_loaded = ($class = '') ->

  if $class isnt ''
    _is_loaded[$class.toLowerCase()] = $class

  return _is_loaded


#  ------------------------------------------------------------------------

#  ------------------------------------------------------------------------

#
# Loads the main config.coffee file
#
# This function lets us grab the config file even if the Config class
# hasn't been instantiated yet
#
# @access	private
# @return	array
#
exports.get_config = get_config = ($replace = {}) ->

  if _config[0]?
    return _config[0]

  #  Fetch the config file
  $found = false
  $config = {}

  $check_locations = ['config', ENVIRONMENT + '/config' ]
  for $file in $check_locations

    $file_path = APPPATH + 'config/' + $file + EXT
    if file_exists($file_path)
      $found = true
      $config = array_merge($config, require($file_path))


  if not $found
    console.log 'The config/config file does not exist.'
    process.exit 1


  #  Does the $config array exist in the file?
  if not $config?  #or  not is_array($config)
    console.log 'Your config file does not appear to be formatted correctly.'
    process.exit 1


  #  Are any values being dynamically replaced?
  for $val, $key of $replace
    if $config[$key]?
      $config[$key] = $val

  return _config[0] = $config

#  ------------------------------------------------------------------------

#
# Returns the specified config item
#
# @access	public
# @return	mixed
#
exports.config_item = config_item = ($item) ->

  if not _config_item[$item]?
    $config = get_config()

    if not $config[$item]?
      return false

    _config_item[$item] = $config[$item]


  return _config_item[$item]

#  ------------------------------------------------------------------------

#
# Error Handler
#
# This function lets us invoke the exception class and
# display errors using the standard error template located
# in application/errors/errors.php
# This function will send the error page directly to the
# browser and exit.
#
# @access	public
# @return	void
#
exports.show_error = show_error = ($message, $status_code = 500, $heading = 'An Error Was Encountered') ->
  _error = load_class('Exceptions', 'core')
  require('./Exspresso').res.send  _error.show_error($heading, $message, 'error_general', $status_code)


#  ------------------------------------------------------------------------

#
# 404 Page Handler
#
# This function is similar to the show_error() function above
# However, instead of the standard error template it displays
# 404 errors.
#
# @access	public
# @return	void
#
exports.show_404 = show_404 = ($page = '', $log_error = TRUE) ->
  _error = load_class('Exceptions', 'core')
  _error.show_404($page, $log_error)


#  ------------------------------------------------------------------------

#
# Error Logging Interface
#
# We use this as a simple mechanism to access the logging
# class and send messages to be logged.
#
# @access	public
# @return	void
#
exports.log_message = log_message = ($level = 'error', $message, $js_error = false) ->

  if config_item('log_threshold') is 0
    return

  _log = load_class('Log')
  _log.write_log($level, $message, $js_error)


# End of file Common.coffee
# Location: ./Common.coffee