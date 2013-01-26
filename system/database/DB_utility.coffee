#+--------------------------------------------------------------------+
#  DB_utility.coffee
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
# @copyright  Copyright (c) 2012, Dark Overlord of Data
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
class global.Exspresso_DB_utility extends Exspresso_DB_forge
  
  db: null
  data_cache: {}
  
  #
  # Constructor
  #
  # Grabs the CI super object instance so we can access it.
  #
  #
  constructor: ($Exspresso) ->
    #  Assign the main database object to $this->db
    super($Exspresso)
    
    log_message('debug', "Database Utility Class Initialized")
    
  
  #  --------------------------------------------------------------------
  
  #
  # List databases
  #
  # @access	public
  # @return	bool
  #
  list_databases: ($callback) ->
    #  Is there a cached result?
    if @data_cache['db_names']?
      $callback null, @data_cache['db_names']

    @db.query @_list_databases(), ($err, $query) =>

      if not $err
        $dbs = []
        if $query.num_rows > 0
          for $row in $query.result_array()
            $dbs.push current($row)

        @data_cache['db_names'] = $dbs

      $callback $err, @data_cache['db_names']
    
  
  #  --------------------------------------------------------------------
  
  #
  # Determine if a particular database exists
  #
  # @access	public
  # @param	string
  # @return	boolean
  #
  database_exists: ($database_name) ->
    #  Some databases won't have access to the list_databases() function, so
    #  this is intended to allow them to override with their own functions as
    #  defined in $driver_utility.php
    if method_exists(@, '_database_exists')
      return @_database_exists($database_name)
      
    else 
      return if not in_array($database_name, @list_databases()) then false else true
      
    
  
  
  #  --------------------------------------------------------------------
  
  #
  # Optimize Table
  #
  # @access	public
  # @param	string	the table name
  # @return	bool
  #
  optimize_table: ($table_name, $callback) ->
    $sql = @_optimize_table($table_name)
    
    if is_bool($sql)
      $callback('db_must_use_set')

    @db.query $sql, ($err, $query) ->

      $res = $query.result_array() unless $err

      $callback current($err, $res)
    
  
  #  --------------------------------------------------------------------

  #
  # Optimize Database
  #
  # @access	public
  # @return	array
  #
  optimize_database: ($callback) ->

    $result = {}
    @db.list_tables ($table_list) =>

      $sql_list = []
      for $table_name in $table_list
        $sql = @_optimize_table($table_name)
        $sql_list.push $sql unless is_bool($sql)

      @db.query_list $sql_list, ($err, $results) =>

        if not $err
          for $query in $results

            #  Build the result array...
            $res = $query.result_array()
            $res = current($res)
            $key = str_replace(@db.database + '.', '', current($res))
            $keys = array_keys($res)
            delete $res[$keys[0]]
            $result[$key] = $res

        $callback $err, $result


  #  --------------------------------------------------------------------
  
  #
  # Repair Table
  #
  # @access	public
  # @param	string	the table name
  # @return	bool
  #
  repair_table: ($table_name, $callback) ->
    $sql = @_repair_table($table_name)
    
    if is_bool($sql)
      $callback $sql, []

    @db.query $sql, ($err, $query) ->
      $res = $query.result_array() unless $err
      $callback $err, current($res)
    
  
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
  csv_from_result: ($query, $delim = ",", $newline = "\n", $enclosure = '"') ->
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
  xml_from_result: ($query, $params = {}) ->
    if not is_object($query) or  not method_exists($query, 'list_fields')
      show_error('You must submit a valid result object')
      
    
    $root     = $params.root ? 'root'
    $element  = $params.element ? 'element'
    $newline  = $params.newline ? "\n"
    $tab      = $params.tab ? "\t"

    #  Load the xml helper
    @Exspresso.load.helper('xml')
    
    #  Generate the result
    $xml = "<#{$root}>" + $newline
    for $row in $query.result_array()
      $xml+=$tab + "<#{$element}>" + $newline
      
      for $key, $val of $row
        $xml+=$tab + $tab + "<#{$key}>" + xml_convert($val) + "</#{$key}>" + $newline
        
      $xml+=$tab + "</#{$element}>" + $newline
      
    $xml+="</#{$root}>" + $newline
    
    return $xml
    
  
  #  --------------------------------------------------------------------
  
  #
  # Database Backup
  #
  # @access	public
  # @return	void
  #
  backup: ($prefs = {}, $callback) ->
    #  If the parameters have not been submitted as an
    #  array then we know that it is simply the table
    #  name, which is a valid short cut.
    if is_string($prefs)
      $prefs = array('tables', $prefs)
      
    
    #  ------------------------------------------------------
    
    #  Set up our default preferences
    $prefs.__proto__ =
      'tables':[],
      'ignore':[],
      'filename':'', 
      'format':'gzip', #  gzip, zip, txt
      'add_drop':true, 
      'add_insert':true, 
      'newline':"\n"
      

    #  ------------------------------------------------------
    
    #  Are we backing up a complete database or individual tables?
    #  If no table names were submitted we'll fetch the entire table list
    if count($prefs['tables']) is 0
      @db.list_tables ($err, $result) =>
        if $err then $callback $err
        if count($result) is 0 then $callback 'no tables to backup'
        $prefs['tables'] = $result
        @backup $prefs, $callback
      return


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
      
      @Exspresso.load.library('zip')
      @Exspresso.zip.add_data($prefs['filename'], @_backup($prefs))
      return @Exspresso.zip.get_zip()
      
module.exports = Exspresso_DB_utility


#  End of file DB_utility.php 
#  Location: ./system/database/DB_utility.php 