#+--------------------------------------------------------------------+
#  MysqlDriver.coffee
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
#
#
# MySQL Database Adapter Class
#
# Note: _DB is an extender class that the app controller
# creates dynamically based on whether the active record
# class is being used or not.
#


class system.db.mysql.MysqlDriver extends system.db.ActiveRecord

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
  # @private called by the base class
  # @return	resource
  #
  connect: ($next) =>

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
  # @private called by the base class
  # @return	resource
  #
  pconnect: ($next) ->
    throw new Error('Not Supported: mysql_driver::pconnect')

  #  --------------------------------------------------------------------

  #
  # Reconnect
  #
  # Keep / reestablish the db connection if no queries have been
  # sent for a length of time exceeding the server's idle timeout
  #
    # @return [Void]  #
  reconnect: ($next) ->
    @client.ping($next)

  #  --------------------------------------------------------------------

  #
  # Select the database
  #
  # @private called by the base class
  # @return	resource
  #
  db_select: ($next) ->
    @client.useDatabase(@database, $next)


  #  --------------------------------------------------------------------

  #
  # Set client character set
  #
    # @param  [String]    # @param  [String]    # @return	resource
  #
  dbSetCharset: ($charset, $collation, $next) ->
    @client.query("SET NAMES '" + @escapeStr($charset) + "' COLLATE '" + @escapeStr($collation) + "'", $next)


  #  --------------------------------------------------------------------

  #
  # Version number query string
  #
    # @return	[String]
  #
  _version: () ->
    return "SELECT version() AS ver"


  #  --------------------------------------------------------------------

  #
  # Execute the query
  #
  # @private called by the base class
  # @param  [String]  an SQL query
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
  # @private called by execute()
  # @param  [String]  an SQL query
  # @return	[String]
  #
  _prep_query: ($sql) ->
    #  "DELETE FROM TABLE" returns 0 affected rows This hack modifies
    #  the query so that it returns the number of affected rows
    if @delete_hack is true
      if preg_match('/^\\s*DELETE\\s+FROM\\s+(\\S+)\\s*$/i', $sql)?
        $sql = preg_replace("/^\\s*DELETE\\s+FROM\\s+(\\S+)\\s*$/", "DELETE FROM $1 WHERE 1=1", $sql)



    return $sql


  #  --------------------------------------------------------------------

  #
  # Begin Transaction
  #
    # @return	bool
  #
  transBegin: ($test_mode = false, $next = null) ->
    if $next is null
      $next = $test_mode
      $test_mode = false

    if not @_trans_enabled
      return $next null, true

    #  When transactions are nested we only begin/commit/rollback the outermost ones
    if @_trans_depth > 0
      return $next null, true

    #  Reset the transaction failure flag.
    #  If the $test_mode flag is set to TRUE transactions will be rolled back
    #  even if the queries produce a successful result.
    @_trans_failure = if ($test_mode is true) then true else false

    @simpleQuery 'SET AUTOCOMMIT=0', =>
      @simpleQuery 'START TRANSACTION', => #  can also be BEGIN or BEGIN WORK
        $next null, true

  #  --------------------------------------------------------------------

  #
  # Commit Transaction
  #
    # @return	bool
  #
  transCommit: ($next) ->
    if not @_trans_enabled
      return $next null, true

    #  When transactions are nested we only begin/commit/rollback the outermost ones
    if @_trans_depth > 0
      return $next null, true

    @simpleQuery 'COMMIT', =>
      @simpleQuery 'SET AUTOCOMMIT=1', =>
        $next null, true


  #  --------------------------------------------------------------------

  #
  # Rollback Transaction
  #
    # @return	bool
  #
  transRollback: ($next) ->
    if not @_trans_enabled
      return $next null, true

    #  When transactions are nested we only begin/commit/rollback the outermost ones
    if @_trans_depth > 0
      return $next null, true

    @simpleQuery 'ROLLBACK', =>
      @simpleQuery 'SET AUTOCOMMIT=1', =>
        $next null, true


  #  --------------------------------------------------------------------

  #
  # Escape String
  #
    # @param  [String]    # @return	[Boolean]	whether or not the string will be used in a LIKE condition
  # @return	[String]
  #
  escapeStr: ($str, $like = false) ->
    if is_array($str)
      for $key, $val of $str
        $str[$key] = @escapeStr($val, $like)


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
    # @return	integer
  #
  affectedRows: ($next) ->
    #@client.affected_rows($next)


  #  --------------------------------------------------------------------

  #
  # Insert ID
  #
    # @return	integer
  #
  insertId: ($next) ->

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
    # @param  [String]    # @return	[String]
  #
  countAll: ($table = '', $next) ->
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
  # @private
  # @return	[Boolean]ean
  # @return	[String]
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
    # @param  [String]  the table name
  # @return	[String]
  #
  _list_columns: ($table = '') ->
    return "SHOW COLUMNS FROM " + @_protect_identifiers($table, true, null, false)


  #  --------------------------------------------------------------------

  #
  # Field data query
  #
  # Generates a platform-specific query so that the column data can be retrieved
  #
    # @param  [String]  the table name
  # @return [Object]  #
  _field_data: ($table) ->
    return "SELECT * FROM " + $table + " LIMIT 1"


  #  --------------------------------------------------------------------

  #
  # The error message string
  #
  # @private
  # @return	[String]
  #
  _error_message: () ->
    'sql error_message'
    #@client.error()


  #  --------------------------------------------------------------------

  #
  # The error message number
  #
  # @private
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
  # @private
  # @param  [String]    # @return	[String]
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
    # @param  [String]  the table name
  # @param  [Array]  the insert keys
  # @param  [Array]  the insert values
  # @return	[String]
  #
  _insert: ($table, $keys, $values) ->
    return "INSERT INTO " + $table + " (" + implode(', ', $keys) + ") VALUES (" + implode(', ', $values) + ");" #SELECT LAST_INSERT_ID() AS id;"


  #  --------------------------------------------------------------------


  #
  # Replace statement
  #
  # Generates a platform-specific replace string from the supplied data
  #
    # @param  [String]  the table name
  # @param  [Array]  the insert keys
  # @param  [Array]  the insert values
  # @return	[String]
  #
  _replace: ($table, $keys, $values) ->
    return "REPLACE INTO " + $table + " (" + implode(', ', $keys) + ") VALUES (" + implode(', ', $values) + ")"


  #  --------------------------------------------------------------------

  #
  # Insert_batch statement
  #
  # Generates a platform-specific insert string from the supplied data
  #
    # @param  [String]  the table name
  # @param  [Array]  the insert keys
  # @param  [Array]  the insert values
  # @return	[String]
  #
  _insert_batch : ($table, $keys, $values) ->
    return "INSERT INTO " + $table + " (" + implode(', ', $keys) + ") VALUES " + implode(', ', $values)


  #  --------------------------------------------------------------------


  #
  # Update statement
  #
  # Generates a platform-specific update string from the supplied data
  #
    # @param  [String]  the table name
  # @param  [Array]  the update data
  # @param  [Array]  the where clause
  # @param  [Array]  the orderby clause
  # @param  [Array]  the limit clause
  # @return	[String]
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
    # @param  [String]  the table name
  # @param  [Array]  the update data
  # @param  [Array]  the where clause
  # @return	[String]
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
    # @param  [String]  the table name
  # @return	[String]
  #
  _truncate: ($table) ->
    return "TRUNCATE " + $table


  #  --------------------------------------------------------------------

  #
  # Delete statement
  #
  # Generates a platform-specific delete string from the supplied data
  #
    # @param  [String]  the table name
  # @param  [Array]  the where clause
  # @param  [String]  the limit clause
  # @return	[String]
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
    # @param  [String]  the sql query string
  # @param  [Integer]  the number of rows to limit the query to
  # @param  [Integer]  the offset value
  # @return	[String]
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
    # @param	resource
  # @return [Void]  #
  _close: ($next) ->
    @client.end($next)

# End Class ExspressoMysqlDriver
module.exports = system.db.mysql.MysqlDriver
#  End of file MysqlDriver.coffee
#  Location: ./system/database/drivers/mysql/MysqlDriver.coffee