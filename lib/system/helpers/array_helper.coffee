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
# This file was ported from CodeIgniter to coffee-script using php2coffee
#
#
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @package    Exspresso
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license    MIT License
# @link       http://darkoverlordofdata.com
# @since      Version 1.0
#

#  ------------------------------------------------------------------------

#
# Exspresso Array Helpers
#
#

#  ------------------------------------------------------------------------

#
# Element
#
# Lets you determine whether an array index is set and whether it has a value.
# If the element is empty it returns FALSE (or whatever you specify as the default value.)
#
# @access	public
# @param	string
# @param	array
# @param	mixed
# @return	mixed	depends on what the array contains
#
if not function_exists('element')
  exports.element = element = ($item, $array, $default = false) ->
    if not $array[$item]?  or $array[$item] is ""
      return $default
      
    
    return $array[$item]
    
  

#  ------------------------------------------------------------------------

#
# Random Element - Takes an array as input and returns a random element
#
# @access	public
# @param	array
# @return	mixed	depends on what the array contains
#
if not function_exists('random_element')
  exports.random_element = random_element = ($array) ->
    if not is_array($array)
      return $array
      
    
    return $array[array_rand($array)]
    
  

#  --------------------------------------------------------------------

#
# Elements
#
# Returns only the array items specified.  Will return a default value if
# it is not set.
#
# @access	public
# @param	array
# @param	array
# @param	mixed
# @return	mixed	depends on what the array contains
#
if not function_exists('elements')
  exports.elements = elements = ($items, $array, $default = false) ->
    $return = {}
    
    if not is_array($items)
      $items = [$items]
      
    
    for $item in $items
      if $array[$item]? 
        $return[$item] = $array[$item]
        
      else 
        $return[$item] = $default
        
      
    
    return $return

#  ------------------------------------------------------------------------
#
# Export helpers to the global namespace
#
#
for $name, $body of module.exports
  define $name, $body


#  End of file array_helper.php 
#  Location: ./system/helpers/array_helper.php 