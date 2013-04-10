#+--------------------------------------------------------------------+
#  SqliteResult.coffee
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
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @see        http://darkoverlordofdata.com
# @since      Version 1.0
#

#  ------------------------------------------------------------------------

#
# SQLite Result Class
#
#

class system.db.sqlite.SqliteResult extends system.db.Result

  _metadata : null


  constructor: ($results) ->

    @_result_array = @_result_object = $results
    @_metadata = []
    if $results.length > 0
      for $name, $val of $results[0]
        @_metadata.push {name: $name}
    @_num_rows = @numRows()

  #
  # Number of rows in the result set
  #
  # @return	[Integer]
  #
  numRows :  ->
    @_result_array.length

  #
  # Number of fields in the result set
  #
  # @return	[Integer]
  #
  numFields :  ->
    @_metadata.length

  #
  # Fetch Field Names
  #
  # Generates an array of column names
  #
  # @return	[Array]
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
  # @return	[Array]
  #
  fieldData :  ->
    return @_metadata

  #
  # Free the result
  #
  # @return	[Null]
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
  # @return	[Array]
  #
  _data_seek : ($n = 0) ->
    @_current_row = $n

  #
  # Result - associative array
  #
  # Returns the result set as an array
  #
  # @private
  # @return	[Array]
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

module.exports = system.db.sqlite.SqliteResult


#  End of file SqliteResult.coffee
#  Location: ./system/db/drivers/sqlite/SqliteResult.coffee