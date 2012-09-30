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
# CodeIgniter Array Helpers
#
# @package		CodeIgniter
# @subpackage	Helpers
# @category	Helpers
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/helpers/array_helper.html
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
	global.element = ($item, $array, $default = FALSE) ->
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
	global.random_element = ($array) ->
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
	global.elements = ($items, $array, $default = FALSE) ->
		$return = {}
		
		if not is_array($items)
			$items = [$items]
			
		
		for $item in as
			if $array[$item]? 
				$return[$item] = $array[$item]
				
			else 
				$return[$item] = $default
				
			
		
		return $return
		
	

#  End of file array_helper.php 
#  Location: ./system/helpers/array_helper.php 