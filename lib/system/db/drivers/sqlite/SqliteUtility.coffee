#+--------------------------------------------------------------------+
#  SqliteUtility.coffee
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
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @see        http://darkoverlordofdata.com
# @since      Version 1.0
#

#  ------------------------------------------------------------------------

#
# SQLite Utility Class
#
class system.db.sqlite.SqliteUtility extends system.db.Utility
  
  #
  # List databases
  #
  # @access	private
  # @return	bool
  #
  _list_databases :  ->
    if @db_debug then 
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
    
  
module.exports = system.db.sqlite.SqliteUtility

#  End of file SqliteUtility.coffee
#  Location: ./system/db/drivers/sqlite/SqliteUtility.coffee