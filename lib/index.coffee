#+--------------------------------------------------------------------+
#| lib.coffee
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
# php compatability lib
#
format          = require('format-number')              # Formats numbers with separators...
fs              = require('fs')                         # Standard POSIX file i/o
path            = require('path')                       # File path utilities
querystring     = require('querystring')                # Utilities for dealing with query strings.
url             = require('url')                        # Utilities for URL resolution and parsing.

exports.define = (name, value, scope = global) ->

  if scope[name]?
    return false # already defined

  Object.defineProperty scope, name,
    'value':			value
    'enumerable': true
    'writable':		false

  return true # success

exports.defined = (name, scope = global) ->

  return scope[name]?

exports.constant = (name, scope = global) ->

  if scope[name]?
    return scope[name]
  else
    return null


exports._classes = _classes = {}                        # class registry

exports.die = ($message) ->
  console.log $message
  process.exit 1

## --------------------------------------------------------------------

exports.array_keys = ($input, $search = null) ->

  $ret = []
  $keys = Object.keys($input)
  if $search is null
    $keys
  else
    $i = 0
    while $i < $keys.length
      $k = $keys[$i]
      $ret.push $k if $input[$k] is $search
      $i++
    $ret

## --------------------------------------------------------------------

exports.array_unique = ($array) ->

  $ret = {}
  $val = {}
  if Array.isArray($array)
    for $v, $k in $array
      if not $val[$v]?
        $val[$v] = $k
        $ret[$k] = $v
  else
    for $k, $v of $array
      if not $val[$v]?
        $val[$v] = $k
        $ret[$k] = $v
  $ret

## --------------------------------------------------------------------

exports.array_values = ($input) ->

  $ret = []
  for $k, $v of $input
    $ret.push $v
  $ret


## --------------------------------------------------------------------

exports.array_merge = ($array1, $array2) ->

  $ret = {}
  for $key, $item of $array1
    $ret[$key] = $item
  for $key, $item of $array2
    $ret[$key] = $item
  return $ret

## --------------------------------------------------------------------

exports.array_pad = ($input, $pad_size, $pad_value) ->

  if $input.length < $pad_size
    $start = $input.length
    for $i in [$start..$pad_size-1]
      $input[$i] = $pad_value

  $input

## --------------------------------------------------------------------

exports.array_shift = ($array) ->

  $array.shift()


## --------------------------------------------------------------------

exports.array_slice = ($array, $offset, $length = null) ->

  if $length is null
    $end = $array.length
  else
    $end = $offset + $length
  $array.slice($offset, $end)


## --------------------------------------------------------------------

exports.array_splice = ($input, $offset, $length = 0, $replacement = null) ->

    if $length is 0 then $length = $input.length
    if $replacement is null
      $input.splice($offset, $length)
    else
      Array::splice.apply($input, [$offset, $length].concat($replacement))


## --------------------------------------------------------------------

exports.array_unshift = ($array, $var...) ->

  Array::unshift.apply($array, $var)

## --------------------------------------------------------------------

#exports.class_exists = ($class_name) ->


  #_classes[$class_name]?

## --------------------------------------------------------------------

exports.count = ($var) ->

  if typeof $var is 'string' or typeof $var is 'number' or typeof $var is 'boolean'
    return 1

  if typeof $var isnt 'object'
    return 0

  Object.keys($var).length

## --------------------------------------------------------------------

exports.current = ($array) ->

  if Array.isArray($array)
    if $array.length>0 then $array[0] else false
  else
    $length = Object.keys($array).length
    if $length>0 then $array[Object.keys($array)[0]] else false


## --------------------------------------------------------------------

exports.dirname = ($str) ->

  path.dirname($str)

## --------------------------------------------------------------------

exports.end = ($array) ->

  if Array.isArray($array)
    $length = $array.length
    if $length>0 then $array[$length-1] else false
  else
    $length = Object.keys($array).length
    if $length>0 then $array[Object.keys($array)[$length-1]] else false


## --------------------------------------------------------------------

exports.exit = exports.die = ($status = 0) ->

  if typeof $status is 'number'
    process.exit $status
  else
    console.log $status
    process.exit 1

