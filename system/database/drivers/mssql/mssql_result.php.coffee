#+--------------------------------------------------------------------+
#  mssql_result.coffee
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
{default, defined, is_resource, max_length, mssql_data_seek, mssql_fetch_assoc, mssql_fetch_field, mssql_fetch_object, mssql_free_result, mssql_num_fields, mssql_num_rows, name, primary_key, result_id, stdClass, type}  = require(FCPATH + 'helper')
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
# MS SQL Result Class
#
# This class extends the parent result class: CI_DB_result
#
# @category	Database
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/database/
#
class CI_DB_mssql_result extends CI_DB_result
  
  #
  # Number of rows in the result set
  #
  # @access	public
  # @return	integer
  #
  num_rows :  ->
    return mssql_num_rows(@result_id)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Number of fields in the result set
  #
  # @access	public
  # @return	integer
  #
  num_fields :  ->
    return mssql_num_fields(@result_id)
    
  
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
    while $field = mssql_fetch_field(@result_id))$field_names.push $field.name
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
    while $field = mssql_fetch_field(@result_id))$F = new stdClass()$F.name = $field.name$F.type = $field.type$F.max_length = $field.max_length$F.primary_key = 0$F.default = ''$retval.push $F
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
      mssql_free_result(@result_id)
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
    return mssql_data_seek(@result_id, $n)
    
  
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
    return mssql_fetch_assoc(@result_id)
    
  
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
    return mssql_fetch_object(@result_id)
    
  
  

register_class 'CI_DB_mssql_result', CI_DB_mssql_result
module.exports = CI_DB_mssql_result


#  End of file mssql_result.php 
#  Location: ./system/database/drivers/mssql/mssql_result.php 