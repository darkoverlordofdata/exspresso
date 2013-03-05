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
_classes          = {}    # singleton class cache
_is_loaded        = {}    # class loaded flag
_class            = {}    # metadata cache
__PROTO__         = true  # if true, set using the '__proto__' property

#
# privately dereference some Object utility members
#
create                    = Object.create
defineProperties          = Object.defineProperties
defineProperty            = Object.defineProperty
freeze                    = Object.freeze
getOwnPropertyDescriptor  = Object.getOwnPropertyDescriptor
getOwnPropertyNames       = Object.getOwnPropertyNames
getPrototypeOf            = Object.getPrototypeOf
keys                      = Object.keys
prototype                 = Object.prototype
#
# publicly dereference some Object utility member
#
exports.defineProperties  = Object.defineProperties
exports.defineProperty    = Object.defineProperty
exports.freeze            = Object.freeze
exports.keys              = Object.keys

#
# Init Namespaces
#
define 'system'           # ./lib/system
  core        : {}        # ./lib/system/core
  lib         :           # ./lib/system/lib
    session   : {}        # ./lib/system/lib/session
  db          :           # ./lib/system/db
    mysql     : {}        # ./lib/system/db/mysql
    postgres  : {}        # ./lib/system/db/postgres

define 'modules'          # ./lib/modules
  user        :           # ./lib/modules/user
    lib       : {}        # ./lib/modules/user/lib
    models    : {}        # ./lib/modules/user/models

define 'application'      # ./lib/application
  core        : {}        # ./lib/application/core
  lib         : {}        # ./lib/application/lib
  models      : {}        # ./lib/application/models


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
# Returns a core singleton
#
# Use to access the top level server objects
#
# @access	public
# @param	string	the class name being requested
# @param	string	the class name prefix
# @return	object  constructor param
#
exports.core = core = ($class, $param) ->

  if typeof $class is 'string'
    $prefix = ''
  else
    $prefix = $class.subclass
    $class = $class.class

  #  Does the class exist?  If so, we're done...
  if _classes[$class]?
    return _classes[$class]

  #  Look for the class first in the native system/libraries folder
  #  then in the local application/libraries folder
  for $path in [BASEPATH, APPPATH]
    if file_exists($path + 'core/' + $prefix + $class + EXT)
      $klass = require($path + 'core/' + $prefix + $class + EXT)

      break

  #  Is the request a class extension?  If so we load it too
  if file_exists(APPPATH + 'core/' + config_item('subclass_prefix') + $class + EXT)
    $klass = require(APPPATH + 'core/' + config_item('subclass_prefix') + $class + EXT)

  #  Did we find the class?
  if not $klass?
    die 'Unable to locate the specified class: ' + $class + EXT

  #  Keep track of what we just loaded
  is_loaded($class)

  _classes[$class] = new $klass($param)


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
# Returns a new core object.
#
# Uesd to create core objects that will be passed
# to the Controller object constructor.
#
# @access	public
# @param	string	the class name being requested
# @param	string	the class name prefix
# @param  object  list of params to pass to the constructor
# @return	object
#
exports.new_core = new_core = ($class, $0, $1, $2, $3, $4, $5, $6, $7, $8, $9) ->

  if typeof $class is 'string'
    $prefix = ''
  else
    $prefix = $class.subclass
    $class = $class.class

  #  Does the class exist?  If so, we're done...
  if system.core[$prefix+$class]?
    return new system.core[$prefix+$class]($0, $1, $2, $3, $4, $5, $6, $7, $8, $9)

  $name = false

  #  Look for the class first in the native system/libraries folder
  #  then in the local application/libraries folder
  for $path in [BASEPATH, APPPATH]
    if file_exists($path + 'core/' + $class + EXT)
      $name = $prefix + $class

      if not system.core[$name]?
        require($path + 'core/' + $class + EXT)

      break

  #  Is the request a class extension?  If so we load it too
  if file_exists(APPPATH + 'core/' + config_item('subclass_prefix') + $class + EXT)
    $name = config_item('subclass_prefix') + $class

    if not system[$directory][$name]?
      require(APPPATH + 'core/' + config_item('subclass_prefix') + $class + EXT)

  #  Did we find the class?
  if not system.core[$name]?
    die 'Unable to locate the specified class: ' + $class + EXT

  return new system.core[$name]($0, $1, $2, $3, $4, $5, $6, $7, $8, $9)

