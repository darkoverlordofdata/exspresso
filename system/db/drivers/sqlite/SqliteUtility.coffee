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
# SQLite Utility Class
#
module.exports = class system.db.sqlite.SqliteUtility extends system.db.Utility
  
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
    
  
  #
  # Optimize table query
  #
  # @access	private
  # @param	string	the table name
  # @return	object
  #
  _optimize_table : ($table) ->
    #  Currently unsupported
    return @db.display_error('db_unsuported_feature')
    
  
  #
  # Repair table query
  #
  # @access	private
  # @param	string	the table name
  # @return	object
  #
  _repair_table : ($table) ->
    #  Currently unsupported
    return @db.display_error('db_unsuported_feature')
    
  
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
    
