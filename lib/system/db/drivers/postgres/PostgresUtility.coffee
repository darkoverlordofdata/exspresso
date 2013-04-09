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
#
# Exspresso
#
# An open source application development framework for coffee-script
#
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @see        http://darkoverlordofdata.com
# @since      Version 1.0
#

#  ------------------------------------------------------------------------

#
# Postgre Utility Class
#
#
class system.db.postgres.PostgresUtility extends system.db.Utility
  
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
    
module.exports = system.db.postgres.PostgresUtility

#  End of file PostgreUtility.coffee
#  Location: ./system/db/drivers/postgres/PostgreUtility.coffee