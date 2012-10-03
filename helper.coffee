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

## --------------------------------------------------------------------

#
# is_dir — check if path is a folder
#
#	@param	string	The path being checked
# @returns true or false
#
exports.is_dir = ($path) ->

  try
    $stats = fs.statSync($path)
    $b = $stats.isDirectory()
  catch ex
    $b = false
  finally
    return $b

## --------------------------------------------------------------------

#
# realpath — Returns canonicalized absolute pathname
#
#	@param	string	The path being checked
# @returns the canonicalized absolute pathname
#
exports.realpath = ($path) ->

  if fs.existsSync($path)
    return fs.realpathSync($path)
  else
    return false

## --------------------------------------------------------------------

#
# file_exists — check file system
#
#	@param	string	The path being checked
# @returns true or false
#
exports.file_exists = ($path) ->

  fs.existsSync($path)

## --------------------------------------------------------------------

#
# array_merge — Merge one or more arrays.
#
#	@param	object	array to merge
#	@param	object	array to merge
# @returns merged hash
#
exports.array_merge = ($array1, $array2) ->

  $ret = {}
  for $key, $item of $array1
    $ret[$key] = $item
  for $key, $item of $array2
    $ret[$key] = $item
  $ret

## --------------------------------------------------------------------

#
# trim — Strip chars from both ends of a string.
#
#	@param	string	string to replace in
#	@param	string	chars list
# @returns string with chars removed
#
exports.trim = ($str, $chars) ->
  ltrim(rtrim($str, $chars), $chars)

## --------------------------------------------------------------------

#
# ltrim — Strip chars from end of a string.
#
#	@param	string	string to replace in
#	@param	string	chars list
# @returns string with chars removed
#
exports.ltrim = ltrim = ($str, $chars) ->
  $chars = $chars || "\s";
  $str.replace(new RegExp("^[" + $chars + "]+", "g"), "")

## --------------------------------------------------------------------

#
# rtrim — Strip chars from beginning of a string.
#
#	@param	string	string to replace in
#	@param	string	chars list
# @returns string with chars removed
#
exports.rtrim = rtrim = ($str, $chars) ->
  $chars = $chars || "\s";
  $str.replace(new RegExp("[" + $chars + "]+$", "g"), "")

## --------------------------------------------------------------------

#
# ucfirst — Make a string's first character uppercase.
#
#	@param	string	sting to change
# @returns changed string
#
exports.ucfirst = ($str) ->
  $str.charAt(0).toUpperCase() + $str.substr(1)

exports.dirname = ($str) ->
  path.dirname($str)

exports.strrchr = ($haystack, $needle) ->

  if typeof $needle isnt 'string'
    $needle = String.fromCharCode(parseInt($needle, 10))

  $needle = $needle.charAt(0)
  $pos = $haystack.lastIndexOf($needle)
  if $pos is -1 then return false

  $haystack.substr($pos)

exports.count = ($var) ->

  if typeof $var is 'string' or typeof $var is 'number' or typeof $var is 'boolean'
    return 1

  if typeof $var isnt 'object'
    return 0

  Object.keys($var).length

exports.is_string = ($var) ->

  if typeof $var is 'string' then true else false

exports.is_array = ($var) ->

  if typeof $var is 'object' then true else false

exports.is_null = ($var) ->

  if $var is null or typeof $var is 'undefined' then true else false


exports.strpos = ($haystack, $needle, $offset = 0) ->

  if typeof $needle isnt 'string'
    $needle = String.fromCharCode(parseInt($needle, 10))

  $pos = $haystack.indexOf($needle, $offset)
  if $pos is -1 then false else $pos

exports.strrpos = ($haystack, $needle, $offset = 0) ->

  if typeof $needle isnt 'string'
    $needle = String.fromCharCode(parseInt($needle, 10))

  $pos = $haystack.lastIndexOf($needle, $offset)
  if $pos is -1 then false else $pos

exports.substr = ($string, $start, $length) ->

  $pos = $string.substr($start, $length)
  if $pos is -1 then false else $pos

exports.in_array = ($needle, $haystack, $strict = false) ->

  $pos = $haystack.indexOf($needle)
  if $pos is -1 then return false
  if $strict
    if typeof $needle is typeof $haystack[$pos] then $pos else false
  else
    $pos


exports.strtolower = ($str) ->
  $str.toLowerCase()

exports._classes = _classes = {}
exports.class_exists = ($class_name) ->
  _classes[$class_name]?


exports.is_object = ($var) ->

  if typeof $var is 'object' then true else false

exports.array_unshift = ($array, $var...) ->

  Array::unshift.apply($array, $var)

exports.array_shift = ($array) ->

  $array.shift()

exports.explode = ($delimiter, $string, $limit) ->

  $string.split($delimiter, $limit)

exports.implode = ($glue, $pieces = null) ->

  if $pieces = null
    $pieces = $glue
    $glue = ''

  $pieces.join($glue)

exports.str_replace = ($search, $replace, $subject) ->

  $subject.replace($search, $replace)


exports.exit = exit = ($status = 0) ->

  if typeof $status is 'number'
    process.exit $status
  else
    console.log $status
    process.exit 1

exports.die = exit

exports.is_array = ($var) ->

  Array.isArray($var)
