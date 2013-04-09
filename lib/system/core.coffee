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
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @author     darkoverlordofdata
# @copyright	Copyright (c) 2012 - 2013, Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @see 		    http://darkoverlordofdata.com
# @since		  Version 1.0
#

#
# the expresso core api
#

#
# externals
#
format            = require('util').format
path              = require('path')
fs                = require('fs')
url               = require('url')
crypto            = require('crypto')
formatnumber      = require('format-number')
querystring       = require('querystring')
sprintf           = require('sprintf').sprintf
glob              = require('glob').sync



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
# Initialize the API
#
#
module.exports = ->

  #
  # Load the framework constants
  #
  if file_exists(APPPATH+'config/'+ENVIRONMENT+'/constants.coffee')
    require APPPATH+'config/'+ENVIRONMENT+'/constants.coffee'
  else
    require APPPATH+'config/constants.coffee'

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
  load_class SYSPATH+'core/Connect.coffee'
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
  load_class SYSPATH+'core/URI.coffee'
  load_class SYSPATH+'core/Utf8.coffee'
  load_class SYSPATH+'lib/Profiler.coffee'
  load_class SYSPATH+'lib/Driver.coffee'
  load_class SYSPATH+'lib/DriverLibrary.coffee'
  load_class MODPATH+'user/lib/User.coffee'
  load_class MODPATH+'user/models/UserModel.coffee'
  load_class SYSPATH+'lib/session/Session.coffee'
  load_class APPPATH+'core/PublicController.coffee'
  load_class APPPATH+'core/Module.coffee'


#
# Magic
#
# Dependency injection via prototype.
#
# Args can be
#
#
#   1)  A list of classes followed by an optional list
#       of constructor parameters.
#
#       This is used to create a super-controller, where
#       the controller's properties and methods are available
#       to all objects loaded by the controller.
#
#
#   2)  A list of objects to use as prototypes.
#
#       This is used to merge the super-controller with data
#       making the controller's properties and methods
#       available to the view.
#
#
#
# @param  [Object]  proto  the prototype of the new object
# @param  [Array] args  list of mixin classes, followed by construcor args
# @return [Object] the fabricated mixin
#
module.exports.magic = ($proto, $args...) ->

  $properties = {}
  $pos = 0

  # get the mixin class(es)
  while 'function' is typeof ($mixin = $args[$pos])
    # the 1st mixin class will also be the constructor
    $class = $mixin if $pos is 0
    $pos++
    for $key, $val of metadata($mixin)
      $properties[$key] = $val

  # no class was encountered
  if not $class? then switch $args.length
    when 0
    # simple case -
      return create($proto)

    when 1
    # optimized case -
      if __PROTO__
        # array inherits from the object
        $args[0].__proto__ = $proto
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
        $args[$args.length-1].__proto__ = $proto
        return create($args[0])

      else
        for $data in $args
          for $key in getOwnPropertyNames($data)
            $properties[$key] = getOwnPropertyDescriptor($data, $key)

  # clone the object with all properties
  $this = create($proto, $properties)
  # call the constructor
  $class.apply $this, $args[$pos..] if $class?
  $this

#
# Get Class Metadata
#
# Analyze the metadata for a class, then build and cache
# a table of property definitions for that classs.
#
# @param  [Object]  class a class constructor function
# @return [Object]  the cached metadata
#
metadata = ($class) ->

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
# @return [Void]
#
module.exports.set_classpath = ($def) ->
  _classpaths[$namespace] = $classpath for $namespace, $classpath of $def


#
# Load Class
#
# Requires a class module, building a namespace
# structure that corresponds to the file path.
#
# There are 3 namespaces:
#
# <dl>
#   <dt>system</dt>        <dd>all the core system classes</dd>
#   <dt>application</dt>   <dd>exspresso implementation classes</dd>
#   <dt>modules</dt>       <dd>HMVC root</dd>
# </dl>
#
# @param  [String]  path  full path to the class
# @param  [Object]  namespace the namespace to load into
# @return [Object] the class object
#
#
module.exports.load_class = ($path, $namespace = global) ->

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
# @param [String] file  file name to test
# @return [Boolean] true if file is writeable
#
module.exports.is_really_writable = ($file) ->

  #  We'll actually write a file then read it.  Bah...
  if is_dir($file)
    $file = rtrim($file, '/') + '/' + md5(''+rand(1, 100) + rand(1, 100))

    if ($fp = fs.openSync($file, FOPEN_WRITE_CREATE)) is false
      return false

    fs.closeSync($fp)
    fs.chmodSync($file, DIR_WRITE_MODE)
    fs.unlinkSync($file)
    return true

  else if not is_file($file) or ($fp = fs.openSync($file, FOPEN_WRITE_CREATE)) is false
    return false

  fs.closeSync($fp)
  return true


