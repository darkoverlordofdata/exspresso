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
# SQLite Utility Class
#
# @category	Database
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/database/
#
class CI_DB_sqlite_utilityextends CI_DB_utility
	
	#
	# List databases
	#
	# I don't believe you can do a database listing with SQLite
	# since each database is its own file.  I suppose we could
	# try reading a directory looking for SQLite files, but
	# that doesn't seem like a terribly good idea
	#
	# @access	private
	# @return	bool
	#
	_list_databases :  =>
		if @.db_debug
			return @.db.display_error('db_unsuported_feature')
			
		return {}
		
	
	#  --------------------------------------------------------------------
	
	#
	# Optimize table query
	#
	# Is optimization even supported in SQLite?
	#
	# @access	private
	# @param	string	the table name
	# @return	object
	#
	_optimize_table : ($table) =>
		return FALSE
		
	
	#  --------------------------------------------------------------------
	
	#
	# Repair table query
	#
	# Are table repairs even supported in SQLite?
	#
	# @access	private
	# @param	string	the table name
	# @return	object
	#
	_repair_table : ($table) =>
		return FALSE
		
	
	#  --------------------------------------------------------------------
	
	#
	# SQLite Export
	#
	# @access	private
	# @param	array	Preferences
	# @return	mixed
	#
	_backup : ($params = {}) =>
		#  Currently unsupported
		return @.db.display_error('db_unsuported_feature')
		
	

#  End of file sqlite_utility.php 
#  Location: ./system/database/drivers/sqlite/sqlite_utility.php 