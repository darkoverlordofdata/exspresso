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
# ODBC Database Adapter Class
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
class CI_DB_odbc_driverextends CI_DB
	
	$dbdriver: 'odbc'
	
	#  the character used to excape - not necessary for ODBC
	$_escape_char: ''
	
	#  clause and character used for LIKE escape sequences
	$_like_escape_str: " {escape '%s'} "
	$_like_escape_chr: '!'
	
	#
	# The syntax to count rows is slightly different across different
	# database engines, so this string appears in each driver and is
	# used for the count_all() and count_all_results() functions.
	#
	$_count_string: "SELECT COUNT(*) AS "
	$_random_keyword: {}
	
	
	CI_DB_odbc_driver : ($params) =>
		parent::CI_DB($params)
		
		@._random_keyword = ' RND(' + time() + ')'#  database specific random keyword
		
	
	#
	# Non-persistent database connection
	#
	# @access	private called by the base class
	# @return	resource
	#
	db_connect :  =>
		return odbc_connect(@.hostname, @.username, @.password)
		
	
	#  --------------------------------------------------------------------
	
	#
	# Persistent database connection
	#
	# @access	private called by the base class
	# @return	resource
	#
	db_pconnect :  =>
		return odbc_pconnect(@.hostname, @.username, @.password)
		
	
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
	reconnect :  =>
		#  not implemented in odbc
		
	
	#  --------------------------------------------------------------------
	
	#
	# Select the database
	#
	# @access	private called by the base class
	# @return	resource
	#
	db_select :  =>
		#  Not needed for ODBC
		return TRUE
		
	
	#  --------------------------------------------------------------------
	
	#
	# Set client character set
	#
	# @access	public
	# @param	string
	# @param	string
	# @return	resource
	#
	db_set_charset : ($charset, $collation) =>
		#  @todo - add support if needed
		return TRUE
		
	
	#  --------------------------------------------------------------------
	
	#
	# Version number query string
	#
	# @access	public
	# @return	string
	#
	_version :  =>
		return "SELECT version() AS ver"
		
	
	#  --------------------------------------------------------------------
	
	#
	# Execute the query
	#
	# @access	private called by the base class
	# @param	string	an SQL query
	# @return	resource
	#
	_execute : ($sql) =>
		$sql = @._prep_query($sql)
		return odbc_exec(@.conn_id, $sql)
		
	
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
	_prep_query : ($sql) =>
		return $sql
		
	
	#  --------------------------------------------------------------------
	
	#
	# Begin Transaction
	#
	# @access	public
	# @return	bool
	#
	trans_begin : ($test_mode = FALSE) =>
		if not @.trans_enabled
			return TRUE
			
		
		#  When transactions are nested we only begin/commit/rollback the outermost ones
		if @._trans_depth > 0
			return TRUE
			
		
		#  Reset the transaction failure flag.
		#  If the $test_mode flag is set to TRUE transactions will be rolled back
		#  even if the queries produce a successful result.
		@._trans_failure = if ($test_mode is TRUE) then TRUE else FALSE
		
		return odbc_autocommit(@.conn_id, FALSE)
		
	
	#  --------------------------------------------------------------------
	
	#
	# Commit Transaction
	#
	# @access	public
	# @return	bool
	#
	trans_commit :  =>
		if not @.trans_enabled
			return TRUE
			
		
		#  When transactions are nested we only begin/commit/rollback the outermost ones
		if @._trans_depth > 0
			return TRUE
			
		
		$ret = odbc_commit(@.conn_id)
		odbc_autocommit(@.conn_id, TRUE)
		return $ret
		
	
	#  --------------------------------------------------------------------
	
	#
	# Rollback Transaction
	#
	# @access	public
	# @return	bool
	#
	trans_rollback :  =>
		if not @.trans_enabled
			return TRUE
			
		
		#  When transactions are nested we only begin/commit/rollback the outermost ones
		if @._trans_depth > 0
			return TRUE
			
		
		$ret = odbc_rollback(@.conn_id)
		odbc_autocommit(@.conn_id, TRUE)
		return $ret
		
	
	#  --------------------------------------------------------------------
	
	#
	# Escape String
	#
	# @access	public
	# @param	string
	# @param	bool	whether or not the string will be used in a LIKE condition
	# @return	string
	#
	escape_str : ($str, $like = FALSE) =>
		if is_array($str)
			for $val, $key in as
				$str[$key] = @.escape_str($val, $like)
				
			
			return $str
			
		
		#  ODBC doesn't require escaping
		$str = remove_invisible_characters($str)
		
		#  escape LIKE condition wildcards
		if $like is TRUE
			$str = str_replace(['%', '_', @._like_escape_chr], 
			[@._like_escape_chr + '%', @._like_escape_chr + '_', @._like_escape_chr + @._like_escape_chr], 
			$str)
			
		
		return $str
		
	
	#  --------------------------------------------------------------------
	
	#
	# Affected Rows
	#
	# @access	public
	# @return	integer
	#
	affected_rows :  =>
		return odbc_num_rows(@.conn_id)
		
	
	#  --------------------------------------------------------------------
	
	#
	# Insert ID
	#
	# @access	public
	# @return	integer
	#
	insert_id :  =>
		return odbc_insert_id(@.conn_id)
		
	
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
	count_all : ($table = '') =>
		if $table is ''
			return 0
			
		
		$query = @.query(@._count_string + @._protect_identifiers('numrows') + " FROM " + @._protect_identifiers($table, TRUE, NULL, FALSE))
		
		if $query.num_rows() is 0
			return 0
			
		
		$row = $query.row()
		return $row.numrows
		
	
	#  --------------------------------------------------------------------
	
	#
	# Show table query
	#
	# Generates a platform-specific query string so that the table names can be fetched
	#
	# @access	private
	# @param	boolean
	# @return	string
	#
	_list_tables : ($prefix_limit = FALSE) =>
		$sql = "SHOW TABLES FROM `" + @.database + "`"
		
		if $prefix_limit isnt FALSE and @.dbprefix isnt ''
			# $sql .= " LIKE '".$this->escape_like_str($this->dbprefix)."%' ".sprintf($this->_like_escape_str, $this->_like_escape_chr);
			return FALSE#  not currently supported
			
		
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
	_list_columns : ($table = '') =>
		return "SHOW COLUMNS FROM " + $table
		
	
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
	_field_data : ($table) =>
		return "SELECT TOP 1 FROM " + $table
		
	
	#  --------------------------------------------------------------------
	
	#
	# The error message string
	#
	# @access	private
	# @return	string
	#
	_error_message :  =>
		return odbc_errormsg(@.conn_id)
		
	
	#  --------------------------------------------------------------------
	
	#
	# The error message number
	#
	# @access	private
	# @return	integer
	#
	_error_number :  =>
		return odbc_error(@.conn_id)
		
	
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
	_escape_identifiers : ($item) =>
		if @._escape_char is ''
			return $item
			
		
		for $id in as
			if strpos($item, '.' + $id) isnt FALSE
				$str = @._escape_char + str_replace('.', @._escape_char + '.', $item)
				
				#  remove duplicates if the user already included the escape
				return preg_replace('/[' + @._escape_char + ']+/', @._escape_char, $str)
				
			
		
		if strpos($item, '.') isnt FALSE
			$str = @._escape_char + str_replace('.', @._escape_char + '.' + @._escape_char, $item) + @._escape_char
			
		else 
			$str = @._escape_char + $item + @._escape_char
			
		
		#  remove duplicates if the user already included the escape
		return preg_replace('/[' + @._escape_char + ']+/', @._escape_char, $str)
		
	
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
	_from_tables : ($tables) =>
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
	_insert : ($table, $keys, $values) =>
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
	_update : ($table, $values, $where, $orderby = {}, $limit = FALSE) =>
		for $val, $key in as
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
	_truncate : ($table) =>
		return @._delete($table)
		
	
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
	_delete : ($table, $where = {}, $like = {}, $limit = FALSE) =>
		$conditions = ''
		
		if count($where) > 0 or count($like) > 0
			$conditions = "\nWHERE "
			$conditions+=implode("\n", @.ar_where)
			
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
	_limit : ($sql, $limit, $offset) =>
		#  Does ODBC doesn't use the LIMIT clause?
		return $sql
		
	
	#  --------------------------------------------------------------------
	
	#
	# Close DB Connection
	#
	# @access	public
	# @param	resource
	# @return	void
	#
	_close : ($conn_id) =>
		odbc_close($conn_id)
		
	
	
	



#  End of file odbc_driver.php 
#  Location: ./system/database/drivers/odbc/odbc_driver.php 