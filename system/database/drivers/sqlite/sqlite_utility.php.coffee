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
# This file was ported from CodeIgniter to coffee-script using php2coffee
#
#


{db, db_debug, defined, display_error}  = require(FCPATH + 'lib')


if not defined('BASEPATH') then die 'No direct script access allowed'
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @package		Exspresso
# @author		darkoverlordofdata
# @copyright	Copyright (c) 2012, Dark Overlord of Data
# @license		MIT License
# @link		http://darkoverlordofdata.com
# @since		Version 1.0
# @filesource
#

#  ------------------------------------------------------------------------

#
# SQLite Utility Class
#
# @category	Database
# @author		darkoverlordofdata
# @link		http://darkoverlordofdata.com/user_guide/database/
#
class Exspresso_DB_sqlite_utility extends Exspresso_DB_utility
  
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
    
  

register_class 'Exspresso_DB_sqlite_utility', Exspresso_DB_sqlite_utility
module.exports = Exspresso_DB_sqlite_utility

#  End of file sqlite_utility.php 
#  Location: ./system/database/drivers/sqlite/sqlite_utility.php 