## --------------------------------------------------------------------

exports.explode = ($delimiter, $string, $limit) ->

  $string.split($delimiter, $limit)

## --------------------------------------------------------------------

exports.format_number = ($number, $decimals = 0, $dec_point = '.', $thousands_sep = ',') ->

  $format = format(seperator: $thousands_sep, decimal: $dec_point, padRight: $decimals, truncate: $decimals)
  $format($number)

## --------------------------------------------------------------------

exports.file_exists = ($path) ->

  fs.existsSync($path)

## --------------------------------------------------------------------

exports.implode = ($glue, $pieces = null) ->

  if $pieces is null
    $pieces = $glue
    $glue = ''

  $pieces.join($glue)

## --------------------------------------------------------------------

exports.in_array = ($needle, $haystack, $strict = false) ->

  $pos = $haystack.indexOf($needle)
  if $pos is -1 then return false
  if $strict
    if typeof $needle is typeof $haystack[$pos] then $pos else false
  else
    $pos

## --------------------------------------------------------------------

exports.is_array = ($var) ->

  if typeof $var is 'object' then true else false

## --------------------------------------------------------------------

exports.is_bool = ($var) ->

  if typeof $var is 'boolean' then true else false

## --------------------------------------------------------------------

exports.is_file = ($path) ->

  try
    $stats = fs.statSync($path)
    $b = $stats.isFile()
  catch ex
    $b = false
  finally
    return $b

## --------------------------------------------------------------------

exports.is_dir = ($path) ->

  try
    $stats = fs.statSync($path)
    $b = $stats.isDirectory()
  catch ex
    $b = false
  finally
    return $b

## --------------------------------------------------------------------

exports.is_null = ($var) ->

  if $var is null or typeof $var is 'undefined' then true else false

## --------------------------------------------------------------------

exports.is_numeric = ($var) ->

  if typeof $var is 'number' then true else false

## --------------------------------------------------------------------

exports.is_object = ($var) ->

  if typeof $var is 'object' then true else false

## --------------------------------------------------------------------

exports.is_string = ($var) ->

  if typeof $var is 'string' then true else false


## --------------------------------------------------------------------

exports.ltrim = ltrim = ($str, $chars) ->

  $chars = $chars ? "\\s";
  $str.replace(new RegExp("^[" + $chars + "]+", "g"), "")


## --------------------------------------------------------------------

exports.microtime = () ->

  return new Date().getTime()

## --------------------------------------------------------------------

exports.mt_rand = ($min = 0, $max = 2147483647) ->

  Math.floor(Math.random() * $max) - $min


## --------------------------------------------------------------------

exports.parse_str = ($str, $arr = {}) ->

  $p = querystring.parse($str)
  for $key, $val of $p
    $arr[$key] = $val

  return

## --------------------------------------------------------------------

exports.parse_url = ($url) ->

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

createRegExp = ($pattern) ->

  $delim = $pattern.charAt(0)
  $end = $pattern.lastIndexOf($delim)
  $flags = $pattern.substr($end+1)
  $pattern = $pattern.substr(1, $end-1)
  new RegExp($pattern, $flags)


## --------------------------------------------------------------------

exports.preg_match = ($pattern, $subject) ->

  $regex = createRegExp($pattern)
  $subject.match($regex)


## --------------------------------------------------------------------

exports.preg_replace = ($pattern, $replacement, $subject, $limit = -1) ->


  $regex = createRegExp($pattern)
  $subject.replace($regex,$replacement)

## --------------------------------------------------------------------

exports.rawurldecode = ($str) ->

  querystring.unescape($str)

## --------------------------------------------------------------------

exports.realpath = ($path) ->

  if fs.existsSync($path)
    return fs.realpathSync($path)
  else
    return false

## --------------------------------------------------------------------

exports.rtrim = rtrim = ($str, $chars) ->

  $chars = $chars ? "\\s";
  $str.replace(new RegExp("[" + $chars + "]+$", "g"), "")

## --------------------------------------------------------------------

