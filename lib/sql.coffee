#+--------------------------------------------------------------------+
#| sql.coffee
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
#	A DSL for SQL
#
#   Layered onto CodeIgniter's ActiveRecord
#


## --------------------------------------------------------------------

#
# SELECT
#
#   @access	public
#   @param array  list of columns to select
#   @param object pseudo-this
#   @return	void
#
exports.SELECT = ($columns..., $sql) ->
  $sql.columns = $columns

  if $sql.columns.length > 0
    $sql.db.select $sql.columns unless $sql.columns.length is 1 and $sql.columns[0] is '*'

  if $sql.distinct is true
    $sql.db.distinct()

  $sql.db.from $sql.table

  for $column, $i in $sql.where
    if $sql.like[$i]
      $sql.db.like $column, $sql.value[$i]
    else
      $sql.db.where $column, $sql.value[$i]

  for $table, $i in $sql.join
    if $sql.join_type is false
      $sql.db.join $table, $sql.relation[$i]
    else
      $sql.db.join $table, $sql.relation[$i], $sql.join_type

  $sql.db.limit $sql.start, $sql.offset
  $sql.db.get $sql.callback


## --------------------------------------------------------------------

#
# UPDATE
#
#   @access	public
#   @param object pseudo-this
#   @return	void
#
exports.INSERT = ($sql) ->

  $data = {}
  for $column, $i in $sql.columns
    $data[$column] = $sql.values[$i]

  $sql.db.insert $sql.table, $data, $sql.callback

## --------------------------------------------------------------------

#
# INTO
#
#   @access	public
#   @param strint table name
#   @param array  list of columns to select
#   @param object pseudo-this
#   @return	void
#
exports.INTO = ($table, $columns, $sql) ->
  $sql.table = $table
  $sql.columns = $columns
  $sql

## --------------------------------------------------------------------

#
# VALUES
#
#   @access	public
#   @param array  list of values to add
#   @param object pseudo-this
#   @return	void
#
exports.VALUES = ($values, $sql) ->
  $sql.values = $values
  $sql

## --------------------------------------------------------------------

#
# DISTINCT
#
#   @access	public
#   @param object pseudo-this
#   @return	void
#
exports.DISTINCT = ($sql) ->
  $sql.distinct = true
  $sql

## --------------------------------------------------------------------

#
# UPDATE
#
#   @access	public
#   @param array  list of columns to select
#   @param object pseudo-this
#   @return	void
#
exports.UPDATE = ($table, $sql) ->

  for $column, $i in $sql.where
    if $sql.like[$i]
      $sql.db.like $column, $sql.value[$i]
    else
      $sql.db.where $column, $sql.value[$i]

  $sql.db.update $table, $sql.data, $sql.callback


## --------------------------------------------------------------------

#
# SET
#
#   @access	public
#   @param object  table of data to update
#   @param object pseudo-this
#   @return	void
#
exports.SET = ($data, $sql) ->
  $sql.data = $data
  $sql

## --------------------------------------------------------------------

#
# FROM
#
#   @access	public
#   @param array  table to select from
#   @param object pseudo-this
#   @return	void
#
exports.FROM = ($table, $sql) ->
  $sql.table = $table
  $sql

## --------------------------------------------------------------------

#
# WHERE
#
#   @access	public
#   @param array  select condition field
#   @param object pseudo-this
#   @return	void
#
exports.WHERE = ($column, $sql) ->
  $sql.where.push $column
  $sql.value.push $sql.tmp
  $sql.like.push $sql.is_like
  $sql.is_like = false
  $sql.tmp = null
  $sql

## --------------------------------------------------------------------

#
# IS
#
#   @access	public
#   @param array  dondition equality match
#   @param object pseudo-this
#   @return	void
#
exports.IS = ($value, $sql) ->
  $sql.is_like = false
  $sql.tmp = $value
  $sql

## --------------------------------------------------------------------

