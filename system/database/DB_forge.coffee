#+--------------------------------------------------------------------+
#  DB_forge.coffee
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
# Database Utility Class
#
# @category	Database
# @author		darkoverlordofdata
# @link		http://darkoverlordofdata.com/user_guide/database/
#
class global.Exspresso_DB_forge

  Exspresso: null
  db: null
  fields: []
  keys: []
  primary_keys: []
  db_char_set: ''
  
  #
  # Constructor
  #
  # Grabs the CI super object instance so we can access it.
  #
  #
  constructor: (@Exspresso, @db) ->

    @_reset() # always initialize arrays in the constructor!
    log_message('debug', "Database Forge Class Initialized")
    

  #
  # Create database
  #
  # @access	public
  # @param	string	the database name
  # @return	bool
  #
  create_database: ($db_name, $next) ->
    $sql = @_create_database($db_name)
    if is_bool($sql)
      $next $sql
      
    @db.query($sql, $next)
    
  
  #
  # Drop database
  #
  # @access	public
  # @param	string	the database name
  # @return	bool
  #
  drop_database: ($db_name, $next) ->
    $sql = @_drop_database($db_name)
    
    if is_bool($sql)
      $next $sql

    @db.query($sql, $next)
    
  
  #
  # Add Key
  #
  # @access	public
  # @param	string	key
  # @param	string	type
  # @return	void
  #
  add_key: ($key = '', $primary = false) ->
    if is_array($key)
      for $one in $key
        @add_key($one, $primary)

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
  # @access	public
  # @param	string	collation
  # @return	void
  #
  add_field: ($field = '') ->
    if $field is ''
      show_error('Field information is required.')
      
    
    if is_string($field)
      if $field is 'id'
        @add_field
          'id':
            'type':'INT', 
            'constraint':9, 
            'auto_increment':true
            
        @add_key 'id', true
        
      else 
        if strpos($field, ' ') is false
          show_error('Field information is required for that operation.')

        @fields.push $field

    if is_array($field)
      @fields = array_merge(@fields, $field)

    
  
  #
  # Create Table
  #
  # @access	public
  # @param	string	the table name
  # @return	bool
  #
  create_table: ($table = '', $if_not_exists = false, $next) ->
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
  # @access	public
  # @param	string	the table name
  # @return	bool
  #
  drop_table: ($table_name, $next) ->
    $sql = @_drop_table(@db.dbprefix + $table_name)
    
    if is_bool($sql)
      $next $sql

    @db.query($sql, $next)
    
  
  #
  # Rename Table
  #
  # @access	public
  # @param	string	the old table name
  # @param	string	the new table name
  # @return	bool
  #
  rename_table: ($table_name, $new_table_name, $next) ->
    if $table_name is '' or $new_table_name is ''
      $next('A table name is required for that operation.')

    $sql = @_rename_table($table_name, $new_table_name)
    @db.query($sql, $next)
    
  
  #
  # Column Add
  #
  # @access	public
  # @param	string	the table name
  # @param	string	the column name
  # @param	string	the column definition
  # @return	bool
  #
  add_column: ($table = '', $field = {}, $after_field = '', $next) ->
    if $table is ''
      $next('A table name is required for that operation.')

    if typeof $next is 'undefined'
      $next = $after_field
      $after_field = ''

    #  add field info into field array, but we can only do one at a time
    #  so we cycle through
    
    for $k, $v of $field
      @add_field array($k, $field[$k])
      
      if count(@fields) is 0
        show_error('Field information is required.')

      $sql = @_alter_table('ADD', @db.dbprefix + $table, @fields, $after_field)
      
      @_reset()
      @db.query($sql, $next)
    
    
  
  #
  # Column Drop
  #
  # @access	public
  # @param	string	the table name
  # @param	string	the column name
  # @return	bool
  #
  drop_column: ($table = '', $column_name = '', $next) ->
    
    if $table is ''
      $next('A table name is required for that operation.')
      
    if $column_name is ''
      $next('A column name is required for that operation.')
      
    
    $sql = @_alter_table('DROP', @db.dbprefix + $table, $column_name)
    
    return @db.query($sql, $next)
    
  
  #
  # Column Modify
  #
  # @access	public
  # @param	string	the table name
  # @param	string	the column name
  # @param	string	the column definition
  # @return	bool
  #
  modify_column: ($table = '', $field = {}, $next) ->
    if $table is ''
      $next('A table name is required for that operation.')

    #  add field info into field array, but we can only do one at a time
    #  so we cycle through
    
    for $k, $v of $field
      #  If no name provided, use the current name
      if not $field[$k]['name']? 
        $field[$k]['name'] = $k

      @add_field array($k, $field[$k])
      
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
  # @access	private
  # @return	void
  #
  _reset :  ->
    @fields = []
    @keys = []
    @primary_keys = []

module.exports = Exspresso_DB_forge

#  End of file DB_forge.coffee
#  Location: ./system/database/DB_forge.coffee