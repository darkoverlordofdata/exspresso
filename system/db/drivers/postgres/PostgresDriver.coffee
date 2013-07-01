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
# Postgre Database Adapter Class
#
#
module.exports = class system.db.postgres.PostgresDriver extends system.db.ActiveRecord

  #  some platform specific strings

  _escape_char      : '"'
  _like_escape_str  : '' # " ESCAPE '%s' "
  _like_escape_chr  : '' # !'
  _count_string     : "SELECT COUNT(*) AS "
  _random_keyword   : ' RANDOM()'#  database specific random keyword

  #
  # Database connection settings
  # Selects the internal driver
  #
  # @param  [Object]  params  config array
  # @param  [system.core.Controller]  controller  the page controller
  #
  constructor: ($args...) ->
    super $args...

    Object.defineProperties @,
      driver        : {writeable: false, enumerable: true, value: 'pg'}
      version       : {writeable: false, enumerable: true, value: '1.3.0'}

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

    pg = require(@driver)
    @connected = true
    pg.connect @_connect_string(), ($err, $client, $done) =>

      @client = $client
      @done = $done
      if ($err)
        $done()
        @connected = false
        console.log $err
      else
        # return connection to pool -- pg v 0.14.x
        setTimeout $done, 1000
        $next null, $client

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
  # @param  [String]  # @param  [String]  # @return	resource
  #
  dbSetCharset: ($charset, $collation, $next) ->
    #  @todo - add support if needed
    return $next() if $next?
    return true


  #
  # Version number query string
  #
  # @return	[String]
  #
  _db_version:  ->
    "SELECT version() AS ver"


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
    $sql


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
    return true if not @_trans_enabled

    #  When transactions are nested we only begin/commit/rollback the outermost ones
    return true if @_trans_depth > 0

    @simpleQuery 'COMMIT', $next


  #
  # Rollback Transaction
  #
  # @return	bool
  #
  transRollback:  ->
    return true if not @_trans_enabled

    #  When transactions are nested we only begin/commit/rollback the outermost ones
    return true if @_trans_depth > 0

    @simpleQuery 'ROLLBACK', $next


  #
  # Escape String
  #
  # @param  [String]  # @return	[Boolean]	whether or not the string will be used in a LIKE condition
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
  affectedRows:  ->


  #
  # Insert ID
  #
  # @return	integer
  #
  insertId: ($next) ->

    @query "SELECT LASTVAL() AS id", ($err, $insert) =>
      return $next($err) if $err
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
    "SELECT column_name FROM information_schema.columns WHERE table_name ='" + $table + "'"


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
  _error_message:  ->


  #
  # The error message number
  #
  # @private
  # @return	integer
  #
  _error_number:  ->
    ''


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
        return $str.replace(RegExp('[' + @_escape_char + ']+'), @_escape_char)



    if $item.indexOf('.') isnt -1
      $str = @_escape_char + $item.replace('.', @_escape_char + '.' + @_escape_char) + @_escape_char

    else
      $str = @_escape_char + $item + @_escape_char


    #  remove duplicates if the user already included the escape
    return $str.replace(RegExp('[' + @_escape_char + ']+'), @_escape_char)


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
    return $tables.join(', ')


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
    "INSERT INTO " + $table + " (" + $keys.join(', ') + ") VALUES (" + $values.join(', ') + ");" #SELECT LASTVAL() AS id;"

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
      $valstr.push $key + " = " + $val


    $limit = if not $limit then '' else ' LIMIT ' + $limit

    $orderby = if $orderby.length>0 then ' ORDER BY ' + $orderby.join(", ") else ''

    $sql = "UPDATE " + $table + " SET " + $valstr.join(', ')

    $sql+= if $where isnt '' and $where.length>0 then " WHERE " + $where.join(" ") else ''

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
      $conditions+=@ar_where.join("\n")

      if $where.length > 0 and $like.length > 0
        $conditions+=" AND "

      $conditions+=$like.join("\n")


    $limit = if not $limit then '' else ' LIMIT ' + $limit

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
    $sql+=" OFFSET " + $offset if $offset > 0
    $sql


  #
  # Close DB Connection
  #
  # @param	resource
  # @return [Void]  #
  _close: ($next) ->
    $next() if $next?

