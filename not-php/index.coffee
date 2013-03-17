#+--------------------------------------------------------------------+
#| index.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of not-php
#|
#| Not-php is free software; you can copy, modify, and distribute
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
crypto          = require('crypto')                     # super secret stuff


exports.define = (name, value, scope = global) ->

  if scope[name]?
    return false # already defined

  Object.defineProperty scope, name,
    'value':			value
    'enumerable': true
    'writable':		false

  return true # success


## --------------------------------------------------------------------

exports.explode = ($delimiter, $string, $limit) ->

  $string.split($delimiter, $limit)


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


exports.is_bool = ($var) ->

  if typeof $var is 'boolean' then true else false

## --------------------------------------------------------------------


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


createRegExp = ($pattern) ->

  $delim = $pattern.charAt(0)
  $end = $pattern.lastIndexOf($delim)
  $flags = $pattern.substr($end+1)
  $pattern = $pattern.substr(1, $end-1)
  new RegExp($pattern, $flags)




## --------------------------------------------------------------------

exports.PREG_SPLIT_NO_EMPTY       = 1
exports.PREG_SPLIT_DELIM_CAPTURE  = 2
exports.PREG_SPLIT_OFFSET_CAPTURE = 4

exports.preg_split = ($pattern, $subject, $limit = -1, $flags = 0) ->

  if $flags & PREG_SPLIT_OFFSET_CAPTURE
    throw new Error('Unsupported feature: PREG_SPLIT_OFFSET_CAPTURE')

  $result = $subject.split(createRegExp($pattern), $limit)

  # PREG_SPLIT_DELIM_CAPTURE is the standard behaviour in js
  # to disable this, just don't use capture...
  if $flags & PREG_SPLIT_NO_EMPTY
    $item for $item in $result when $item?
  else
    $result

## --------------------------------------------------------------------

exports.preg_match = ($pattern, $subject) ->

  $regex = createRegExp($pattern)
  $subject.match($regex)


## --------------------------------------------------------------------

exports.PREG_PATTERN_ORDER    = 1
exports.PREG_SET_ORDER        = 2
exports.PREG_OFFSET_CAPTURE   = 4

exports.preg_match_all = ($pattern, $subject, $z, $flags) ->

  $regex = createRegExp($pattern)
  $matches = []
  while ($match = $regex.exec($subject)) isnt null
    $matches.push $match

  return $matches if $flags is PREG_SET_ORDER

  $x = $matches[0].length
  $y = $matches[0][0].length
  $result = []
  for $i in [0...$y]
    $result.push []
    for $j in [0..$x]
      $result[$i].push $matches[$j][$i]
  $result


exports.preg_replace_callback = ($pattern, $callback, $subject, $limit = -1) ->

  $re = createRegExp($pattern)
  if typeof $callback is 'string'
    $func = global[$callback]
  else
    $object = $callback[0]
    $method = $callback[1]
    $func = $object[$method]

  $subject.replace($re, $func, $limit)

## --------------------------------------------------------------------

exports.preg_replace = ($pattern, $replacement, $subject, $limit = -1) ->


  $regex = createRegExp($pattern)
  $subject.replace($regex,$replacement)
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

#exports.stristr = ($haystack, $needle, $before_needle = false) ->
#
#  if typeof $needle isnt 'string'
#    $needle = String.fromCharCode(parseInt($needle, 10))
#
#  $pos = $haystack.search(new RegExp($needle, 'i'))
#  if $pos is -1
#    false
#  else
#    if $before_needle is true
#      $haystack.substr(0, $pos)
#    else
#      $haystack.substr($pos, $needle.length)
#
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

#exports.strrchr = ($haystack, $needle) ->
#
#  if typeof $needle isnt 'string'
#    $needle = String.fromCharCode(parseInt($needle, 10))
#
#  $needle = $needle.charAt(0)
#  $pos = $haystack.lastIndexOf($needle)
#  if $pos is -1 then return false
#
#  $haystack.substr($pos)

## --------------------------------------------------------------------

#exports.strrpos = ($haystack, $needle, $offset = $haystack.length) ->
#
#  if typeof $needle isnt 'string'
#    $needle = String.fromCharCode(parseInt($needle, 10))
#
#  $pos = $haystack.lastIndexOf($needle, $offset)
#  if $pos is -1 then false else $pos

## --------------------------------------------------------------------

#exports.strstr = ($haystack, $needle, $before_needle = false) ->
#
#  if typeof $needle isnt 'string'
#    $needle = String.fromCharCode(parseInt($needle, 10))
#
#  $pos = $haystack.indexOf($needle)
#  if $pos is -1
#    false
#  else
#    if $before_needle
#      $haystack.substr(0,$pos)
#    else
#      $haystack.substr($pos)
#

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


#  ------------------------------------------------------------------------
#
# Export module to the global namespace
#
#
exports.export = ($scope = global, $extra = {}) ->

  for $name, $body of module.exports
    exports.define $name, $body, $scope unless $extra[$name]?

  for $name, $body of $extra
    exports.define $name, $body, $scope

  Object.defineProperties $scope,
    $_ENV:    get: -> process.env
    $argv:    get: -> process.argv
    $argc:    get: -> process.argv.length

  return

