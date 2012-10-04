#+--------------------------------------------------------------------+
#  mysqli_driver.coffee
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

{APPPATH, BASEPATH, ENVIRONMENT, EXT, FCPATH, SYSDIR, WEBROOT} = require(process.cwd() + '/index')
{_protect_identifiers, _reserved_identifiers, _trans_depth, _trans_failure, addslashes, ar_where, array_keys, conn_id, count, database, dbprefix, defined, escape_like_str, function_exists, hostname, implode, is_array, is_object, mysql_escape_string, mysqli_affected_rows, mysqli_close, mysqli_connect, mysqli_errno, mysqli_error, mysqli_insert_id, mysqli_ping, mysqli_query, mysqli_real_escape_string, mysqli_select_db, num_rows, numrows, password, port, preg_match, preg_replace, query, row, simple_query, str_replace, strpos, substr, trans_enabled, username}  = require(FCPATH + 'pal')
{config_item, get_class, get_config, is_loaded, load_class, load_new, load_object, log_message, register_class} = require(BASEPATH + 'core/Common')

if not defined('BASEPATH') then die 'No direct script access allowed'
#
# CodeIgniter
#
# An open source application development framework for PHP 5.1.6 or newer
#
# @package		CodeIgniter
# @author		ExpressionEngine Dev Team
# @copyright	Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license		http://codeigniter.com/user_guide/license.html
# @link		http://codeigniter.com
# @since		Version 1.0
# @filesource
#

#  ------------------------------------------------------------------------

#
# MySQLi Database Adapter Class - MySQLi only works with PHP 5
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
class CI_DB_mysqli_driver extends CI_DB
  
  dbdriver: 'mysqli'
  
  #  The character used for escaping
  _escape_char: '`'
  
  #  clause and character used for LIKE escape sequences - not used in MySQL
  _like_escape_str: ''
  _like_escape_chr: ''
  
  #
  # The syntax to count rows is slightly different across different
  # database engines, so this string appears in each driver and is
  # used for the count_all() and count_all_results() functions.
  #
  _count_string: "SELECT COUNT(*) AS "
  _random_keyword: ' RAND()'#  database specific random keyword
  
  #
  # Whether to use the MySQL "delete hack" which allows the number
  # of affected rows to be shown. Uses a preg_replace when enabled,
  # adding a bit more processing to all queries.
  #
  delete_hack: true
  
  #  --------------------------------------------------------------------
  
  #
  # Non-persistent database connection
  #
  # @access	private called by the base class
  # @return	resource
  #
  db_connect :  ->
    if @port isnt ''
      return mysqli_connect(@hostname, @username, @password, @database, @port)
      
    else 
      return mysqli_connect(@hostname, @username, @password, @database)
      
    
    
  
  #  --------------------------------------------------------------------
  
  #
  # Persistent database connection
  #
  # @access	private called by the base class
  # @return	resource
  #
  db_pconnect :  ->
    return @db_connect()
    
  
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
    if mysqli_ping(@conn_id) is false
      @conn_id = false
      
    
  
  #  --------------------------------------------------------------------
  
  #
  # Select the database
  #
  # @access	private called by the base class
  # @return	resource
  #
  db_select :  ->
    return mysqli_select_db(@conn_id, @database)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Set client character set
  #
  # @access	private
  # @param	string
  # @param	string
  # @return	resource
  #
  _db_set_charset : ($charset, $collation) ->
    return mysqli_query(@conn_id, "SET NAMES '" + @escape_str($charset) + "' COLLATE '" + @escape_str($collation) + "'")
    
  
  #  --------------------------------------------------------------------
  
  #
  # Version number query string
  #
  # @access	public
  # @return	string
  #
  _version :  ->
    return "SELECT version() AS ver"
    
  
  #  --------------------------------------------------------------------
  
  #
  # Execute the query
  #
  # @access	private called by the base class
  # @param	string	an SQL query
  # @return	resource
  #
  _execute : ($sql) ->
    $sql = @_prep_query($sql)
    $result = mysqli_query(@conn_id, $sql)
    return $result
    
  
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
    #  "DELETE FROM TABLE" returns 0 affected rows This hack modifies
    #  the query so that it returns the number of affected rows
    if @delete_hack is true
      if preg_match('/^\s*DELETE\s+FROM\s+(\S+)\s*$/i', $sql)
        $sql = preg_replace("/^\s*DELETE\s+FROM\s+(\S+)\s*$/", "DELETE FROM \\1 WHERE 1=1", $sql)
        
      
    
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
    
    @simple_query('SET AUTOCOMMIT=0')
    @simple_query('START TRANSACTION')#  can also be BEGIN or BEGIN WORK
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
    @simple_query('SET AUTOCOMMIT=1')
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
    @simple_query('SET AUTOCOMMIT=1')
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
      
    
    if function_exists('mysqli_real_escape_string') and is_object(@conn_id)
      $str = mysqli_real_escape_string(@conn_id, $str)
      
    else if function_exists('mysql_escape_string')
      $str = mysql_escape_string($str)
      
    else 
      $str = addslashes($str)
      
    
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
  affected_rows :  ->
    return mysqli_affected_rows(@conn_id)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Insert ID
  #
  # @access	public
  # @return	integer
  #
  insert_id :  ->
    return mysqli_insert_id(@conn_id)
    
  
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
      
    
    $query = @query(@_count_string + @_protect_identifiers('numrows') + " FROM " + @_protect_identifiers($table, true, null, false))
    
    if $query.num_rows() is 0
      return 0
      
    
    $row = $query.row()
    return $row.numrows
    
  
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
  _list_columns : ($table = '') ->
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
    return mysqli_error(@conn_id)
    
  
  #  --------------------------------------------------------------------
  
  #
  # The error message number
  #
  # @access	private
  # @return	integer
  #
  _error_number :  ->
    return mysqli_errno(@conn_id)
    
  
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
    $ids = {}
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
  _truncate : ($table) ->
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
    $sql+="LIMIT " + $limit
    
    if $offset > 0
      $sql+=" OFFSET " + $offset
      
    
    return $sql
    
  
  #  --------------------------------------------------------------------
  
  #
  # Close DB Connection
  #
  # @access	public
  # @param	resource
  # @return	void
  #
  _close : ($conn_id) ->
    mysqli_close($conn_id)
    
  
  
  

register_class 'CI_DB_mysqli_driver', CI_DB_mysqli_driver
module.exports = CI_DB_mysqli_driver


#  End of file mysqli_driver.php 
#  Location: ./system/database/drivers/mysqli/mysqli_driver.php 