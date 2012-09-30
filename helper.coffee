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

## --------------------------------------------------------------------

#
# is_dir — check if path is a folder
#
#	@param	string	The path being checked
# @returns true or false
#
exports.is_dir = (path) ->

  try
    stats = fs.statSync(path)
    b = stats.isDirectory()
  catch ex
    b = false
  finally
    return b

## --------------------------------------------------------------------

#
# realpath — Returns canonicalized absolute pathname
#
#	@param	string	The path being checked
# @returns the canonicalized absolute pathname
#
exports.realpath = (path) ->

  if fs.existsSync(path)
    return fs.realpathSync(path)
  else
    return false

## --------------------------------------------------------------------

#
# file_exists — check file system
#
#	@param	string	The path being checked
# @returns true or false
#
exports.file_exists = (path) ->

  return fs.existsSync(path)

## --------------------------------------------------------------------

#
# array_merge — Merge one or more arrays.
#
#	@param	object	array to merge
#	@param	object	array to merge
# @returns merged hash
#
exports.array_merge = (array1, array2) ->

  #ret = Object.create(__proto__: array1)
  #ret = {__proto__: array1}
  ret = {}
  for key, item of array1
    ret[key] = item
  for key, item of array2
    ret[key] = item
  return ret

## --------------------------------------------------------------------

#
# trim — Strip chars from both ends of a string.
#
#	@param	string	string to replace in
#	@param	string	chars list
# @returns string with chars removed
#
exports.trim = (str, chars) ->
  return ltrim(rtrim(str, chars), chars)

## --------------------------------------------------------------------

#
# ltrim — Strip chars from end of a string.
#
#	@param	string	string to replace in
#	@param	string	chars list
# @returns string with chars removed
#
exports.ltrim = (str, chars) ->
  chars = chars || "\s";
  return str.replace(new RegExp("^[" + chars + "]+", "g"), "")

## --------------------------------------------------------------------

#
# rtrim — Strip chars from beginning of a string.
#
#	@param	string	string to replace in
#	@param	string	chars list
# @returns string with chars removed
#
exports.rtrim = (str, chars) ->
  chars = chars || "\s";
  return str.replace(new RegExp("[" + chars + "]+$", "g"), "")

## --------------------------------------------------------------------

#
# ucfirst — Make a string's first character uppercase.
#
#	@param	string	sting to change
# @returns changed string
#
exports.ucfirst = (str) ->
  return str.charAt(0).toUpperCase() + str.substr(1)