#+--------------------------------------------------------------------+
#  postgre_utility.coffee
#+--------------------------------------------------------------------+
#  Copyright DarkOverlordOfData (c) 2012 - 2013
#+--------------------------------------------------------------------+
#
#  This file is a part of Exspresso
#
#  Exspresso is free software you can copy, modify, and distribute
#  it under the terms of the MIT License
#
#+--------------------------------------------------------------------+
#
# This file was ported from CodeIgniter to coffee-script using php2coffee
#
#
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @package    Exspresso
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license    MIT License
# @link       http://darkoverlordofdata.com
# @since      Version 1.0
#

#  ------------------------------------------------------------------------

#
# Postgre Utility Class
#
# @category	Database
# @author		darkoverlordofdata
# @link		http://darkoverlordofdata.com/user_guide/database/
#
class global.Exspresso_DB_postgres_utility extends Exspresso_DB_utility
  
  #
  # List databases
  #
  # @access	private
  # @return	bool
  #
  _list_databases :  ->
    return "SELECT datname FROM pg_database"
    
  
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
    
module.exports = Exspresso_DB_postgres_utility

#  End of file postgres_utility.php
#  Location: ./system/database/drivers/postgres/postgres_utility.php