#
# LIKE
#
#   @access	public
#   @param array  dondition wildcard match
#   @param object pseudo-this
#   @return	void
#
exports.LIKE = ($value, $sql) ->
  $sql.is_like = true
  $sql.tmp = $value
  $sql

## --------------------------------------------------------------------

#
# LIMIT
#
#   @access	public
#   @param array  max # of rows to return
#   @param object pseudo-this
#   @return	void
#
exports.LIMIT = ($start, $sql) ->
  $sql.start = $start
  $sql

## --------------------------------------------------------------------

#
# OFFSET
#
#   @access	public
#   @param array  offset into virtual recordset
#   @param object pseudo-this
#   @return	void
#
exports.OFFSET = ($offset, $sql) ->
  $sql.offset = $offset
  $sql

## --------------------------------------------------------------------

#
# ORDER_BY
#
#   @access	public
#   @param array  offset into virtual recordset
#   @param object pseudo-this
#   @return	void
#
exports.ORDER_BY = ($column, $sql) ->
  $sql.order_by.push $column
  $sql

## --------------------------------------------------------------------

#
# JOIN Types:
#
#   INNER, OUTER, LEFT, RIGHT
#
#   @access	public
#   @param array  offset into virtual recordset
#   @param object pseudo-this
#   @return	void
#
exports.INNER = ($sql) ->
  if $sql.join_type is false
    $sql.join_type = 'inner'
  else
    $sql.join_type = 'inner '+$sql.join_type
  $sql

exports.OUTER = ($sql) ->
  if $sql.join_type is false
    $sql.join_type = 'outer'
  else
    $sql.join_type = 'outer '+$sql.join_type
  $sql

exports.LEFT = ($sql) ->
  if $sql.join_type is false
    $sql.join_type = 'left'
  else
    $sql.join_type = 'left '+$sql.join_type
  $sql

exports.RIGHT = ($sql) -> #100
  if $sql.join_type is false
    $sql.join_type = 'right'
  else
    $sql.join_type = 'right '+$sql.join_type
  $sql


## --------------------------------------------------------------------

#
# JOIN
#
#   @access	public
#   @param array  offset into virtual recordset
#   @param object pseudo-this
#   @return	void
#
exports.JOIN = ($table, $sql) ->
  $sql.join.push $table
  $sql

## --------------------------------------------------------------------

#
# ON
#
#   @access	public
#   @param array  offset into virtual recordset
#   @param object pseudo-this
#   @return	void
#
exports.ON = ($relation, $sql) ->
  $sql.relation.push $relation
  $sql


## --------------------------------------------------------------------

#
# GO
#
#   @access	public
#   @param function callback when i/o completes
#   @return	object pseudo-this
#
exports.GO = ($db, $callback) ->
  new SqlStatement($db, $callback)


## --------------------------------------------------------------------

#
# SqlStatement
#
#   Tracks state and variables for one sql statement
#
#   @access	private
#
class SqlStatement

  db:           null  # a DB_active_rec object
  callback:     null  # call when i/o completes

  constructor: (@db, @callback) ->

    @table =        ''    # table name
    @distinct =     false # return DISTINCT rows
    @columns =      []    # list of column names
    @where =        []    # WHERE column
    @like =         []    # encountered LIKE
    @value =        []    # LIKE or WHERE condition
    @values =       []    # INSERT INTO (...) VALUES (...)
    @order_by =     []    # order by column
    @order_dir =    []    # order by direction: ASC | DESC
    @join =         []    # joined table name
    @relation =     []    # joined relation
    @group_by =     []    # group by column
    @having =       []    # having condition
    @join_type =    false # inner/outer/left/right
    @limit =        -1    # limit start
    @offset =       -1    # limit offset
    @is_like =      false # encountered LIKE
    @tmp =          null  # temporary value
    @data =         {}    # UPDATE/INSERT data


# End of file sql.coffee
# Location: ./sql.coffee