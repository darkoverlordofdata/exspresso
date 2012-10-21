#+--------------------------------------------------------------------+
#  Common.coffee
#+--------------------------------------------------------------------+
#  Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#
#  This file is a part of Exspresso
#
#  Exspresso is free software you can copy, modify, and distribute
#  it under the terms of the MIT License
#
#+--------------------------------------------------------------------+
#
# This file was ported from php to coffee-script using php2coffee v6.6.6
#
#

{APPPATH, BASEPATH, ENVIRONMENT, EXT, FCPATH, SYSDIR, WEBROOT} = require(process.cwd() + '/index')
{array_merge, chmod, class_exists, count, defined, die, error_reporting, fclose, file_exists, fopen, header, ini_get, is_array, is_dir, is_file, is_numeric, is_writable, log_exception, md5, mt_rand, php_sapi_name, preg_replace, rtrim, show_php_error, strtolower, substr, unlink, version_compare, write_log}	= require(FCPATH + 'lib')

#
# CodeIgniter
#
# An open source application development framework for PHP 5.1.6 or newer
#
# @package		CodeIgniter
# @author		ExpressionEngine Dev Team
# @copyright	Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license		http://codeigniter.com/user_guide/license.html
# @link		http://codeigniter.com
# @since		Version 1.0
# @filesource
#

#  ------------------------------------------------------------------------

#
# Common Functions
#
# Loads the base classes and executes the request.
#
# @package		CodeIgniter
# @subpackage	codeigniter
# @category	Common Functions
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/
#


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

#  ------------------------------------------------------------------------

#
# class_exists
#
# Returns true if the class has been defined
#
# @access public
# @return	boolean
#
exports.class_exists = ($class_name) ->

  Exspresso[$class_name]?

#  ------------------------------------------------------------------------

#
# register_class
#
# Regsiter a class
#
# @access public
# @param string class name
# @param object the class
# @return	void
#
exports.register_class = ($classname, $class) ->

  Exspresso[$classname] = $class
  return
#  ------------------------------------------------------------------------

#
# get_instance
#
# Returns the super object
#
# @access public
# @return	object
#
exports.get_instance = () -> require(BASEPATH + 'core/Exspresso')

#  ------------------------------------------------------------------------

#
# CI_<Object> factory
#
# Load the class if not already in cache.
# Returns a new instance of the class.
#
# @access	public
# @param	string	the class name being requested
# @param	string	the directory where the class should be found
# @param	string	the class name prefix
# @return	object
#
exports.load_new = load_new = ($class, $directory = 'libraries', $prefix = 'CI_') ->

  #  Does the class exist?  If so, we're done...
  if Exspresso[$class]?
    return new Exspresso[$class]()

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
    die 'Unable to locate the specified class: ' + $class + EXT

  return new Exspresso[$name]()

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
    die 'Unable to locate the specified class: ' + $class + EXT


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
    die 'The configuration file does not exist.'


  #  Does the $config array exist in the file?
  if not $config?  #or  not is_array($config)
    die 'Your config file does not appear to be formatted correctly.'


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
exports.show_error = show_error = ($err, $status_code = 500) ->
  console.log $err
  #return

  _error = load_class('Exceptions', 'core')
  _error.show_error($err, '5xx', $status_code)

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


#  ------------------------------------------------------------------------

#
# Set HTTP Status Header
#
# @access	public
# @param	int		the status code
# @param	string
# @return	void
#
exports.set_status_header = set_status_header = ($code = 200, $text = '') ->
  $stati =
    200:'OK',
    201:'Created',
    202:'Accepted',
    203:'Non-Authoritative Information',
    204:'No Content',
    205:'Reset Content',
    206:'Partial Content',

    300:'Multiple Choices',
    301:'Moved Permanently',
    302:'Found',
    304:'Not Modified',
    305:'Use Proxy',
    307:'Temporary Redirect',

    400:'Bad Request',
    401:'Unauthorized',
    403:'Forbidden',
    404:'Not Found',
    405:'Method Not Allowed',
    406:'Not Acceptable',
    407:'Proxy Authentication Required',
    408:'Request Timeout',
    409:'Conflict',
    410:'Gone',
    411:'Length Required',
    412:'Precondition Failed',
    413:'Request Entity Too Large',
    414:'Request-URI Too Long',
    415:'Unsupported Media Type',
    416:'Requested Range Not Satisfiable',
    417:'Expectation Failed',

    500:'Internal Server Error',
    501:'Not Implemented',
    502:'Bad Gateway',
    503:'Service Unavailable',
    504:'Gateway Timeout',
    505:'HTTP Version Not Supported'


  if $code is '' or  not is_numeric($code)
    show_error('Status codes must be numeric', 500)


  if $stati[$code]?  and $text is ''
    $text = $stati[$code]


  if $text is ''
    show_error('No status text available.  Please check your status code number or supply your own message text.', 500)

  $text


#  --------------------------------------------------------------------

#
# Exception Handler
#
# This is the custom exception handler that is declaired at the top
# of Codeigniter.php.  The main reason we use this is to permit
# PHP errors to be logged in our own log files since the user may
# not have access to server logs. Since this function
# effectively intercepts PHP errors, however, we also need
# to display errors based on the current error_reporting level.
# We do that with the use of a PHP error template.
#
# @access	private
# @return	void
#
exports._exception_handler = _exception_handler = ($severity, $message, $filepath, $line) ->

  $_error = load_class('Exceptions', 'core')

  #$_error.show_php_error($severity, $message, $filepath, $line)


  #  Should we log the error?  No?  We're done...
  if config_item('log_threshold') is 0
    return


  $_error.log_exception($severity, $message, $filepath, $line)


# End of file Common.coffee
# Location: ./system/core/Common.coffee