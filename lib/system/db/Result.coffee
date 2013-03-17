#+--------------------------------------------------------------------+
#  Result.coffee
#+--------------------------------------------------------------------+
#  Copyright DarkOverlordOfData (c) 2012 - 2013
#+--------------------------------------------------------------------+
#
#  This file is a part of Exspresso
#
#  Exspresso is free software you can copy, modify, and distribute
#  it under the terms of the MIT License
#
#+--------------------------------------------------------------------+
#
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @see        http://darkoverlordofdata.com
# @since      Version 1.0
#

#  ------------------------------------------------------------------------

#
# Database Result Class
#
# This is the platform-independent result class.
# This class will not be called directly. Rather, the adapter
# class for the specific database will extend and instantiate it.
#
class system.db.Result
  
  _result_array           : null
  _result_object          : null
  _custom_result_object   : null
  _current_row            : 0
  _num_rows               : 0
  _row_data               : null

  constructor: ->

    @_result_array           = []
    @_result_object          = []
    @_custom_result_object   = []


  #
  # Query result.  Acts as a wrapper function for the following functions.
  #
  # @param  [String]  can be "object" or "array"
  # @return [Mixed]  either a result object or array
  #
  result : ($type = 'object') ->

    if $type is 'object'
      return @resultObject()
    else if $type is 'array'
      return @resultArray()
    else
      return @customResultObject($type)
      
    
  
  #
  # Custom query result.
  #
  # @param  class_name  A string that represents the type of object you want back
  # @return array of objects
  #
  customResultObject : ($class_name) ->
    if @_custom_result_object[$class_name]?
      return @_custom_result_object[$class_name]
      
    
    if @num_rows() is 0
      return []
      
    
    #  add the data to the object
    @_data_seek(0)
    $result_object = []
    while $row = @_fetch_object()
      $object = new $class_name()
      for $key, $value of $row
        $object[$key] = $value
      $result_object.push $object

    
    #  return the array
    return @_custom_result_object[$class_name] = $result_object
  
  #
  # Query result.  "object" version.
  #
  # @return [Object]
  #
  resultObject : () ->
    return @_result_array
    
  
  #
  # Query result.  "array" version.
  #
  # @return	array
  #
  resultArray : () ->
    return @_result_array

  
  #
  # Query result.  Acts as a wrapper function for the following functions.
  #
  # @param  [String]
  # @param  [String]  can be "object" or "array"
  # @return [Mixed]  either a result object or array
  #
  row : ($n = 0, $type = 'object') ->
    if not 'number' is typeof($n)
      #  We cache the row data for subsequent uses
      if not 'object' is typeof(@_row_data)
        @_row_data = @row_array(0)
        
      
      if @_row_data[$n]?
        return @_row_data[$n]
        
      #  reset the $n variable if the result was not achieved
      $n = 0
      
    
    if $type is 'object'
      return @rowObject($n)
    else if $type is 'array'
      return @rowArray($n)
    else
      return @customRowObject($n, $type)

  #
  # Assigns an item into a particular column slot
  #
  # @return [Object]
  #
  setRow: ($key, $value = null) ->
    if not 'object' is typeof(@_row_data)
      @_row_data = @rowArray(0)

    if 'object' is typeof($key)
      for $k, $v of $key
        @_row_data[$k] = $v
      return

    if $key isnt '' and  $value isnt null
      @_row_data[$key] = $value


  #
  # Returns a single result row - custom object version
  #
  # @return [Object]
  #
  customRowObject : ($n, $type) ->
    $result = @customResultObject($type)

    return $result if $result.length is 0

    if $n isnt @_current_row and $result[$n]?
      @_current_row = $n

    return $result[@_current_row]

  #
  # Returns a single result row - object version
  #
  # @return [Object]
  #
  rowObject : ($n = 0) ->

    if @_result_object.length is 0
      return {}

    if $n isnt @_current_row and @_result_object[$n]?
      @_current_row = $n

    return @_result_object[@_current_row]

  #
  # Returns a single result row - array version
  #
  # @return	array
  #
  rowArray : ($n = 0) ->

    if @_result_array.length is 0
      return {}

    if $n isnt @_current_row and @_result_array[$n]?
      @_current_row = $n

    return @_result_array[@_current_row]

  #
  # Returns the "first" row
  #
  # @return [Object]
  #
  firstRow : ($type = 'object') ->

    if @_result_array.length is 0
      return {}

    return @_result_array[0]

  #
  # Returns the "last" row
  #
    # @return [Object]  lastRow : ($type = 'object') ->

    if @_result_array.length is 0
      return {}

    return @_result_array[@_result_array.length - 1]

  #
  # Returns the "next" row
  #
  # @return [Object]
  #
  nextRow : ($type = 'object') ->

    if @_result_array.length is 0
      return {}


    if @_result_array[@_current_row + 1]?
      ++@_current_row


    return @_result_array[@_current_row]

  #
  # Returns the "previous" row
  #
  # @return [Object]
  #
  previousRow : ($type = 'object') ->

    if @_result_array.length is 0
      return {}


    if @_result_array[@_current_row - 1]?
      --@_current_row

    return @_result_array[@_current_row]

  #
  # The following functions are normally overloaded by the identically named
  # methods in the platform-specific driver -- except when query caching
  # is used.  When caching is enabled we do not load the other driver.
  # These functions are primarily here to prevent undefined function errors
  # when a cached result object is in use.  They are not otherwise fully
  # operational due to the unavailability of the database resource IDs with
  # cached results.

  numRows       :  -> return 0
  numFields     :  -> return 0
  listFields    :  -> return []
  fieldData     :  -> return []
  freeResult    :  -> return true
  _data_seek    :  -> return true
  _fetch_assoc  :  -> return []
  _fetch_object :  -> return []

  ##  END DB_result class

module.exports = system.db.Result
#  End of file Result.coffee
#  Location: ./system/db/Result.coffee
