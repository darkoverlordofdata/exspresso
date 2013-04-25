#+--------------------------------------------------------------------+
#  PostgreUtility.coffee
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
# Postgre Utility Class
#
#
module.exports = class system.db.postgres.PostgresUtility extends system.db.Utility
  
  #
  # List databases
  #
  # @private
  # @return	bool
  #
  _list_databases :  ->
    "SELECT datname FROM pg_database"
    
  
  #
  # Optimize table query
  #
  # Is table optimization supported in Postgre?
  #
  # @private
  # @param  [String]  the table name
  # @return [Object]  #
  _optimize_table : ($table) ->
    false
    
  
  #
  # Repair table query
  #
  # Are table repairs supported in Postgre?
  #
  # @private
  # @param  [String]  the table name
  # @return [Object]  #
  _repair_table : ($table) ->
    false
    
  
  #
  # Postgre Export
  #
  # @private
  # @param  [Array]  Preferences
  # @return [Mixed]  #
  _backup : ($params = {}) ->
    #  Currently unsupported
    @db.display_error('db_unsuported_feature')
    