#
# Loads a new core object
#
# Used to bootstrap the core/loader object in
# the controller constructor.
#
# @access	public
# @param	string	the class name being requested
# @param	string	the directory where the class should be found
# @param	string	the class name prefix
# @param  object  ExspressoController object
# @return	object
#
exports.load_core = load_core = ($class, $controller) ->

  if typeof $class is 'string'
    $prefix = ''
  else
    $prefix = $class.subclass
    $class = $class.class

  $klass = application.core[$prefix+$class] or system.core[$prefix+$class]
  #  Does the class exist?  If so, we're done...
  if $klass?
    return create_mixin($controller, $klass, $controller)

  $name = false
  $root = null

  #  Look for the class first in the native system/libraries folder
  #  then in the local application/libraries folder
  for $path in [BASEPATH, APPPATH]
    $root = (if $path is BASEPATH then system else application)
    if file_exists($path + 'core/' + $class + EXT)
      $name = $prefix + $class

      if not $root.lib[$name]?
        $klass = require($path + 'core/' + $class + EXT)

      break

  #  Is the request a class extension?  If so we load it too
  if file_exists(APPPATH + 'core/' + config_item('subclass_prefix') + $class + EXT)
    $name = config_item('subclass_prefix') + $class

    if not system.lib[$name]?
      $klass = require(APPPATH + 'core/' + config_item('subclass_prefix') + $class + EXT)

  #  Did we find the class?
  if not $klass?
    die 'Unable to locate the specified class: ' + $class + EXT

  create_mixin($controller, $klass, $controller)


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

  if typeof $args[0] is 'string'
    core('Exceptions').showError format.apply(undefined, $args), '5xx', 500
  else
    core('Exceptions').showError $args[0], '5xx', 500

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
  core('Exceptions').show404 $page, $log_error

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
  return true if config_item('log_threshold') is 0
  core('Log').writeLog $level, format.apply(undefined, $args)

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


#
# Copy Own Properties
#
# Copy all properties from a source or template object
# Getters, setters, read only, and other custom attributes
# are safely copied
#
# @param	object	destination object
# @param	object	source object
# @return	object
#
exports.copyOwnProperties = ($dst, $src) ->
  $properties = {}
  for $key in getOwnPropertyNames($src)
    $properties[$key] = getOwnPropertyDescriptor($src, $key)

  defineProperties $dst, $properties


#
# Define Getter
#
# @access	public
# @param	object	property definition
# @return	object
#
Function::getter = ($def) ->
  $name = keys($def)[0]
  defineProperty @::, $name, {get: $def[$name]}

#
# Define Setter
#
# @access	public
# @param	object	property definition
# @return	object
#
Function::setter = ($def) ->
  $name = keys($def)[0]
  defineProperty @::, $name, {set: $def[$name]}


#
# Define Class Metadata
#
# Analyze the metadata for a class, then build and cache
# a table of property definitions for that classs.
#
# @param	object	destination object
# @param	object	source object
# @return	object  the cached metadata
#
exports.defineClass = ($class) ->

  $name = $class::constructor.name
  if not _class[$name]?

    $props = {}       # an array to build the object property def
    $chain = []       # an array to list the inheritance chain
    $proto = $class:: # starting point in the chain

    # Build an inheritance list
    until $proto is prototype
      $chain.push $proto
      $proto = getPrototypeOf($proto)

    # Reverse list to process overrides in the correct order
    for $proto in $chain.reverse()
      if $proto isnt Object::
        # Build the inherited properties table
        for $key in getOwnPropertyNames($proto)
          $props[$key] = getOwnPropertyDescriptor($proto, $key)

    # cache the class definition
    _class[$name] = $props
  _class[$name]

#
# Create a Mixin
#
# Create a mixin object from a prototype object
# with an optional list of classes to mixin,
# followed by an optional list of arguments to the
# constructor of the first class.
#
# If there are no classes, the list of args is a list
# of additional objects that are simply merged into the
# first object. These objects are expected to be literal
# based, and only the own properties are used
#
#
# @param	object	object to use as the prototype
# @param	array   list of mixin classes, followed by construcor args
# @return	object
#
exports.create_mixin = ($object, $args...) ->

  $properties = {}
  $pos = 0

  # get the mixin class(es)
  while 'function' is typeof ($mixin = $args[$pos])
    # the 1st mixin class will also be the constructor
    $class = $mixin if $pos is 0
    $pos++
    for $key, $val of defineClass($mixin)
      $properties[$key] = $val

  # no class was encountered
  if not $class? then switch $args.length
    when 0
    # simple case -
      return create($object)

    when 1
    # optimized case -
      if __PROTO__
        # array inherits from the object
        $args[0].__proto__ = $object
        return create($args[0])

      else
        for $key in getOwnPropertyNames($args[0])
          $properties[$key] = getOwnPropertyDescriptor($args[0], $key)

    else
    # multiple arrays -
      if __PROTO__
        # each array inherits from the next
        for $i in [0...$args.length]
          $args[$i].__proto__ = $args[$i+1]
        # last array inherits from the object
        $args[$args.length-1].__proto__ = $object
        return create($args[0])

      else
        for $data in $args
          for $key in getOwnPropertyNames($data)
            $properties[$key] = getOwnPropertyDescriptor($data, $key)

  # clone the object with all properties
  $this = create($object, $properties)
  # call the constructor
  $class.apply $this, $args[$pos..] if $class?
  $this


#  ------------------------------------------------------------------------
#
# Export module to the global namespace
#
#
for $name, $body of module.exports
  define $name, $body


# End of file Common.coffee
# Location: ./system/core/Common.coffee