exports.str_replace = ($search, $replace, $subject) ->

  if typeof $search is 'string'
    $subject = $subject.replace($search, $replace)
  else
    $i = 0
    while $i < $search.length
      if typeof $replace is 'string'
        $subject = $subject.replace($search[$i], $replace)
      else
        $subject = $subject.replace($search[$i], if $replace[$i]? then $replace[$i] else '')
      $i++

  $subject

## --------------------------------------------------------------------

exports.stristr = ($haystack, $needle, $before_needle = false) ->

  if typeof $needle isnt 'string'
    $needle = String.fromCharCode(parseInt($needle, 10))

  $pos = $haystack.search(new RegExp($needle, 'i'))
  if $pos is -1
    false
  else
    if $before_needle is true
      $haystack.substr(0, $pos)
    else
      $haystack.substr($pos, $needle.length)

## --------------------------------------------------------------------

exports.strlen = ($string) ->

  $string.length

## --------------------------------------------------------------------

exports.strncmp = ($str1, $str2, $len) ->

  $str1 = $str1.substr(0, $len)
  $str2 = $str2.substr(0, $len)
  if $str1 < $str2
    -1
  else if $str1 > $str2
    1
  else
    0


## --------------------------------------------------------------------

exports.strpos = ($haystack, $needle, $offset = 0) ->

  if typeof $needle isnt 'string'
    $needle = String.fromCharCode(parseInt($needle, 10))

  $pos = $haystack.indexOf($needle, $offset)
  if $pos is -1 then false else $pos

## --------------------------------------------------------------------

exports.strrchr = ($haystack, $needle) ->

  if typeof $needle isnt 'string'
    $needle = String.fromCharCode(parseInt($needle, 10))

  $needle = $needle.charAt(0)
  $pos = $haystack.lastIndexOf($needle)
  if $pos is -1 then return false

  $haystack.substr($pos)

## --------------------------------------------------------------------

exports.strrpos = ($haystack, $needle, $offset = $haystack.length) ->

  if typeof $needle isnt 'string'
    $needle = String.fromCharCode(parseInt($needle, 10))

  $pos = $haystack.lastIndexOf($needle, $offset)
  if $pos is -1 then false else $pos

## --------------------------------------------------------------------

exports.strstr = ($haystack, $needle, $before_needle = false) ->

  if typeof $needle isnt 'string'
    $needle = String.fromCharCode(parseInt($needle, 10))

  $pos = $haystack.indexOf($needle)
  if $pos is -1
    false
  else
    if $before_needle
      $haystack.substr(0,$pos)
    else
      $haystack.substr($pos)


## --------------------------------------------------------------------

exports.strtolower = ($str) ->

  if $str?
    $str.toLowerCase()

## --------------------------------------------------------------------

exports.strtoupper = ($str) ->

  if $str?
    $str.toUpperCase()

## --------------------------------------------------------------------

exports.substr = ($string, $start, $length) ->

  $pos = $string.substr($start, $length)
  if $pos is -1 then false else $pos

## --------------------------------------------------------------------

exports.trim = ($str, $chars) ->

  ltrim(rtrim($str, $chars), $chars)


## --------------------------------------------------------------------

exports.ucfirst = ($str) ->

  $str.charAt(0).toUpperCase() + $str.substr(1)


#  ------------------------------------------------------------------------

#
# class_exists
#
# Returns true if the class has been defined
#
# @access public
# @return	boolean
#
exports.class_exists = class_exists = ($classname) -> typeof global[$classname] is 'function'

exports.function_exists = function_exists = ($funcname) -> typeof global[$funcname] is 'function'

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
exports.register_class = register_class = ($classname, $class) -> define $classname, $class

#  ------------------------------------------------------------------------

#
# get_class
#
# Returns the registered class
#
# @access public
# @return	object
#
exports.get_class = get_class = ($classname) -> global[$classname]

exports.array = ($key, $value) ->
  $array = {}
  $array[$key] = $value
  return $array



#  ------------------------------------------------------------------------
#
# Export module to the global namespace
#
#
for $name, $body of module.exports
  exports.define $name, $body

