#+--------------------------------------------------------------------+
#  inflector_helper.coffee
#+--------------------------------------------------------------------+
#  Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#
#  This file is a part of Exspresso
#
#  Exspresso is free software you can copy, modify, and distribute
#  it under the terms of the MIT License
#
#+--------------------------------------------------------------------+
#
# This file was ported from php to coffee-script using php2coffee v6.6.6
#
#


{defined, function_exists, in_array, preg_match, preg_replace, str_replace, strlen, strtolower, substr, trim, ucwords}  = require(FCPATH + 'lib')


if not defined('BASEPATH') then die 'No direct script access allowed'
#
# CodeIgniter
#
# An open source application development framework for PHP 5.1.6 or newer
#
# @package		CodeIgniter
# @author		ExpressionEngine Dev Team
# @copyright	Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license		http://codeigniter.com/user_guide/license.html
# @link		http://codeigniter.com
# @since		Version 1.0
# @filesource
#

#  ------------------------------------------------------------------------

#
# CodeIgniter Inflector Helpers
#
# @package		CodeIgniter
# @subpackage	Helpers
# @category	Helpers
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/helpers/directory_helper.html
#


#  --------------------------------------------------------------------

#
# Singular
#
# Takes a plural word and makes it singular
#
# @access	public
# @param	string
# @return	str
#
if not function_exists('singular')
  exports.singular = singular = ($str) ->
    $str = trim($str)
    $end = substr($str,  - 3)
    
    $str = preg_replace('/(.*)?([s|c]h)es/i', '$1$2', $str)
    
    if strtolower($end) is 'ies'
      $str = if substr($str, 0, strlen($str) - 3) + (preg_match('/[a-z]/', $end) then 'y' else 'Y')
      
    else if strtolower($end) is 'ses'
      $str = substr($str, 0, strlen($str) - 2)
      
    else 
      $end = strtolower(substr($str,  - 1))
      
      if $end is 's'
        $str = substr($str, 0, strlen($str) - 1)
        
      
    
    return $str
    
  

#  --------------------------------------------------------------------

#
# Plural
#
# Takes a singular word and makes it plural
#
# @access	public
# @param	string
# @param	bool
# @return	str
#
if not function_exists('plural')
  exports.plural = plural = ($str, $force = false) ->
    $str = trim($str)
    $end = substr($str,  - 1)
    
    if preg_match('/y/i', $end)
      #  Y preceded by vowel => regular plural
      $vowels = ['a', 'e', 'i', 'o', 'u', 'A', 'E', 'I', 'O', 'U']
      $str = if in_array(substr($str,  - 2, 1), $vowels) then $str + 's' else substr($str, 0,  - 1) + 'ies'
      
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
# @access	public
# @param	string
# @return	str
#
if not function_exists('camelize')
  exports.camelize = camelize = ($str) ->
    $str = 'x' + strtolower(trim($str))
    $str = ucwords(preg_replace('/[\s_]+/', ' ', $str))
    return substr(str_replace(' ', '', $str), 1)
    
  

#  --------------------------------------------------------------------

#
# Underscore
#
# Takes multiple words separated by spaces and underscores them
#
# @access	public
# @param	string
# @return	str
#
if not function_exists('underscore')
  exports.underscore = underscore = ($str) ->
    return preg_replace('/[\s]+/', '_', strtolower(trim($str)))
    
  

#  --------------------------------------------------------------------

#
# Humanize
#
# Takes multiple words separated by underscores and changes them to spaces
#
# @access	public
# @param	string
# @return	str
#
if not function_exists('humanize')
  exports.humanize = humanize = ($str) ->
    return ucwords(preg_replace('/[_]+/', ' ', strtolower(trim($str))))
    
  


#  End of file inflector_helper.php 
#  Location: ./system/helpers/inflector_helper.php 