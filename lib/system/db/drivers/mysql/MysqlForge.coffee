#+--------------------------------------------------------------------+
#  mysql_forge.coffee
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
# @author     darkoverlordofdata
# @copyright  Copyright (c) 2012 - 2013, Dark Overlord of Data
# @copyright  Copyright (c) 2008 - 2011, EllisLab, Inc.
# @see        http://darkoverlordofdata.com
# @since      Version 1.0
#

#  ------------------------------------------------------------------------

#
# MySQL Forge Class
#
#
class system.db.mysql.MysqlForge extends system.db.Forge
  
  #
  # Create database
  #
  # @private
  # @param  [String]  the database name
  # @return	bool
  #
  _create_database : ($name) ->
    return "CREATE DATABASE " + $name
    
  
  #
  # Drop database
  #
  # @private
  # @param  [String]  the database name
  # @return	bool
  #
  _drop_database : ($name) ->
    return "DROP DATABASE " + $name
    
  
  #
  # Process Fields
  #
  # @private
  # @param  [Mixed]  the fields
  # @return	[String]
  #
  _process_fields : ($fields) ->
    $current_field_count = 0
    $sql = ''
    
    for $field, $attributes of $fields
      #  Numeric field names aren't allowed in databases, so if the key is
      #  numeric, we know it was assigned by PHP and the developer manually
      #  entered the field information, so we'll simply add it to the list
      if is_numeric($field)
        $sql+="\n\t#{$attributes}"
        
      else
        $attributes = array_change_key_case($attributes, CASE_UPPER)

        $sql+="\n\t" + @db._protect_identifiers($field)
        
        if array_key_exists('NAME', $attributes)
          $sql+=' ' + @db._protect_identifiers($attributes['NAME']) + ' '
          
        
        if array_key_exists('TYPE', $attributes)
          $sql+=' ' + $attributes['TYPE']
          
          if array_key_exists('CONSTRAINT', $attributes)
            switch $attributes['TYPE']
              when 'decimal','float','numeric'
                $sql+='(' + implode(',', $attributes['CONSTRAINT']) + ')'
              when 'enum','set'
                $sql+='("' + implode('","', $attributes['CONSTRAINT']) + '")'
              else
                $sql+='(' + $attributes['CONSTRAINT'] + ')'
                
        if array_key_exists('UNSIGNED', $attributes) and $attributes['UNSIGNED'] is true
          $sql+=' UNSIGNED'
          
        if array_key_exists('DEFAULT', $attributes)
          $sql+=' DEFAULT \'' + $attributes['DEFAULT'] + '\''

        if array_key_exists('NULL', $attributes)
          $sql+=if ($attributes['NULL'] is true) then ' NULL' else ' NOT NULL'
          
        if array_key_exists('AUTO_INCREMENT', $attributes) and $attributes['AUTO_INCREMENT'] is true
          $sql+=' AUTO_INCREMENT'

      #  don't add a comma on the end of the last field
      if ++$current_field_count < count($fields)
        $sql+=','

    return $sql
    
  
  #
  # Create Table
  #
  # @private
  # @param  [String]  the table name
  # @param  [Mixed]  the fields
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
    
    $sql+=@_process_fields($fields)

    log_message 'debug', '_create_table 1 $primary_keys %j', $primary_keys

    if count($primary_keys) > 0
      $key_name = @db._protect_identifiers(implode('_', $primary_keys))
      $primary_keys = @db._protect_identifiers($primary_keys)
      $sql+=",\n\tPRIMARY KEY " + $key_name + " (" + implode(', ', $primary_keys) + ")"

    if is_array($keys) and count($keys) > 0
      for $key in $keys
        if is_array($key)
          $key_name = @db._protect_identifiers(implode('_', $key))
          $key = @db._protect_identifiers($key)

        else
          $key_name = @db._protect_identifiers($key)
          $key = [$key_name]

        $sql+=",\n\tKEY #{$key_name} (" + implode(', ', $key) + ")"

    $sql+="\n) DEFAULT CHARACTER SET #{@db.char_set} COLLATE #{@db.dbcollat};"
    log_message 'debug', '_create_table 2 $primary_keys %j', $primary_keys

    return $sql
    
  
  #
  # Drop Table
  #
  # @private
  # @return	[String]
  #
  _drop_table : ($table) ->
    return "DROP TABLE IF EXISTS " + @db._escape_identifiers($table)
    
  
  #
  # Alter table query
  #
  # Generates a platform-specific query so that a table can be altered
  # Called by addColumn(), dropColumn(), and column_alter(),
  #
  # @private
  # @param  [String]  the ALTER type (ADD, DROP, CHANGE)
  # @param  [String]  the column name
  # @param  [Array]  fields
  # @param  [String]  the field after which we should add the new field
  # @return [Object]  #
  _alter_table : ($alter_type, $table, $fields, $after_field = '') ->
    $sql = 'ALTER TABLE ' + @db._protect_identifiers($table) + " $alter_type "
    
    #  DROP has everything it needs now.
    if $alter_type is 'DROP'
      return $sql + @db._protect_identifiers($fields)
      
    
    $sql+=@_process_fields($fields)
    
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
    
module.exports = system.db.mysql.MysqlForge

#  End of file mysql_forge.coffee
#  Location: ./system/database/drivers/mysql/mysql_forge.coffee