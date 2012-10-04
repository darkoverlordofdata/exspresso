#+--------------------------------------------------------------------+
#| helper.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the GNU General Public License Version 3
#|
#+--------------------------------------------------------------------+
#
#	helper - core PHP-apish helpers
#
fs              = require('fs')                         # Standard POSIX file i/o
path            = require('path')                       # File path utilities

exports._classes = _classes = {}

## --------------------------------------------------------------------

exports.array_merge = ($array1, $array2) ->

  $ret = {}
  for $key, $item of $array1
    $ret[$key] = $item
  for $key, $item of $array2
    $ret[$key] = $item
  $ret

## --------------------------------------------------------------------

exports.array_shift = ($array) ->

  $array.shift()

## --------------------------------------------------------------------

exports.array_unshift = ($array, $var...) ->

  Array::unshift.apply($array, $var)

## --------------------------------------------------------------------

exports.class_exists = ($class_name) ->

  _classes[$class_name]?

## --------------------------------------------------------------------

exports.count = ($var) ->

  if typeof $var is 'string' or typeof $var is 'number' or typeof $var is 'boolean'
    return 1

  if typeof $var isnt 'object'
    return 0

  Object.keys($var).length

## --------------------------------------------------------------------

exports.dirname = ($str) ->

  path.dirname($str)

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

exports.is_object = ($var) ->

  if typeof $var is 'object' then true else false

## --------------------------------------------------------------------

exports.is_string = ($var) ->

  if typeof $var is 'string' then true else false


## --------------------------------------------------------------------

exports.ltrim = ltrim = ($str, $chars) ->
  $chars = $chars || "\s";
  $str.replace(new RegExp("^[" + $chars + "]+", "g"), "")

## --------------------------------------------------------------------

exports.realpath = ($path) ->

  if fs.existsSync($path)
    return fs.realpathSync($path)
  else
    return false

## --------------------------------------------------------------------

exports.rtrim = rtrim = ($str, $chars) ->
  $chars = $chars || "\s";
  $str.replace(new RegExp("[" + $chars + "]+$", "g"), "")

## --------------------------------------------------------------------

exports.str_replace = ($search, $replace, $subject) ->

  $subject.replace($search, $replace)

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

exports.strtolower = ($str) ->

  $str.toLowerCase()

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







