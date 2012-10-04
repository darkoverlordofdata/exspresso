#+--------------------------------------------------------------------+
#  DB_driver.coffee
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
{CI_DB_Cache, CI_DB_result, _close, _db_set_charset, _error_message, _error_number, _escape_identifiers, _execute, _field_data, _insert, _list_columns, _list_tables, _update, _version, ar_aliased_tables, array_shift, array_slice, array_splice, call_user_func_array, class_exists, count, current, db_connect, db_pconnect, db_select, debug_backtrace, defined, delete, delete_all, end, escape_str, explode, false, func_get_args, func_num_args, function_exists, implode, in_array, is_array, is_bool, is_null, is_object, is_resource, is_string, line, load, microtime, null, num_rows, number_format, preg_match, preg_replace, read, result_array, result_object, row, str_replace, stristr, strlen, strncmp, strpos, strstr, substr, trans_begin, trans_commit, trans_rollback, trim, write}  = require(FCPATH + 'pal')
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
# Database Driver Class
#
# This is the platform-independent base DB implementation class.
# This class will not be called directly. Rather, the adapter
# class for the specific database will extend and instantiate it.
#
# @package		CodeIgniter
# @subpackage	Drivers
# @category	Database
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/database/
#
class CI_DB_driver
  
  username: {}
  password: {}
  hostname: {}
  database: {}
  dbdriver: 'mysql'
  dbprefix: ''
  char_set: 'utf8'
  dbcollat: 'utf8_general_ci'
  autoinit: true#  Whether to automatically initialize the DB
  swap_pre: ''
  port: ''
  pconnect: false
  conn_id: false
  result_id: false
  db_debug: false
  benchmark: 0
  query_count: 0
  bind_marker: '?'
  save_queries: true
  queries: {}
  query_times: {}
  data_cache: {}
  trans_enabled: true
  trans_strict: true
  _trans_depth: 0
  _trans_status: true#  Used with transactions to determine if a rollback should occur
  cache_on: false
  cachedir: ''
  cache_autodel: false
  CACHE: {}#  The cache class object
  
  #  Private variables
  _protect_identifiers: true
  _reserved_identifiers: ['*']#  Identifiers that should NOT be escaped
  
  #  These are use with Oracle
  stmt_id: {}
  curs_id: {}
  limit_used: {}
  
  
  
  #
  # Constructor.  Accepts one parameter containing the database
  # connection settings.
  #
  # @param array
  #
  constructor : ($params) ->
    if is_array($params)
      for $key, $val of $params
        @[$key] = $val
        
      
    
    log_message('debug', 'Database Driver Class Initialized')
    
  
  #  --------------------------------------------------------------------
  
  #
  # Initialize Database Settings
  #
  # @access	private Called by the constructor
  # @param	mixed
  # @return	void
  #
  initialize :  ->
    #  If an existing connection resource is available
    #  there is no need to connect and select the database
    if is_resource(@conn_id) or is_object(@conn_id)
      return true
      
    
    #  ----------------------------------------------------------------
    
    #  Connect to the database and set the connection ID
    @conn_id = if (@pconnect is false) then @db_connect() else @db_pconnect()
    
    #  No connection resource?  Throw an error
    if not @conn_id
      log_message('error', 'Unable to connect to the database')
      
      if @db_debug
        @display_error('db_unable_to_connect')
        
      return false
      
    
    #  ----------------------------------------------------------------
    
    #  Select the DB... assuming a database name is specified in the config file
    if @database isnt ''
      if not @db_select()
        log_message('error', 'Unable to select database: ' + @database)
        
        if @db_debug
          @display_error('db_unable_to_select', @database)
          
        return false
        
      else 
        #  We've selected the DB. Now we set the character set
        if not @db_set_charset(@char_set, @dbcollat)
          return false
          
        
        return true
        
      
    
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
    if not @_db_set_charset(@char_set, @dbcollat)
      log_message('error', 'Unable to set database connection charset: ' + @char_set)
      
      if @db_debug
        @display_error('db_unable_to_set_charset', @char_set)
        
      
      return false
      
    
    return true
    
  
  #  --------------------------------------------------------------------
  
  #
  # The name of the platform in use (mysql, mssql, etc...)
  #
  # @access	public
  # @return	string
  #
  platform :  ->
    return @dbdriver
    
  
  #  --------------------------------------------------------------------
  
  #
  # Database Version Number.  Returns a string containing the
  # version of the database being used
  #
  # @access	public
  # @return	string
  #
  version :  ->
    if false is ($sql = @_version())
      if @db_debug
        return @display_error('db_unsupported_function')
        
      return false
      
    
    #  Some DBs have functions that return the version, and don't run special
    #  SQL queries per se. In these instances, just return the result.
    $driver_version_exceptions = ['oci8', 'sqlite']
    
    if in_array(@dbdriver, $driver_version_exceptions)
      return $sql
      
    else 
      $query = @query($sql)
      return $query.row('ver')
      
    
  
  #  --------------------------------------------------------------------
  
  #
  # Execute the query
  #
  # Accepts an SQL string as input and returns a result object upon
  # successful execution of a "read" type query.  Returns boolean TRUE
  # upon successful execution of a "write" type query. Returns boolean
  # FALSE upon failure, and if the $db_debug variable is set to TRUE
  # will raise an error.
  #
  # @access	public
  # @param	string	An SQL query string
  # @param	array	An array of binding data
  # @return	mixed
  #
  query : ($sql, $binds = false, $return_object = true) ->
    if $sql is ''
      if @db_debug
        log_message('error', 'Invalid query: ' + $sql)
        return @display_error('db_invalid_query')
        
      return false
      
    
    #  Verify table prefix and replace if necessary
    if (@dbprefix isnt '' and @swap_pre isnt '') and (@dbprefix isnt @swap_pre)
      $sql = preg_replace("/(\W)" + @swap_pre + "(\S+?)/", "\\1" + @dbprefix + "\\2", $sql)
      
    
    #  Is query caching enabled?  If the query is a "read type"
    #  we will load the caching class and return the previously
    #  cached query if it exists
    if @cache_on is true and stristr($sql, 'SELECT')
      if @_cache_init()
        @load_rdriver()
        if false isnt ($cache = @CACHE.read($sql))
          return $cache
          
        
      
    
    #  Compile binds if needed
    if $binds isnt false
      $sql = @compile_binds($sql, $binds)
      
    
    #  Save the  query for debugging
    if @save_queries is true
      @queries.push $sql
      
    
    #  Start the Query Timer
    $time_start = [$sm, $ss] = explode(' ', microtime())
    #  Run the Query
    if false is (@result_id = @simple_query($sql))
      if @save_queries is true
        @query_times.push 0
        
      
      #  This will trigger a rollback if transactions are being used
      @_trans_status = false
      
      if @db_debug
        #  grab the error number and message now, as we might run some
        #  additional queries before displaying the error
        $error_no = @_error_number()
        $error_msg = @_error_message()
        
        #  We call this function in order to roll-back queries
        #  if transactions are enabled.  If we don't call this here
        #  the error message will trigger an exit, causing the
        #  transactions to remain in limbo.
        @trans_complete()
        
        #  Log and display errors
        log_message('error', 'Query error: ' + $error_msg)
        return @display_error([
          'Error Number: ' + $error_no, 
          $error_msg, 
          $sql
          ]
        )
        
      
      return false
      
    
    #  Stop and aggregate the query time results
    $time_end = [$em, $es] = explode(' ', microtime())@benchmark+=($em + $es) - ($sm + $ss)
    
    if @save_queries is true
      @query_times.push ($em + $es) - ($sm + $ss)
      
    
    #  Increment the query counter
    @query_count++
    
    #  Was the query a "write" type?
    #  If so we'll simply return true
    if @is_write_type($sql) is true
      #  If caching is enabled we'll auto-cleanup any
      #  existing files related to this particular URI
      if @cache_on is true and @cache_autodel is true and @_cache_init()
        @CACHE.delete()
        
      
      return true
      
    
    #  Return TRUE if we don't need to create a result object
    #  Currently only the Oracle driver uses this when stored
    #  procedures are used
    if $return_object isnt true
      return true
      
    
    #  Load and instantiate the result driver
    
    $driver = @load_rdriver()
    $RES = new $driver()
    $RES.conn_id = @conn_id
    $RES.result_id = @result_id
    
    if @dbdriver is 'oci8'
      $RES.stmt_id = @stmt_id
      $RES.curs_id = null
      $RES.limit_used = @limit_used
      @stmt_id = false
      
    
    #  oci8 vars must be set before calling this
    $RES.num_rows = $RES.num_rows()
    
    #  Is query caching enabled?  If so, we'll serialize the
    #  result object and save it to a cache file.
    if @cache_on is true and @_cache_init()
      #  We'll create a new instance of the result object
      #  only without the platform specific driver since
      #  we can't use it with cached data (the query result
      #  resource ID won't be any good once we've cached the
      #  result object, so we'll have to compile the data
      #  and save it)
      $CR = new CI_DB_result()
      $CR.num_rows = $RES.num_rows()
      $CR.result_object = $RES.result_object()
      $CR.result_array = $RES.result_array()
      
      #  Reset these since cached objects can not utilize resource IDs.
      $CR.conn_id = null
      $CR.result_id = null
      
      @CACHE.write($sql, $CR)
      
    
    return $RES
    
  
  #  --------------------------------------------------------------------
  
  #
  # Load the result drivers
  #
  # @access	public
  # @return	string	the name of the result class
  #
  load_rdriver :  ->
    $driver = 'CI_DB_' + @dbdriver + '_result'
    
    if not class_exists($driver)
      require(BASEPATH + 'database/DB_result' + EXT)
      require(BASEPATH + 'database/drivers/' + @dbdriver + '/' + @dbdriver + '_result' + EXT)
      
    
    return $driver
    
  
  #  --------------------------------------------------------------------
  
  #
  # Simple Query
  # This is a simplified version of the query() function.  Internally
  # we only use it when running transaction commands since they do
  # not require all the features of the main query() function.
  #
  # @access	public
  # @param	string	the sql query
  # @return	mixed
  #
  simple_query : ($sql) ->
    if not @conn_id
      @initialize()
      
    
    return @_execute($sql)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Disable Transactions
  # This permits transactions to be disabled at run-time.
  #
  # @access	public
  # @return	void
  #
  trans_off :  ->
    @trans_enabled = false
    
  
  #  --------------------------------------------------------------------
  
  #
  # Enable/disable Transaction Strict Mode
  # When strict mode is enabled, if you are running multiple groups of
  # transactions, if one group fails all groups will be rolled back.
  # If strict mode is disabled, each group is treated autonomously, meaning
  # a failure of one group will not affect any others
  #
  # @access	public
  # @return	void
  #
  trans_strict : ($mode = true) ->
    @trans_strict = if is_bool($mode) then $mode else true
    
  
  #  --------------------------------------------------------------------
  
  #
  # Start Transaction
  #
  # @access	public
  # @return	void
  #
  trans_start : ($test_mode = false) ->
    if not @trans_enabled
      return false
      
    
    #  When transactions are nested we only begin/commit/rollback the outermost ones
    if @_trans_depth > 0
      @_trans_depth+=1
      return 
      
    
    @trans_begin($test_mode)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Complete Transaction
  #
  # @access	public
  # @return	bool
  #
  trans_complete :  ->
    if not @trans_enabled
      return false
      
    
    #  When transactions are nested we only begin/commit/rollback the outermost ones
    if @_trans_depth > 1
      @_trans_depth-=1
      return true
      
    
    #  The query() function will set this flag to FALSE in the event that a query failed
    if @_trans_status is false
      @trans_rollback()
      
      #  If we are NOT running in strict mode, we will reset
      #  the _trans_status flag so that subsequent groups of transactions
      #  will be permitted.
      if @trans_strict is false
        @_trans_status = true
        
      
      log_message('debug', 'DB Transaction Failure')
      return false
      
    
    @trans_commit()
    return true
    
  
  #  --------------------------------------------------------------------
  
  #
  # Lets you retrieve the transaction flag to determine if it has failed
  #
  # @access	public
  # @return	bool
  #
  trans_status :  ->
    return @_trans_status
    
  
  #  --------------------------------------------------------------------
  
  #
  # Compile Bindings
  #
  # @access	public
  # @param	string	the sql statement
  # @param	array	an array of bind data
  # @return	string
  #
  compile_binds : ($sql, $binds) ->
    if strpos($sql, @bind_marker) is false
      return $sql
      
    
    if not is_array($binds)
      $binds = [$binds]
      
    
    #  Get the sql segments around the bind markers
    $segments = explode(@bind_marker, $sql)
    
    #  The count of bind should be 1 less then the count of segments
    #  If there are more bind arguments trim it down
    if count($binds)>=count($segments)
      $binds = array_slice($binds, 0, count($segments) - 1)
      
    
    #  Construct the binded query
    $result = $segments[0]
    $i = 0
    for $bind in $binds
      $result+=@escape($bind)
      $result+=$segments[++$i]
      
    
    return $result
    
  
  #  --------------------------------------------------------------------
  
  #
  # Determines if a query is a "write" type.
  #
  # @access	public
  # @param	string	An SQL query string
  # @return	boolean
  #
  is_write_type : ($sql) ->
    if not preg_match('/^\s*"?(SET|INSERT|UPDATE|DELETE|REPLACE|CREATE|DROP|TRUNCATE|LOAD DATA|COPY|ALTER|GRANT|REVOKE|LOCK|UNLOCK)\s+/i', $sql)
      return false
      
    return true
    
  
  #  --------------------------------------------------------------------
  
  #
  # Calculate the aggregate query elapsed time
  #
  # @access	public
  # @param	integer	The number of decimal places
  # @return	integer
  #
  elapsed_time : ($decimals = 6) ->
    return number_format(@benchmark, $decimals)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Returns the total number of queries
  #
  # @access	public
  # @return	integer
  #
  total_queries :  ->
    return @query_count
    
  
  #  --------------------------------------------------------------------
  
  #
  # Returns the last query that was executed
  #
  # @access	public
  # @return	void
  #
  last_query :  ->
    return end(@queries)
    
  
  #  --------------------------------------------------------------------
  
  #
  # "Smart" Escape String
  #
  # Escapes data based on type
  # Sets boolean and null types
  #
  # @access	public
  # @param	string
  # @return	mixed
  #
  escape : ($str) ->
    if is_string($str)
      $str = "'" + @escape_str($str) + "'"
      
    else if is_bool($str)
      $str = if ($str is false) then 0 else 1
      
    else if is_null($str)
      $str = 'NULL'
      
    
    return $str
    
  
  #  --------------------------------------------------------------------
  
  #
  # Escape LIKE String
  #
  # Calls the individual driver for platform
  # specific escaping for LIKE conditions
  #
  # @access	public
  # @param	string
  # @return	mixed
  #
  escape_like_str : ($str) ->
    return @escape_str($str, true)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Primary
  #
  # Retrieves the primary key.  It assumes that the row in the first
  # position is the primary key
  #
  # @access	public
  # @param	string	the table name
  # @return	string
  #
  primary : ($table = '') ->
    $fields = @list_fields($table)
    
    if not is_array($fields)
      return false
      
    
    return current($fields)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Returns an array of table names
  #
  # @access	public
  # @return	array
  #
  list_tables : ($constrain_by_prefix = false) ->
    #  Is there a cached result?
    if @data_cache['table_names']? 
      return @data_cache['table_names']
      
    
    if false is ($sql = @_list_tables($constrain_by_prefix))
      if @db_debug
        return @display_error('db_unsupported_function')
        
      return false
      
    
    $retval = {}
    $query = @query($sql)
    
    if $query.num_rows() > 0
      for $row in $query.result_array()
        if $row['TABLE_NAME']? 
          $retval.push $row['TABLE_NAME']
          
        else 
          $retval.push array_shift($row)
          
        
      
    
    @data_cache['table_names'] = $retval
    return @data_cache['table_names']
    
  
  #  --------------------------------------------------------------------
  
  #
  # Determine if a particular table exists
  # @access	public
  # @return	boolean
  #
  table_exists : ($table_name) ->
    return if ( not in_array(@_protect_identifiers($table_name, true, false, false), @list_tables())) then false else true
    
  
  #  --------------------------------------------------------------------
  
  #
  # Fetch MySQL Field Names
  #
  # @access	public
  # @param	string	the table name
  # @return	array
  #
  list_fields : ($table = '') ->
    #  Is there a cached result?
    if @data_cache['field_names'][$table]? 
      return @data_cache['field_names'][$table]
      
    
    if $table is ''
      if @db_debug
        return @display_error('db_field_param_missing')
        
      return false
      
    
    if false is ($sql = @_list_columns($table))
      if @db_debug
        return @display_error('db_unsupported_function')
        
      return false
      
    
    $query = @query($sql)
    
    $retval = {}
    for $row in $query.result_array()
      if $row['COLUMN_NAME']? 
        $retval.push $row['COLUMN_NAME']
        
      else 
        $retval.push current($row)
        
      
    
    @data_cache['field_names'][$table] = $retval
    return @data_cache['field_names'][$table]
    
  
  #  --------------------------------------------------------------------
  
  #
  # Determine if a particular field exists
  # @access	public
  # @param	string
  # @param	string
  # @return	boolean
  #
  field_exists : ($field_name, $table_name) ->
    return if ( not in_array($field_name, @list_fields($table_name))) then false else true
    
  
  #  --------------------------------------------------------------------
  
  #
  # Returns an object with field data
  #
  # @access	public
  # @param	string	the table name
  # @return	object
  #
  field_data : ($table = '') ->
    if $table is ''
      if @db_debug
        return @display_error('db_field_param_missing')
        
      return false
      
    
    $query = @query(@_field_data(@_protect_identifiers($table, true, null, false)))
    
    return $query.field_data()
    
  
  #  --------------------------------------------------------------------
  
  #
  # Generate an insert string
  #
  # @access	public
  # @param	string	the table upon which the query will be performed
  # @param	array	an associative array data of key/values
  # @return	string
  #
  insert_string : ($table, $data) ->
    $fields = {}
    $values = {}
    
    for $key, $val of $data
      $fields.push @_escape_identifiers($key)
      $values.push @escape($val)
      
    
    return @_insert(@_protect_identifiers($table, true, null, false), $fields, $values)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Generate an update string
  #
  # @access	public
  # @param	string	the table upon which the query will be performed
  # @param	array	an associative array data of key/values
  # @param	mixed	the "where" statement
  # @return	string
  #
  update_string : ($table, $data, $where) ->
    if $where is ''
      return false
      
    
    $fields = {}
    for $key, $val of $data
      $fields[@_protect_identifiers($key)] = @escape($val)
      
    
    if not is_array($where)
      $dest = [$where]
      
    else 
      $dest = {}
      for $key, $val of $where
        $prefix = if (count($dest) is 0) then '' else ' AND '
        
        if $val isnt ''
          if not @_has_operator($key)
            $key+=' ='
            
          
          $val = ' ' + @escape($val)
          
        
        $dest.push $prefix + $key + $val
        
      
    
    return @_update(@_protect_identifiers($table, true, null, false), $fields, $dest)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Tests whether the string has an SQL operator
  #
  # @access	private
  # @param	string
  # @return	bool
  #
  _has_operator : ($str) ->
    $str = trim($str)
    if not preg_match("/(\s|<|>|!|=|is null|is not null)/i", $str)
      return false
      
    
    return true
    
  
  #  --------------------------------------------------------------------
  
  #
  # Enables a native PHP function to be run, using a platform agnostic wrapper.
  #
  # @access	public
  # @param	string	the function name
  # @param	mixed	any parameters needed by the function
  # @return	mixed
  #
  call_function : ($function) ->
    $driver = if (@dbdriver is 'postgre') then 'pg_' else @dbdriver + '_'
    
    if false is strpos($driver, $function)
      $function = $driver + $function
      
    
    if not function_exists($function)
      if @db_debug
        return @display_error('db_unsupported_function')
        
      return false
      
    else 
      $args = if (func_num_args() > 1) then array_splice(func_get_args(), 1) else null
      
      return call_user_func_array($function, $args)
      
    
  
  #  --------------------------------------------------------------------
  
  #
  # Set Cache Directory Path
  #
  # @access	public
  # @param	string	the path to the cache directory
  # @return	void
  #
  cache_set_path : ($path = '') ->
    @cachedir = $path
    
  
  #  --------------------------------------------------------------------
  
  #
  # Enable Query Caching
  #
  # @access	public
  # @return	void
  #
  cache_on :  ->
    @cache_on = true
    return true
    
  
  #  --------------------------------------------------------------------
  
  #
  # Disable Query Caching
  #
  # @access	public
  # @return	void
  #
  cache_off :  ->
    @cache_on = false
    return false
    
  
  
  #  --------------------------------------------------------------------
  
  #
  # Delete the cache files associated with a particular URI
  #
  # @access	public
  # @return	void
  #
  cache_delete : ($segment_one = '', $segment_two = '') ->
    if not @_cache_init()
      return false
      
    return @CACHE.delete($segment_one, $segment_two)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Delete All cache files
  #
  # @access	public
  # @return	void
  #
  cache_delete_all :  ->
    if not @_cache_init()
      return false
      
    
    return @CACHE.delete_all()
    
  
  #  --------------------------------------------------------------------
  
  #
  # Initialize the Cache Class
  #
  # @access	private
  # @return	void
  #
  _cache_init :  ->
    if is_object(@CACHE) and class_exists('CI_DB_Cache')
      return true
      
    
    if not class_exists('CI_DB_Cache')
      if not require(BASEPATH + 'database/DB_cache' + EXT)
        return @cache_off()
        
      
    
    @CACHE = new CI_DB_Cache(@)#  pass db object to support multiple db connections and returned db objects
    return true
    
  
  #  --------------------------------------------------------------------
  
  #
  # Close DB Connection
  #
  # @access	public
  # @return	void
  #
  close :  ->
    if is_resource(@conn_id) or is_object(@conn_id)
      @_close(@conn_id)
      
    @conn_id = false
    
  
  #  --------------------------------------------------------------------
  
  #
  # Display an error message
  #
  # @access	public
  # @param	string	the error message
  # @param	string	any "swap" values
  # @param	boolean	whether to localize the message
  # @return	string	sends the application/error_db.php template
  #
  display_error : ($error = '', $swap = '', $native = false) ->
    $LANG = load_class('Lang', 'core')
    $LANG.load('db')
    
    $heading = $LANG.line('db_error_heading')
    
    if $native is true
      $message = $error
      
    else 
      $message = if ( not is_array($error)) then [str_replace('%s', $swap, $LANG.line($error])) else $error
      
    
    #  Find the most likely culprit of the error by going through
    #  the backtrace until the source file is no longer in the
    #  database folder.
    
    $trace = debug_backtrace()
    
    for $call in $trace
      if $call['file']?  and strpos($call['file'], BASEPATH + 'database') is false
        #  Found it - use a relative path for safety
        $message.push 'Filename: ' + str_replace([BASEPATH, APPPATH], '', $call['file'])
        $message.push 'Line Number: ' + $call['line']
        
        break
        
      
    
    $error = load_class('Exceptions', 'core')
    echo $error.show_error($heading, $message, 'error_db')
    die()
    
  
  #  --------------------------------------------------------------------
  
  #
  # Protect Identifiers
  #
  # This function adds backticks if appropriate based on db type
  #
  # @access	private
  # @param	mixed	the item to escape
  # @return	mixed	the item with backticks
  #
  protect_identifiers : ($item, $prefix_single = false) ->
    return @_protect_identifiers($item, $prefix_single)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Protect Identifiers
  #
  # This function is used extensively by the Active Record class, and by
  # a couple functions in this class.
  # It takes a column or table name (optionally with an alias) and inserts
  # the table prefix onto it.  Some logic is necessary in order to deal with
  # column names that include the path.  Consider a query like this:
  #
  # SELECT * FROM hostname.database.table.column AS c FROM hostname.database.table
  #
  # Or a query with aliasing:
  #
  # SELECT m.member_id, m.member_name FROM members AS m
  #
  # Since the column name can include up to four segments (host, DB, table, column)
  # or also have an alias prefix, we need to do a bit of work to figure this out and
  # insert the table prefix (if it exists) in the proper position, and escape only
  # the correct identifiers.
  #
  # @access	private
  # @param	string
  # @param	bool
  # @param	mixed
  # @param	bool
  # @return	string
  #
  _protect_identifiers : ($item, $prefix_single = false, $protect_identifiers = null, $field_exists = true) ->
    if not is_bool($protect_identifiers)
      $protect_identifiers = @_protect_identifiers
      
    
    if is_array($item)
      $escaped_array = {}
      
      for $k, $v of $item
        $escaped_array[@_protect_identifiers($k)] = @_protect_identifiers($v)
        
      
      return $escaped_array
      
    
    #  Convert tabs or multiple spaces into single spaces
    $item = preg_replace('/[\t ]+/', ' ', $item)
    
    #  If the item has an alias declaration we remove it and set it aside.
    #  Basically we remove everything to the right of the first space
    $alias = ''
    if strpos($item, ' ') isnt false
      $alias = strstr($item, " ")
      $item = substr($item, 0,  - strlen($alias))
      
    
    #  This is basically a bug fix for queries that use MAX, MIN, etc.
    #  If a parenthesis is found we know that we do not need to
    #  escape the data or add a prefix.  There's probably a more graceful
    #  way to deal with this, but I'm not thinking of it -- Rick
    if strpos($item, '(') isnt false
      return $item + $alias
      
    
    #  Break the string apart if it contains periods, then insert the table prefix
    #  in the correct location, assuming the period doesn't indicate that we're dealing
    #  with an alias. While we're at it, we will escape the components
    if strpos($item, '.') isnt false
      $parts = explode('.', $item)
      
      #  Does the first segment of the exploded item match
      #  one of the aliases previously identified?  If so,
      #  we have nothing more to do other than escape the item
      if in_array($parts[0], @ar_aliased_tables)
        if $protect_identifiers is true
          for $key, $val of $parts
            if not in_array($val, @_reserved_identifiers)
              $parts[$key] = @_escape_identifiers($val)
              
            
          
          $item = implode('.', $parts)
          
        return $item + $alias
        
      
      #  Is there a table prefix defined in the config file?  If not, no need to do anything
      if @dbprefix isnt ''
        #  We now add the table prefix based on some logic.
        #  Do we have 4 segments (hostname.database.table.column)?
        #  If so, we add the table prefix to the column name in the 3rd segment.
        if $parts[3]? 
          $i = 2
          
        #  Do we have 3 segments (database.table.column)?
        #  If so, we add the table prefix to the column name in 2nd position
        else if $parts[2]? 
          $i = 1
          
        #  Do we have 2 segments (table.column)?
        #  If so, we add the table prefix to the column name in 1st segment
        else 
          $i = 0
          
        
        #  This flag is set when the supplied $item does not contain a field name.
        #  This can happen when this function is being called from a JOIN.
        if $field_exists is false
          $i++
          
        
        #  Verify table prefix and replace if necessary
        if @swap_pre isnt '' and strncmp($parts[$i], @swap_pre, strlen(@swap_pre)) is 0
          $parts[$i] = preg_replace("/^" + @swap_pre + "(\S+?)/", @dbprefix + "\\1", $parts[$i])
          
        
        #  We only add the table prefix if it does not already exist
        if substr($parts[$i], 0, strlen(@dbprefix)) isnt @dbprefix
          $parts[$i] = @dbprefix + $parts[$i]
          
        
        #  Put the parts back together
        $item = implode('.', $parts)
        
      
      if $protect_identifiers is true
        $item = @_escape_identifiers($item)
        
      
      return $item + $alias
      
    
    #  Is there a table prefix?  If not, no need to insert it
    if @dbprefix isnt ''
      #  Verify table prefix and replace if necessary
      if @swap_pre isnt '' and strncmp($item, @swap_pre, strlen(@swap_pre)) is 0
        $item = preg_replace("/^" + @swap_pre + "(\S+?)/", @dbprefix + "\\1", $item)
        
      
      #  Do we prefix an item with no segments?
      if $prefix_single is true and substr($item, 0, strlen(@dbprefix)) isnt @dbprefix
        $item = @dbprefix + $item
        
      
    
    if $protect_identifiers is true and  not in_array($item, @_reserved_identifiers)
      $item = @_escape_identifiers($item)
      
    
    return $item + $alias
    
  
  
  

register_class 'CI_DB_driver', CI_DB_driver
module.exports = CI_DB_driver


#  End of file DB_driver.php 
#  Location: ./system/database/DB_driver.php 