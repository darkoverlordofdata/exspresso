#+--------------------------------------------------------------------+
#  core.coffee
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
# @see 		    http://darkoverlordofdata.com
# @since		  Version 1.0
#

#
# the expresso core module
#

#
# externals
#
format            = require('util').format
path              = require('path')
fs                = require('fs')


#
# local variables
#
_config           = null  # contents of .lib/application/config/config.coffee
_classpaths       = {}    # namespace roots
_classes          = {}    # singleton class cache
_is_loaded        = {}    # singleton class loaded flag
_class            = {}    # class metadata cache
__PROTO__         = true  # if true, set mixin using the '__proto__' property


#
# privately dereference some methods
#
fopen                     = fs.openSync
fclose                    = fs.closeSync
unlink                    = fs.unlinkSync
chmod                     = fs.chmodSync
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
# Getter
#
# @param  [Object]  property definition
# @return [Object]  #
Function::getter = ($def) ->
  $name = keys($def)[0]
  defineProperty @::, $name, {get: $def[$name]}

#
# Setter
#
# @param  [Object]  property definition
# @return [Object]  #
Function::setter = ($def) ->
  $name = keys($def)[0]
  defineProperty @::, $name, {set: $def[$name]}

#
# Define - read only attribute
#
# @param  [Object]  property definition
# @return [Object]  #
Function::define = ($def) ->
  $name = keys($def)[0]
  defineProperty @::, $name, {writeable: false, enumerable: ($name[0] isnt '_'), value: $def[$name]}

# Load the framework constants
#
if file_exists(APPPATH+'config/'+ENVIRONMENT+'/constants.coffee')
  require APPPATH+'config/'+ENVIRONMENT+'/constants.coffee'
else
  require APPPATH+'config/constants.coffee'

#
# Set Classpath
#
#   Adds a namespace/classpath pair
#   The namespace root is associated with the path.
#   load_class will build the namespace tree from
#   the file system and load the class into the correct
#   branch of the tree
#
#
# @param  [Object]    array of {namespace: classpath}
#
#
exports.set_classpath = set_classpath = ($def) ->
  _classpaths[$namespace] = $classpath for $namespace, $classpath of $def


#
# Load Class
#
# Requires a class module, building a namespace
# structure that corresponds to the file path.
#
# There are 3 namespaces:
#
#   system        all the core system classes
#   application   exspresso implementation classes
#   modules       HMVC root
#
#
# @param  [String]    full path to the class
#
#
exports.load_class = load_class = ($path, $namespace = global) ->

  for $name, $classpath of _classpaths
    if $path.indexOf($classpath) is 0
      $subpath = $path.substr($classpath.length)
      unless $namespace[$name]?
        defineProperty $namespace, $name, {writeable: false, value: {}}


      $segments = $subpath.split('/')
      $class = $segments.pop().split('.')[0]

      $namespace = $namespace[$name]
      while $segments.length>0
        $segment = $segments.shift()
        if $segment isnt 'drivers'
          unless $namespace[$segment]?
            defineProperty $namespace, $segment, {writeable: false, value: {}}
          $namespace = $namespace[$segment]

      if $namespace[$class]?
        $klass = $namespace[$class]
      else
        $klass = require($path)
        defineProperty $namespace, $class, {writeable: false, value: $klass}
      return $klass
  return

#
# Tests for file writability
#
# is_writable() returns TRUE on Windows servers when you really can't write to
# the file, based on the read-only attribute.  is_writable() is also unreliable
# on Unix servers if safe_mode is on.
#
# @private
# @return [Void]  #
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
# @param  [String]  the class name being requested
# @return [Object]  constructor param
#
exports.core = core = ($class, $0, $1, $2, $3, $4, $5, $6, $7, $8, $9) ->

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
  for $path in [SYSPATH, APPPATH]
    if file_exists($path + 'core/' + $prefix + $class + EXT)
      $klass = load_class($path + 'core/' + $prefix + $class + EXT)
      break

  #  Is the request a class extension?  If so we load it too
  if file_exists(APPPATH + 'core/' + config_item('subclass_prefix') + $class + EXT)
    $klass = load_class(APPPATH + 'core/' + config_item('subclass_prefix') + $class + EXT)

  #  Did we find the class?
  if not $klass?
    die 'Unable to locate the specified class: ' + $class + EXT

  #  Keep track of what we just loaded
  is_loaded($class)
  _classes[$class] = new $klass($0, $1, $2, $3, $4, $5, $6, $7, $8, $9)