#
# Returns a core singleton
#
# Use to access the top level server objects
#
# @param  [String]  class the class name being requested
# @param  [Mixed] p0  param 0
# @param  [Mixed] p1  param 1
# @param  [Mixed] p2  param 2
# @param  [Mixed] p3  param 3
# @param  [Mixed] p4  param 4
# @param  [Mixed] p5  param 5
# @param  [Mixed] p6  param 6
# @param  [Mixed] p7  param 7
# @param  [Mixed] p8  param 8
# @param  [Mixed] p9  param 9
# @returns [Object] the singleton
#
module.exports.core = ($class, $0, $1, $2, $3, $4, $5, $6, $7, $8, $9) ->

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
# @param [String] class the name of the class
# @return [Boolean] true if the class is loaded
#
module.exports.is_loaded = ($class = '') ->

  if $class isnt ''
    _is_loaded[$class.toLowerCase()] = $class
  _is_loaded


#
# Returns a new core object.
#
# Uesd to create core objects that will be passed
# to the Controller object constructor.
#
# @param  [String]  class the class name being requested
# @param  [Mixed] p0  param 0
# @param  [Mixed] p1  param 1
# @param  [Mixed] p2  param 2
# @param  [Mixed] p3  param 3
# @param  [Mixed] p4  param 4
# @param  [Mixed] p5  param 5
# @param  [Mixed] p6  param 6
# @param  [Mixed] p7  param 7
# @param  [Mixed] p8  param 8
# @param  [Mixed] p9  param 9
# @returns [Object] the new object
#
module.exports.new_core = ($class, $0, $1, $2, $3, $4, $5, $6, $7, $8, $9) ->

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
# @param  [String]  class the class name being requested
# @param  [system.core.Object]  controller  the controller to load into
# @return [Object] the new core object
#
module.exports.load_core = ($class, $controller) ->

  if typeof $class is 'string'
    $prefix = ''
  else
    $prefix = $class.subclass
    $class = $class.class

  $klass = system.core[$prefix+$class] or application.core[$prefix+$class]
  #  Does the class exist?  If so, we're done...
  if $klass?
    return magic($controller, $klass, $controller)

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

  magic($controller, $klass, $controller)


#
# Loads the main config.coffee file
#
# This function lets us grab the config file even if the Config class
# hasn't been instantiated yet
#
# @param  [Object]  replace hash of replacement key/value pairs
# @return [Object] the config hash
#
module.exports.get_config = ($replace = {}) ->

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
      _config[$key] = $val for $key, $val of require($file_path)

  if not $found
    die 'The configuration file does not exist.'

  #  Does the $config array exist in the file?
  if not _config?
    die 'Your config file does not appear to be formatted correctly.'

  #  Are any values being dynamically replaced?
  _config[$key] = $val for $key, $val of $replace when _config[$key]?

  _config

#
# Returns the specified config item
#
# @param  [String]  item  the config value name
# @return [Mixed] the config item value
#
module.exports.config_item = ($item) ->

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
# @param  [Array] args  the argment array
# @return [Boolean] true
#
module.exports.show_error = ($args...) ->
  return false unless $args[0]?

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
# @param  [Array] args  the argment array
# @param  [Boolean] log_error write to log
# @return [Boolean] true
#
module.exports.show_404 = ($page = '', $log_error = true) ->
  core('Exceptions').show404 $page, $log_error

#
# Error Logging Interface
#
# We use this as a simple mechanism to access the logging
# class and send messages to be logged.
#
# @param [String] level the logging level: error | debug | info
# @param [Array]  args  the remaining args match the sprintf signature
# @return [Boolean] true
#
module.exports.log_message = ($level = 'error', $args...) ->
  return true if config_item('log_threshold') is 0
  core('Log').write $level, format.apply(undefined, $args)

#
# Get HTTP Status Text
#
# @param  [Integer] code		the status code
# @param  [String]  text  alternate status text
# @return [String] the status text
#
module.exports.get_status_text = ($code = 200, $text = '') ->
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

  return '' if $code is '' or  not 'number' is typeof($code)
  $text = $stat[$code] if $stat[$code]?  and $text is ''
  $text

