#+--------------------------------------------------------------------+
#  DB_utility.coffee
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
{_backup, _database_exists, _list_databases, _optimize_table, _repair_table, add_data, array_keys, count, current, database, date, db_debug, defined, display_error, extract, function_exists, get_instance, get_zip, gzencode, helper, in_array, is_bool, is_object, is_string, library, list_fields, list_tables, load, method_exists, num_rows, preg_match, query, result_array, rtrim, str_replace, time, xml_convert, zip}  = require(FCPATH + 'pal')
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
class CI_DB_utility extends CI_DB_forge
  
  db: {}
  data_cache: {}
  
  #
  # Constructor
  #
  # Grabs the CI super object instance so we can access it.
  #
  #
  CI_DB_utility :  ->
    #  Assign the main database object to $this->db
    $CI = get_instance()
    @db = $CI.db
    
    log_message('debug', "Database Utility Class Initialized")
    
  
  #  --------------------------------------------------------------------
  
  #
  # List databases
  #
  # @access	public
  # @return	bool
  #
  list_databases :  ->
    #  Is there a cached result?
    if @data_cache['db_names']? 
      return @data_cache['db_names']
      
    
    $query = @db.query(@_list_databases())
    $dbs = {}
    if $query.num_rows() > 0
      for $row in $query.result_array()
        $dbs.push current($row)
        
      
    
    @data_cache['db_names'] = $dbs
    return @data_cache['db_names']
    
  
  #  --------------------------------------------------------------------
  
  #
  # Determine if a particular database exists
  #
  # @access	public
  # @param	string
  # @return	boolean
  #
  database_exists : ($database_name) ->
    #  Some databases won't have access to the list_databases() function, so
    #  this is intended to allow them to override with their own functions as
    #  defined in $driver_utility.php
    if method_exists(@, '_database_exists')
      return @_database_exists($database_name)
      
    else 
      return if ( not in_array($database_name, @list_databases())) then false else true
      
    
  
  
  #  --------------------------------------------------------------------
  
  #
  # Optimize Table
  #
  # @access	public
  # @param	string	the table name
  # @return	bool
  #
  optimize_table : ($table_name) ->
    $sql = @_optimize_table($table_name)
    
    if is_bool($sql)
      show_error('db_must_use_set')
      
    
    $query = @db.query($sql)
    $res = $query.result_array()
    
    #  Note: Due to a bug in current() that affects some versions
    #  of PHP we can not pass function call directly into it
    return current($res)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Optimize Database
  #
  # @access	public
  # @return	array
  #
  optimize_database :  ->
    $result = {}
    for $table_name in @db.list_tables()
      $sql = @_optimize_table($table_name)
      
      if is_bool($sql)
        return $sql
        
      
      $query = @db.query($sql)
      
      #  Build the result array...
      #  Note: Due to a bug in current() that affects some versions
      #  of PHP we can not pass function call directly into it
      $res = $query.result_array()
      $res = current($res)
      $key = str_replace(@db.database + '.', '', current($res))
      $keys = array_keys($res)
      delete $res[$keys[0]]
      
      $result[$key] = $res
      
    
    return $result
    
  
  #  --------------------------------------------------------------------
  
  #
  # Repair Table
  #
  # @access	public
  # @param	string	the table name
  # @return	bool
  #
  repair_table : ($table_name) ->
    $sql = @_repair_table($table_name)
    
    if is_bool($sql)
      return $sql
      
    
    $query = @db.query($sql)
    
    #  Note: Due to a bug in current() that affects some versions
    #  of PHP we can not pass function call directly into it
    $res = $query.result_array()
    return current($res)
    
  
  #  --------------------------------------------------------------------
  
  #
  # Generate CSV from a query result object
  #
  # @access	public
  # @param	object	The query result object
  # @param	string	The delimiter - comma by default
  # @param	string	The newline character - \n by default
  # @param	string	The enclosure - double quote by default
  # @return	string
  #
  csv_from_result : ($query, $delim = ",", $newline = "\n", $enclosure = '"') ->
    if not is_object($query) or  not method_exists($query, 'list_fields')
      show_error('You must submit a valid result object')
      
    
    $out = ''
    
    #  First generate the headings from the table column names
    for $name in $query.list_fields()
      $out+=$enclosure + str_replace($enclosure, $enclosure + $enclosure, $name) + $enclosure + $delim
      
    
    $out = rtrim($out)
    $out+=$newline
    
    #  Next blast through the result array and build out the rows
    for $row in $query.result_array()
      for $item in $row
        $out+=$enclosure + str_replace($enclosure, $enclosure + $enclosure, $item) + $enclosure + $delim
        
      $out = rtrim($out)
      $out+=$newline
      
    
    return $out
    
  
  #  --------------------------------------------------------------------
  
  #
  # Generate XML data from a query result object
  #
  # @access	public
  # @param	object	The query result object
  # @param	array	Any preferences
  # @return	string
  #
  xml_from_result : ($query, $params = {}) ->
    if not is_object($query) or  not method_exists($query, 'list_fields')
      show_error('You must submit a valid result object')
      
    
    #  Set our default values
    for $key, $val of 'root':'root', 'element':'element', 'newline':"\n", 'tab':"\t"
      if not $params[$key]? 
        $params[$key] = $val
        
      
    
    #  Create variables for convenience
    extract($params)
    
    #  Load the xml helper
    $CI = get_instance()
    $CI.load.helper('xml')
    
    #  Generate the result
    $xml = "<{$root}>" + $newline
    for $row in $query.result_array()
      $xml+=$tab + "<{$element}>" + $newline
      
      for $key, $val of $row
        $xml+=$tab + $tab + "<{$key}>" + xml_convert($val) + "</{$key}>" + $newline
        
      $xml+=$tab + "</{$element}>" + $newline
      
    $xml+="</$root>" + $newline
    
    return $xml
    
  
  #  --------------------------------------------------------------------
  
  #
  # Database Backup
  #
  # @access	public
  # @return	void
  #
  backup : ($params = {}) ->
    #  If the parameters have not been submitted as an
    #  array then we know that it is simply the table
    #  name, which is a valid short cut.
    if is_string($params)
      $params = 'tables':$params
      
    
    #  ------------------------------------------------------
    
    #  Set up our default preferences
    $prefs = 
      'tables':{}, 
      'ignore':{}, 
      'filename':'', 
      'format':'gzip', #  gzip, zip, txt
      'add_drop':true, 
      'add_insert':true, 
      'newline':"\n"
      
    
    #  Did the user submit any preferences? If so set them....
    if count($params) > 0
      for $key, $val of $prefs
        if $params[$key]? 
          $prefs[$key] = $params[$key]
          
        
      
    
    #  ------------------------------------------------------
    
    #  Are we backing up a complete database or individual tables?
    #  If no table names were submitted we'll fetch the entire table list
    if count($prefs['tables']) is 0
      $prefs['tables'] = @db.list_tables()
      
    
    #  ------------------------------------------------------
    
    #  Validate the format
    if not in_array($prefs['format'], ['gzip', 'zip', 'txt'], true)
      $prefs['format'] = 'txt'
      
    
    #  ------------------------------------------------------
    
    #  Is the encoder supported?  If not, we'll either issue an
    #  error or use plain text depending on the debug settings
    if ($prefs['format'] is 'gzip' and  not function_exists('gzencode')) or ($prefs['format'] is 'zip' and  not function_exists('gzcompress'))
      if @db.db_debug
        return @db.display_error('db_unsuported_compression')
        
      
      $prefs['format'] = 'txt'
      
    
    #  ------------------------------------------------------
    
    #  Set the filename if not provided - Only needed with Zip files
    if $prefs['filename'] is '' and $prefs['format'] is 'zip'
      $prefs['filename'] = if (count($prefs['tables']) is 1) then $prefs['tables'] else @db.database
      $prefs['filename']+='_' + date('Y-m-d_H-i', time())
      
    
    #  ------------------------------------------------------
    
    #  Was a Gzip file requested?
    if $prefs['format'] is 'gzip'
      return gzencode(@_backup($prefs))
      
    
    #  ------------------------------------------------------
    
    #  Was a text file requested?
    if $prefs['format'] is 'txt'
      return @_backup($prefs)
      
    
    #  ------------------------------------------------------
    
    #  Was a Zip file requested?
    if $prefs['format'] is 'zip'
      #  If they included the .zip file extension we'll remove it
      if preg_match("|.+?\.zip$|", $prefs['filename'])
        $prefs['filename'] = str_replace('.zip', '', $prefs['filename'])
        
      
      #  Tack on the ".sql" file extension if needed
      if not preg_match("|.+?\.sql$|", $prefs['filename'])
        $prefs['filename']+='.sql'
        
      
      #  Load the Zip class and output it
      
      $CI = get_instance()
      $CI.load.library('zip')
      $CI.zip.add_data($prefs['filename'], @_backup($prefs))
      return $CI.zip.get_zip()
      
    
    
  
  

register_class 'CI_DB_utility', CI_DB_utility
module.exports = CI_DB_utility


#  End of file DB_utility.php 
#  Location: ./system/database/DB_utility.php 