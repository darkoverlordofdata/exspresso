#+--------------------------------------------------------------------+
#  inflector_helper.coffee
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
# Exspresso Inflector Helpers
#
#

exports.is_global = true

#
# Singular
#
# Takes a plural word and makes it singular
#
# @param  [String]
# @return	[String]
#
exports.singular = ($str) ->
  $str = trim($str)
  $end = $str.substr(-3)

  $str = $str.replace(/(.*)?([s|c]h)es/i, '$1$2')

  if $end.toLowerCase() is 'ies'
    $str = $str.substr(0, $str.length - 3) + if (preg_match('/[a-z]/', $end)) then 'y' else 'Y'

  else if $end.toLowerCase() is 'ses'
    $str = $str.substr(0, $str.length - 2)

  else
    $end = $str.substr(-1).toLowerCase()

    if $end is 's'
      $str = $str.substr(0, $str.length - 1)

  return $str


#
# Plural
#
# Takes a singular word and makes it plural
#
# @param  [String]
# @return	[Boolean]
# @return	str
#
exports.plural = ($str, $force = false) ->
  $str = trim($str)
  $end = $str.substr(- 1)

  if $end is 'y' or $end is 'Y'
    #  Y preceded by vowel => regular plural
    $vowels = ['a', 'e', 'i', 'o', 'u', 'A', 'E', 'I', 'O', 'U']
    $str = if $vowels.indexOf($str.substr(-2, 1)) isnt -1 then $str + 's' else $str.substr(0, -1) + 'ies'

  else if $end is 'h' or $end is 'H'
    if /^[c|s]h$/i.test($str.substr(-2))
      $str+='es'
    else
      $str+='s'

  else if $end is 's' or $end is 'S'
    if $force is true
      $str+='es'

  else
    $str+='s'

  return $str



#
# Camelize
#
# Takes multiple words separated by spaces or underscores and camelizes them
#
# @param  [String]
# @return	str
#
exports.camelize = camelize = ($str) ->
  $str = 'x' + trim($str.toLowerCase())
  $str = ucwords($str.replace(/[\s_]+/, ' '))
  $str.substr(1).replace(/\s/g, '')



#
# Underscore
#
# Takes multiple words separated by spaces and underscores them
#
# @param  [String]
# @return	str
#
exports.underscore = ($str) ->
  trim($str).toLowerCase().replace(/[\s]+/g, '_')



#
# Humanize
#
# Takes multiple words separated by underscores and changes them to spaces
#
# @param  [String]  # @return	str
#
exports.humanize = ($str) ->
  trim($str).toLowerCase().replace(/[_]+/g, ' ')


#  ------------------------------------------------------------------------
#
# Export helpers to the global namespace
#
#
#for $name, $body of module.exports
#  exports.define $name, $body
