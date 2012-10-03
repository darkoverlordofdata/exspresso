#+--------------------------------------------------------------------+
#  odbc_utility.coffee
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
# ODBC Utility Class
#
# @category	Database
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/database/
#
class CI_DB_odbc_utility extends CI_DB_utility
	
	#
	# List databases
	#
	# @access	private
	# @return	bool
	#
	_list_databases :  ->
		#  Not sure if ODBC lets you list all databases...
		if @db.db_debug
			return @db.display_error('db_unsuported_feature')
			
		return false
		
	
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
	_optimize_table : ($table) ->
		#  Not a supported ODBC feature
		if @db.db_debug
			return @db.display_error('db_unsuported_feature')
			
		return false
		
	
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
	_repair_table : ($table) ->
		#  Not a supported ODBC feature
		if @db.db_debug
			return @db.display_error('db_unsuported_feature')
			
		return false
		
	
	#  --------------------------------------------------------------------
	
	#
	# ODBC Export
	#
	# @access	private
	# @param	array	Preferences
	# @return	mixed
	#
	_backup : ($params = {}) ->
		#  Currently unsupported
		return @db.display_error('db_unsuported_feature')
		
	
	

register_class 'CI_DB_odbc_utility', CI_DB_odbc_utility
module.exports = CI_DB_odbc_utility

#  End of file odbc_utility.php 
#  Location: ./system/database/drivers/odbc/odbc_utility.php 