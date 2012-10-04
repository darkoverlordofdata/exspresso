#+--------------------------------------------------------------------+
#  mssql_utility.coffee
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
{db, defined, display_error}  = require(FCPATH + 'helper')
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
# MS SQL Utility Class
#
# @category	Database
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/database/
#
class CI_DB_mssql_utility extends CI_DB_utility
  
  #
  # List databases
  #
  # @access	private
  # @return	bool
  #
  _list_databases :  ->
    return "EXEC sp_helpdb"#  Can also be: EXEC sp_databases
    
  
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
    return false#  Is this supported in MS SQL?
    
  
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
    return false#  Is this supported in MS SQL?
    
  
  #  --------------------------------------------------------------------
  
  #
  # MSSQL Export
  #
  # @access	private
  # @param	array	Preferences
  # @return	mixed
  #
  _backup : ($params = {}) ->
    #  Currently unsupported
    return @db.display_error('db_unsuported_feature')
    
  
  

register_class 'CI_DB_mssql_utility', CI_DB_mssql_utility
module.exports = CI_DB_mssql_utility

#  End of file mssql_utility.php 
#  Location: ./system/database/drivers/mssql/mssql_utility.php 