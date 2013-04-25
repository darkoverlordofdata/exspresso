#+--------------------------------------------------------------------+
#  sqlite_forge.coffee
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
# SQLite Forge Class
#
#
module.exports = class system.db.sqlite.SqliteForge extends system.db.Forge

  fs = require('fs')

  #
  # Create database
  #
  # @access	public
  # @param	string	the database name
  # @return	bool
  #
  _create_database :  ->
    #  In SQLite, a database is created when you connect to the database.
    #  We'll return TRUE so that an error isn't generated
    return true
    
  
  #
  # Drop database
  #
  # @access	private
  # @param	string	the database name
  # @return	bool
  #
  _drop_database : ($name) ->
    if not fs.existsSync(@db.database) or not fs.unlinkSync(@db.database)
      if @db.db_debug
        return @db.display_error('db_unable_to_drop')
        
      return false
      
    return true
    
  #
  # Create Table
  #
  # @access	private
  # @param	string	the table name
  # @param	array	the fields
  # @param	mixed	primary key(s)
  # @param	mixed	key(s)
  # @param	boolean	should 'IF NOT EXISTS' be added to the SQL
  # @return	bool
  #
  _create_table : ($table, $fields, $primary_keys, $keys, $if_not_exists) ->
    $sql = 'CREATE TABLE '
    
    #  IF NOT EXISTS added to SQLite in 3.3.0
    if $if_not_exists is true # and version_compare(@db._version(), '3.3.0', '>=') is true
      $sql+='IF NOT EXISTS '
      
    
    $sql+=@db._escape_identifiers($table) + "("
    $current_field_count = 0
    $pkey = false
    
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

        if $attributes.AUTO_INCREMENT? and $attributes.AUTO_INCREMENT is true and $primary_keys.indexOf($field) is 0
          $pkey = true
          $sql+=' INTEGER PRIMARY KEY'

        else

          if $attributes.UNSIGNED? and $attributes.UNSIGNED is true
            $sql+=' UNSIGNED'

          if $attributes.TYPE is 'tinyint' then $attributes.TYPE = 'int'
          $sql+=' ' + $attributes.TYPE

          if $attributes.CONSTRAINT?
            $sql+='(' + $attributes['CONSTRAINT'] + ')'

          if $attributes.DEFAULT?
            $sql+=' DEFAULT \'' + $attributes.DEFAULT + '\''

          if $attributes.NULL? and $attributes.NULL is true
            $sql+=' NULL'

          else
            $sql+=' NOT NULL'

          if $attributes.AUTO_INCREMENT? and $attributes.AUTO_INCREMENT is true
            $sql+=' AUTOINCREMENT'

      #  don't add a comma on the end of the last field
      if ++$current_field_count < keys($fields).length
        $sql+=','

    if $primary_keys.length > 0 and $pkey is false
      $primary_keys = @db._protect_identifiers($primary_keys)
      $sql+=",\n\tPRIMARY KEY (" + $primary_keys.join(', ') + ")"

    $sql+="\n)"

    if Array.isArray($keys) and $keys.length > 0


      for $key in $keys
        if Array.isArray($key)
          $key_name = @db._protect_identifiers($key.join('_'))
          $key = @db._protect_identifiers($key)

        else
          $key_name = @db._protect_identifiers($key)
          $key = [$key_name]

        $sql+=";\n\tCREATE INDEX #{$key_name} ON " +@db._escape_identifiers($table) + " (" + $key.join(', ') + ")"

    return $sql

  
  #
  # Drop Table
  #
  # @access	private
  # @return	bool
  #
  _drop_table : ($table) ->
    "DROP TABLE IF EXISTS " + @db._escape_identifiers($table)


  #
  # Alter table query
  #
  # Generates a platform-specific query so that a table can be altered
  # Called by add_column(), drop_column(), and column_alter(),
  #
  # @access	private
  # @param	string	the ALTER type (ADD, DROP, CHANGE)
  # @param	string	the column name
  # @param	string	the table name
  # @param	string	the column definition
  # @param	string	the default value
  # @param	boolean	should 'NOT NULL' be added
  # @param	string	the field after which we should add the new field
  # @return	object
  #
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
  # @access	private
  # @param	string	the old table name
  # @param	string	the new table name
  # @return	string
  #
  _rename_table : ($table_name, $new_table_name) ->
    $sql = 'ALTER TABLE ' + @db._protect_identifiers($table_name) + " RENAME TO " + @db._protect_identifiers($new_table_name)
    return $sql
    
  
