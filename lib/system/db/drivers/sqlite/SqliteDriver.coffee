#+--------------------------------------------------------------------+
#  SqliteDriver.coffee
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
# CodeIgniter
#
# An open source application development framework for PHP 5.1.6 or newer
#
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @see        http://darkoverlordofdata.com
# @since      Version 1.0
#

#  ------------------------------------------------------------------------



#
# SQLite Database Adapter Class
#
# Note: _DB is an extender class that the app controller
# creates dynamically based on whether the active record
# class is being used or not.
#
# @package		CodeIgniter
# @subpackage	Drivers
# @category	Database
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/database/
#
class system.db.sqlite.SqliteDriver extends system.db.ActiveRecord

  dbdriver          : 'sqlite'
  version           : require(FCPATH + 'node_modules/node-sqlite-purejs/package.json').version

  #  The character used to escape with - not needed for SQLite
  _escape_char      : '"'
  
  #  clause and character used for LIKE escape sequences
  _like_escape_str  : '' # " ESCAPE '%s' "
  _like_escape_chr  : '' # '!'
  
  #
  # The syntax to count rows is slightly different across different
  # database engines, so this string appears in each driver and is
  # used for the count_all() and count_all_results() functions.
  #
  _count_string     : "SELECT COUNT(*) AS "
  _random_keyword   : ' random()'#  database specific random keyword
  
  #
  # Non-persistent database connection
  #
  # @access	private called by the base class
  # @return	resource
  #
  db_connect: ($next) ->

    sqlite = require('node-sqlite-purejs')
    sqlite.open @database, {}, ($err, $client) =>

      @client = $client
      if ($err)
        @connected = false
        console.log $err
      else
        $next null, $client

  
  #  --------------------------------------------------------------------
  
  #
  # Persistent database connection
  #
  # @access	private called by the base class
  # @return	resource
  #
  db_pconnect :  ->

  
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
  db_select :  ->
    return true
    
  
  #  --------------------------------------------------------------------
  
  #
  # Set client character set
  #
  # @access	public
  # @param	string
  # @param	string
  # @return	resource
  #
  dbSetCharset: ($charset, $collation, $next) ->
    #  @todo - add support if needed
    return $next() if $next?
    return true

  
  #  --------------------------------------------------------------------
  
  #
  # Version number query string
  #
  # @access	public
  # @return	string
  #
  _version :  ->
    "SELECT sqlite_version() AS ver"
    
  
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
    @client.exec $sql, $next

  
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
      return $next(null, true)

    #  When transactions are nested we only begin/commit/rollback the outermost ones
    if @_trans_depth > 0
      return $next(null, true)

    #  Reset the transaction failure flag.
    #  If the $test_mode flag is set to TRUE transactions will be rolled back
    #  even if the queries produce a successful result.
    @_trans_failure = if ($test_mode is true) then true else false

    @simpleQuery 'BEGIN TRANSACTION', => #  can also be BEGIN or BEGIN WORK
      $next(null, true)

  #
  # Commit Transaction
  #
  # @return	bool
  #
  transCommit: ($next) ->
    if not @_trans_enabled
      return $next(null, true)

    #  When transactions are nested we only begin/commit/rollback the outermost ones
    if @_trans_depth > 0
      return $next(null, true)

    @simpleQuery 'COMMIT TRANSACTION', => #  can also be BEGIN or BEGIN WORK
      $next(null, true)


  #
  # Rollback Transaction
  #
  # @return	bool
  #
  transRollback: ($next) ->
    if not @_trans_enabled
      return $next(null, true)

    #  When transactions are nested we only begin/commit/rollback the outermost ones
    if @_trans_depth > 0
      return $next(null, true)

    @simpleQuery 'ROLLBACK', =>
      $next(null, true)


  #
  # Escape String
  #
  # @param  [String]
  # @param	[Boolean]	whether or not the string will be used in a LIKE condition
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
      $str = $str.replace(/\%/g, @_like_escape_chr + '%')
      $str = $str.replace(/\_/g, @_like_escape_chr + '_')
      $str = $str.replace(RegExp(reg_quote(@_like_escape_chr), 'g'), @_like_escape_chr + @_like_escape_chr)
    return $str


  #
  # Affected Rows
  #
  # @return	integer
  #
  affectedRows: ($next) ->
    #@client.affected_rows($next)


    #
    # Insert ID
    #
    # @return	integer
    #
  insertId: ($next) ->

    @query "SELECT LAST_INSERT_ROWID() AS id;", ($err, $insert) =>
      return($next $err) if $err
      $next(null, $insert.row().id)

  #
  # "Count All" query
  #
  # Generates a platform-specific query string that counts all records in
  # the specified database
  #
  # @param  [String]  # @return	[String]
  #
  countAll: ($table = '', $next) ->
    if $table is ''
      return 0

    @query @_count_string + @_protect_identifiers('numrows') + " FROM " + @_protect_identifiers($table, true, null, false), ($err, $query)->

      return $next($err) if $err
      $next(null, $query.row().numrows)

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
    $sql = "SELECT name FROM sqlite_master WHERE  tyype = 'table' "


    if $prefix_limit isnt false and @dbprefix isnt ''
      $sql+="AND name LIKE '" + @escape_like_str(@dbprefix) + "%'"
    else
      $sel+="AND name NOT LIKE 'sqlite_%'"
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
    "PRAGMA table_info(" + @_protect_identifiers($table, true, null, false)+");"


  #
  # Field data query
  #
  # Generates a platform-specific query so that the column data can be retrieved
  #
  # @param  [String]  the table name
  # @return [Object]  #
  _field_data: ($table) ->
    "SELECT * FROM " + $table + " LIMIT 1"


  #
  # The error message string
  #
  # @private
  # @return	[String]
  #
  _error_message: () ->
    'sql error_message'
  #@client.error()


  #
  # The error message number
  #
  # @private
  # @return	integer
  #
  _error_number: () ->
    'sql error_number'
  #@client.errno()


  #
  # Escape the SQL Identifiers
  #
  # This function escapes column and table names
  #
  # @private
  # @param  [String]  # @return	[String]
  #
  _escape_identifiers: ($item) ->
    if @_escape_char is ''
      return $item

    for $id in @_reserved_identifiers
      if $item.indexOf('.' + $id) isnt -1
        $str = @_escape_char + $item.replace('.', @_escape_char + '.')

        #  remove duplicates if the user already included the escape
        return $str.replace(RegExp('[' + @_escape_char + ']+', 'g'), @_escape_char)

    if $item.indexOf('.') isnt -1
      $str = @_escape_char + $item.replace('.', @_escape_char + '.' + @_escape_char) + @_escape_char

    else
      $str = @_escape_char + $item + @_escape_char

    #  remove duplicates if the user already included the escape
    $str.replace(RegExp('[' + @_escape_char + ']+', 'g'), @_escape_char)


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
    $tables = [$tables] if 'string' is typeof($tables)
    '(' + $tables.join(', ') + ')'


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
    "INSERT INTO " + $table + " (" + $keys.join(', ') + ") VALUES (" + $values.join(', ') + ");" #SELECT LAST_INSERT_ID() AS id;"



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
    "REPLACE INTO " + $table + " (" + $keys.join(', ') + ") VALUES (" + $values.join(', ') + ")"


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
    "INSERT INTO " + $table + " (" + $keys.join(', ') + ") VALUES " + $values.join(', ')



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
  _update: ($table, $values, $where, $orderby = [], $limit = false) ->
    $valstr = []
    for $key, $val of $values
      $valstr.push $key + ' = ' + $val

    $limit = if not $limit then '' else ' LIMIT ' + $limit

    $orderby = if $orderby.length>0 then ' ORDER BY ' + $orderby.join(", ") else ''

    $sql = "UPDATE " + $table + " SET " + $valstr.join(', ')

    $sql+= if $where isnt '' and $where.length>0 then " WHERE " + $where.join(" ") else ''

    $sql+=$orderby + $limit

    return $sql



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
    $where = if $where isnt '' and $where.length>0 then $where.join(" ") + ' AND ' else ''

    for $key, $val of $values
      $ids.push $val[$index]
      for $field in Object.keys($val)
        if $field isnt $index
          $final[$field].push 'WHEN ' + $index + ' = ' + $val[$index] + ' THEN ' + $val[$field]

    $sql = "UPDATE " + $table + " SET "
    $cases = ''

    for $k, $v of $final
      $cases+=$k + ' = CASE ' + "\n"
      for $row in $v
        $cases+=$row + "\n"
      $cases+='ELSE ' + $k + ' END, '
    $sql+=$cases.substr(0,  - 2)

    $sql+=' WHERE ' + $where + $index + ' IN (' + $ids.join(',') + ')'



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
    "TRUNCATE " + $table


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

    if $where.length > 0 or $like.length > 0
      $conditions = "\nWHERE "
      $conditions+=$where.join("\n")

      if $where.length > 0 and $like.length > 0
        $conditions+=" AND "

      $conditions+=$like.join("\n")

    $limit = if ( not $limit) then '' else ' LIMIT ' + $limit

    "DELETE FROM " + $table + $conditions + $limit


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

    $sql + "LIMIT " + $offset + $limit


  #
  # Close DB Connection
  #
  # @param	resource
  # @return [Void]  #
  _close: ($next) ->
    @client.end($next)

module.exports = system.db.sqlite.SqliteDriver


#  End of file SqliteDriver.coffee
#  Location: ./system/db/drivers/sqlite/SqliteDriver.coffee