if not defined('BASEPATH') then die 'No direct script access allowed'
#
# CodeIgniter
#
# An open source application development framework for PHP 5.1.6 or newer
#
# @package		CodeIgniter
# @author		ExpressionEngine Dev Team
# @copyright   Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license		http://codeigniter.com/user_guide/license.html
# @link		http://codeigniter.com
# @since		Version 1.0
# @filesource
#

#  ------------------------------------------------------------------------

#
# oci8 Result Class
#
# This class extends the parent result class: CI_DB_result
#
# @category	Database
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/database/
#
class CI_DB_oci8_resultextends CI_DB_result
	
	$stmt_id: {}
	$curs_id: {}
	$limit_used: {}
	
	#
	# Number of rows in the result set.
	#
	# Oracle doesn't have a graceful way to retun the number of rows
	# so we have to use what amounts to a hack.
	#
	#
	# @access  public
	# @return  integer
	#
	num_rows :  =>
		$rowcount = count(@.result_array())
		ociexecute(@.stmt_id)
		
		if @.curs_id
			ociexecute(@.curs_id)
			
		
		return $rowcount
		
	
	#  --------------------------------------------------------------------
	
	#
	# Number of fields in the result set
	#
	# @access  public
	# @return  integer
	#
	num_fields :  =>
		$count = ocinumcols(@.stmt_id)
		
		#  if we used a limit we subtract it
		if @.limit_used
			$count = $count - 1
			
		
		return $count
		
	
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
		$fieldCount = @.num_fields()
		($c = 1$c<=$fieldCount$c++)
		{
		$field_names.push ocicolumnname(@.stmt_id, $c)
		}
		return $field_names
		
	
	#  --------------------------------------------------------------------
	
	#
	# Field data
	#
	# Generates an array of objects containing field meta-data
	#
	# @access  public
	# @return  array
	#
	field_data :  =>
		$retval = {}
		$fieldCount = @.num_fields()
		($c = 1$c<=$fieldCount$c++)
		{
		$F = new stdClass()
		$F.name = ocicolumnname(@.stmt_id, $c)
		$F.type = ocicolumntype(@.stmt_id, $c)
		$F.max_length = ocicolumnsize(@.stmt_id, $c)
		
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
		if is_resource(@.result_id)
			ocifreestatement(@.result_id)
			@.result_id = FALSE
			
		
	
	#  --------------------------------------------------------------------
	
	#
	# Result - associative array
	#
	# Returns the result set as an array
	#
	# @access  private
	# @return  array
	#
	_fetch_assoc : ( and $row) =>
		$id = if (@.curs_id) then @.curs_id else @.stmt_id
		
		return ocifetchinto($id, $row, OCI_ASSOC + OCI_RETURN_NULLS)
		
	
	#  --------------------------------------------------------------------
	
	#
	# Result - object
	#
	# Returns the result set as an object
	#
	# @access  private
	# @return  object
	#
	_fetch_object :  =>
		$result = {}
		
		#  If PHP 5 is being used we can fetch an result object
		if function_exists('oci_fetch_object')
			$id = if (@.curs_id) then @.curs_id else @.stmt_id
			
			return oci_fetch_object($id)
			
		
		#  If PHP 4 is being used we have to build our own result
		for $val, $key in as
			$obj = new stdClass()
			if is_array($val)
				for $v, $k in as
					$obj.$k = $v
					
				
			else 
				$obj.$key = $val
				
			
			$result.push $obj
			
		
		return $result
		
	
	#  --------------------------------------------------------------------
	
	#
	# Query result.  "array" version.
	#
	# @access  public
	# @return  array
	#
	result_array :  =>
		if count(@.result_array) > 0
			return @.result_array
			
		
		#  oracle's fetch functions do not return arrays.
		#  The information is returned in reference parameters
		$row = NULL
		while @._fetch_assoc($row)
			@.result_array.push $row
			
		
		return @.result_array
		
	
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
		return FALSE#  Not needed
		
	
	


#  End of file oci8_result.php 
#  Location: ./system/database/drivers/oci8/oci8_result.php 