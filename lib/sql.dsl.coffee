#+--------------------------------------------------------------------+
#| sql.dsl.coffee.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the GNU General Public License Version 3
#|
#+--------------------------------------------------------------------+
#
#	sql.dsl.coffee
#
#
#

exports.GO = ($db, $callback) ->
  new SqlDsl($db, $callback)

exports.SELECT = ($columns..., $sql) ->
  $sql.select $columns

exports.INSERT = ($sql) ->
  $sql.insert()

exports.INTO = ($table, $columns, $sql) ->
  $sql.into $table, $columns

exports.VALUES = ($values, $sql) ->
  $sql.values $values

exports.DISTINCT = ($sql) ->
  $sql.distinct()

exports.UPDATE = ($table, $sql) ->
  $sql.update $table

exports.SET = ($data, $sql) ->
  $sql.set $data

exports.FROM = ($table, $sql) ->
  $sql.from $table

exports.WHERE = ($column, $sql) ->
  $sql.where $column

exports.IS = ($value, $sql) ->
  $sql.is $value

exports.LIKE = ($value, $sql) ->
  $sql.like $value

exports.LIMIT = ($start, $sql) ->
  $sql.limit $start

exports.OFFSET = ($offset, $sql) ->
  $sql.offset $offset

exports.ORDER_BY = ($column, $sql) ->
  $sql.order_by $column

exports.INNER = ($sql) ->
  $sql.inner()

exports.OUTER = ($sql) ->
  $sql.outer()

exports.LEFT = ($sql) ->
  $sql.left()

exports.RIGHT = ($sql) ->
  $sql.right()

exports.JOIN = ($table, $sql) ->
  $sql.join $table

exports.ON = ($relation, $sql) ->
  $sql.on $relation




## --------------------------------------------------------------------

