#+--------------------------------------------------------------------+
#  array_helper.coffee
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
# Exspresso Array Helpers
#
#

#
# Element
#
# Lets you determine whether an array index is set and whether it has a value.
# If the element is empty it returns FALSE (or whatever you specify as the default value.)
#
# @param  [String]
# @param  [Array]
# @param  [Mixed]
# @return [Mixed]  depends on what the array contains
#
exports.element = ($item, $array, $default = false) ->
  if not $array[$item]?  or $array[$item] is ""
    return $default
  return $array[$item]



#
# Random Element - Takes an array as input and returns a random element
#
# @param  [Array]
# @return [Mixed]  depends on what the array contains
#
exports.random_element = ($array) ->
  if 'object' isnt typeof($array)
    return $array

  if Array.isArray($array)
    $array[rand(0, $array.length)]

  else
    $keys = Object.keys($array)
    $array[$keys[rand(0, $keys.length)]]


#
# Elements
#
# Returns only the array items specified.  Will return a default value if
# it is not set.
#
# @param  [Array]
# @param  [Array]
# @param  [Mixed]
# @return [Mixed]  depends on what the array contains
#
exports.elements = ($items, $array, $default = false) ->
  $return = {}

  if not Array.isArray($items)
    $items = [$items]

  for $item in $items
    if $array[$item]?
      $return[$item] = $array[$item]

    else
      $return[$item] = $default

  return $return