#
# Remove Invisible Characters
#
# This prevents sandwiching null characters
# between ascii characters, like Java\0script.
#
# @param  [String]  str the string to clean
# @param  [Boolean] url_encoded true to relace url encoded non-printables
# @return [String] the clean string
#
module.exports.remove_invisible_characters = ($str, $url_encoded = true) ->

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
# @param  [Object]  dst the destination object
# @param  [Object]  src the source object
# @return [Object] the destination object
#
module.exports.copyOwnProperties = ($dst, $src) ->
  $properties = {}
  for $key in getOwnPropertyNames($src)
    $properties[$key] = getOwnPropertyDescriptor($src, $key)

  defineProperties $dst, $properties


#
# publicly dereference some Object utility member
#
module.exports.defineProperties = Object.defineProperties
module.exports.defineProperty = Object.defineProperty
module.exports.freeze = Object.freeze
module.exports.keys = Object.keys

module.exports.sprintf = require('sprintf').sprintf
module.exports.glob = require('glob').sync
module.exports.rawurldecode = querystring.unescape
module.exports.file_exists = fs.existsSync || path.existsSync
module.exports.basename = require('path').basename

module.exports.function_exists = ($funcname) -> typeof global[$funcname] is 'function'
module.exports.dirname = ($str) -> path.dirname
module.exports.is_dir = ($path) -> fs.existsSync($path) and fs.statSync($path).isDirectory()
module.exports.is_file = ($path) -> fs.existsSync($path) and fs.statSync($path).isFile()
module.exports.realpath = ($path) -> if fs.existsSync($path) then fs.realpathSync($path) else false
module.exports.time = -> Math.floor(Date.now()/1000)

