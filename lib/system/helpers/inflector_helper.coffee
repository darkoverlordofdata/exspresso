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
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @see        http://darkoverlordofdata.com
# @since      Version 1.0
#

#  ------------------------------------------------------------------------

#
# Exspresso Inflector Helpers
#
#


#  --------------------------------------------------------------------

#
# Singular
#
# Takes a plural word and makes it singular
#
# @param  [String]  # @return	str
#
if not function_exists('singular')
  exports.singular = singular = ($str) ->
    $str = trim($str)
    $end = substr($str,  - 3)
    
    $str = preg_replace('/(.*)?([s|c]h)es/i', '$1$2', $str)
    
    if $end.toLowerCase() is 'ies'
      $str = if substr($str, 0, strlen($str) - 3) + (preg_match('/[a-z]/', $end)) then 'y' else 'Y'
      
    else if $end.toLowerCase() is 'ses'
      $str = substr($str, 0, strlen($str) - 2)
      
    else 
      $end = substr($str.toLowerCase(),  - 1)
      
      if $end is 's'
        $str = substr($str, 0, strlen($str) - 1)
        
      
    
    return $str
    
  

#  --------------------------------------------------------------------

#
# Plural
#
# Takes a singular word and makes it plural
#
# @param  [String]  # @return	[Boolean]
# @return	str
#
if not function_exists('plural')
  exports.plural = plural = ($str, $force = false) ->
    $str = trim($str)
    $end = substr($str,  - 1)
    
    if preg_match('/y/i', $end)
      #  Y preceded by vowel => regular plural
      $vowels = ['a', 'e', 'i', 'o', 'u', 'A', 'E', 'I', 'O', 'U']
      $str = if $vowels.indexOf(substr($str,  - 2, 1)) isnt -1 then $str + 's' else substr($str, 0,  - 1) + 'ies'
      
    else if preg_match('/h/i', $end)
      if preg_match('/^[c|s]h$/i', substr($str,  - 2))
        $str+='es'
        
      else 
        $str+='s'
        
      
    else if preg_match('/s/i', $end)
      if $force is true
        $str+='es'
        
      
    else 
      $str+='s'
      
    
    return $str
    
  

#  --------------------------------------------------------------------

#
# Camelize
#
# Takes multiple words separated by spaces or underscores and camelizes them
#
# @param  [String]  # @return	str
#
if not function_exists('camelize')
  exports.camelize = camelize = ($str) ->
    $str = 'x' + trim($str.toLowerCase())
    $str = ucwords(preg_replace('/[\s_]+/', ' ', $str))
    return substr(str_replace(' ', '', $str), 1)
    
  

#  --------------------------------------------------------------------

#
# Underscore
#
# Takes multiple words separated by spaces and underscores them
#
# @param  [String]  # @return	str
#
if not function_exists('underscore')
  exports.underscore = underscore = ($str) ->
    return preg_replace('/[\s]+/', '_', trim($str.toLowerCase()))
    
  

#  --------------------------------------------------------------------

#
# Humanize
#
# Takes multiple words separated by underscores and changes them to spaces
#
# @param  [String]  # @return	str
#
if not function_exists('humanize')
  exports.humanize = humanize = ($str) ->
    return ucwords(preg_replace('/[_]+/', ' ', trim($str.toLowerCase())))


#  ------------------------------------------------------------------------
#
# Export helpers to the global namespace
#
#
for $name, $body of module.exports
  exports.define $name, $body



#  End of file inflector_helper.php 
#  Location: ./system/helpers/inflector_helper.php 