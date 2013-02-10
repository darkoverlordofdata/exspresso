#+--------------------------------------------------------------------+
#  mysql_driver.coffee
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
#
#
# MySQL Database Adapter Class
#
# Note: _DB is an extender class that the app controller
# creates dynamically based on whether the active record
# class is being used or not.
#


class Exspresso_DB_mysql_driver extends Exspresso_DB

  # by default, expect mysql to listen on port 3306
  dbdriver            : 'mysql'
  port                : 3306
  connected           : false

  #  The character used for escaping
  _escape_char        : '`'

  #  clause and character used for LIKE escape sequences - not used in MySQL
  _like_escape_str    : ''
  _like_escape_chr    : ''

  #
  # Whether to use the MySQL "delete hack" which allows the number
  # of affected rows to be shown. Uses a preg_replace when enabled,
  # adding a bit more processing to all queries.
  #
  delete_hack         : true

  #
  # The syntax to count rows is slightly different across different
  # database engines, so this string appears in each driver and is
  # used for the count_all() and count_all_results() functions.
  #
  _count_string       : 'SELECT COUNT(*) AS '
  _random_keyword     : ' RAND()'#  database specific random keyword


  #
  # Non-persistent database connection
  #
  # @access	private called by the base class
  # @return	resource
  #
  db_connect: ($next) =>

    if not @connected
      mysql = require('mysql')

      @client = new mysql.createConnection
        host: @hostname
        port: @port
        user: @username
        password: @password
        database: @database
        debug: false # @db_debug

      @connected = true

    @client.connect $next, ($err) =>
      if ($err)
        @connected = false
        console.log $err
      else
        $next $err, @client

  #  --------------------------------------------------------------------

  #
  # Persistent database connection
  #
  # @access	private called by the base class
  # @return	resource
  #
  db_pconnect: ($next) ->
    throw new Error('Not Supported: mysql_driver::_db_pconnect')

  #  --------------------------------------------------------------------

  #
  # Reconnect
  #
  # Keep / reestablish the db connection if no queries have been
  # sent for a length of time exceeding the server's idle timeout
  #
  # @access	public
  # @return	void
  #
  reconnect: ($next) ->
    @client.ping($next)

  #  --------------------------------------------------------------------

  #
  # Select the database
  #
  # @access	private called by the base class
  # @return	resource
  #
  db_select: ($next) ->
    @client.useDatabase(@database, $next)


  #  --------------------------------------------------------------------

  #
  # Set client character set
  #
  # @access	public
  # @param	string
  # @param	string
  # @return	resource
  #
  db_set_charset: ($charset, $collation, $next) ->
    @client.query("SET NAMES '" + @escape_str($charset) + "' COLLATE '" + @escape_str($collation) + "'", $next)


  #  --------------------------------------------------------------------

  #
  # Version number query string
  #
  # @access	public
  # @return	string
  #
  _version: () ->
    return "SELECT version() AS ver"


  #  --------------------------------------------------------------------

  #
  # Execute the query
  #
  # @access	private called by the base class
  # @param	string	an SQL query
  # @return	resource
  #
  _execute: ($sql, $params, $next) ->
    $sql = @_prep_query($sql)
    @client.query $sql, $params, $next

  #  --------------------------------------------------------------------

  #
  # Prep the query
  #
  # If needed, each database adapter can prep the query string
  #
  # @access	private called by execute()
  # @param	string	an SQL query
  # @return	string
  #
  _prep_query: ($sql) ->
    #  "DELETE FROM TABLE" returns 0 affected rows This hack modifies
    #  the query so that it returns the number of affected rows
    if @delete_hack is true
      if preg_match('/^\\s*DELETE\\s+FROM\\s+(\\S+)\\s*$/i', $sql)
        $sql = preg_replace("/^\\s*DELETE\\s+FROM\\s+(\\S+)\\s*$/", "DELETE FROM $1 WHERE 1=1", $sql)



    return $sql


  #  --------------------------------------------------------------------

  #
  # Begin Transaction
  #
  # @access	public
  # @return	bool
  #
  trans_begin: ($test_mode = false, $next = null) ->
    if $next is null
      $next = $test_mode
      $test_mode = false

    if not @trans_enabled
      return $next null, true

    #  When transactions are nested we only begin/commit/rollback the outermost ones
    if @_trans_depth > 0
      return $next null, true

    #  Reset the transaction failure flag.
    #  If the $test_mode flag is set to TRUE transactions will be rolled back
    #  even if the queries produce a successful result.
    @_trans_failure = if ($test_mode is true) then true else false

    @simple_query 'SET AUTOCOMMIT=0', =>
      @simple_query 'START TRANSACTION', => #  can also be BEGIN or BEGIN WORK
        $next null, true

  #  --------------------------------------------------------------------

  #
  # Commit Transaction
  #
  # @access	public
  # @return	bool
  #
  trans_commit: ($next) ->
    if not @trans_enabled
      return $next null, true

    #  When transactions are nested we only begin/commit/rollback the outermost ones
    if @_trans_depth > 0
      return $next null, true

    @simple_query 'COMMIT', =>
      @simple_query 'SET AUTOCOMMIT=1', =>
        $next null, true


  #  --------------------------------------------------------------------

  #
  # Rollback Transaction
  #
  # @access	public
  # @return	bool
  #
  trans_rollback: ($next) ->
    if not @trans_enabled
      return $next null, true

    #  When transactions are nested we only begin/commit/rollback the outermost ones
    if @_trans_depth > 0
      return $next null, true

    @simple_query 'ROLLBACK', =>
      @simple_query 'SET AUTOCOMMIT=1', =>
        $next null, true


  #  --------------------------------------------------------------------

  #
  # Escape String
  #
  # @access	public
  # @param	string
  # @param	bool	whether or not the string will be used in a LIKE condition
  # @return	string
  #
  escape_str: ($str, $like = false) ->
    if is_array($str)
      for $key, $val of $str
        $str[$key] = @escape_str($val, $like)


      return $str

    $str = @client.escape($str)


    #  escape LIKE condition wildcards
    if $like is true
      $str = str_replace(['%', '_'], ['\\%', '\\_'], $str)

    return $str


  #  --------------------------------------------------------------------

  #
  # Affected Rows
  #
  # @access	public
  # @return	integer
  #
  affected_rows: ($next) ->
    #@client.affected_rows($next)


  #  --------------------------------------------------------------------

  #
  # Insert ID
  #
  # @access	public
  # @return	integer
  #
  insert_id: ($next) ->

    @query "SELECT LAST_INSERT_ID() AS id;", ($err, $insert) =>

      if $err
        $next $err
      else
        $next null, $insert.row().id



  #  --------------------------------------------------------------------

  #
  # "Count All" query
  #
  # Generates a platform-specific query string that counts all records in
  # the specified database
  #
  # @access	public
  # @param	string
  # @return	string
  #
  count_all: ($table = '', $next) ->
    if $table is ''
      return 0

    @query @_count_string + @_protect_identifiers('numrows') + " FROM " + @_protect_identifiers($table, true, null, false), ($err, $query)->

      if $err then $next $err
      else $next null, $query.row().numrows

  #  --------------------------------------------------------------------

  #
  # List table query
  #
  # Generates a platform-specific query string so that the table names can be fetched
  #
  # @access	private
  # @param	boolean
  # @return	string
  #
  _list_tables: ($prefix_limit = false) ->
    $sql = "SHOW TABLES FROM " + @_escape_char + @database + @_escape_char

    if $prefix_limit isnt false and @dbprefix isnt ''
      $sql+=" LIKE '" + @escape_like_str(@dbprefix) + "%'"


    return $sql


  #  --------------------------------------------------------------------

  #
  # Show column query
  #
  # Generates a platform-specific query string so that the column names can be fetched
  #
  # @access	public
  # @param	string	the table name
  # @return	string
  #
  _list_columns: ($table = '') ->
    return "SHOW COLUMNS FROM " + @_protect_identifiers($table, true, null, false)


  #  --------------------------------------------------------------------

  #
  # Field data query
  #
  # Generates a platform-specific query so that the column data can be retrieved
  #
  # @access	public
  # @param	string	the table name
  # @return	object
  #
  _field_data: ($table) ->
    return "SELECT * FROM " + $table + " LIMIT 1"


  #  --------------------------------------------------------------------

  #
  # The error message string
  #
  # @access	private
  # @return	string
  #
  _error_message: () ->
    'sql error_message'
    #@client.error()


  #  --------------------------------------------------------------------

  #
  # The error message number
  #
  # @access	private
  # @return	integer
  #
  _error_number: () ->
    'sql error_number'
    #@client.errno()


  #  --------------------------------------------------------------------

  #
  # Escape the SQL Identifiers
  #
  # This function escapes column and table names
  #
  # @access	private
  # @param	string
  # @return	string
  #
  _escape_identifiers: ($item) ->
    if @_escape_char is ''
      return $item


    for $id in @_reserved_identifiers
      if strpos($item, '.' + $id) isnt false
        $str = @_escape_char + str_replace('.', @_escape_char + '.', $item)

        #  remove duplicates if the user already included the escape
        return preg_replace('/[' + @_escape_char + ']+/', @_escape_char, $str)



    if strpos($item, '.') isnt false
      $str = @_escape_char + str_replace('.', @_escape_char + '.' + @_escape_char, $item) + @_escape_char

    else
      $str = @_escape_char + $item + @_escape_char


    #  remove duplicates if the user already included the escape
    return preg_replace('/[' + @_escape_char + ']+/', @_escape_char, $str)


  #  --------------------------------------------------------------------

  #
  # From Tables
  #
  # This function implicitly groups FROM tables so there is no confusion
  # about operator precedence in harmony with SQL standards
  #
  # @access	public
  # @param	type
  # @return	type
  #
  _from_tables: ($tables) ->
    if not is_array($tables)
      $tables = [$tables]


    return '(' + implode(', ', $tables) + ')'


  #  --------------------------------------------------------------------

  #
  # Insert statement
  #
  # Generates a platform-specific insert string from the supplied data
  #
  # @access	public
  # @param	string	the table name
  # @param	array	the insert keys
  # @param	array	the insert values
  # @return	string
  #
  _insert: ($table, $keys, $values) ->
    return "INSERT INTO " + $table + " (" + implode(', ', $keys) + ") VALUES (" + implode(', ', $values) + ");" #SELECT LAST_INSERT_ID() AS id;"


  #  --------------------------------------------------------------------


  #
  # Replace statement
  #
  # Generates a platform-specific replace string from the supplied data
  #
  # @access	public
  # @param	string	the table name
  # @param	array	the insert keys
  # @param	array	the insert values
  # @return	string
  #
  _replace: ($table, $keys, $values) ->
    return "REPLACE INTO " + $table + " (" + implode(', ', $keys) + ") VALUES (" + implode(', ', $values) + ")"


  #  --------------------------------------------------------------------

  #
  # Insert_batch statement
  #
  # Generates a platform-specific insert string from the supplied data
  #
  # @access	public
  # @param	string	the table name
  # @param	array	the insert keys
  # @param	array	the insert values
  # @return	string
  #
  _insert_batch : ($table, $keys, $values) ->
    return "INSERT INTO " + $table + " (" + implode(', ', $keys) + ") VALUES " + implode(', ', $values)


  #  --------------------------------------------------------------------


  #
  # Update statement
  #
  # Generates a platform-specific update string from the supplied data
  #
  # @access	public
  # @param	string	the table name
  # @param	array	the update data
  # @param	array	the where clause
  # @param	array	the orderby clause
  # @param	array	the limit clause
  # @return	string
  #
  _update: ($table, $values, $where, $orderby = {}, $limit = false) ->
    $valstr = []
    for $key, $val of $values
      $valstr.push $key + ' = ' + $val


    $limit = if ( not $limit) then '' else ' LIMIT ' + $limit

    $orderby = if (count($orderby)>=1) then ' ORDER BY ' + implode(", ", $orderby) else ''

    $sql = "UPDATE " + $table + " SET " + implode(', ', $valstr)

    $sql+= if ($where isnt '' and count($where)>=1) then " WHERE " + implode(" ", $where) else ''

    $sql+=$orderby + $limit

    return $sql


  #  --------------------------------------------------------------------


  #
  # Update_Batch statement
  #
  # Generates a platform-specific batch update string from the supplied data
  #
  # @access	public
  # @param	string	the table name
  # @param	array	the update data
  # @param	array	the where clause
  # @return	string
  #
  _update_batch : ($table, $values, $index, $where = null) ->
    $ids = []
    $where = if ($where isnt '' and count($where)>=1) then implode(" ", $where) + ' AND ' else ''

    for $key, $val of $values
      $ids.push $val[$index]

      for $field in array_keys($val)
        if $field isnt $index
          $final[$field].push 'WHEN ' + $index + ' = ' + $val[$index] + ' THEN ' + $val[$field]




    $sql = "UPDATE " + $table + " SET "
    $cases = ''

    for $k, $v of $final
      $cases+=$k + ' = CASE ' + "\n"
      for $row in $v
        $cases+=$row + "\n"


      $cases+='ELSE ' + $k + ' END, '


    $sql+=substr($cases, 0,  - 2)

    $sql+=' WHERE ' + $where + $index + ' IN (' + implode(',', $ids) + ')'

    return $sql


  #  --------------------------------------------------------------------


  #
  # Truncate statement
  #
  # Generates a platform-specific truncate string from the supplied data
  # If the database does not support the truncate() command
  # This function maps to "DELETE FROM table"
  #
  # @access	public
  # @param	string	the table name
  # @return	string
  #
  _truncate: ($table) ->
    return "TRUNCATE " + $table


  #  --------------------------------------------------------------------

  #
  # Delete statement
  #
  # Generates a platform-specific delete string from the supplied data
  #
  # @access	public
  # @param	string	the table name
  # @param	array	the where clause
  # @param	string	the limit clause
  # @return	string
  #
  _delete: ($table, $where = [], $like = [], $limit = false) ->
    $conditions = ''

    if count($where) > 0 or count($like) > 0
      $conditions = "\nWHERE "
      $conditions+=implode("\n", $where)

      if count($where) > 0 and count($like) > 0
        $conditions+=" AND "

      $conditions+=implode("\n", $like)


    $limit = if ( not $limit) then '' else ' LIMIT ' + $limit

    return "DELETE FROM " + $table + $conditions + $limit


  #  --------------------------------------------------------------------

  #
  # Limit string
  #
  # Generates a platform-specific LIMIT clause
  #
  # @access	public
  # @param	string	the sql query string
  # @param	integer	the number of rows to limit the query to
  # @param	integer	the offset value
  # @return	string
  #
  _limit: ($sql, $limit, $offset) ->
    if $offset is 0
      $offset = ''

    else
      $offset+=", "


    return $sql + "LIMIT " + $offset + $limit


  #  --------------------------------------------------------------------

  #
  # Close DB Connection
  #
  # @access	public
  # @param	resource
  # @return	void
  #
  _close: ($next) ->
    @client.end($next)

# End Class Exspresso_DB_mysql_driver
module.exports = Exspresso_DB_mysql_driver
#  End of file @client.driver.php
#  Location: ./system/database/drivers/mysql/mysql_driver.php