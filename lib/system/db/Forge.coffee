#+--------------------------------------------------------------------+
#  Forge.coffee
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
# Database Utility Class
#
#
class system.db.Forge

  db            : null
  fields        : []
  keys          : []
  primary_keys  : []
  db_char_set   : ''
  
  #
  # Constructor
  #
  # Grabs the CI super object instance so we can access it.
  #
  #
  constructor: ($controller, $db) ->

    @db = $db
    @_reset() # always initialize arrays in the constructor!
    log_message('debug', "Database Forge Class Initialized")
    

  #
  # Create database
  #
    # @param  [String]  the database name
  # @return	bool
  #
  createDatabase: ($db_name, $next) ->
    $sql = @_create_database($db_name)
    if is_bool($sql)
      $next $sql
      
    @db.query($sql, $next)
    
  
  #
  # Drop database
  #
    # @param  [String]  the database name
  # @return	bool
  #
  dropDatabase: ($db_name, $next) ->
    $sql = @_drop_database($db_name)
    
    if is_bool($sql)
      $next $sql

    @db.query($sql, $next)
    
  
  #
  # Add Key
  #
    # @param  [String]  key
  # @param  [String]  type
  # @return [Void]  #
  addKey: ($key = '', $primary = false) ->
    if is_array($key)
      for $one in $key
        @addKey($one, $primary)

      return

    if $key is ''
      show_error('Key information is required for that operation.')

    if $primary is true
      @primary_keys.push $key
      
    else 
      @keys.push $key
      
    
  
  #
  # Add Field
  #
    # @param  [String]  collation
  # @return [Void]  #
  addField: ($field = '') ->
    if $field is ''
      show_error('Field information is required.')
      
    
    if is_string($field)
      if $field is 'id'
        @addField
          'id':
            'type':'INT', 
            'constraint':9, 
            'auto_increment':true
            
        @addKey 'id', true
        
      else 
        if strpos($field, ' ') is false
          show_error('Field information is required for that operation.')

        @fields.push $field

    if is_array($field)
      @fields = array_merge(@fields, $field)

    
  
  #
  # Create Table
  #
    # @param  [String]  the table name
  # @return	bool
  #
  createTable: ($table = '', $if_not_exists = false, $next) ->
    log_message 'debug', '>DB_forge::create_database'
    if typeof $if_not_exists is 'function'
      $next = $if_not_exists
      $if_not_exists = false

    if $table is ''
      show_error 'A table name is required for that operation.'

    if count(@fields) is 0
      show_error 'Field information is required.'

    $sql = @_create_table(@db.dbprefix + $table, @fields, @primary_keys, @keys, $if_not_exists)
    log_message 'debug', '>SQL: %s', $sql
    @_reset()
    @db.query $sql, $next

  
  #
  # Drop Table
  #
    # @param  [String]  the table name
  # @return	bool
  #
  dropTable: ($table_name, $next) ->
    $sql = @_drop_table(@db.dbprefix + $table_name)
    
    if is_bool($sql)
      $next $sql

    @db.query($sql, $next)
    
  
  #
  # Rename Table
  #
    # @param  [String]  the old table name
  # @param  [String]  the new table name
  # @return	bool
  #
  renameTable: ($table_name, $new_table_name, $next) ->
    if $table_name is '' or $new_table_name is ''
      $next('A table name is required for that operation.')

    $sql = @_rename_table($table_name, $new_table_name)
    @db.query($sql, $next)
    
  
  #
  # Column Add
  #
    # @param  [String]  the table name
  # @param  [String]  the column name
  # @param  [String]  the column definition
  # @return	bool
  #
  addColumn: ($table = '', $field = {}, $after_field = '', $next) ->
    if $table is ''
      $next('A table name is required for that operation.')

    if typeof $next is 'undefined'
      $next = $after_field
      $after_field = ''

    #  add field info into field array, but we can only do one at a time
    #  so we cycle through
    
    for $k, $v of $field
      @addField array($k, $field[$k])
      
      if count(@fields) is 0
        show_error('Field information is required.')

      $sql = @_alter_table('ADD', @db.dbprefix + $table, @fields, $after_field)
      
      @_reset()
      @db.query($sql, $next)
    
    
  
  #
  # Column Drop
  #
    # @param  [String]  the table name
  # @param  [String]  the column name
  # @return	bool
  #
  dropColumn: ($table = '', $column_name = '', $next) ->
    
    if $table is ''
      $next('A table name is required for that operation.')
      
    if $column_name is ''
      $next('A column name is required for that operation.')
      
    
    $sql = @_alter_table('DROP', @db.dbprefix + $table, $column_name)
    
    return @db.query($sql, $next)
    
  
  #
  # Column Modify
  #
    # @param  [String]  the table name
  # @param  [String]  the column name
  # @param  [String]  the column definition
  # @return	bool
  #
  modifyColumn: ($table = '', $field = {}, $next) ->
    if $table is ''
      $next('A table name is required for that operation.')

    #  add field info into field array, but we can only do one at a time
    #  so we cycle through
    
    for $k, $v of $field
      #  If no name provided, use the current name
      if not $field[$k]['name']? 
        $field[$k]['name'] = $k

      @addField array($k, $field[$k])
      
      if count(@fields) is 0
        show_error('Field information is required.')

      $sql = @_alter_table('CHANGE', @db.dbprefix + $table, @fields)
      
      @_reset()
      @db.query($sql, $next)

  
  #
  # Reset
  #
  # Resets table creation vars
  #
  # @private
  # @return [Void]  #
  _reset :  ->
    @fields = []
    @keys = []
    @primary_keys = []

module.exports = system.db.Forge

#  End of file Forge.coffee
#  Location: ./system/database/Forge.coffee