#
# Is Loaded
#
# Keeps track of which libraries have been loaded.  This function is
# called by the load_class() function above
#
# @return	array
#
exports.is_loaded = is_loaded = ($class = '') ->

  if $class isnt ''
    _is_loaded[$class.toLowerCase()] = $class
  _is_loaded


#
# Returns a new core object.
#
# Uesd to create core objects that will be passed
# to the Controller object constructor.
#
# @param  [String]  the class name being requested
# @param  [Object]  list of params to pass to the constructor
# @return [Object]  #
exports.new_core = new_core = ($class, $0, $1, $2, $3, $4, $5, $6, $7, $8, $9) ->

  if typeof $class is 'string'
    $prefix = ''
  else
    $prefix = $class.subclass
    $class = $class.class

  #  Does the class exist?  If so, we're done...
  $klass = system.core[$prefix+$class] or application.core[$prefix+$class]
  if $klass?
    return new $klass($0, $1, $2, $3, $4, $5, $6, $7, $8, $9)

  #  Look for the class first in the native system/libraries folder
  #  then in the local application/libraries folder
  for $path in [SYSPATH, APPPATH]
    if file_exists($path + 'core/' + $prefix + $class + EXT)
      $klass = load_class($path + 'core/' + $prefix + $class + EXT)
      break

  #  Is the request a class extension?  If so we load it too
  if file_exists(APPPATH + 'core/' + config_item('subclass_prefix') + $class + EXT)
    $klass = load_class(APPPATH + 'core/' + config_item('subclass_prefix') + $class + EXT)

  #  Did we find the class?
  if not $klass?
    die 'new_core: Unable to locate the specified class ' + $class + EXT

  new $klass($0, $1, $2, $3, $4, $5, $6, $7, $8, $9)

#
# Loads a new core object
#
# Used to bootstrap the core/loader object in
# the controller constructor.
#
# @param  [String]  the class name being requested
# @param  [Object]  ExspressoController object
# @return [Object]  #
exports.load_core = load_core = ($class, $controller) ->

  if typeof $class is 'string'
    $prefix = ''
  else
    $prefix = $class.subclass
    $class = $class.class

  $klass = system.core[$prefix+$class] or application.core[$prefix+$class]
  #  Does the class exist?  If so, we're done...
  if $klass?
    return create_mixin($controller, $klass, $controller)

  #  Look for the class first in the native system/libraries folder
  #  then in the local application/libraries folder
  for $path in [SYSPATH, APPPATH]
    if file_exists($path + 'core/' + $class + EXT)
      $klass = load_class($path + 'core/' + $prefix + $class + EXT)
      break

  #  Is the request a class extension?  If so we load it too
  if file_exists(APPPATH + 'core/' + config_item('subclass_prefix') + $class + EXT)
    $klass = load_class(APPPATH + 'core/' + config_item('subclass_prefix') + $class + EXT)

  #  Did we find the class?
  if not $klass?
    die 'load_core: Unable to locate the specified class ' + $class + EXT

  create_mixin($controller, $klass, $controller)


#
# Loads the main config.coffee file
#
# This function lets us grab the config file even if the Config class
# hasn't been instantiated yet
#
# @private
# @return	array
#
exports.get_config = get_config = ($replace = {}) ->

  return _config if _config?

  #  Fetch the config file
  $found = false
  _config = {}

  # merge together config, overlaying with environment specific values
  $check_locations = [APPPATH, APPPATH + ENVIRONMENT + '/' ]

  for $location in $check_locations

    $file_path = $location + 'config/config' + EXT
    if file_exists($file_path)
      $found = true
      _config = array_merge(_config, require($file_path))

  if not $found
    die 'The configuration file does not exist.'

  #  Does the $config array exist in the file?
  if not _config?
    die 'Your config file does not appear to be formatted correctly.'

  #  Are any values being dynamically replaced?
  _config[$key] = $val for $val, $key of $replace when _config[$key]?

  _config

