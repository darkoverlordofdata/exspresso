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
util            = require('util')                       # misc
crypto          = require('crypto')


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


#exports._classes = _classes = {}                        # class registry

exports.die = ($message) ->
  console.log $message
  process.exit 1


exports.array_diff = ($array1, $array2) ->

  $ret = []
  for $val in $array1
    if $array2.indexOf($val) is -1 then $ret.push $val
  $ret

## --------------------------------------------------------------------

exports.array_keys = array_keys = ($input, $search = null) ->

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

exports.array_merge = array_merge = ($array1, $array2) ->

  $ret = {}
  for $key, $item of $array1
    $ret[$key] = $item
  for $key, $item of $array2
    $ret[$key] = $item
  return $ret

## --------------------------------------------------------------------

exports.array_merge_recursive = array_merge_recursive = ($array1, $array2) ->

  $ret = {}
  for $key, $item of $array1
    $ret[$key] = $item
  for $key, $item of $array2
    if typeof $array1[$key] is 'object' or typeof $item is 'object'
      $ret[$key] = array_merge($array1[$key], $item)
    else
      $ret[$key] = $item
  return $ret

## --------------------------------------------------------------------

exports.array_pad = ($input, $pad_size, $pad_value) ->

  if $input.length < $pad_size
    $start = $input.length
    for $i in [$start..$pad_size-1]
      $input[$i] = $pad_value

  $input


__push = [].push
exports.array_push = ($array, $var...) ->

  __push.apply $array, $var

# ----------------------------------------------------------

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

exports.call_user_func = ($callback, $parameter...) ->

  if Array.isArray($callback)
    $object = $callback[0]
    $method = $callback[1]
  else
    $object = global
    $method = $callback
  $object[$method].apply($object, $parameter)

## --------------------------------------------------------------------

exports.call_user_func_array = ($callback, $param_arr) ->

  if Array.isArray($callback)
    $object = $callback[0]
    $method = $callback[1]
  else
    $object = global
    $method = $callback
  $object[$method].apply($object, $param_arr)

## --------------------------------------------------------------------

exports.count = count = ($var) ->

  if $var is null
    return 0

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

exports.empty = ($var) ->

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
        if count($var) is 0 then false else true
    else false

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

exports.number_format = ($number, $decimals = 0, $dec_point = '.', $thousands_sep = ',') ->

  $format = format(seperator: $thousands_sep, decimal: $dec_point, padRight: $decimals, truncate: $decimals)
  $format($number)

## --------------------------------------------------------------------

exports.file_exists = file_exists = fs.existsSync || path.existsSync

#exports.file_exists = file_exists = ($path) ->

  #if fs.existsSync?
  #  fs.existsSync($path)
  #else
  #  path.existsSync($path)

## --------------------------------------------------------------------

exports.implode = ($glue, $pieces = null) ->

  if $pieces is null
    $pieces = $glue
    $glue = ''

  if Array.isArray($pieces)
    $pieces.join($glue)
  else
    $ret = []
    for $key, $val of $pieces
      $ret.push $val
    $ret.join($glue)

## --------------------------------------------------------------------

exports.in_array = ($needle, $haystack, $strict = false) ->

  $pos = $haystack.indexOf($needle)
  if $pos is -1 then return false
  if $strict
    if typeof $needle is typeof $haystack[$pos] then true else false
  else
    true

## --------------------------------------------------------------------

exports.is_array = ($var) ->

  if typeof $var is 'object'
    if $var is null then false else true
  else
    false

## --------------------------------------------------------------------

exports.is_bool = ($var) ->

  if typeof $var is 'boolean' then true else false

## --------------------------------------------------------------------

exports.is_callable = ($class, $method) ->

  $def = global[$class]
  if typeof $def is 'function'
    if typeof $def.__proto__[$method] is method
      true
  false


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

exports.microtime = ($get_as_float = false) ->

  $now = new Date().getTime() / 1000
  $sec = parseInt($now, 10)

  ''+ if $get_as_float then $now else (Math.round(($now - $sec) * 1000) / 1000) + ' ' + $sec

## --------------------------------------------------------------------

exports.mt_rand = ($min = 0, $max = 2147483647) ->

  Math.floor(Math.random() * $max) - $min

exports.rand = ($min = 0, $max = 2147483647) ->

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


exports.PATHINFO_DIRNAME    = PATHINFO_DIRNAME    = 1
exports.PATHINFO_BASENAME   = PATHINFO_BASENAME   = 2
exports.PATHINFO_EXTENSION  = PATHINFO_EXTENSION  = 4
exports.PATHINFO_FILENAME   = PATHINFO_FILENAME   = 8

exports.pathinfo = ($path, $options = PATHINFO_DIRNAME | PATHINFO_BASENAME | PATHINFO_EXTENSION | PATHINFO_FILENAME) ->

  $result = {}

  if ($options & PATHINFO_DIRNAME) is PATHINFO_DIRNAME
    $result['dirname'] = path.dirname($path)
    return $result['dirname'] if $options is PATHINFO_DIRNAME

  if ($options & PATHINFO_BASENAME) is PATHINFO_BASENAME
    $result['basename'] = path.basename($path)
    return $result['basename'] if $options is PATHINFO_BASENAME

  if ($options & PATHINFO_EXTENSION) is PATHINFO_EXTENSION
    $result['extension'] = path.extname($path)
    return $result['extension'] if $options is PATHINFO_EXTENSION

  if ($options & PATHINFO_FILENAME) is PATHINFO_FILENAME
    $result['filename'] = path.basename($path, path.extname($path))
    return $result['filename'] if $options is PATHINFO_FILENAME

  return $result




