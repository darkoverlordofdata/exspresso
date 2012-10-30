#+--------------------------------------------------------------------+
#  postgre_utility.coffee
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


{db, defined, display_error}  = require(FCPATH + 'lib')


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
# Postgre Utility Class
#
# @category	Database
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/database/
#
class CI_DB_postgre_utility extends CI_DB_utility
  
  #
  # List databases
  #
  # @access	private
  # @return	bool
  #
  _list_databases :  ->
    return "SELECT datname FROM pg_database"
    
  
  #  --------------------------------------------------------------------
  
  #
  # Optimize table query
  #
  # Is table optimization supported in Postgre?
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
  # Are table repairs supported in Postgre?
  #
  # @access	private
  # @param	string	the table name
  # @return	object
  #
  _repair_table : ($table) ->
    return false
    
  
  #  --------------------------------------------------------------------
  
  #
  # Postgre Export
  #
  # @access	private
  # @param	array	Preferences
  # @return	mixed
  #
  _backup : ($params = {}) ->
    #  Currently unsupported
    return @db.display_error('db_unsuported_feature')
    
  

register_class 'CI_DB_postgre_utility', CI_DB_postgre_utility
module.exports = CI_DB_postgre_utility


#  End of file postgre_utility.php 
#  Location: ./system/database/drivers/postgre/postgre_utility.php 