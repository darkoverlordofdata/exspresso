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
# MySQLi Result Class
#
# This class extends the parent result class: CI_DB_result
#
# @category	Database
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/database/
#
class CI_DB_mysqli_resultextends CI_DB_result
	
	#
	# Number of rows in the result set
	#
	# @access	public
	# @return	integer
	#
	num_rows :  =>
		return mysqli_num_rows(@.result_id)
		
	
	#  --------------------------------------------------------------------
	
	#
	# Number of fields in the result set
	#
	# @access	public
	# @return	integer
	#
	num_fields :  =>
		return mysqli_num_fields(@.result_id)
		
	
	#  --------------------------------------------------------------------
	
	#
	# Fetch Field Names
	#
	# Generates an array of column names
	#
	# @access	public
	# @return	array
	#
	list_fields :  =>
		$field_names = {}
		while $field = mysqli_fetch_field(@.result_id))$field_names.push $field.name
		}
		
		return $field_names
		
	
	#  --------------------------------------------------------------------
	
	#
	# Field data
	#
	# Generates an array of objects containing field meta-data
	#
	# @access	public
	# @return	array
	#
	field_data :  =>
		$retval = {}
		while $field = mysqli_fetch_field(@.result_id))$F = new stdClass()$F.name = $field.name$F.type = $field.type$F.default = $field.def$F.max_length = $field.max_length$F.primary_key = if ($field.flags and MYSQLI_PRI_KEY_FLAG) then 1 else 0$retval.push $F
		}
		
		return $retval
		
	
	#  --------------------------------------------------------------------
	
	#
	# Free the result
	#
	# @return	null
	#
	free_result :  =>
		if is_object(@.result_id)
			mysqli_free_result(@.result_id)
			@.result_id = FALSE
			
		
	
	#  --------------------------------------------------------------------
	
	#
	# Data Seek
	#
	# Moves the internal pointer to the desired offset.  We call
	# this internally before fetching results to make sure the
	# result set starts at zero
	#
	# @access	private
	# @return	array
	#
	_data_seek : ($n = 0) =>
		return mysqli_data_seek(@.result_id, $n)
		
	
	#  --------------------------------------------------------------------
	
	#
	# Result - associative array
	#
	# Returns the result set as an array
	#
	# @access	private
	# @return	array
	#
	_fetch_assoc :  =>
		return mysqli_fetch_assoc(@.result_id)
		
	
	#  --------------------------------------------------------------------
	
	#
	# Result - object
	#
	# Returns the result set as an object
	#
	# @access	private
	# @return	object
	#
	_fetch_object :  =>
		return mysqli_fetch_object(@.result_id)
		
	
	


#  End of file mysqli_result.php 
#  Location: ./system/database/drivers/mysqli/mysqli_result.php 