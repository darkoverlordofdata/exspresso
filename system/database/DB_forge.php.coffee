#+--------------------------------------------------------------------+
#  DB_forge.coffee
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
{_alter_table, _create_database, _create_table, _drop_database, _drop_table, _rename_table, array_merge, count, db, dbprefix, defined, get_instance, is_array, is_bool, is_string, query, strpos}  = require(FCPATH + 'lib')
{config_item, get_class, get_config, is_loaded, load_class, load_new, load_object, log_message, register_class} = require(BASEPATH + 'core/Common')

if not defined('BASEPATH') then die 'No direct script access allowed'
#
# Code Igniter
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
# Database Utility Class
#
# @category	Database
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/database/
#
class CI_DB_forge
  
  fields: {}
  keys: {}
  primary_keys: {}
  db_char_set: ''
  
  #
  # Constructor
  #
  # Grabs the CI super object instance so we can access it.
  #
  #
  CI_DB_forge :  ->
    #  Assign the main database object to $this->db
    $CI = get_instance()
    @db = $CI.db
    log_message('debug', "Database Forge Class Initialized")
    
  
  #  --------------------------------------------------------------------
  
  #
  # Create database
  #
  # @access	public
  # @param	string	the database name
  # @return	bool
  #
  create_database : ($db_name) ->
    $sql = @_create_database($db_name)
    
    if is_bool($sql)
      return $sql
      
    
    return @db.query($sql)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Drop database
  #
  # @access	public
  # @param	string	the database name
  # @return	bool
  #
  drop_database : ($db_name) ->
    $sql = @_drop_database($db_name)
    
    if is_bool($sql)
      return $sql
      
    
    return @db.query($sql)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Add Key
  #
  # @access	public
  # @param	string	key
  # @param	string	type
  # @return	void
  #
  add_key : ($key = '', $primary = false) ->
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
      
    
  
  #  --------------------------------------------------------------------
  
  #
  # Add Field
  #
  # @access	public
  # @param	string	collation
  # @return	void
  #
  add_field : ($field = '') ->
    if $field is ''
      show_error('Field information is required.')
      
    
    if is_string($field)
      if $field is 'id'
        @add_field(
          'id':
            'type':'INT', 
            'constraint':9, 
            'auto_increment':true
            
          )
        @add_key('id', true)
        
      else 
        if strpos($field, ' ') is false
          show_error('Field information is required for that operation.')
          
        
        @fields.push $field
        
      
    
    if is_array($field)
      @fields = array_merge(@fields, $field)
      
    
    
  
  #  --------------------------------------------------------------------
  
  #
  # Create Table
  #
  # @access	public
  # @param	string	the table name
  # @return	bool
  #
  create_table : ($table = '', $if_not_exists = false) ->
    if $table is ''
      show_error('A table name is required for that operation.')
      
    
    if count(@fields) is 0
      show_error('Field information is required.')
      
    
    $sql = @_create_table(@db.dbprefix + $table, @fields, @primary_keys, @keys, $if_not_exists)
    
    @_reset()
    return @db.query($sql)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Drop Table
  #
  # @access	public
  # @param	string	the table name
  # @return	bool
  #
  drop_table : ($table_name) ->
    $sql = @_drop_table(@db.dbprefix + $table_name)
    
    if is_bool($sql)
      return $sql
      
    
    return @db.query($sql)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Rename Table
  #
  # @access	public
  # @param	string	the old table name
  # @param	string	the new table name
  # @return	bool
  #
  rename_table : ($table_name, $new_table_name) ->
    if $table_name is '' or $new_table_name is ''
      show_error('A table name is required for that operation.')
      
    
    $sql = @_rename_table($table_name, $new_table_name)
    return @db.query($sql)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Column Add
  #
  # @access	public
  # @param	string	the table name
  # @param	string	the column name
  # @param	string	the column definition
  # @return	bool
  #
  add_column : ($table = '', $field = {}, $after_field = '') ->
    if $table is ''
      show_error('A table name is required for that operation.')
      
    
    #  add field info into field array, but we can only do one at a time
    #  so we cycle through
    
    for $k, $v of $field
      @add_field($k:$field[$k])
      
      if count(@fields) is 0
        show_error('Field information is required.')
        
      
      $sql = @_alter_table('ADD', @db.dbprefix + $table, @fields, $after_field)
      
      @_reset()
      
      if @db.query($sql) is false
        return false
        
      
    
    return true
    
    
  
  #  --------------------------------------------------------------------
  
  #
  # Column Drop
  #
  # @access	public
  # @param	string	the table name
  # @param	string	the column name
  # @return	bool
  #
  drop_column : ($table = '', $column_name = '') ->
    
    if $table is ''
      show_error('A table name is required for that operation.')
      
    
    if $column_name is ''
      show_error('A column name is required for that operation.')
      
    
    $sql = @_alter_table('DROP', @db.dbprefix + $table, $column_name)
    
    return @db.query($sql)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Column Modify
  #
  # @access	public
  # @param	string	the table name
  # @param	string	the column name
  # @param	string	the column definition
  # @return	bool
  #
  modify_column : ($table = '', $field = {}) ->
    if $table is ''
      show_error('A table name is required for that operation.')
      
    
    #  add field info into field array, but we can only do one at a time
    #  so we cycle through
    
    for $k, $v of $field
      #  If no name provided, use the current name
      if not $field[$k]['name']? 
        $field[$k]['name'] = $k
        
      
      @add_field($k:$field[$k])
      
      if count(@fields) is 0
        show_error('Field information is required.')
        
      
      $sql = @_alter_table('CHANGE', @db.dbprefix + $table, @fields)
      
      @_reset()
      
      if @db.query($sql) is false
        return false
        
      
    
    return true
    
  
  #  --------------------------------------------------------------------
  
  #
  # Reset
  #
  # Resets table creation vars
  #
  # @access	private
  # @return	void
  #
  _reset :  ->
    @fields = {}
    @keys = {}
    @primary_keys = {}
    
  
  

register_class 'CI_DB_forge', CI_DB_forge
module.exports = CI_DB_forge

#  End of file DB_forge.php 
#  Location: ./system/database/DB_forge.php 