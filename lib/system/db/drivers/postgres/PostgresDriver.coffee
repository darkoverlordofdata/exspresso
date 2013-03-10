#+--------------------------------------------------------------------+
#  PostgreDriver.coffee
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
# Postgre Database Adapter Class
#
# Note: _DB is an extender class that the app controller
# creates dynamically based on whether the active record
# class is being used or not.
#
#
class system.db.postgres.PostgresDriver extends system.db.ActiveRecord

  dbdriver          : 'postgres'
  port              : 5432
  connected         : false

  _escape_char      : '"'

  #  clause and character used for LIKE escape sequences
  _like_escape_str  : '' # " ESCAPE '%s' "
  _like_escape_chr  : '' # !'

  #
  # The syntax to count rows is slightly different across different
  # database engines, so this string appears in each driver and is
  # used for the count_all() and count_all_results() functions.
  #
  _count_string     : "SELECT COUNT(*) AS "
  _random_keyword   : ' RANDOM()'#  database specific random keyword

  #
  # Connection String
  #
  # @private
  # @return	[String]  postgres://username:password@hostname:port/database
  #
  _connect_string:  ->

    $connect_string = @dbdriver + "://#{@username}:#{@password}@#{@hostname}:#{@port}/#{@database}"
    return trim($connect_string)


  #
  # Non-persistent database connection
  #
  # @private called by the base class
  # @return	resource
  #
  connect: ($next) =>

    pg = require('pg')
    @connected = true
    pg.connect @_connect_string(), ($err, $client, $done) =>

      @client = $client
      @done = $done
      if ($err)
        @connected = false
        console.log $err
      else
        $next $err, $client

  #
  # Persistent database connection
  #
  # @private called by the base class
  # @return	resource
  #
  db_pconnect:  ->
    throw new Error('Not Supported: postgres_driver::pconnect')


  #
  # Reconnect
  #
  # Keep / reestablish the db connection if no queries have been
  # sent for a length of time exceeding the server's idle timeout
  #
    # @return [Void]  #
  reconnect: ($next) -> @connect $next



  #
  # Select the database
  #
  # @private called by the base class
  # @return	resource
  #
  db_select:  ->
    #  Not needed for Postgre so we'll return TRUE
    return true


  #
  # Set client character set
  #
    # @param  [String]    # @param  [String]    # @return	resource
  #
  dbSetCharset: ($charset, $collation, $next) ->
    #  @todo - add support if needed
    if $next? then $next()
    return true


  #
  # Version number query string
  #
    # @return	[String]
  #
  _version:  ->
    return "SELECT version() AS ver"


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
    return $sql


  #
  # Begin Transaction
  #
    # @return	bool
  #
  transBegin: ($test_mode = false) ->
    if not @_trans_enabled
      return true


    #  When transactions are nested we only begin/commit/rollback the outermost ones
    if @_trans_depth > 0
      return true


    #  Reset the transaction failure flag.
    #  If the $test_mode flag is set to TRUE transactions will be rolled back
    #  even if the queries produce a successful result.
    @_trans_failure = if ($test_mode is true) then true else false

    @simpleQuery 'BEGIN', $next #


  #
  # Commit Transaction
  #
    # @return	bool
  #
  transCommit:  ->
    if not @_trans_enabled
      return true


    #  When transactions are nested we only begin/commit/rollback the outermost ones
    if @_trans_depth > 0
      return true

    @simpleQuery 'COMMIT', $next


  #
  # Rollback Transaction
  #
    # @return	bool
  #
  transRollback:  ->
    if not @_trans_enabled
      return true


    #  When transactions are nested we only begin/commit/rollback the outermost ones
    if @_trans_depth > 0
      return true


    @simpleQuery 'ROLLBACK', $next


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

    #$str = pg.escape_string($str)
    $str = "'" + $str + "'"

    #  escape LIKE condition wildcards
    if $like is true
      $str = str_replace(['%', '_', @_like_escape_chr],
      [@_like_escape_chr + '%', @_like_escape_chr + '_', @_like_escape_chr + @_like_escape_chr],
      $str)


    return $str


  #
  # Affected Rows
  #
    # @return	integer
  #
  affectedRows:  ->


  #
  # Insert ID
  #
    # @return	integer
  #
  insertId: ($next) ->

    @query "SELECT LASTVAL() AS id", ($err, $insert) =>

      if $err
        $next $err
      else
        $next null, $insert.row().id

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


  #
  # Show table query
  #
  # Generates a platform-specific query string so that the table names can be fetched
  #
  # @private
  # @return	[Boolean]ean
  # @return	[String]
  #
  _list_tables: ($prefix_limit = false) ->
    $sql = "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'"

    if $prefix_limit isnt false and @dbprefix isnt ''
      $sql+=" AND table_name LIKE '" + @escape_like_str(@dbprefix) + "%' " + sprintf(@_like_escape_str, @_like_escape_chr)


    return $sql


  #
  # Show column query
  #
  # Generates a platform-specific query string so that the column names can be fetched
  #
    # @param  [String]  the table name
  # @return	[String]
  #
  _list_columns: ($table = '') ->
    return "SELECT column_name FROM information_schema.columns WHERE table_name ='" + $table + "'"


  #
  # Field data query
  #
  # Generates a platform-specific query so that the column data can be retrieved
  #
    # @param  [String]  the table name
  # @return [Object]  #
  _field_data: ($table) ->
    return "SELECT * FROM " + $table + " LIMIT 1"


  #
  # The error message string
  #
  # @private
  # @return	[String]
  #
  _error_message:  ->


  #
  # The error message number
  #
  # @private
  # @return	integer
  #
  _error_number:  ->
    return ''


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


    return implode(', ', $tables)


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
    return "INSERT INTO " + $table + " (" + implode(', ', $keys) + ") VALUES (" + implode(', ', $values) + ");" #SELECT LASTVAL() AS id;"

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
  _insert_batch: ($table, $keys, $values) ->
    return "INSERT INTO " + $table + " (" + implode(', ', $keys) + ") VALUES " + implode(', ', $values)

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
      $valstr.push $key + " = " + $val


    $limit = if ( not $limit) then '' else ' LIMIT ' + $limit

    $orderby = if (count($orderby)>=1) then ' ORDER BY ' + implode(", ", $orderby) else ''

    $sql = "UPDATE " + $table + " SET " + implode(', ', $valstr)

    $sql+= if ($where isnt '' and count($where)>=1) then " WHERE " + implode(" ", $where) else ''

    $sql+=$orderby + $limit

    return $sql


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
  _delete: ($table, $where = {}, $like = {}, $limit = false) ->
    $conditions = ''

    if count($where) > 0 or count($like) > 0
      $conditions = "\nWHERE "
      $conditions+=implode("\n", @ar_where)

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
    $sql+="LIMIT " + $limit

    if $offset > 0
      $sql+=" OFFSET " + $offset


    return $sql


  #
  # Close DB Connection
  #
    # @param	resource
  # @return [Void]  #
  _close: ($next) ->
    #@done()
    #@client.end()
    $next()


# End Class ExspressoPostgresDriver
module.exports = system.db.postgres.PostgresDriver
#  End of file PostgresDriver.coffee
#  Location: ./system/database/drivers/postgre/PostgresDriver.coffee