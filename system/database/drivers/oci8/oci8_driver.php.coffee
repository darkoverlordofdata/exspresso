#+--------------------------------------------------------------------+
#  oci8_driver.coffee
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
{OCIcommit, OCIrollback, _protect_identifiers, _reserved_identifiers, _trans_depth, _trans_failure, ar_where, array_key_exists, conn_id, count, db_debug, dbprefix, defined, display_error, escape_like_str, hostname, implode, is_array, is_resource, numrows, ocibindbyname, ocierror, ociexecute, ocilogoff, ocilogon, ocinewcursor, ociparse, ociplogon, ocirowcount, ociserverversion, ocisetprefetch, password, preg_replace, query, row, sprintf, str_replace, strpos, trans_enabled, trim, username}  = require(FCPATH + 'helper')
{config_item, get_class, get_config, is_loaded, load_class, load_new, load_object, log_message, register_class} = require(BASEPATH + 'core/Common')

if not defined('BASEPATH') then die 'No direct script access allowed'
#
# CodeIgniter
#
# An open source application development framework for PHP 5.1.6 or newer
#
# @package		CodeIgniter
# @author		ExpressionEngine Dev Team
# @copyright   Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license		http://codeigniter.com/user_guide/license.html
# @link		http://codeigniter.com
# @since		Version 1.0
# @filesource
#

#  ------------------------------------------------------------------------

#
# oci8 Database Adapter Class
#
# Note: _DB is an extender class that the app controller
# creates dynamically based on whether the active record
# class is being used or not.
#
# @package		CodeIgniter
# @subpackage  Drivers
# @category	Database
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/database/
#

#
# oci8 Database Adapter Class
#
# This is a modification of the DB_driver class to
# permit access to oracle databases
#
# NOTE: this uses the PHP 4 oci methods
#
# @author	  Kelly McArdle
#
#

