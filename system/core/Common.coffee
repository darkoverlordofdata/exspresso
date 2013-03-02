#+--------------------------------------------------------------------+
#  Common.coffee
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
# @package		Exspresso
# @author		  darkoverlordofdata
# @copyright	Copyright (c) 2012 - 2013, Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license		MIT License
# @link		    http://darkoverlordofdata.com
# @since		  Version 1.0
#

#  ------------------------------------------------------------------------

#
# Common Functions
#
format            = require('util').format
path              = require('path')
fs                = require('fs')

fopen             = fs.openSync
fclose            = fs.closeSync
unlink            = fs.unlinkSync
chmod             = fs.chmodSync

_config           = []    # [0] is reference to config array
_config_item      = {}    # config item cache
_classes          = {}    # class cache
_is_loaded        = {}    # class loaded flag
_log              = null  # loging object
_error            = null  # error display object

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
exports.is_really_writable = is_really_writable = ($file) ->


  #  We'll actually write a file then read it.  Bah...
  if is_dir($file)
    $file = rtrim($file, '/') + '/' + md5(''+mt_rand(1, 100) + mt_rand(1, 100))

    if ($fp = fopen($file, FOPEN_WRITE_CREATE)) is false
      return false

    fclose($fp)
    chmod($file, DIR_WRITE_MODE)
    unlink($file)
    return true

  else if not is_file($file) or ($fp = fopen($file, FOPEN_WRITE_CREATE)) is false
    return false

  fclose($fp)
  return true



#
# Exspresso Object Creation
#
# Returns a new instance of the class.
#
# @access	public
# @param	string	the class name being requested
# @param	string	the directory where the class should be found
# @param	string	the class name prefix
# @param  object  list of params to pass to the constructor
# @return	object
#
exports.load_new = load_new = ($class, $directory = 'libraries', $prefix = 'Exspresso_', $0, $1, $2, $3, $4, $5, $6, $7, $8, $9) ->

  if typeof $prefix isnt 'string'
    [$prefix, $0, $1, $2, $3, $4, $5, $6, $7, $8, $9] = ['Exspresso_', $prefix, $0, $1, $2, $3, $4, $5, $6, $7, $8]

  #$prefix = 'Exspresso_'
  #  Does the class exist?  If so, we're done...
  if class_exists($prefix+$class)
    #return create_mixin($controller, global[$prefix+$class], $controller)
    return new global[$prefix+$class]($0, $1, $2, $3, $4, $5, $6, $7, $8, $9)

  $name = false

  #  Look for the class first in the native system/libraries folder
  #  then in the local application/libraries folder
  for $path in [BASEPATH, APPPATH]
    if file_exists($path + $directory + '/' + $class + EXT)
      $name = $prefix + $class

      if not class_exists($name)
        require $path + $directory + '/' + $class + EXT

      break

  #  Is the request a class extension?  If so we load it too
  if file_exists(APPPATH + $directory + '/' + config_item('subclass_prefix') + $class + EXT)
    $name = config_item('subclass_prefix') + $class

    if not class_exists($name)
      require APPPATH + $directory + '/' + config_item('subclass_prefix') + $class + EXT

  #  Did we find the class?
  if not class_exists($name)
    die 'Unable to locate the specified class: ' + $class + EXT

  #create_mixin($controller, global[$name], $controller)
  return new global[$name]($0, $1, $2, $3, $4, $5, $6, $7, $8, $9)

#
# Exspresso Mixin Creation
#
# Returns a new instance of the class.
# Create as mixin with a controller object.
#
# @access	public
# @param	string	the class name being requested
# @param	string	the directory where the class should be found
# @param	string	the class name prefix
# @param  object  Exspresso_Controller object
# @return	object
#
exports.load_mixin = load_mixin = ($class, $directory = 'libraries', $prefix = 'Exspresso_', $controller) ->

  if typeof $prefix isnt 'string'
    [$prefix, $controller] = ['Exspresso_', $prefix]

  #  Does the class exist?  If so, we're done...
  if class_exists($prefix+$class)
    return create_mixin($controller, global[$prefix+$class], $controller)

  $name = false

  #  Look for the class first in the native system/libraries folder
  #  then in the local application/libraries folder
  for $path in [BASEPATH, APPPATH]
    if file_exists($path + $directory + '/' + $class + EXT)
      $name = $prefix + $class

      if not class_exists($name)
        require $path + $directory + '/' + $class + EXT

      break

  #  Is the request a class extension?  If so we load it too
  if file_exists(APPPATH + $directory + '/' + config_item('subclass_prefix') + $class + EXT)
    $name = config_item('subclass_prefix') + $class

    if not class_exists($name)
      require APPPATH + $directory + '/' + config_item('subclass_prefix') + $class + EXT

  #  Did we find the class?
  if not class_exists($name)
    die 'Unable to locate the specified class: ' + $class + EXT

  create_mixin($controller, global[$name], $controller)

