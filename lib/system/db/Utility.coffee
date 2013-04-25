#+--------------------------------------------------------------------+
#  Utility.coffee
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
# Database Utility Class
#
#
module.exports = class system.db.Utility extends system.db.Forge

  #
  # @property [Object] metadata cache
  #
  data_cache: null
  
  #
  # Constructor
  #
  # Grabs the CI super object instance so we can access it.
  #
  #
  constructor: ($controller, $db) ->

    super $controller, $db

    Object.defineProperties @,
      data_cache        : {enumerable: true, writeable: false, value: {}}

    log_message('debug', "Database Utility Class Initialized")
    
  
  #
  # List databases
  #
  # @return	bool
  #
  listDatabases: ($next) ->
    #  Is there a cached result?
    if @data_cache['db_names']?
      $next null, @data_cache['db_names']

    @db.query @_list_databases(), ($err, $query) =>

      if not $err
        $dbs = []
        if $query.num_rows > 0
          for $row in $query.result()
            $dbs.push $row[Object.keys($row)[0]]

        @data_cache['db_names'] = $dbs

      $next $err, @data_cache['db_names']
    
  
  #
  # Determine if a particular database exists
  #
  # @param  [String]
  # @return	[Boolean]
  #
  databaseExists: ($database_name) ->

    if @_database_exists?
      return @_database_exists($database_name)
      
    else 
      return if @listDatabases().indexOf($database_name) is -1 then false else true
      
    
  
  
  #
  # Optimize Table
  #
  # @param  [String]  the table name
  # @return	bool
  #
  optimizeTable: ($table_name, $next) ->
    $sql = @_optimize_table($table_name)
    
    if 'boolean' is typeof($sql)
      $next('db_must_use_set')

    @db.query $sql, ($err, $query) ->

      $res = $query.result() unless $err

      $next $err, $res
    
  
  #
  # Optimize Database
  #
  # @return	array
  #
  optimizeDatabase: ($next) ->

    $result = {}
    @db.listTables ($table_list) =>

      $sql_list = []
      for $table_name in $table_list
        $sql = @_optimize_table($table_name)
        $sql_list.push $sql unless 'boolean' is typeof($sql)

      @db.queryList $sql_list, ($err, $results) =>

        if not $err
          for $query in $results

            #  Build the result array...
            $res = $query.result()
            $res = $res[0]
            $key = $res.replace(@db.database + '.', '')
            $keys = Object.keys($res)
            delete $res[$keys[0]]
            $result[$key] = $res

        $next $err, $result


  #
  # Repair Table
  #
  # @param  [String]  the table name
  # @return	bool
  #
  repairTable: ($table_name, $next) ->
    $sql = @_repair_table($table_name)
    
    if 'boolean' is typeof($sql)
      $next $sql, []

    @db.query $sql, ($err, $query) ->
      $res = $query.result() unless $err
      $next $err, $res[Object.keys($res)[0]]
    
  
  #
  # Generate CSV from a query result object
  #
  # @param  [Object]  The query result object
  # @param  [String]  The delimiter - comma by default
  # @param  [String]  The newline character - \n by default
  # @param  [String]  The enclosure - double quote by default
  # @return	[String]
  #
  csvFromResult: ($query, $delim = ",", $newline = "\n", $enclosure = '"') ->
    if not 'object' is typeof($query) or  not $query.list_fields?
      show_error('You must submit a valid result object')
      
    
    $out = ''
    
    #  First generate the headings from the table column names
    for $name in $query.list_fields()
      $out+=$enclosure + $name.replace($enclosure, $enclosure + $enclosure) + $enclosure + $delim

    $out = $out.replace(/[\s]+$/g, '')
    $out+=$newline
    
    #  Next blast through the result array and build out the rows
    for $row in $query.result_array()
      for $item in $row
        $out+=$enclosure + $item.replace($enclosure, $enclosure + $enclosure) + $enclosure + $delim
        
      $out = $out.replace(/[\s]+$/g, '')
      $out+=$newline
      
    
    return $out
    
  
  #
  # Generate XML data from a query result object
  #
  # @param  [Object]  The query result object
  # @param  [Array]  Any preferences
  # @return	[String]
  #
  xmlFromResult: ($query, $params = {}) ->
    if not 'object' is typeof($query) or  not $query.list_fields?
      show_error('You must submit a valid result object')
      
    
    $root     = $params.root ? 'root'
    $element  = $params.element ? 'element'
    $newline  = $params.newline ? "\n"
    $tab      = $params.tab ? "\t"

    #  Load the xml helper
    xml = @load.helper('xml')
    
    #  Generate the result
    $xml = "<#{$root}>" + $newline
    for $row in $query.result_array()
      $xml+=$tab + "<#{$element}>" + $newline
      
      for $key, $val of $row
        $xml+=$tab + $tab + "<#{$key}>" + xml.xml_convert($val) + "</#{$key}>" + $newline
        
      $xml+=$tab + "</#{$element}>" + $newline
      
    $xml+="</#{$root}>" + $newline
    
    return $xml
    
  
  #
  # Database Backup
  #
  # @return [Void]
  #
  backup: ($prefs = {}, $next) ->
    #  If the parameters have not been submitted as an
    #  array then we know that it is simply the table
    #  name, which is a valid short cut.
    if 'string' is typeof($prefs)
      $prefs = {tables: $prefs}
      
    #
    #  Set defaults
    #
    $prefs.__proto__ =
      tables      :[]
      ignore      :[]
      filename    :''
      format      :'gzip' #  gzip, zip, txt
      add_drop    :true
      add_insert  :true
      newline     :"\n"
      
    #
    #  Are we backing up a complete database or individual tables?
    #  If no table names were submitted we'll fetch the entire table list
    #
    if $prefs['tables'].length is 0
      @db.list_tables ($err, $result) =>
        return $next $errif $err
        $next 'no tables to backup' if $result.length is 0
        $prefs['tables'] = $result
        @backup $prefs, $next
      return

    #
    #  Validate the format
    #
    if ['gzip', 'zip', 'txt'].indexOf($prefs['format']) is -1
      $prefs['format'] = 'txt'
      
    #
    #  Is the encoder supported?  If not, we'll either issue an
    #  error or use plain text depending on the debug settings
    #
    if ($prefs['format'] is 'gzip' and  not function_exists('gzencode')) or ($prefs['format'] is 'zip' and  not function_exists('gzcompress'))
      if @db.db_debug
        return @db.display_error('db_unsuported_compression')
        
      
      $prefs['format'] = 'txt'
      
    #
    #  Set the filename if not provided - Only needed with Zip files
    #
    if $prefs['filename'] is '' and $prefs['format'] is 'zip'
      $prefs['filename'] = if $prefs['tables'].length is 1 then $prefs['tables'] else @db.database
      $prefs['filename']+='_' + date('Y-m-d_H-i', time())
      
    #
    #  Was a Gzip file requested?
    #
    if $prefs['format'] is 'gzip'
      return gzencode(@_backup($prefs))
      
    #
    #  Was a text file requested?
    #
    if $prefs['format'] is 'txt'
      return @_backup($prefs)
      
    #
    #  Was a Zip file requested?
    #
    if $prefs['format'] is 'zip'
      #
      #  Remove default *.zip extendsion from file name
      #
      if /.+?\.zip$/.test($prefs['filename'])
        $prefs['filename'] = $prefs['filename'].replace('.zip', '')
        
      #
      #  Tack on the ".sql" file extension if needed
      #
      if not /.+?\.sql$/.test($prefs['filename'])
        $prefs['filename']+='.sql'
        
      #
      #  Load the Zip class and output it
      #
      @zip = @load.library('zip')
      @zip.add_data($prefs['filename'], @_backup($prefs))
      return @zip.get_zip()
      
