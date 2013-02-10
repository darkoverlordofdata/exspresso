#+--------------------------------------------------------------------+
#  mysql_result.coffee
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
# This file was ported from CodeIgniter to coffee-script using php2coffee
#
#
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @package    Exspresso
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license    MIT License
# @link       http://darkoverlordofdata.com
# @since      Version 1.0
#

#  --------------------------------------------------------------------

#
# MySQL Result Class
#
# This class extends the parent result class: Exspresso_DB_result
#

class global.Exspresso_DB_mysql_result extends Exspresso_DB_result

  _metadata = []


  constructor: ($results, $info) ->

    @_result_array = @_result_object = $results
    @_metadata = $info
    @_num_rows = @num_rows()

  #
  # Number of rows in the result set
  #
  # @access	public
  # @return	integer
  #
  num_rows :  ->
    @_result_array.length


  

  #
  # Number of fields in the result set
  #
  # @access	public
  # @return	integer
  #
  num_fields :  ->
    @_metadata.length

  

  #
  # Fetch Field Names
  #
  # Generates an array of column names
  #
  # @access	public
  # @return	array
  #
  list_fields :  ->
    $field_names = []
    for $field in @_metadata
      $field_names.push $field.name
    return $field_names


  

  #
  # Field data
  #
  # Generates an array of objects containing field meta-data
  #
  # @access	public
  # @return	array
  #
  field_data :  ->
    return @_metadata


  

  #
  # Free the result
  #
  # @return	null
  #
  free_result :  ->
    @result_array = null

  

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
    @_current_row = $n

  

  #
  # Result - associative array
  #
  # Returns the result set as an array
  #
  # @access	private
  # @return	array
  #
  _fetch_assoc :  ->


  

  #
  # Result - object
  #
  # Returns the result set as an object
  #
  # @access	private
  # @return	object
  #
  _fetch_object :  ->

module.exports = Exspresso_DB_mysql_result

#  End of file mysql_result.php 
#  Location: ./system/database/drivers/mysql/mysql_result.php 