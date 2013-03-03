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
# This class extends the parent result class: ExspressoDb_result
#

class global.ExspressoMysqlResult extends ExspressoDbResult

  _metadata = []


  constructor: ($results, $info) ->

    @_result_array = @_result_object = $results
    @_metadata = $info
    @_num_rows = @numRows()

  #
  # Number of rows in the result set
  #
  # @access	public
  # @return	integer
  #
  numRows :  ->
    @_result_array.length


  

  #
  # Number of fields in the result set
  #
  # @access	public
  # @return	integer
  #
  numFields :  ->
    @_metadata.length

  

  #
  # Fetch Field Names
  #
  # Generates an array of column names
  #
  # @access	public
  # @return	array
  #
  listFields :  ->
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
  fieldData :  ->
    return @_metadata


  

  #
  # Free the result
  #
  # @return	null
  #
  freeResult :  ->
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

module.exports = ExspressoMysqlResult

#  End of file mysql_result.php 
#  Location: ./system/database/drivers/mysql/mysql_result.php 