#+--------------------------------------------------------------------+
#  PostgreResult.coffee
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
# Postgres Result Class
#
# This class extends the parent result class: ExspressoDb_result
#
class system.db.postgres.PostgresResult extends system.db.Result


  constructor: ($results) ->
    @_result_array = @_result_object = $results.rows
    @_num_rows = @numRows()

  #
  # Number of rows in the result set
  #
  # @return	integer
  #
  numRows :  ->
    return @_result_array.length


  #
  # Number of fields in the result set
  #
  # @return	integer
  #
  numFields :  ->


  #
  # Fetch Field Names
  #
  # Generates an array of column names
  #
  # @return	array
  #
  listFields :  ->
    $field_names = []


  #
  # Field data
  #
  # Generates an array of objects containing field meta-data
  #
  # @return	array
  #
  fieldData :  ->
    $retval = []


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
  # @private
  # @return	array
  #
  _data_seek : ($n = 0) ->
    @_current_row = $n

  #
  # Result - associative array
  #
  # Returns the result set as an array
  #
  # @private
  # @return	array
  #
  _fetch_assoc :  ->


  #
  # Result - object
  #
  # Returns the result set as an object
  #
  # @private
  # @return [Object]  #
  _fetch_object :  ->

module.exports = system.db.postgres.PostgresResult

#  End of file PostgreResult.coffee
#  Location: ./system/database/drivers/postgre/PostgreResult.coffee