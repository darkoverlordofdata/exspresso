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
# SQLite Result Class
#
# This class extends the parent result class: CI_DB_result
#
# @category	Database
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/database/
#
class CI_DB_sqlite_resultextends CI_DB_result
	
	#
	# Number of rows in the result set
	#
	# @access	public
	# @return	integer
	#
	num_rows :  =>
		return sqlite_num_rows(@.result_id)
		
	
	#  --------------------------------------------------------------------
	
	#
	# Number of fields in the result set
	#
	# @access	public
	# @return	integer
	#
	num_fields :  =>
		return sqlite_num_fields(@.result_id)
		
	
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
		($i = 0$i < @.num_fields()$i++)
		{
		$field_names.push sqlite_field_name(@.result_id, $i)
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
		($i = 0$i < @.num_fields()$i++)
		{
		$F = new stdClass()
		$F.name = sqlite_field_name(@.result_id, $i)
		$F.type = 'varchar'
		$F.max_length = 0
		$F.primary_key = 0
		$F.default = ''
		
		$retval.push $F
		}
		
		return $retval
		
	
	#  --------------------------------------------------------------------
	
	#
	# Free the result
	#
	# @return	null
	#
	free_result :  =>
		#  Not implemented in SQLite
		
	
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
		return sqlite_seek(@.result_id, $n)
		
	
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
		return sqlite_fetch_array(@.result_id)
		
	
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
		if function_exists('sqlite_fetch_object')
			return sqlite_fetch_object(@.result_id)
			
		else 
			$arr = sqlite_fetch_array(@.result_id, SQLITE_ASSOC)
			if is_array($arr)
				$obj = $arr
				return $obj
				else 
				return NULL
				
			
		
	
	


#  End of file sqlite_result.php 
#  Location: ./system/database/drivers/sqlite/sqlite_result.php 