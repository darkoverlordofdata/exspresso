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
# Abstract Database Result Class
#
# A lightweight wrapper for the query result array
#
module.exports = class system.db.Result

  #
  # @property [Array<Object>] array of rows returned from query
  #
  _rows: null
  #
  # @property [Array<Object>] array of field data for rows
  #
  _meta: null
  #
  # @property [Array<Object>] array of custom row objects
  #
  _custom: null
  #
  # @property [Integer] index of current row 
  #
  _current: 0

  constructor : ($data, $meta) ->

    Object.defineProperties @,
      _rows       : {writeable: false, enumerable: true, value: $data}
      _meta       : {writeable: false, enumerable: true, value: $meta}
      _custom     : {writeable: false, enumerable: true, value: {}}
      num_rows    : {get: -> @_rows.length}


  #
  # Fetch Field Names
  #
  # Generates an array of column names
  #
  # @return	[Array]
  #
  listFields :  ->
    $field_names = []
    for $field in @_meta
      $field_names.push $field.name
    return $field_names

  #
  # Number of rows in the result set
  #
  # @return	[Integer]
  #
  numRows :  ->
    @_rows.length

  #
  # Number of fields in the result set
  #
  # @return	[Integer]
  #
  numFields :  ->
    @_meta.length

  #
  # Field data
  #
  # Generates an array of objects containing field meta-data
  #
  # @return	[Array]
  #
  fieldData :  ->
    @_meta
  #
  # Free the result
  #
  # @return	[Null]
  #
  freeResult :  ->
    @_rows = null

  #
  # Query result.  Acts as a wrapper function for the following functions.
  #
  # @param  [String]  can be "object" or "array"
  # @return [Mixed]  either a result object or array
  #
  result: ($type) ->
    if $type? then @customResultObject($type) else @_rows
  
  #
  # Custom query result.
  #
  # @param  class a no-constructor class to subclass the data with.
  # @return array of objects
  #
  customResultObject: ($class) ->
    if @_custom[$class.name]?
      return @_custom[$class.name]

    $result = []
    return $result if @num_rows() is 0

    class Custom extends $class
      constructor: ($columns = {}) ->
        @[$name] = $value for $name, $value in $columns

    @_current = 0
    while $row = @_fetch_object()
      $result.push new Custom($row)
    #  return the array
    @_custom[$class.name] = $result
  
  #
  # Query result.  Acts as a wrapper function for the following functions.
  #
  # @param  [String]
  # @param  [String]  can be "object" or "array"
  # @return [Mixed]  either a result object or array
  #
  row: ($n = 0, $type) ->
    $n = 0 unless 'number' is typeof($n)
    if $type? then @customRowObject($n, $type) else @rowArray($n)


  #
  # Returns a single result row - custom object version
  #
  # @return [Object]
  #
  customRowObject : ($n, $type) ->
    $result = @customResultObject($type)

    return {} if $result.length is 0
    if $n isnt @_current and $result[$n]?
      @_current = $n
    return $result[@_current]

  #
  # Returns a single result row - array version
  #
  # @return	array
  #
  rowArray : ($n = 0) ->

    return {} if @_rows.length is 0
    if $n isnt @_current and @_rows[$n]?
      @_current = $n
    return @_rows[@_current]

  #
  # Returns the "first" row
  #
  # @return [Object]
  #
  firstRow : ($type = 'object') ->

    return {} if @_rows.length is 0
    return @_rows[0]

  #
  # Returns the "last" row
  #
  # @return [Object]
  #
  lastRow : ($type = 'object') ->

    return {} if @_rows.length is 0
    return @_rows[@_rows.length - 1]

  #
  # Returns the "next" row
  #
  # @return [Object]
  #
  nextRow : ($type = 'object') ->

    return {} if @_rows.length is 0
    if @_rows[@_current + 1]?
      ++@_current
    return @_rows[@_current]

  #
  # Returns the "previous" row
  #
  # @return [Object]
  #
  previousRow : ($type = 'object') ->

    return {} if @_rows.length is 0
    if @_rows[@_current - 1]?
      --@_current
    return @_rows[@_current]

