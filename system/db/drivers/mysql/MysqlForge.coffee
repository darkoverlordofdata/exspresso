#+--------------------------------------------------------------------+
#  MysqlForge.coffee
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
# MySQL Forge Class
#
#
module.exports = class system.db.mysql.MysqlForge extends system.db.Forge
  
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
      if 'number' is typeof($field)
        $sql+="\n\t#{$attributes}"
        
      else
        $tmp = {}
        $tmp[$key.toUpperCase()] = $val for $key, $val of $attributes
        $attributes = $tmp

        $sql+="\n\t" + @db._protect_identifiers($field)
        
        if $attributes['NAME']?
          $sql+=' ' + @db._protect_identifiers($attributes['NAME']) + ' '
          
        
        if $attributes.TYPE?
          $sql+=' ' + $attributes.TYPE
          
          if $attributes.CONSTRAINT?
            switch $attributes.TYPE
              when 'decimal','float','numeric'
                $sql+='(' + $attributes.CONSTRAINT.join(',') + ')'
              when 'enum','set'
                $sql+='("' + $attributes.CONSTRAINT.join('","') + '")'
              else
                $sql+='(' + $attributes.CONSTRAINT + ')'
                
        if $attributes.UNSIGNED? and $attributes.UNSIGNED is true
          $sql+=' UNSIGNED'
          
        if $attributes.DEFAULT?
          $sql+=' DEFAULT \'' + $attributes.DEFAULT + '\''

        if $attributes.NULL?
          $sql+=if ($attributes.NULL is true) then ' NULL' else ' NOT NULL'
          
        if $attributes.AUTO_INCREMENT? and $attributes.AUTO_INCREMENT is true
          $sql+=' AUTO_INCREMENT'

      #  don't add a comma on the end of the last field
      if ++$current_field_count < keys($fields).length
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

    $sql+='IF NOT EXISTS ' if $if_not_exists is true

    $sql+=@db._escape_identifiers($table) + " ("

    $sql+=@_process_fields($fields)

    if $primary_keys.length > 0

      $key_name = @db._protect_identifiers($primary_keys.join('_'))
      $primary_keys = @db._protect_identifiers($primary_keys)
      $sql+=",\n\tPRIMARY KEY " + $key_name + " (" + $primary_keys.join(', ') + ")"

    if Array.isArray($keys) and $keys.length > 0

      for $key in $keys
        if Array.isArray($key)
          $key_name = @db._protect_identifiers($key.join('_'))
          $key = @db._protect_identifiers($key)

        else
          $key_name = @db._protect_identifiers($key)
          $key = [$key_name]

        $sql+=",\n\tKEY #{$key_name} (" + $key.join(', ') + ")"

    $sql+="\n) DEFAULT CHARACTER SET #{@db.char_set} COLLATE #{@db.dbcollat};"

  
  #
  # Drop Table
  #
  # @private
  # @return	[String]
  #
  _drop_table : ($table) ->
    "DROP TABLE IF EXISTS " + @db._escape_identifiers($table)
    
  
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

