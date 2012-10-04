#+--------------------------------------------------------------------+
#  odbc_result.coffee
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

{APPPATH, BASEPATH, ENVIRONMENT, EXT, FCPATH, SYSDIR, WEBROOT} = require(process.cwd() + '/index')
{default, defined, function_exists, is_resource, max_length, name, odbc_fetch_array, odbc_fetch_into, odbc_fetch_object, odbc_field_len, odbc_field_name, odbc_field_type, odbc_free_result, odbc_num_fields, odbc_num_rows, primary_key, result_id, stdClass, type}  = require(FCPATH + 'helper')
{config_item, get_class, get_config, is_loaded, load_class, load_new, load_object, log_message, register_class} = require(BASEPATH + 'core/Common')

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
# ODBC Result Class
#
# This class extends the parent result class: CI_DB_result
#
# @category	Database
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/database/
#
class CI_DB_odbc_result extends CI_DB_result
  
  #
  # Number of rows in the result set
  #
  # @access	public
  # @return	integer
  #
  num_rows :  ->
    return odbc_num_rows(@result_id)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Number of fields in the result set
  #
  # @access	public
  # @return	integer
  #
  num_fields :  ->
    return odbc_num_fields(@result_id)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Fetch Field Names
  #
  # Generates an array of column names
  #
  # @access	public
  # @return	array
  #
  list_fields :  ->
    $field_names = {}
    for ($i = 0$i < @num_fields()$i++)
    {
    $field_names.push odbc_field_name(@result_id, $i)
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
  field_data :  ->
    $retval = {}
    for ($i = 0$i < @num_fields()$i++)
    {
    $F = new stdClass()
    $F.name = odbc_field_name(@result_id, $i)
    $F.type = odbc_field_type(@result_id, $i)
    $F.max_length = odbc_field_len(@result_id, $i)
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
  free_result :  ->
    if is_resource(@result_id)
      odbc_free_result(@result_id)
      @result_id = false
      
    
  
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
  _data_seek : ($n = 0) ->
    return false
    
  
  #  --------------------------------------------------------------------
  
  #
  # Result - associative array
  #
  # Returns the result set as an array
  #
  # @access	private
  # @return	array
  #
  _fetch_assoc :  ->
    if function_exists('odbc_fetch_object')
      return odbc_fetch_array(@result_id)
      
    else 
      return @_odbc_fetch_array(@result_id)
      
    
  
  #  --------------------------------------------------------------------
  
  #
  # Result - object
  #
  # Returns the result set as an object
  #
  # @access	private
  # @return	object
  #
  _fetch_object :  ->
    if function_exists('odbc_fetch_object')
      return odbc_fetch_object(@result_id)
      
    else 
      return @_odbc_fetch_object(@result_id)
      
    
  
  
  #
  # Result - object
  #
  # subsititutes the odbc_fetch_object function when
  # not available (odbc_fetch_object requires unixODBC)
  #
  # @access	private
  # @return	object
  #
  _odbc_fetch_object : ( and $odbc_result) ->
    $rs = {}
    $rs_obj = false
    if odbc_fetch_into($odbc_result, $rs)
      for $k, $v of $rs
        $field_name = odbc_field_name($odbc_result, $k + 1)
        $rs_obj.$field_name = $v
        
      
    return $rs_obj
    
  
  
  #
  # Result - array
  #
  # subsititutes the odbc_fetch_array function when
  # not available (odbc_fetch_array requires unixODBC)
  #
  # @access	private
  # @return	array
  #
  _odbc_fetch_array : ( and $odbc_result) ->
    $rs = {}
    $rs_assoc = false
    if odbc_fetch_into($odbc_result, $rs)
      $rs_assoc = {}
      for $k, $v of $rs
        $field_name = odbc_field_name($odbc_result, $k + 1)
        $rs_assoc[$field_name] = $v
        
      
    return $rs_assoc
    
  
  

register_class 'CI_DB_odbc_result', CI_DB_odbc_result
module.exports = CI_DB_odbc_result


#  End of file odbc_result.php 
#  Location: ./system/database/drivers/odbc/odbc_result.php 