#
# Exspresso Class registry
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
exports.load_class = load_class = ($class, $directory = 'libraries', $prefix = 'Exspresso_', $config = {}) ->

  if typeof $prefix isnt 'string' then [$prefix, $config] = ['Exspresso_', $prefix]

  $core = $class.split('_')[0] # strip subclass suffix from driver name

  #  Does the class exist?  If so, we're done...
  if _classes[$core]?
    return _classes[$core]

  $name = false

  #  Look for the class first in the native system/libraries folder
  #  then in the local application/libraries folder
  for $path in [BASEPATH, APPPATH]
    if file_exists($path + $directory + '/' + $class + EXT)
      $name = $prefix + $class
      if not class_exists($name)
        require $path + $directory + '/' + $class + EXT

      break

  #  Is the request a class extension?  If so we load it too
  if file_exists(APPPATH + $directory + '/' + config_item('subclass_prefix') + $class + EXT)
    $name = config_item('subclass_prefix') + $class

    if not class_exists($name)
      require APPPATH + $directory + '/' + config_item('subclass_prefix') + $class + EXT

  #  Did we find the class?
  if not class_exists($name)
    die 'Unable to locate the specified class: ' + $class + EXT

  #  Keep track of what we just loaded
  is_loaded($core)

  _classes[$core] = new (global[$name])($config)
  return _classes[$core]

#
# Is Loaded
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
# @return	true
#
exports.show_error = show_error = ($args...) ->
  if not $args[0]? then return false

  _error = load_class('Exceptions', 'core')
  if typeof $args[0] is 'string'
    _error.show_error format.apply(undefined, $args), '5xx', 500
  else
    _error.show_error $args[0], '5xx', 500
  true

#
# 404 Page Handler
#
# This function is similar to the show_error() function above
# However, instead of the standard error template it displays
# 404 errors.
#
# @access	public
# @return	true
#
exports.show_404 = show_404 = ($page = '', $log_error = true) ->
  _error = load_class('Exceptions', 'core')
  _error.show_404 $page, $log_error
  true

#
# Error Logging Interface
#
# We use this as a simple mechanism to access the logging
# class and send messages to be logged.
#
# @access	public
# @return	void
#
exports.log_message = log_message = ($level = 'error', $args...) ->

  if config_item('log_threshold') is 0
    return true

  _log = load_class('Log')
  _log.writeLog $level, format.apply(undefined, $args)
  true

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
    show_error('Status codes must be numeric')


  if $stati[$code]?  and $text is ''
    $text = $stati[$code]


  if $text is ''
    show_error('No status text available.  Please check your status code number or supply your own message text.')

  $text

#
# Remove Invisible Characters
#
# This prevents sandwiching null characters
# between ascii characters, like Java\0script.
#
# @access	public
# @param	string
# @return	string
#
exports.remove_invisible_characters = remove_invisible_characters = ($str, $url_encoded = true) ->

  #  every control character except newline (dec 10)
  #  carriage return (dec 13), and horizontal tab (dec 09)

  if $url_encoded
    #     url encoded 00-08, 11, 12, 14, 15       url encoded 16-31
    $str = $str.replace(/%0[0-8bcef]/g, '').replace(/%1[0-9a-f]/g, '')

  $str.replace(/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]+/g, '')  #  00-08, 11, 12, 14-31, 127

#  ------------------------------------------------------------------------
#
# Export module to the global namespace
#
#
for $name, $body of module.exports
  define $name, $body

# End of file Common.coffee
# Location: ./system/core/Common.coffee