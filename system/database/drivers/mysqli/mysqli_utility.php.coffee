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
# MySQLi Utility Class
#
# @category	Database
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/database/
#
class CI_DB_mysqli_utilityextends CI_DB_utility
	
	#
	# List databases
	#
	# @access	private
	# @return	bool
	#
	_list_databases :  =>
		return "SHOW DATABASES"
		
	
	#  --------------------------------------------------------------------
	
	#
	# Optimize table query
	#
	# Generates a platform-specific query so that a table can be optimized
	#
	# @access	private
	# @param	string	the table name
	# @return	object
	#
	_optimize_table : ($table) =>
		return "OPTIMIZE TABLE " + @.db._escape_identifiers($table)
		
	
	#  --------------------------------------------------------------------
	
	#
	# Repair table query
	#
	# Generates a platform-specific query so that a table can be repaired
	#
	# @access	private
	# @param	string	the table name
	# @return	object
	#
	_repair_table : ($table) =>
		return "REPAIR TABLE " + @.db._escape_identifiers($table)
		
	
	#  --------------------------------------------------------------------
	
	#
	# MySQLi Export
	#
	# @access	private
	# @param	array	Preferences
	# @return	mixed
	#
	_backup : ($params = {}) =>
		#  Currently unsupported
		return @.db.display_error('db_unsuported_feature')
		
	

#  End of file mysqli_utility.php 
#  Location: ./system/database/drivers/mysqli/mysqli_utility.php 