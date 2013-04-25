#+--------------------------------------------------------------------+
#  PostgresForge.coffee
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
# Postgre Forge Class
#
#
module.exports = class system.db.postgres.PostgresForge extends system.db.Forge
  
  #
  # Create database
  #
  # @private
  # @param  [String]  the database name
  # @return	bool
  #
  _create_database : ($name) ->
    "CREATE DATABASE " + $name
    
  
  #
  # Drop database
  #
  # @private
  # @param  [String]  the database name
  # @return	bool
  #
  _drop_database : ($name) ->
    "DROP DATABASE " + $name
    
  
  #
  # Create Table
  #
  # @private
  # @param  [String]  the table name
  # @param  [Array]  the fields
  # @param  [Mixed]  primary key(s)
  # @param  [Mixed]  key(s)
  # @return	[Boolean]ean	should 'IF NOT EXISTS' be added to the SQL
  # @return	bool
  #
  _create_table : ($table, $fields, $primary_keys, $keys, $if_not_exists) ->
    $sql = 'CREATE TABLE '

    if $if_not_exists is true
      $sql+='IF NOT EXISTS '
        
      
    
    $sql+=@db._escape_identifiers($table) + " ("
    $current_field_count = 0
    
    for $field, $attr of $fields
      if 'number' is typeof($field)
        $sql+="\n\t#{$attr}"
        
      else
        $attributes = {}
        $attributes[$key.toUpperCase()] = $val for $key, $val of $attr

        $sql+="\n\t" + @db._protect_identifiers($field)
        
        $is_unsigned = ($attributes.UNSIGNED? and $attributes.UNSIGNED is true)
        
        #  Convert datatypes to be PostgreSQL-compatible
        switch $attributes.TYPE.toUpperCase()
          when 'TINYINT'
            $attributes.TYPE = 'SMALLINT'
            
          when 'SMALLINT'
            $attributes.TYPE = if ($is_unsigned) then 'INTEGER' else 'SMALLINT'
            
          when 'MEDIUMINT'
            $attributes.TYPE = 'INTEGER'
            
          when 'INT'
            $attributes.TYPE = if ($is_unsigned) then 'BIGINT' else 'INTEGER'
            
          when 'BIGINT'
            $attributes.TYPE = if ($is_unsigned) then 'NUMERIC' else 'BIGINT'
            
          when 'DOUBLE'
            $attributes.TYPE = 'DOUBLE PRECISION'
            
          when 'DATETIME'
            $attributes.TYPE = 'TIMESTAMP'
            
          when 'LONGTEXT'
            $attributes.TYPE = 'TEXT'
            
          when 'BLOB'
            $attributes.TYPE = 'BYTEA'
            
            
        
        #  If this is an auto-incrementing primary key, use the serial data type instead
        if $primary_keys.indexOf($field) isnt -1 and $attributes.AUTO_INCREMENT? and $attributes.AUTO_INCREMENT is true
          $sql+=' SERIAL'
          
        else 
          $sql+=' ' + $attributes.TYPE
          
        
        #  Modified to prevent constraints with integer data types
        if $attributes.CONSTRAINT? and $attributes.TYPE.indexOf('INT') is -1
          $sql+='(' + $attributes.CONSTRAINT + ')'
          
        
        if $attributes.DEFAULT?
          $sql+=' DEFAULT \'' + $attributes.DEFAULT + '\''
          
        
        if $attributes.NULL? and $attributes.NULL is true
          $sql+=' NULL'
          
        else 
          $sql+=' NOT NULL'
          
        
        #  Added new attribute to create unqite fields. Also works with MySQL
        if $attributes.UNIQUE? and $attributes.UNIQUE is true
          $sql+=' UNIQUE'

      #  don't add a comma on the end of the last field
      if ++$current_field_count < Object.keys($fields).length
        $sql+=','

    
    if $primary_keys.length > 0
      #  Something seems to break when passing an array to _protect_identifiers()
      for $index, $key of $primary_keys
        $primary_keys[$index] = @db._protect_identifiers($key)
        
      
      $sql+=",\n\tPRIMARY KEY (" + $primary_keys.join(', ') + ")"
      
    
    $sql+="\n);"
    
    if Array.isArray($keys) and $keys.length > 0
      for $key in $keys
        if Array.isArray($key)
          $key = @db._protect_identifiers($key)
          
        else 
          $key = [@db._protect_identifiers($key)]
          
        
        for $field in $key
          $sql+="CREATE INDEX " + $table + "_" + $field.replace(/[\"\']/g, '') + "_index ON #{$table} (#{$field}); "

    return $sql
    
  
  #
  # Drop Table
  #
  # @access    private
  # @return    bool
  #
  _drop_table : ($table) ->
    "DROP TABLE IF EXISTS " + @db._escape_identifiers($table) + " CASCADE"
    
  
  #
  # Alter table query
  #
  # Generates a platform-specific query so that a table can be altered
  # Called by addColumn(), dropColumn(), and column_alter(),
  #
  # @private
  # @param  [String]  the ALTER type (ADD, DROP, CHANGE)
  # @param  [String]  the column name
  # @param  [String]  the table name
  # @param  [String]  the column definition
  # @param  [String]  the default value
  # @return	[Boolean]ean	should 'NOT NULL' be added
  # @param  [String]  the field after which we should add the new field
  # @return [Object]  #
  _alter_table : ($alter_type, $table, $column_name, $column_definition = '', $default_value = '', $null = '', $after_field = '') ->
    $sql = 'ALTER TABLE ' + @db._protect_identifiers($table) + " #{$alter_type} " + @db._protect_identifiers($column_name)
    
    #  DROP has everything it needs now.
    if $alter_type is 'DROP'
      return $sql

    $sql+=" $column_definition"
    
    if $default_value isnt ''
      $sql+=" DEFAULT \"#{$default_value}\""

    if $null is null
      $sql+=' NULL'
      
    else 
      $sql+=' NOT NULL'

    if $after_field isnt ''
      $sql+=' AFTER ' + @db._protect_identifiers($after_field)

    return $sql
    
    
  
  #
  # Rename a table
  #
  # Generates a platform-specific query so that a table can be renamed
  #
  # @private
  # @param  [String]  the old table name
  # @param  [String]  the new table name
  # @return	[String]
  #
  _rename_table : ($table_name, $new_table_name) ->
    $sql = 'ALTER TABLE ' + @db._protect_identifiers($table_name) + " RENAME TO " + @db._protect_identifiers($new_table_name)
    return $sql
    
