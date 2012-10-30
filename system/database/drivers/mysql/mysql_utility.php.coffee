#+--------------------------------------------------------------------+
#  mysql_utility.coffee
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


{_escape_identifiers, count, database, db, defined, escape, extract, in_array, mysql_fetch_field, mysql_field_type, name, num_rows, preg_replace, query, result_array, result_id, strtolower}  = require(FCPATH + 'lib')


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
# MySQL Utility Class
#
# @category	Database
# @author		ExpressionEngine Dev Team
# @link		http://codeigniter.com/user_guide/database/
#
class CI_DB_mysql_utility extends CI_DB_utility
  
  #
  # List databases
  #
  # @access	private
  # @return	bool
  #
  _list_databases :  ->
    return "SHOW DATABASES"
    
  
  #  --------------------------------------------------------------------
  
  #
  # Optimize table query
  #
  # Generates a platform-specific query so that a table can be optimized
  #
  # @access	private
  # @param	string	the table name
  # @return	object
  #
  _optimize_table : ($table) ->
    return "OPTIMIZE TABLE " + @db._escape_identifiers($table)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Repair table query
  #
  # Generates a platform-specific query so that a table can be repaired
  #
  # @access	private
  # @param	string	the table name
  # @return	object
  #
  _repair_table : ($table) ->
    return "REPAIR TABLE " + @db._escape_identifiers($table)
    
  
  #  --------------------------------------------------------------------
  #
  # MySQL Export
  #
  # @access	private
  # @param	array	Preferences
  # @return	mixed
  #
  _backup : ($params = {}) ->
    if count($params) is 0
      return false
      
    
    #  Extract the prefs for simplicity
    extract($params)
    
    #  Build the output
    $output = ''
    for $table in $tables
      #  Is the table in the "ignore" list?
      if in_array($table, $ignore, true)
        continue
        
      
      #  Get the table schema
      $query = @db.query("SHOW CREATE TABLE `" + @db.database + '`.' + $table)
      
      #  No result means the table name was invalid
      if $query is false
        continue
        
      
      #  Write out the table schema
      $output+='#' + $newline + '# TABLE STRUCTURE FOR: ' + $table + $newline + '#' + $newline + $newline
      
      if $add_drop is true
        $output+='DROP TABLE IF EXISTS ' + $table + ';' + $newline + $newline
        
      
      $i = 0
      $result = $query.result_array()
      for $val in $result[0]
        if $i++2
          $output+=$val + ';' + $newline + $newline
          
        
      
      #  If inserts are not needed we're done...
      if $add_insert is false
        continue
        
      
      #  Grab all the data from the current table
      $query = @db.query("SELECT * FROM $table")
      
      if $query.num_rows() is 0
        continue
        
      
      #  Fetch the field names and determine if the field is an
      #  integer type.  We use this info to decide whether to
      #  surround the data with quotes or not
      
      $i = 0
      $field_str = ''
      $is_int = {}
      while $field = mysql_fetch_field($query.result_id))#  Most versions of MySQL store timestamp as a string#  Create a string of field names$is_int[$i] = if (in_array(strtolower(mysql_field_type($query.result_id, $i)), ['tinyint', 'smallint', 'mediumint', 'int', 'bigint'], # , 'timestamp'),
      true)
      ) then true else false$field_str+='`' + $field.name + '`, '
      $i++
      }
      
      #  Trim off the end comma
      $field_str = preg_replace("/, $/", "", $field_str)
      
      
      #  Build the insert string
      for $row in $query.result_array()
        $val_str = ''
        
        $i = 0
        for $v in $row
          #  Is the value NULL?
          if $v is null
            $val_str+='NULL'
            
          else 
            #  Escape the data if it's not an integer
            if $is_int[$i] is false
              $val_str+=@db.escape($v)
              
            else 
              $val_str+=$v
              
            
          
          #  Append a comma
          $val_str+=', '
          $i++
          
        
        #  Remove the comma at the end of the string
        $val_str = preg_replace("/, $/", "", $val_str)
        
        #  Build the INSERT string
        $output+='INSERT INTO ' + $table + ' (' + $field_str + ') VALUES (' + $val_str + ');' + $newline
        
      
      $output+=$newline + $newline
      
    
    return $output
    
  

register_class 'CI_DB_mysql_utility', CI_DB_mysql_utility
module.exports = CI_DB_mysql_utility

#  End of file mysql_utility.php 
#  Location: ./system/database/drivers/mysql/mysql_utility.php 