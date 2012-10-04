#+--------------------------------------------------------------------+
#  DB_result.coffee
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
{array_key_exists, count, defined, is_array, is_null, is_numeric}  = require(FCPATH + 'helper')
{config_item, get_class, get_config, is_loaded, load_class, load_new, load_object, log_message, register_class} = require(BASEPATH + 'core/Common')

if not defined('BASEPATH') then die ('No direct script access allowed')
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
# Database Result Class
#
# This is the platform-independent result class.
# This class will not be called directly. Rather, the adapter
# class for the specific database will extend and instantiate it.
#
# @category	Database
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/database/
#
class CI_DB_result
  
  conn_id: null
  result_id: null
  result_array: {}
  result_object: {}
  custom_result_object: {}
  current_row: 0
  num_rows: 0
  row_data: null
  
  
  #
  # Query result.  Acts as a wrapper function for the following functions.
  #
  # @access	public
  # @param	string	can be "object" or "array"
  # @return	mixed	either a result object or array
  #
  result : ($type = 'object') ->
    if $type is 'array'
      return @result_array()
      
    else if $type is 'object'
      return @result_object()
      
    else 
      return @custom_result_object($type)
      
    
  
  #  --------------------------------------------------------------------
  
  #
  # Custom query result.
  #
  # @param  class_name  A string that represents the type of object you want back
  # @return array of objects
  #
  custom_result_object : ($class_name) ->
    if array_key_exists($class_name, @custom_result_object)
      return @custom_result_object[$class_name]
      
    
    if @result_id is false or @num_rows() is 0
      return {}
      
    
    #  add the data to the object
    @_data_seek(0)
    $result_object = {}
    while $row = @_fetch_object()
      $object = new $class_name()
      for $key, $value of $row
        $object.$key = $value
      $result_object.push $object

    
    #  return the array
    return @custom_result_object[$class_name] = $result_object
  
  #
  # Query result.  "object" version.
  #
  # @access	public
  # @return	object
  #
  result_object :  ->
    if count(@result_object) > 0
      return @result_object
      
    
    #  In the event that query caching is on the result_id variable
    #  will return FALSE since there isn't a valid SQL resource so
    #  we'll simply return an empty array.
    if @result_id is false or @num_rows() is 0
      return {}
      
    
    @_data_seek(0)
    while $row = @_fetch_object())@result_object.push $row
    }
    
    return @result_object
    
  
  #  --------------------------------------------------------------------
  
  #
  # Query result.  "array" version.
  #
  # @access	public
  # @return	array
  #
  result_array :  ->
    if count(@result_array) > 0
      return @result_array
      
    
    #  In the event that query caching is on the result_id variable
    #  will return FALSE since there isn't a valid SQL resource so
    #  we'll simply return an empty array.
    if @result_id is false or @num_rows() is 0
      return {}
      
    
    @_data_seek(0)
    while $row = @_fetch_assoc())@result_array.push $row
    }
    
    return @result_array
    
  
  #  --------------------------------------------------------------------
  
  #
  # Query result.  Acts as a wrapper function for the following functions.
  #
  # @access	public
  # @param	string
  # @param	string	can be "object" or "array"
  # @return	mixed	either a result object or array
  #
  row : ($n = 0, $type = 'object') ->
    if not is_numeric($n)
      #  We cache the row data for subsequent uses
      if not is_array(@row_data)
        @row_data = @row_array(0)
        
      
      #  array_key_exists() instead of isset() to allow for MySQL NULL values
      if array_key_exists($n, @row_data)
        return @row_data[$n]
        
      #  reset the $n variable if the result was not achieved
      $n = 0
      
    
    if $type is 'object' then return @row_object($n)else if $type is 'array' then return @row_array($n)else #  --------------------------------------------------------------------#
    # Assigns an item into a particular column slot
    #
    # @access	public
    # @return	object
    ##  --------------------------------------------------------------------#
    # Returns a single result row - custom object version
    #
    # @access	public
    # @return	object
    ##
    # Returns a single result row - object version
    #
    # @access	public
    # @return	object
    ##  --------------------------------------------------------------------#
    # Returns a single result row - array version
    #
    # @access	public
    # @return	array
    ##  --------------------------------------------------------------------#
    # Returns the "first" row
    #
    # @access	public
    # @return	object
    ##  --------------------------------------------------------------------#
    # Returns the "last" row
    #
    # @access	public
    # @return	object
    ##  --------------------------------------------------------------------#
    # Returns the "next" row
    #
    # @access	public
    # @return	object
    ##  --------------------------------------------------------------------#
    # Returns the "previous" row
    #
    # @access	public
    # @return	object
    ##  --------------------------------------------------------------------#
    # The following functions are normally overloaded by the identically named
    # methods in the platform-specific driver -- except when query caching
    # is used.  When caching is enabled we do not load the other driver.
    # These functions are primarily here to prevent undefined function errors
    # when a cached result object is in use.  They are not otherwise fully
    # operational due to the unavailability of the database resource IDs with
    # cached results.
    ##  END DB_result class#  End of file DB_result.php #  Location: ./system/database/DB_result.php return @custom_row_object($n, $type)}set_row : ($key, $value = null) ->
      #  We cache the row data for subsequent uses
      if not is_array(@row_data)
        @row_data = @row_array(0)
        
      
      if is_array($key)
        for $k, $v of $key
          @row_data[$k] = $v
          
        
        return 
        
      
      if $key isnt '' and  not is_null($value)
        @row_data[$key] = $value
        
      custom_row_object : ($n, $type) ->
      $result = @custom_result_object($type)
      
      if count($result) is 0
        return $result
        
      
      if $n isnt @current_row and $result[$n]? 
        @current_row = $n
        
      
      return $result[@current_row]
      row_object : ($n = 0) ->
      $result = @result_object()
      
      if count($result) is 0
        return $result
        
      
      if $n isnt @current_row and $result[$n]? 
        @current_row = $n
        
      
      return $result[@current_row]
      row_array : ($n = 0) ->
      $result = @result_array()
      
      if count($result) is 0
        return $result
        
      
      if $n isnt @current_row and $result[$n]? 
        @current_row = $n
        
      
      return $result[@current_row]
      first_row : ($type = 'object') ->
      $result = @result($type)
      
      if count($result) is 0
        return $result
        
      return $result[0]
      last_row : ($type = 'object') ->
      $result = @result($type)
      
      if count($result) is 0
        return $result
        
      return $result[count($result) - 1]
      next_row : ($type = 'object') ->
      $result = @result($type)
      
      if count($result) is 0
        return $result
        
      
      if $result[@current_row + 1]? 
        ++@current_row
        
      
      return $result[@current_row]
      previous_row : ($type = 'object') ->
      $result = @result($type)
      
      if count($result) is 0
        return $result
        
      
      if $result[@current_row - 1]? 
        --@current_row
        
      return $result[@current_row]
      num_rows :  -> return @num_rowsnum_fields :  -> return 0list_fields :  -> return {}field_data :  -> return {}free_result :  -> return true_data_seek :  -> return true_fetch_assoc :  -> return {}_fetch_object :  -> return {}}

register_class 'CI_DB_result', CI_DB_result
module.exports = CI_DB_result