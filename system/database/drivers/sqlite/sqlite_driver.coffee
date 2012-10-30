#+--------------------------------------------------------------------+
#  sqlite_driver.coffee
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
# This file was ported from php to coffee-script using php2coffee v6.6.6
#
#


{count, implode, is_array, preg_replace, str_replace, strpos}  = require(FCPATH + 'lib')


#
# SQLite Database Adapter Class
#
# Note: _DB is an extender class that the app controller
# creates dynamically based on whether the active record
# class is being used or not.
#
#
module.exports = (CI_DB) ->

  class CI_DB_sqlite_driver extends CI_DB

    dbdriver: 'sqlite'
    sqlite:   null

    #  The character used to escape with - not needed for SQLite
    _escape_char: ''

    #  clause and character used for LIKE escape sequences
    _like_escape_str: " ESCAPE '%s' "
    _like_escape_chr: '!'

    #
    # The syntax to count rows is slightly different across different
    # database engines, so this string appears in each driver and is
    # used for the count_all() and count_all_results() functions.
    #
    _count_string: "SELECT COUNT(*) AS "
    _random_keyword: ' Random()'#  database specific random keyword

    #
    # Non-persistent database connection
    #
    # @access	private called by the base class
    # @return	resource
    #
    db_connect: ($callback) ->

      sqlite = require('sqlite3').verbose()

      @sqlite = sqlite.Database(@database, $callback)


    #  --------------------------------------------------------------------

    #
    # Persistent database connection
    #
    # @access	private called by the base class
    # @return	resource
    #
    db_pconnect: ($callback) ->
      #  not implemented in SQLite


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
    reconnect :  ->
      #  not implemented in SQLite


    #  --------------------------------------------------------------------

    #
    # Select the database
    #
    # @access	private called by the base class
    # @return	resource
    #
    db_select : ($callback) ->
      $callback(null)


    #  --------------------------------------------------------------------

    #
    # Set client character set
    #
    # @access	public
    # @param	string
    # @param	string
    # @return	resource
    #
    db_set_charset : ($charset, $collation, $callback) ->
      #  @todo - add support if needed
      $callback(null)


    #  --------------------------------------------------------------------

    #
    # Version number query string
    #
    # @access	public
    # @return	string
    #
    _version :  ->
      return sqlite_libversion()


    #  --------------------------------------------------------------------

    #
    # Execute the query
    #
    # @access	private called by the base class
    # @param	string	an SQL query
    # @return	resource
    #
    _execute: ($sql, $params, $callback) ->
      $sql = @_prep_query($sql)
      @sqlite.run $sql, $params, $callback


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
    _prep_query : ($sql) ->
      return $sql


    #  --------------------------------------------------------------------

    #
    # Begin Transaction
    #
    # @access	public
    # @return	bool
    #
    trans_begin : ($test_mode = false) ->
      if not @trans_enabled
        return true


      #  When transactions are nested we only begin/commit/rollback the outermost ones
      if @_trans_depth > 0
        return true


      #  Reset the transaction failure flag.
      #  If the $test_mode flag is set to TRUE transactions will be rolled back
      #  even if the queries produce a successful result.
      @_trans_failure = if ($test_mode is true) then true else false

      @simple_query('BEGIN TRANSACTION')
      return true


    #  --------------------------------------------------------------------

    #
    # Commit Transaction
    #
    # @access	public
    # @return	bool
    #
    trans_commit :  ->
      if not @trans_enabled
        return true


      #  When transactions are nested we only begin/commit/rollback the outermost ones
      if @_trans_depth > 0
        return true


      @simple_query('COMMIT')
      return true


    #  --------------------------------------------------------------------

    #
    # Rollback Transaction
    #
    # @access	public
    # @return	bool
    #
    trans_rollback :  ->
      if not @trans_enabled
        return true


      #  When transactions are nested we only begin/commit/rollback the outermost ones
      if @_trans_depth > 0
        return true


      @simple_query('ROLLBACK')
      return true


    #  --------------------------------------------------------------------

    #
    # Escape String
    #
    # @access	public
    # @param	string
    # @param	bool	whether or not the string will be used in a LIKE condition
    # @return	string
    #
    escape_str : ($str, $like = false) ->
      if is_array($str)
        for $key, $val of $str
          $str[$key] = @escape_str($val, $like)


        return $str


      #$str = sqlite_escape_string($str)

      #  escape LIKE condition wildcards
      if $like is true
        $str = str_replace(['%', '_', @_like_escape_chr],
        [@_like_escape_chr + '%', @_like_escape_chr + '_', @_like_escape_chr + @_like_escape_chr],
        $str)


      return $str


    #  --------------------------------------------------------------------

    #
    # Affected Rows
    #
    # @access	public
    # @return	integer
    #
    affected_rows :  ->
      #  @todo - add support if needed
      return false
      #return sqlite_changes(@conn_id)


    #  --------------------------------------------------------------------

    #
    # Insert ID
    #
    # @access	public
    # @return	integer
    #
    insert_id :  ->
      #  @todo - add support if needed
      return false
      #return sqlite_last_insert_rowid(@conn_id)


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
    count_all : ($table = '') ->

      if $table is ''
        return 0

      @query @_count_string + @_protect_identifiers('numrows') + " FROM " + @_protect_identifiers($table, true, null, false), ($results)->

        $callback $results.length


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
    _list_tables : ($prefix_limit = false) ->
      $sql = "SELECT name from sqlite_master WHERE type='table'"

      if $prefix_limit isnt false and @dbprefix isnt ''
        $sql+=" AND 'name' LIKE '" + @escape_like_str(@dbprefix) + "%' " + sprintf(@_like_escape_str, @_like_escape_chr)

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
    _list_columns : ($table = '') ->
      #  Not supported
      return false


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
    _field_data : ($table) ->
      return "SELECT * FROM " + $table + " LIMIT 1"


    #  --------------------------------------------------------------------

    #
    # The error message string
    #
    # @access	private
    # @return	string
    #
    _error_message :  ->
      #  Not supported
      return false
      #return sqlite_error_string(sqlite_last_error(@conn_id))


    #  --------------------------------------------------------------------

    #
    # The error message number
    #
    # @access	private
    # @return	integer
    #
    _error_number :  ->
      #  Not supported
      return false
      #return sqlite_last_error(@conn_id)


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
    _escape_identifiers : ($item) ->
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
    _from_tables : ($tables) ->
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
    _insert : ($table, $keys, $values) ->
      return "INSERT INTO " + $table + " (" + implode(', ', $keys) + ") VALUES (" + implode(', ', $values) + ")"


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
    _update : ($table, $values, $where, $orderby = {}, $limit = false) ->
      for $key, $val of $values
        $valstr.push $key + " = " + $val


      $limit = if ( not $limit) then '' else ' LIMIT ' + $limit

      $orderby = if (count($orderby)>=1) then ' ORDER BY ' + implode(", ", $orderby) else ''

      $sql = "UPDATE " + $table + " SET " + implode(', ', $valstr)

      $sql+=($where isnt '' and count($where)>=1) then " WHERE " + implode(" ", $where) else ''

      $sql+=$orderby + $limit

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
    _truncate : ($table) ->
      return @_delete($table)


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
    _delete : ($table, $where = {}, $like = {}, $limit = false) ->
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
    # @access	public
    # @param	string	the sql query string
    # @param	integer	the number of rows to limit the query to
    # @param	integer	the offset value
    # @return	string
    #
    _limit : ($sql, $limit, $offset) ->
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
    _close: ($callback) ->
      @sqlite.end
      $callback() if $callback?

# End Class CI_DB_sqlite_driver

#  End of file sqlite_driver.php 
#  Location: ./system/database/drivers/sqlite/sqlite_driver.php 