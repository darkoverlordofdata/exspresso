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
# Abstract Database Utility Class
#
#
module.exports = class system.db.Forge

  #
  # @property [system.core.Controller] The page controller
  #
  controller: null
  #
  # @property [system.db.Driver] The db connection
  #
  db: null
  #
  # @property [Object] Hash of field names: attributes
  #
  fields: null
  #
  # @property [Array] List of key field names
  #
  keys: null
  #
  # @property [Array] List of primary key field names
  #
  primary_keys: null
  #
  # @property [Object] data object
  #
  data: null

  #
  # Constructor
  #
  #
  constructor: ($controller, $db) ->


    Object.defineProperties @,
      controller        : {enumerable: true, writeable: false, value: $controller}
      db                : {enumerable: true, writeable: false, value: $db}
    @_reset()

    log_message('debug', "Database Forge Class Initialized")
    

  #
  # Create database
  #
  # @param  [String]  the database name
  # @return	bool
  #
  createDatabase: ($db_name, $next) ->

    $sql = @_create_database($db_name)

    if 'boolean' is typeof($sql)
      return $next(null) if $sql
      return show_error('Unable to create database %s', $db_name)

    @db.query($sql, $next)
    
  
  #
  # Drop database
  #
  # @param  [String]  the database name
  # @return	bool
  #
  dropDatabase: ($db_name, $next) ->
    $sql = @_drop_database($db_name)
    if 'boolean' is typeof($sql)
      return $next null, $sql

    @db.query($sql, $next)
    
  
  #
  # Add Key
  #
  # @param  [String]  key
  # @param  [String]  type
  # @return [Void]
  #
  addKey: ($key = '', $primary = false) ->
    if 'object' is typeof($key)
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
  # @return [Void]
  #
  addField: ($field = '') ->
    if $field is ''
      show_error('Field information is required.')

    if 'string' is typeof($field)
      if $field is 'id'
        @addField
          'id':
            'type':'INT', 
            'constraint':9, 
            'auto_increment':true
            
        @addKey 'id', true
        
      else 
        if $field.indexOf(' ') is -1
          show_error('Field information is required for that operation.')

        @fields.push $field

    else
      @fields[$key] = $val for $key, $val of $field

  #
  # Add Data
  #
  # @param  [mixed]  data the initial data load
  # @return [Void]
  #
  addData: ($data) ->

    if Array.isArray($data)
      @data = $data
    else
      if @data is null
        @data = [$data]
      else
        @data.push $data
  
  #
  # Create Table
  #
  # @param  [String]  table the table name
  # @param  [Function]  next  async callback
  # @param  [Function]  def definition callback
  # @return	[Void]
  #
  createTable: ($table = '', $next, $def) ->

    if $table is ''
      show_error 'A table name is required for that operation.'

    @db.tableExists $table, ($err, $table_exists) =>

      return $next($err) if $err
      return $next(null) if $table_exists

      if $def? # call the table definition function
        @data = null
        @_reset()
        $def(@)

      if Object.keys(@fields).length is 0
        show_error 'Field information is required.'

      $sql = @_create_table(@db.dbprefix + $table, @fields, @primary_keys, @keys, false)
      @_reset()
      @db.query $sql, ($err) =>

        return log_message('error', 'Error creating table %s: %s', $table, $err.message) if $err?

        if @data isnt null then @db.insertBatch($table, @data, $next)
        else $next(null)


  
  #
  # Drop Table
  #
  # @param  [String]  the table name
  # @return	bool
  #
  dropTable: ($table_name, $next) ->
    $sql = @_drop_table(@db.dbprefix + $table_name)

    if 'boolean' is typeof($sql)
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
      
      if keys(@fields).length is 0
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
      
      if @fields.length is 0
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
  # @return [Void]
  #
  _reset :  ->
    @fields = {}
    @keys = []
    @primary_keys = []

