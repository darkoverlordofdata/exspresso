#+--------------------------------------------------------------------+
#  sqlite_utility.coffee
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
{db, db_debug, defined, display_error}	= require(FCPATH + 'helper')
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
# SQLite Utility Class
#
# @category	Database
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/database/
#
class CI_DB_sqlite_utility extends CI_DB_utility
	
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
	_list_databases :  ->
		if @db_debug
			return @db.display_error('db_unsuported_feature')
			
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
	_optimize_table : ($table) ->
		return false
		
	
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
	_repair_table : ($table) ->
		return false
		
	
	#  --------------------------------------------------------------------
	
	#
	# SQLite Export
	#
	# @access	private
	# @param	array	Preferences
	# @return	mixed
	#
	_backup : ($params = {}) ->
		#  Currently unsupported
		return @db.display_error('db_unsuported_feature')
		
	

register_class 'CI_DB_sqlite_utility', CI_DB_sqlite_utility
module.exports = CI_DB_sqlite_utility

#  End of file sqlite_utility.php 
#  Location: ./system/database/drivers/sqlite/sqlite_utility.php 