#
# Returns the specified config item
#
# @return [Mixed]  #
exports.config_item = config_item = ($item) ->

  get_config() if not _config?
  _config[$item] || ''


#
# Error Handler
#
# This function lets us invoke the exception class and
# display errors using the standard error template located
# in application/errors/5xx.eco
# This function will send the error page directly to the
# browser and exit.
#
# @return	true
#
exports.show_error = show_error = ($args...) ->
  if not $args[0]? then return false

  if typeof $args[0] is 'string'
    core('Exceptions').show5xx format.apply(undefined, $args), '5xx', 500
  else
    core('Exceptions').show5xx $args[0], '5xx', 500

#
# 404 Page Handler
#
# This function is similar to the show_error() function above
# However, instead of the standard error template it displays
# 404 errors.
#
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
# @return [Void]  #
exports.log_message = log_message = ($level = 'error', $args...) ->
  return true if config_item('log_threshold') is 0
  core('Log').write $level, format.apply(undefined, $args)

#
# Get HTTP Status Text
#
# @param	int		the status code
# @param  [String]  # @return [Void]  #
exports.get_status_text = get_status_text = ($code = 200, $text = '') ->
  $stat =
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

  return '' if $code is '' or  not is_numeric($code)
  $text = $stat[$code] if $stat[$code]?  and $text is ''
  $text

#
# Remove Invisible Characters
#
# This prevents sandwiching null characters
# between ascii characters, like Java\0script.
#
# @param  [String]  # @return	[String]
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
# @param  [Object]  destination object
# @param  [Object]  source object
# @return [Object]  #
exports.copyOwnProperties = ($dst, $src) ->
  $properties = {}
  for $key in getOwnPropertyNames($src)
    $properties[$key] = getOwnPropertyDescriptor($src, $key)

  defineProperties $dst, $properties

#
# Define Class Metadata
#
# Analyze the metadata for a class, then build and cache
# a table of property definitions for that classs.
#
# @param  [Object]  destination object
# @param  [Object]  source object
# @return [Object]  the cached metadata
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
# @param  [Object]  object to use as the prototype
# @param  [Array]  list of mixin classes, followed by construcor args
# @return [Object]  #
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


#
# Export the core module to the global namespace
#
#
for $name, $body of module.exports
  define $name, $body

#
# Built-in classpaths
#
set_classpath config_item('classpaths')
#
# Pre-load the system.core classes
#
load_class SYSPATH+'core/Object.coffee'
load_class SYSPATH+'core/Exspresso.coffee'
load_class SYSPATH+'core/Benchmark.coffee'
load_class SYSPATH+'core/Config.coffee'
load_class SYSPATH+'core/Controller.coffee'
load_class SYSPATH+'core/Exceptions.coffee'
load_class SYSPATH+'core/Hooks.coffee'
load_class SYSPATH+'core/I18n.coffee'
load_class SYSPATH+'core/Input.coffee'
load_class SYSPATH+'core/Loader.coffee'
load_class SYSPATH+'core/Log.coffee'
load_class SYSPATH+'core/Model.coffee'
load_class SYSPATH+'core/Modules.coffee'
load_class SYSPATH+'core/Output.coffee'
load_class SYSPATH+'core/Router.coffee'
load_class SYSPATH+'core/Security.coffee'
load_class SYSPATH+'core/Server.coffee'
load_class SYSPATH+'core/URI.coffee'
load_class SYSPATH+'core/Utf8.coffee'
load_class SYSPATH+'lib/Driver.coffee'
load_class SYSPATH+'lib/DriverLibrary.coffee'
load_class MODPATH+'user/lib/User.coffee'
load_class MODPATH+'user/models/UserModel.coffee'
load_class SYSPATH+'lib/session/Session.coffee'

# End of file core.coffee
# Location: ./system/core.coffee