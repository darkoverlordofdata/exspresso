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
# This file was ported from php to coffee-script using php2coffee v6.6.6
#
#

{APPPATH, BASEPATH, ENVIRONMENT, EXT, FCPATH, SYSDIR, WEBROOT} = require(process.cwd() + '/index')
{_escape_identifiers, _protect_identifiers, _version, array_change_key_case, array_key_exists, count, database, db, db_debug, defined, display_error, file_exists, implode, is_array, is_numeric, unlink, version_compare}  = require(FCPATH + 'pal')
{config_item, get_class, get_config, is_loaded, load_class, load_new, load_object, log_message, register_class} = require(BASEPATH + 'core/Common')

if not defined('BASEPATH') then die 'No direct script access allowed'
#
# CodeIgniter
#
# An open source application development framework for PHP 5.1.6 or newer
#
# @package		CodeIgniter
# @author		ExpressionEngine Dev Team
# @copyright	Copyright (c) 2008 - 2011, EllisLab, Inc.
# @license		http://codeigniter.com/user_guide/license.html
# @link		http://codeigniter.com
# @since		Version 1.0
# @filesource
#

#  ------------------------------------------------------------------------

#
# SQLite Forge Class
#
# @category	Database
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/database/
#
class CI_DB_sqlite_forge extends CI_DB_forge
  
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
    
  
  #  --------------------------------------------------------------------
  
  #
  # Drop database
  #
  # @access	private
  # @param	string	the database name
  # @return	bool
  #
  _drop_database : ($name) ->
    if not file_exists(@db.database) or  not unlink(@db.database)
      if @db.db_debug
        return @db.display_error('db_unable_to_drop')
        
      return false
      
    return true
    
  #  --------------------------------------------------------------------
  
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
    if $if_not_exists is true and version_compare(@db._version(), '3.3.0', '>=') is true
      $sql+='IF NOT EXISTS '
      
    
    $sql+=@db._escape_identifiers($table) + "("
    $current_field_count = 0
    
    for $field, $attributes of $fields
      #  Numeric field names aren't allowed in databases, so if the key is
      #  numeric, we know it was assigned by PHP and the developer manually
      #  entered the field information, so we'll simply add it to the list
      if is_numeric($field)
        $sql+="\n\t$attributes"
        
      else 
        $attributes = array_change_key_case($attributes, CASE_UPPER)
        
        $sql+="\n\t" + @db._protect_identifiers($field)
        
        $sql+=' ' + $attributes['TYPE']
        
        if array_key_exists('CONSTRAINT', $attributes)
          $sql+='(' + $attributes['CONSTRAINT'] + ')'
          
        
        if array_key_exists('UNSIGNED', $attributes) and $attributes['UNSIGNED'] is true
          $sql+=' UNSIGNED'
          
        
        if array_key_exists('DEFAULT', $attributes)
          $sql+=' DEFAULT \'' + $attributes['DEFAULT'] + '\''
          
        
        if array_key_exists('NULL', $attributes) and $attributes['NULL'] is true
          $sql+=' NULL'
          
        else 
          $sql+=' NOT NULL'
          
        
        if array_key_exists('AUTO_INCREMENT', $attributes) and $attributes['AUTO_INCREMENT'] is true
          $sql+=' AUTO_INCREMENT'
          
        
      
      #  don't add a comma on the end of the last field
      if ++$current_field_count < count($fields)
        $sql+=','
        
      
    
    if count($primary_keys) > 0
      $primary_keys = @db._protect_identifiers($primary_keys)
      $sql+=",\n\tPRIMARY KEY (" + implode(', ', $primary_keys) + ")"
      
    
    if is_array($keys) and count($keys) > 0
      for $key in $keys
        if is_array($key)
          $key = @db._protect_identifiers($key)
          
        else 
          $key = [@db._protect_identifiers($key])
          
        
        $sql+=",\n\tUNIQUE (" + implode(', ', $key) + ")"
        
      
    
    $sql+="\n)"
    
    return $sql
    
  
  #  --------------------------------------------------------------------
  
  #
  # Drop Table
  #
  #  Unsupported feature in SQLite
  #
  # @access	private
  # @return	bool
  #
  _drop_table : ($table) ->
    if @db.db_debug
      return @db.display_error('db_unsuported_feature')
      
    return {}
    
  
  #  --------------------------------------------------------------------
  
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
    $sql = 'ALTER TABLE ' + @db._protect_identifiers($table) + " $alter_type " + @db._protect_identifiers($column_name)
    
    #  DROP has everything it needs now.
    if $alter_type is 'DROP'
      #  SQLite does not support dropping columns
      #  http://www.sqlite.org/omitted.html
      #  http://www.sqlite.org/faq.html#q11
      return false
      
    
    $sql+=" $column_definition"
    
    if $default_value isnt ''
      $sql+=" DEFAULT \"$default_value\""
      
    
    if $null is null
      $sql+=' NULL'
      
    else 
      $sql+=' NOT NULL'
      
    
    if $after_field isnt ''
      $sql+=' AFTER ' + @db._protect_identifiers($after_field)
      
    
    return $sql
    
    
  
  #  --------------------------------------------------------------------
  
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
    
  

register_class 'CI_DB_sqlite_forge', CI_DB_sqlite_forge
module.exports = CI_DB_sqlite_forge

#  End of file sqlite_forge.php 
#  Location: ./system/database/drivers/sqlite/sqlite_forge.php 