class CI_DB_oci8_driver extends CI_DB
  
  dbdriver: 'oci8'
  
  #  The character used for excaping
  _escape_char: '"'
  
  #  clause and character used for LIKE escape sequences
  _like_escape_str: " escape '%s' "
  _like_escape_chr: '!'
  
  #
  # The syntax to count rows is slightly different across different
  # database engines, so this string appears in each driver and is
  # used for the count_all() and count_all_results() functions.
  #
  _count_string: "SELECT COUNT(1) AS "
  _random_keyword: ' ASC'#  not currently supported
  
  #  Set "auto commit" by default
  _commit: OCI_COMMIT_ON_SUCCESS
  
  #  need to track statement id and cursor id
  stmt_id: {}
  curs_id: {}
  
  #  if we use a limit, we will add a field that will
  #  throw off num_fields later
  limit_used: {}
  
  #
  # Non-persistent database connection
  #
  # @access  private called by the base class
  # @return  resource
  #
  db_connect :  ->
    return ocilogon(@username, @password, @hostname)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Persistent database connection
  #
  # @access  private called by the base class
  # @return  resource
  #
  db_pconnect :  ->
    return ociplogon(@username, @password, @hostname)
    
  
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
    #  not implemented in oracle
    
  
  #  --------------------------------------------------------------------
  
  #
  # Select the database
  #
  # @access  private called by the base class
  # @return  resource
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
  db_set_charset : ($charset, $collation) ->
    #  @todo - add support if needed
    return true
    
  
  #  --------------------------------------------------------------------
  
  #
  # Version number query string
  #
  # @access  public
  # @return  string
  #
  _version :  ->
    return ociserverversion(@conn_id)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Execute the query
  #
  # @access  private called by the base class
  # @param   string  an SQL query
  # @return  resource
  #
  _execute : ($sql) ->
    #  oracle must parse the query before it is run. All of the actions with
    #  the query are based on the statement id returned by ociparse
    @stmt_id = false
    @_set_stmt_id($sql)
    ocisetprefetch(@stmt_id, 1000)
    return ociexecute(@stmt_id, @_commit)
    
  
  #
  # Generate a statement ID
  #
  # @access  private
  # @param   string  an SQL query
  # @return  none
  #
  _set_stmt_id : ($sql) ->
    if not is_resource(@stmt_id)
      @stmt_id = ociparse(@conn_id, @_prep_query($sql))
      
    
  
  #  --------------------------------------------------------------------
  
  #
  # Prep the query
  #
  # If needed, each database adapter can prep the query string
  #
  # @access  private called by execute()
  # @param   string  an SQL query
  # @return  string
  #
  _prep_query : ($sql) ->
    return $sql
    
  
  #  --------------------------------------------------------------------
  
  #
  # getCursor.  Returns a cursor from the datbase
  #
  # @access  public
  # @return  cursor id
  #
  get_cursor :  ->
    @curs_id = ocinewcursor(@conn_id)
    return @curs_id
    
  
  #  --------------------------------------------------------------------
  
  #
  # Stored Procedure.  Executes a stored procedure
  #
  # @access  public
  # @param   package	 package stored procedure is in
  # @param   procedure   stored procedure to execute
  # @param   params	  array of parameters
  # @return  array
  #
  # params array keys
  #
  # KEY	  OPTIONAL	NOTES
  # name		no		the name of the parameter should be in :<param_name> format
  # value	no		the value of the parameter.  If this is an OUT or IN OUT parameter,
  #					this should be a reference to a variable
  # type		yes		the type of the parameter
  # length	yes		the max size of the parameter
  #
  stored_procedure : ($package, $procedure, $params) ->
    if $package is '' or $procedure is '' or  not is_array($params)
      if @db_debug
        log_message('error', 'Invalid query: ' + $package + '.' + $procedure)
        return @display_error('db_invalid_query')
        
      return false
      
    
    #  build the query string
    $sql = "begin $package.$procedure("
    
    $have_cursor = false
    for $param in $params
      $sql+=$param['name'] + ","
      
      if array_key_exists('type', $param) and ($param['type'] is OCI_B_CURSOR)
        $have_cursor = true
        
      
    $sql = trim($sql, ",") + "); end;"
    
    @stmt_id = false
    @_set_stmt_id($sql)
    @_bind_params($params)
    @query($sql, false, $have_cursor)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Bind parameters
  #
  # @access  private
  # @return  none
  #
  _bind_params : ($params) ->
    if not is_array($params) or  not is_resource(@stmt_id)
      return 
      
    
    for $param in $params
      for $val in ['name', 'value', 'type', 'length']
        if not $param[$val]? 
          $param[$val] = ''
          
        
      
      ocibindbyname(@stmt_id, $param['name'], $param['value'], $param['length'], $param['type'])
      
    
  
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
    
    @_commit = OCI_DEFAULT
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
      
    
    $ret = OCIcommit(@conn_id)
    @_commit = OCI_COMMIT_ON_SUCCESS
    return $ret
    
  
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
      
    
    $ret = OCIrollback(@conn_id)
    @_commit = OCI_COMMIT_ON_SUCCESS
    return $ret
    
  
  #  --------------------------------------------------------------------
  
  #
  # Escape String
  #
  # @access  public
  # @param   string
  # @param	bool	whether or not the string will be used in a LIKE condition
  # @return  string
  #
  escape_str : ($str, $like = false) ->
    if is_array($str)
      for $key, $val of $str
        $str[$key] = @escape_str($val, $like)
        
      
      return $str
      
    
    $str = remove_invisible_characters($str)
    
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
  # @access  public
  # @return  integer
  #
  affected_rows :  ->
    return ocirowcount(@stmt_id)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Insert ID
  #
  # @access  public
  # @return  integer
  #
  insert_id :  ->
    #  not supported in oracle
    return @display_error('db_unsupported_function')
    
  
  #  --------------------------------------------------------------------
  
  #
  # "Count All" query
  #
  # Generates a platform-specific query string that counts all records in
  # the specified database
  #
  # @access  public
  # @param   string
  # @return  string
  #
  count_all : ($table = '') ->
    if $table is ''
      return 0
      
    
    $query = @query(@_count_string + @_protect_identifiers('numrows') + " FROM " + @_protect_identifiers($table, true, null, false))
    
    if $query is false
      return 0
      
    
    $row = $query.row()
    return $row.numrows
    
  
  #  --------------------------------------------------------------------
  
  #
  # Show table query
  #
  # Generates a platform-specific query string so that the table names can be fetched
  #
  # @access  private
  # @param	boolean
  # @return  string
  #
  _list_tables : ($prefix_limit = false) ->
    $sql = "SELECT TABLE_NAME FROM ALL_TABLES"
    
    if $prefix_limit isnt false and @dbprefix isnt ''
      $sql+=" WHERE TABLE_NAME LIKE '" + @escape_like_str(@dbprefix) + "%' " + sprintf(@_like_escape_str, @_like_escape_chr)
      
    
    return $sql
    
  
  #  --------------------------------------------------------------------
  
  #
  # Show column query
  #
  # Generates a platform-specific query string so that the column names can be fetched
  #
  # @access  public
  # @param   string  the table name
  # @return  string
  #
  _list_columns : ($table = '') ->
    return "SELECT COLUMN_NAME FROM all_tab_columns WHERE table_name = '$table'"
    
  
  #  --------------------------------------------------------------------
  
  #
  # Field data query
  #
  # Generates a platform-specific query so that the column data can be retrieved
  #
  # @access  public
  # @param   string  the table name
  # @return  object
  #
  _field_data : ($table) ->
    return "SELECT * FROM " + $table + " where rownum = 1"
    
  
  #  --------------------------------------------------------------------
  
  #
  # The error message string
  #
  # @access  private
  # @return  string
  #
  _error_message :  ->
    $error = ocierror(@conn_id)
    return $error['message']
    
  
  #  --------------------------------------------------------------------
  
  #
  # The error message number
  #
  # @access  private
  # @return  integer
  #
  _error_number :  ->
    $error = ocierror(@conn_id)
    return $error['code']
    
  
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
  # @access  public
  # @param   string  the table name
  # @param   array   the insert keys
  # @param   array   the insert values
  # @return  string
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
    return "TRUNCATE TABLE " + $table
    
  
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
  # @access  public
  # @param   string  the sql query string
  # @param   integer the number of rows to limit the query to
  # @param   integer the offset value
  # @return  string
  #
  _limit : ($sql, $limit, $offset) ->
    $limit = $offset + $limit
    $newsql = "SELECT * FROM (select inner_query.*, rownum rnum FROM ($sql) inner_query WHERE rownum < $limit)"
    
    if $offset isnt 0
      $newsql+=" WHERE rnum >= $offset"
      
    
    #  remember that we used limits
    @limit_used = true
    
    return $newsql
    
  
  #  --------------------------------------------------------------------
  
  #
  # Close DB Connection
  #
  # @access  public
  # @param   resource
  # @return  void
  #
  _close : ($conn_id) ->
    ocilogoff($conn_id)
    
  
  
  

register_class 'CI_DB_oci8_driver', CI_DB_oci8_driver
module.exports = CI_DB_oci8_driver



#  End of file oci8_driver.php 
#  Location: ./system/database/drivers/oci8/oci8_driver.php 