# htmlspecialchars
#
# Convert special characters to html entities
#
# @param  [String]  str the string to convert
# @return [String] converted string
#
module.exports.htmlspecialchars = ($str) ->

  (''+$str)
    .replace(/\&/g, "&amp;")
    .replace(/\'/g, "&#39;")
    .replace(/\"/g, "&quot;")
    .replace(/\</g, "&lt;")
    .replace(/\>/g, "&gt;")

# stripslashes
#
# Remove escaping slashes from a string
#
# @param  [String]  str the string to convert
# @return [String] converted string
#
module.exports.stripslashes = ($str) ->
  (''+$str)
    .replace(/\\'/g, '\'')
    .replace(/\\"/g, '"')
    .replace(/\\0/g, '\0')
    .replace(/\\\\/g, '\\')

# wordwrap
#
# Wraps a string to fixed number of characters
#
# @param  [String]  str the string to convert
# @param  [Integer] width character wrap count
# @param  [String]  break char used to break line
# @param  [Boolean] cut if true, cut words at or before limit
# @return [String] converted string
#
# @see http://james.padolsey.com/javascript/wordwrap-for-javascript/
#
module.exports.wordwrap = ($string, $width=75, $break=os.EOL, $cut=false) ->

  return $string unless $string.length>0
  $re = '.{1,' + $width + '}(\\s|$)' + if $cut then '|.{' + $width + '}|.+$' else '|\\S+?(\\s|$)'
  $string.match(RegExp($re, 'g') ).join($break);


# define
#
# define a readonly property
#
# @param  [String]  name  name of the property
# @param  [String]  value property value
# @param  [String]  scope where to define the property
# @return [Mixed]
#
module.exports.define = ($name, $value, $scope = global) ->
  Object.defineProperty($scope, $name, {writeable: false, value: $value})
  $value

module.exports.number_format = ($number, $decimals = 0, $dec_point = '.', $thousands_sep = ',') ->

  $format = formatnumber(seperator: $thousands_sep, decimal: $dec_point, padRight: $decimals, truncate: $decimals)
  $format($number)

# die
#
# display message end exit process with fail
#
# @param  [String]  str  string display
#
module.exports.die = ($message) ->
  console.log $message
  process.exit 1

# die
#
# display message end exit process with success
#
# @param  [String]  str  string display
#
module.exports.exit = ($message) ->
  console.log $message
  process.exit 0


# md5
#
# returns an md5 hash of a string
#
# @param  [String]  str  string to hash
# @return [String] the md5 hash value
#
module.exports.md5 = ($str, $output='hex') ->
  crypto.createHash('md5').update($str).digest($output)

# sha1
#
# returns an sha1 hash of a string
#
# @param  [String]  str  string to hash
# @return [String] the sha1 hash value
#
module.exports.sha1 = ($str, $output='hex') ->
  crypto.createHash('sha1').update($str).digest($output)

# reg_quote
#
# escape the regexp control chars in the string
#
# @param  [String]  str  string to escape
# @return [String] the escaped string
#
module.exports.reg_quote = ($str) ->
  $str.replace(/([\.\\\+\*\?\[\^\]\$\(\)\{\}\=\!\<\>\|\:\-])/gm, '\\$1')


# uniqid
#
# returns a unique string id
#
# @param  [String]  prefix  prefix to prepend to the string
# @return [String] the unique id
#
module.exports.uniqid = ($prefix = '', $more_entropy = false) ->

  $result = $prefix + (Date().now()).toString(16)+(Math.floor(Math.random() * 256)).toString(16)
  if $more_entropy is true
    $result += (Math.random() * 10).toFixed(8).toString()
  $result


# ucfirst
#
# returns a string with the first char capitalized
#
# @param  [String] str  string to capitalize
# @return [String] the capitalized string
#
module.exports.ucfirst = ($str) ->
  $str.charAt(0).toUpperCase() + $str.substr(1)

# ucwords
#
# returns a string with the first char of each word capitalized
#
# @param  [String] str  string to capitalize
# @return [String] the capitalized string
#
module.exports.ucwords = ($str) ->
  ''+$str.replace /^([a-z\u00E0-\u00FC])|\s+([a-z\u00E0-\u00FC])/g, ($1) -> $1.toUpperCase()


# rand
#
# returns a random number between min and max
#
# @param  [Integer]  min  low range value
# @param  [Integer]  max  hi range value
# @return [Integer] the random number
#
module.exports.rand = ($min = 0, $max = 2147483647) ->
  Math.floor(Math.random() * $max) - $min


# array
#
# returns an array with 1 key/value pair
#
# @param  [String]  key the hash key
# @param  [Mixed] value the value
# @return [String] a new object with 1 key/value pair
#
module.exports.array = ($key, $value) ->
  $array = {}
  $array[$key] = $value
  $array

# parse_url
#
# parse an url and return it's elements
#
# @param  [String]  url the url to parse
# @return [Object] a new hash with the parse elements
#
module.exports.parse_url = ($url) ->

  $p = url.parse($url)
  if $p.auth?
    [$username, $password] = $p.auth.split(':')
  else
    [$username, $password] = ['','']

  return {
    scheme:     $p.protocol.split(':')[0]
    host:       $p.hostname
    port:       $p.port
    user:       $username
    pass:       $password
    path:       $p.pathname
    query:      $p.query
    fragment:   $p.hash
  }


module.exports.is_array = ($var) ->
  if typeof $var is 'object'
    if $var is null then false else true
  else
    false

# rtrim
#
# right trim a string
#
# @param  [String] str  string to trim
# @param  [String] char the character to trim
# @return [String] the trimed string
#
module.exports.rtrim = ($str, $chars = ' ') ->

  if $chars is ' '
    $str.replace(/[\s]+$/g, '')
  else if $chars is '/'
    $str.replace(/[\/]+$/g, '')
  else
    $str.replace(new RegExp("[" + $chars + "]+$", "g"), "")

# ltrim
#
# left trim a string
#
# @param  [String] str  string to trim
# @param  [String] char the character to trim
# @return [String] the trimed string
#
module.exports.ltrim = ($str, $chars = ' ') ->

  if $chars is ' '
    $str.replace(/^[\s]+/g, '')
  else if $chars is '/'
    $str.replace(/^[\/]+/g, '')
  else
    $str.replace(new RegExp("^[" + $chars + "]+", "g"), "")

# rtrim
#
# trim a string
#
# @param  [String] str  string to trim
# @param  [String] char the character to trim
# @return [String] the trimed string
#
module.exports.trim = ($str, $chars = ' ') ->

  if $chars is ' ' then $str.replace(/^[\s]+/g, '').replace(/[\s]+$/g, '')
  else ltrim(rtrim($str, $chars), $chars)

# empty
#
# checks if a primitive variable has a value
# checks if a object variable has children
#
# @param  [String] var  variable to check
# @returns [Boolean] true if var has a value
#
module.exports.empty = ($var) ->

  not switch typeof $var
    when 'undefined' then false
    when 'string'
      if $var.length is 0 then false else true
    when 'number'
      if $var is 0 then false else true
    when 'boolean'
      $var
    when 'object'
      if Array.isArray($var)
        if $var.length is 0 then false else true
      else
        if Object.keys($var).length is 0 then false else true
    else false



#  ------------------------------------------------------------------------
#
# Export module to the global namespace
#
#
module.exports.export = ($scope = global) ->

  for $name, $body of module.exports
    Object.defineProperty($scope, $name, {writeable: false, value: $body}) unless $name is 'export'

  return

# End of file core.coffee
# Location: ./system/core.coffee