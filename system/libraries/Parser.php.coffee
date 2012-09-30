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
# Parser Class
#
# @package		CodeIgniter
# @subpackage	Libraries
# @category	Parser
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/libraries/parser.html
#
class CI_Parser
	
	$l_delim: '{'
	$r_delim: '}'
	$object: {}
	
	#
	#  Parse a template
	#
	# Parses pseudo-variables contained in the specified template view,
	# replacing them with the data in the second param
	#
	# @access	public
	# @param	string
	# @param	array
	# @param	bool
	# @return	string
	#
	parse($template, $data, $return = FALSE)
	{
	$CI = get_instance()
	$template = $CI.load.view($template, $data, TRUE)
	
	return @._parse($template, $data, $return)
	}
	
	#  --------------------------------------------------------------------
	
	#
	#  Parse a String
	#
	# Parses pseudo-variables contained in the specified string,
	# replacing them with the data in the second param
	#
	# @access	public
	# @param	string
	# @param	array
	# @param	bool
	# @return	string
	#
	parse_string : ($template, $data, $return = FALSE) =>
		return @._parse($template, $data, $return)
		
	
	#  --------------------------------------------------------------------
	
	#
	#  Parse a template
	#
	# Parses pseudo-variables contained in the specified template,
	# replacing them with the data in the second param
	#
	# @access	public
	# @param	string
	# @param	array
	# @param	bool
	# @return	string
	#
	_parse : ($template, $data, $return = FALSE) =>
		if $template is ''
			return FALSE
			
		
		for $val, $key in as
			if is_array($val)
				$template = @._parse_pair($key, $val, $template)
				
			else 
				$template = @._parse_single($key, ''+$val, $template)
				
			
		
		if $return is FALSE
			$CI = get_instance()
			$CI.output.append_output($template)
			
		
		return $template
		
	
	#  --------------------------------------------------------------------
	
	#
	#  Set the left/right variable delimiters
	#
	# @access	public
	# @param	string
	# @param	string
	# @return	void
	#
	set_delimiters : ($l = '{', $r = '}') =>
		@.l_delim = $l
		@.r_delim = $r
		
	
	#  --------------------------------------------------------------------
	
	#
	#  Parse a single key/value
	#
	# @access	private
	# @param	string
	# @param	string
	# @param	string
	# @return	string
	#
	_parse_single : ($key, $val, $string) =>
		return str_replace(@.l_delim + $key + @.r_delim, $val, $string)
		
	
	#  --------------------------------------------------------------------
	
	#
	#  Parse a tag pair
	#
	# Parses tag pairs:  {some_tag} string... {/some_tag}
	#
	# @access	private
	# @param	string
	# @param	array
	# @param	string
	# @return	string
	#
	_parse_pair : ($variable, $data, $string) =>
		if FALSE is ($match = @._match_pair($string, $variable))
			return $string
			
		
		$str = ''
		for $row in as
			$temp = $match['1']
			for $val, $key in as
				if not is_array($val)
					$temp = @._parse_single($key, $val, $temp)
					
				else 
					$temp = @._parse_pair($key, $val, $temp)
					
				
			
			$str+=$temp
			
		
		return str_replace($match['0'], $str, $string)
		
	
	#  --------------------------------------------------------------------
	
	#
	#  Matches a variable pair
	#
	# @access	private
	# @param	string
	# @param	string
	# @return	mixed
	#
	_match_pair : ($string, $variable) =>
		if not preg_match("|" + preg_quote(@.l_delim) + $variable + preg_quote(@.r_delim) + "(.+?)" + preg_quote(@.l_delim) + '/' + $variable + preg_quote(@.r_delim) + "|s", $string, $match)
			return FALSE
			
		
		return $match
		
	
	
#  END Parser Class

#  End of file Parser.php 
#  Location: ./system/libraries/Parser.php 