## --------------------------------------------------------------------

exports.preg_quote = ($str, $delimiter = '') ->

  $array = $str.split('')
  for $i, $char of $array
    if ".\+*?[^]$(){}=!<>|:-".indexOf($char) isnt -1
      $array[$i] = "\\"+$char
  $array.join()

## --------------------------------------------------------------------

exports.preg_match = ($pattern, $subject) ->

  $regex = createRegExp($pattern)
  $subject.match($regex)


## --------------------------------------------------------------------

exports.preg_match_all = ($pattern, $subject) ->

  $regex = createRegExp($pattern)
  $matches = []
  while ($match = $regex.exec($subject)) isnt null
    $matches.push $match
  $matches



## --------------------------------------------------------------------

exports.preg_replace = ($pattern, $replacement, $subject, $limit = -1) ->


  $regex = createRegExp($pattern)
  $subject.replace($regex,$replacement)

## --------------------------------------------------------------------

exports.rawurldecode = ($str) ->

  querystring.unescape($str)

## --------------------------------------------------------------------

exports.realpath = ($path) ->

  if file_exists($path)
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

exports.method_exists = method_exists = ($object, $method_name) -> typeof $object[$method_name] is 'function'

exports.stripslashes = stripslashes = ($str) ->
  return ($str + '').replace /\\(.?)/g, ($s, $p) ->
    switch $p
      when '\\' then '\\'
      when '0'  then '\u0000'
      when ''   then ''
      else $p

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


exports.htmlspecialchars = ($str) ->

  (''+$str).replace("&", "&amp;").replace("'", "&#39;").replace('"', "&quot;").replace("<", "&lt;").replace(">", "&gt;")

exports.CASE_LOWER = CASE_LOWER = 0
exports.CASE_UPPER = CASE_UPPER = 1

exports.array_change_key_case = ($input, $case = CASE_LOWER) ->

  $ret = {}
  for $key, $val of $input
    if $case = CASE_LOWER
      $ret[$key.toLowerCase()] = $val
    else if $case = CASE_UPPER
      $ret[$key.toUpperCase()] = $val
  $ret

exports.array_key_exists = ($key, $search) ->
  $search[$key]?

exports.get_object_vars = ($object) ->
  $res = {}
  for $key, $val of $object
    if $key.substr(0,1) isnt '_' and typeof $object[$key] isnt 'function'
      $res[$key] = $val
  $res


exports.sprintf = require('sprintf').sprintf
exports.glob = require('glob').sync
exports.basename = require('path').basename
exports.sort = ($array) ->
  $array.sort()
  true

exports.ksort = ($array) ->

  $keys = Object.keys($array)
  $copy = {}
  for $key in $keys
    $copy[$key] = $array[$key]
    delete $array[$key]
  $keys.sort()
  for $key in $keys
    $array[$key] = $copy[$key]
  true

exports.memory_get_usage = ($real_usage = false) ->

  if $real_usage
    process.memoryUsage().heapTotal
  else
    process.memoryUsage().heapUsed

exports.round = ($val, $precision = 0) ->

  if $precision is 0
    Math.round($val)
  else
    Math.round($val*Math.pow(10,$precision)) / Math.pow(10,$precision)

exports.print_r = ($expression, $return = false) ->

  if $return is true
    util.inspect($expression)

exports.ucwords = ($str) ->

  ''+$str.replace /^([a-z\u00E0-\u00FC])|\s+([a-z\u00E0-\u00FC])/g, ($1) -> $1.toUpperCase()


exports.wordwrap = ($string, $width=75, $break="\n", $cut=false) ->

  if $cut
    # Match anything 1 to $width chars long followed by whitespace or EOS,
    # otherwise match anything $width chars long
    $search = '/(.{1,'+$width+'})(?:\s|$)|(.{'+$width+'})/uS'
    $replace = '$1$2'+$break
  else
    # Anchor the beginning of the pattern with a lookahead
    # to avoid crazy backtracking when words are longer than $width
    $search = '/(?=\s)(.{1,'+$width+'})(?:\s|$)/uS'
    $replace = '$1'+$break

  preg_replace($search, $replace, $string)


exports.md5 = ($str, $raw_output = false) ->
  if $raw_output is true
    crypto.createHash('md5').update($str).digest("binary")
  else
    crypto.createHash('md5').update($str).digest("hex")

exports.sha1 = ($str, $raw_output = false) ->
  if $raw_output is true
    crypto.createHash('sha1').update($str).digest("binary")
  else
    crypto.createHash('sha1').update($str).digest("hex")


exports.gettype = ($var) -> typeof $var


exports.ip2long = ($ip_address) ->
  $ip = array_pad(explode('.', $ip_address), 4, 0)
  $l = 0
  for $i in [0..3]
    $l = ($l * 256) + $ip[$i]
  $l

exports.uniqid = ($prefix = '', $more_entropy = false) ->

  $res = $prefix + (new Date().getTime()).toString(16)+(Math.floor(Math.random() * 256)).toString(16)
  if $more_entropy is true
    $res += (Math.random() * 10).toFixed(8).toString()
  return $res


#  ------------------------------------------------------------------------
#
# Export module to the global namespace
#
#
for $name, $body of module.exports
  exports.define $name, $body

