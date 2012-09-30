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
# CodeIgniter String Helpers
#
# @package		CodeIgniter
# @subpackage	Helpers
# @category	Helpers
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/helpers/string_helper.html
#

#  ------------------------------------------------------------------------

#
# Trim Slashes
#
# Removes any leading/trailing slashes from a string:
#
# /this/that/theother/
#
# becomes:
#
# this/that/theother
#
# @access	public
# @param	string
# @return	string
#
if not function_exists('trim_slashes')
	global.trim_slashes = ($str) ->
		return trim($str, '/')
		
	

#  ------------------------------------------------------------------------

#
# Strip Slashes
#
# Removes slashes contained in a string or in an array
#
# @access	public
# @param	mixed	string or array
# @return	mixed	string or array
#
if not function_exists('strip_slashes')
	global.strip_slashes = ($str) ->
		if is_array($str)
			for $val, $key in as
				$str[$key] = strip_slashes($val)
				
			
		else 
			$str = stripslashes($str)
			
		
		return $str
		
	

#  ------------------------------------------------------------------------

#
# Strip Quotes
#
# Removes single and double quotes from a string
#
# @access	public
# @param	string
# @return	string
#
if not function_exists('strip_quotes')
	global.strip_quotes = ($str) ->
		return str_replace(['"', "'"], '', $str)
		
	

#  ------------------------------------------------------------------------

#
# Quotes to Entities
#
# Converts single and double quotes to entities
#
# @access	public
# @param	string
# @return	string
#
if not function_exists('quotes_to_entities')
	global.quotes_to_entities = ($str) ->
		return str_replace(["\'", "\"", "'", '"'], ["&#39;", "&quot;", "&#39;", "&quot;"], $str)
		
	

#  ------------------------------------------------------------------------

#
# Reduce Double Slashes
#
# Converts double slashes in a string to a single slash,
# except those found in http://
#
# http://www.some-site.com//index.php
#
# becomes:
#
# http://www.some-site.com/index.php
#
# @access	public
# @param	string
# @return	string
#
if not function_exists('reduce_double_slashes')
	global.reduce_double_slashes = ($str) ->
		return preg_replace("#(^|[^:])//+#", "\\1/", $str)
		
	

#  ------------------------------------------------------------------------

#
# Reduce Multiples
#
# Reduces multiple instances of a particular character.  Example:
#
# Fred, Bill,, Joe, Jimmy
#
# becomes:
#
# Fred, Bill, Joe, Jimmy
#
# @access	public
# @param	string
# @param	string	the character you wish to reduce
# @param	bool	TRUE/FALSE - whether to trim the character from the beginning/end
# @return	string
#
if not function_exists('reduce_multiples')
	global.reduce_multiples = ($str, $character = ',', $trim = FALSE) ->
		$str = preg_replace('#' + preg_quote($character, '#') + '{2,}#', $character, $str)
		
		if $trim is TRUE
			$str = trim($str, $character)
			
		
		return $str
		
	

#  ------------------------------------------------------------------------

#
# Create a Random String
#
# Useful for generating passwords or hashes.
#
# @access	public
# @param	string	type of random string.  basic, alpha, alunum, numeric, nozero, unique, md5, encrypt and sha1
# @param	integer	number of characters
# @return	string
#
if not function_exists('random_string')
	global.random_string = ($type = 'alnum', $len = 8) ->
		switch $type
			when 'basic'return mt_rand()
				
			when 'alnum','numeric','nozero','alpha'
				
				switch $type
					when 'alpha'$pool = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
						
					when 'alnum'$pool = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
						
					when 'numeric'$pool = '0123456789'
						
					when 'nozero'$pool = '123456789'
						
						
				
				$str = ''
				($i = 0$i < $len$i++)
				{
				$str+=substr($pool, mt_rand(0, strlen($pool) - 1), 1)
				}
				return $str
				
			when 'unique','md5'
				
				return md5(uniqid(mt_rand()))
				
			when 'encrypt','sha1'
				
				$CI = get_instance()
				$CI.load.helper('security')
				
				return do_hash(uniqid(mt_rand(), TRUE), 'sha1')
				
				
		
	

#  ------------------------------------------------------------------------

#
# Alternator
#
# Allows strings to be alternated.  See docs...
#
# @access	public
# @param	string (as many parameters as needed)
# @return	string
#
if not function_exists('alternator')
	global.alternator =  ->
		global.$i = global.$i ? {}
		
		if func_num_args() is 0
			$i = 0
			return ''
			
		$args = func_get_args()
		return $args[($i++count($args))]
		
	

#  ------------------------------------------------------------------------

#
# Repeater function
#
# @access	public
# @param	string
# @param	integer	number of repeats
# @return	string
#
if not function_exists('repeater')
	global.repeater = ($data, $num = 1) ->
		return if (($num > 0) then str_repeat($data, $num) else '')
		
	


#  End of file string_helper.php 
#  Location: ./system/helpers/string_helper.php 