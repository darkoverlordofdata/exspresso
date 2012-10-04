#+--------------------------------------------------------------------+
#  mssql_driver.coffee
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
{_protect_identifiers, _reserved_identifiers, _trans_depth, _trans_failure, ar_where, conn_id, count, database, dbprefix, defined, hostname, implode, is_array, last_id, mssql_close, mssql_connect, mssql_get_last_message, mssql_pconnect, mssql_query, mssql_rows_affected, mssql_select_db, num_rows, numrows, password, port, preg_match, preg_replace, query, row, self, simple_query, str_replace, strpos, trans_enabled, username, version}  = require(FCPATH + 'helper')
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
# MS SQL Database Adapter Class
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
class CI_DB_mssql_driver extends CI_DB
  
  dbdriver: 'mssql'
  
  #  The character used for escaping
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
  _random_keyword: ' ASC'#  not currently supported
  
  #
  # Non-persistent database connection
  #
  # @access	private called by the base class
  # @return	resource
  #
  db_connect :  ->
    if @port isnt ''
      @hostname+=',' + @port
      
    
    return mssql_connect(@hostname, @username, @password)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Persistent database connection
  #
  # @access	private called by the base class
  # @return	resource
  #
  db_pconnect :  ->
    if @port isnt ''
      @hostname+=',' + @port
      
    
    return mssql_pconnect(@hostname, @username, @password)
    
  
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
    #  not implemented in MSSQL
    
  
  #  --------------------------------------------------------------------
  
  #
  # Select the database
  #
  # @access	private called by the base class
  # @return	resource
  #
  db_select :  ->
    #  Note: The brackets are required in the event that the DB name
    #  contains reserved characters
    return mssql_select_db('[' + @database + ']', @conn_id)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Set client character set
  #
  # @access	public
  # @param	string
  # @param	string
  # @return	resource
  #
  db_set_charset : ($charset, $collation) ->
    #  @todo - add support if needed
    return true
    
  
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
    return mssql_query($sql, @conn_id)
    
  
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
    
    @simple_query('BEGIN TRAN')
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
      
    
    @simple_query('COMMIT TRAN')
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
      
    
    @simple_query('ROLLBACK TRAN')
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
      
    
    #  Escape single quotes
    $str = str_replace("'", "''", remove_invisible_characters($str))
    
    #  escape LIKE condition wildcards
    if $like is true
      $str = str_replace([@_like_escape_chr, '%', '_'], 
      [@_like_escape_chr + @_like_escape_chr, @_like_escape_chr + '%', @_like_escape_chr + '_'], 
      $str
      )
      
    
    return $str
    
  
  #  --------------------------------------------------------------------
  
  #
  # Affected Rows
  #
  # @access	public
  # @return	integer
  #
  affected_rows :  ->
    return mssql_rows_affected(@conn_id)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Insert ID
  #
  # Returns the last id created in the Identity column.
  #
  # @access public
  # @return integer
  #
  insert_id :  ->
    $ver = self::_parse_major_version(@version())
    $sql = if ($ver>=8 then "SELECT SCOPE_IDENTITY() AS last_id" else "SELECT @@IDENTITY AS last_id")
    $query = @query($sql)
    $row = $query.row()
    return $row.last_id
    
  
  #  --------------------------------------------------------------------
  
  #
  # Parse major version
  #
  # Grabs the major version number from the
  # database server version string passed in.
  #
  # @access private
  # @param string $version
  # @return int16 major version number
  #
  _parse_major_version : ($version) ->
    preg_match('/([0-9]+)\.([0-9]+)\.([0-9]+)/', $version, $ver_info)
    return $ver_info[1]#  return the major version b/c that's all we're interested in.
    
  
  #  --------------------------------------------------------------------
  
  #
  # Version number query string
  #
  # @access public
  # @return string
  #
  _version :  ->
    return "SELECT @@VERSION AS ver"
    
  
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
    $sql = "SELECT name FROM sysobjects WHERE type = 'U' ORDER BY name"
    
    #  for future compatibility
    if $prefix_limit isnt false and @dbprefix isnt ''
      # $sql .= " LIKE '".$this->escape_like_str($this->dbprefix)."%' ".sprintf($this->_like_escape_str, $this->_like_escape_chr);
      return false#  not currently supported
      
    
    return $sql
    
  
  #  --------------------------------------------------------------------
  
  #
  # List column query
  #
  # Generates a platform-specific query string so that the column names can be fetched
  #
  # @access	private
  # @param	string	the table name
  # @return	string
  #
  _list_columns : ($table = '') ->
    return "SELECT * FROM INFORMATION_SCHEMA.Columns WHERE TABLE_NAME = '" + $table + "'"
    
  
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
    return "SELECT TOP 1 * FROM " + $table
    
  
  #  --------------------------------------------------------------------
  
  #
  # The error message string
  #
  # @access	private
  # @return	string
  #
  _error_message :  ->
    return mssql_get_last_message()
    
  
  #  --------------------------------------------------------------------
  
  #
  # The error message number
  #
  # @access	private
  # @return	integer
  #
  _error_number :  ->
    #  Are error numbers supported?
    return ''
    
  
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
      
    
    return implode(', ', $tables)
    
  
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
    $i = $limit + $offset
    
    return preg_replace('/(^\SELECT (DISTINCT)?)/i', '\\1 TOP ' + $i + ' ', $sql)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Close DB Connection
  #
  # @access	public
  # @param	resource
  # @return	void
  #
  _close : ($conn_id) ->
    mssql_close($conn_id)
    
  
  

register_class 'CI_DB_mssql_driver', CI_DB_mssql_driver
module.exports = CI_DB_mssql_driver



#  End of file mssql_driver.php 
#  Location: ./system/database/drivers/mssql/mssql_driver.php 