#
# SqlDsl
#
#   Tracks state and variables for one sql statement
#
#   @access	private
#
class SqlDsl

  db:                null    # a DB_active_rec object
  callback:          null    # call when i/o completes

  constructor: (@db, @callback) ->

    @_table =         ''      # table name
    @_distinct =      false   # return DISTINCT rows
    @_columns =       []      # list of column names
    @_where =         []      # WHERE column
    @_like =          []      # encountered LIKE
    @_value =         []      # LIKE or WHERE condition
    @_values =        []      # INSERT INTO (...) VALUES (...)
    @_order_by =      []      # order by column
    @_order_dir =     []      # order by direction: ASC | DESC
    @_join =          []      # joined table name
    @_relation =      []      # joined relation
    @_group_by =      []      # group by column
    @_having =        []      # having condition
    @_join_type =     false   # inner/outer/left/right
    @_limit =         -1      # limit start
    @_offset =        -1      # limit offset
    @_is_like =       false   # encountered LIKE
    @_tmp =           null    # temporary value
    @_data =          {}      # UPDATE/INSERT data


  #
  # SELECT
  #
  #   @access	public
  #   @param array  list of columns to select
  #   @return	void
  #
  select: ($columns) ->
    @_columns = $columns

    if @_columns.length > 0
      @db.select @_columns unless @_columns.length is 1 and @_columns[0] is '*'

    if @_distinct is true
      @db.distinct()

    @db.from @_table

    for $column, $i in @_where
      if @_like[$i]
        @db.like $column, @_value[$i]
      else
        @db.where $column, @_value[$i]

    for $table, $i in @_join
      if @_join_type is false
        @db.join $table, @_relation[$i]
      else
        @db.join $table, @_relation[$i], @_join_type

    @db.limit @_start, @_offset
    @db.get @callback


  ## --------------------------------------------------------------------

  #
  # UPDATE
  #
  #   @access	public
  #   @return	void
  #
  insert:  ->

    $data = {}
    for $column, $i in @_columns
      $data[$column] = @_values[$i]

    @db.insert @_table, $data, @callback

  ## --------------------------------------------------------------------

  #
  # INTO
  #
  #   @access	public
  #   @param strint table name
  #   @param array  list of columns to select
  #   @return	void
  #
  into: ($table, $columns) ->
    @_table = $table
    @_columns = $columns
    @

  ## --------------------------------------------------------------------

  #
  # VALUES
  #
  #   @access	public
  #   @param array  list of values to add
  #   @return	void
  #
  values: ($values) ->
    @_values = $values
    @

  ## --------------------------------------------------------------------

  #
  # DISTINCT
  #
  #   @access	public
  #   @return	void
  #
  distinct:  ->
    @_distinct = true
    @

  ## --------------------------------------------------------------------

  #
  # UPDATE
  #
  #   @access	public
  #   @param string table to update
  #   @return	void
  #
  update: ($table) ->

    for $column, $i in @_where
      if @_like[$i]
        @db.like $column, @_value[$i]
      else
        @db.where $column, @_value[$i]

    @db.update $table, @_data, @callback


  ## --------------------------------------------------------------------

  #
  # SET
  #
  #   @access	public
  #   @param object  table of data to update
  #   @return	void
  #
  set: ($data) ->
    @_data = $data
    @

  ## --------------------------------------------------------------------

  #
  # FROM
  #
  #   @access	public
  #   @param array  table to select from
  #   @return	void
  #
  from: ($table) ->
    @_table = $table
    @

  ## --------------------------------------------------------------------

  #
  # WHERE
  #
  #   @access	public
  #   @param string column name
  #   @return	void
  #
  where: ($column) ->
    @_where.push $column
    @_value.push @_tmp
    @_like.push @_is_like
    @_is_like = false
    @_tmp = null
    @

  ## --------------------------------------------------------------------

  #
  # IS
  #
  #   @access	public
  #   @param string  condition equality match
  #   @return	void
  #
  is: ($value) ->
    @_is_like = false
    @_tmp = $value
    @

  ## --------------------------------------------------------------------

  #
  # LIKE
  #
  #   @access	public
  #   @param string  condition wildcard match
  #   @return	void
  #
  like: ($value) ->
    @_is_like = true
    @_tmp = $value
    @

  ## --------------------------------------------------------------------

  #
  # LIMIT
  #
  #   @access	public
  #   @param number  max # of rows to return
  #   @return	void
  #
  limit: ($start) ->
    @_start = $start
    @

  ## --------------------------------------------------------------------

  #
  # OFFSET
  #
  #   @access	public
  #   @param number  offset into virtual recordset
  #   @return	void
  #
  offset: ($offset) ->
    @_offset = $offset
    @

  ## --------------------------------------------------------------------

  #
  # ORDER_BY
  #
  #   @access	public
  #   @param string  column to sort by
  #   @return	void
  #
  order_by: ($column) ->
    @_order_by.push $column
    @

  ## --------------------------------------------------------------------

  #
  # JOIN Types:
  #
  #   INNER, OUTER, LEFT, RIGHT
  #
  #   @access	public
  #   @return	void
  #
  inner:  ->
    if @_join_type is false
      @_join_type = 'inner'
    else
      @_join_type = 'inner '+@_join_type
    @

  outer:  ->
    if @_join_type is false
      @_join_type = 'outer'
    else
      @_join_type = 'outer '+@_join_type
    @

  left:  ->
    if @_join_type is false
      @_join_type = 'left'
    else
      @_join_type = 'left '+@_join_type
    @

  right:  ->
    if @_join_type is false
      @_join_type = 'right'
    else
      @_join_type = 'right '+@_join_type
    @


  ## --------------------------------------------------------------------

  #
  # JOIN
  #
  #   @access	public
  #   @param array  offset into virtual recordset
  #   @return	void
  #
  join: ($table) ->
    @_join.push $table
    @

  ## --------------------------------------------------------------------

  #
  # ON
  #
  #   @access	public
  #   @param array  offset into virtual recordset
  #   @return	void
  #
  on: ($relation) ->
    @_relation.push $relation
    @




# End of file sql.dsl.coffee
# Location: ./sql.dsl.coffee